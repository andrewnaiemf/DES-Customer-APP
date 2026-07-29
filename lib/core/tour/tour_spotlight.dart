import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'tour_step_model.dart';

/// رسم التسليط على العنصر المستهدف
class TourSpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double padding;
  final SpotlightShape shape;
  final double borderRadius;
  final Color overlayColor;
  final double animationValue;
  final Color? pulseColor;

  TourSpotlightPainter({
    required this.targetRect,
    this.padding = 8.0,
    this.shape = SpotlightShape.roundedRectangle,
    this.borderRadius = 16.0,
    this.overlayColor = const Color(0xE6000000),
    this.animationValue = 1.0,
    this.pulseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // إنشاء المسار الكامل للشاشة
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // إنشاء المسار للعنصر المستهدف مع الـ padding
    final expandedRect = targetRect.inflate(padding);
    
    Path spotlightPath;
    
    switch (shape) {
      case SpotlightShape.circle:
        final radius = (expandedRect.width > expandedRect.height
                ? expandedRect.width
                : expandedRect.height) /
            2;
        spotlightPath = Path()
          ..addOval(Rect.fromCenter(
            center: expandedRect.center,
            width: radius * 2 * animationValue,
            height: radius * 2 * animationValue,
          ));
        break;
        
      case SpotlightShape.roundedRectangle:
        spotlightPath = Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: expandedRect.center,
              width: expandedRect.width * animationValue,
              height: expandedRect.height * animationValue,
            ),
            Radius.circular(borderRadius),
          ));
        break;
        
      case SpotlightShape.rectangle:
        spotlightPath = Path()
          ..addRect(Rect.fromCenter(
            center: expandedRect.center,
            width: expandedRect.width * animationValue,
            height: expandedRect.height * animationValue,
          ));
        break;
    }

    // قص المسار المستهدف من المسار الكامل
    final combinedPath = Path.combine(
      PathOperation.difference,
      fullPath,
      spotlightPath,
    );

    // رسم الـ Overlay
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(combinedPath, paint);

    // رسم حدود متوهجة (Pulse Effect)
    if (pulseColor != null) {
      final borderPaint = Paint()
        ..color = pulseColor!.withOpacity(0.5 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawPath(spotlightPath, borderPaint);

      // Outer glow
      final glowPaint = Paint()
        ..color = pulseColor!.withOpacity(0.2 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawPath(spotlightPath, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TourSpotlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        animationValue != oldDelegate.animationValue ||
        padding != oldDelegate.padding ||
        shape != oldDelegate.shape;
  }
}

/// Widget لعرض التسليط
class TourSpotlight extends StatelessWidget {
  final Rect targetRect;
  final TourStep step;
  final double animationValue;
  final bool isDark;

  const TourSpotlight({
    super.key,
    required this.targetRect,
    required this.step,
    required this.animationValue,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: TourSpotlightPainter(
        targetRect: targetRect,
        padding: step.spotlightPadding,
        shape: step.spotlightShape,
        overlayColor: isDark
            ? const Color(0xE6000000)
            : const Color(0xCC000000),
        animationValue: animationValue,
        pulseColor: step.accentColor ?? const Color(0xFF6366F1),
      ),
    );
  }
}
