import 'package:equatable/equatable.dart';

/// حالة التتبع المباشر
/// Live tracking state
class TrackingState extends Equatable {
  // Service initialization
  final bool isInitializing;
  final bool isServiceReady;
  final String? initializationError;

  // Current tracking
  final String? currentOrderId;
  final String? currentActivityId;
  final Map<String, dynamic>? currentTrackingData;
  final bool isStartingTracking;
  final bool isStoppingTracking;

  // Trackable orders (orders that can be tracked)
  final List<String> trackableOrderIds;
  final bool isLoadingTrackableOrders;

  // Errors
  final String? error;
  final bool hasError;

  const TrackingState({
    this.isInitializing = false,
    this.isServiceReady = false,
    this.initializationError,
    this.currentOrderId,
    this.currentActivityId,
    this.currentTrackingData,
    this.isStartingTracking = false,
    this.isStoppingTracking = false,
    this.trackableOrderIds = const [],
    this.isLoadingTrackableOrders = false,
    this.error,
    this.hasError = false,
  });

  /// حالة أولية
  /// Initial state
  factory TrackingState.initial() => const TrackingState(
        isInitializing: true,
      );

  /// هل يوجد تتبع نشط؟
  /// Is there active tracking?
  bool get hasActiveTracking =>
      currentOrderId != null && currentActivityId != null;

  /// هل الطلب قيد التتبع؟
  /// Is order being tracked?
  bool isOrderBeingTracked(String orderId) => currentOrderId == orderId;

  /// هل يمكن تتبع الطلب؟
  /// Is order trackable?
  bool isOrderTrackable(String orderId) => trackableOrderIds.contains(orderId);

  /// هل يمكن بدء تتبع جديد؟
  /// Can start new tracking?
  bool get canStartTracking =>
      isServiceReady && !hasActiveTracking && !isStartingTracking;

  /// هل يمكن إيقاف التتبع الحالي؟
  /// Can stop current tracking?
  bool get canStopTracking => hasActiveTracking && !isStoppingTracking;

  @override
  List<Object?> get props => [
        isInitializing,
        isServiceReady,
        initializationError,
        currentOrderId,
        currentActivityId,
        currentTrackingData,
        isStartingTracking,
        isStoppingTracking,
        trackableOrderIds,
        isLoadingTrackableOrders,
        error,
        hasError,
      ];

  TrackingState copyWith({
    bool? isInitializing,
    bool? isServiceReady,
    String? initializationError,
    String? currentOrderId,
    String? currentActivityId,
    Map<String, dynamic>? currentTrackingData,
    bool? isStartingTracking,
    bool? isStoppingTracking,
    List<String>? trackableOrderIds,
    bool? isLoadingTrackableOrders,
    String? error,
    bool? hasError,
    bool clearError = false,
  }) {
    return TrackingState(
      isInitializing: isInitializing ?? this.isInitializing,
      isServiceReady: isServiceReady ?? this.isServiceReady,
      initializationError: initializationError ?? this.initializationError,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      currentActivityId: currentActivityId ?? this.currentActivityId,
      currentTrackingData: currentTrackingData ?? this.currentTrackingData,
      isStartingTracking: isStartingTracking ?? this.isStartingTracking,
      isStoppingTracking: isStoppingTracking ?? this.isStoppingTracking,
      trackableOrderIds: trackableOrderIds ?? this.trackableOrderIds,
      isLoadingTrackableOrders:
          isLoadingTrackableOrders ?? this.isLoadingTrackableOrders,
      error: clearError ? null : (error ?? this.error),
      hasError: clearError ? false : (hasError ?? this.hasError),
    );
  }
}
