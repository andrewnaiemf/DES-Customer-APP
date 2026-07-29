import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/business_logic/auth/CheckPhoneCubit/check_phone_cubit.dart';
import 'package:app/functions/country_code_sheet.dart';
import 'package:app/persentation/screens/warranty/warranty_strings.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_exports.dart';
import 'dart:ui' as ui;

// ═══════════════════════════════════════════════════════════════════════════
// 👤 Customer Information Section - Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class CustomerInfoSection extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool isDark;

  const CustomerInfoSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    this.isDark = false,
  });

  @override
  State<CustomerInfoSection> createState() => _CustomerInfoSectionState();
}

class _CustomerInfoSectionState extends State<CustomerInfoSection>
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
    widget.firstNameController.addListener(_updateFilledCount);
    widget.lastNameController.addListener(_updateFilledCount);
    widget.emailController.addListener(_updateFilledCount);
    widget.phoneController.addListener(_updateFilledCount);
    _updateFilledCount();
  }

  void _updateFilledCount() {
    int count = 0;
    if (widget.firstNameController.text.isNotEmpty) count++;
    if (widget.lastNameController.text.isNotEmpty) count++;
    if (widget.emailController.text.isNotEmpty) count++;
    if (widget.phoneController.text.isNotEmpty) count++;

    if (count != _filledFieldsCount) {
      setState(() => _filledFieldsCount = count);
    }
  }

  @override
  void dispose() {
    widget.firstNameController.removeListener(_updateFilledCount);
    widget.lastNameController.removeListener(_updateFilledCount);
    widget.emailController.removeListener(_updateFilledCount);
    widget.phoneController.removeListener(_updateFilledCount);
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
              ? AppTheme.blue.withOpacity(0.2)
              : AppTheme.blue.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.blue)
                .withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: AppTheme.blue.withOpacity(0.06),
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
                    // Name Row (First & Last)
                    _buildNameRow(),
                    const SizedBox(height: 20),

                    // Email
                    _buildTextField(
                      controller: widget.emailController,
                      label: WarrantyStrings.emailAddress,
                      hint: WarrantyStrings.enterEmail,
                      icon: Icons.email_rounded,
                      iconColor: AppTheme.cyan,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [EnglishOnlyInputFormatter()],
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number with Country Code
                    _buildPhoneField(context),
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
            AppTheme.blue.withOpacity(isDark ? 0.15 : 0.1),
            AppTheme.blue.withOpacity(isDark ? 0.05 : 0.03),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.blue.withOpacity(isDark ? 0.15 : 0.2),
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
                  WarrantyStrings.customerInfoTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getText(isDark),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer contact information',
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
        gradient: AppTheme.blueGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blue.withOpacity(0.4),
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
            Icons.person_rounded,
            color: AppTheme.white,
            size: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBadge() {
    final isComplete = _filledFieldsCount == 4;

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
            AppTheme.blue.withOpacity(isDark ? 0.15 : 0.1),
            AppTheme.blue.withOpacity(isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? AppTheme.secondary.withOpacity(0.3)
              : AppTheme.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress dots
          ...List.generate(4, (index) {
            final isFilled = index < _filledFieldsCount;
            return Container(
              width: 6,
              height: 6,
              margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: isFilled
                    ? (isComplete ? AppTheme.secondary : AppTheme.blue)
                    : AppTheme.getTextSecondary(isDark).withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: isFilled
                    ? [
                  BoxShadow(
                    color: (isComplete ? AppTheme.secondary : AppTheme.blue)
                        .withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ]
                    : null,
              ),
            );
          }),
          const SizedBox(width: 8),
          Text(
            '$_filledFieldsCount/4',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isComplete ? AppTheme.secondary : AppTheme.blue,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 👤 Name Row (First & Last Name)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildNameRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First Name
        Expanded(
          child: _buildTextField(
            controller: widget.firstNameController,
            label: WarrantyStrings.firstName,
            hint: WarrantyStrings.enterFirstName,
            icon: Icons.badge_rounded,
            iconColor: AppTheme.blue,
            inputFormatters: [EnglishLettersOnlyFormatter()],
            validator: _requiredValidator,
          ),
        ),
        const SizedBox(width: 12),

        // Last Name
        Expanded(
          child: _buildTextField(
            controller: widget.lastNameController,
            label: WarrantyStrings.lastName,
            hint: WarrantyStrings.enterLastName,
            icon: Icons.badge_outlined,
            iconColor: AppTheme.blue,
            inputFormatters: [EnglishLettersOnlyFormatter()],
            validator: _requiredValidator,
          ),
        ),
      ],
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
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getText(isDark),
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),

        // Text Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppTheme.primary)
                    .withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
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
                color: AppTheme.getTextSecondary(isDark),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
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
                  ? AppTheme.darkCard.withOpacity(0.8)
                  : AppTheme.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.lightBorder,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: iconColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.error.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.error,
                  width: 2,
                ),
              ),
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Phone Field with Country Code
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildPhoneField(BuildContext context) {
    return BlocBuilder<CheckPhoneCubit, CheckPhoneState>(
      builder: (context, state) {
        final cubit = context.read<CheckPhoneCubit>();
        final currentCode = cubit.selectedCounty?.code ?? '+1';
        final flagEmoji = cubit.selectedCounty?.flag ?? '🇺🇸';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_rounded,
                    size: 16,
                    color: AppTheme.purple,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    WarrantyStrings.mobileNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getText(isDark),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.purple,
                    ),
                  ),
                ],
              ),
            ),

            // Phone Input Row
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppTheme.purple)
                        .withOpacity(isDark ? 0.2 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country Code Selector
                  IntrinsicWidth(
                    child: _buildCountryCodeSelector(currentCode, flagEmoji),
                  ),
                  const SizedBox(width: 10),

                  // Phone Number Field
                  Expanded(
                    child: _buildPhoneTextField(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountryCodeSelector(String code, String flag) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showCountryCodeBottomSheetEnglish(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.purple.withOpacity(isDark ? 0.15 : 0.1),
              AppTheme.purple.withOpacity(isDark ? 0.08 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.purple.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purple.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flag
            // Text(
            //   flag,
            //   style: const TextStyle(fontSize: 20),
            // ),
            const SizedBox(width: 8),

            // Code
            Text(
              code,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.purple,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 4),

            // Dropdown Arrow
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.purple,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneTextField() {
    return TextFormField(
      controller: widget.phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.getText(isDark),
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        hintText: '5xxxxxxxx',
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppTheme.getTextSecondary(isDark),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.purple.withOpacity(isDark ? 0.2 : 0.15),
                AppTheme.purple.withOpacity(isDark ? 0.1 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.phone_android_rounded,
            color: AppTheme.purple,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: isDark
            ? AppTheme.darkCard.withOpacity(0.8)
            : AppTheme.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? AppTheme.primary.withOpacity(0.1)
                : AppTheme.lightBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.purple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.error.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.error,
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.error,
        ),
      ),
      validator: _phoneValidator,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✅ Validators
  // ═══════════════════════════════════════════════════════════════════════
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return WarrantyStrings.fieldRequired;
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return WarrantyStrings.fieldRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return WarrantyStrings.invalidEmail;
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return WarrantyStrings.fieldRequired;
    }
    if (value.trim().length < 8) {
      return WarrantyStrings.invalidPhone;
    }
    return null;
  }
}