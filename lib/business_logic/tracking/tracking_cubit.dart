import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/live_tracking/services/live_order_tracking_service.dart';
import '../../core/live_tracking/models/order_tracking_model.dart';
import '../../core/live_tracking/models/order_tracking_status.dart';
import '../../services/tracking_error_handler.dart';
import 'tracking_state.dart';

/// Cubit لإدارة حالة التتبع المباشر
/// Live tracking state management cubit
class TrackingCubit extends Cubit<TrackingState> {
  final LiveOrderTrackingService _trackingService;
  final TrackingErrorHandler _errorHandler;

  StreamSubscription? _trackingSubscription;
  Timer? _cleanupTimer;

  // ✅ Static instance للوصول من أي مكان
  static TrackingCubit? instance;

  TrackingCubit({
    required LiveOrderTrackingService trackingService,
    required TrackingErrorHandler errorHandler,
  })  : _trackingService = trackingService,
        _errorHandler = errorHandler,
        super(TrackingState.initial()) {
    instance = this; // تعيين الـ instance
    _initialize();
  }

  /// تهيئة الخدمة
  /// Initialize service
  Future<void> _initialize() async {
    try {
      emit(state.copyWith(isInitializing: true, clearError: true));

      // Initialize tracking service
      await _trackingService.initialize();

      // Listen to tracking updates
      _trackingSubscription = _trackingService.trackingStream.listen(
        (tracking) {
          if (tracking != null) {
            emit(state.copyWith(
              currentOrderId: tracking.orderId,
              currentActivityId: null, // Will be set by the service
              currentTrackingData: tracking.toJson(),
              isServiceReady: true,
            ));
          } else {
            emit(state.copyWith(
              currentOrderId: null,
              currentActivityId: null,
              currentTrackingData: null,
              isServiceReady: true,
            ));
          }
        },
        onError: (error) {
          final trackingError = TrackingError.unknown(
            message: 'Error in tracking stream',
            originalError: error,
          );
          emit(state.copyWith(
            error: _errorHandler.getUserFriendlyMessage(trackingError),
            hasError: true,
          ));
        },
      );

      emit(state.copyWith(
        isInitializing: false,
        isServiceReady: true,
      ));
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing tracking: $e');
      emit(state.copyWith(
        isInitializing: false,
        isServiceReady: false,
        initializationError: 'فشل تهيئة خدمة التتبع',
        error: 'فشل تهيئة خدمة التتبع',
        hasError: true,
      ));
    }
  }

  /// مزامنة مع الطلبات المتاحة
  /// Sync with available orders
  Future<void> syncWithOrders(List<String> currentOrderIds) async {
    try {
      // Get trackable orders (orders with shipping status)
      final trackableOrders = currentOrderIds.where((orderId) {
        // Here you would check if order has shippingStatus
        // For now, we assume all current orders are trackable
        return true;
      }).toList();

      emit(state.copyWith(trackableOrderIds: trackableOrders));

      // Auto-start tracking if:
      // 1. No active tracking
      // 2. There are trackable orders
      // 3. Service is ready
      if (!state.hasActiveTracking &&
          trackableOrders.isNotEmpty &&
          state.isServiceReady) {
        await _selectOrderToTrack(trackableOrders);
      }

      // Stop tracking if current order is no longer visible
      if (state.hasActiveTracking &&
          state.currentOrderId != null &&
          !currentOrderIds.contains(state.currentOrderId)) {
        debugPrint(
            '⚠️ Current tracking order is no longer visible, stopping tracking');
        await stopTracking();
      }
    } catch (e) {
      debugPrint('❌ Error syncing with orders: $e');
    }
  }

  /// اختيار طلب للتتبع تلقائياً
  /// Auto-select order to track
  Future<void> _selectOrderToTrack(List<String> trackableOrders) async {
    try {
      // Select most recent order (first in list)
      final orderToTrack = trackableOrders.first;
      debugPrint('🎯 Auto-starting tracking for order: $orderToTrack');
      await startTracking(orderToTrack);
    } catch (e) {
      debugPrint('❌ Error auto-selecting order: $e');
    }
  }

