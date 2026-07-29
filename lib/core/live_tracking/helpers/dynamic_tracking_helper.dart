// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Dynamic Order Tracking Helper
// ═══════════════════════════════════════════════════════════════════════════
// Helper متطور لإدارة Live Tracking بشكل ديناميكي كامل

import 'dart:async';
import 'dart:developer';

import 'package:app/core/live_tracking/models/order_tracking_model.dart';
import 'package:app/core/live_tracking/services/live_order_tracking_service.dart';
import 'package:app/models/order/order_model.dart';
import 'package:app/models/order_item/order_item_model.dart';
import 'package:flutter/material.dart';

class DynamicTrackingHelper {
  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 Singleton Pattern
  // ═══════════════════════════════════════════════════════════════════════════
  static final DynamicTrackingHelper _instance = DynamicTrackingHelper._internal();
  factory DynamicTrackingHelper() => _instance;
  DynamicTrackingHelper._internal();

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 Properties
  // ═══════════════════════════════════════════════════════════════════════════
  final LiveOrderTrackingService _service = LiveOrderTrackingService();
  
  // Stream Controller للبث المباشر
  final _trackingController = StreamController<OrderTrackingModel?>.broadcast();
  
  // Current tracking model
  OrderTrackingModel? _currentTracking;
  
  // Timer للتحديث التلقائي
  Timer? _updateTimer;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 Public Getters
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Stream للاستماع للتغييرات
  Stream<OrderTrackingModel?> get trackingStream => _trackingController.stream;
  
  /// Current tracking model
  OrderTrackingModel? get currentTracking => _currentTracking;
  
