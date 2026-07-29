import 'package:flutter/material.dart';
import 'responsive_utils.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📐 APP DIMENSIONS - Unified Sizing System
// ═══════════════════════════════════════════════════════════════════════════

class AppDimensions {
  // ═══════════════════════════════════════════════════════════════════════════
  // 📏 SPACING SYSTEM
  // ═══════════════════════════════════════════════════════════════════════════

  /// 2px
  static double xxs(BuildContext context) => ResponsiveUtils.spacing(context, 2);

  /// 4px
  static double xs(BuildContext context) => ResponsiveUtils.spacing(context, 4);

  /// 8px
  static double sm(BuildContext context) => ResponsiveUtils.spacing(context, 8);

  /// 12px
  static double md(BuildContext context) => ResponsiveUtils.spacing(context, 12);

  /// 16px
  static double lg(BuildContext context) => ResponsiveUtils.spacing(context, 16);

  /// 20px
  static double xl(BuildContext context) => ResponsiveUtils.spacing(context, 20);

  /// 24px
  static double xxl(BuildContext context) => ResponsiveUtils.spacing(context, 24);

  /// 32px
  static double xxxl(BuildContext context) => ResponsiveUtils.spacing(context, 32);

  /// 40px
  static double xxxxl(BuildContext context) => ResponsiveUtils.spacing(context, 40);

  /// 48px
  static double xxxxxl(BuildContext context) => ResponsiveUtils.spacing(context, 48);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════════════════

  /// 4px
  static double radiusXS(BuildContext context) => ResponsiveUtils.radius(context, 4);

  /// 8px
  static double radiusSM(BuildContext context) => ResponsiveUtils.radius(context, 8);

  /// 12px
  static double radiusMD(BuildContext context) => ResponsiveUtils.radius(context, 12);

  /// 16px
  static double radiusLG(BuildContext context) => ResponsiveUtils.radius(context, 16);

  /// 20px
  static double radiusXL(BuildContext context) => ResponsiveUtils.radius(context, 20);

  /// 24px
  static double radiusXXL(BuildContext context) => ResponsiveUtils.radius(context, 24);

  /// 28px
  static double radiusXXXL(BuildContext context) => ResponsiveUtils.radius(context, 28);

  /// 32px
  static double radiusFull(BuildContext context) => ResponsiveUtils.radius(context, 32);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔘 BUTTON HEIGHTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// 32px
  static double buttonXS(BuildContext context) => ResponsiveUtils.buttonHeight(context, 32);

  /// 40px
  static double buttonSM(BuildContext context) => ResponsiveUtils.buttonHeight(context, 40);

  /// 48px
  static double buttonMD(BuildContext context) => ResponsiveUtils.buttonHeight(context, 48);

  /// 56px
  static double buttonLG(BuildContext context) => ResponsiveUtils.buttonHeight(context, 56);

  /// 64px
  static double buttonXL(BuildContext context) => ResponsiveUtils.buttonHeight(context, 64);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 ICON SIZES
  // ═══════════════════════════════════════════════════════════════════════════

  /// 12px
  static double iconXXS(BuildContext context) => ResponsiveUtils.icon(context, 12);

  /// 16px
  static double iconXS(BuildContext context) => ResponsiveUtils.icon(context, 16);

  /// 20px
  static double iconSM(BuildContext context) => ResponsiveUtils.icon(context, 20);

  /// 24px
  static double iconMD(BuildContext context) => ResponsiveUtils.icon(context, 24);

  /// 28px
  static double iconLG(BuildContext context) => ResponsiveUtils.icon(context, 28);

  /// 32px
  static double iconXL(BuildContext context) => ResponsiveUtils.icon(context, 32);

  /// 40px
  static double iconXXL(BuildContext context) => ResponsiveUtils.icon(context, 40);

  /// 48px
  static double iconXXXL(BuildContext context) => ResponsiveUtils.icon(context, 48);

  /// 64px
  static double iconHuge(BuildContext context) => ResponsiveUtils.icon(context, 64);

  // ═══════════════════════════════════════════════════════════════════════════
  // 👤 AVATAR SIZES
  // ═══════════════════════════════════════════════════════════════════════════

