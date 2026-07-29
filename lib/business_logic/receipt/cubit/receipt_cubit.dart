import 'dart:async';
import 'dart:developer';
import 'package:app/models/receipt/receipt_model.dart';
import 'package:app/network/services/receipts_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'receipt_state.dart';

class ReceiptCubit extends Cubit<ReceiptState> {
  ReceiptCubit() : super(ReceiptInitial());

  static ReceiptCubit get(BuildContext context) => BlocProvider.of(context);

  // Pagination constants
  static const int _receiptsPerPage = 20;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Pagination state
  bool isLoadingData = false;
  List<ReceiptModel> allReceipt = [];
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentFilter;
  String? _currentSearchQuery;
  DateTime? _lastFetchTime;
  Timer? _searchDebounce;

  // Original method - kept for backward compatibility
  Future<void> getReceipt_OLD() async {
    try {
      isLoadingData = true;
      emit(ReceiptGetLoading(isFirstLoad: true));
      allReceipt = await ReceiptsServices.getData();
      isLoadingData = false;
      emit(ReceiptGetSuccess(
        currentPage: 1,
        lastPage: 1,
        total: allReceipt.length,
        hasMore: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      log('Error in getReceipt_OLD: $e');
      isLoadingData = false;
      emit(ReceiptGetError(message: e.toString()));
    }
  }

  /// Main method to get receipts - Without Pagination (loads all data)
  Future<void> getReceipts({
    bool forceRefresh = false,
    String? status,
  }) async {
    try {
      // Check cache validity
      if (!forceRefresh && _isCacheValid()) {
        log('Using cached receipt data');
        return;
      }

      _currentFilter = status;
      allReceipt.clear();

      isLoadingData = true;
      emit(ReceiptGetLoading(isFirstLoad: true));

      // ✅ استخدام الـ method القديمة بدون pagination
      allReceipt = await ReceiptsServices.getData();

      _lastFetchTime = DateTime.now();
      _hasMore = false; // لا يوجد المزيد (كل البيانات محملة)

      isLoadingData = false;
      emit(ReceiptGetSuccess(
        currentPage: 1,
        lastPage: 1,
        total: allReceipt.length,
        hasMore: false,
        activeFilter: status,
        lastUpdated: _lastFetchTime!,
      ));

      log('📄 All receipts loaded: ${allReceipt.length}');
    } catch (e) {
      log('❌ Error in getReceipts: $e');
      isLoadingData = false;
      emit(ReceiptGetError(
        message: e.toString(),
        hasCache: allReceipt.isNotEmpty,
      ));
    }
  }

  /// Load more receipts (DISABLED - all data loaded at once)
  Future<void> loadMore() async {
    // ❌ Pagination disabled - all data is loaded in getReceipts()
    return;
  }

  /// Filter receipts by status
  Future<void> filterByStatus(String? status) async {
    if (_currentFilter == status) return;
    
    log('🔍 Filtering receipts by status: $status');
    await getReceipts(forceRefresh: true, status: status);
  }

  /// Search receipts with debounce
  void searchReceipts(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (_currentSearchQuery == query) return;

    _currentSearchQuery = query.isEmpty ? null : query;
    log('🔍 Searching receipts: "$query"');

    await getReceipts(
      forceRefresh: true,
      status: _currentFilter,
    );
  }

  /// Refresh receipts (pull-to-refresh)
  Future<void> refresh() async {
    emit(ReceiptGetLoading(isRefreshing: true));
    await getReceipts(forceRefresh: true, status: _currentFilter);
  }

  /// Update a single receipt in the list
  void updateReceipt(ReceiptModel updatedReceipt) {
    final index = allReceipt.indexWhere((rec) => rec.id == updatedReceipt.id);
    if (index != -1) {
      allReceipt[index] = updatedReceipt;
      
      if (state is ReceiptGetSuccess) {
        final currentState = state as ReceiptGetSuccess;
        emit(currentState.copyWith(lastUpdated: DateTime.now()));
      }
      
      log('✅ Receipt updated: ${updatedReceipt.id}');
    }
  }

  /// Add new receipt to the list
  void addReceiptToList(ReceiptModel newReceipt) {
    allReceipt.insert(0, newReceipt);
    
    if (state is ReceiptGetSuccess) {
      final currentState = state as ReceiptGetSuccess;
      emit(currentState.copyWith(
        total: currentState.total + 1,
        lastUpdated: DateTime.now(),
      ));
    }
    
    log('✅ Receipt added: ${newReceipt.id}');
  }

  /// Remove receipt from the list
  void removeReceiptFromList(int receiptId) {
    final initialLength = allReceipt.length;
    allReceipt.removeWhere((rec) => rec.id == receiptId);
    final removed = initialLength - allReceipt.length;
    
    if (removed > 0 && state is ReceiptGetSuccess) {
      final currentState = state as ReceiptGetSuccess;
      emit(currentState.copyWith(
        total: currentState.total - removed,
        lastUpdated: DateTime.now(),
      ));
      
      log('✅ Receipt removed: $receiptId');
    }
  }

  /// Apply client-side filter (for fallback)
  /// Note: ReceiptModel doesn't have status field, filter by kind instead if needed
  List<ReceiptModel> _applyFilter(List<ReceiptModel> receipts, String? filterValue) {
    if (filterValue == null || filterValue.isEmpty) return receipts;
    // Can filter by 'kind' field if needed in the future
    return receipts;
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    final difference = DateTime.now().difference(_lastFetchTime!);
    return difference < _cacheValidDuration;
  }

  /// Clear cache and force refresh
  void clearCache() {
    _lastFetchTime = null;
    allReceipt.clear();
    _currentPage = 1;
    _hasMore = true;
    log('🗑️ Receipt cache cleared');
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
