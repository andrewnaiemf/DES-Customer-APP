import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════════════
// ⏳ Premium Loading Overlay - Form Loading State
// ═══════════════════════════════════════════════════════════════════════════

class PremiumLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color accentColor;
  final bool isDark;
  final LoadingStyle style;

  const PremiumLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.accentColor = const Color(0xFF6842E2),
    this.isDark = false,
    this.style = LoadingStyle.overlay,
  });

  @override
  State<PremiumLoadingOverlay> createState() => _PremiumLoadingOverlayState();
}

enum LoadingStyle { overlay, skeleton, pulse }

class _PremiumLoadingOverlayState extends State<PremiumLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    if (widget.isLoading) {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(PremiumLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,

        // Loading overlay
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: _buildLoadingContent(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    switch (widget.style) {
      case LoadingStyle.skeleton:
        return _buildSkeletonLoader();
      case LoadingStyle.pulse:
        return _buildPulseLoader();
      case LoadingStyle.overlay:
        return _buildOverlayLoader();
    }
  }

  Widget _buildOverlayLoader() {
    return Container(
      color: widget.isDark
          ? Colors.black.withOpacity(0.7)
          : Colors.white.withOpacity(0.85),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated loader
              _buildAnimatedLoader(),

              // Message
              if (widget.message != null) ...[
                const SizedBox(height: 24),
                _buildLoadingMessage(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLoader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.accentColor
                      .withOpacity(widget.isDark ? 0.2 : 0.15),
                  widget.accentColor
                      .withOpacity(widget.isDark ? 0.1 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating ring
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: CustomPaint(
                    size: const Size(60, 60),
                    painter: _LoaderRingPainter(
                      color: widget.accentColor,
                      strokeWidth: 3,
                    ),
                  ),
                ),

                // Center icon
                Icon(
                  Icons.sync_rounded,
                  size: 24,
                  color: widget.accentColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF14141F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(widget.isDark ? 0.3 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDotsAnimation(),
          const SizedBox(width: 12),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? Colors.white
                  : const Color(0xFF1D1D25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotsAnimation() {
    return SizedBox(
      width: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = math.sin(
                (_pulseController.value + delay) * math.pi,
              ).abs();

              return Container(
                width: 4,
                height: 4 + (value * 4),
                decoration: BoxDecoration(
                  color:
                      widget.accentColor.withOpacity(0.5 + value * 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      color: widget.isDark
          ? const Color(0xFF0A0A12)
          : const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header skeleton
          _buildSkeletonBox(height: 80, radius: 20),
          const SizedBox(height: 20),

          // Content skeletons
          _buildSkeletonBox(height: 56, radius: 16),
          const SizedBox(height: 12),
          _buildSkeletonBox(height: 56, radius: 16),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildSkeletonBox(height: 56, radius: 16)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildSkeletonBox(height: 56, radius: 16)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSkeletonBox(height: 120, radius: 20),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double height,
    double radius = 12,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _pulseController.value * 2, 0),
              end: Alignment(1 + _pulseController.value * 2, 0),
              colors: widget.isDark
                  ? const [
                      Color(0xFF1A1A2E),
                      Color(0xFF2A2A3E),
                      Color(0xFF1A1A2E),
                    ]
                  : const [
                      Color(0xFFE5E7EB),
                      Color(0xFFF5F7FA),
                      Color(0xFFE5E7EB),
                    ],
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  Widget _buildPulseLoader() {
    return Container(
      color: widget.isDark
          ? Colors.black.withOpacity(0.5)
          : Colors.white.withOpacity(0.7),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: List.generate(3, (index) {
                final scale = 1 + (index * 0.3);
                final opacity =
                    (1 - index * 0.3) * _pulseAnimation.value;

                return Container(
                  width: 60 * scale,
                  height: 60 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.accentColor
                          .withOpacity(opacity * 0.5),
                      width: 2,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Custom painter for loader ring
// ═══════════════════════════════════════════════════════════════════════════
class _LoaderRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _LoaderRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔄 Inline Loading Indicator
// ═══════════════════════════════════════════════════════════════════════════

class PremiumLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final String? label;
  final bool isDark;

  const PremiumLoadingIndicator({
    super.key,
    this.size = 40,
    this.color = const Color(0xFF6842E2),
    this.strokeWidth = 3,
    this.label,
    this.isDark = false,
  });

  @override
  State<PremiumLoadingIndicator> createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _LoaderRingPainter(
                  color: widget.color,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
            );
          },
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: widget.isDark
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}
