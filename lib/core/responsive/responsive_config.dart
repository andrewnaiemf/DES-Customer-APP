import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📱 RESPONSIVE CONFIG - Device Configurations
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveConfig {
  // ───────────────────────────────────────────────────────────────────────
  // 📏 BREAKPOINTS - نقاط التحول بين الأحجام
  // ───────────────────────────────────────────────────────────────────────

  /// Mobile Small (iPhone SE, older Androids)
  static const double mobileSmall = 320;

  /// Mobile Medium (iPhone 8, standard Androids)
  static const double mobileMedium = 375;

  /// Mobile Large (iPhone 12/13/14, large Androids)
  static const double mobileLarge = 414;

  /// Mobile XLarge (iPhone Pro Max, Galaxy Ultra)
  static const double mobileXLarge = 428;

  /// Tablet Small (iPad Mini, small tablets)
  static const double tabletSmall = 600;

  /// Tablet Medium (iPad, standard tablets)
  static const double tabletMedium = 768;

  /// Tablet Large (iPad Pro 11")
  static const double tabletLarge = 834;

  /// Tablet XLarge (iPad Pro 12.9")
  static const double tabletXLarge = 1024;

  /// Desktop Small
  static const double desktopSmall = 1280;

  /// Desktop Medium
  static const double desktopMedium = 1440;

  /// Desktop Large
  static const double desktopLarge = 1920;

  // ───────────────────────────────────────────────────────────────────────
  // 📐 DESIGN REFERENCES - المقاسات المرجعية لكل نوع شاشة
  // ───────────────────────────────────────────────────────────────────────

  static const Map<DeviceType, DesignReference> designReferences = {
    DeviceType.mobileSmall: DesignReference(
      width: 320,
      height: 568,
      name: 'iPhone SE / Small Android',
    ),
    DeviceType.mobileMedium: DesignReference(
      width: 375,
      height: 667,
      name: 'iPhone 8 / Medium Android',
    ),
    DeviceType.mobileLarge: DesignReference(
      width: 393,
      height: 852,
      name: 'iPhone 14 Pro / Large Android',
    ),
    DeviceType.mobileXLarge: DesignReference(
      width: 430,
      height: 932,
      name: 'iPhone 14 Pro Max / XLarge Android',
    ),
    DeviceType.tabletSmall: DesignReference(
      width: 744,
      height: 1133,
      name: 'iPad Mini',
    ),
    DeviceType.tabletMedium: DesignReference(
      width: 820,
      height: 1180,
      name: 'iPad Air',
    ),
    DeviceType.tabletLarge: DesignReference(
      width: 834,
      height: 1194,
      name: 'iPad Pro 11"',
    ),
    DeviceType.tabletXLarge: DesignReference(
      width: 1024,
      height: 1366,
      name: 'iPad Pro 12.9"',
    ),
    DeviceType.desktop: DesignReference(
      width: 1440,
      height: 900,
      name: 'Desktop',
    ),
  };

  // ───────────────────────────────────────────────────────────────────────
  // 🎯 SCALE FACTORS - عوامل التحجيم لكل نوع
  // ───────────────────────────────────────────────────────────────────────

  static const Map<DeviceType, ScaleFactors> scaleFactors = {
    DeviceType.mobileSmall: ScaleFactors(
      font: ScaleRange(min: 0.85, max: 1.0),
      spacing: ScaleRange(min: 0.80, max: 1.0),
      icon: ScaleRange(min: 0.85, max: 1.0),
      widget: ScaleRange(min: 0.85, max: 1.0),
    ),
    DeviceType.mobileMedium: ScaleFactors(
      font: ScaleRange(min: 0.90, max: 1.05),
      spacing: ScaleRange(min: 0.88, max: 1.05),
      icon: ScaleRange(min: 0.90, max: 1.05),
      widget: ScaleRange(min: 0.90, max: 1.05),
    ),
    DeviceType.mobileLarge: ScaleFactors(
      font: ScaleRange(min: 0.95, max: 1.10),
      spacing: ScaleRange(min: 0.95, max: 1.10),
      icon: ScaleRange(min: 0.95, max: 1.10),
      widget: ScaleRange(min: 0.95, max: 1.10),
    ),
    DeviceType.mobileXLarge: ScaleFactors(
      font: ScaleRange(min: 1.0, max: 1.15),
      spacing: ScaleRange(min: 1.0, max: 1.15),
      icon: ScaleRange(min: 1.0, max: 1.15),
      widget: ScaleRange(min: 1.0, max: 1.15),
    ),
    DeviceType.tabletSmall: ScaleFactors(
      font: ScaleRange(min: 1.0, max: 1.20),
      spacing: ScaleRange(min: 1.10, max: 1.30),
      icon: ScaleRange(min: 1.05, max: 1.25),
      widget: ScaleRange(min: 1.10, max: 1.30),
    ),
    DeviceType.tabletMedium: ScaleFactors(
      font: ScaleRange(min: 1.05, max: 1.25),
      spacing: ScaleRange(min: 1.15, max: 1.40),
      icon: ScaleRange(min: 1.10, max: 1.30),
      widget: ScaleRange(min: 1.15, max: 1.40),
    ),
    DeviceType.tabletLarge: ScaleFactors(
      font: ScaleRange(min: 1.10, max: 1.30),
      spacing: ScaleRange(min: 1.20, max: 1.50),
      icon: ScaleRange(min: 1.15, max: 1.35),
      widget: ScaleRange(min: 1.20, max: 1.50),
    ),
    DeviceType.tabletXLarge: ScaleFactors(
      font: ScaleRange(min: 1.15, max: 1.35),
      spacing: ScaleRange(min: 1.25, max: 1.60),
      icon: ScaleRange(min: 1.20, max: 1.40),
      widget: ScaleRange(min: 1.25, max: 1.60),
    ),
    DeviceType.desktop: ScaleFactors(
      font: ScaleRange(min: 1.20, max: 1.50),
      spacing: ScaleRange(min: 1.30, max: 1.80),
      icon: ScaleRange(min: 1.25, max: 1.50),
      widget: ScaleRange(min: 1.30, max: 1.80),
    ),
  };

  // ───────────────────────────────────────────────────────────────────────
  // 📊 GRID COLUMNS - عدد الأعمدة لكل حجم
  // ───────────────────────────────────────────────────────────────────────

  static int getGridColumns(DeviceType type, Orientation orientation) {
    switch (type) {
      case DeviceType.mobileSmall:
      case DeviceType.mobileMedium:
        return orientation == Orientation.portrait ? 2 : 3;
      case DeviceType.mobileLarge:
      case DeviceType.mobileXLarge:
        return orientation == Orientation.portrait ? 2 : 4;
      case DeviceType.tabletSmall:
      case DeviceType.tabletMedium:
        return orientation == Orientation.portrait ? 3 : 4;
      case DeviceType.tabletLarge:
      case DeviceType.tabletXLarge:
        return orientation == Orientation.portrait ? 4 : 5;
      case DeviceType.desktop:
        return 6;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 DATA CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// نوع الجهاز
enum DeviceType {
  mobileSmall,
  mobileMedium,
  mobileLarge,
  mobileXLarge,
  tabletSmall,
  tabletMedium,
  tabletLarge,
  tabletXLarge,
  desktop,
}

/// المقاس المرجعي للتصميم
class DesignReference {
  final double width;
  final double height;
  final String name;

  const DesignReference({
    required this.width,
    required this.height,
    required this.name,
  });

  double get aspectRatio => width / height;
}

/// نطاق التحجيم
class ScaleRange {
  final double min;
  final double max;

  const ScaleRange({required this.min, required this.max});

  double clamp(double value) => value.clamp(min, max);
}

/// عوامل التحجيم لكل نوع
class ScaleFactors {
  final ScaleRange font;
  final ScaleRange spacing;
  final ScaleRange icon;
  final ScaleRange widget;

  const ScaleFactors({
    required this.font,
    required this.spacing,
    required this.icon,
    required this.widget,
  });
}