  /// بدء التتبع لطلب معين
  /// Start tracking for specific order
  Future<void> startTracking(String orderId) async {
    if (!state.canStartTracking) {
      debugPrint('⚠️ Cannot start tracking: service not ready or already tracking');
      return;
    }

    try {
      emit(state.copyWith(isStartingTracking: true, clearError: true));

      await _errorHandler.executeWithRetry(
        operation: () async {
          // Create a basic tracking model for the order
          final trackingModel = OrderTrackingModel(
            orderId: orderId,
            orderReference: '#$orderId',
            status: OrderTrackingStatus.pending,
          );
          await _trackingService.startTracking(trackingModel);
        },
        operationName: 'Start Tracking',
        onError: (error) {
          emit(state.copyWith(
            error: _errorHandler.getUserFriendlyMessage(error),
            hasError: true,
            isStartingTracking: false,
          ));
        },
      );

      emit(state.copyWith(isStartingTracking: false));
    } catch (e) {
      debugPrint('❌ Error starting tracking: $e');
      emit(state.copyWith(
        isStartingTracking: false,
        error: 'فشل بدء التتبع',
        hasError: true,
      ));
    }
  }

  /// إيقاف التتبع الحالي
  /// Stop current tracking
  Future<void> stopTracking() async {
    if (!state.canStopTracking) {
      debugPrint('⚠️ Cannot stop tracking: no active tracking');
      return;
    }

    try {
      emit(state.copyWith(isStoppingTracking: true, clearError: true));

      await _errorHandler.executeWithRetry(
        operation: () async {
          await _trackingService.stopTracking();
        },
        operationName: 'Stop Tracking',
        onError: (error) {
          emit(state.copyWith(
            error: _errorHandler.getUserFriendlyMessage(error),
            hasError: true,
            isStoppingTracking: false,
          ));
        },
      );

      emit(state.copyWith(
        isStoppingTracking: false,
        currentOrderId: null,
        currentActivityId: null,
        currentTrackingData: null,
      ));
    } catch (e) {
      debugPrint('❌ Error stopping tracking: $e');
      emit(state.copyWith(
        isStoppingTracking: false,
        error: 'فشل إيقاف التتبع',
        hasError: true,
      ));
    }
  }

  /// إيقاف التتبع لطلب معين
  /// Stop tracking for a specific order
  Future<void> stopTrackingForOrder(String orderId) async {
    try {
      // التحقق من أن هذا الطلب هو المتتبع حالياً
      if (state.currentOrderId == orderId) {
        debugPrint('🛑 Stopping tracking for cancelled/declined order: $orderId');
        await stopTracking();
      } else {
        debugPrint('ℹ️ Order $orderId is not currently being tracked, skipping');
      }
    } catch (e) {
      debugPrint('❌ Error stopping tracking for order $orderId: $e');
    }
  }

  /// التبديل إلى طلب آخر
  /// Switch to another order
  Future<void> switchTracking(String newOrderId) async {
    try {
      if (state.hasActiveTracking) {
        await stopTracking();
      }
      await startTracking(newOrderId);
    } catch (e) {
      debugPrint('❌ Error switching tracking: $e');
      emit(state.copyWith(
        error: 'فشل التبديل إلى طلب آخر',
        hasError: true,
      ));
    }
  }

  /// جدولة التنظيف التلقائي للتتبع المكتمل
  /// Schedule automatic cleanup for completed tracking
  void _scheduleTrackingCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer(const Duration(seconds: 5), () async {
      if (state.hasActiveTracking) {
        final trackingData = state.currentTrackingData;
        if (trackingData != null) {
          final status = trackingData['shippingStatus'] as String?;
          if (status == 'delivered' || status == 'cancelled') {
            debugPrint('🧹 Auto-cleaning completed tracking');
            await stopTracking();
          }
        }
      }
    });
  }

  /// مسح الخطأ الحالي
  /// Clear current error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    _cleanupTimer?.cancel();
    return super.close();
  }
}
