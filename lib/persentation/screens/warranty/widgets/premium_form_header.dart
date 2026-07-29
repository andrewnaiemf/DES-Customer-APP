import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Premium Form Header - Glassmorphism Design
// ═══════════════════════════════════════════════════════════════════════════

class PremiumFormHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final VoidCallback? onClose;
  final Widget? trailing;
  final int? currentStep;
  final int? totalSteps;
  final double? progress;

  const PremiumFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.accentColor = const Color(0xFF3B82F6),
    this.isDark = false,
    this.onClose,
    this.trailing,
    this.currentStep,
    this.totalSteps,
    this.progress,
  });

  @override
  State<PremiumFormHeader> createState() => _PremiumFormHeaderState();
}

class _PremiumFormHeaderState extends State<PremiumFormHeader>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Icon entrance animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _iconScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _iconRotation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Pulse animation for icon glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _iconController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withOpacity(widget.isDark ? 0.15 : 0.08),
            widget.accentColor.withOpacity(widget.isDark ? 0.05 : 0.02),
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              // Animated background pattern
              _buildBackgroundPattern(),

              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Animated Icon
                        _buildAnimatedIcon(),
                        const SizedBox(width: 16),

                        // Title & Subtitle
                        Expanded(child: _buildTitleSection()),

                        // Trailing widget or close button
                        if (widget.trailing != null)
                          widget.trailing!
                        else if (widget.onClose != null)
                          _buildCloseButton(),
                      ],
                    ),

                    // Progress indicator
                    if (widget.progress != null || widget.currentStep != null)
                      _buildProgressSection(),
                  ],
                ),
              ),

              // Bottom border with gradient
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor.withOpacity(0),
                        widget.accentColor
                            .withOpacity(widget.isDark ? 0.3 : 0.4),
                        widget.accentColor.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: _HeaderPatternPainter(
              color: widget.accentColor,
              isDark: widget.isDark,
              animationValue: _shimmerAnimation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_iconController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _iconScale.value,
          child: Transform.rotate(
            angle: _iconRotation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor,
                    widget.accentColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor
                        .withOpacity(0.4 * _pulseAnimation.value),
                    blurRadius: 16 * _pulseAnimation.value,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: widget.accentColor
                        .withOpacity(0.2 * _pulseAnimation.value),
                    blurRadius: 24 * _pulseAnimation.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner glow
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with shimmer effect
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    widget.isDark ? Colors.white : const Color(0xFF1D1D25),
                    widget.accentColor,
                    widget.isDark ? Colors.white : const Color(0xFF1D1D25),
                  ],
                  stops: [
                    (_shimmerAnimation.value - 0.3).clamp(0, 1).toDouble(),
                    _shimmerAnimation.value.clamp(0, 1).toDouble(),
                    (_shimmerAnimation.value + 0.3).clamp(0, 1).toDouble(),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color:
                      widget.isDark ? Colors.white : const Color(0xFF1D1D25),
                  letterSpacing: 0.3,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),

        // Subtitle
        Text(
          widget.subtitle,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: widget.isDark
                ? Colors.white.withOpacity(0.6)
                : const Color(0xFF6B7280),
          ),
        ),

        // Step indicator
        if (widget.currentStep != null && widget.totalSteps != null) ...[
          const SizedBox(height: 6),
          _buildStepBadge(),
        ],
      ],
    );
  }

  Widget _buildStepBadge() {
    final isComplete = widget.currentStep == widget.totalSteps;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [
                  const Color(0xFF10B981)
                      .withOpacity(widget.isDark ? 0.2 : 0.15),
                  const Color(0xFF10B981)
                      .withOpacity(widget.isDark ? 0.1 : 0.08),
                ]
              : [
                  widget.accentColor
                      .withOpacity(widget.isDark ? 0.15 : 0.1),
                  widget.accentColor
                      .withOpacity(widget.isDark ? 0.08 : 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete
              ? const Color(0xFF10B981).withOpacity(0.3)
              : widget.accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle_rounded : Icons.layers_rounded,
            size: 12,
            color:
                isComplete ? const Color(0xFF10B981) : widget.accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            'Step ${widget.currentStep} of ${widget.totalSteps}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  isComplete ? const Color(0xFF10B981) : widget.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress =
        widget.progress ?? (widget.currentStep! / widget.totalSteps!);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor,
                          widget.accentColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withOpacity(0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Progress percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.accentColor,
                ),
              ),
              if (progress >= 1)
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'All fields completed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onClose?.call();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Icon(
          Icons.close_rounded,
          size: 20,
          color: widget.isDark
              ? Colors.white.withOpacity(0.7)
              : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Custom painter for animated background pattern
// ═══════════════════════════════════════════════════════════════════════════
class _HeaderPatternPainter extends CustomPainter {
  final Color color;
  final bool isDark;
  final double animationValue;

  _HeaderPatternPainter({
    required this.color,
    required this.isDark,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(isDark ? 0.03 : 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw animated circles
    for (int i = 0; i < 3; i++) {
      final offset = (animationValue + i * 0.3) % 2;
      final radius = 30.0 + (offset * 50);
      final opacity = (1 - offset / 2).clamp(0.0, 1.0);

      paint.color = color.withOpacity(opacity * (isDark ? 0.08 : 0.05));

      canvas.drawCircle(
        Offset(size.width - 50, size.height / 2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeaderPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
