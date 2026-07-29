import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Colors
// ═══════════════════════════════════════════════════════════════════════════
class AppColors {
  // Light Mode
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Mode
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Brand Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color accent = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF34D399)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFF87171)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Modern Button - Primary Design
// ═══════════════════════════════════════════════════════════════════════════
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? suffixIcon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.suffixIcon,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _loadingController;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: _isEnabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        width: widget.isFullWidth ? double.infinity : null,
        height: _getHeight(),
        padding: widget.padding ?? _getPadding(),
        decoration: _buildDecoration(),
        child: Center(
          child: widget.isLoading ? _buildLoadingIndicator() : _buildContent(),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (widget.type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: _isEnabled
              ? (widget.gradient ?? AppColors.primaryGradient)
              : null,
          color: _isEnabled ? null : AppColors.lightTextSecondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        );

      case ButtonType.secondary:
        return BoxDecoration(
          color: widget.backgroundColor ??
              (_isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          border: Border.all(
            color: _isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case ButtonType.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          border: Border.all(
            color: _isEnabled
                ? AppColors.primary
                : AppColors.lightTextSecondary.withOpacity(0.3),
            width: 2,
          ),
        );

      case ButtonType.ghost:
        return BoxDecoration(
          color: _isPressed
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
        );

      case ButtonType.danger:
        return BoxDecoration(
          gradient: _isEnabled ? AppColors.dangerGradient : null,
          color: _isEnabled ? null : AppColors.error.withOpacity(0.3),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        );

      case ButtonType.success:
        return BoxDecoration(
          gradient: _isEnabled ? AppColors.successGradient : null,
          color: _isEnabled ? null : AppColors.accent.withOpacity(0.3),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        );

      case ButtonType.dark:
        return BoxDecoration(
          gradient: _isEnabled ? AppColors.darkGradient : null,
          color: _isEnabled ? null : AppColors.darkCard.withOpacity(0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        );
    }
  }

  Widget _buildContent() {
    final textColor = _getTextColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: _getIconSize()),
          const SizedBox(width: 10),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: textColor,
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: 10),
          Icon(widget.suffixIcon, color: textColor, size: _getIconSize()),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _getLoadingSize(),
          height: _getLoadingSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'جاري التحميل...',
          style: TextStyle(
            color: _getTextColor(),
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getTextColor() {
    if (!_isEnabled) {
      return AppColors.lightTextSecondary.withOpacity(0.5);
    }

    if (widget.textColor != null) return widget.textColor!;

    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.danger:
      case ButtonType.success:
      case ButtonType.dark:
        return Colors.white;
      case ButtonType.secondary:
        return _isDark ? AppColors.darkText : AppColors.lightText;
      case ButtonType.outlined:
      case ButtonType.ghost:
        return AppColors.primary;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 52;
      case ButtonSize.large:
        return 60;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 13;
      case ButtonSize.medium:
        return 15;
      case ButtonSize.large:
        return 17;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

enum ButtonType { primary, secondary, outlined, ghost, danger, success, dark }

enum ButtonSize { small, medium, large }

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Icon Button Modern
// ═══════════════════════════════════════════════════════════════════════════
class ModernIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showShadow;
  final Gradient? gradient;
  final bool showBorder;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
    this.showShadow = true,
    this.gradient,
    this.showBorder = true,
  });

  @override
  State<ModernIconButton> createState() => _ModernIconButtonState();
}

class _ModernIconButtonState extends State<ModernIconButton> {
  bool _isPressed = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.92 : 1.0),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: widget.gradient,
          color: widget.gradient == null
              ? (widget.backgroundColor ??
                  (_isDark ? AppColors.darkCard : Colors.white))
              : null,
          borderRadius: BorderRadius.circular(widget.size * 0.3),
          border: widget.showBorder && widget.gradient == null
              ? Border.all(
                  color: _isDark ? AppColors.darkBorder : AppColors.lightBorder,
                )
              : null,
          boxShadow: widget.showShadow
              ? [
                  BoxShadow(
                    color: widget.gradient != null
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.black.withOpacity(_isDark ? 0.2 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor ??
              (widget.gradient != null
                  ? Colors.white
                  : (_isDark ? AppColors.darkText : AppColors.lightText)),
          size: widget.size * 0.45,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Text Button Modern
// ═══════════════════════════════════════════════════════════════════════════
class ModernTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;

  const ModernTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed?.call();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: buttonColor, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: buttonColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Floating Action Button Modern
// ═══════════════════════════════════════════════════════════════════════════
class ModernFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Gradient? gradient;
  final bool mini;

  const ModernFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.gradient,
    this.mini = false,
  });

  @override
  State<ModernFAB> createState() => _ModernFABState();
}

