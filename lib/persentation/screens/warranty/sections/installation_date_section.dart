import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_theme.dart';
import 'package:app/persentation/screens/warranty/warranty_strings.dart';
import 'package:app/persentation/widgets/custom_date_picker.dart';
import 'dart:ui' as ui;

// ═══════════════════════════════════════════════════════════════════════════
// 📅 Installation Date Section - Premium Design (Matching CustomerInfoSection)
// ═══════════════════════════════════════════════════════════════════════════
class InstallationDateSection extends StatefulWidget {
  final TextEditingController dateController;
  final bool isDark;

  const InstallationDateSection({
    super.key,
    required this.dateController,
    this.isDark = false,
  });

  @override
  State<InstallationDateSection> createState() =>
      _InstallationDateSectionState();
}

class _InstallationDateSectionState extends State<InstallationDateSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool get isDark => widget.isDark;
  bool _isDateFilled = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    widget.dateController.addListener(_updateFilledState);
    _updateFilledState();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  void _updateFilledState() {
    final filled = widget.dateController.text.isNotEmpty;
    if (filled != _isDateFilled) {
      setState(() => _isDateFilled = filled);
    }
  }

  @override
  void dispose() {
    widget.dateController.removeListener(_updateFilledState);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildSectionCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCard.withOpacity(0.95)
            : AppTheme.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppTheme.purple.withOpacity(0.2)
              : AppTheme.purple.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.purple)
                .withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: AppTheme.purple.withOpacity(0.06),
              blurRadius: 40,
              spreadRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ModernDateField(
                  controller: widget.dateController,
                  label: WarrantyStrings.installationDate,
                  hint: WarrantyStrings.selectInstallDate,
                  prefixIcon: Icons.event_rounded,
                  isDark: isDark,
                  isRequired: true,
                  iconColor: AppTheme.purple,
                  lastDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return WarrantyStrings.selectDate;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Header Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.purple.withOpacity(isDark ? 0.15 : 0.1),
            AppTheme.purple.withOpacity(isDark ? 0.05 : 0.03),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.purple.withOpacity(isDark ? 0.15 : 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          _buildIconContainer(),
          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WarrantyStrings.installationInfoTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getText(isDark),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  WarrantyStrings.selectInstallDate,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Progress Badge
          _buildProgressBadge(),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppTheme.purpleGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: AppTheme.white.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.calendar_month_rounded,
            color: AppTheme.white,
            size: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBadge() {
    final isComplete = _isDateFilled;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [
                  AppTheme.secondary.withOpacity(isDark ? 0.2 : 0.15),
                  AppTheme.secondary.withOpacity(isDark ? 0.1 : 0.08),
                ]
              : [
                  AppTheme.purple.withOpacity(isDark ? 0.15 : 0.1),
                  AppTheme.purple.withOpacity(isDark ? 0.08 : 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? AppTheme.secondary.withOpacity(0.3)
              : AppTheme.purple.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppTheme.secondary
                  : AppTheme.getTextSecondary(isDark).withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: isComplete
                  ? [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isComplete ? '1/1' : '0/1',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isComplete ? AppTheme.secondary : AppTheme.purple,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📅 Modern Date Field Widget - Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class ModernDateField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool isDark;
  final bool isRequired;
  final Color? iconColor;
  final bool showQuickOptions;
  final bool showRelativeDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? dateFormat;
  final String? displayFormat;
  final ValueChanged<DateTime>? onDateSelected;

  const ModernDateField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.isDark = false,
    this.isRequired = false,
    this.iconColor,
    this.showQuickOptions = true,
    this.showRelativeDate = true,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'yyyy-MM-dd',
    this.displayFormat = 'MMMM d, yyyy',
    this.validator,
    this.onDateSelected,
  });

  @override
  State<ModernDateField> createState() => _ModernDateFieldState();
}

class _ModernDateFieldState extends State<ModernDateField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDateSelected = false;
  bool _isFocused = false;

  Color get _activeColor => widget.iconColor ?? AppTheme.purple;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkDateSelected();
    widget.controller.addListener(_checkDateSelected);
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _checkDateSelected() {
    final hasDate = widget.controller.text.isNotEmpty;
    if (hasDate != _isDateSelected) {
      setState(() => _isDateSelected = hasDate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkDateSelected);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════════════════════════
              // 🏷️ Premium Label
              // ═══════════════════════════════════════════════════════════
              _buildLabel(),
              const SizedBox(height: 10),

              // ═══════════════════════════════════════════════════════════
              // 📅 Date Picker Field
              // ═══════════════════════════════════════════════════════════
              _buildDateField(),

              // ═══════════════════════════════════════════════════════════
              // ⚡ Quick Date Options
              // ═══════════════════════════════════════════════════════════
              if (widget.showQuickOptions) ...[
                const SizedBox(height: 16),
                _buildQuickDateOptions(),
              ],
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏷️ Label Builder
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          // Label Icon
          if (widget.prefixIcon != null) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isFocused
                    ? _activeColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                widget.prefixIcon,
                size: 16,
                color: _isFocused
                    ? _activeColor
                    : AppTheme.getTextSecondary(widget.isDark),
              ),
            ),
            const SizedBox(width: 6),
          ],

          // Label Text
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 14,
                fontWeight: _isFocused ? FontWeight.w700 : FontWeight.w600,
                color: _isFocused
                    ? _activeColor
                    : AppTheme.getText(widget.isDark),
                letterSpacing: 0.2,
              ),
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Required Indicator
          if (widget.isRequired) ...[
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _isFocused ? _activeColor : AppTheme.red,
              ),
            ),
          ],

          // Selected Indicator
          if (_isDateSelected) ...[
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Selected',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondary,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 📅 Date Field Builder
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDateField() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isFocused = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isFocused = false);
        _animationController.reverse();
        _selectDate(context);
      },
      onTapCancel: () {
        setState(() => _isFocused = false);
        _animationController.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // Primary Shadow
            BoxShadow(
              color: _isFocused
                  ? _activeColor.withOpacity(widget.isDark ? 0.3 : 0.15)
                  : (widget.isDark ? Colors.black : _activeColor)
                  .withOpacity(widget.isDark ? 0.2 : 0.04),
              blurRadius: _isFocused ? 16 : 10,
              spreadRadius: _isFocused ? 2 : 0,
              offset: const Offset(0, 4),
            ),
            // Secondary Glow
            if (_isFocused)
              BoxShadow(
                color: _activeColor.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: _isDateSelected
                ? LinearGradient(
              colors: [
                _activeColor.withOpacity(0.1),
                _activeColor.withOpacity(0.05),
              ],
            )
                : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isFocused
                  ? _activeColor
                  : _isDateSelected
                  ? _activeColor.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppTheme.darkCard.withOpacity(0.8)
                  : AppTheme.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isDark
                    ? AppTheme.primary.withOpacity(0.1)
                    : AppTheme.lightBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Calendar Icon
                _buildCalendarIcon(),
                const SizedBox(width: 14),

                // Date Text
                Expanded(child: _buildDateText()),

                // Status Icon
                _buildStatusIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _activeColor.withOpacity(widget.isDark ? 0.25 : 0.15),
            _activeColor.withOpacity(widget.isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: _activeColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [
          BoxShadow(
            color: _activeColor.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.prefixIcon ?? Icons.event_rounded,
        color: _activeColor,
        size: 22,
      ),
    );
  }

  Widget _buildDateText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 15,
            fontWeight: _isDateSelected ? FontWeight.w600 : FontWeight.w400,
            color: _isDateSelected
                ? AppTheme.getText(widget.isDark)
                : AppTheme.getTextSecondary(widget.isDark),
          ),
          child: Text(
            _isDateSelected
                ? _formatDisplayDate(widget.controller.text)
                : widget.hint ?? 'Select date',
          ),
        ),
        if (_isDateSelected && widget.showRelativeDate) ...[
          const SizedBox(height: 2),
          Text(
            _getRelativeDate(widget.controller.text),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _activeColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIcon() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: _isDateSelected
          ? Container(
        key: const ValueKey('check'),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.15),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: AppTheme.secondary,
          size: 16,
        ),
      )
          : Container(
        key: const ValueKey('arrow'),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _activeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _isFocused
              ? _activeColor
              : AppTheme.getTextSecondary(widget.isDark),
          size: 24,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⚡ Quick Date Options
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildQuickDateOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _activeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  size: 12,
                  color: _activeColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Quick Select',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextSecondary(widget.isDark),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        // Quick Options
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildQuickOption(
                label: 'Today',
                icon: Icons.today_rounded,
                date: DateTime.now(),
              ),
              const SizedBox(width: 10),
              _buildQuickOption(
                label: 'Yesterday',
                icon: Icons.history_rounded,
                date: DateTime.now().subtract(const Duration(days: 1)),
              ),
              const SizedBox(width: 10),
              _buildQuickOption(
                label: 'Last Week',
                icon: Icons.date_range_rounded,
                date: DateTime.now().subtract(const Duration(days: 7)),
              ),
              const SizedBox(width: 10),
              _buildQuickOption(
                label: 'Last Month',
                icon: Icons.calendar_month_rounded,
                date: DateTime.now().subtract(const Duration(days: 30)),
              ),
              const SizedBox(width: 10),
              _buildQuickOption(
                label: 'Custom',
                icon: Icons.edit_calendar_rounded,
                onTap: () => _selectDate(context),
                isCustom: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickOption({
    required String label,
    required IconData icon,
    DateTime? date,
    VoidCallback? onTap,
    bool isCustom = false,
  }) {
    final isSelected = date != null &&
        widget.controller.text ==
            DateFormat(widget.dateFormat).format(date);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap();
        } else if (date != null) {
          widget.controller.text = DateFormat(widget.dateFormat!).format(date);
          widget.onDateSelected?.call(date);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _activeColor,
              _activeColor.withOpacity(0.8),
            ],
          )
              : LinearGradient(
            colors: [
              (isCustom ? _activeColor : AppTheme.getSurface(widget.isDark))
                  .withOpacity(widget.isDark ? 0.15 : 0.8),
              (isCustom ? _activeColor : AppTheme.getSurface(widget.isDark))
                  .withOpacity(widget.isDark ? 0.08 : 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isCustom
                ? _activeColor.withOpacity(0.3)
                : AppTheme.getBorder(widget.isDark),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _activeColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: _activeColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppTheme.white
                  : isCustom
                  ? _activeColor
                  : AppTheme.getTextSecondary(widget.isDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.white
                    : isCustom
                    ? _activeColor
                    : AppTheme.getText(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📅 Date Selection Logic
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _selectDate(BuildContext context) async {
    HapticFeedback.lightImpact();

    final now = DateTime.now();
    DateTime initialDate = now;

    if (_isDateSelected) {
      try {
        initialDate = DateFormat(widget.dateFormat).parse(widget.controller.text);
      } catch (e) {
        initialDate = now;
      }
    }

    try {
      final picked = await CustomDatePicker.showBottomSheet(
        context: context,
        initialDate: initialDate,
        firstDate: widget.firstDate ?? DateTime(2000),
        lastDate: widget.lastDate ?? DateTime(2100),
        title: 'Select Installation Date',
        locale: const Locale('en', 'US'),
      );

      if (picked != null) {
        widget.controller.text = DateFormat(widget.dateFormat!).format(picked);
        widget.onDateSelected?.call(picked);
      }
    } catch (e) {
      // Fallback to default date picker
      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: widget.firstDate ?? DateTime(2000),
        lastDate: widget.lastDate ?? DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: _activeColor,
                onPrimary: AppTheme.white,
                surface: widget.isDark ? AppTheme.darkCard : AppTheme.white,
                onSurface: AppTheme.getText(widget.isDark),
              ),
              dialogBackgroundColor:
              widget.isDark ? AppTheme.darkCard : AppTheme.white,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        widget.controller.text = DateFormat(widget.dateFormat!).format(picked);
        widget.onDateSelected?.call(picked);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 Helper Methods
  // ═══════════════════════════════════════════════════════════════════════════
  String _formatDisplayDate(String dateStr) {
    try {
      final date = DateFormat(widget.dateFormat).parse(dateStr);
      return DateFormat(widget.displayFormat).format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getRelativeDate(String dateStr) {
    try {
      final date = DateFormat(widget.dateFormat).parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final difference = today.difference(dateOnly).inDays;

      if (difference == 0) return '📍 Today';
      if (difference == 1) return '⏪ Yesterday';
      if (difference == -1) return '⏩ Tomorrow';
      if (difference > 0) {
        if (difference < 7) return '📅 $difference days ago';
        if (difference < 30) return '📅 ${(difference / 7).floor()} weeks ago';
        if (difference < 365) return '📅 ${(difference / 30).floor()} months ago';
        return '📅 ${(difference / 365).floor()} years ago';
      } else {
        final absDiff = difference.abs();
        if (absDiff < 7) return '📅 In $absDiff days';
        if (absDiff < 30) return '📅 In ${(absDiff / 7).floor()} weeks';
        if (absDiff < 365) return '📅 In ${(absDiff / 30).floor()} months';
        return '📅 In ${(absDiff / 365).floor()} years';
      }
    } catch (e) {
      return '';
    }
  }
}