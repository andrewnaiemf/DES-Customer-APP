// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Tracking UI Widgets - Premium Enhanced Version
// ═══════════════════════════════════════════════════════════════════════════
// مجموعة Widgets لعرض حالة التتبع بتصميم احترافي عصري
//
// Path: lib/core/live_tracking/widgets/tracking_widgets.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../models/order_tracking_model.dart';
import '../theme/tracking_colors.dart';

// Export the new Live Activity style widget
export 'live_tracking_compact_card.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Brand Colors - الألوان الرسمية للتطبيق
// ═══════════════════════════════════════════════════════════════════════════
class MyColors {
  MyColors._();
  
  // Brand Colors
  static const Color yellow = Color.fromRGBO(217, 179, 29, 1.0);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightgreen = Color(0xFF28E6C5);
  static const Color darkgray = Color(0xFFC6CBE0);
  static const Color lightgray = Color(0xFFF9FAFB);
  
  static const MaterialColor mainColorSwatch = MaterialColor(
    0xFF6842E2,
    <int, Color>{
      50: Color(0xFFEDE7FC),
      100: Color(0xFFD1C3F7),
      200: Color(0xFFB39BF2),
      300: Color(0xFF9473ED),
      400: Color(0xFF7E55E9),
      500: Color(0xFF6842E2),
      600: Color(0xFF603CDF),
      700: Color(0xFF5533DA),
      800: Color(0xFF4B2BD6),
      900: Color(0xFF3A1DCF),
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏷️ Tracking Status Badge - Enhanced with Animations
// ═══════════════════════════════════════════════════════════════════════════
class TrackingStatusBadge extends StatefulWidget {
  final OrderTrackingStatus status;
  final bool showIcon;
  final bool compact;
  final bool outlined;
  final bool animated;

  const TrackingStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.compact = false,
    this.outlined = false,
    this.animated = true,
  });

  @override
  State<TrackingStatusBadge> createState() => _TrackingStatusBadgeState();
}

class _TrackingStatusBadgeState extends State<TrackingStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.animated && widget.status.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animated ? _scaleAnimation.value : 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 10 : 14,
              vertical: widget.compact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: widget.outlined 
                  ? Colors.transparent 
                  : statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(widget.compact ? 20 : 24),
              border: Border.all(
                color: statusColor.withOpacity(widget.outlined ? 0.8 : 0.25),
                width: widget.outlined ? 1.5 : 1,
              ),
              boxShadow: widget.animated && widget.status.isActive
                  ? [
                      BoxShadow(
                        color: statusColor.withOpacity(_glowAnimation.value),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showIcon) ...[
                  _buildAnimatedIcon(statusColor),
                  SizedBox(width: widget.compact ? 6 : 8),
                ],
                Text(
                  widget.compact ? widget.status.shortDescription : widget.status.arabicText,
                  style: TextStyle(
                    fontSize: widget.compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            widget.status.icon,
            size: widget.compact ? 14 : 16,
            color: color,
          ),
        );
      },
    );
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case OrderTrackingStatus.pending:
        return MyColors.purple;
      case OrderTrackingStatus.confirmed:
        return MyColors.purple;
      case OrderTrackingStatus.preparing:
        return MyColors.yellow;
      case OrderTrackingStatus.ready:
        return TrackingColors.ready;
      case OrderTrackingStatus.pickedUp:
        return TrackingColors.pickedUp;
      case OrderTrackingStatus.onTheWay:
        return const Color(0xFF3B82F6);
      case OrderTrackingStatus.arrived:
        return TrackingColors.arrived;
      case OrderTrackingStatus.delivered:
        return MyColors.lightgreen;
      case OrderTrackingStatus.cancelled:
        return TrackingColors.error;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Tracking Progress Bar - Premium Animated Version
// ═══════════════════════════════════════════════════════════════════════════
class TrackingProgressBar extends StatefulWidget {
  final double progress;
  final Color? color;
  final double height;
  final bool showPercentage;
  final bool animated;
  final bool showShimmer;
  final BorderRadius? borderRadius;