class _ModernFABState extends State<ModernFAB> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.mini ? 48.0 : 60.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.92 : 1.0),
        height: size,
        padding: widget.label != null
            ? const EdgeInsets.symmetric(horizontal: 20)
            : null,
        constraints: widget.label == null
            ? BoxConstraints(minWidth: size, maxWidth: size)
            : null,
        decoration: BoxDecoration(
          gradient: widget.gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: Colors.white,
              size: widget.mini ? 22 : 26,
            ),
            if (widget.label != null) ...[
              const SizedBox(width: 10),
              Text(
                widget.label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📭 Modern Empty State
// ═══════════════════════════════════════════════════════════════════════════
class ModernEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? svgPath;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final double iconSize;
  final EmptyStateStyle style;

  const ModernEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.svgPath,
    this.actionText,
    this.onAction,
    this.actionIcon,
    this.iconSize = 80,
    this.style = EmptyStateStyle.normal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Image Container
            _buildIconContainer(isDark),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ModernButton(
                text: actionText!,
                onPressed: onAction,
                icon: actionIcon,
                isFullWidth: false,
                size: ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(bool isDark) {
    switch (style) {
      case EmptyStateStyle.normal:
        return _buildNormalStyle(isDark);
      case EmptyStateStyle.gradient:
        return _buildGradientStyle(isDark);
      case EmptyStateStyle.minimal:
        return _buildMinimalStyle(isDark);
      case EmptyStateStyle.illustrated:
        return _buildIllustratedStyle(isDark);
    }
  }

  Widget _buildNormalStyle(bool isDark) {
    return Container(
      width: iconSize + 40,
      height: iconSize + 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: _buildIconContent(
            isDark,
            AppColors.primary,
            iconSize * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientStyle(bool isDark) {
    return Container(
      width: iconSize + 20,
      height: iconSize + 20,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildIconContent(isDark, Colors.white, iconSize * 0.5),
    );
  }

  Widget _buildMinimalStyle(bool isDark) {
    return _buildIconContent(
      isDark,
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      iconSize,
    );
  }

  Widget _buildIllustratedStyle(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circles
        ...List.generate(3, (index) {
          final size = iconSize + (index * 30);
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1 - (index * 0.03)),
                width: 2,
              ),
            ),
          );
        }),
        // Icon
        Container(
          width: iconSize - 20,
          height: iconSize - 20,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 20,
              ),
            ],
          ),
          child: _buildIconContent(
            isDark,
            AppColors.primary,
            (iconSize - 20) * 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIconContent(bool isDark, Color color, double size) {
    if (svgPath != null) {
      return Center(
        child: SvgPicture.asset(
          svgPath!,
          width: size,
          height: size,
          // ignore: deprecated_member_use
          color: color,
        ),
      );
    }

    return Center(
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: size,
        color: color,
      ),
    );
  }
}

enum EmptyStateStyle { normal, gradient, minimal, illustrated }

// ═══════════════════════════════════════════════════════════════════════════
// 📭 Empty List Widget (Compatible with old code)
// ═══════════════════════════════════════════════════════════════════════════
class EmptyList extends StatelessWidget {
  final String title;
  final String icon;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyList({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ModernEmptyState(
      title: 'لا يوجد $title جديدة',
      subtitle: subtitle,
      svgPath: icon,
      actionText: actionText,
      onAction: onAction,
      style: EmptyStateStyle.normal,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔄 Loading Button (Compatible with old CustomButtonLoading)
// ═══════════════════════════════════════════════════════════════════════════
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadiusGeometry? borderRadius;
  final bool isLoading;
  final Gradient? gradient;
  final double? elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.isLoading = false,
    this.gradient,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ModernButton(
        text: text,
        onPressed: isLoading ? null : onPressed,
        isLoading: isLoading,
        type: gradient != null ? ButtonType.primary : ButtonType.dark,
        gradient: gradient,
        textColor: textColor,
        borderRadius: (borderRadius as BorderRadius?)?.topLeft.x,
      ),
    );
  }
}

class CustomButtonLoading extends StatelessWidget {
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  const CustomButtonLoading({
    super.key,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ModernButton(
        text: '',
        onPressed: null,
        isLoading: true,
        type: ButtonType.dark,
        borderRadius: (borderRadius as BorderRadius?)?.topLeft.x,
      ),
    );
  }
}
