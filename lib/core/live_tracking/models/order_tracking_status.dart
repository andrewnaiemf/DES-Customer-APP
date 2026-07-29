// ═══════════════════════════════════════════════════════════════════════════
// 📊 Order Tracking Status - Unified Enum
// ═══════════════════════════════════════════════════════════════════════════
// حالات تتبع الطلب الموحدة
// يجب استخدام هذا الـ Enum في كل التطبيق
//
// Path: lib/core/live_tracking/models/order_tracking_status.dart
// Created: February 9, 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../theme/tracking_colors.dart';

/// حالات تتبع الطلب الموحدة (8 خطوات + إلغاء)
enum OrderTrackingStatus {
  // ═══════════════════════════════════════════════════════════════════════
  // الحالات الأساسية (8 خطوات)
  // ═══════════════════════════════════════════════════════════════════════
  
  pending(
    step: 1,
    apiValue: 'pending',
    arabicText: 'في انتظار التأكيد',
    englishText: 'Pending Confirmation',
    arabicDescription: 'طلبك قيد المراجعة وسيتم تأكيده قريباً ⏳',
    englishDescription: 'Your order is being reviewed and will be confirmed soon',
    progressPercentage: 0.0,
    iconName: 'hourglass_empty',
  ),
  
  confirmed(
    step: 2,
    apiValue: 'confirmed',
    arabicText: 'تم تأكيد الطلب',
    englishText: 'Order Confirmed',
    arabicDescription: 'تم تأكيد طلبك وسيبدأ التحضير قريباً ✅',
    englishDescription: 'Your order has been confirmed and will be prepared soon',
    progressPercentage: 0.15,
    iconName: 'check_circle',
  ),
  
  preparing(
    step: 3,
    apiValue: 'preparing',
    arabicText: 'جاري التحضير',
    englishText: 'Preparing',
    arabicDescription: 'يتم تحضير طلبك الآن بعناية 👨‍🍳',
    englishDescription: 'Your order is being carefully prepared',
    progressPercentage: 0.30,
    iconName: 'restaurant',
  ),
  
  ready(
    step: 4,
    apiValue: 'ready',
    arabicText: 'جاهز للاستلام',
    englishText: 'Ready for Pickup',
    arabicDescription: 'طلبك جاهز وينتظر السائق 📦',
    englishDescription: 'Your order is ready and waiting for driver',
    progressPercentage: 0.45,
    iconName: 'inventory_2',
  ),
  
  pickedUp(
    step: 5,
    apiValue: 'picked_up',
    arabicText: 'تم الاستلام',
    englishText: 'Picked Up',
    arabicDescription: 'السائق استلم طلبك من المتجر 🚗',
    englishDescription: 'Driver has picked up your order from the store',
    progressPercentage: 0.60,
    iconName: 'local_shipping',
  ),
  
  onTheWay(
    step: 6,
    apiValue: 'on_the_way',
    arabicText: 'في الطريق إليك',
    englishText: 'On The Way',
    arabicDescription: 'طلبك في الطريق إليك الآن 🛵',
    englishDescription: 'Your order is on the way to you',
    progressPercentage: 0.75,
    iconName: 'delivery_dining',
  ),
  
  arrived(
    step: 7,
    apiValue: 'arrived',
    arabicText: 'السائق وصل',
    englishText: 'Driver Arrived',
    arabicDescription: 'السائق وصل إلى موقعك! 📍',
    englishDescription: 'Driver has arrived at your location!',
    progressPercentage: 0.90,
    iconName: 'location_on',
  ),
  
  delivered(
    step: 8,
    apiValue: 'delivered',
    arabicText: 'تم التسليم',
    englishText: 'Delivered',
    arabicDescription: 'تم تسليم طلبك بنجاح. شكراً لك! 🎉',
    englishDescription: 'Your order has been delivered successfully. Thank you!',
    progressPercentage: 1.0,
    iconName: 'check_circle',
  ),
  
