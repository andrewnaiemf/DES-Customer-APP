import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Premium Header Theme
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyHeaderTheme {
  // Header Colors
  static const List<Color> gradientColors = [
    Color(0xFF6842E2),
    Color(0xFF8B6CEF),
    Color(0xFF6842E2),
  ];

  static const Color buttonBackground = Colors.white;
  static const double buttonOpacity = 0.15;
  static const double buttonBorderOpacity = 0.2;

  // Header Dimensions
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(16, 8, 16, 20);
  static const BorderRadius headerBorderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(28),
    bottomRight: Radius.circular(28),
  );

  // Shadow
  static BoxShadow get headerShadow => BoxShadow(
        color: const Color(0xFF6842E2).withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 8),
      );

  // Button Style
  static const double buttonPadding = 12;
  static const double buttonRadius = 12;
  static const double buttonIconSize = 20;

  // Title Style
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  // Subtitle Style
  static TextStyle get subtitleStyle => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.85),
      );

  // Status Indicator
  static const double statusIndicatorSize = 6;
  static const Color statusIndicatorColor = Color(0xFF00C88D);
  static BoxShadow get statusIndicatorShadow => BoxShadow(
        color: const Color(0xFF00C88D).withOpacity(0.5),
        blurRadius: 6,
      );

  // Progress Bar
  static const double progressBarHeight = 6;
  static const double progressBarRadius = 3;
  static const double progressBarBackgroundOpacity = 0.2;

  static const List<Color> progressGradientColors = [
    Color(0xFF00C88D),
    Color(0xFF28E6C5),
  ];

  static BoxShadow get progressShadow => BoxShadow(
        color: const Color(0xFF00C88D).withOpacity(0.5),
        blurRadius: 8,
      );

  // Progress Text Style
  static TextStyle get progressLabelStyle => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.7),
      );

  static const TextStyle progressValueStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Premium Header Widget
// ═══════════════════════════════════════════════════════════════════════════
class PremiumWarrantyHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onHelpPressed;
  final double progress;
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;

  const PremiumWarrantyHeader({
    Key? key,
    required this.onBackPressed,
    required this.onHelpPressed,
    required this.progress,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, slideAnimation.value),
          child: Opacity(
            opacity: fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: WarrantyHeaderTheme.headerPadding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: WarrantyHeaderTheme.gradientColors,
          ),
          borderRadius: WarrantyHeaderTheme.headerBorderRadius,
          boxShadow: [WarrantyHeaderTheme.headerShadow],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Back Button
                _HeaderButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBackPressed,
                ),
                const SizedBox(width: 16),

                // Title Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Warranty',
                        style: WarrantyHeaderTheme.titleStyle,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: WarrantyHeaderTheme.statusIndicatorSize,
                            height: WarrantyHeaderTheme.statusIndicatorSize,
                            decoration: BoxDecoration(
                              color: WarrantyHeaderTheme.statusIndicatorColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                WarrantyHeaderTheme.statusIndicatorShadow
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Complete all required fields',
                            style: WarrantyHeaderTheme.subtitleStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Help Button
                _HeaderButton(
                  icon: Icons.help_outline_rounded,
                  onTap: onHelpPressed,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Indicator
            _ProgressIndicator(progress: progress),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Header Button
// ═══════════════════════════════════════════════════════════════════════════
class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(
            WarrantyHeaderTheme.buttonPadding,
          ),
          decoration: BoxDecoration(
            color: WarrantyHeaderTheme.buttonBackground.withOpacity(
              WarrantyHeaderTheme.buttonOpacity,
            ),
            borderRadius: BorderRadius.circular(
              WarrantyHeaderTheme.buttonRadius,
            ),
            border: Border.all(
              color: WarrantyHeaderTheme.buttonBackground.withOpacity(
                WarrantyHeaderTheme.buttonBorderOpacity,
              ),
            ),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: WarrantyHeaderTheme.buttonIconSize,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Progress Indicator
// ═══════════════════════════════════════════════════════════════════════════
class _ProgressIndicator extends StatelessWidget {
  final double progress;

  const _ProgressIndicator({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Form Completion',
              style: WarrantyHeaderTheme.progressLabelStyle,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: WarrantyHeaderTheme.progressValueStyle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: WarrantyHeaderTheme.progressBarHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              WarrantyHeaderTheme.progressBarBackgroundOpacity,
            ),
            borderRadius: BorderRadius.circular(
              WarrantyHeaderTheme.progressBarRadius,
            ),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: screenWidth * progress * 0.85,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: WarrantyHeaderTheme.progressGradientColors,
                  ),
                  borderRadius: BorderRadius.circular(
                    WarrantyHeaderTheme.progressBarRadius,
                  ),
                  boxShadow: [WarrantyHeaderTheme.progressShadow],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