  const TrackingProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 10,
    this.showPercentage = false,
    this.animated = true,
    this.showShimmer = true,
    this.borderRadius,
  });

  @override
  State<TrackingProgressBar> createState() => _TrackingProgressBarState();
}

class _TrackingProgressBarState extends State<TrackingProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? MyColors.purple;
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(widget.height);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التقدم',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MyColors.darkgray,
                  ),
                ),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: (widget.progress * 100).toInt()),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: effectiveColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$value%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: effectiveColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        
        // Progress Bar Container
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(0.12),
            borderRadius: effectiveRadius,
            border: Border.all(
              color: effectiveColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Animated Progress Fill
                  AnimatedContainer(
                    duration: widget.animated
                        ? const Duration(milliseconds: 800)
                        : Duration.zero,
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * widget.progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          effectiveColor,
                          effectiveColor.withOpacity(0.75),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: effectiveRadius,
                      boxShadow: [
                        BoxShadow(
                          color: effectiveColor.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  // Shimmer Effect
                  if (widget.showShimmer && widget.progress < 1.0)
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Positioned(
                          left: -60 + (constraints.maxWidth * widget.progress + 60) * _shimmerController.value,
                          child: Container(
                            width: 60,
                            height: widget.height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📍 Tracking Timeline - Enhanced with Animations
// ═══════════════════════════════════════════════════════════════════════════
class TrackingTimeline extends StatelessWidget {
  final List<OrderTrackingStep> steps;
  final Axis direction;
  final double spacing;
  final bool showDescription;
  final bool showTime;
  final bool animated;

  const TrackingTimeline({
    super.key,
    required this.steps,
    this.direction = Axis.vertical,
    this.spacing = 24,
    this.showDescription = true,
    this.showTime = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return _buildHorizontalTimeline();
    }
    return _buildVerticalTimeline();
  }

  Widget _buildVerticalTimeline() {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return _VerticalTimelineItem(
          step: step,
          isLast: isLast,
          spacing: spacing,
          showDescription: showDescription,
          showTime: showTime,
          index: index,
          animated: animated,
        );
      }),
    );
  }

  Widget _buildHorizontalTimeline() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;

            return _HorizontalTimelineItem(
              step: step,
              isLast: isLast,
              index: index,
              animated: animated,
            );
          }),
        ),
      ),
    );
  }
}

class _VerticalTimelineItem extends StatefulWidget {
  final OrderTrackingStep step;
  final bool isLast;
  final double spacing;
  final bool showDescription;
  final bool showTime;
  final int index;
  final bool animated;

  const _VerticalTimelineItem({
    required this.step,
    required this.isLast,
    required this.spacing,
    required this.showDescription,
    required this.showTime,
    required this.index,
    required this.animated,
  });

  @override
  State<_VerticalTimelineItem> createState() => _VerticalTimelineItemState();
}

