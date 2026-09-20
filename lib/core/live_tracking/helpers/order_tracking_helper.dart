// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Order Tracking Helper
// ═══════════════════════════════════════════════════════════════════════════
// Helper functions لتسهيل استخدام Live Order Tracking
//
// Path: lib/core/live_tracking/helpers/order_tracking_helper.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:developer';

import '../models/order_tracking_model.dart';
import '../services/live_order_tracking_service.dart';
import 'package:app/models/order/order_model.dart';
import 'package:app/network/services/orders_services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Order Tracking Helper
// ═══════════════════════════════════════════════════════════════════════════
class OrderTrackingHelper {
  OrderTrackingHelper._(); // Private constructor

  static final _service = LiveOrderTrackingService();

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Quick Access Getters
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على الطلب الحالي
  static OrderTrackingModel? get currentTracking => _service.currentTracking;

  /// هل يوجد تتبع نشط
  static bool get hasActiveTracking => _service.hasActiveTracking;

  /// هل تم تهيئة الخدمة
  static bool get isInitialized => _service.isInitialized;

  /// Stream للتحديثات
  static Stream<OrderTrackingModel?> get trackingStream =>
      _service.trackingStream;

  // ═══════════════════════════════════════════════════════════════════════
  // 🚀 Initialization
  // ═══════════════════════════════════════════════════════════════════════