  /// 24px
  static double avatarXS(BuildContext context) => ResponsiveUtils.size(context, 24);

  /// 32px
  static double avatarSM(BuildContext context) => ResponsiveUtils.size(context, 32);

  /// 40px
  static double avatarMD(BuildContext context) => ResponsiveUtils.size(context, 40);

  /// 48px
  static double avatarLG(BuildContext context) => ResponsiveUtils.size(context, 48);

  /// 64px
  static double avatarXL(BuildContext context) => ResponsiveUtils.size(context, 64);

  /// 80px
  static double avatarXXL(BuildContext context) => ResponsiveUtils.size(context, 80);

  /// 100px
  static double avatarHuge(BuildContext context) => ResponsiveUtils.size(context, 100);

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 APP BAR & NAV
  // ═══════════════════════════════════════════════════════════════════════════

  /// App bar height
  static double appBarHeight(BuildContext context) {
    return ResponsiveUtils.value(
      context,
      mobile: ResponsiveUtils.height(context, 56),
      tablet: ResponsiveUtils.height(context, 64),
      desktop: ResponsiveUtils.height(context, 72),
    );
  }

  /// Bottom nav height
  static double bottomNavHeight(BuildContext context) {
    return ResponsiveUtils.value(
      context,
      mobile: ResponsiveUtils.height(context, 60),
      tablet: ResponsiveUtils.height(context, 72),
      desktop: ResponsiveUtils.height(context, 80),
    );
  }

  /// Drawer width
  static double drawerWidth(BuildContext context) {
    return ResponsiveUtils.value(
      context,
      mobile: ResponsiveUtils.screenWidth(context) * 0.75,
      tablet: 320.0,
      desktop: 280.0,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 INPUT FIELDS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Input height
  static double inputHeight(BuildContext context) => ResponsiveUtils.buttonHeight(context, 48);

  /// Input height large
  static double inputHeightLG(BuildContext context) => ResponsiveUtils.buttonHeight(context, 56);

  /// Text area min height
  static double textAreaMinHeight(BuildContext context) => ResponsiveUtils.height(context, 120);

  // ═══════════════════════════════════════════════════════════════════════════
  // 📋 CARD & DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

  /// Card min height
  static double cardMinHeight(BuildContext context) => ResponsiveUtils.height(context, 120);

  /// Dialog max width
  static double dialogMaxWidth(BuildContext context) => ResponsiveUtils.maxDialogWidth(context);

  /// Bottom sheet border radius
  static double bottomSheetRadius(BuildContext context) => ResponsiveUtils.radius(context, 24);
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔤 APP TYPOGRAPHY - Font Sizes
// ═══════════════════════════════════════════════════════════════════════════

class AppTypography {
  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 DISPLAY (Large Headers)
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle displayLarge(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 36),
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.2,
  );

  static TextStyle displayMedium(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 30),
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.2,
  );

  static TextStyle displaySmall(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 26),
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.3,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 📰 HEADLINE
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle headlineLarge(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 24),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle headlineMedium(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 22),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle headlineSmall(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 20),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 TITLE
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle titleLarge(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 18),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );

  static TextStyle titleMedium(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 16),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );

  static TextStyle titleSmall(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 15),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 📄 BODY
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle bodyLarge(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 16),
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.5,
  );

  static TextStyle bodyMedium(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 14),
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.5,
  );

  static TextStyle bodySmall(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 13),
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.5,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏷️ LABEL
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle labelLarge(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 14),
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.4,
  );

  static TextStyle labelMedium(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 12),
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.4,
  );

  static TextStyle labelSmall(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 11),
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 CAPTION & OVERLINE
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle caption(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 12),
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.4,
  );

  static TextStyle overline(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 10),
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.4,
    letterSpacing: 1,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔘 BUTTON
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle buttonLarge(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 16),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.2,
  );

  static TextStyle buttonMedium(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 15),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.2,
  );

  static TextStyle buttonSmall(BuildContext context, {Color? color}) => TextStyle(
    fontSize: ResponsiveUtils.font(context, 14),
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.2,
  );
}