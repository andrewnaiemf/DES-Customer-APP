import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_tour_service.dart';
import 'tour_step_model.dart';
import 'tour_spotlight.dart';
import 'tour_tooltip.dart';

/// Overlay Widget الرئيسي للجولة الإرشادية
class TourOverlay extends StatefulWidget {
  final Widget child;

  const TourOverlay({
    super.key,
    required this.child,
  });

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay>
    with TickerProviderStateMixin {
  final AppTourService _tourService = AppTourService.instance;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _tourService.addListener(_onTourChanged);
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _onTourChanged() {
    if (_tourService.isTourActive) {
      _fadeController.forward();
    } else {
      _fadeController.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tourService.removeListener(_onTourChanged);
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Rect? _getTargetRect(GlobalKey key) {
    try {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return null;

      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      return Rect.fromLTWH(
        position.dx,
        position.dy,
        size.width,
        size.height,
      );
    } catch (e) {
      return null;
    }
  }

  TooltipPosition _calculateBestPosition(Rect targetRect) {
    final screenSize = MediaQuery.of(context).size;
    final tooltipHeight = 280.0;
    final tooltipWidth = screenSize.width - 40;

    // Check available space
    final spaceAbove = targetRect.top;
    final spaceBelow = screenSize.height - targetRect.bottom;
    final spaceLeft = targetRect.left;
    final spaceRight = screenSize.width - targetRect.right;

    if (spaceBelow >= tooltipHeight + 40) {
      return TooltipPosition.bottom;
    } else if (spaceAbove >= tooltipHeight + 40) {
      return TooltipPosition.top;
    } else if (spaceRight >= tooltipWidth / 2 + 40) {
      return TooltipPosition.right;
    } else if (spaceLeft >= tooltipWidth / 2 + 40) {
      return TooltipPosition.left;
    }

    return TooltipPosition.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main App Content
        widget.child,

        // Tour Overlay
        if (_tourService.isTourActive && _tourService.currentStep != null)
          _buildTourOverlay(),
      ],
    );
  }

  Widget _buildTourOverlay() {
    final step = _tourService.currentStep!;
    final targetRect = _getTargetRect(step.targetKey);

    if (targetRect == null) {
      // Skip to next step if target not found
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tourService.nextStep();
      });
      return const SizedBox.shrink();
    }

    final tooltipPosition = step.tooltipPosition == TooltipPosition.auto
        ? _calculateBestPosition(targetRect)
        : step.tooltipPosition;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop with Spotlight
            GestureDetector(
              onTap: step.allowTargetTap ? null : () {},
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return TourSpotlight(
                    targetRect: targetRect,
                    step: step,
                    animationValue: _pulseAnimation.value,
                    isDark: _isDark,
                  );
                },
              ),
            ),

            // Target Tap Handler (if allowed)
            if (step.allowTargetTap)
              Positioned(
                left: targetRect.left,
                top: targetRect.top,
                width: targetRect.width,
                height: targetRect.height,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _tourService.nextStep();
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),

            // Tooltip
            TourTooltip(
              step: step,
              currentIndex: _tourService.currentStepIndex,
              totalSteps: _tourService.totalSteps,
              onNext: () {
                HapticFeedback.lightImpact();
                _tourService.nextStep();
              },
              onPrevious: () {
                HapticFeedback.lightImpact();
                _tourService.previousStep();
              },
              onSkip: () {
                HapticFeedback.mediumImpact();
                _tourService.skipTour();
              },
              onComplete: () {
                HapticFeedback.mediumImpact();
                _tourService.completeTour();
              },
              position: tooltipPosition,
              targetRect: targetRect,
              isDark: _isDark,
              animationValue: _fadeAnimation.value,
            ),
          ],
        );
      },
    );
  }
}
