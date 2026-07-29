part of 'orders_cubit.dart';

@immutable
sealed class OrdersState {}

final class OrdersInitial extends OrdersState {}

final class SelectBranch extends OrdersState {}

final class OrdersActionLoading extends OrdersState {}

final class OrdersActionSuccess extends OrdersState {}

final class OrdersActionError extends OrdersState {}

// ✅ Enhanced Loading States
final class OrdersGetLoading extends OrdersState {
  final bool isFirstLoad;
  final bool isLoadingMore;
  final bool isRefreshing;

  OrdersGetLoading({
    this.isFirstLoad = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });
}

// ✅ Success State with Pagination Info
final class OrdersGetSuccess extends OrdersState {
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;
  final String? activeFilter;
  final DateTime lastUpdated;

  OrdersGetSuccess({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
    this.activeFilter,
    required this.lastUpdated,
  });

  OrdersGetSuccess copyWith({
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMore,
    String? activeFilter,
    DateTime? lastUpdated,
  }) {
    return OrdersGetSuccess(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      activeFilter: activeFilter ?? this.activeFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final class OrdersGetError extends OrdersState {
  final String message;
  final bool hasCache;

  OrdersGetError({
    required this.message,
    this.hasCache = false,
  });
}

final class OrdersDeleteLoading extends OrdersState {
  final int id;
  OrdersDeleteLoading(this.id);
}

final class OrdersDeleteSuccess extends OrdersState {}

final class OrdersDeleteError extends OrdersState {}
