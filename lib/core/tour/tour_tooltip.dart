import 'package:flutter/material.dart';
import 'tour_step_model.dart';

/// ألوان الجولة
class TourColors {
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF1E293B);
  static const Color textDark = Color(0xFFF8FAFC);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}

/// Widget لعرض شرح الخطوة
class TourTooltip extends StatelessWidget {
  final TourStep step;
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onComplete;
  final TooltipPosition position;
  final Rect targetRect;
  final bool isDark;
  final double animationValue;

  const TourTooltip({
    super.key,
    required this.step,
    required this.currentIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onComplete,
    required this.position,
    required this.targetRect,
    required this.isDark,
    required this.animationValue,
  });

  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == totalSteps - 1;

  Color get _surfaceColor =>
      isDark ? TourColors.surfaceDark : TourColors.surfaceLight;
  Color get _textColor =>
      isDark ? TourColors.textDark : TourColors.textLight;
  Color get _textSecondary =>
      isDark ? TourColors.textSecondaryDark : TourColors.textSecondaryLight;
  Color get _accentColor =>
      step.accentColor ?? (isDark ? TourColors.primaryDark : TourColors.primaryLight);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: _getLeftPosition(context),
      top: _getTopPosition(context),
      right: _getRightPosition(context),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: animationValue,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: animationValue,
          alignment: _getAlignment(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 40,
            ),
            margin: const EdgeInsets.all(20),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: 16),

                    // Title & Description
                    _buildContent(),

                    const SizedBox(height: 20),

                    // Progress & Actions
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Step Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _accentColor,
                _accentColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            step.icon ?? Icons.info_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),

        const Spacer(),

        // Step Counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${currentIndex + 1} / $totalSteps',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _accentColor,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Close Button
        GestureDetector(
          onTap: onSkip,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.close_rounded,
              color: _textSecondary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          step.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textColor,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 8),

        // Description
        Text(
          step.description,
          style: TextStyle(
            fontSize: 15,
            color: _textSecondary,
            height: 1.6,
          ),
        ),

        // Custom Content
        if (step.customContent != null) ...[
          const SizedBox(height: 16),
          step.customContent!,
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Progress Bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: _textSecondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * ((currentIndex + 1) / totalSteps),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _accentColor,
                          _accentColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Action Buttons
        Row(
          children: [
            // Previous Button
            if (!isFirst)
              Expanded(
                child: _buildSecondaryButton(
                  text: 'السابق',
                  icon: Icons.arrow_back_rounded,
                  onTap: onPrevious,
                  iconFirst: true,
                ),
              )
            else
              Expanded(
                child: _buildSecondaryButton(
                  text: 'تخطي',
                  onTap: onSkip,
                ),
              ),

            const SizedBox(width: 12),

            // Next/Complete Button
            Expanded(
              flex: 2,
              child: _buildPrimaryButton(
                text: isLast ? 'إنهاء الجولة' : 'التالي',
                icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                onTap: isLast ? onComplete : onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _accentColor,
              _accentColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    bool iconFirst = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _textSecondary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconFirst && icon != null) ...[
              Icon(icon, color: _textSecondary, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!iconFirst && icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, color: _textSecondary, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  // Position Calculations
  double? _getLeftPosition(BuildContext context) {
    switch (position) {
      case TooltipPosition.right:
        return targetRect.right + 20;
      case TooltipPosition.left:
        return null;
      default:
        return 0;
    }
  }

  double? _getRightPosition(BuildContext context) {
    switch (position) {
      case TooltipPosition.left:
        return MediaQuery.of(context).size.width - targetRect.left + 20;
      case TooltipPosition.right:
        return null;
      default:
        return 0;
    }
  }

  double _getTopPosition(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final tooltipHeight = 400.0; // ارتفاع الـ Tooltip (أقل)
    
    // ✅ حساب المساحة المحجوزة في أسفل الشاشة
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final bottomNavHeight = kBottomNavigationBarHeight;
    final reservedBottomSpace = bottomPadding + bottomNavHeight + 120; // مسافة أقل = tooltip أعلى

    switch (position) {
      case TooltipPosition.top:
        return targetRect.top - tooltipHeight - 20;
      case TooltipPosition.bottom:
        // ✅ تأكد أن الـ Tooltip لن يتداخل مع Bottom Nav
        final proposedTop = targetRect.bottom + 20;
        final maxTop = screenHeight - reservedBottomSpace - tooltipHeight;
        return proposedTop > maxTop ? maxTop : proposedTop;
      case TooltipPosition.left:
      case TooltipPosition.right:
        // ✅ للعناصر على الجانب، تأكد من عدم النزول لأسفل الشاشة
        final centeredTop = targetRect.center.dy - tooltipHeight / 2;
        final maxTop = screenHeight - reservedBottomSpace - tooltipHeight;
        final minTop = 60.0; // مسافة من الأعلى
        return centeredTop.clamp(minTop, maxTop);
      case TooltipPosition.auto:
      default:
        // ✅ اختيار تلقائي محسّن
        final spaceBelow = screenHeight - targetRect.bottom - reservedBottomSpace;
        final spaceAbove = targetRect.top - 100; // مسافة آمنة من الأعلى
        
        if (spaceBelow >= tooltipHeight + 40) {
          // هناك مساحة كافية أسفل العنصر
          return targetRect.bottom + 20;
        } else if (spaceAbove >= tooltipHeight + 40) {
          // هناك مساحة كافية أعلى العنصر
          return targetRect.top - tooltipHeight - 20;
        } else {
          // لا يوجد مساحة كافية: اعرض في المنتصف
          final centeredTop = (screenHeight - tooltipHeight - reservedBottomSpace) / 2;
          return centeredTop.clamp(60.0, screenHeight - reservedBottomSpace - tooltipHeight);
        }
    }
  }

  Alignment _getAlignment() {
    switch (position) {
      case TooltipPosition.top:
        return Alignment.bottomCenter;
      case TooltipPosition.bottom:
        return Alignment.topCenter;
      case TooltipPosition.left:
        return Alignment.centerRight;
      case TooltipPosition.right:
        return Alignment.centerLeft;
      default:
        return Alignment.topCenter;
    }
  }
}
