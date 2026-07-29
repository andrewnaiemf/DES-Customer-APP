import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ⏳ Loading State Theme
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyLoadingTheme {
  // Logo Container
  static const double logoSize = 80;
  static const List<Color> logoGradientColors = [
    Color(0xFF6842E2),
    Color(0xFF8B6CEF),
  ];
  static const double logoIconSize = 36;

  static BoxShadow get logoShadow => BoxShadow(
        color: const Color(0xFF6842E2).withOpacity(0.4),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  // Progress Indicator
  static const double progressSize = 48;
  static const double progressStrokeWidth = 3;
  static const Color progressColor = Color(0xFF6842E2);
  static const double progressBackgroundOpacity = 0.15;

  // Animation
  static const double pulseScaleMin = 0.95;
  static const double pulseScaleMax = 1.05;
}

// ═══════════════════════════════════════════════════════════════════════════
// ⏳ Premium Loading State Widget
// ═══════════════════════════════════════════════════════════════════════════
class PremiumLoadingState extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final bool isDark;

  const PremiumLoadingState({
    Key? key,
    required this.pulseAnimation,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Logo
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  width: WarrantyLoadingTheme.logoSize,
                  height: WarrantyLoadingTheme.logoSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: WarrantyLoadingTheme.logoGradientColors,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [WarrantyLoadingTheme.logoShadow],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: WarrantyLoadingTheme.logoIconSize,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Loading Text
          Text(
            'Loading service areas...',
            style: WarrantyLoadingTheme.titleStyle.copyWith(
              color: _getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait a moment',
            style: WarrantyLoadingTheme.subtitleStyle.copyWith(
              color: _getTextSecondaryColor(isDark),
            ),
          ),
          const SizedBox(height: 32),

          // Loading Indicator
          SizedBox(
            width: WarrantyLoadingTheme.progressSize,
            height: WarrantyLoadingTheme.progressSize,
            child: CircularProgressIndicator(
              strokeWidth: WarrantyLoadingTheme.progressStrokeWidth,
              valueColor: const AlwaysStoppedAnimation<Color>(
                WarrantyLoadingTheme.progressColor,
              ),
              backgroundColor: WarrantyLoadingTheme.progressColor.withOpacity(
                WarrantyLoadingTheme.progressBackgroundOpacity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF1D1D25);
  }

  Color _getTextSecondaryColor(bool isDark) {
    return isDark
        ? Colors.white.withOpacity(0.6)
        : const Color(0xFF6B7280);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎬 Pulse Animation Controller Helper
// ═══════════════════════════════════════════════════════════════════════════
class PulseAnimationController {
  static AnimationController create(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    )..repeat(reverse: true);
  }

  static Animation<double> createPulseAnimation(
      AnimationController controller) {
    return Tween<double>(
      begin: WarrantyLoadingTheme.pulseScaleMin,
      end: WarrantyLoadingTheme.pulseScaleMax,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
}
