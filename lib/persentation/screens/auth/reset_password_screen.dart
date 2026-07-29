import 'package:app/core/responsive/responsive.dart';
// ═══════════════════════════════════════════════════════════════════════════
// 📌 reset_password_screen.dart - شاشة إعادة تعيين كلمة المرور
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui' as ui;

import 'package:app/business_logic/auth/CheckPhoneCubit/check_phone_cubit.dart';
import 'package:app/business_logic/reset_password/cubit/reset_password_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/widgets/buttons.dart';
import 'package:app/persentation/widgets/textFormField.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide AnimatedBuilder;
import 'package:flutter/material.dart' as flutter;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gif_view/gif_view.dart';

import '../../../functions/country_code_sheet.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 ألوان الهوية البصرية للتطبيق
// ═══════════════════════════════════════════════════════════════════════════
class AppBrandColors {
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color background = Color(0xFF15172A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B5CF6)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [dark, Color(0xFF0D1F3C)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, Color(0xFF10B981)],
  );

  static LinearGradient subtleGradient(bool isDark) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark
        ? [background, const Color(0xFF0D1F3C)]
        : [white, lightGray],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔐 شاشة إعادة تعيين كلمة المرور
// ═══════════════════════════════════════════════════════════════════════════
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 🌙 Theme Helpers
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Controllers
  // ─────────────────────────────────────────────────────────────────────────
  late final TextEditingController phoneController;
  late final GifController gifController;

  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 Animation Controllers
  // ─────────────────────────────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final AnimationController _shakeController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shakeAnimation;

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 State Variables
  // ─────────────────────────────────────────────────────────────────────────
  bool _isPhoneFocused = false;
  bool _isButtonHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    phoneController = TextEditingController();
    // gifController = GifController(
    //   autoPlay: true,
    //   loop: true,
    // );
   gifController = GifController();

  // gifController.repeat(); // ده بدل autoPlay + loop
  }

  void _initializeAnimations() {
    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Slide Animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Shake Animation (for errors)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Start animations with staggered delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Build Method
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? AppBrandColors.background : AppBrandColors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppBrandColors.subtleGradient(_isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ═══════════════════════════════════════════════════════════
              // 🔝 Custom App Bar
              // ═══════════════════════════════════════════════════════════
              _buildCustomAppBar(),

              // ═══════════════════════════════════════════════════════════
              // 📝 Main Content
              // ═══════════════════════════════════════════════════════════
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing(context, 24)),
                    child: Column(
                      children: [
                        SizedBox(height: ResponsiveUtils.spacing(context, 20)),

                        // Illustration
                        _buildIllustration(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 32)),

                        // Header Section
                        _buildHeaderSection(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 40)),

                        // Form Section
                        _buildFormSection(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 40)),

                        // Send Button
                        _buildSendButton(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 24)),

                        // Help Text
                        _buildHelpText(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 40)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔝 Custom App Bar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 16),
        vertical: ResponsiveUtils.spacing(context, 12),
      ),
      child: Row(
        children: [
          // Back Button
          _buildBackButton(),

          const Spacer(),

          // Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Reset Password'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 18),
                fontWeight: FontWeight.w600,
                color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
                letterSpacing: -0.3,
              ),
            ),
          ),

          const Spacer(),

          // Placeholder for symmetry
          SizedBox(width: ResponsiveUtils.width(context, 48)),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    final btnPad = ResponsiveUtils.spacing(context, 12);
    final borderR = ResponsiveUtils.radius(context, 14);
    final iconSize = ResponsiveUtils.icon(context, 20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          MyNavigator.back(context);
        },
        borderRadius: BorderRadius.circular(borderR),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(btnPad),
          decoration: BoxDecoration(
            color: _isDark
                ? AppBrandColors.white.withOpacity(0.1)
                : AppBrandColors.lightGray,
            borderRadius: BorderRadius.circular(borderR),
            border: Border.all(
              color: _isDark
                  ? AppBrandColors.white.withOpacity(0.1)
                  : AppBrandColors.darkGray.withOpacity(0.2),
            ),
            boxShadow: _isDark ? null : [
              BoxShadow(
                color: AppBrandColors.dark.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppBrandColors.purple,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Illustration
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildIllustration() {
    final outerSize = ResponsiveUtils.width(context, 180);
    final innerSize = ResponsiveUtils.width(context, 140);
    final gifSize = ResponsiveUtils.width(context, 120);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppBrandColors.purple.withOpacity(_isDark ? 0.3 : 0.1),
              AppBrandColors.lightGreen.withOpacity(_isDark ? 0.3 : 0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppBrandColors.purple.withOpacity(_isDark ? 0.2 : 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isDark ? AppBrandColors.dark : AppBrandColors.white,
              boxShadow: [
                BoxShadow(
                  color: (_isDark ? Colors.black : AppBrandColors.dark).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: GifView.asset(
                Assets.forgetPassGIF,
                height: gifSize,
                width: gifSize,
                fit: BoxFit.contain,
                // repeat: ImageRepeat.noRepeat,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏷️ Header Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Main Title
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppBrandColors.primaryGradient.createShader(bounds),
              child: Text(
                'Forgot Password?'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            SizedBox(height: ResponsiveUtils.spacing(context, 12)),

            // Subtitle
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, 20),
              ),
              child: Text(
                'Enter your phone number and we will send you a verification code to reset your password.'
                    .tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 15),
                  color: _isDark
                      ? AppBrandColors.darkGray
                      : AppBrandColors.dark.withOpacity(0.6),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Form Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFormSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Padding(
              padding: EdgeInsets.only(
                left: ResponsiveUtils.spacing(context, 4),
                bottom: ResponsiveUtils.spacing(context, 10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 6)),
                    decoration: BoxDecoration(
                      gradient: AppBrandColors.primaryGradient,
                      borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 8)),
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: Colors.white,
                      size: ResponsiveUtils.icon(context, 14),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 10)),
                  Text(
                    'Phone Number'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 14),
                      fontWeight: FontWeight.w600,
                      color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
                    ),
                  ),
                ],
              ),
            ),

            // Phone Input
            _buildPhoneInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return BlocBuilder<CheckPhoneCubit, CheckPhoneState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
              boxShadow: _isPhoneFocused
                  ? [
                BoxShadow(
                  color: AppBrandColors.purple.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
                  : [
                BoxShadow(
                  color: (_isDark ? Colors.black : AppBrandColors.dark).withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Phone Text Field
                Expanded(
                  child: _buildPhoneTextField(context),
                ),

                SizedBox(width: ResponsiveUtils.spacing(context, 10)),

                // Country Selector
                _buildCountrySelector(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneTextField(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() => _isPhoneFocused = focused);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isDark ? AppBrandColors.dark : AppBrandColors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
          border: Border.all(
            color: _isPhoneFocused
                ? AppBrandColors.purple
                : (_isDark
                ? AppBrandColors.white.withOpacity(0.1)
                : AppBrandColors.darkGray.withOpacity(0.4)),
            width: _isPhoneFocused ? 2 : 1.5,
          ),
        ),
        child: CustomTextFormField(
          text: 'Enter your phone number'.tr(),
          controller: phoneController,
          keyboardType: TextInputType.phone,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
          borderColor: Colors.transparent,
          isFilld: true,
          color: Colors.transparent,
          hintColor: _isDark
              ? AppBrandColors.darkGray.withOpacity(0.6)
              : AppBrandColors.darkGray,
          textColor: _isDark ? AppBrandColors.white : AppBrandColors.dark,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, 12),
            vertical: ResponsiveUtils.spacing(context, 14),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 8),
              vertical: ResponsiveUtils.spacing(context, 10),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, 8),
                vertical: ResponsiveUtils.spacing(context, 3),
              ),
              decoration: BoxDecoration(
                color: AppBrandColors.purple.withOpacity(_isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 8)),
              ),
              child: Text(
                context.read<CheckPhoneCubit>().selectedCounty.code,
                style: TextStyle(
                  color: AppBrandColors.purple,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveUtils.font(context, 13),
                ),
              ),
            ),
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
            decoration: BoxDecoration(
              gradient: AppBrandColors.primaryGradient,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 10)),
              boxShadow: [
                BoxShadow(
                  color: AppBrandColors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.asset(
              AssetsSVG.user,
              color: Colors.white,
              width: ResponsiveUtils.icon(context, 16),
              height: ResponsiveUtils.icon(context, 16),
            ),
          ),
          onChanged: (val) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildCountrySelector(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          showCountryCodeBottomSheet(context);
        },
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: ResponsiveUtils.width(context, 72),
          height: ResponsiveUtils.height(context, 56),
          decoration: BoxDecoration(
            color: _isDark ? AppBrandColors.dark : AppBrandColors.white,
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
            border: Border.all(
              color: _isDark
                  ? AppBrandColors.white.withOpacity(0.1)
                  : AppBrandColors.darkGray.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: _isDark ? null : [
              BoxShadow(
                color: AppBrandColors.dark.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _isDark
                    ? AppBrandColors.darkGray
                    : AppBrandColors.dark.withOpacity(0.5),
                size: ResponsiveUtils.icon(context, 20),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 4)),
              ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 4)),
                child: SvgPicture.asset(
                  context.read<CheckPhoneCubit>().selectedCounty.flag,
                  width: ResponsiveUtils.width(context, 28),
                  height: ResponsiveUtils.height(context, 20),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔘 Send Button
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSendButton() {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      builder: (context, state) {
        final isLoading = ResetPasswordCubit.get(context).isLoading;
        final isEnabled = phoneController.text.isNotEmpty;

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isButtonHovered = true),
              onExit: (_) => setState(() => _isButtonHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: ResponsiveUtils.buttonHeight(context, 56),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
                  gradient: isEnabled
                      ? (_isDark
                      ? LinearGradient(
                    colors: [AppBrandColors.purple, AppBrandColors.purple.withOpacity(0.8)],
                  )
                      : AppBrandColors.darkGradient)
                      : LinearGradient(
                    colors: [
                      AppBrandColors.darkGray.withOpacity(_isDark ? 0.3 : 1.0),
                      AppBrandColors.darkGray.withOpacity(_isDark ? 0.2 : 0.8),
                    ],
                  ),
                  boxShadow: isEnabled && !isLoading
                      ? [
                    BoxShadow(
                      color: (_isDark ? AppBrandColors.purple : AppBrandColors.dark).withOpacity(
                        _isButtonHovered ? 0.4 : 0.25,
                      ),
                      blurRadius: _isButtonHovered ? 20 : 16,
                      offset: Offset(0, _isButtonHovered ? 8 : 6),
                    ),
                  ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEnabled && !isLoading ? _handleSendOTP : null,
                    borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
                    child: Center(
                      child: isLoading
                          ? _buildLoadingIndicator()
                          : _buildButtonContent(),
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

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: ResponsiveUtils.icon(context, 22),
          height: ResponsiveUtils.icon(context, 22),
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppBrandColors.lightGreen,
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 14)),
        Text(
          'Sending...'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.font(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: ResponsiveUtils.icon(context, 20),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 10)),
        Text(
          'Send Verification Code'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.font(context, 16),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendOTP() async {
    HapticFeedback.mediumImpact();

    final phone = context.read<CheckPhoneCubit>().selectedCounty.code +
        phoneController.text;

    await ResetPasswordCubit.get(context).sendOTPMessage(
      context: context,
      phone: phone,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 💡 Help Text
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHelpText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        decoration: BoxDecoration(
          color: AppBrandColors.lightGreen.withOpacity(_isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
          border: Border.all(
            color: AppBrandColors.lightGreen.withOpacity(_isDark ? 0.4 : 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
              decoration: BoxDecoration(
                color: AppBrandColors.lightGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: AppBrandColors.lightGreen.withOpacity(0.8),
                size: ResponsiveUtils.icon(context, 20),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 12)),
            Expanded(
              child: Text(
                'You will receive a 6-digit code via SMS'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 13),
                  color: _isDark
                      ? AppBrandColors.white.withOpacity(0.8)
                      : AppBrandColors.dark.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Custom Animated Builder (Helper Widget)
// ═══════════════════════════════════════════════════════════════════════════
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return flutter.AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}