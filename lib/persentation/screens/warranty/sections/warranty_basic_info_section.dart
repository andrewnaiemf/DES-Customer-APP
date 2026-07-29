import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_exports.dart';
import 'dart:ui' as ui;

// ═══════════════════════════════════════════════════════════════════════════
// 🛡️ Warranty Basic Info Section - Premium Design (Matching CustomerInfoSection)
// ═══════════════════════════════════════════════════════════════════════════
// Used in multi-entry screen for just Warranty Code + Serial Number
// ═══════════════════════════════════════════════════════════════════════════

class WarrantyBasicInfoSection extends StatefulWidget {
  final TextEditingController codeController;
  final TextEditingController serialController;
  final bool isDark;

  const WarrantyBasicInfoSection({
    super.key,
    required this.codeController,
    required this.serialController,
    this.isDark = false,
  });

  @override
  State<WarrantyBasicInfoSection> createState() =>
      _WarrantyBasicInfoSectionState();
}

class _WarrantyBasicInfoSectionState extends State<WarrantyBasicInfoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool get isDark => widget.isDark;
  int _filledFieldsCount = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupListeners();
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

  void _setupListeners() {
    widget.codeController.addListener(_updateFilledCount);
    widget.serialController.addListener(_updateFilledCount);
    _updateFilledCount();
  }

  void _updateFilledCount() {
    int count = 0;
    if (widget.codeController.text.isNotEmpty) count++;
    if (widget.serialController.text.isNotEmpty) count++;

    if (count != _filledFieldsCount) {
      setState(() => _filledFieldsCount = count);
    }
  }

  @override
  void dispose() {
    widget.codeController.removeListener(_updateFilledCount);
    widget.serialController.removeListener(_updateFilledCount);
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
              ? AppTheme.secondary.withOpacity(0.2)
              : AppTheme.secondary.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.secondary)
                .withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: AppTheme.secondary.withOpacity(0.06),
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
                child: Column(
                  children: [
                    // Warranty Code
                    _buildTextField(
                      controller: widget.codeController,
                      label: 'Warranty Code',
                      hint: 'Enter warranty code',
                      icon: Icons.qr_code_rounded,
                      iconColor: AppTheme.secondary,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Serial Number
                    _buildTextField(
                      controller: widget.serialController,
                      label: 'Serial Number',
                      hint: 'Enter serial number',
                      icon: Icons.confirmation_number_rounded,
                      iconColor: AppTheme.secondary,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ],
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
            AppTheme.secondary.withOpacity(isDark ? 0.15 : 0.1),
            AppTheme.secondary.withOpacity(isDark ? 0.05 : 0.03),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.secondary.withOpacity(isDark ? 0.15 : 0.2),
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
                  'Warranty Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getText(isDark),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Warranty code & serial number',
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondary,
            AppTheme.secondaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withOpacity(0.4),
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
            Icons.shield_rounded,
            color: AppTheme.white,
            size: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBadge() {
    final isComplete = _filledFieldsCount == 2;

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
                  AppTheme.secondary.withOpacity(isDark ? 0.15 : 0.1),
                  AppTheme.secondary.withOpacity(isDark ? 0.08 : 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress dots
          ...List.generate(2, (index) {
            final isFilled = index < _filledFieldsCount;
            return Container(
              width: 6,
              height: 6,
              margin: EdgeInsets.only(right: index < 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: isFilled
                    ? AppTheme.secondary
                    : AppTheme.getTextSecondary(isDark).withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: AppTheme.secondary.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            );
          }),
          const SizedBox(width: 8),
          Text(
            '$_filledFieldsCount/2',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isComplete
                  ? AppTheme.secondary
                  : AppTheme.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Text Field Builder
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondary(isDark),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.red,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Text Field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.getText(isDark),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.getTextSecondary(isDark).withOpacity(0.5),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withOpacity(isDark ? 0.2 : 0.15),
                    iconColor.withOpacity(isDark ? 0.1 : 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: isDark
                ? AppTheme.darkSurface.withOpacity(0.5)
                : AppTheme.lightGray.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.getBorder(isDark),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.secondary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.red.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
