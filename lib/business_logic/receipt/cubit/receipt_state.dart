part of 'receipt_cubit.dart';

@immutable
sealed class ReceiptState {}

final class ReceiptInitial extends ReceiptState {}

final class SelectBranch extends ReceiptState {}

final class ReceiptActionLoading extends ReceiptState {}

final class ReceiptActionSuccess extends ReceiptState {}

final class ReceiptActionError extends ReceiptState {}

final class ReceiptGetLoading extends ReceiptState {
  final bool isFirstLoad;
  final bool isLoadingMore;
  final bool isRefreshing;

  ReceiptGetLoading({
    this.isFirstLoad = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });
}

final class ReceiptGetSuccess extends ReceiptState {
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;
  final String? activeFilter;
  final DateTime lastUpdated;

  ReceiptGetSuccess({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
    this.activeFilter,
    required this.lastUpdated,
  });

  ReceiptGetSuccess copyWith({
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMore,
    String? activeFilter,
    DateTime? lastUpdated,
  }) {
    return ReceiptGetSuccess(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      activeFilter: activeFilter ?? this.activeFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final class ReceiptGetError extends ReceiptState {
  final String message;
  final bool hasCache;

  ReceiptGetError({
    required this.message,
    this.hasCache = false,
  });
}

final class ReceiptDeleteLoading extends ReceiptState {
  final int id;
  ReceiptDeleteLoading(this.id);
}

final class ReceiptDeleteSuccess extends ReceiptState {}

final class ReceiptDeleteError extends ReceiptState {}
