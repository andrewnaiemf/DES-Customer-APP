import 'dart:async';
import 'dart:developer';
import 'package:app/models/invoice/invoice_model.dart';
import 'package:app/network/services/invoice_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'invoice_state.dart';

class InVoiceCubit extends Cubit<InVoiceState> {
  InVoiceCubit() : super(InVoiceInitial());

  static InVoiceCubit get(BuildContext context) => BlocProvider.of(context);

  static const int _invoicesPerPage = 20;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  bool isLoadingData = false;
  List<InVoiceModel> allInVoice = [];
  int totalInvoices = 0;
  Map<String, int> statusCounts = const {
    'all': 0,
    'paid': 0,
    'unpaid': 0,
    'return': 0,
    'partial_return': 0,
  };
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentFilter;

  String? get activeFilter => _currentFilter;
  String? _currentSearchQuery;
  DateTime? _lastFetchTime;
  Timer? _searchDebounce;

  Future<void> getInvoices({
    bool forceRefresh = false,
    String? status,
  }) async {
    if (!forceRefresh &&
        _isCacheValid() &&
        status == _currentFilter &&
        allInVoice.isNotEmpty) {
      return;
    }

    _currentFilter = status;
    _currentPage = 1;
    _hasMore = true;
    allInVoice.clear();

    isLoadingData = true;
    emit(InVoiceGetLoading(isFirstLoad: true));

    try {
      final page = await _loadPage(1);
      _lastFetchTime = DateTime.now();
      isLoadingData = false;
      emit(InVoiceGetSuccess(
        currentPage: _currentPage,
        lastPage: page.lastPage,
        total: page.total,
        hasMore: _hasMore,
        activeFilter: status,
        lastUpdated: _lastFetchTime!,
      ));
    } catch (e) {
      log('❌ Error in getInvoices: $e');
      isLoadingData = false;
      emit(InVoiceGetError(
        message: e.toString(),
        hasCache: allInVoice.isNotEmpty,
      ));
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingData) return;
    if (state is InVoiceGetLoading &&
        (state as InVoiceGetLoading).isLoadingMore) {
      return;
    }

    isLoadingData = true;
    if (state is InVoiceGetSuccess) {
      emit((state as InVoiceGetSuccess).copyWith(isLoadingMore: true));
    }

    try {
      final nextPage = _currentPage + 1;
      final page = await _loadPage(nextPage);
      isLoadingData = false;
      emit(InVoiceGetSuccess(
        currentPage: _currentPage,
        lastPage: page.lastPage,
        total: page.total,
        hasMore: _hasMore,
        isLoadingMore: false,
        activeFilter: _currentFilter,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      log('❌ Error in invoice loadMore: $e');
      isLoadingData = false;
      if (state is InVoiceGetSuccess) {
        emit((state as InVoiceGetSuccess).copyWith(isLoadingMore: false));
      }
    }
  }

  Future<({int lastPage, int total})> _loadPage(int page) async {
    final result = await InVoiceServices.getPaginatedInvoices(
      page: page,
      perPage: _invoicesPerPage,
      status: _currentFilter,
      search: _currentSearchQuery,
    );

    List<InVoiceModel> items = [];
    int lastPage = page;
    int total = totalInvoices;
    bool hasMore = false;

    if (result != null) {
      final raw = result['data'];
      final list = raw is List ? raw : const [];
      items = list
          .whereType<Map>()
          .map((e) => InVoiceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      lastPage = int.tryParse('${result['last_page'] ?? page}') ?? page;
      final parsedTotal = int.tryParse('${result['total'] ?? ''}') ?? 0;
      if (parsedTotal > 0) {
        total = parsedTotal;
      } else if (total <= 0) {
        total = (page == 1 ? items.length : allInVoice.length + items.length);
      }
      _applyCounts(result['counts']);
      final nextUrl = result['next_page_url'];
      hasMore = nextUrl != null || page < lastPage;
    } else {
      items = await InVoiceServices.getData(
        page: page,
        perPage: _invoicesPerPage,
        status: _currentFilter,
        search: _currentSearchQuery,
      );
      hasMore = items.length >= _invoicesPerPage;
      if (total <= 0) {
        total = (page == 1 ? items.length : allInVoice.length + items.length);
      }
    }

    if (page == 1) {
      allInVoice = items;
    } else {
      allInVoice.addAll(items);
    }
    _currentPage = page;
    _hasMore = hasMore && items.isNotEmpty;
    totalInvoices = total;
    return (lastPage: lastPage, total: total);
  }

  Future<void> filterByStatus(String? status) async {
    if (_currentFilter == status) return;
    await getInvoices(forceRefresh: true, status: status);
  }

  void searchInvoices(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final normalized = query.isEmpty ? null : query;
    if (_currentSearchQuery == normalized) return;
    _currentSearchQuery = normalized;
    await getInvoices(forceRefresh: true, status: _currentFilter);
  }

  Future<void> refresh() async {
    emit(InVoiceGetLoading(isRefreshing: true));
    await getInvoices(forceRefresh: true, status: _currentFilter);
  }

  void updateInvoice(InVoiceModel updatedInvoice) {
    final index = allInVoice.indexWhere((inv) => inv.id == updatedInvoice.id);
    if (index != -1) {
      allInVoice[index] = updatedInvoice;
      if (state is InVoiceGetSuccess) {
        emit((state as InVoiceGetSuccess).copyWith(lastUpdated: DateTime.now()));
      }
    }
  }

  void addInvoiceToList(InVoiceModel newInvoice) {
    allInVoice.insert(0, newInvoice);
    if (state is InVoiceGetSuccess) {
      final currentState = state as InVoiceGetSuccess;
      totalInvoices = currentState.total + 1;
      emit(currentState.copyWith(
        total: totalInvoices,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  void removeInvoiceFromList(int invoiceId) {
    final initialLength = allInVoice.length;
    allInVoice.removeWhere((inv) => inv.id == invoiceId);
    final removed = initialLength - allInVoice.length;
    if (removed > 0 && state is InVoiceGetSuccess) {
      final currentState = state as InVoiceGetSuccess;
      totalInvoices = currentState.total - removed;
      emit(currentState.copyWith(
        total: totalInvoices,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  void _applyCounts(dynamic raw) {
    if (raw is! Map) return;
    int read(String key) => int.tryParse('${raw[key] ?? ''}') ?? -1;
    final all = read('all');
    final paid = read('paid');
    final unpaid = read('unpaid');
    final returned = read('return');
    final partialReturn = read('partial_return');
    if (all < 0 && paid < 0 && unpaid < 0 && returned < 0 && partialReturn < 0) {
      return;
    }
    statusCounts = {
      'all': all >= 0 ? all : (statusCounts['all'] ?? 0),
      'paid': paid >= 0 ? paid : (statusCounts['paid'] ?? 0),
      'unpaid': unpaid >= 0 ? unpaid : (statusCounts['unpaid'] ?? 0),
      'return': returned >= 0 ? returned : (statusCounts['return'] ?? 0),
      'partial_return':
          partialReturn >= 0 ? partialReturn : (statusCounts['partial_return'] ?? 0),
    };
  }

  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  void clearCache() {
    _lastFetchTime = null;
    allInVoice.clear();
    totalInvoices = 0;
    statusCounts = const {
      'all': 0,
      'paid': 0,
      'unpaid': 0,
      'return': 0,
      'partial_return': 0,
    };
    _currentPage = 1;
    _hasMore = true;
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
