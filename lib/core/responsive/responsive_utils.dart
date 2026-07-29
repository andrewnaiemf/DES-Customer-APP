import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'responsive_config.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📱 RESPONSIVE UTILS - Advanced Multi-Device Scaling System
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveUtils {
  // ───────────────────────────────────────────────────────────────────────
  // 🔍 DEVICE DETECTION
  // ───────────────────────────────────────────────────────────────────────

  /// الحصول على نوع الجهاز
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final shortestSide = math.min(width, height);

    // استخدام أقصر ضلع للتحديد الصحيح (يعمل مع الـ rotation)
    if (shortestSide < ResponsiveConfig.mobileSmall + 30) {
      return DeviceType.mobileSmall;
    } else if (shortestSide < ResponsiveConfig.mobileMedium + 20) {
      return DeviceType.mobileMedium;
    } else if (shortestSide < ResponsiveConfig.mobileLarge) {
      return DeviceType.mobileLarge;
    } else if (shortestSide < ResponsiveConfig.tabletSmall) {
      return DeviceType.mobileXLarge;
    } else if (shortestSide < ResponsiveConfig.tabletMedium) {
      return DeviceType.tabletSmall;
    } else if (shortestSide < ResponsiveConfig.tabletLarge) {
      return DeviceType.tabletMedium;
    } else if (shortestSide < ResponsiveConfig.tabletXLarge) {
      return DeviceType.tabletLarge;
    } else if (shortestSide < ResponsiveConfig.desktopSmall) {
      return DeviceType.tabletXLarge;
    } else {
      return DeviceType.desktop;
    }
  }

  /// التحقق من نوع الجهاز
  static bool isMobile(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.mobileSmall ||
        type == DeviceType.mobileMedium ||
        type == DeviceType.mobileLarge ||
        type == DeviceType.mobileXLarge;
  }

  static bool isTablet(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.tabletSmall ||
        type == DeviceType.tabletMedium ||
        type == DeviceType.tabletLarge ||
        type == DeviceType.tabletXLarge;
  }

  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  static bool isSmallMobile(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.mobileSmall || type == DeviceType.mobileMedium;
  }

  static bool isLargeMobile(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.mobileLarge || type == DeviceType.mobileXLarge;
  }

  static bool isSmallTablet(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.tabletSmall || type == DeviceType.tabletMedium;
  }

  static bool isLargeTablet(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.tabletLarge || type == DeviceType.tabletXLarge;
  }

  // ───────────────────────────────────────────────────────────────────────
  // 📐 ORIENTATION & SCREEN INFO
  // ───────────────────────────────────────────────────────────────────────

  static Orientation orientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  static bool isPortrait(BuildContext context) {
    return orientation(context) == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return orientation(context) == Orientation.landscape;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double shortestSide(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide;
  }

  static double longestSide(BuildContext context) {
    return MediaQuery.of(context).size.longestSide;
  }

  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double safeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double safeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double pixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // ───────────────────────────────────────────────────────────────────────
  // 🎯 SCALE CALCULATIONS
  // ───────────────────────────────────────────────────────────────────────

  /// الحصول على المقاس المرجعي المناسب
  static DesignReference _getDesignReference(BuildContext context) {
    final deviceType = getDeviceType(context);
    return ResponsiveConfig.designReferences[deviceType] ??
        ResponsiveConfig.designReferences[DeviceType.mobileLarge]!;
  }

  /// الحصول على عوامل التحجيم
  static ScaleFactors _getScaleFactors(BuildContext context) {
    final deviceType = getDeviceType(context);
    return ResponsiveConfig.scaleFactors[deviceType] ??
        ResponsiveConfig.scaleFactors[DeviceType.mobileLarge]!;
  }

  /// حساب عامل التحجيم
  static double _calculateScaleFactor(
      BuildContext context, {
        required ScaleRange range,
        ScaleMode mode = ScaleMode.balanced,
      }) {
    final screenSize = MediaQuery.of(context).size;
    final reference = _getDesignReference(context);

    double rawScale;

    switch (mode) {
      case ScaleMode.width:
        rawScale = screenSize.width / reference.width;
        break;
      case ScaleMode.height:
        rawScale = screenSize.height / reference.height;
        break;
      case ScaleMode.balanced:
        final widthScale = screenSize.width / reference.width;
        final heightScale = screenSize.height / reference.height;
        rawScale = (widthScale + heightScale) / 2;
        break;
      case ScaleMode.min:
        rawScale = math.min(
          screenSize.width / reference.width,
          screenSize.height / reference.height,
        );
        break;
      case ScaleMode.max:
        rawScale = math.max(
          screenSize.width / reference.width,
          screenSize.height / reference.height,
        );
        break;
      case ScaleMode.diagonal:
        final refDiagonal = math.sqrt(
          reference.width * reference.width + reference.height * reference.height,
        );
        final screenDiagonal = math.sqrt(
          screenSize.width * screenSize.width + screenSize.height * screenSize.height,
        );
        rawScale = screenDiagonal / refDiagonal;
        break;
    }

    return range.clamp(rawScale);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📏 SCALING METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// دالة مساعدة لتقريب القيم
  /// تقرب القيمة إلى منزلتين عشريتين إذا كانت كسر، أو إلى أقرب عدد صحيح
  static double _roundValue(double value) {
    // إذا القيمة قريبة جداً من عدد صحيح (فرق أقل من 0.01)
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.01) {
      return rounded;
    }
    
    // وإلا قرب إلى منزلتين عشريتين
    return (value * 100).roundToDouble() / 100;
  }

  /// تحجيم العرض
  static double width(BuildContext context, double value) {
    final factors = _getScaleFactors(context);
    final scale = _calculateScaleFactor(
      context,
      range: factors.widget,
      mode: ScaleMode.width,
    );
    return _roundValue(value * scale);
  }

  /// تحجيم الارتفاع
  static double height(BuildContext context, double value) {
    final factors = _getScaleFactors(context);
    final scale = _calculateScaleFactor(
      context,
      range: factors.widget,
      mode: ScaleMode.height,
    );
    return _roundValue(value * scale);
  }

  /// تحجيم النص
  static double font(BuildContext context, double fontSize) {
    final factors = _getScaleFactors(context);
    final scale = _calculateScaleFactor(
      context,
      range: factors.font,
      mode: ScaleMode.balanced,
    );

    // تعديل إضافي للتابلت والآيباد
    if (isTablet(context)) {
      // زيادة طفيفة في حجم الخط للتابلت
      return _roundValue(fontSize * scale * 1.05);
    }

    return _roundValue(fontSize * scale);
  }

  /// تحجيم المسافات (padding, margin)
  static double spacing(BuildContext context, double value) {
    final factors = _getScaleFactors(context);
    final scale = _calculateScaleFactor(
      context,
      range: factors.spacing,
      mode: ScaleMode.min,
    );
    return _roundValue(value * scale);
  }

  /// تحجيم الأيقونات
  static double icon(BuildContext context, double size) {
    final factors = _getScaleFactors(context);
    final scale = _calculateScaleFactor(
      context,
      range: factors.icon,
      mode: ScaleMode.min,
    );
    return _roundValue(size * scale);
  }

  /// تحجيم الـ radius
  static double radius(BuildContext context, double value) {
    final factors = _getScaleFactors(context);
    final scale = _calculateScaleFactor(
      context,
      range: ScaleRange(
        min: factors.widget.min * 0.95,
        max: factors.widget.max * 1.05,
      ),
      mode: ScaleMode.min,
    );
    return _roundValue(value * scale);
  }

  /// تحجيم حجم الزر
  static double buttonHeight(BuildContext context, double height) {
    final factors = _getScaleFactors(context);
    final scale = _calculateScaleFactor(
      context,
      range: factors.widget,
      mode: ScaleMode.height,
    );

    // ضمان حد أدنى لارتفاع الزر
    final scaledHeight = height * scale;
    return _roundValue(math.max(scaledHeight, 44)); // minimum touch target
  }

  /// تحجيم عام (للأبعاد المربعة)
  static double size(BuildContext context, double value) {
    final factors = _getScaleFactors(context);
    final scale = _calculateScaleFactor(
      context,
      range: factors.widget,
      mode: ScaleMode.min,
    );
    return _roundValue(value * scale);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 EDGE INSETS HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// EdgeInsets.all responsive
  static EdgeInsets paddingAll(BuildContext context, double value) {
    return EdgeInsets.all(spacing(context, value));
  }

  /// EdgeInsets.symmetric responsive
  static EdgeInsets paddingSymmetric(
      BuildContext context, {
        double horizontal = 0,
        double vertical = 0,
      }) {
    return EdgeInsets.symmetric(
      horizontal: spacing(context, horizontal),
      vertical: spacing(context, vertical),
    );
  }

  /// EdgeInsets.only responsive
  static EdgeInsets paddingOnly(
      BuildContext context, {
        double left = 0,
        double right = 0,
        double top = 0,
        double bottom = 0,
      }) {
    return EdgeInsets.only(
      left: spacing(context, left),
      right: spacing(context, right),
      top: spacing(context, top),
      bottom: spacing(context, bottom),
    );
  }

  /// Padding للصفحات
  static EdgeInsets pagePadding(BuildContext context) {
    if (isTablet(context)) {
      return paddingSymmetric(context, horizontal: 32, vertical: 24);
    } else if (isDesktop(context)) {
      return paddingSymmetric(context, horizontal: 48, vertical: 32);
    }
    return paddingSymmetric(context, horizontal: 20, vertical: 16);
  }

  /// Padding للكروت
  static EdgeInsets cardPadding(BuildContext context) {
    if (isTablet(context)) {
      return paddingAll(context, 20);
    } else if (isDesktop(context)) {
      return paddingAll(context, 24);
    }
    return paddingAll(context, 16);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔲 BORDER RADIUS HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  static BorderRadius borderRadius(BuildContext context, double value) {
    return BorderRadius.circular(radius(context, value));
  }

  static BorderRadius borderRadiusOnly(
      BuildContext context, {
        double topLeft = 0,
        double topRight = 0,
        double bottomLeft = 0,
        double bottomRight = 0,
      }) {
    return BorderRadius.only(
      topLeft: Radius.circular(radius(context, topLeft)),
      topRight: Radius.circular(radius(context, topRight)),
      bottomLeft: Radius.circular(radius(context, bottomLeft)),
      bottomRight: Radius.circular(radius(context, bottomRight)),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 GRID HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// عدد الأعمدة المناسب
  static int gridColumns(BuildContext context) {
    final type = getDeviceType(context);
    final orient = orientation(context);
    return ResponsiveConfig.getGridColumns(type, orient);
  }

  /// العرض المتاح لكل عنصر في الـ grid
  static double gridItemWidth(
      BuildContext context, {
        double spacing = 16,
        double horizontalPadding = 20,
      }) {
    final columns = gridColumns(context);
    final totalSpacing = ResponsiveUtils.spacing(context, spacing) * (columns - 1);
    final totalPadding = ResponsiveUtils.spacing(context, horizontalPadding) * 2;
    final availableWidth = screenWidth(context) - totalSpacing - totalPadding;
    return availableWidth / columns;
  }

  /// نسبة العرض إلى الارتفاع للعناصر
  static double gridAspectRatio(BuildContext context, {double baseRatio = 1.0}) {
    if (isTablet(context) || isDesktop(context)) {
      // للتابلت نستخدم نسبة أعرض
      return baseRatio * 1.1;
    }
    return baseRatio;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 RESPONSIVE VALUE SELECTOR
  // ═══════════════════════════════════════════════════════════════════════════

  /// اختيار قيمة بناءً على حجم الشاشة
  static T value<T>(
      BuildContext context, {
        required T mobile,
        T? mobileLarge,
        T? tablet,
        T? tabletLarge,
        T? desktop,
      }) {
    final type = getDeviceType(context);

    switch (type) {
      case DeviceType.mobileSmall:
      case DeviceType.mobileMedium:
        return mobile;
      case DeviceType.mobileLarge:
      case DeviceType.mobileXLarge:
        return mobileLarge ?? mobile;
      case DeviceType.tabletSmall:
      case DeviceType.tabletMedium:
        return tablet ?? mobileLarge ?? mobile;
      case DeviceType.tabletLarge:
      case DeviceType.tabletXLarge:
        return tabletLarge ?? tablet ?? mobileLarge ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tabletLarge ?? tablet ?? mobileLarge ?? mobile;
    }
  }

  /// اختيار قيمة مع الـ orientation
  static T valueWithOrientation<T>(
      BuildContext context, {
        required T mobilePortrait,
        T? mobileLandscape,
        T? tabletPortrait,
        T? tabletLandscape,
        T? desktop,
      }) {
    final isLand = isLandscape(context);

    if (isDesktop(context)) {
      return desktop ?? tabletLandscape ?? tabletPortrait ?? mobilePortrait;
    }

    if (isTablet(context)) {
      if (isLand) {
        return tabletLandscape ?? tabletPortrait ?? mobilePortrait;
      }
      return tabletPortrait ?? mobilePortrait;
    }

    if (isLand) {
      return mobileLandscape ?? mobilePortrait;
    }
    return mobilePortrait;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 MAX WIDTH CONSTRAINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحد الأقصى لعرض المحتوى
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isLargeTablet(context)) return 900;
    if (isSmallTablet(context)) return 700;
    return double.infinity;
  }

  /// الحد الأقصى لعرض الـ dialog
  static double maxDialogWidth(BuildContext context) {
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 500;
    return screenWidth(context) * 0.9;
  }

  /// الحد الأقصى لعرض الـ card
  static double maxCardWidth(BuildContext context) {
    if (isDesktop(context)) return 400;
    if (isTablet(context)) return 350;
    return double.infinity;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 SCALE MODE ENUM
// ═══════════════════════════════════════════════════════════════════════════

enum ScaleMode {
  width,
  height,
  balanced,
  min,
  max,
  diagonal,
}

// ═══════════════════════════════════════════════════════════════════════════
// 📐 EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

extension ResponsiveDouble on num {
  /// Width: 100.w(context)
  double w(BuildContext context) => ResponsiveUtils.width(context, toDouble());

  /// Height: 100.h(context)
  double h(BuildContext context) => ResponsiveUtils.height(context, toDouble());

  /// Font: 16.sp(context)
  double sp(BuildContext context) => ResponsiveUtils.font(context, toDouble());

  /// Spacing: 20.s(context)
  double s(BuildContext context) => ResponsiveUtils.spacing(context, toDouble());

  /// Icon: 24.ic(context)
  double ic(BuildContext context) => ResponsiveUtils.icon(context, toDouble());

  /// Radius: 12.r(context)
  double r(BuildContext context) => ResponsiveUtils.radius(context, toDouble());

  /// Size (square): 50.sz(context)
  double sz(BuildContext context) => ResponsiveUtils.size(context, toDouble());
}

extension ResponsiveContext on BuildContext {
  /// Get device type
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);

  /// Check device type
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isSmallMobile => ResponsiveUtils.isSmallMobile(this);
  bool get isLargeMobile => ResponsiveUtils.isLargeMobile(this);
  bool get isSmallTablet => ResponsiveUtils.isSmallTablet(this);
  bool get isLargeTablet => ResponsiveUtils.isLargeTablet(this);

  /// Orientation
  bool get isPortrait => ResponsiveUtils.isPortrait(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);

  /// Screen dimensions
  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);

  /// Grid
  int get gridColumns => ResponsiveUtils.gridColumns(this);
}