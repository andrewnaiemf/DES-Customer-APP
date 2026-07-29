import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PremiumBackground extends StatefulWidget {
  final Widget child;

  const PremiumBackground({
    super.key,
    required this.child,
  });

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF111827),
                    Color(0xFF0B1020),
                  ],
                ),
              ),
            ),

            Positioned(
              top: -100 + (_controller.value * 20),
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.15),
                ),
              ),
            ),

            Positioned(
              bottom: -80 - (_controller.value * 20),
              left: -50,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withOpacity(0.12),
                ),
              ),
            ),

            widget.child,
          ],
        );
      },
    );
  }
}

// ==================== App Theme Colors (محسّن) ====================
class AppTheme {
  static const Color primary = Color(0xFF6C3FE8);
  static const Color secondary = Color(0xFF9B5FF3);
  static const Color accent = Color(0xFFC47EF0);

  static const Color success = Color(0xFF6EFFC0);
  static const Color warning = Color(0xFFFFE066);
  static const Color orange = Color(0xFFFFB347);
  static const Color danger = Color(0xFFFF5E7A);

  static const Color dark = Color(0xFF0F172A);
  static const Color dark2 = Color(0xFF15172A);

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C3FE8),
      Color(0xFF9B5FF3),
      Color(0xFFC47EF0),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF171A30),
      Color(0xFF0E1324),
    ],
  );
}
class PremiumPills extends StatelessWidget {
  const PremiumPills({super.key});

  @override
  Widget build(BuildContext context) {
    final pills = [
      ('Exclusive Discount', AppTheme.warning),
      ('Limited Time', AppTheme.success),
      ('Most Popular', AppTheme.orange),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pills.map((pill) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pill.$2,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                pill.$1.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}