// ═══════════════════════════════════════════════════════════════════════════
// 📦 Order Tracking Models & Enums
// ═══════════════════════════════════════════════════════════════════════════
// الموديلات والـ Enums الخاصة بتتبع الطلبات
//
// Path: lib/core/live_tracking/models/order_tracking_model.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../theme/tracking_colors.dart';
import 'order_tracking_status.dart';

// إعادة تصدير للاستخدام الخارجي
export 'order_tracking_status.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📍 Order Tracking Step Model
// ═══════════════════════════════════════════════════════════════════════════
class OrderTrackingStep {
  final OrderTrackingStatus status;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isCurrent;
  final DateTime? completedAt;
  final String? note;

  const OrderTrackingStep({
    required this.status,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.isCurrent = false,
    this.completedAt,
    this.note,
  });

  /// الحصول على اللون
  Color get color => status.color;

  /// الحصول على اللون الفاتح
  Color get lightColor => status.lightColor;

  /// الحصول على الأيقونة
  IconData get icon => isCompleted ? Icons.check_rounded : status.icon;

  /// الحصول على الأيقونة الأصلية
  IconData get originalIcon => status.icon;

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() => {
    'status': status.name,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'isCurrent': isCurrent,
    'completedAt': completedAt?.toIso8601String(),
    'note': note,
  };

  /// إنشاء من JSON
  factory OrderTrackingStep.fromJson(Map<String, dynamic> json) {
    final status = OrderTrackingStatus.fromString(json['status']?.toString());
    return OrderTrackingStep(
      status: status,
      title: json['title']?.toString() ?? status.arabicText,
      description: json['description']?.toString() ?? status.description,
      isCompleted: json['isCompleted'] == true,
      isCurrent: json['isCurrent'] == true,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      note: json['note']?.toString(),
    );
  }

  /// إنشاء من Status مباشرة
  factory OrderTrackingStep.fromStatus(
      OrderTrackingStatus stepStatus, {
        required OrderTrackingStatus currentStatus,
        DateTime? completedAt,
        String? note,
      }) {
    final isCompleted = currentStatus.isCompletedFor(stepStatus);
    final isCurrent = currentStatus == stepStatus;

    return OrderTrackingStep(
      status: stepStatus,
      title: stepStatus.arabicText,
      description: stepStatus.description,
      isCompleted: isCompleted,
      isCurrent: isCurrent,
      completedAt: isCompleted ? (completedAt ?? DateTime.now()) : null,
      note: note,
    );
  }

