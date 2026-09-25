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

  static const int _receiptsPerPage = 20;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  bool isLoadingData = false;
  List<ReceiptModel> allReceipt = [];
  int totalReceipts = 0;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentFilter;
  String? _currentSearchQuery;
  DateTime? _lastFetchTime;
  Timer? _searchDebounce;

  Future<void> getReceipts({
    bool forceRefresh = false,
    String? status,
  }) async {
    if (!forceRefresh &&
        _isCacheValid() &&
        status == _currentFilter &&
        allReceipt.isNotEmpty) {
      return;
    }

    _currentFilter = status;
    _currentPage = 1;
    _hasMore = true;
    allReceipt.clear();

    isLoadingData = true;
    emit(ReceiptGetLoading(isFirstLoad: true));

    try {
      final page = await _loadPage(1);
      _lastFetchTime = DateTime.now();
      isLoadingData = false;
      emit(ReceiptGetSuccess(
        currentPage: _currentPage,
        lastPage: page.lastPage,
        total: page.total,
        hasMore: _hasMore,
        activeFilter: status,
        lastUpdated: _lastFetchTime!,
      ));
    } catch (e) {
      log('❌ Error in getReceipts: $e');
      isLoadingData = false;
      emit(ReceiptGetError(
        message: e.toString(),
        hasCache: allReceipt.isNotEmpty,
      ));
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingData) return;

    isLoadingData = true;
    if (state is ReceiptGetSuccess) {
      emit((state as ReceiptGetSuccess).copyWith(isLoadingMore: true));
    }

    try {
      final page = await _loadPage(_currentPage + 1);
      isLoadingData = false;
      emit(ReceiptGetSuccess(
        currentPage: _currentPage,
        lastPage: page.lastPage,
        total: page.total,
        hasMore: _hasMore,
        isLoadingMore: false,
        activeFilter: _currentFilter,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      log('❌ Error in receipt loadMore: $e');
      isLoadingData = false;
      if (state is ReceiptGetSuccess) {
        emit((state as ReceiptGetSuccess).copyWith(isLoadingMore: false));
      }
    }
  }

  Future<({int lastPage, int total})> _loadPage(int page) async {
    final result = await ReceiptsServices.getPaginatedReceipts(
      page: page,
      perPage: _receiptsPerPage,
      status: _currentFilter,
      search: _currentSearchQuery,
    );

    List<ReceiptModel> items = [];
    int lastPage = page;
    int total = totalReceipts;
    bool hasMore = false;

    if (result != null) {
      final raw = result['data'];
      final list = raw is List ? raw : const [];
      items = list
          .whereType<Map>()
          .map((e) => ReceiptModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      lastPage = int.tryParse('${result['last_page'] ?? page}') ?? page;
      final parsedTotal = int.tryParse('${result['total'] ?? ''}') ?? 0;
      if (parsedTotal > 0) {
        total = parsedTotal;
      } else if (total <= 0) {
        total = (page == 1 ? items.length : allReceipt.length + items.length);
      }
      hasMore = result['next_page_url'] != null || page < lastPage;
    } else {
      items = await ReceiptsServices.getData(
        page: page,
        perPage: _receiptsPerPage,
        status: _currentFilter,
        search: _currentSearchQuery,
      );
      hasMore = items.length >= _receiptsPerPage;
      if (total <= 0) {
        total = (page == 1 ? items.length : allReceipt.length + items.length);
      }
    }

    if (page == 1) {
      allReceipt = items;
    } else {
      allReceipt.addAll(items);
    }
    _currentPage = page;
    _hasMore = hasMore && items.isNotEmpty;
    totalReceipts = total;
    return (lastPage: lastPage, total: total);
  }

  Future<void> filterByStatus(String? status) async {
    if (_currentFilter == status) return;
    await getReceipts(forceRefresh: true, status: status);
  }

  void searchReceipts(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final normalized = query.isEmpty ? null : query;
    if (_currentSearchQuery == normalized) return;
    _currentSearchQuery = normalized;
    await getReceipts(forceRefresh: true, status: _currentFilter);
  }

  Future<void> refresh() async {
    emit(ReceiptGetLoading(isRefreshing: true));
    await getReceipts(forceRefresh: true, status: _currentFilter);
  }

  void updateReceipt(ReceiptModel updatedReceipt) {
    final index = allReceipt.indexWhere((rec) => rec.id == updatedReceipt.id);
    if (index != -1) {
      allReceipt[index] = updatedReceipt;
      if (state is ReceiptGetSuccess) {
        emit((state as ReceiptGetSuccess).copyWith(lastUpdated: DateTime.now()));
      }
    }
  }

  void addReceiptToList(ReceiptModel newReceipt) {
    allReceipt.insert(0, newReceipt);
    if (state is ReceiptGetSuccess) {
      final currentState = state as ReceiptGetSuccess;
      totalReceipts = currentState.total + 1;
      emit(currentState.copyWith(
        total: totalReceipts,
        lastUpdated: DateTime.now(),
      ));
    }
  }

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
    }
  }

  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  void clearCache() {
    _lastFetchTime = null;
    allReceipt.clear();
    totalReceipts = 0;
    _currentPage = 1;
    _hasMore = true;
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
