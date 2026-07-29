import 'dart:async';
import 'dart:developer';

import 'package:app/business_logic/products/cubit/products_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/business_logic/tracking/tracking_cubit.dart';
import 'package:app/core/live_tracking/helpers/order_tracking_helper.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/common/paginated_response.dart';
import 'package:app/models/order/order_model.dart';
import 'package:app/models/selected_products/selected_products.dart';
import 'package:app/network/services/orders_services.dart';
import 'package:app/persentation/screens/layout/layout_screen.dart';
import 'package:app/persentation/screens/orders/order_done_screen.dart';
import 'package:app/persentation/widgets/force_makeAlert.dart';
import 'package:app/theme/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());

  static OrdersCubit get(BuildContext context) => BlocProvider.of(context);
  BrancheModel? selectedBranch;

  void selectBranch(BrancheModel brancheModel) {
    selectedBranch = brancheModel;
    emit(SelectBranch());
  }

  bool isLoadingData = false;
  bool isLoadingAction = false;
  bool isLoadingDelete = false;

  // ✅ Pagination State
  List<OrderModel> allOrders = []; // الطلبات المفلترة (للعرض)
  List<OrderModel> _unfilteredOrders = []; // كل الطلبات الأصلية (للفلاتر)
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentFilter;
  DateTime? _lastFetchTime;
  static const int _ordersPerPage = 20;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // ✅ Getters
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  String? get activeFilter => _currentFilter;
  List<OrderModel> get unfilteredOrders => _unfilteredOrders;
  bool get isLoadingMore => state is OrdersGetLoading && 
      (state as OrdersGetLoading).isLoadingMore;

  // ✅ Search Debounce
  Timer? _searchDebounce;
  String? _lastSearchQuery;

  Future<void> addOrder({
    required BuildContext context,
    required DateTime dateTime,
    required BrancheModel brancheModel,
    required String address,
    required bool useLoyalty,
  }) async {
    try {
      isLoadingAction = true;
      emit(OrdersActionLoading());

      Response? response = await OrdersServices.addData(
        {
          "use_loyalty" : "${useLoyalty==true?"1":"0"}",
          "order": {
            "date": "${dateTime.day}-${dateTime.month}-${dateTime.year}",
            "location": address,
            "branch_id": "${brancheModel.id}",
            "notes": "",
            "line_items": SelectedProductsModel.selectedProducts
                .map((e) => {
                      "product_id": e.productModel.id,
                      "quantity": e.qty,
                    })
                .toList(),
          }
        },
      );

      print("${response?.data}");
      if (response?.statusCode == 200) {
        SelectedProductsModel.selectedProducts.clear();
        // ignore: use_build_context_synchronously
        ProductsCubit.get(context).totalPrice = 0.0;

        // ignore: use_build_context_synchronously
        MyNavigator.navigateTo(context, OrderDoneScreen()); 
        // ignore: use_build_context_synchronously
        ProfileCubit.get(context).getProfile();
        showMessage(context: context, message: response?.data['msg'], color: MyColors.mainColor);
      } else if (response?.statusCode == 428||response?.data['msg']=="can not make order before pay overdue  invoices"){
        showForceMakeAlert(context,dateTime,address,useLoyalty);
      }else {
        log('${response?.data['msg']}');
        // ignore: use_build_context_synchronously
        showMessage(context: context, message: response?.data['msg'], color: MyColors.redColor);
      }
      isLoadingAction = false;
      emit(OrdersActionSuccess());
    } catch (e) {
      log('$e');
      isLoadingAction = false;
      emit(OrdersActionError());
    }
  }

  Future<void> addForceOrder({
    required BuildContext context,
    required DateTime dateTime,
    required BrancheModel brancheModel,
    required String address,
    required bool useLoyalty,
  }) async {
    try {
      isLoadingAction = true;
      emit(OrdersActionLoading());

      Response? response = await OrdersServices.addData(
        {
          "force_make" : "1",
          "use_loyalty" : "${useLoyalty==true?"1":"0"}",
          "order": {
            "date": "${dateTime.day}-${dateTime.month}-${dateTime.year}",
            "location": address,
            "branch_id": "${brancheModel.id}",
            "notes": "",
            "line_items": SelectedProductsModel.selectedProducts
                .map((e) => {
              "product_id": e.productModel.id,
              "quantity": e.qty,
            })
                .toList(),
          }
        },
      );

      if (response?.statusCode == 200) {
        SelectedProductsModel.selectedProducts.clear();
        // ignore: use_build_context_synchronously
        ProductsCubit.get(context).totalPrice = 0.0;
        // ignore: use_build_context_synchronously
        MyNavigator.navigateTo(context, OrderDoneScreen());
        ProfileCubit.get(context).getProfile();
        // ignore: use_build_context_synchronously
        showMessage(context: context, message: response?.data['msg'], color: MyColors.mainColor);
      }else {
        log('${response?.data['msg']}');
        // ignore: use_build_context_synchronously
        showMessage(context: context, message: response?.data['msg'], color: MyColors.redColor);
      }
      isLoadingAction = false;
      emit(OrdersActionSuccess());
    } catch (e) {
      log('$e');
      isLoadingAction = false;
      emit(OrdersActionError());
    }
  }

  /// ✅ Get Orders - Enhanced with Pagination
  Future<void> getOrders({
    bool forceRefresh = false,
    String? status,
  }) async {
    // Check cache validity
    if (!forceRefresh && _isCacheValid() && status == _currentFilter) {
      return;
    }

    _currentFilter = status;
    _currentPage = 1;
    allOrders = [];

    try {
      isLoadingData = true;
      emit(OrdersGetLoading(isFirstLoad: true));
      
      // ✅ جلب البيانات مع pagination (إذا الباك إند يدعمه)
      // الباك إند هيرجع: { data: { data: [...], current_page, last_page, total } }
      final paginatedData = await OrdersServices.getPaginatedOrders(
        page: _currentPage,
        perPage: _ordersPerPage,
        status: status,
      );
      
      if (paginatedData != null && paginatedData.containsKey('data')) {
        // ✅ Server-Side Pagination مدعوم
        final ordersJson = paginatedData['data'] as List;
        final fetchedOrders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
        
        // ✅ حفظ الطلبات الأصلية قبل الفلترة
        _unfilteredOrders = fetchedOrders;
        
        // ✅ تطبيق فلترة إضافية على النتائج (لحل مشكلة shippingStatus)
        allOrders = _applyFilter(fetchedOrders, status);
        
        _currentPage = paginatedData['current_page'] ?? 1;
        
        // ✅ Fix: Use next_page_url to detect if there are more pages
        // Laravel pagination returns null when no more pages
        final nextPageUrl = paginatedData['next_page_url'];
        _hasMore = nextPageUrl != null;
        
        log('✅ Server Pagination: Page $_currentPage, Total: ${allOrders.length}, HasMore: $_hasMore');
      } else {
        // ✅ Fallback: Client-Side Pagination (الباك إند مش مدعوم pagination)
        log('⚠️ Server pagination not available, using client-side');
        final fetchedOrders = await OrdersServices.getData();
        
        // ✅ حفظ الطلبات الأصلية قبل الفلترة
        _unfilteredOrders = fetchedOrders;
        
        allOrders = _applyFilter(fetchedOrders, status);
        _hasMore = false;
      }
      
      _lastFetchTime = DateTime.now();
      
      isLoadingData = false;
      emit(OrdersGetSuccess(
        currentPage: _currentPage,
        lastPage: _hasMore ? 999 : _currentPage, // نستخدم 999 كـ placeholder
        total: allOrders.length,
        hasMore: _hasMore,
        activeFilter: _currentFilter,
        lastUpdated: _lastFetchTime!,
      ));
      
      // ✅ تأخير التتبع لبعد عرض البيانات (async - مايوقفش الـ UI)
      Future.microtask(() => _checkAndStartTracking());
      
    } catch (e) {
      log('❌ Error in getOrders: $e');
      isLoadingData = false;
      emit(OrdersGetError(
        message: e.toString(),
        hasCache: allOrders.isNotEmpty,
      ));
    }
  }

  /// ✅ Load More - للتحميل التدريجي
  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore) return;

    final currentState = state;
    if (currentState is! OrdersGetSuccess) return;

    try {
      emit(OrdersGetLoading(isLoadingMore: true));

      _currentPage++;
      
      // ✅ جلب الصفحة التالية من الباك إند
      final paginatedData = await OrdersServices.getPaginatedOrders(
        page: _currentPage,
        perPage: _ordersPerPage,
        status: _currentFilter,
      );
      
      if (paginatedData != null && paginatedData.containsKey('data')) {
        // ✅ Server-Side Pagination
        final ordersJson = paginatedData['data'] as List;
        final fetchedOrders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
        
        // ✅ إضافة الطلبات الجديدة للطلبات الأصلية
        _unfilteredOrders.addAll(fetchedOrders);
        
        // ✅ تطبيق فلترة إضافية على النتائج الجديدة
        final filteredNewOrders = _applyFilter(fetchedOrders, _currentFilter);
        
        // ✅ Append to existing list
        allOrders.addAll(filteredNewOrders);
        
        // ✅ Fix: Use next_page_url to detect if there are more pages
        final nextPageUrl = paginatedData['next_page_url'];
        _hasMore = nextPageUrl != null;
        
        log('✅ Loaded more: Page $_currentPage, Total orders: ${allOrders.length}, HasMore: $_hasMore');
        
        emit(OrdersGetSuccess(
          currentPage: _currentPage,
          lastPage: _hasMore ? 999 : _currentPage, // placeholder
          total: allOrders.length,
          hasMore: _hasMore,
          activeFilter: _currentFilter,
          lastUpdated: DateTime.now(),
        ));
      } else {
        // ✅ Fallback: لا يوجد المزيد
        _hasMore = false;
        emit(currentState);
      }
    } catch (e) {
      log('❌ Error loading more: $e');
      _currentPage--; // ✅ Rollback page number
      emit(OrdersGetError(message: e.toString(), hasCache: true));
    }
  }

  /// ✅ Filter by Status
  Future<void> filterByStatus(String? status) async {
    if (status == _currentFilter) return;
    await getOrders(status: status, forceRefresh: true);
  }

  /// ✅ Search with Debounce
  void search(String query) {
    _searchDebounce?.cancel();
    
    if (query == _lastSearchQuery) return;
    _lastSearchQuery = query;

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      log('🔍 Search query: "$query" | Unfiltered orders: ${_unfilteredOrders.length}');
      
      if (query.isEmpty) {
        // ✅ البحث فارغ: نرجع للقائمة الكاملة
        allOrders = _unfilteredOrders;
        emit(OrdersGetSuccess(
          currentPage: _currentPage,
          lastPage: _hasMore ? 999 : _currentPage,
          total: allOrders.length,
          hasMore: _hasMore,
          activeFilter: _currentFilter,
          lastUpdated: DateTime.now(),
        ));
        return;
      }

      // ✅ Client-Side Search من الطلبات الموجودة
      final searchLower = query.toLowerCase().trim();
      // ✅ إزالة # و order من البحث للمرونة
      final cleanSearch = searchLower.replaceAll('#', '').replaceAll('order', '');
      
      log('🔍 Clean search: "$cleanSearch"');
      
      final searchResults = _unfilteredOrders.where((order) {
        final orderRef = order.reference?.toLowerCase() ?? '';
        final orderId = order.id?.toString() ?? '';
        
        // ✅ البحث برقم الطلبية بأكثر من طريقة
        return orderRef.contains(cleanSearch) ||           // order4144 يحتوي على 4144
               orderId.contains(cleanSearch) ||            // ID يحتوي على 4144
               orderRef.contains('order$cleanSearch') ||   // order4144
               order.customer?.name?.toLowerCase().contains(searchLower) == true ||
               order.location?.toLowerCase().contains(searchLower) == true;
      }).toList();

      allOrders = searchResults;
      
      log('✅ Search results: ${allOrders.length} orders found for query: "$query"');
      
      emit(OrdersGetSuccess(
        currentPage: 1,
        lastPage: 1,
        total: searchResults.length,
        hasMore: false,
        activeFilter: _currentFilter,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      log('❌ Search error: $e');
      emit(OrdersGetError(message: e.toString(), hasCache: allOrders.isNotEmpty));
    }
  }

  /// ✅ Refresh (Pull to Refresh)
  Future<void> refresh() async {
    if (state is OrdersGetLoading) return;
    
    emit(OrdersGetLoading(isRefreshing: true));
    await getOrders(forceRefresh: true, status: _currentFilter);
  }

  /// ✅ Apply Client-Side Filter (temporary)
  List<OrderModel> _applyFilter(List<OrderModel> orders, String? status) {
    if (status == null) return orders;

    if (status == 'Pending') {
      return orders.where((order) {
        final orderStatus = order.status?.toLowerCase() ?? '';
        final shippingStatus = order.shippingStatus?.toLowerCase() ?? '';
        
        // ✅ إذا الطلب تم توصيله أو إلغاؤه في الشحن، لا يظهر في "قيد الانتظار"
        if (shippingStatus == 'delivered' || shippingStatus == 'cancelled') {
          return false;
        }
        
        if (orderStatus.isEmpty) return true;
        if (orderStatus == 'pending' || orderStatus == 'draft') return true;
        if (orderStatus == 'approved' || 
            orderStatus == 'declined' || 
            orderStatus == 'canceled') {
          return false;
        }
        return true;
      }).toList();
    }

    final selectedLower = status.toLowerCase();
    return orders.where((order) => 
        order.status?.toLowerCase() == selectedLower
    ).toList();
  }

  /// ✅ Check Cache Validity
  bool _isCacheValid() {
    if (_lastFetchTime == null || allOrders.isEmpty) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  /// ✅ Clear Cache
  void clearCache() {
    allOrders = [];
    _lastFetchTime = null;
    _currentPage = 1;
    _hasMore = true;
    _currentFilter = null;
    emit(OrdersInitial());
  }

  /// ✅ Update Single Order
  void updateOrder(OrderModel updatedOrder) {
    final index = allOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      allOrders[index] = updatedOrder;
      
      if (state is OrdersGetSuccess) {
        emit((state as OrdersGetSuccess).copyWith(
          lastUpdated: DateTime.now(),
        ));
      }
    }
  }

  /// ✅ Remove Order from List
  void removeOrderFromList(int orderId) {
    allOrders.removeWhere((o) => o.id == orderId);
    
    if (state is OrdersGetSuccess) {
      final currentState = state as OrdersGetSuccess;
      emit(currentState.copyWith(
        total: currentState.total - 1,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// ✅ Add Order to List
  void addOrderToList(OrderModel newOrder) {
    allOrders.insert(0, newOrder);
    
    if (state is OrdersGetSuccess) {
      final currentState = state as OrdersGetSuccess;
      emit(currentState.copyWith(
        total: currentState.total + 1,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  // ✅ OLD METHOD - Kept for reference (DEPRECATED - Use getOrders() instead)
  Future<void> getOrders_OLD() async {
    try {
      isLoadingData = true;
      emit(OrdersGetLoading(isFirstLoad: true));
      
      // ✅ جلب البيانات
      allOrders = await OrdersServices.getData();
      
      isLoadingData = false;
      emit(OrdersGetSuccess(
        currentPage: 1,
        lastPage: 1,
        total: allOrders.length,
        hasMore: false,
        lastUpdated: DateTime.now(),
      ));
      
      // ✅ تأخير التتبع لبعد عرض البيانات (async - مايوقفش الـ UI)
      Future.microtask(() => _checkAndStartTracking());
      
    } catch (e) {
      log('$e');
      isLoadingData = false;
      emit(OrdersGetError(
        message: e.toString(),
        hasCache: allOrders.isNotEmpty,
      ));
    }
  }
  
  /// Check if there are active orders and start tracking
  void _checkAndStartTracking() {
    try {
      log('🔍 Checking for active orders to start tracking...');
      
      // ✅ أولاً: البحث عن الطلبات الملغية أو المرفوضة لإيقاف التتبع
      final cancelledOrders = allOrders.where((order) {
        final status = order.status?.toLowerCase() ?? '';
        return status == 'canceled' || 
               status == 'cancelled' || 
               status == 'declined';
      }).toList();
      
      if (cancelledOrders.isNotEmpty) {
        log('🛑 Found ${cancelledOrders.length} cancelled/declined order(s), stopping tracking');
        for (final order in cancelledOrders) {
          log('   - Stopping tracking for: ${order.reference} (Status: ${order.status})');
          // إيقاف التتبع للطلب الملغي
          TrackingCubit.instance?.stopTrackingForOrder(order.id.toString());
        }
      }
      
      // Find ALL active orders (not just approved)
      final activeOrders = allOrders.where((order) {
        // Check if order is in an active shipping state
        final shippingStatus = order.shippingStatus?.toLowerCase() ?? '';
        final orderStatus = order.status?.toLowerCase() ?? '';
        
        // ✅ استبعاد الطلبات الملغية والمرفوضة
        if (orderStatus == 'canceled' || 
            orderStatus == 'cancelled' || 
            orderStatus == 'declined') {
          return false;
        }
        
        final isActive = shippingStatus != 'delivered' && 
                        shippingStatus != 'cancelled' &&
                        shippingStatus != '' &&
                        order.status == 'Approved';
        
        if (isActive) {
          log('✅ Found active order: ${order.reference} - Status: ${order.shippingStatus}');
        }
        
        return isActive;
      }).toList();
      
      if (activeOrders.isEmpty) {
        log('ℹ️ No active orders found for tracking');
        return;
      }
      
      log('📦 Found ${activeOrders.length} active order(s)');
      
      // Sort by updated time and get the latest
      activeOrders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final latestOrder = activeOrders.first;
      
      log('🚀 Starting Live Activity for order: ${latestOrder.reference}');
      log('   - Shipping Status: ${latestOrder.shippingStatus}');
      log('   - Order Status: ${latestOrder.status}');
      
      // Start tracking with detailed logging
      OrderTrackingHelper.startTrackingFromOrder(latestOrder).then((success) {
        if (success) {
          log('✅ Live Activity started successfully for ${latestOrder.reference}');
        } else {
          log('❌ Failed to start Live Activity for ${latestOrder.reference}');
        }
      });
      
    } catch (e) {
      log('❌ Error checking active orders for tracking: $e');
    }
  }


  Future<void> editOrder({
    required BuildContext context,
    required String orderId,
    required List<SelectedProductsModel> currentList
  }) async {
    try {
      isLoadingAction = true;
      emit(OrdersActionLoading());

      Response? response = await OrdersServices.editOrder(
          {
            "line_items": currentList
                .map((e) => {
              "product_id": e.productModel.id,
              "unit_price":e.price,
              "quantity": e.qty,
            })
                .toList(),
          },
          orderId
      );

      print("${response?.data}");
      if (response?.statusCode == 200) {
        SelectedProductsModel.selectedProducts.clear();
        MyNavigator.navigateTo(context, LayoutScreen());
        ProfileCubit.get(context).getProfile();
        showMessage(context: context, message: response?.data['msg'], color: MyColors.mainColor);
      }else {
        log('${response?.data['msg']}');
        // ignore: use_build_context_synchronously
        showMessage(context: context, message: response?.data['msg'], color: MyColors.redColor);
      }
      isLoadingAction = false;
      emit(OrdersActionSuccess());
    } catch (e) {
      log('$e');
      isLoadingAction = false;
      emit(OrdersActionError());
    }
  }
  Future<void> cancelOrder({
    required BuildContext context,
    required String orderId,
  }) async {
    try {
      isLoadingAction = true;
      emit(OrdersActionLoading());

      Response? response = await OrdersServices.cancelOrder(orderId);

      print("${response?.data}");
      if (response?.statusCode == 200) {
        SelectedProductsModel.selectedProducts.clear();
        MyNavigator.navigateTo(context, LayoutScreen());
        ProfileCubit.get(context).getProfile();
        showMessage(context: context, message: response?.data['msg'], color: MyColors.mainColor);
      }else {
        log('${response?.data['msg']}');
        // ignore: use_build_context_synchronously
        showMessage(context: context, message: response?.data['msg'], color: MyColors.redColor);
      }
      isLoadingAction = false;
      emit(OrdersActionSuccess());
    } catch (e) {
      log('$e');
      isLoadingAction = false;
      emit(OrdersActionError());
    }
  }


}
