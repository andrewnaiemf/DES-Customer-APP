import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/persentation/screens/warranty/warranty_strings.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_exports.dart';
import 'dart:ui' as ui;

// ═══════════════════════════════════════════════════════════════════════════
// 🚗 Vehicle Information Section - Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class VehicleInfoSection extends StatefulWidget {
  final TextEditingController makeController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController colorController;
  final TextEditingController licensePlateController;
  final bool isDark;

  const VehicleInfoSection({
    super.key,
    required this.makeController,
    required this.modelController,
    required this.yearController,
    required this.colorController,
    required this.licensePlateController,
    this.isDark = false,
  });

  @override
  State<VehicleInfoSection> createState() => _VehicleInfoSectionState();
}

class _VehicleInfoSectionState extends State<VehicleInfoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get isDark => widget.isDark;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
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
            child: _buildSectionCard(),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCard.withOpacity(0.95)
            : AppTheme.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppTheme.yellow.withOpacity(0.15)
              : AppTheme.yellow.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.yellow)
                .withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: AppTheme.yellow.withOpacity(0.05),
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
                    // Vehicle Make
                    _buildTextField(
                      controller: widget.makeController,
                      label: WarrantyStrings.vehicleMake,
                      hint: WarrantyStrings.enterMake,
                      icon: Icons.business_rounded,
                      inputFormatters: [EnglishOnlyInputFormatter()],
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Model
                    _buildTextField(
                      controller: widget.modelController,
                      label: WarrantyStrings.vehicleModel,
                      hint: WarrantyStrings.enterModel,
                      icon: Icons.car_rental_rounded,
                      inputFormatters: [EnglishOnlyInputFormatter()],
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),

                    // Year and Color Row
                    Row(
                      children: [
                        // Manufacturing Year
                        Expanded(
                          child: _buildTextField(
                            controller: widget.yearController,
                            label: WarrantyStrings.vehicleYear,
                            hint: WarrantyStrings.enterYear,
                            icon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                            validator: _yearValidator,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Vehicle Color
                        Expanded(
                          child: _buildTextField(
                            controller: widget.colorController,
                            label: WarrantyStrings.vehicleColor,
                            hint: WarrantyStrings.enterColor,
                            icon: Icons.palette_rounded,
                            inputFormatters: [EnglishLettersOnlyFormatter()],
                            validator: _requiredValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // License Plate
                    _buildTextField(
                      controller: widget.licensePlateController,
                      label: WarrantyStrings.licensePlate,
                      hint: WarrantyStrings.enterPlate,
                      icon: Icons.pin_rounded,
                      inputFormatters: [EnglishOnlyInputFormatter()],
                      validator: _requiredValidator,
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
            AppTheme.yellow.withOpacity(isDark ? 0.12 : 0.08),
            AppTheme.yellow.withOpacity(isDark ? 0.05 : 0.02),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.yellow.withOpacity(isDark ? 0.1 : 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          _buildIconContainer(),
          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WarrantyStrings.vehicleInfoTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getText(isDark),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your vehicle details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Decorative Badge
          _buildBadge(),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppTheme.yellowGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.yellow.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 30,
            height: 30,
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
          Icon(
            Icons.directions_car_rounded,
            color: AppTheme.dark,
            size: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.yellow.withOpacity(isDark ? 0.15 : 0.1),
            AppTheme.yellow.withOpacity(isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.yellow.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.yellow.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Required',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.yellow,
              letterSpacing: 0.3,
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
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getText(isDark),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.yellow,
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
                      AppTheme.yellow.withOpacity(isDark ? 0.15 : 0.1),
                      AppTheme.yellow.withOpacity(isDark ? 0.08 : 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.yellow,
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
                  color: AppTheme.yellow,
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
              errorStyle: TextStyle(
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
  // ✅ Validators
  // ═══════════════════════════════════════════════════════════════════════
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return WarrantyStrings.fieldRequired;
    }
    return null;
  }

  String? _yearValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return WarrantyStrings.fieldRequired;
    }
    final year = int.tryParse(value);
    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
      return WarrantyStrings.invalidYear;
    }
    return null;
  }
}