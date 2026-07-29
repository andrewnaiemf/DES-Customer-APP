import 'package:flutter/material.dart';
import 'dart:ui' as ui;

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme - Premium Design System v2.0
// ═══════════════════════════════════════════════════════════════════════════
// Complete Brand Identity with Light/Dark Mode Support
// Premium UI Components, Glassmorphism & Professional Styling
// ═══════════════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Primary Brand Colors
  // ═══════════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF6842E2);
  static const Color primaryLight = Color(0xFF8B6CEF);
  static const Color primaryDark = Color(0xFF5234B5);
  static const Color primarySoft = Color(0xFFEDE7FB);

  // Legacy alias
  static const Color purple = primary;
  static const Color purpleLight = primaryLight;

  // ═══════════════════════════════════════════════════════════════════════
  // 🌈 Secondary & Accent Colors
  // ═══════════════════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFF00C88D);
  static const Color secondaryLight = Color(0xFF28E6C5);
  static const Color secondaryDark = Color(0xFF00A875);
  static const Color secondarySoft = Color(0xFFE6F9F3);

  static const Color accent = Color(0xFFFBBF4D);
  static const Color accentLight = Color(0xFFFFD07A);
  static const Color accentDark = Color(0xFFE5A835);
  static const Color accentSoft = Color(0xFFFFF8E7);

  // Legacy aliases
  static const Color green = secondary;
  static const Color lightGreen = secondaryLight;
  static const Color yellow = accent;

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Extended UI Colors
  // ═══════════════════════════════════════════════════════════════════════
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFF60A5FA);
  static const Color blueDark = Color(0xFF2563EB);
  static const Color blueSoft = Color(0xFFEBF3FF);

  static const Color orange = Color(0xFFFF9F43);
  static const Color orangeLight = Color(0xFFFFB86C);
  static const Color orangeDark = Color(0xFFE8892E);
  static const Color orangeSoft = Color(0xFFFFF4E8);

  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFF87171);
  static const Color redDark = Color(0xFFDC2626);
  static const Color redSoft = Color(0xFFFEE8E8);

  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFF472B6);
  static const Color pinkDark = Color(0xFFDB2777);
  static const Color pinkSoft = Color(0xFFFCE7F3);

  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFF2DD4BF);
  static const Color tealDark = Color(0xFF0D9488);
  static const Color tealSoft = Color(0xFFE6FAF8);

  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoLight = Color(0xFF818CF8);
  static const Color indigoDark = Color(0xFF4F46E5);
  static const Color indigoSoft = Color(0xFFEEEFFC);

  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFF22D3EE);
  static const Color cyanDark = Color(0xFF0891B2);
  static const Color cyanSoft = Color(0xFFE5F8FB);

  // ═══════════════════════════════════════════════════════════════════════
  // ✅ Status Colors
  // ═══════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSoft = Color(0xFFE7F8F2);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF6E7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEE8E8);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFEBF3FF);

  // ═══════════════════════════════════════════════════════════════════════
  // 🌙 Dark Theme Colors
  // ═══════════════════════════════════════════════════════════════════════
  static const Color dark = Color(0xFF081428);
  static const Color darkBackground = Color(0xFF0A0A12);
  static const Color darkCard = Color(0xFF14141F);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkBorder = Color(0xFF2A2A3E);
  static const Color darkDivider = Color(0xFF353550);
  static const Color darkInput = Color(0xFF1E1E2D);
  static const Color darkElevated = Color(0xFF1F1F32);

  // Legacy aliases
  static const Color background = darkBackground;
  static const Color cardDark = darkCard;
  static const Color surfaceDark = darkSurface;
  static const Color borderDark = darkBorder;

  // ═══════════════════════════════════════════════════════════════════════
  // ☀️ Light Theme Colors
  // ═══════════════════════════════════════════════════════════════════════
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFBFC);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFD1D5DB);
  static const Color lightInput = Color(0xFFF3F4F6);
  static const Color lightText = Color(0xFF1D1D25);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightElevated = Color(0xFFF8F9FC);

  // Legacy aliases
  static const Color black = lightText;
  static const Color omnia = Color(0xFFE5E5F5);
  static const Color lightGray = lightSurface;
  static const Color darkGray = Color(0xFFC6CBE0);

  // ═══════════════════════════════════════════════════════════════════════
  // 🔢 Opacity Values
  // ═══════════════════════════════════════════════════════════════════════
  static const double opacityHigh = 0.87;
  static const double opacityMedium = 0.60;
  static const double opacityLow = 0.38;
  static const double opacityDisabled = 0.12;

  // ═══════════════════════════════════════════════════════════════════════
  // 🎭 Theme-Aware Color Getters
  // ═══════════════════════════════════════════════════════════════════════

  /// Get background color based on theme
  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  /// Get card background color
  static Color getCard(bool isDark) => isDark ? darkCard : lightCard;

  /// Get card background with opacity for glass effect
  static Color getCardGlass(bool isDark) =>
      isDark ? darkCard.withOpacity(0.95) : white.withOpacity(0.98);

  /// Get surface color (slightly different from card)
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;

  /// Get elevated surface color
  static Color getElevated(bool isDark) =>
      isDark ? darkElevated : lightElevated;

  /// Get primary text color
  static Color getText(bool isDark) => isDark ? white : lightText;

  /// Get secondary text color
  static Color getTextSecondary(bool isDark) =>
      isDark ? white.withOpacity(0.6) : lightTextSecondary;

  /// Get tertiary/hint text color
  static Color getTextTertiary(bool isDark) =>
      isDark ? white.withOpacity(0.4) : lightTextSecondary.withOpacity(0.7);

  /// Get disabled text color
  static Color getTextDisabled(bool isDark) =>
      isDark ? white.withOpacity(0.3) : lightTextSecondary.withOpacity(0.5);

  /// Get border color
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;

  /// Get soft border color for focus states
  static Color getBorderSoft(bool isDark, Color accentColor) =>
      accentColor.withOpacity(isDark ? 0.3 : 0.25);

  /// Get divider color
  static Color getDivider(bool isDark) => isDark ? darkDivider : lightDivider;

  /// Get input field background
  static Color getInputFill(bool isDark) => isDark ? darkInput : lightInput;

  /// Get input field fill with transparency
  static Color getInputFillGlass(bool isDark) =>
      isDark ? darkCard.withOpacity(0.8) : white;

  /// Get shimmer base color
  static Color getShimmerBase(bool isDark) => isDark ? darkSurface : lightBorder;

  /// Get shimmer highlight color
  static Color getShimmerHighlight(bool isDark) =>
      isDark ? darkBorder : lightSurface;

  /// Get overlay color (for modals, dialogs)
  static Color getOverlay(bool isDark) =>
      isDark ? Colors.black54 : Colors.black38;

  /// Get icon color
  static Color getIconColor(bool isDark) =>
      isDark ? white.withOpacity(0.8) : lightTextSecondary;

  /// Get active icon color
  static Color getIconActive(bool isDark) => primary;

  /// Get soft color for a given main color
  static Color getSoftColor(Color color, bool isDark) =>
      isDark ? color.withOpacity(0.15) : color.withOpacity(0.1);

  // ═══════════════════════════════════════════════════════════════════════
  // 🌈 Gradient Presets
  // ═══════════════════════════════════════════════════════════════════════

  /// Primary brand gradient
  static LinearGradient primaryGradient({bool reversed = false}) =>
      LinearGradient(
        begin: reversed ? Alignment.bottomRight : Alignment.topLeft,
        end: reversed ? Alignment.topLeft : Alignment.bottomRight,
        colors: const [primary, primaryLight],
      );

  /// Purple gradient (alias for primary)
  static LinearGradient purpleGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleLight],
  );

  /// Secondary/Success gradient
  static LinearGradient secondaryGradient({bool reversed = false}) =>
      LinearGradient(
        begin: reversed ? Alignment.bottomRight : Alignment.topLeft,
        end: reversed ? Alignment.topLeft : Alignment.bottomRight,
        colors: const [secondary, secondaryLight],
      );

  /// Success gradient (alias)
  static LinearGradient successGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successLight],
  );

  /// Warning/Gold gradient
  static LinearGradient warningGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, warningLight],
  );

  /// Yellow/Accent gradient (alias for warning)
  static LinearGradient yellowGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  /// Green/Secondary gradient (alias for secondary)
  static LinearGradient greenGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, lightGreen],
  );

  /// Gold gradient (alias)
  static LinearGradient goldGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  /// Error/Danger gradient
  static LinearGradient errorGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, errorLight],
  );

  /// Info/Blue gradient
  static LinearGradient infoGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [info, infoLight],
  );

  /// Blue gradient (alias for info)
  static LinearGradient blueGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, blueLight],
  );

  /// Orange gradient
  static LinearGradient orangeGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeLight],
  );

  /// Cyan gradient
  static LinearGradient cyanGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, cyanLight],
  );

  /// Pink gradient
  static LinearGradient pinkGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pink, pinkLight],
  );

  /// Teal gradient
  static LinearGradient tealGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, tealLight],
  );

  /// Dark gradient
  static LinearGradient darkGradient() => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [dark, dark.withOpacity(0.85)],
  );

  /// Glass effect gradient
  static LinearGradient glassGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [white.withOpacity(0.1), white.withOpacity(0.05)]
        : [white.withOpacity(0.8), white.withOpacity(0.6)],
  );

  /// Subtle background gradient
  static LinearGradient backgroundGradient(bool isDark) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark
        ? const [Color(0xFF1A1040), Color(0xFF0D0D1A), Color(0xFF0A0A12)]
        : const [Color(0xFFF8F9FC), Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
  );

  /// Card highlight gradient
  static LinearGradient cardHighlightGradient(Color color, bool isDark) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(isDark ? 0.15 : 0.1),
          color.withOpacity(isDark ? 0.08 : 0.05),
        ],
      );

  /// Header gradient for sections
  static LinearGradient headerGradient(Color color, bool isDark) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(isDark ? 0.15 : 0.1),
          color.withOpacity(isDark ? 0.05 : 0.03),
        ],
      );

  /// Icon container gradient
  static LinearGradient iconGradient(Color color, bool isDark) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(isDark ? 0.2 : 0.15),
          color.withOpacity(isDark ? 0.1 : 0.08),
        ],
      );

  /// Badge gradient for status indicators
  static LinearGradient badgeGradient(Color color, bool isDark,
      {bool isActive = false}) =>
      LinearGradient(
        colors: isActive
            ? [
          color.withOpacity(isDark ? 0.2 : 0.15),
          color.withOpacity(isDark ? 0.1 : 0.08),
        ]
            : [
          color.withOpacity(isDark ? 0.15 : 0.1),
          color.withOpacity(isDark ? 0.08 : 0.05),
        ],
      );

  /// Shimmer gradient for loading effects
  static LinearGradient shimmerGradient(bool isDark) => LinearGradient(
    colors: [
      getShimmerBase(isDark),
      getShimmerHighlight(isDark),
      getShimmerBase(isDark),
    ],
    stops: const [0.0, 0.5, 1.0],
  );

  /// Gradient based on color name
  static LinearGradient getGradient(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'primary':
      case 'purple':
        return primaryGradient();
      case 'secondary':
      case 'green':
        return secondaryGradient();
      case 'blue':
      case 'info':
        return blueGradient();
      case 'orange':
        return orangeGradient();
      case 'red':
      case 'error':
        return errorGradient();
      case 'pink':
        return pinkGradient();
      case 'cyan':
        return cyanGradient();
      case 'teal':
        return tealGradient();
      case 'yellow':
      case 'accent':
      case 'warning':
        return warningGradient();
      case 'success':
        return successGradient();
      default:
        return primaryGradient();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🌫️ Shadow Presets
  // ═══════════════════════════════════════════════════════════════════════

  /// Soft shadow for cards
  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black38 : dark.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Small shadow
  static List<BoxShadow> shadowSM(bool isDark) => [
    BoxShadow(
      color:
      (isDark ? Colors.black : primary).withOpacity(isDark ? 0.3 : 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Medium shadow
  static List<BoxShadow> shadowMD(bool isDark) => [
    BoxShadow(
      color:
      (isDark ? Colors.black : primary).withOpacity(isDark ? 0.35 : 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Large shadow
  static List<BoxShadow> shadowLG(bool isDark) => [
    BoxShadow(
      color:
      (isDark ? Colors.black : primary).withOpacity(isDark ? 0.4 : 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Extra large shadow
  static List<BoxShadow> shadowXL(bool isDark) => [
    BoxShadow(
      color: (isDark ? Colors.black : dark).withOpacity(isDark ? 0.5 : 0.15),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  /// Elevated shadow with color
  static List<BoxShadow> elevatedShadow(Color color, bool isDark) => [
    BoxShadow(
      color: color.withOpacity(isDark ? 0.35 : 0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: color.withOpacity(isDark ? 0.2 : 0.15),
      blurRadius: 40,
      offset: const Offset(0, 20),
      spreadRadius: -8,
    ),
  ];

  /// Primary color shadow
  static List<BoxShadow> primaryShadow(bool isDark) => [
    BoxShadow(
      color: primary.withOpacity(isDark ? 0.4 : 0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Success color shadow
  static List<BoxShadow> successShadow(bool isDark) => [
    BoxShadow(
      color: success.withOpacity(isDark ? 0.4 : 0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Error color shadow
  static List<BoxShadow> errorShadow(bool isDark) => [
    BoxShadow(
      color: error.withOpacity(isDark ? 0.4 : 0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Glow shadow effect
  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.4}) => [
    BoxShadow(
      color: color.withOpacity(intensity),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Card shadow - Premium style
  static List<BoxShadow> cardShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black26 : dark.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: isDark ? Colors.black12 : dark.withOpacity(0.02),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  /// Premium card shadow with color accent
  static List<BoxShadow> premiumCardShadow(Color accentColor, bool isDark) => [
    BoxShadow(
      color: (isDark ? Colors.black : accentColor)
          .withOpacity(isDark ? 0.4 : 0.1),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    if (!isDark)
      BoxShadow(
        color: accentColor.withOpacity(0.06),
        blurRadius: 40,
        spreadRadius: 10,
        offset: const Offset(0, 4),
      ),
  ];

  /// Icon container shadow
  static List<BoxShadow> iconShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Inner glow shadow (for premium effects)
  static List<BoxShadow> innerGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 10,
    ),
  ];

  /// Input field shadow
  static List<BoxShadow> inputShadow(bool isDark, {Color? accentColor}) => [
    BoxShadow(
      color: (isDark ? Colors.black : accentColor ?? primary)
          .withOpacity(isDark ? 0.2 : 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Inner shadow (for pressed states)
  static List<BoxShadow> innerShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black38 : dark.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: -2,
    ),
  ];

  /// Colored shadow helper
  static List<BoxShadow> coloredShadow(Color color, bool isDark) => [
    BoxShadow(
      color: color.withOpacity(isDark ? 0.4 : 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Badge glow shadow
  static List<BoxShadow> badgeGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.5),
      blurRadius: 4,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // 📐 Border Radius Presets
  // ═══════════════════════════════════════════════════════════════════════
  static const double radiusXS = 6.0;
  static const double radiusSM = 10.0;
  static const double radiusMD = 14.0;
  static const double radiusLG = 18.0;
  static const double radiusXL = 22.0;
  static const double radiusXXL = 28.0;
  static const double radiusRound = 100.0;

  // Premium border radius values
  static const double radiusCard = 24.0;
  static const double radiusInput = 16.0;
  static const double radiusIcon = 16.0;
  static const double radiusBadge = 20.0;

  // BorderRadius helpers
  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusSM => BorderRadius.circular(radiusSM);
  static BorderRadius get borderRadiusMD => BorderRadius.circular(radiusMD);
  static BorderRadius get borderRadiusLG => BorderRadius.circular(radiusLG);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);
  static BorderRadius get borderRadiusRound => BorderRadius.circular(radiusRound);
  static BorderRadius get borderRadiusCard => BorderRadius.circular(radiusCard);
  static BorderRadius get borderRadiusInput => BorderRadius.circular(radiusInput);
  static BorderRadius get borderRadiusIcon => BorderRadius.circular(radiusIcon);
  static BorderRadius get borderRadiusBadge => BorderRadius.circular(radiusBadge);

  // ═══════════════════════════════════════════════════════════════════════
  // 📏 Spacing Presets
  // ═══════════════════════════════════════════════════════════════════════
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceLG = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;
  static const double space3XL = 32.0;
  static const double space4XL = 40.0;
  static const double space5XL = 48.0;

  // ═══════════════════════════════════════════════════════════════════════
  // 📦 Size Presets
  // ═══════════════════════════════════════════════════════════════════════
  static const double iconSizeSM = 16.0;
  static const double iconSizeMD = 20.0;
  static const double iconSizeLG = 24.0;
  static const double iconSizeXL = 28.0;

  static const double iconContainerSM = 36.0;
  static const double iconContainerMD = 44.0;
  static const double iconContainerLG = 52.0;
  static const double iconContainerXL = 64.0;

  // ═══════════════════════════════════════════════════════════════════════
  // ⏱️ Animation Durations
  // ═══════════════════════════════════════════════════════════════════════
  static const Duration durationInstant = Duration(milliseconds: 50);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationSlower = Duration(milliseconds: 600);
  static const Duration durationSlowest = Duration(milliseconds: 800);
  static const Duration durationSection = Duration(milliseconds: 700);

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Animation Curves
  // ═══════════════════════════════════════════════════════════════════════
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSnappy = Curves.easeOutCubic;
  static const Curve curveSmooth = Curves.easeInOutCubic;

  // ═══════════════════════════════════════════════════════════════════════
  // 🌫️ Blur Presets
  // ═══════════════════════════════════════════════════════════════════════
  static const double blurSM = 5.0;
  static const double blurMD = 10.0;
  static const double blurLG = 15.0;
  static const double blurXL = 20.0;

  static ui.ImageFilter get blurFilterSM =>
      ui.ImageFilter.blur(sigmaX: blurSM, sigmaY: blurSM);
  static ui.ImageFilter get blurFilterMD =>
      ui.ImageFilter.blur(sigmaX: blurMD, sigmaY: blurMD);
  static ui.ImageFilter get blurFilterLG =>
      ui.ImageFilter.blur(sigmaX: blurLG, sigmaY: blurLG);
  static ui.ImageFilter get blurFilterXL =>
      ui.ImageFilter.blur(sigmaX: blurXL, sigmaY: blurXL);

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Typography Helpers
  // ═══════════════════════════════════════════════════════════════════════

  /// Headline text style
  static TextStyle headline(bool isDark, {double? size, FontWeight? weight}) =>
      TextStyle(
        fontSize: size ?? 24,
        fontWeight: weight ?? FontWeight.w700,
        color: getText(isDark),
        letterSpacing: -0.5,
      );

  /// Title text style
  static TextStyle title(bool isDark, {double? size, FontWeight? weight}) =>
      TextStyle(
        fontSize: size ?? 18,
        fontWeight: weight ?? FontWeight.w700,
        color: getText(isDark),
        letterSpacing: 0.3,
      );

  /// Subtitle text style
  static TextStyle subtitle(bool isDark, {double? size, FontWeight? weight}) =>
      TextStyle(
        fontSize: size ?? 13,
        fontWeight: weight ?? FontWeight.w400,
        color: getTextSecondary(isDark),
      );

  /// Body text style
  static TextStyle body(bool isDark, {double? size, FontWeight? weight}) =>
      TextStyle(
        fontSize: size ?? 14,
        fontWeight: weight ?? FontWeight.w400,
        color: getText(isDark),
      );

  /// Caption text style
  static TextStyle caption(bool isDark, {double? size, FontWeight? weight}) =>
      TextStyle(
        fontSize: size ?? 12,
        fontWeight: weight ?? FontWeight.w500,
        color: getTextSecondary(isDark),
      );

  /// Label text style
  static TextStyle label(bool isDark,
      {double? size, FontWeight? weight, Color? color}) =>
      TextStyle(
        fontSize: size ?? 14,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? getText(isDark),
        letterSpacing: 0.2,
      );

  /// Small label text style
  static TextStyle labelSmall(bool isDark,
      {double? size, FontWeight? weight, Color? color}) =>
      TextStyle(
        fontSize: size ?? 11,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? getTextSecondary(isDark),
        letterSpacing: 0.3,
      );

  /// Button text style
  static TextStyle button(
      {double? size, FontWeight? weight, Color? color}) =>
      TextStyle(
        fontSize: size ?? 14,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? white,
        letterSpacing: 0.3,
      );

  /// Input text style
  static TextStyle inputText(bool isDark,
      {double? size, FontWeight? weight}) =>
      TextStyle(
        fontSize: size ?? 15,
        fontWeight: weight ?? FontWeight.w500,
        color: getText(isDark),
      );

  /// Input hint text style
  static TextStyle inputHint(bool isDark, {double? size, FontWeight? weight}) =>
      TextStyle(
        fontSize: size ?? 14,
        fontWeight: weight ?? FontWeight.w400,
        color: getTextSecondary(isDark),
      );

  /// Error text style
  static TextStyle errorText({double? size, FontWeight? weight}) => TextStyle(
    fontSize: size ?? 12,
    fontWeight: weight ?? FontWeight.w500,
    color: error,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 🔲 Decoration Helpers
  // ═══════════════════════════════════════════════════════════════════════

  /// Card decoration
  static BoxDecoration cardDecoration(bool isDark, {Color? borderColor}) =>
      BoxDecoration(
        color: getCard(isDark),
        borderRadius: borderRadiusMD,
        border: Border.all(color: borderColor ?? getBorder(isDark)),
        boxShadow: cardShadow(isDark),
      );

  /// Premium card decoration with glass effect
  static BoxDecoration premiumCardDecoration(bool isDark,
      {Color accentColor = blue}) =>
      BoxDecoration(
        color: getCardGlass(isDark),
        borderRadius: borderRadiusCard,
        border: Border.all(
          color: accentColor.withOpacity(isDark ? 0.2 : 0.25),
          width: 1.5,
        ),
        boxShadow: premiumCardShadow(accentColor, isDark),
      );

  /// Surface decoration
  static BoxDecoration surfaceDecoration(bool isDark) => BoxDecoration(
    color: getSurface(isDark),
    borderRadius: borderRadiusSM,
    border: Border.all(color: getBorder(isDark)),
  );

  /// Input decoration
  static BoxDecoration inputDecoration(bool isDark, {bool focused = false}) =>
      BoxDecoration(
        color: getInputFill(isDark),
        borderRadius: borderRadiusSM,
        border: Border.all(
          color: focused ? primary : getBorder(isDark),
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [
          BoxShadow(
            color: primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      );

  /// Premium input field container decoration
  static BoxDecoration premiumInputContainerDecoration(bool isDark,
      {Color? accentColor}) =>
      BoxDecoration(
        borderRadius: borderRadiusInput,
        boxShadow: inputShadow(isDark, accentColor: accentColor),
      );

  /// Gradient card decoration
  static BoxDecoration gradientCardDecoration(Color color, bool isDark) =>
      BoxDecoration(
        gradient: cardHighlightGradient(color, isDark),
        borderRadius: borderRadiusMD,
        border: Border.all(color: color.withOpacity(0.25)),
      );

  /// Primary button decoration
  static BoxDecoration primaryButtonDecoration(bool isDark) => BoxDecoration(
    gradient: primaryGradient(),
    borderRadius: borderRadiusSM,
    boxShadow: primaryShadow(isDark),
  );

  /// Secondary button decoration
  static BoxDecoration secondaryButtonDecoration(bool isDark) => BoxDecoration(
    color: getSurface(isDark),
    borderRadius: borderRadiusSM,
    border: Border.all(color: getBorder(isDark)),
  );

  /// Header section decoration
  static BoxDecoration headerDecoration(bool isDark, Color accentColor) =>
      BoxDecoration(
        gradient: headerGradient(accentColor, isDark),
        border: Border(
          bottom: BorderSide(
            color: accentColor.withOpacity(isDark ? 0.15 : 0.2),
            width: 1,
          ),
        ),
      );

  /// Icon container decoration
  static BoxDecoration iconContainerDecoration(Color color) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withOpacity(0.85)],
    ),
    borderRadius: borderRadiusIcon,
    boxShadow: iconShadow(color),
  );

  /// Small icon decoration (for prefix icons)
  static BoxDecoration smallIconDecoration(Color color, bool isDark) =>
      BoxDecoration(
        gradient: iconGradient(color, isDark),
        borderRadius: BorderRadius.circular(10),
      );

  /// Badge decoration
  static BoxDecoration badgeDecoration(Color color, bool isDark,
      {bool isActive = false}) =>
      BoxDecoration(
        gradient: badgeGradient(color, isDark, isActive: isActive),
        borderRadius: borderRadiusBadge,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      );

  /// Country code selector decoration
  static BoxDecoration countryCodeDecoration(bool isDark, {Color? accentColor}) {
    final color = accentColor ?? purple;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withOpacity(isDark ? 0.15 : 0.1),
          color.withOpacity(isDark ? 0.08 : 0.05),
        ],
      ),
      borderRadius: borderRadiusInput,
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Input Decoration Helpers
  // ═══════════════════════════════════════════════════════════════════════

  /// Get input decoration for TextFormField
  static InputDecoration getInputDecoration({
    required bool isDark,
    required String hint,
    required Widget prefixIcon,
    Color accentColor = primary,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: inputHint(isDark),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: getInputFillGlass(isDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusInput,
          borderSide: BorderSide(
            color: isDark ? primary.withOpacity(0.1) : lightBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusInput,
          borderSide: BorderSide(
            color: accentColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusInput,
          borderSide: BorderSide(
            color: error.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusInput,
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),
        errorStyle: errorText(),
      );

  /// Build prefix icon widget for input fields
  static Widget buildPrefixIcon(IconData icon, Color color, bool isDark) =>
      Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: smallIconDecoration(color, isDark),
        child: Icon(
          icon,
          color: color,
          size: iconSizeMD,
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 ThemeData Builder
  // ═══════════════════════════════════════════════════════════════════════

  /// Build light theme
  static ThemeData lightTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: lightSurface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightText,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadiusMD,
        side: const BorderSide(color: lightBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightInput,
      border: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: BorderSide(color: error.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusSM),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightDivider,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: borderRadiusSM),
    ),
  );

  /// Build dark theme
  static ThemeData darkTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: darkSurface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadiusMD,
        side: const BorderSide(color: darkBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkInput,
      border: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: BorderSide(color: primary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: BorderSide(color: error.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusSM),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkDivider,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: borderRadiusSM),
    ),
  );
}