  /// تهيئة الخدمة
  static Future<void> initialize() async {
    await _service.initialize();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎬 Start Tracking
  // ═══════════════════════════════════════════════════════════════════════

  /// بدء التتبع من بيانات بسيطة
  static Future<bool> startTracking({
    required String orderId,
    required String orderReference,
    required String shippingStatus,
    DateTime? orderDate,
    String? driverName,
    String? driverPhone,
    String? driverImage,
    String? estimatedDeliveryTime,
    String? deliveryAddress,
    double? totalAmount,
    String? currency,
  }) async {
    try {
      final status = OrderTrackingStatus.fromString(shippingStatus);

      if (!status.isActive) {
        log('[TrackingHelper] Order $orderReference is not active (${status.name}), skipping');
        return false;
      }

      final tracking = OrderTrackingModel.withDefaultSteps(
        orderId: orderId,
        orderReference: orderReference,
        status: status,
        startTime: orderDate,
        driverName: driverName,
        driverPhone: driverPhone,
        driverImage: driverImage,
        estimatedDeliveryTime: estimatedDeliveryTime,
        deliveryAddress: deliveryAddress,
        totalAmount: totalAmount,
        currency: currency,
      );

      return await _service.startTracking(tracking);
    } catch (e) {
      log('[TrackingHelper] Error starting tracking: $e');
      return false;
    }
  }

  /// بدء التتبع من OrderTrackingModel
  static Future<bool> startTrackingWithModel(OrderTrackingModel tracking) async {
    return await _service.startTracking(tracking);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Update Tracking
  // ═══════════════════════════════════════════════════════════════════════

  /// تحديث التتبع من بيانات بسيطة
  static Future<bool> updateTracking({
    required String orderId,
    required String orderReference,
    required String shippingStatus,
    String? driverName,
    String? driverPhone,
    String? estimatedDeliveryTime,
    String? deliveryAddress,
  }) async {
    try {
      final status = OrderTrackingStatus.fromString(shippingStatus);

      final tracking = OrderTrackingModel.withDefaultSteps(
        orderId: orderId,
        orderReference: orderReference,
        status: status,
        driverName: driverName,
        driverPhone: driverPhone,
        estimatedDeliveryTime: estimatedDeliveryTime,
        deliveryAddress: deliveryAddress,
      );

      return await _service.updateTracking(tracking);
    } catch (e) {
      log('[TrackingHelper] Error updating tracking: $e');
      return false;
    }
  }

  /// تحديث التتبع من OrderTrackingModel
  static Future<bool> updateTrackingWithModel(OrderTrackingModel tracking) async {
    return await _service.updateTracking(tracking);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🛑 Stop Tracking
  // ═══════════════════════════════════════════════════════════════════════

  /// إيقاف التتبع
  static Future<void> stopTracking({bool silent = false}) async {
    await _service.stopTracking(silent: silent);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📩 FCM Notification Handling
  // ═══════════════════════════════════════════════════════════════════════

  /// معالجة إشعار FCM
  static Future<void> handleFCMNotification(Map<String, dynamic> data) async {
    try {
      log('[TrackingHelper] 🔔 Handling FCM notification');
      log('[TrackingHelper] 📦 Data: $data');

      final payload = _flattenNotificationData(data);

      // استخراج البيانات - مع دعم أسماء متعددة للحقول
      final orderId = _extractString(payload, [
        'order_id', 'orderId', 'id',
        'orderid', 'ORDER_ID'
      ]);
      
      final orderRef = _extractString(payload, [
        'order_reference', 'orderReference', 'reference', 'ref',
        'order_ref', 'orderRef', 'order_number', 'orderNumber'
      ]);

      // Prefer `screen` (event step). Top-level shipping_status was often
      // wrongly set to orders.status (Approved) which freezes on confirmed.
      final status = _extractShippingStep(payload);

      log('[TrackingHelper] 📋 Extracted - OrderID: $orderId, Ref: $orderRef, Status: $status');

      // إذا لم نجد order_id، جرب استخدام reference كـ ID
      final finalOrderId = orderId ?? orderRef ?? '';
      final finalOrderRef = orderRef ?? orderId ?? '';

      if (finalOrderId.isEmpty || status == null) {
        log('[TrackingHelper] ⚠️ Missing required notification data');
        log('[TrackingHelper] ❌ Cannot start/update Live Activity without order_id and status');
        return;
      }

      // استخراج البيانات الإضافية
      final driverName = _extractString(payload, [
        'driver_name', 'driverName', 'driver',
        'courier_name', 'courierName'
      ]);
      
      final driverPhone = _extractString(payload, [
        'driver_phone', 'driverPhone',
        'courier_phone', 'courierPhone'
      ]);
      
      final estimatedTime = _extractString(payload, [
        'estimated_delivery', 'estimatedDelivery', 'eta',
        'delivery_time', 'deliveryTime', 'estimated_time'
      ]);
      
      final address = _extractString(payload, [
        'delivery_address', 'deliveryAddress', 'address',
        'location', 'delivery_location'
      ]);

      // التحقق من نوع الإشعار والحالة
      final trackingStatus = OrderTrackingStatus.fromString(status);
      log('[TrackingHelper] 📊 Tracking Status: ${trackingStatus.name} (${trackingStatus.arabicText})');

      // ✅ FIX: إذا الطلبية اتلغت أو اتسلمت - نوقف الـ Live Activity
      if (trackingStatus == OrderTrackingStatus.cancelled || 
          trackingStatus == OrderTrackingStatus.delivered) {
        log('[TrackingHelper] 🛑 Order ${trackingStatus == OrderTrackingStatus.cancelled ? "cancelled" : "delivered"} - Stopping Live Activity...');
        await stopTracking(silent: false);
        log('[TrackingHelper] ✅ Live Activity stopped successfully');
        return;
      }

      // Match by numeric id OR reference (FCM sometimes sends one then the other)
      final existingTracking = _service.currentTracking;
      final isSameOrder = existingTracking != null && (
        existingTracking.orderId == finalOrderId ||
        existingTracking.orderReference == finalOrderRef ||
        existingTracking.orderId == finalOrderRef ||
        existingTracking.orderReference == finalOrderId
      );
      
      log('[TrackingHelper] 🔍 Existing tracking: ${existingTracking?.orderId} / ${existingTracking?.orderReference}');
      log('[TrackingHelper] 🔍 New order: $finalOrderId / $finalOrderRef');
      log('[TrackingHelper] 🔍 Same order? $isSameOrder');

      // Keep stable ids so ActivityId map lookup succeeds on update
      final updateOrderId = isSameOrder ? existingTracking!.orderId : finalOrderId;
      final updateOrderRef = isSameOrder
          ? (existingTracking!.orderReference.isNotEmpty
              ? existingTracking.orderReference
              : finalOrderRef)
          : finalOrderRef;

      if (isSameOrder) {
        log('[TrackingHelper] 🔄 Updating existing Live Activity for same order...');
        final success = await updateTracking(
          orderId: updateOrderId,
          orderReference: updateOrderRef,
          shippingStatus: status,
          driverName: driverName,
          driverPhone: driverPhone,
          estimatedDeliveryTime: estimatedTime,
          deliveryAddress: address,
        );
        
        if (success) {
          log('[TrackingHelper] ✅ Live Activity updated successfully!');
        } else {
          // Update failed (lost activityId) — force-replace Live Activity
          log('[TrackingHelper] ⚠️ Update failed, force-replacing Live Activity...');
          await stopTracking(silent: true);
          await Future.delayed(const Duration(milliseconds: 400));
          await startTracking(
            orderId: updateOrderId,
            orderReference: updateOrderRef,
            shippingStatus: status,
            driverName: driverName,
            driverPhone: driverPhone,
            estimatedDeliveryTime: estimatedTime,
            deliveryAddress: address,
          );
        }
      } else {
        if (existingTracking != null) {
          log('[TrackingHelper] 🛑 Ending old Live Activity for order: ${existingTracking.orderId}');
          await stopTracking(silent: true);
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        log('[TrackingHelper] 🆕 Starting new Live Activity...');
        final success = await startTracking(
          orderId: finalOrderId,
          orderReference: finalOrderRef,
          shippingStatus: status,
          driverName: driverName,
          driverPhone: driverPhone,
          estimatedDeliveryTime: estimatedTime,
          deliveryAddress: address,
        );
        
        if (success) {
          log('[TrackingHelper] ✅ Live Activity started successfully!');
        } else {
          log('[TrackingHelper] ❌ Failed to start Live Activity');
        }
      }

      log('[TrackingHelper] ✅ FCM notification handled successfully');
    } catch (e) {
      log('[TrackingHelper] ❌ Error handling FCM notification: $e');
    }
  }

  /// Alias for handleFCMNotification (for backward compatibility)
  static Future<void> handleOrderNotification(Map<String, dynamic> data) async {
    await handleFCMNotification(data);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📦 Start Tracking from OrderModel
  // ═══════════════════════════════════════════════════════════════════════

  /// بدء التتبع من OrderModel
  static Future<bool> startTrackingFromOrder(dynamic order) async {
    try {
      // Extract order data
      final orderId = order.id?.toString() ?? '';
      final orderRef = order.reference ?? '';
      final shippingStatus = order.shippingStatus ?? '';
      
      if (orderId.isEmpty || orderRef.isEmpty || shippingStatus.isEmpty) {
        log('[TrackingHelper] Missing required order data');
        return false;
      }

      // Extract optional data
      final location = order.location;
      final total = order.totalWithTax ?? order.total;
      
      return await startTracking(
        orderId: orderId,
        orderReference: orderRef,
        shippingStatus: shippingStatus,
        orderDate: order.checkoutDate,
        deliveryAddress: location,
        totalAmount: total?.toDouble(),
        currency: 'SAR',
      );
    } catch (e) {
      log('[TrackingHelper] Error starting tracking from order: $e');
      return false;
    }
  }

  /// استخراج قيمة نصية من البيانات
  static String? _extractString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  /// Order-level statuses that must not drive Live Activity steps.
  static const _orderLevelStatuses = {
    'approved', 'draft', 'pending', 'declined', 'rejected',
  };

  static const _shippingSteps = {
    'received', 'processing', 'delivery', 'delivered',
    'canceled', 'cancelled', 'approved', // Approved as screen = confirmed step
  };

  /// Pick the real shipping step for Live Activity.
  /// Prefer `screen` when it is a shipping event; ignore Approved-as-shipping_status.
  static String? _extractShippingStep(Map<String, dynamic> payload) {
    final screen = _extractString(payload, ['screen', 'Screen']);
    final shipping = _extractString(payload, [
      'shipping_status', 'shippingStatus',
      'delivery_status', 'order_status', 'orderStatus',
    ]);
    final generic = _extractString(payload, ['status', 'Status']);

    final screenNorm = screen?.toLowerCase().trim();
    final shippingNorm = shipping?.toLowerCase().trim();

    if (screen != null && screenNorm != null && _shippingSteps.contains(screenNorm)) {
      return screen;
    }
    if (shipping != null &&
        shippingNorm != null &&
        !_orderLevelStatuses.contains(shippingNorm)) {
      return shipping;
    }
    if (screen != null) return screen;
    if (generic != null &&
        !_orderLevelStatuses.contains(generic.toLowerCase().trim())) {
      return generic;
    }
    // Last resort: Approved/Received as first confirm step only
    return screen ?? shipping ?? generic;
  }

  static Map<String, dynamic> _flattenNotificationData(Map<String, dynamic> data) {
    final merged = Map<String, dynamic>.from(data);
    for (final key in ['notification_data', 'order']) {
      final parsed = _asMap(merged[key]);
      if (parsed == null) continue;
      parsed.forEach((nestedKey, nestedValue) {
        merged.putIfAbsent(nestedKey, () => nestedValue);
      });
    }
    return merged;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    if (value is String && value.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Utility Methods
  // ═══════════════════════════════════════════════════════════════════════

  /// تنظيف الموارد
  static Future<void> dispose() async {
    await _service.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 UI Helpers
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على لون الحالة
  static getStatusColor(OrderTrackingStatus status) => status.color;

  /// الحصول على لون الحالة الفاتح
  static getStatusLightColor(OrderTrackingStatus status) => status.lightColor;

  /// الحصول على أيقونة الحالة
  static getStatusIcon(OrderTrackingStatus status) => status.icon;

  /// الحصول على نص الحالة
  static getStatusText(OrderTrackingStatus status) => status.arabicText;

  /// الحصول على وصف الحالة
  static getStatusDescription(OrderTrackingStatus status) => status.description;

  /// الحصول على نسبة التقدم
  static getStatusProgress(OrderTrackingStatus status) => status.progressPercentage;

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Real-time Updates
  // ═══════════════════════════════════════════════════════════════════════

  /// تهيئة التحديثات التلقائية
  /// NOTE: Disabled because API doesn't support GET for single order
  /// Instead, we rely on periodic refresh of orders list
  static void setupRealtimeUpdates() {
    // Disabled - API returns 404 for GET /orders/{id}
    // _service.onFetchTrackingUpdate = _fetchOrderUpdate;
    log('[TrackingHelper] ⚠️ Real-time polling disabled (API limitation)');
  }

  /// جلب تحديث الطلب من السيرفر
  /// DISABLED: API doesn't support GET for single order
  static Future<OrderTrackingModel?> _fetchOrderUpdate(String orderId) async {
    // API doesn't support this endpoint
    return null;
  }

  /// تحويل OrderModel إلى OrderTrackingModel
  static OrderTrackingModel? _convertOrderModelToTracking(OrderModel order) {
    try {
      if (order.shippingStatus == null) return null;

      final status = OrderTrackingStatus.fromString(order.shippingStatus!);

      return OrderTrackingModel.withDefaultSteps(
        orderId: order.id.toString(),
        orderReference: order.reference ?? 'N/A',
        status: status,
        startTime: order.checkoutDate,
        deliveryAddress: order.location,
        totalAmount: order.totalWithTax,
        currency: 'SAR',
        // يمكن إضافة معلومات السائق إذا كانت متوفرة
      );
    } catch (e) {
      log('[TrackingHelper] Error converting OrderModel: $e');
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Extension on OrderTrackingModel for easy updates
// ═══════════════════════════════════════════════════════════════════════════
extension OrderTrackingModelX on OrderTrackingModel {
  /// بدء التتبع
  Future<bool> startTracking() async {
    return await OrderTrackingHelper.startTrackingWithModel(this);
  }

  /// تحديث التتبع
  Future<bool> updateTracking() async {
    return await OrderTrackingHelper.updateTrackingWithModel(this);
  }
}