  cancelled(
    step: -1,
    apiValue: 'cancelled',
    arabicText: 'تم الإلغاء',
    englishText: 'Cancelled',
    arabicDescription: 'تم إلغاء الطلب ❌',
    englishDescription: 'Order has been cancelled',
    progressPercentage: 0.0,
    iconName: 'cancel',
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Properties
  // ═══════════════════════════════════════════════════════════════════════
  
  final int step;
  final String apiValue;
  final String arabicText;
  final String englishText;
  final String arabicDescription;
  final String englishDescription;
  final double progressPercentage;
  final String iconName;

  const OrderTrackingStatus({
    required this.step,
    required this.apiValue,
    required this.arabicText,
    required this.englishText,
    required this.arabicDescription,
    required this.englishDescription,
    required this.progressPercentage,
    required this.iconName,
  });

  // ═══════════════════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════════════════
  
  /// النص حسب اللغة
  String getText(String locale) {
    return locale == 'ar' ? arabicText : englishText;
  }
  
  /// الوصف حسب اللغة
  String getDescription(String locale) {
    return locale == 'ar' ? arabicDescription : englishDescription;
  }
  
  /// اللون
  Color get color {
    switch (this) {
      case OrderTrackingStatus.pending:
        return TrackingColors.orderPlaced;
      case OrderTrackingStatus.confirmed:
        return TrackingColors.confirmed;
      case OrderTrackingStatus.preparing:
        return TrackingColors.preparing;
      case OrderTrackingStatus.ready:
        return TrackingColors.ready;
      case OrderTrackingStatus.pickedUp:
        return TrackingColors.pickedUp;
      case OrderTrackingStatus.onTheWay:
        return TrackingColors.outForDelivery;
      case OrderTrackingStatus.arrived:
        return TrackingColors.arrived;
      case OrderTrackingStatus.delivered:
        return TrackingColors.delivered;
      case OrderTrackingStatus.cancelled:
        return TrackingColors.cancelled;
    }
  }
  
  /// اللون الفاتح
  Color get lightColor => color.withOpacity(0.2);
  
  /// اللون الداكن
  Color get darkColor {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }
  
  /// الأيقونة
  IconData get iconData {
    switch (iconName) {
      case 'hourglass_empty':
        return Icons.hourglass_empty;
      case 'check_circle':
        return Icons.check_circle;
      case 'restaurant':
        return Icons.restaurant;
      case 'inventory_2':
        return Icons.inventory_2;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'delivery_dining':
        return Icons.delivery_dining;
      case 'location_on':
        return Icons.location_on;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  /// Alias للأيقونة (للتوافق مع الكود القديم)
  IconData get icon => iconData;
  
  /// الأيقونة المخططة
  IconData get outlinedIcon {
    switch (iconName) {
      case 'hourglass_empty':
        return Icons.hourglass_empty_outlined;
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'inventory_2':
        return Icons.inventory_2_outlined;
      case 'local_shipping':
        return Icons.local_shipping_outlined;
      case 'delivery_dining':
        return Icons.delivery_dining_outlined;
      case 'location_on':
        return Icons.location_on_outlined;
      case 'cancel':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
  
  /// النسبة المئوية (0-100)
  int get progressPercent => (progressPercentage * 100).toInt();

  /// Alias للوصف (للتوافق مع الكود القديم)
  String get description => arabicDescription;

  /// الوصف المختصر (للتوافق مع الكود القديم)
  String get shortDescription {
    switch (this) {
      case OrderTrackingStatus.pending:
        return 'قيد الانتظار';
      case OrderTrackingStatus.confirmed:
        return 'مؤكد';
      case OrderTrackingStatus.preparing:
        return 'قيد التحضير';
      case OrderTrackingStatus.ready:
        return 'جاهز';
      case OrderTrackingStatus.pickedUp:
        return 'تم الاستلام';
      case OrderTrackingStatus.onTheWay:
        return 'في الطريق';
      case OrderTrackingStatus.arrived:
        return 'وصل';
      case OrderTrackingStatus.delivered:
        return 'تم التسليم';
      case OrderTrackingStatus.cancelled:
        return 'ملغي';
    }
  }
  
  /// هل الحالة نشطة؟
  bool get isActive => this != delivered && this != cancelled;
  
  /// هل الحالة مكتملة (delivered)؟
  bool get isCompleted => this == delivered;
  
  /// هل تم التوصيل؟
  bool get isDelivered => this == delivered;
  
  /// هل الحالة ملغاة؟
  bool get isCancelled => this == cancelled;
  
  /// هل الحالة نهائية؟
  bool get isTerminal => this == delivered || this == cancelled;
  
  /// هل تحتاج معلومات السائق؟
  bool get needsDriverInfo => 
      this == pickedUp || 
      this == onTheWay || 
      this == arrived;
  
  /// الخطوة التالية
  OrderTrackingStatus? get nextStep {
    if (isTerminal) return null;
    final currentIndex = OrderTrackingStatus.activeSteps.indexOf(this);
    if (currentIndex == -1 || currentIndex >= OrderTrackingStatus.activeSteps.length - 1) {
      return null;
    }
    return OrderTrackingStatus.activeSteps[currentIndex + 1];
  }
  
  /// عنوان الإشعار
  String getNotificationTitle(String locale) {
    switch (this) {
      case OrderTrackingStatus.pending:
        return locale == 'ar' ? '⏳ في انتظار التأكيد' : '⏳ Pending Confirmation';
      case OrderTrackingStatus.confirmed:
        return locale == 'ar' ? '✅ تم تأكيد طلبك' : '✅ Order Confirmed';
      case OrderTrackingStatus.preparing:
        return locale == 'ar' ? '👨‍🍳 جاري تحضير طلبك' : '👨‍🍳 Preparing Your Order';
      case OrderTrackingStatus.ready:
        return locale == 'ar' ? '📦 طلبك جاهز' : '📦 Order Ready';
      case OrderTrackingStatus.pickedUp:
        return locale == 'ar' ? '🚗 السائق استلم طلبك' : '🚗 Driver Picked Up';
      case OrderTrackingStatus.onTheWay:
        return locale == 'ar' ? '🛵 طلبك في الطريق' : '🛵 On The Way';
      case OrderTrackingStatus.arrived:
        return locale == 'ar' ? '📍 السائق وصل!' : '📍 Driver Arrived!';
      case OrderTrackingStatus.delivered:
        return locale == 'ar' ? '🎉 تم التسليم بنجاح' : '🎉 Delivered Successfully';
      case OrderTrackingStatus.cancelled:
        return locale == 'ar' ? '❌ تم إلغاء الطلب' : '❌ Order Cancelled';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Static Methods
  // ═══════════════════════════════════════════════════════════════════════
  
  /// جميع الخطوات النشطة (بدون cancelled)
  static List<OrderTrackingStatus> get activeSteps => [
    pending,
    confirmed,
    preparing,
    ready,
    pickedUp,
    onTheWay,
    arrived,
    delivered,
  ];

  // Aliases للتوافق مع الكود القديم (const values)
  static const OrderTrackingStatus orderPlaced = pending;
  static const OrderTrackingStatus outForDelivery = onTheWay;
  
  /// تحويل من String
  static OrderTrackingStatus fromString(String? value) {
    if (value == null || value.isEmpty) return pending;
    
    // التعامل مع أسماء متعددة
    final normalizedValue = value.toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .trim();
    
    // محاولة المطابقة المباشرة
    try {
      return OrderTrackingStatus.values.firstWhere(
        (status) => 
          status.apiValue == normalizedValue ||
          status.name.toLowerCase() == normalizedValue ||
          status.apiValue.replaceAll('_', '') == normalizedValue.replaceAll('_', ''),
      );
    } catch (_) {
      // التعامل مع القيم القديمة أو البديلة
      switch (normalizedValue) {
        // Pending aliases
        case 'order_placed':
        case 'orderplaced':
        case 'placed':
        case 'new':
          return pending;
          
        // Confirmed aliases
        case 'approved':
        case 'accepted':
          return confirmed;
          
        // Preparing aliases
        case 'processing':
        case 'in_preparation':
        case 'inpreparation':
          return preparing;
          
        // Ready aliases
        case 'ready_for_pickup':
        case 'readyforpickup':
        case 'ready_to_ship':
        case 'readytoship':
          return ready;
          
        // Picked Up aliases
        case 'pickup':
        case 'pickedup':
        case 'collected':
          return pickedUp;
          
        // On The Way aliases
        case 'out_for_delivery':
        case 'outfordelivery':
        case 'in_transit':
        case 'intransit':
        case 'shipped':
        case 'shipping':
        case 'delivery':
          return onTheWay;
          
        // Arrived aliases
        case 'arriving':
        case 'near':
        case 'nearby':
          return arrived;
          
        // Delivered aliases
        case 'complete':
        case 'completed':
        case 'done':
          return delivered;
          
        // Cancelled aliases
        case 'canceled':
        case 'rejected':
        case 'declined':
          return cancelled;
          
        default:
          return pending;
      }
    }
  }
  
  /// تحويل من API Response
  static OrderTrackingStatus fromApiResponse(Map<String, dynamic> data) {
    // محاولة استخراج الحالة من حقول مختلفة
    final status = data['shipping_status'] ?? 
                   data['status'] ?? 
                   data['order_status'] ??
                   data['tracking_status'] ??
                   data['delivery_status'];
    
    return fromString(status?.toString());
  }
  
  /// الحصول على الخطوة بالرقم
  static OrderTrackingStatus? fromStep(int stepNumber) {
    try {
      return OrderTrackingStatus.activeSteps.firstWhere((status) => status.step == stepNumber);
    } catch (_) {
      return null;
    }
  }

  /// Alias for fromString (للتوافق مع الكود القديم)
  static OrderTrackingStatus fromShippingStatus(String? status) =>
      fromString(status);
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Extension Methods
// ═══════════════════════════════════════════════════════════════════════════

extension OrderTrackingStatusExtension on OrderTrackingStatus {
  /// مقارنة الخطوات
  bool isAfter(OrderTrackingStatus other) {
    if (isCancelled || other.isCancelled) return false;
    return step > other.step;
  }
  
  bool isBefore(OrderTrackingStatus other) {
    if (isCancelled || other.isCancelled) return false;
    return step < other.step;
  }

  /// التحقق من أن الحالة مكتملة بالنسبة لحالة أخرى
  bool isCompletedFor(OrderTrackingStatus other) {
    if (isCancelled) return false;
    if (other.isCancelled) return false;
    return step >= other.step;
  }
  
  /// الحصول على الخطوات بين حالتين
  List<OrderTrackingStatus> stepsUntil(OrderTrackingStatus target) {
    if (isTerminal || target.isTerminal) return [];
    
    final startIndex = OrderTrackingStatus.activeSteps.indexOf(this);
    final endIndex = OrderTrackingStatus.activeSteps.indexOf(target);
    
    if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
      return [];
    }
    
    return OrderTrackingStatus.activeSteps.sublist(startIndex + 1, endIndex + 1);
  }
}