class _VerticalTimelineItemState extends State<_VerticalTimelineItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    if (widget.step.isCurrent && widget.animated) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Indicator
                  Column(
                    children: [
                      _buildIndicator(),
                      if (!widget.isLast) _buildLine(),
                    ],
                  ),
                  const SizedBox(width: 18),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : widget.spacing),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicator() {
    final color = _getStepColor();
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.step.isCurrent ? _pulseAnimation.value : 1.0,
          child: Container(
            width: widget.step.isCurrent ? 40 : 36,
            height: widget.step.isCurrent ? 40 : 36,
            decoration: BoxDecoration(
              gradient: widget.step.isCompleted
                  ? LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.step.isCompleted ? null : color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: widget.step.isCurrent ? 3 : 2,
              ),
              boxShadow: widget.step.isCurrent
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : widget.step.isCompleted
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  widget.step.isCompleted ? Icons.check_rounded : widget.step.originalIcon,
                  key: ValueKey(widget.step.isCompleted),
                  size: widget.step.isCurrent ? 20 : 18,
                  color: widget.step.isCompleted ? Colors.white : color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLine() {
    final color = _getStepColor();
    
    return Expanded(
      child: Container(
        width: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color,
              widget.step.isCompleted ? color.withOpacity(0.5) : color.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final color = _getStepColor();
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.step.isCurrent 
            ? color.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: widget.step.isCurrent
            ? Border.all(color: color.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.step.title,
            style: TextStyle(
              fontSize: widget.step.isCurrent ? 17 : 16,
              fontWeight: widget.step.isCurrent ? FontWeight.bold : FontWeight.w600,
              color: widget.step.isCompleted || widget.step.isCurrent
                  ? MyColors.black
                  : MyColors.darkgray,
              letterSpacing: -0.3,
            ),
          ),
          
          // Description
          if (widget.showDescription) ...[
            const SizedBox(height: 6),
            Text(
              widget.step.description,
              style: TextStyle(
                fontSize: 14,
                color: MyColors.darkgray,
                height: 1.5,
              ),
            ),
          ],
          
          // Time Badge
          if (widget.showTime && widget.step.completedAt != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(widget.step.completedAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Note
          if (widget.step.note != null && widget.step.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.step.note!,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStepColor() {
    if (widget.step.isCurrent) return MyColors.purple;
    if (widget.step.isCompleted) return MyColors.lightgreen;
    return MyColors.darkgray;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _HorizontalTimelineItem extends StatelessWidget {
  final OrderTrackingStep step;
  final bool isLast;
  final int index;
  final bool animated;

  const _HorizontalTimelineItem({
    required this.step,
    required this.isLast,
    required this.index,
    required this.animated,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStepColor();
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circle Indicator
                    Container(
                      width: step.isCurrent ? 52 : 46,
                      height: step.isCurrent ? 52 : 46,
                      decoration: BoxDecoration(
                        gradient: step.isCompleted
                            ? LinearGradient(
                                colors: [color, color.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: step.isCompleted ? null : color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color,
                          width: step.isCurrent ? 3 : 2,
                        ),
                        boxShadow: step.isCurrent
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        step.isCompleted ? Icons.check_rounded : step.originalIcon,
                        size: 22,
                        color: step.isCompleted ? Colors.white : color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Label
                    SizedBox(
                      width: 80,
                      child: Text(
                        step.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: step.isCurrent ? FontWeight.bold : FontWeight.w600,
                          color: step.isCompleted || step.isCurrent
                              ? MyColors.black
                              : MyColors.darkgray,
                        ),
                      ),
                    ),
                  ],
                ),
                // Connecting Line
                if (!isLast)
                  Container(
                    width: 50,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          step.isCompleted ? color.withOpacity(0.5) : color.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStepColor() {
    if (step.isCurrent) return MyColors.purple;
    if (step.isCompleted) return MyColors.lightgreen;
    return MyColors.darkgray;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Tracking Card - Premium Design with Hero Animation
// ═══════════════════════════════════════════════════════════════════════════
class TrackingCard extends StatefulWidget {
  final OrderTrackingModel tracking;
  final VoidCallback? onTap;
  final VoidCallback? onCallDriver;
  final bool showTimeline;
  final bool compact;
  final bool elevated;
  final String? heroTag;

  const TrackingCard({
    super.key,
    required this.tracking,
    this.onTap,
    this.onCallDriver,
    this.showTimeline = true,
    this.compact = false,
    this.elevated = true,
    this.heroTag,
  });

  @override
  State<TrackingCard> createState() => _TrackingCardState();
}

class _TrackingCardState extends State<TrackingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = _buildCardContent();
    
    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: Material(
          color: Colors.transparent,
          child: cardContent,
        ),
      );
    }
    
    return cardContent;
  }

  Widget _buildCardContent() {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      onTap: () {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.02),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(widget.compact ? 18 : 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(widget.compact ? 18 : 24),
                border: Border.all(
                  color: widget.tracking.color.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: widget.elevated
                    ? [
                        BoxShadow(
                          color: widget.tracking.color.withOpacity(_isPressed ? 0.2 : 0.12),
                          blurRadius: _isPressed ? 16 : 24,
                          offset: Offset(0, _isPressed ? 4 : 10),
                          spreadRadius: _isPressed ? 0 : 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),

                  SizedBox(height: widget.compact ? 18 : 22),

                  // Progress Bar
                  TrackingProgressBar(
                    progress: widget.tracking.progressPercentage,
                    color: widget.tracking.color,
                    showPercentage: !widget.compact,
                    height: widget.compact ? 8 : 10,
                    showShimmer: widget.tracking.isActive,
                  ),

                  // Driver Info
                  if (widget.tracking.hasDriverInfo && !widget.compact) ...[
                    const SizedBox(height: 18),
                    _buildDriverInfo(),
                  ],

                  // Estimated Time
                  if (widget.tracking.hasEstimatedTime && !widget.compact) ...[
                    const SizedBox(height: 14),
                    _buildEstimatedTime(),
                  ],

                  // Timeline
                  if (widget.showTimeline && !widget.compact && widget.tracking.steps.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            MyColors.darkgray.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TrackingTimeline(
                      steps: widget.tracking.steps,
                      spacing: 18,
                      showDescription: false,
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

  Widget _buildHeader() {
    return Row(
      children: [
        // Order Icon with Gradient Background
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.tracking.color.withOpacity(0.15),
                widget.tracking.color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.tracking.color.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.local_shipping_rounded,
            color: widget.tracking.color,
            size: widget.compact ? 24 : 28,
          ),
        ),
        const SizedBox(width: 16),
        
        // Order Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طلب #${widget.tracking.orderReference}',
                style: TextStyle(
                  fontSize: widget.compact ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: MyColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              TrackingStatusBadge(
                status: widget.tracking.status,
                compact: widget.compact,
                animated: true,
              ),
            ],
          ),
        ),
        
        // Arrow Indicator
        if (widget.onTap != null)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MyColors.lightgray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MyColors.darkgray.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: MyColors.darkgray,
            ),
          ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColors.lightgray,
            MyColors.lightgray.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MyColors.darkgray.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: TrackingColors.purpleGradient.map((c) => c.withOpacity(0.2)).toList(),
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: MyColors.purple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: widget.tracking.driverImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(
                      widget.tracking.driverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person_rounded,
                        size: 26,
                        color: MyColors.purple,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    size: 26,
                    color: MyColors.purple,
                  ),
          ),
          const SizedBox(width: 14),
          
          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السائق',
                  style: TextStyle(
                    fontSize: 12,
                    color: MyColors.darkgray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.tracking.driverName!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: MyColors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Call Button
          if (widget.tracking.driverPhone != null && widget.onCallDriver != null)
            _CallDriverButton(onPressed: widget.onCallDriver!),
        ],
      ),
    );
  }

  Widget _buildEstimatedTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MyColors.purple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MyColors.purple.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MyColors.purple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.access_time_rounded,
              size: 18,
              color: MyColors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'الوصول المتوقع: ',
            style: TextStyle(
              fontSize: 14,
              color: MyColors.darkgray,
            ),
          ),
          Text(
            widget.tracking.estimatedDeliveryTime!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: MyColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📞 Call Driver Button - Animated
// ═══════════════════════════════════════════════════════════════════════════
class _CallDriverButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CallDriverButton({required this.onPressed});

  @override
  State<_CallDriverButton> createState() => _CallDriverButtonState();
}

class _CallDriverButtonState extends State<_CallDriverButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: TrackingColors.greenGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: MyColors.lightgreen.withOpacity(_isPressed ? 0.6 : 0.4),
                    blurRadius: _isPressed ? 6 : 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔔 Mini Tracking Banner - Premium Animated Version
// ═══════════════════════════════════════════════════════════════════════════
class MiniTrackingBanner extends StatefulWidget {
  final OrderTrackingModel tracking;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const MiniTrackingBanner({
    super.key,
    required this.tracking,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<MiniTrackingBanner> createState() => _MiniTrackingBannerState();
}

class _MiniTrackingBannerState extends State<MiniTrackingBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap?.call();
              },
              onHorizontalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dx.abs() > 200) {
                  _dismiss();
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.tracking.color,
                      widget.tracking.color.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tracking.color.withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        children: [
                          // Animated Icon
                          _buildAnimatedIcon(),
                          const SizedBox(width: 14),
                          
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'طلب #${widget.tracking.orderReference}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.tracking.statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Progress Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${widget.tracking.progressPercent}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: widget.tracking.color,
                              ),
                            ),
                          ),
                          
                          // Dismiss
                          if (widget.onDismiss != null) ...[
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _dismiss();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.tracking.icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Live Tracking Compact Card - Premium Live Activity Style
// ═══════════════════════════════════════════════════════════════════════════
class LiveActivityColors {
  LiveActivityColors._();

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF15172A);
  static const Color cardBackground = Color(0xFF1D1D25);
  static const Color lightGray = Color(0xFF3D3D4A);
  static const Color mediumGray = Color(0xFF636366);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC6CBE0);
  static const Color divider = Color(0xFF38383A);

  // Accent Colors from Brand
  static const Color yellowAccent = Color.fromRGBO(217, 179, 29, 1.0);
  static const Color greenAccent = Color(0xFF28E6C5);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color purpleAccent = Color(0xFF6842E2);
  static const Color redAccent = Color(0xFFFF4757);
}

class LiveTrackingCompactCard extends StatefulWidget {
  final OrderTrackingModel tracking;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onCallDriver;
  final bool showDriverInfo;
  final bool elevated;
  final EdgeInsetsGeometry? margin;

  const LiveTrackingCompactCard({
    super.key,
    required this.tracking,
    this.onTrackOrder,
    this.onCallDriver,
    this.showDriverInfo = true,
    this.elevated = true,
    this.margin,
  });

  @override
  State<LiveTrackingCompactCard> createState() => _LiveTrackingCompactCardState();
}

class _LiveTrackingCompactCardState extends State<LiveTrackingCompactCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.tracking.isActive) {
      _pulseController.repeat(reverse: true);
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: widget.elevated
            ? [
                BoxShadow(
                  color: _getAccentColor().withOpacity(0.35),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                LiveActivityColors.cardBackground,
                LiveActivityColors.darkBackground,
              ],
            ),
            border: Border.all(
              color: _getAccentColor().withOpacity(0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStatusInfo(),
                    const SizedBox(height: 18),
                    _buildProgressBar(),
                    
                    if (widget.tracking.hasEstimatedTime) ...[
                      const SizedBox(height: 18),
                      _buildEstimatedTime(),
                    ],
                    
                    if (widget.showDriverInfo && widget.tracking.hasDriverInfo) ...[
                      const SizedBox(height: 18),
                      _buildDriverInfo(),
                    ],
                  ],
                ),
              ),
              
              // CTA Button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Animated Order Icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.tracking.isActive ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getAccentColor().withOpacity(0.25),
                      _getAccentColor().withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _getAccentColor().withOpacity(0.35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getAccentColor().withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getAccentColor(),
                  size: 30,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 18),

        // Order Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طلب #${widget.tracking.orderReference}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: LiveActivityColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getAccentColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getAccentColor().withOpacity(0.7),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.tracking.statusText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _getAccentColor(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Progress Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getAccentColor().withOpacity(0.25),
                _getAccentColor().withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _getAccentColor().withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            '${widget.tracking.progressPercent}%',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _getAccentColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiveActivityColors.lightGray.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LiveActivityColors.lightGray.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getAccentColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: _getAccentColor(),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.tracking.statusDescription,
              style: const TextStyle(
                fontSize: 14,
                color: LiveActivityColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'التقدم',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: LiveActivityColors.textSecondary,
              ),
            ),
            Text(
              _getProgressLabel(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getAccentColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Progress Bar
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: LiveActivityColors.lightGray.withOpacity(0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * widget.tracking.progressPercentage,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getAccentColor(),
                          _getAccentColor().withOpacity(0.75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _getAccentColor().withOpacity(0.55),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  
                  // Shimmer
                  if (widget.tracking.isActive)
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        final progress = widget.tracking.progressPercentage;
                        return Positioned(
                          left: -80 + (constraints.maxWidth * progress + 80) * _shimmerController.value,
                          child: Container(
                            width: 80,
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        _buildProgressSteps(),
      ],
    );
  }

  Widget _buildProgressSteps() {
    final steps = [
      OrderTrackingStatus.orderPlaced,
      OrderTrackingStatus.preparing,
      OrderTrackingStatus.outForDelivery,
      OrderTrackingStatus.delivered,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = widget.tracking.status.isCompletedFor(status);
        final isCurrent = widget.tracking.status == status;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Column(
                children: [
                  Container(
                    width: isCurrent ? 12 : 8,
                    height: isCurrent ? 12 : 8,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? _getAccentColor()
                          : LiveActivityColors.mediumGray,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: _getAccentColor().withOpacity(0.7),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status.shortDescription,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCompleted || isCurrent
                          ? LiveActivityColors.textPrimary
                          : LiveActivityColors.mediumGray,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEstimatedTime() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LiveActivityColors.lightGray.withOpacity(0.2),
            LiveActivityColors.lightGray.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LiveActivityColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getAccentColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: _getAccentColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الوصول المتوقع',
                  style: TextStyle(
                    fontSize: 12,
                    color: LiveActivityColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.tracking.estimatedDeliveryTime!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LiveActivityColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LiveActivityColors.lightGray.withOpacity(0.2),
            LiveActivityColors.lightGray.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LiveActivityColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Driver Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getAccentColor().withOpacity(0.25),
                  _getAccentColor().withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _getAccentColor().withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: widget.tracking.driverImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.tracking.driverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person_rounded,
                        color: _getAccentColor(),
                        size: 26,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: _getAccentColor(),
                    size: 26,
                  ),
          ),
          const SizedBox(width: 14),

          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'السائق',
                  style: TextStyle(
                    fontSize: 12,
                    color: LiveActivityColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.tracking.driverName!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LiveActivityColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Call Button
          if (widget.tracking.driverPhone != null && widget.onCallDriver != null)
            _buildCallButton(),
        ],
      ),
    );
  }

  Widget _buildCallButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onCallDriver?.call();
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: TrackingColors.greenGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: LiveActivityColors.greenAccent.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.onTrackOrder == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTrackOrder?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getAccentColor(),
                _getAccentColor().withOpacity(0.85),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: _getAccentColor().withOpacity(0.4),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'تتبع الطلب',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods
  Color _getAccentColor() {
    switch (widget.tracking.status) {
      case OrderTrackingStatus.pending:
      case OrderTrackingStatus.confirmed:
        return LiveActivityColors.purpleAccent;
      case OrderTrackingStatus.preparing:
        return LiveActivityColors.yellowAccent;
      case OrderTrackingStatus.ready:
        return TrackingColors.ready;
      case OrderTrackingStatus.pickedUp:
        return TrackingColors.pickedUp;
      case OrderTrackingStatus.onTheWay:
        return LiveActivityColors.blueAccent;
      case OrderTrackingStatus.arrived:
        return TrackingColors.arrived;
      case OrderTrackingStatus.delivered:
        return LiveActivityColors.greenAccent;
      case OrderTrackingStatus.cancelled:
        return LiveActivityColors.redAccent;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.tracking.status) {
      case OrderTrackingStatus.pending:
        return Icons.pending_rounded;
      case OrderTrackingStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderTrackingStatus.preparing:
        return Icons.inventory_2_rounded;
      case OrderTrackingStatus.ready:
        return Icons.done_all_rounded;
      case OrderTrackingStatus.pickedUp:
        return Icons.local_shipping_rounded;
      case OrderTrackingStatus.onTheWay:
        return Icons.delivery_dining_rounded;
      case OrderTrackingStatus.arrived:
        return Icons.location_on_rounded;
      case OrderTrackingStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderTrackingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String _getProgressLabel() {
    switch (widget.tracking.status) {
      case OrderTrackingStatus.pending:
        return 'في انتظار التأكيد';
      case OrderTrackingStatus.confirmed:
        return 'تم تأكيد الطلب';
      case OrderTrackingStatus.preparing:
        return 'جاري التحضير الآن';
      case OrderTrackingStatus.ready:
        return 'جاهز للتسليم';
      case OrderTrackingStatus.pickedUp:
        return 'تم الاستلام';
      case OrderTrackingStatus.onTheWay:
        return 'في الطريق إليك';
      case OrderTrackingStatus.arrived:
        return 'وصل إلى موقعك';
      case OrderTrackingStatus.delivered:
        return 'تم التسليم بنجاح';
      case OrderTrackingStatus.cancelled:
        return 'تم الإلغاء';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔔 Live Tracking Compact Banner - Floating Version
// ═══════════════════════════════════════════════════════════════════════════
class LiveTrackingCompactBanner extends StatefulWidget {
  final OrderTrackingModel tracking;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const LiveTrackingCompactBanner({
    super.key,
    required this.tracking,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<LiveTrackingCompactBanner> createState() => _LiveTrackingCompactBannerState();
}

class _LiveTrackingCompactBannerState extends State<LiveTrackingCompactBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap?.call();
          },
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx.abs() > 200) {
              _dismiss();
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LiveActivityColors.cardBackground,
                  LiveActivityColors.darkBackground,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getAccentColor().withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getAccentColor().withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Status Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getAccentColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _getAccentColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getAccentColor(),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'طلب #${widget.tracking.orderReference}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: LiveActivityColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: _getAccentColor(),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getAccentColor().withOpacity(0.6),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.tracking.statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getAccentColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Progress Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getAccentColor(),
                        _getAccentColor().withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getAccentColor().withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${widget.tracking.progressPercent}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Dismiss Button
                if (widget.onDismiss != null) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _dismiss();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: LiveActivityColors.lightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: LiveActivityColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAccentColor() {
    switch (widget.tracking.status) {
      case OrderTrackingStatus.pending:
      case OrderTrackingStatus.confirmed:
        return LiveActivityColors.purpleAccent;
      case OrderTrackingStatus.preparing:
        return LiveActivityColors.yellowAccent;
      case OrderTrackingStatus.ready:
        return TrackingColors.ready;
      case OrderTrackingStatus.pickedUp:
        return TrackingColors.pickedUp;
      case OrderTrackingStatus.onTheWay:
        return LiveActivityColors.blueAccent;
      case OrderTrackingStatus.arrived:
        return TrackingColors.arrived;
      case OrderTrackingStatus.delivered:
        return LiveActivityColors.greenAccent;
      case OrderTrackingStatus.cancelled:
        return LiveActivityColors.redAccent;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.tracking.status) {
      case OrderTrackingStatus.pending:
        return Icons.pending_rounded;
      case OrderTrackingStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderTrackingStatus.preparing:
        return Icons.inventory_2_rounded;
      case OrderTrackingStatus.ready:
        return Icons.done_all_rounded;
      case OrderTrackingStatus.pickedUp:
        return Icons.local_shipping_rounded;
      case OrderTrackingStatus.onTheWay:
        return Icons.delivery_dining_rounded;
      case OrderTrackingStatus.arrived:
        return Icons.location_on_rounded;
      case OrderTrackingStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderTrackingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}