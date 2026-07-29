import 'package:flutter/material.dart';

/// شكل التسليط على العنصر
enum SpotlightShape {
  circle,
  roundedRectangle,
  rectangle,
}

/// موقع الـ Tooltip
enum TooltipPosition {
  top,
  bottom,
  left,
  right,
  auto,
}

/// نموذج خطوة الجولة الإرشادية
class TourStep {
  /// معرف فريد للخطوة
  final String id;

  /// المفتاح العام للعنصر المستهدف
  final GlobalKey targetKey;

  /// عنوان الخطوة
  final String title;

  /// وصف تفصيلي للخطوة
  final String description;

  /// أيقونة اختيارية
  final IconData? icon;

  /// لون مميز للخطوة
  final Color? accentColor;

  /// شكل التسليط
  final SpotlightShape spotlightShape;

  /// موقع الـ Tooltip
  final TooltipPosition tooltipPosition;

  /// Padding حول العنصر المسلط عليه
  final double spotlightPadding;

  /// هل يمكن النقر على العنصر أثناء الشرح
  final bool allowTargetTap;

  /// Widget مخصص للمحتوى (اختياري)
  final Widget? customContent;

  /// Callback عند عرض هذه الخطوة
  final VoidCallback? onShow;

  /// Callback عند إخفاء هذه الخطوة
  final VoidCallback? onHide;

  /// مدة العرض (للتقدم التلقائي - اختياري)
  final Duration? autoAdvanceDuration;

  const TourStep({
    required this.id,
    required this.targetKey,
    required this.title,
    required this.description,
    this.icon,
    this.accentColor,
    this.spotlightShape = SpotlightShape.roundedRectangle,
    this.tooltipPosition = TooltipPosition.auto,
    this.spotlightPadding = 8.0,
    this.allowTargetTap = false,
    this.customContent,
    this.onShow,
    this.onHide,
    this.autoAdvanceDuration,
  });

  TourStep copyWith({
    String? id,
    GlobalKey? targetKey,
    String? title,
    String? description,
    IconData? icon,
    Color? accentColor,
    SpotlightShape? spotlightShape,
    TooltipPosition? tooltipPosition,
    double? spotlightPadding,
    bool? allowTargetTap,
    Widget? customContent,
    VoidCallback? onShow,
    VoidCallback? onHide,
    Duration? autoAdvanceDuration,
  }) {
    return TourStep(
      id: id ?? this.id,
      targetKey: targetKey ?? this.targetKey,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      spotlightShape: spotlightShape ?? this.spotlightShape,
      tooltipPosition: tooltipPosition ?? this.tooltipPosition,
      spotlightPadding: spotlightPadding ?? this.spotlightPadding,
      allowTargetTap: allowTargetTap ?? this.allowTargetTap,
      customContent: customContent ?? this.customContent,
      onShow: onShow ?? this.onShow,
      onHide: onHide ?? this.onHide,
      autoAdvanceDuration: autoAdvanceDuration ?? this.autoAdvanceDuration,
    );
  }
}

/// مجموعة خطوات لشاشة معينة
class ScreenTour {
  final String screenId;
  final String screenName;
  final List<TourStep> steps;
  final bool showOnFirstVisit;

  const ScreenTour({
    required this.screenId,
    required this.screenName,
    required this.steps,
    this.showOnFirstVisit = true,
  });
}
