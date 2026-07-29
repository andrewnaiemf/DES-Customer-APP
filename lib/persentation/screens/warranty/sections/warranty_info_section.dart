import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/persentation/screens/warranty/warranty_strings.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_exports.dart';
import 'dart:ui' as ui;

// ═══════════════════════════════════════════════════════════════════════════
// 🛡️ Warranty Information Section - Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyInfoSection extends StatefulWidget {
  final TextEditingController codeController;
  final TextEditingController serialController;
  final TextEditingController metersController;
  final List<String> selectedWindowsProtection;
  final List<String> selectedPPFProtection;
  final Function(List<String>) onWindowsChanged;
  final Function(List<String>) onPPFChanged;
  final bool isDark;

  const WarrantyInfoSection({
    super.key,
    required this.codeController,
    required this.serialController,
    required this.metersController,
    required this.selectedWindowsProtection,
    required this.selectedPPFProtection,
    required this.onWindowsChanged,
    required this.onPPFChanged,
    this.isDark = false,
  });

  @override
  State<WarrantyInfoSection> createState() => _WarrantyInfoSectionState();
}

class _WarrantyInfoSectionState extends State<WarrantyInfoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool get isDark => widget.isDark;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCard.withOpacity(0.95)
            : AppTheme.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppTheme.green.withOpacity(0.2)
              : AppTheme.green.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.green)
                .withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: AppTheme.green.withOpacity(0.06),
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    // Warranty Code with "Code" prefix
                    _buildCodeField(),
                    const SizedBox(height: 20),

                    // Serial Number
                    _buildTextField(
                      controller: widget.serialController,
                      label: WarrantyStrings.serialNumber,
                      hint: 'Enter serial number',
                      icon: Icons.confirmation_number_rounded,
                      iconColor: AppTheme.green,
                      inputFormatters: [EnglishNumbersOnlyFormatter()],
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 20),

                    // Current Meters
                    _buildTextField(
                      controller: widget.metersController,
                      label: WarrantyStrings.currentMileage,
                      hint: 'Enter current kilometers',
                      icon: Icons.speed_rounded,
                      iconColor: AppTheme.green,
                      keyboardType: TextInputType.number,
                      suffixWidget: _buildKmSuffix(),
                      validator: _metersValidator,
                    ),
                    const SizedBox(height: 28),

                    // Divider with label
                    _buildDividerWithLabel('Protection Areas'),
                    const SizedBox(height: 20),

                    // Protected Areas - Windows
                    _buildProtectedAreaSelector(
                      context: context,
                      title: 'Window Protection Areas',
                      subtitle: 'Glass & windshield protection',
                      icon: Icons.window_rounded,
                      color: AppTheme.blue,
                      gradient: AppTheme.blueGradient(),
                      selectedAreas: widget.selectedWindowsProtection,
                      availableAreas: _getWindowProtectionAreas(),
                      onChanged: widget.onWindowsChanged,
                    ),
                    const SizedBox(height: 16),

                    // Protected Areas - PPF
                    _buildProtectedAreaSelector(
                      context: context,
                      title: 'PPF Protection Areas',
                      subtitle: 'Paint protection film coverage',
                      icon: Icons.security_rounded,
                      color: AppTheme.orange,
                      gradient: AppTheme.orangeGradient(),
                      selectedAreas: widget.selectedPPFProtection,
                      availableAreas: _getPPFProtectionAreas(),
                      onChanged: widget.onPPFChanged,
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
            AppTheme.green.withOpacity(isDark ? 0.15 : 0.1),
            AppTheme.green.withOpacity(isDark ? 0.05 : 0.03),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.green.withOpacity(isDark ? 0.15 : 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon Container with Shield
          _buildIconContainer(),
          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WarrantyStrings.warrantyInfoTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getText(isDark),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Warranty details & protection coverage',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppTheme.greenGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.green.withOpacity(0.4),
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
          // Shield icon with subtle animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppTheme.white,
                  size: 26,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final hasSelections = widget.selectedWindowsProtection.isNotEmpty ||
        widget.selectedPPFProtection.isNotEmpty;
    final totalSelected = widget.selectedWindowsProtection.length +
        widget.selectedPPFProtection.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasSelections
              ? [
            AppTheme.green.withOpacity(isDark ? 0.2 : 0.15),
            AppTheme.green.withOpacity(isDark ? 0.1 : 0.08),
          ]
              : [
            AppTheme.orange.withOpacity(isDark ? 0.15 : 0.1),
            AppTheme.orange.withOpacity(isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasSelections
              ? AppTheme.green.withOpacity(0.3)
              : AppTheme.orange.withOpacity(0.3),
        ),
        boxShadow: hasSelections
            ? [
          BoxShadow(
            color: AppTheme.green.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated dot
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: (hasSelections ? AppTheme.green : AppTheme.orange)
                      .withOpacity(value),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (hasSelections ? AppTheme.green : AppTheme.orange)
                          .withOpacity(0.5 * value),
                      blurRadius: 4,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          Text(
            hasSelections ? '$totalSelected Selected' : 'Pending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasSelections ? AppTheme.green : AppTheme.orange,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔢 Code Field with Prefix
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Text(
                WarrantyStrings.code,
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
                  color: AppTheme.green,
                ),
              ),
            ],
          ),
        ),

        // Code Input Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Code" Prefix Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.purple.withOpacity(isDark ? 0.2 : 0.15),
                    AppTheme.purple.withOpacity(isDark ? 0.1 : 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.purple.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purple.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.qr_code_rounded,
                      color: AppTheme.purple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.purple,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Code Input Field
            Expanded(
              child: Container(
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
                  controller: widget.codeController,
                  inputFormatters: [EnglishNumbersOnlyFormatter()],
                  validator: _requiredValidator,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getText(isDark),
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.getTextSecondary(isDark),
                      letterSpacing: 0,
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
                        color: AppTheme.green,
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
            ),
          ],
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
    Widget? suffixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
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
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              suffixIcon: suffixWidget,
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

  Widget _buildKmSuffix() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.green.withOpacity(isDark ? 0.2 : 0.15),
            AppTheme.green.withOpacity(isDark ? 0.1 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.green.withOpacity(0.2),
        ),
      ),
      child: const Text(
        'KM',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.green,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📐 Divider with Label
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDividerWithLabel(String label) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.getBorder(isDark),
                  AppTheme.green.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.green.withOpacity(isDark ? 0.15 : 0.1),
                  AppTheme.green.withOpacity(isDark ? 0.08 : 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.green.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 14,
                  color: AppTheme.green,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.green,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.green.withOpacity(0.3),
                  AppTheme.getBorder(isDark),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🛡️ Protected Area Selector - Premium Design
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildProtectedAreaSelector({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required LinearGradient gradient,
    required List<String> selectedAreas,
    required List<String> availableAreas,
    required Function(List<String>) onChanged,
  }) {
    final hasSelections = selectedAreas.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await ProtectedAreasBottomSheet.show(
          context: context,
          selectedAreas: selectedAreas,
          availableAreas: availableAreas,
          title: title,
        );
        if (result != null) {
          onChanged(result);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.darkCard.withOpacity(0.6)
              : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasSelections
                ? color.withOpacity(0.4)
                : AppTheme.getBorder(isDark),
            width: hasSelections ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: hasSelections
                  ? color.withOpacity(0.15)
                  : (isDark ? Colors.black : AppTheme.primary).withOpacity(0.05),
              blurRadius: hasSelections ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Animated Icon Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: hasSelections ? gradient : null,
                    color: hasSelections
                        ? null
                        : color.withOpacity(isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withOpacity(hasSelections ? 0 : 0.3),
                    ),
                    boxShadow: hasSelections
                        ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: hasSelections ? AppTheme.white : color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getText(isDark),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection Count Badge
                if (hasSelections)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${selectedAreas.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                      ),
                    ),
                  ),

                const SizedBox(width: 8),

                // Arrow with animation
                AnimatedRotation(
                  turns: hasSelections ? 0.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDark ? 0.1 : 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),

            // Selected Areas Preview
            if (hasSelections) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.08 : 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withOpacity(0.15),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...selectedAreas.take(4).map((area) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : AppTheme.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 12,
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              area,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getText(isDark),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (selectedAreas.length > 4)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+${selectedAreas.length - 4} more',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getSurface(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getBorder(isDark),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 18,
                      color: color,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tap to select areas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📋 Data Lists
  // ═══════════════════════════════════════════════════════════════════════
  List<String> _getWindowProtectionAreas() {
    return [
      'Front Window (L)',
      'Front Window (R)',
      'Rear Window (L)',
      'Rear Window (R)',
      'Side Windows',
      'Sunroof',
      'MPV - Rear Fix Window (L)',
      'MPV - Rear Fix Window (R)',
      'Front Windshield',
      'Rear Windshield',
    ];
  }

  List<String> _getPPFProtectionAreas() {
    return [
      'Full Vehicle',
      'Front Bumper',
      'Rear Bumper',
      'Hood',
      'Side Mirrors',
      'Doors (L)',
      'Doors (R)',
      'Roof',
      'Trunk',
    ];
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

  String? _metersValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return WarrantyStrings.fieldRequired;
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return 'Please enter a valid number';
    }
    return null;
  }
}