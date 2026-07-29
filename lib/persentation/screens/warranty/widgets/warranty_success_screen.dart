import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_theme.dart';
import 'package:app/persentation/screens/warranty/widgets/pressable_scale.dart';
import 'package:app/persentation/screens/warranty/warranty_strings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ✅ Warranty Success Screen - Premium Animated Success Page
// ═══════════════════════════════════════════════════════════════════════════
// Displays after successful warranty registration with:
// • Animated check mark with pulse ring
// • Floating particles celebration
// • Background orbs
// • Info card with email notification
// • "Back to Warranty" button → pops to warranty main screen
// ═══════════════════════════════════════════════════════════════════════════

class WarrantySuccessScreen extends StatefulWidget {
  const WarrantySuccessScreen({super.key});

  @override
  State<WarrantySuccessScreen> createState() => _WarrantySuccessScreenState();
}

class _WarrantySuccessScreenState extends State<WarrantySuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particlesController;

  late Animation<double> _checkScaleAnimation;
  late Animation<double> _containerScaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _ringAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    HapticFeedback.heavyImpact();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _containerScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.75, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 35, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.forward();
    _particlesController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.getBackground(_isDark),
        body: Stack(
          children: [
            // Background Decorations
            _buildBackgroundOrbs(size),

            // Floating Particles
            _buildFloatingParticles(size),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Success Animation
                    AnimatedBuilder(
                      animation: _containerScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _containerScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: _buildSuccessCircle(size),
                    ),

                    const SizedBox(height: 50),

                    // Text Content
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildTextContent(size),
                    ),

                    const SizedBox(height: 32),

                    // Info Card
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 1.4),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildInfoCard(size),
                    ),

                    const Spacer(flex: 3),

                    // Back to Warranty Button
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        );
                      },
                      child: _buildBackToWarrantyButton(size),
                    ),

                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔵 Background Orbs
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundOrbs(Size size) {
    return Stack(
      children: [
        // Top Right Green Orb
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Positioned(
              top: -60,
              right: -50,
              child: Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.08),
                child: Opacity(
                  opacity: _isDark ? 0.12 : 0.18,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.green,
                          AppTheme.green.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Bottom Left Purple Orb
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Positioned(
              bottom: size.height * 0.18,
              left: -80,
              child: Transform.scale(
                scale: 1.0 + ((1 - _pulseController.value) * 0.06),
                child: Opacity(
                  opacity: _isDark ? 0.08 : 0.12,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.purple,
                          AppTheme.purple.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✨ Floating Particles
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildFloatingParticles(Size size) {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        final particleProgress = _particlesController.value;
        return Stack(
          children: List.generate(12, (index) {
            final random = math.Random(index * 42);
            final startX = random.nextDouble() * size.width;
            final startY = size.height * 0.4 + (random.nextDouble() * 100);
            final endY = startY - 200 - (random.nextDouble() * 150);
            final delay = random.nextDouble() * 0.3;

            final progress =
                ((particleProgress - delay) / 0.7).clamp(0.0, 1.0);
            final curve = Curves.easeOutCubic.transform(progress);

            return Positioned(
              left: startX + (math.sin(progress * math.pi * 2) * 20),
              top: ui.lerpDouble(startY, endY, curve)!,
              child: Opacity(
                opacity: (1.0 - progress).clamp(0.0, 0.6),
                child: Container(
                  width: 6 + (random.nextDouble() * 6),
                  height: 6 + (random.nextDouble() * 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index % 3 == 0
                        ? AppTheme.green
                        : index % 3 == 1
                            ? AppTheme.yellow
                            : AppTheme.lightGreen,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✅ Success Circle with Animated Check
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildSuccessCircle(Size size) {
    final circleSize = size.width * 0.44;

    return SizedBox(
      width: circleSize + 40,
      height: circleSize + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Pulse Ring
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: circleSize + 30 + (_pulseController.value * 20),
                height: circleSize + 30 + (_pulseController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.green.withOpacity(
                      0.3 - (_pulseController.value * 0.2),
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),

          // Ring Animation
          AnimatedBuilder(
            animation: _ringAnimation,
            builder: (context, child) {
              return Container(
                width: circleSize + 10,
                height: circleSize + 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.green.withOpacity(0.2),
                    width: 3 * _ringAnimation.value,
                  ),
                ),
              );
            },
          ),

          // Main Circle with Glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.successGradient(),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.green.withOpacity(
                        0.35 + (_pulseController.value * 0.15),
                      ),
                      blurRadius: 40 + (_pulseController.value * 25),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: ScaleTransition(
              scale: _checkScaleAnimation,
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: circleSize * 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Text Content
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTextContent(Size size) {
    return Column(
      children: [
        Text(
          WarrantyStrings.requestSent,
          style: TextStyle(
            fontSize: size.width * 0.068,
            fontWeight: FontWeight.w800,
            color: AppTheme.getText(_isDark),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          WarrantyStrings.warrantyRegisteredDescription,
          style: TextStyle(
            fontSize: size.width * 0.042,
            color: AppTheme.getTextSecondary(_isDark),
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📧 Info Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildInfoCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.green.withOpacity(_isDark ? 0.15 : 0.1),
            AppTheme.lightGreen.withOpacity(_isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: AppTheme.green.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.successGradient(),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              boxShadow: AppTheme.glowShadow(AppTheme.green, intensity: 0.25),
            ),
            child: Icon(
              Icons.email_outlined,
              color: Colors.white,
              size: size.width * 0.06,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              WarrantyStrings.emailNotification,
              style: TextStyle(
                fontSize: size.width * 0.036,
                color: AppTheme.getText(_isDark),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔙 Back to Warranty Button
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBackToWarrantyButton(Size size) {
    return PressableScale(
      onPressed: () {
        HapticFeedback.lightImpact();
        // Pop back to the warranty main screen (removes the success + form screens)
        Navigator.of(context).popUntil((route) {
          // Pop until we reach the layout screen (which contains warranty tab)
          return route.isFirst;
        });
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient(),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: size.width * 0.06,
            ),
            const SizedBox(width: 12),
            Text(
              WarrantyStrings.backToWarranty,
              style: TextStyle(
                fontSize: size.width * 0.044,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
