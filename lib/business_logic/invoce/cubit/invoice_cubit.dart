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

  // Pagination constants
  static const int _invoicesPerPage = 20;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Pagination state
  bool isLoadingData = false;
  List<InVoiceModel> allInVoice = [];
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentFilter;
  String? _currentSearchQuery;
  DateTime? _lastFetchTime;
  Timer? _searchDebounce;

  // Original method - kept for backward compatibility
  Future<void> getInVoice_OLD() async {
    try {
      isLoadingData = true;
      emit(InVoiceGetLoading(isFirstLoad: true));
      allInVoice = await InVoiceServices.getData();
      isLoadingData = false;
      emit(InVoiceGetSuccess(
        currentPage: 1,
        lastPage: 1,
        total: allInVoice.length,
        hasMore: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      log('Error in getInVoice_OLD: $e');
      isLoadingData = false;
      emit(InVoiceGetError(message: e.toString()));
    }
  }

  /// Main method to get invoices - Without Pagination (loads all data)
  Future<void> getInvoices({
    bool forceRefresh = false,
    String? status,
  }) async {
    try {
      // Check cache validity
      if (!forceRefresh && _isCacheValid()) {
        log('Using cached invoice data');
        return;
      }

      _currentFilter = status;
      allInVoice.clear();

      isLoadingData = true;
      emit(InVoiceGetLoading(isFirstLoad: true));

      // ✅ استخدام الـ method القديمة بدون pagination
      allInVoice = await InVoiceServices.getData();

      _lastFetchTime = DateTime.now();
      _hasMore = false; // لا يوجد المزيد (كل البيانات محملة)

      isLoadingData = false;
      emit(InVoiceGetSuccess(
        currentPage: 1,
        lastPage: 1,
        total: allInVoice.length,
        hasMore: false,
        activeFilter: status,
        lastUpdated: _lastFetchTime!,
      ));

      log('📄 All invoices loaded: ${allInVoice.length}');
    } catch (e) {
      log('❌ Error in getInvoices: $e');
      isLoadingData = false;
      emit(InVoiceGetError(
        message: e.toString(),
        hasCache: allInVoice.isNotEmpty,
      ));
    }
  }

  /// Load more invoices (DISABLED - all data loaded at once)
  Future<void> loadMore() async {
    // ❌ Pagination disabled - all data is loaded in getInvoices()
    return;
  }

  /// Filter invoices by status
  Future<void> filterByStatus(String? status) async {
    if (_currentFilter == status) return;
    
    log('🔍 Filtering invoices by status: $status');
    await getInvoices(forceRefresh: true, status: status);
  }

  /// Search invoices with debounce
  void searchInvoices(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (_currentSearchQuery == query) return;

    _currentSearchQuery = query.isEmpty ? null : query;
    log('🔍 Searching invoices: "$query"');

    await getInvoices(
      forceRefresh: true,
      status: _currentFilter,
    );
  }

  /// Refresh invoices (pull-to-refresh)
  Future<void> refresh() async {
    emit(InVoiceGetLoading(isRefreshing: true));
    await getInvoices(forceRefresh: true, status: _currentFilter);
  }

  /// Update a single invoice in the list
  void updateInvoice(InVoiceModel updatedInvoice) {
    final index = allInVoice.indexWhere((inv) => inv.id == updatedInvoice.id);
    if (index != -1) {
      allInVoice[index] = updatedInvoice;
      
      if (state is InVoiceGetSuccess) {
        final currentState = state as InVoiceGetSuccess;
        emit(currentState.copyWith(lastUpdated: DateTime.now()));
      }
      
      log('✅ Invoice updated: ${updatedInvoice.id}');
    }
  }

  /// Add new invoice to the list
  void addInvoiceToList(InVoiceModel newInvoice) {
    allInVoice.insert(0, newInvoice);
    
    if (state is InVoiceGetSuccess) {
      final currentState = state as InVoiceGetSuccess;
      emit(currentState.copyWith(
        total: currentState.total + 1,
        lastUpdated: DateTime.now(),
      ));
    }
    
    log('✅ Invoice added: ${newInvoice.id}');
  }

  /// Remove invoice from the list
  void removeInvoiceFromList(int invoiceId) {
    final initialLength = allInVoice.length;
    allInVoice.removeWhere((inv) => inv.id == invoiceId);
    final removed = initialLength - allInVoice.length;
    
    if (removed > 0 && state is InVoiceGetSuccess) {
      final currentState = state as InVoiceGetSuccess;
      emit(currentState.copyWith(
        total: currentState.total - removed,
        lastUpdated: DateTime.now(),
      ));
      
      log('✅ Invoice removed: $invoiceId');
    }
  }

  /// Apply client-side filter (for fallback)
  List<InVoiceModel> _applyFilter(List<InVoiceModel> invoices, String? status) {
    if (status == null || status.isEmpty) return invoices;
    return invoices.where((inv) => inv.status == status).toList();
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
    allInVoice.clear();
    _currentPage = 1;
    _hasMore = true;
    log('🗑️ Invoice cache cleared');
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
