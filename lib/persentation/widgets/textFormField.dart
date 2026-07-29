import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme Colors - Brand Identity
// ═══════════════════════════════════════════════════════════════════════════
class AppBrandColors {
  // Primary Colors
  static const Color yellow = Color.fromRGBO(217, 179, 29, 1.0);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;

  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B5CF6)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, Color(0xFF34D399)],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 Custom Text Form Field - Modern, Professional & Theme-Aware
// ═══════════════════════════════════════════════════════════════════════════
class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.text,
    required this.controller,
    this.textColor,
    this.keyboardType,
    this.isPassword,
    this.color,
    this.isFilld,
    this.enabled,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines,
    this.borderRadius,
    this.validator,
    this.fontFamily,
    this.borderColor,
    this.onChanged,
    this.scrollPadding,
    this.borderSide,
    this.contentPadding,
    this.fontSize,
    this.hintColor,
    this.focusedBorderColor,
    this.label,
    this.helperText,
    this.showPasswordToggle,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus,
    this.readOnly,
    this.onTap,
    this.focusNode,
    this.inputFormatters,
    this.maxLength,
    this.counterText,
    this.enableInteractiveSelection,
    this.showClearButton,
    this.floatingLabel,
    this.prefixText,
    this.suffixText,
    this.textAlign,
    this.textCapitalization,
    this.obscuringCharacter,
    this.autovalidateMode,
    this.expands,
    this.minLines,
  });

  // Required
  final String text;
  final TextEditingController controller;

  // Styling
  final Color? textColor;
  final Color? color;
  final Color? hintColor;
  final Color? focusedBorderColor;
  final Color? borderColor;
  final double? fontSize;
  final String? fontFamily;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final EdgeInsets? contentPadding;
  final EdgeInsets? scrollPadding;

  // Behavior
  final TextInputType? keyboardType;
  final bool? isPassword;
  final bool? isFilld;
  final bool? enabled;
  final bool? readOnly;
  final bool? autofocus;
  final bool? showPasswordToggle;
  final bool? showClearButton;
  final bool? floatingLabel;
  final bool? enableInteractiveSelection;
  final bool? expands;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextAlign? textAlign;
  final TextCapitalization? textCapitalization;
  final String? obscuringCharacter;
  final AutovalidateMode? autovalidateMode;

  // Icons & Labels
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? label;
  final String? helperText;
  final String? counterText;
  final String? prefixText;
  final String? suffixText;

  // Callbacks
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 📊 State Variables
  // ─────────────────────────────────────────────────────────────────────────
  late bool _obscureText;
  bool _isFocused = false;
  bool _hasError = false;
  bool _isHovered = false;
  String? _errorText;
  late FocusNode _focusNode;

  // Theme Helper
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 Animation Controller
  // ─────────────────────────────────────────────────────────────────────────
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword ?? false;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Theme-Aware Color Getters
  // ─────────────────────────────────────────────────────────────────────────
  Color get _backgroundColor {
    if (!(widget.enabled ?? true)) {
      return _isDark
          ? AppBrandColors.dark.withOpacity(0.5)
          : AppBrandColors.lightGray.withOpacity(0.5);
    }
    if (widget.color != null) return widget.color!;
    return _isDark ? AppBrandColors.dark : AppBrandColors.white;
  }

  Color get _textColor {
    if (widget.textColor != null) return widget.textColor!;
    return _isDark ? Colors.white : AppBrandColors.black;
  }

  Color get _hintColor {
    if (widget.hintColor != null) return widget.hintColor!;
    return _isDark
        ? AppBrandColors.darkGray.withOpacity(0.7)
        : AppBrandColors.darkGray;
  }

  Color get _labelColor {
    if (_hasError) return AppBrandColors.error;
    if (_isFocused) {
      return widget.focusedBorderColor ??
          (_isDark ? AppBrandColors.lightGreen : AppBrandColors.purple);
    }
    return _isDark ? Colors.white : AppBrandColors.dark;
  }

  Color get _borderColor {
    if (_hasError) return AppBrandColors.error;
    if (_isFocused) {
      return widget.focusedBorderColor ??
          (_isDark ? AppBrandColors.lightGreen : AppBrandColors.purple);
    }
    if (_isHovered) {
      return _isDark
          ? Colors.white.withOpacity(0.3)
          : AppBrandColors.darkGray.withOpacity(0.8);
    }
    return widget.borderColor ??
        (_isDark
            ? Colors.white.withOpacity(0.12)
            : AppBrandColors.darkGray.withOpacity(0.4));
  }

  Color get _iconColor {
    if (_isFocused) {
      return _isDark ? AppBrandColors.lightGreen : AppBrandColors.purple;
    }
    return _isDark ? AppBrandColors.darkGray : Colors.grey;
  }

  Color get _cursorColor {
    return widget.focusedBorderColor ??
        (_isDark ? AppBrandColors.lightGreen : AppBrandColors.purple);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏗️ Build Method
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label (if provided and not floating)
            if (widget.label != null && widget.floatingLabel != true)
              _buildLabel(),

            // Text Field Container with Shadow
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                boxShadow: _buildBoxShadow(),
              ),
              child: _buildTextField(),
            ),

            // Helper/Error Text
            if (widget.helperText != null || _errorText != null)
              _buildHelperText(),
          ],
        ),
      ),
    );
  }

  List<BoxShadow> _buildBoxShadow() {
    if (_isFocused) {
      final focusColor = widget.focusedBorderColor ??
          (_isDark ? AppBrandColors.lightGreen : AppBrandColors.purple);
      return [
        BoxShadow(
          color: focusColor.withOpacity(_isDark ? 0.25 : 0.15),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
      ];
    }
    if (_hasError) {
      return [
        BoxShadow(
          color: AppBrandColors.error.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    if (_isHovered) {
      return [
        BoxShadow(
          color: _isDark
              ? Colors.black.withOpacity(0.3)
              : AppBrandColors.dark.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: _isDark
            ? Colors.black.withOpacity(0.2)
            : AppBrandColors.dark.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏷️ Label Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _labelColor,
              fontFamily: widget.fontFamily,
              letterSpacing: 0.3,
            ),
            child: Text(widget.label!),
          ),
          if (widget.validator != null) ...[
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: AppBrandColors.error,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Text Field Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTextField() {
    final defaultBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(16);

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      validator: _handleValidation,
      onChanged: _handleChange,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled ?? true,
      readOnly: widget.readOnly ?? false,
      onTap: widget.onTap,
      autofocus: widget.autofocus ?? false,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      enableInteractiveSelection: widget.enableInteractiveSelection ?? true,
      scrollPadding: widget.scrollPadding ?? const EdgeInsets.all(20),
      textAlign: widget.textAlign ?? TextAlign.start,
      textCapitalization:
      widget.textCapitalization ?? TextCapitalization.none,
      autovalidateMode:
      widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      expands: widget.expands ?? false,
      minLines: widget.minLines,
      style: TextStyle(
        color: _textColor,
        fontFamily: widget.fontFamily,
        fontSize: widget.fontSize ?? 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      maxLines: widget.isPassword == true ? 1 : (widget.maxLines ?? 1),
      obscureText: _obscureText,
      obscuringCharacter: widget.obscuringCharacter ?? '●',
      keyboardType: widget.keyboardType,
      cursorColor: _cursorColor,
      cursorWidth: 2.5,
      cursorRadius: const Radius.circular(2),
      decoration: _buildDecoration(defaultBorderRadius),
    );
  }

  String? _handleValidation(String? value) {
    final error = widget.validator?.call(value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _hasError = error != null;
          _errorText = error;
        });
      }
    });
    return error;
  }

  void _handleChange(String value) {
    widget.onChanged?.call(value);
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorText = null;
      });
    }
    setState(() {}); // Refresh for clear button
  }

  InputDecoration _buildDecoration(BorderRadius borderRadius) {
    return InputDecoration(
      // Error Style
      errorStyle: const TextStyle(
        color: AppBrandColors.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 0.01, // Hide default error text
      ),
      errorMaxLines: 1,

      // Fill
      filled: widget.isFilld ?? true,
      fillColor: _backgroundColor,

      // Hint & Label
      hintText: widget.text,
      hintStyle: TextStyle(
        fontFamily: widget.fontFamily,
        color: _hintColor,
        fontSize: (widget.fontSize ?? 15) - 0.5,
        fontWeight: FontWeight.w400,
      ),
      labelText: widget.floatingLabel == true ? widget.label : null,
      labelStyle: TextStyle(
        fontFamily: widget.fontFamily,
        color: _labelColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: widget.fontFamily,
        color: _labelColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelBehavior: widget.floatingLabel == true
          ? FloatingLabelBehavior.auto
          : FloatingLabelBehavior.never,

      // Counter
      counterText: widget.counterText ?? '',
      counterStyle: TextStyle(
        color: _isDark ? AppBrandColors.darkGray : Colors.grey[600],
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),

      // Prefix & Suffix
      prefixIcon: _buildPrefixIcon(),
      suffixIcon: _buildSuffixIcon(),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      prefixStyle: TextStyle(
        color: _textColor,
        fontSize: widget.fontSize ?? 15,
        fontWeight: FontWeight.w500,
      ),
      suffixStyle: TextStyle(
        color: _hintColor,
        fontSize: widget.fontSize ?? 15,
        fontWeight: FontWeight.w500,
      ),

      // Padding
      contentPadding: widget.contentPadding ??
          const EdgeInsets.symmetric(vertical: 18, horizontal: 20),

      // Borders
      border: _buildBorder(borderRadius, _borderColor),
      focusedBorder: _buildBorder(borderRadius, _borderColor, width: 2),
      enabledBorder: _buildBorder(borderRadius, _borderColor),
      errorBorder: _buildBorder(borderRadius, AppBrandColors.error, width: 1.5),
      focusedErrorBorder:
      _buildBorder(borderRadius, AppBrandColors.error, width: 2),
      disabledBorder: _buildBorder(
        borderRadius,
        _isDark
            ? Colors.white.withOpacity(0.05)
            : AppBrandColors.darkGray.withOpacity(0.2),
      ),
    );
  }

  OutlineInputBorder _buildBorder(
      BorderRadius radius,
      Color color, {
        double width = 1.5,
      }) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: widget.borderSide ?? BorderSide(color: color, width: width),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔘 Prefix Icon Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon == null) return null;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: IconTheme(
          key: ValueKey(_isFocused),
          data: IconThemeData(
            color: _iconColor,
            size: 22,
          ),
          child: widget.prefixIcon!,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔘 Suffix Icon Widget
  // ───────────────────────────────────────────────────────────────────────���─
  Widget? _buildSuffixIcon() {
    List<Widget> icons = [];

    // Clear Button
    bool showClear = widget.showClearButton == true ||
        (_isFocused && widget.controller.text.isNotEmpty);
    if (showClear && widget.controller.text.isNotEmpty) {
      icons.add(_buildClearButton());
    }

    // Password Toggle
    if (widget.isPassword == true || widget.showPasswordToggle == true) {
      icons.add(_buildPasswordToggle());
    }

    // Custom Suffix Icon
    if (widget.suffixIcon != null) {
      icons.add(Padding(
        padding: const EdgeInsets.only(right: 4),
        child: IconTheme(
          data: IconThemeData(color: _iconColor, size: 22),
          child: widget.suffixIcon!,
        ),
      ));
    }

    if (icons.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  Widget _buildPasswordToggle() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              _obscureText
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              key: ValueKey(_obscureText),
              color: _isFocused
                  ? (_isDark
                  ? AppBrandColors.lightGreen
                  : AppBrandColors.purple)
                  : _iconColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.controller.clear();
          widget.onChanged?.call('');
          setState(() {});
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.15)
                  : AppBrandColors.darkGray.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: _isDark
                  ? Colors.white.withOpacity(0.8)
                  : AppBrandColors.dark.withOpacity(0.6),
              size: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 💡 Helper/Error Text Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHelperText() {
    final hasError = _errorText != null;
    final text = _errorText ?? widget.helperText ?? '';

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: text.isNotEmpty ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: hasError
                    ? Icon(
                  Icons.error_outline_rounded,
                  key: const ValueKey('error'),
                  size: 16,
                  color: AppBrandColors.error,
                )
                    : Icon(
                  Icons.info_outline_rounded,
                  key: const ValueKey('info'),
                  size: 16,
                  color: _isDark
                      ? AppBrandColors.darkGray
                      : Colors.grey[500],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    color: hasError
                        ? AppBrandColors.error
                        : (_isDark
                        ? AppBrandColors.darkGray
                        : Colors.grey[600]),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  child: Text(text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Animated Builder Helper
// ═══════════════════════════════════════════════════════════════════════════
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔐 Password Strength Indicator - Enhanced Version
// ═══════════════════════════════════════════════════════════════════════════
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showLabel;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strength = _calculateStrength();
    final strengthInfo = _getStrengthInfo(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : AppBrandColors.lightGray,
          ),
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: index < strength
                        ? LinearGradient(
                      colors: [
                        strengthInfo.color,
                        strengthInfo.color.withOpacity(0.8),
                      ],
                    )
                        : null,
                    boxShadow: index < strength
                        ? [
                      BoxShadow(
                        color: strengthInfo.color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),

        // Label
        if (showLabel && password.isNotEmpty) ...[
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Row(
              key: ValueKey(strength),
              children: [
                Icon(
                  strengthInfo.icon,
                  size: 14,
                  color: strengthInfo.color,
                ),
                const SizedBox(width: 6),
                Text(
                  strengthInfo.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: strengthInfo.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  int _calculateStrength() {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength.clamp(0, 4);
  }

  _StrengthInfo _getStrengthInfo(int strength) {
    switch (strength) {
      case 1:
        return _StrengthInfo(
          label: 'Weak',
          color: AppBrandColors.error,
          icon: Icons.warning_rounded,
        );
      case 2:
        return _StrengthInfo(
          label: 'Fair',
          color: AppBrandColors.warning,
          icon: Icons.info_rounded,
        );
      case 3:
        return _StrengthInfo(
          label: 'Good',
          color: AppBrandColors.info,
          icon: Icons.check_circle_outline_rounded,
        );
      case 4:
        return _StrengthInfo(
          label: 'Strong',
          color: AppBrandColors.success,
          icon: Icons.verified_rounded,
        );
      default:
        return _StrengthInfo(
          label: 'Too Short',
          color: AppBrandColors.darkGray,
          icon: Icons.remove_circle_outline_rounded,
        );
    }
  }
}

class _StrengthInfo {
  final String label;
  final Color color;
  final IconData icon;

  _StrengthInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔍 Search Text Field - Specialized Widget
// ═══════════════════════════════════════════════════════════════════════════
class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const SearchTextField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomTextFormField(
      text: hintText,
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      showClearButton: true,
      borderRadius: BorderRadius.circular(28),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      prefixIcon: const Icon(Icons.search_rounded),
      color: isDark ? AppBrandColors.dark : Colors.white,
      focusedBorderColor:
      isDark ? AppBrandColors.lightGreen : AppBrandColors.purple,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 💳 OTP Text Field - Specialized Widget
// ═══════════════════════════════════════════════════════════════════════════
class OTPTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function(String)? onCompleted;
  final int length;

  const OTPTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onCompleted,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomTextFormField(
      text: '',
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      fontSize: 24,
      maxLength: length,
      showClearButton: false,
      borderRadius: BorderRadius.circular(16),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      onChanged: (value) {
        onChanged?.call(value);
        if (value.length == length) {
          onCompleted?.call(value);
        }
      },
      color: isDark ? AppBrandColors.dark : Colors.white,
      focusedBorderColor:
      isDark ? AppBrandColors.lightGreen : AppBrandColors.purple,
    );
  }
}