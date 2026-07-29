part of 'invoice_cubit.dart';

@immutable
sealed class InVoiceState {}

final class InVoiceInitial extends InVoiceState {}

final class SelectBranch extends InVoiceState {}

final class InVoiceActionLoading extends InVoiceState {}

final class InVoiceActionSuccess extends InVoiceState {}

final class InVoiceActionError extends InVoiceState {}

final class InVoiceGetLoading extends InVoiceState {
  final bool isFirstLoad;
  final bool isLoadingMore;
  final bool isRefreshing;

  InVoiceGetLoading({
    this.isFirstLoad = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });
}

final class InVoiceGetSuccess extends InVoiceState {
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;
  final String? activeFilter;
  final DateTime lastUpdated;

  InVoiceGetSuccess({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
    this.activeFilter,
    required this.lastUpdated,
  });

  InVoiceGetSuccess copyWith({
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMore,
    String? activeFilter,
    DateTime? lastUpdated,
  }) {
    return InVoiceGetSuccess(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      activeFilter: activeFilter ?? this.activeFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final class InVoiceGetError extends InVoiceState {
  final String message;
  final bool hasCache;

  InVoiceGetError({
    required this.message,
    this.hasCache = false,
  });
}

final class InVoiceDeleteLoading extends InVoiceState {
  final int id;
  InVoiceDeleteLoading(this.id);
}

final class InVoiceDeleteSuccess extends InVoiceState {}

final class InVoiceDeleteError extends InVoiceState {}