  /// نسخ مع تعديل
  OrderTrackingStep copyWith({
    OrderTrackingStatus? status,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isCurrent,
    DateTime? completedAt,
    String? note,
  }) {
    return OrderTrackingStep(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderTrackingStep &&
        other.status == status &&
        other.isCompleted == isCompleted &&
        other.isCurrent == isCurrent;
  }

  @override
  int get hashCode => Object.hash(status, isCompleted, isCurrent);

  @override
  String toString() =>
      'OrderTrackingStep(status: ${status.name}, isCompleted: $isCompleted, isCurrent: $isCurrent)';
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Order Tracking Model
// ═══════════════════════════════════════════════════════════════════════════
class OrderTrackingModel {
  final String orderId;
  final String orderReference;
  final OrderTrackingStatus status;
  final DateTime? startTime;
  final DateTime? lastUpdateTime;
  final String? driverName;
  final String? driverPhone;
  final String? driverImage;
  final String? estimatedDeliveryTime;
  final String? deliveryAddress;
  final double? totalAmount;
  final String? currency;
  final List<OrderTrackingStep> steps;
  final Map<String, dynamic>? metadata;

  const OrderTrackingModel({
    required this.orderId,
    required this.orderReference,
    required this.status,
    this.startTime,
    this.lastUpdateTime,
    this.driverName,
    this.driverPhone,
    this.driverImage,
    this.estimatedDeliveryTime,
    this.deliveryAddress,
    this.totalAmount,
    this.currency,
    this.steps = const [],
    this.metadata,
  });

  // ═══════════════════════════════════════════════════════════════════════
  // 🔍 Getters
  // ═══════════════════════════════════════════════════════════════════════

  /// التحقق من كون الطلب نشط
  bool get isActive => status.isActive;

  /// التحقق من كون الطلب مكتمل
  bool get isCompleted => status.isCompleted;

  /// التحقق من كون الطلب ملغي
  bool get isCancelled => status.isCancelled;

  /// الحصول على نسبة التقدم
  double get progressPercentage => status.progressPercentage;

  /// الحصول على نسبة التقدم كنسبة مئوية
  int get progressPercent => status.progressPercent;

  /// الحصول على اللون
  Color get color => status.color;

  /// الحصول على اللون الفاتح
  Color get lightColor => status.lightColor;

  /// الحصول على الأيقونة
  IconData get icon => status.icon;

  /// الحصول على النص
  String get statusText => status.arabicText;

  /// الحصول على النص الإنجليزي
  String get statusTextEn => status.englishText;

  /// الحصول على الوصف
  String get statusDescription => status.description;

  /// الحصول على الخطوة الحالية
  OrderTrackingStep? get currentStep {
    try {
      return steps.firstWhere((step) => step.isCurrent);
    } catch (_) {
      return steps.isNotEmpty ? steps.last : null;
    }
  }

  /// الحصول على الخطوات المكتملة
  List<OrderTrackingStep> get completedSteps =>
      steps.where((step) => step.isCompleted).toList();

  /// الحصول على الخطوات المتبقية
  List<OrderTrackingStep> get remainingSteps =>
      steps.where((step) => !step.isCompleted).toList();

  /// الحصول على عدد الخطوات المكتملة
  int get completedStepsCount => completedSteps.length;

  /// الحصول على إجمالي الخطوات
  int get totalStepsCount => steps.length;

  /// هل يوجد معلومات السائق
  bool get hasDriverInfo =>
      driverName != null && driverName!.isNotEmpty;

  /// هل يوجد وقت توصيل متوقع
  bool get hasEstimatedTime =>
      estimatedDeliveryTime != null && estimatedDeliveryTime!.isNotEmpty;

  /// هل يوجد عنوان توصيل
  bool get hasDeliveryAddress =>
      deliveryAddress != null && deliveryAddress!.isNotEmpty;

  /// الحصول على المبلغ المنسق
  String get formattedAmount {
    if (totalAmount == null) return '';
    final curr = currency ?? 'SAR';
    return '${totalAmount!.toStringAsFixed(2)} $curr';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Serialization
  // ═══════════════════════════════════════════════════════════════════════

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'orderReference': orderReference,
    'status': status.name,
    'startTime': startTime?.toIso8601String(),
    'lastUpdateTime': lastUpdateTime?.toIso8601String(),
    'driverName': driverName,
    'driverPhone': driverPhone,
    'driverImage': driverImage,
    'estimatedDeliveryTime': estimatedDeliveryTime,
    'deliveryAddress': deliveryAddress,
    'totalAmount': totalAmount,
    'currency': currency,
    'steps': steps.map((s) => s.toJson()).toList(),
    'metadata': metadata,
  };

  /// إنشاء من JSON
  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      orderId: json['orderId']?.toString() ?? '',
      orderReference: json['orderReference']?.toString() ?? '',
      status: OrderTrackingStatus.fromString(json['status']?.toString()),
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())
          : null,
      lastUpdateTime: json['lastUpdateTime'] != null
          ? DateTime.tryParse(json['lastUpdateTime'].toString())
          : null,
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      driverImage: json['driverImage']?.toString(),
      estimatedDeliveryTime: json['estimatedDeliveryTime']?.toString(),
      deliveryAddress: json['deliveryAddress']?.toString(),
      totalAmount: json['totalAmount'] != null
          ? double.tryParse(json['totalAmount'].toString())
          : null,
      currency: json['currency']?.toString(),
      steps: (json['steps'] as List?)
          ?.map((s) => OrderTrackingStep.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏭 Factory Constructors
  // ═══════════════════════════════════════════════════════════════════════

  /// إنشاء مع خطوات افتراضية
  factory OrderTrackingModel.withDefaultSteps({
    required String orderId,
    required String orderReference,
    required OrderTrackingStatus status,
    DateTime? startTime,
    String? driverName,
    String? driverPhone,
    String? driverImage,
    String? estimatedDeliveryTime,
    String? deliveryAddress,
    double? totalAmount,
    String? currency,
    Map<String, dynamic>? metadata,
  }) {
    return OrderTrackingModel(
      orderId: orderId,
      orderReference: orderReference,
      status: status,
      startTime: startTime ?? DateTime.now(),
      lastUpdateTime: DateTime.now(),
      driverName: driverName,
      driverPhone: driverPhone,
      driverImage: driverImage,
      estimatedDeliveryTime: estimatedDeliveryTime,
      deliveryAddress: deliveryAddress,
      totalAmount: totalAmount,
      currency: currency ?? 'SAR',
      steps: _buildDefaultSteps(status),
      metadata: metadata,
    );
  }

  /// إنشاء من بيانات الطلب
  factory OrderTrackingModel.fromOrderData({
    required String orderId,
    required String orderReference,
    required String shippingStatus,
    DateTime? orderDate,
    String? driverName,
    String? driverPhone,
    String? estimatedDeliveryTime,
    String? deliveryAddress,
    double? totalAmount,
    String? currency,
  }) {
    final status = OrderTrackingStatus.fromString(shippingStatus);

    return OrderTrackingModel.withDefaultSteps(
      orderId: orderId,
      orderReference: orderReference,
      status: status,
      startTime: orderDate,
      driverName: driverName,
      driverPhone: driverPhone,
      estimatedDeliveryTime: estimatedDeliveryTime,
      deliveryAddress: deliveryAddress,
      totalAmount: totalAmount,
      currency: currency,
    );
  }

  /// ✅ إنشاء من Firestore Real-time Event
  factory OrderTrackingModel.fromFirestoreEvent(Map<String, dynamic> data) {
    final status = OrderTrackingStatus.fromString(
      data['shipping_status']?.toString() ?? data['status']?.toString() ?? 'pending',
    );

    return OrderTrackingModel.withDefaultSteps(
      orderId: data['order_id']?.toString() ?? data['id']?.toString() ?? '',
      orderReference: data['order_reference']?.toString() ?? data['reference']?.toString() ?? '',
      status: status,
      startTime: data['order_date'] != null || data['created_at'] != null
          ? DateTime.tryParse(data['order_date']?.toString() ?? data['created_at']?.toString() ?? '')
          : null,
      driverName: data['driver_name']?.toString(),
      driverPhone: data['driver_phone']?.toString(),
      driverImage: data['driver_image']?.toString(),
      estimatedDeliveryTime: data['estimated_delivery_time']?.toString() ?? data['estimated_time']?.toString(),
      deliveryAddress: data['delivery_address']?.toString() ?? data['location']?.toString(),
      totalAmount: data['total_amount'] != null
          ? double.tryParse(data['total_amount'].toString())
          : null,
      currency: data['currency']?.toString() ?? 'SAR',
      metadata: {
        'updated_at': data['updated_at'],
        'driver_location': data['driver_location'],
        ...?data['metadata'],
      },
    );
  }

  /// بناء الخطوات الافتراضية
  static List<OrderTrackingStep> _buildDefaultSteps(
      OrderTrackingStatus currentStatus) {
    // الحالات الأساسية بالترتيب (4 خطوات للتوافق مع UI القديم)
    const statuses = [
      OrderTrackingStatus.pending,
      OrderTrackingStatus.preparing,
      OrderTrackingStatus.onTheWay,
      OrderTrackingStatus.delivered,
    ];

    return statuses.map((stepStatus) {
      return OrderTrackingStep.fromStatus(
        stepStatus,
        currentStatus: currentStatus,
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Copy With
  // ═══════════════════════════════════════════════════════════════════════

  /// نسخ مع تعديل
  OrderTrackingModel copyWith({
    String? orderId,
    String? orderReference,
    OrderTrackingStatus? status,
    DateTime? startTime,
    DateTime? lastUpdateTime,
    String? driverName,
    String? driverPhone,
    String? driverImage,
    String? estimatedDeliveryTime,
    String? deliveryAddress,
    double? totalAmount,
    String? currency,
    List<OrderTrackingStep>? steps,
    Map<String, dynamic>? metadata,
  }) {
    return OrderTrackingModel(
      orderId: orderId ?? this.orderId,
      orderReference: orderReference ?? this.orderReference,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverImage: driverImage ?? this.driverImage,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      steps: steps ?? this.steps,
      metadata: metadata ?? this.metadata,
    );
  }

  /// تحديث الحالة مع تحديث الخطوات
  OrderTrackingModel updateStatus(OrderTrackingStatus newStatus) {
    return copyWith(
      status: newStatus,
      lastUpdateTime: DateTime.now(),
      steps: _buildDefaultSteps(newStatus),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⚖️ Equality
  // ═══════════════════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderTrackingModel &&
        other.orderId == orderId &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(orderId, status);

  @override
  String toString() =>
      'OrderTrackingModel(orderId: $orderId, ref: $orderReference, status: ${status.name})';
}