  /// Is tracking active
  bool get isTracking => _currentTracking != null && _currentTracking!.isActive;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎬 Initialization
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// تهيئة الخدمة
  static Future<void> initialize() async {
    try {
      await DynamicTrackingHelper()._service.initialize();
      log('✅ DynamicTrackingHelper initialized');
    } catch (e) {
      log('❌ Error initializing DynamicTrackingHelper: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚀 Dynamic Start Tracking
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// بدء التتبع بشكل ديناميكي
  static Future<bool> startTracking({
    required String orderId,
    required String orderReference,
    required String shippingStatus,
    String? customerName,
    String? deliveryAddress,
    String? driverName,
    String? driverPhone,
    String? estimatedDeliveryTime,
    List<OrderItemModel>? items,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final helper = DynamicTrackingHelper();
      
      // تحويل shipping status إلى OrderTrackingStatus
      final status = OrderTrackingStatus.fromShippingStatus(shippingStatus);
      
      // إنشاء tracking model
      final tracking = OrderTrackingModel(
        orderId: orderId,
        orderReference: orderReference,
        status: status,
        deliveryAddress: deliveryAddress,
        estimatedDeliveryTime: estimatedDeliveryTime,
        driverName: driverName,
        driverPhone: driverPhone,
        startTime: DateTime.now(),
        lastUpdateTime: DateTime.now(),
        steps: _buildSteps(status),
        metadata: {
          ...?metadata,
          'customer_name': customerName,
          'items': items?.map((e) => {
            'product_id': e.productId,
            'quantity': e.quantity,
            'name': e.product.nameAr, // استخدام nameAr بدلاً من title
          }).toList(),
        },
      );
      
      // ✅ التحقق: إذا كان في tracking موجود للطلب، نعمل update مش start
      final currentTracking = helper._service.currentTracking;
      final isUpdate = currentTracking != null && currentTracking.orderId == orderId;
      
      bool success;
      if (isUpdate) {
        log('🔄 Updating existing tracking: $orderReference');
        success = await helper._service.updateTracking(tracking);
      } else {
        log('🆕 Starting new tracking: $orderReference');
        success = await helper._service.startTracking(tracking);
      }
      
      if (success) {
        helper._currentTracking = tracking;
        helper._trackingController.add(tracking);
        if (!isUpdate) {
          helper._startAutoUpdate();
        }
        log('✅ ${isUpdate ? "Updated" : "Started"} tracking: $orderReference');
      }
      
      return success;
    } catch (e) {
      log('❌ Error starting tracking: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 Update Status
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// تحديث حالة الطلب
  static Future<bool> updateStatus(
    OrderTrackingStatus newStatus, {
    String? driverName,
    String? driverPhone,
    String? estimatedDeliveryTime,
  }) async {
    try {
      final helper = DynamicTrackingHelper();
      
      if (helper._currentTracking == null) {
        log('⚠️ No active tracking to update');
        return false;
      }
      
      // تحديث الـ tracking model
      final updatedTracking = helper._currentTracking!.copyWith(
        status: newStatus,
        driverName: driverName ?? helper._currentTracking!.driverName,
        driverPhone: driverPhone ?? helper._currentTracking!.driverPhone,
        estimatedDeliveryTime: estimatedDeliveryTime ?? helper._currentTracking!.estimatedDeliveryTime,
        lastUpdateTime: DateTime.now(),
        steps: _buildSteps(newStatus),
      );
      
      // تحديث في الخدمة
      final success = await helper._service.updateTracking(updatedTracking);
      
      if (success) {
        helper._currentTracking = updatedTracking;
        helper._trackingController.add(updatedTracking);
        log('✅ Updated status to: ${newStatus.name}');
        
        // إيقاف التتبع إذا تم التسليم أو الإلغاء
        if (!newStatus.isActive) {
          await Future.delayed(const Duration(seconds: 2));
          await stopTracking();
        }
      }
      
      return success;
    } catch (e) {
      log('❌ Error updating status: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🛑 Stop Tracking
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// إيقاف التتبع
  static Future<void> stopTracking() async {
    try {
      final helper = DynamicTrackingHelper();
      
      await helper._service.stopTracking();
      helper._stopAutoUpdate();
      helper._currentTracking = null;
      helper._trackingController.add(null);
      
      log('✅ Tracking stopped');
    } catch (e) {
      log('❌ Error stopping tracking: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 Start from Order Model
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// بدء التتبع من Order Model
  static Future<bool> startTrackingFromOrder(OrderModel order) async {
    return await startTracking(
      orderId: order.id.toString(),
      orderReference: order.reference ?? 'ORD-${order.id}',
      shippingStatus: order.shippingStatus ?? 'received',
      customerName: order.customer?.name,
      deliveryAddress: order.location,
      items: order.orderItems,
      metadata: {
        'order_date': order.checkoutDate.toString(),
        'total_amount': order.total,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔔 Handle FCM Notification
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// معالجة إشعار FCM لتحديث الطلب
  static Future<void> handleOrderNotification(Map<String, dynamic> data) async {
    try {
      log('📩 Handling order notification');
      
      final orderId = data['order_id']?.toString();
      final shippingStatus = data['shipping_status']?.toString();
      
      if (orderId == null || shippingStatus == null) {
        log('⚠️ Missing order data in notification');
        return;
      }
      
      final helper = DynamicTrackingHelper();
      
      // التحقق من وجود tracking نشط لنفس الطلب
      if (helper._currentTracking?.orderId == orderId) {
        final status = OrderTrackingStatus.fromShippingStatus(shippingStatus);
        await updateStatus(
          status,
          driverName: data['driver_name'],
          driverPhone: data['driver_phone'],
          estimatedDeliveryTime: data['estimated_delivery'],
        );
      } else {
        // بدء tracking جديد
        await startTracking(
          orderId: orderId,
          orderReference: data['order_reference'] ?? 'ORD-$orderId',
          shippingStatus: shippingStatus,
          driverName: data['driver_name'],
          driverPhone: data['driver_phone'],
          estimatedDeliveryTime: data['estimated_delivery'],
        );
      }
    } catch (e) {
      log('❌ Error handling order notification: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 Auto Update
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// بدء التحديث التلقائي
  void _startAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentTracking != null) {
        // إرسال نفس البيانات للحفاظ على النشاط
        _trackingController.add(_currentTracking);
      }
    });
  }
  
  /// إيقاف التحديث التلقائي
  void _stopAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🛠️ Helper Methods
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// بناء الخطوات بناءً على الحالة
  static List<OrderTrackingStep> _buildSteps(OrderTrackingStatus currentStatus) {
    final steps = <OrderTrackingStep>[];
    final allStatuses = [
      OrderTrackingStatus.orderPlaced,
      OrderTrackingStatus.preparing,
      OrderTrackingStatus.outForDelivery,
      OrderTrackingStatus.delivered,
    ];
    
    for (var i = 0; i < allStatuses.length; i++) {
      final status = allStatuses[i];
      final isCompleted = i <= currentStatus.index && currentStatus != OrderTrackingStatus.cancelled;
      final isCurrent = i == currentStatus.index;
      
      steps.add(OrderTrackingStep(
        status: status,
        title: _getStatusTitle(status),
        description: _getStatusDescription(status),
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        completedAt: isCompleted ? DateTime.now() : null,
      ));
    }
    
    return steps;
  }
  
  /// تحليل وقت التسليم المتوقع
  static DateTime _parseEstimatedTime(String estimatedTime) {
    try {
      // محاولة تحليل كـ DateTime
      return DateTime.tryParse(estimatedTime) ?? 
             DateTime.now().add(const Duration(hours: 1));
    } catch (e) {
      // إذا كان نص مثل "30-45 دقيقة"
      final numbers = RegExp(r'\d+').allMatches(estimatedTime);
      if (numbers.isNotEmpty) {
        final minutes = int.tryParse(numbers.first.group(0) ?? '60') ?? 60;
        return DateTime.now().add(Duration(minutes: minutes));
      }
      return DateTime.now().add(const Duration(hours: 1));
    }
  }
  
  /// الحصول على عنوان الحالة
  static String _getStatusTitle(OrderTrackingStatus status) {
    // استخدام الـ property المدمج
    return status.arabicText;
  }
  
  /// الحصول على وصف الحالة
  static String _getStatusDescription(OrderTrackingStatus status) {
    // استخدام الـ property المدمج
    return status.arabicDescription;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🧹 Cleanup
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// تنظيف الموارد
  void dispose() {
    _stopAutoUpdate();
    _trackingController.close();
  }
}
