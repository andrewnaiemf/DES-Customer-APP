import 'package:app/data/constants/assets.dart';
import 'package:app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Brand Colors
// ═══════════════════════════════════════════════════════════════════════════
class _LoadingColors {
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color purpleLight = Color(0xFFEDE9FC);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔄 Main Loading Widget (Transparent Background)
// ═══════════════════════════════════════════════════════════════════════════
class MyLoadingTransperant extends StatefulWidget {
  const MyLoadingTransperant({
    super.key,
    this.color,
    this.size = LoadingSize.medium,
    this.showText = false,
    this.text,
  });

  final Color? color;
  final LoadingSize size;
  final bool showText;
  final String? text;

  @override
  State<MyLoadingTransperant> createState() => _MyLoadingTransperantState();
}

class _MyLoadingTransperantState extends State<MyLoadingTransperant>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _size {
    switch (widget.size) {
      case LoadingSize.small:
        return 32;
      case LoadingSize.medium:
        return 48;
      case LoadingSize.large:
        return 64;
    }
  }

  double get _strokeWidth {
    switch (widget.size) {
      case LoadingSize.small:
        return 2.5;
      case LoadingSize.medium:
        return 3.0;
      case LoadingSize.large:
        return 3.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading Indicator
                  Container(
                    width: _size + 16,
                    height: _size + 16,
                    decoration: BoxDecoration(
                      color: _LoadingColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.color ?? _LoadingColors.purple)
                              .withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SizedBox(
                        width: _size,
                        height: _size,
                        child: CircularProgressIndicator(
                          strokeWidth: _strokeWidth,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.color ?? _LoadingColors.purple,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Optional Text
                  if (widget.showText) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.text ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _LoadingColors.dark.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📏 Loading Size Enum
// ═══════════════════════════════════════════════════════════════════════════
enum LoadingSize { small, medium, large }

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Modern Dots Loading
// ═══════════════════════════════════════════════════════════════════════════
class ModernDotsLoading extends StatefulWidget {
  const ModernDotsLoading({
    super.key,
    this.color,
    this.size = 12,
  });

  final Color? color;
  final double size;

  @override
  State<ModernDotsLoading> createState() => _ModernDotsLoadingState();
}

class _ModernDotsLoadingState extends State<ModernDotsLoading>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
          (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Staggered animation
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? _LoadingColors.purple;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
                child: Transform.translate(
                  offset: Offset(0, -8 * _animations[index].value),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4 * _animations[index].value),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 💫 Pulse Loading
// ═══════════════════════════════════════════════════════════════════════════
class PulseLoading extends StatefulWidget {
  const PulseLoading({
    super.key,
    this.color,
    this.size = 60,
    this.child,
  });

  final Color? color;
  final double size;
  final Widget? child;

  @override
  State<PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<PulseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? _LoadingColors.purple;

    return Center(
      child: SizedBox(
        width: widget.size * 1.5,
        height: widget.size * 1.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse Ring
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(_opacityAnimation.value),
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Center Content
            Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.child ??
                  Icon(
                    Icons.sync_rounded,
                    color: Colors.white,
                    size: widget.size * 0.3,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌀 Rotating Gradient Loading
// ═══════════════════════════════════════════════════════════════════════════
class GradientRotatingLoading extends StatefulWidget {
  const GradientRotatingLoading({
    super.key,
    this.size = 50,
    this.strokeWidth = 4,
  });

  final double size;
  final double strokeWidth;

  @override
  State<GradientRotatingLoading> createState() =>
      _GradientRotatingLoadingState();
}

class _GradientRotatingLoadingState extends State<GradientRotatingLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    _LoadingColors.purple.withOpacity(0),
                    _LoadingColors.purple,
                    _LoadingColors.lightGreen,
                    _LoadingColors.purple.withOpacity(0),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  width: widget.size - (widget.strokeWidth * 2),
                  height: widget.size - (widget.strokeWidth * 2),
                  decoration: const BoxDecoration(
                    color: _LoadingColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Full Screen Loading Overlay
// ═══════════════════════════════════════════════════════════════════════════
class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({
    super.key,
    this.message,
    this.isTransparent = true,
  });

  final String? message;
  final bool isTransparent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isTransparent
          ? _LoadingColors.dark.withOpacity(0.3)
          : _LoadingColors.white,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: _LoadingColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _LoadingColors.purple.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GradientRotatingLoading(size: 56),
              if (message != null) ...[
                const SizedBox(height: 20),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _LoadingColors.dark.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔲 Shimmer Loading (for lists/cards)
// ═══════════════════════════════════════════════════════════════════════════
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
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
    final baseColor = widget.baseColor ?? _LoadingColors.lightGray;
    final highlightColor =
        widget.highlightColor ?? _LoadingColors.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 Shimmer Placeholder Widgets
// ═══════════════════════════════════════════════════════════════════════════
class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _LoadingColors.lightGray,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _LoadingColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _LoadingColors.lightGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _LoadingColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _LoadingColors.lightGray,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: _LoadingColors.lightGray,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _LoadingColors.lightGray,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 200,
              decoration: BoxDecoration(
                color: _LoadingColors.lightGray,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Simple Minimal Loading (Original Style Enhanced)
// ═══════════════════════════════════════════════════════════════════════════
class MinimalLoading extends StatelessWidget {
  const MinimalLoading({
    super.key,
    this.color,
    this.size = 36,
    this.strokeWidth = 3,
  });

  final Color? color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? _LoadingColors.purple,
          ),
        ),
      ),
    );
  }
}