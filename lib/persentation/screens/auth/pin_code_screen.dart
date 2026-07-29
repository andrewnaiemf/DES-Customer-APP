import 'package:app/core/responsive/responsive.dart';
// ═══════════════════════════════════════════════════════════════════════════
// 📌 pin_code_screen.dart - شاشة إدخال رمز التحقق
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:developer';
import 'dart:ui' as ui;

import 'package:app/business_logic/reset_password/cubit/reset_password_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/widgets/buttons.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gif_view/gif_view.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'login_screen.dart';

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
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color background = Color(0xFF15172A);

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
// 🔢 شاشة إدخال رمز التحقق (PIN Code Screen)
// ═══════════════════════════════════════════════════════════════════════════
class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key, required this.phone});

  final String phone;

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 🌙 Theme Helpers
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Controllers
  // ─────────────────────────────────────────────────────────────────────────
  late final TextEditingController _otpController;

  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 Animation Controllers
  // ─────────────────────────────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final AnimationController _shakeController;
  late final AnimationController _successController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shakeAnimation;
  late final Animation<double> _successAnimation;

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 State Variables
  // ─────────────────────────────────────────────────────────────────────────
  String _smsOTP = '';
  bool _isComplete = false;
  bool _hasError = false;
  int _resendCountdown = 59;
  bool _canResend = false;
  bool _isCountdownRunning = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _startResendCountdown();
  }

  void _initializeControllers() {
    _otpController = TextEditingController();
  }

  void _initializeAnimations() {
    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide Animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Shake Animation (for errors)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Success Animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _successAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeOut),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  void _startResendCountdown() {
    if (_isCountdownRunning) return;
    _isCountdownRunning = true;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) {
        _isCountdownRunning = false;
        return false;
      }

      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          _isCountdownRunning = false;
        }
      });
      return _resendCountdown > 0;
    });
  }

  void _triggerErrorAnimation() {
    HapticFeedback.heavyImpact();
    setState(() => _hasError = true);
    _shakeController.forward().then((_) {
      _shakeController.reverse();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _hasError = false);
      });
    });
  }

  void _triggerSuccessAnimation() {
    HapticFeedback.mediumImpact();
    _successController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    _successController.dispose();
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
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.spacing(context, 24),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: ResponsiveUtils.spacing(context, 16)),

                        // Illustration
                        _buildIllustration(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 28)),

                        // Header Section
                        _buildHeaderSection(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 32)),

                        // OTP Input Section
                        _buildOTPSection(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 32)),

                        // Verify Button
                        _buildVerifyButton(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 20)),

                        // Resend Section
                        _buildResendSection(),

                        SizedBox(height: ResponsiveUtils.spacing(context, 32)),
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
              'Verification'.tr(),
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
    final btnSize = ResponsiveUtils.width(context, 44);
    final iconSize = ResponsiveUtils.icon(context, 20);
    final borderR = ResponsiveUtils.radius(context, 14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          MyNavigator.back(context);
        },
        borderRadius: BorderRadius.circular(borderR),
        child: Container(
          width: btnSize,
          height: btnSize,
          alignment: Alignment.center,
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
    final outerSize = ResponsiveUtils.width(context, 140);
    final innerSize = ResponsiveUtils.width(context, 105);
    final gifSize = ResponsiveUtils.width(context, 88);

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
                'Enter Verification Code'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 22),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            SizedBox(height: ResponsiveUtils.spacing(context, 10)),

            // Subtitle with phone number
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, 16),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    color: _isDark
                        ? AppBrandColors.darkGray
                        : AppBrandColors.dark.withOpacity(0.6),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'We sent a 6-digit code to '.tr()),
                    TextSpan(
                      text: _formatPhoneNumber(widget.phone),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppBrandColors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length > 4) {
      return '${phone.substring(0, 3)} **** ${phone.substring(phone.length - 3)}';
    }
    return phone;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔢 OTP Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOTPSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _hasError ? _shakeAnimation.value * (_shakeAnimation.value.isNegative ? 1 : -1) : 0,
                0,
              ),
              child: child,
            );
          },
          child: Column(
            children: [
              // OTP Info Banner
              _buildOTPInfoBanner(),

              SizedBox(height: ResponsiveUtils.spacing(context, 20)),

              // OTP Fields
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: _buildOTPFields(),
              ),

              // Success Indicator
              AnimatedBuilder(
                animation: _successAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _successAnimation.value,
                    child: Transform.scale(
                      scale: _successAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _isComplete
                    ? Container(
                  margin: EdgeInsets.only(
                    top: ResponsiveUtils.spacing(context, 12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing(context, 14),
                    vertical: ResponsiveUtils.spacing(context, 6),
                  ),
                  decoration: BoxDecoration(
                    color: AppBrandColors.success.withOpacity(_isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius(context, 20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppBrandColors.success,
                        size: ResponsiveUtils.icon(context, 18),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing(context, 6)),
                      Text(
                        'Code entered'.tr(),
                        style: TextStyle(
                          color: AppBrandColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.font(context, 13),
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPInfoBanner() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 14),
        vertical: ResponsiveUtils.spacing(context, 10),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppBrandColors.purple.withOpacity(_isDark ? 0.2 : 0.08),
            AppBrandColors.lightGreen.withOpacity(_isDark ? 0.2 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 14),
        ),
        border: Border.all(
          color: AppBrandColors.purple.withOpacity(_isDark ? 0.3 : 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 7)),
            decoration: const BoxDecoration(
              gradient: AppBrandColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: ResponsiveUtils.icon(context, 16),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 10)),
          Text(
            'Enter the 6-digit code'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 14),
              color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPFields() {
    final fieldH = ResponsiveUtils.height(context, 52);
    final fieldW = ResponsiveUtils.width(context, 44);
    final borderR = ResponsiveUtils.radius(context, 14);

    return SizedBox(
      width: ResponsiveUtils.width(context, 340),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        obscureText: false,
        animationType: AnimationType.scale,
        cursorColor: AppBrandColors.purple,
        controller: _otpController,
        autoFocus: true,
        keyboardType: TextInputType.number,
        animationDuration: const Duration(milliseconds: 200),
        backgroundColor: Colors.transparent,
        enableActiveFill: true,
        hapticFeedbackTypes: HapticFeedbackTypes.selection,
        pinTheme: PinTheme(
          // Shape
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(borderR),
          fieldHeight: fieldH,
          fieldWidth: fieldW,

          // Border widths
          borderWidth: 2,
          inactiveBorderWidth: 1.5,
          activeBorderWidth: 2,
          selectedBorderWidth: 2.5,
          errorBorderWidth: 2,
          disabledBorderWidth: 1,

          // Colors - Inactive
          inactiveColor: _isDark
              ? AppBrandColors.white.withOpacity(0.2)
              : AppBrandColors.darkGray.withOpacity(0.4),
          inactiveFillColor: _isDark
              ? AppBrandColors.dark
              : AppBrandColors.white,

          // Colors - Active (when filled)
          activeColor: _hasError ? AppBrandColors.error : AppBrandColors.lightGreen,
          activeFillColor: _hasError
              ? AppBrandColors.error.withOpacity(0.05)
              : AppBrandColors.lightGreen.withOpacity(_isDark ? 0.1 : 0.05),

          // Colors - Selected (current field)
          selectedColor: _hasError ? AppBrandColors.error : AppBrandColors.purple,
          selectedFillColor: _hasError
              ? AppBrandColors.error.withOpacity(0.05)
              : AppBrandColors.purple.withOpacity(_isDark ? 0.15 : 0.05),

          // Colors - Error & Disabled
          errorBorderColor: AppBrandColors.error,
          disabledColor: AppBrandColors.darkGray.withOpacity(0.3),
        ),
        textStyle: TextStyle(
          fontSize: ResponsiveUtils.font(context, 22),
          fontWeight: FontWeight.bold,
          color: _hasError
              ? AppBrandColors.error
              : (_isDark ? AppBrandColors.white : AppBrandColors.dark),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          ArabicToEnglishFormatter(),
        ],
        onCompleted: (value) {
          setState(() {
            _smsOTP = value;
            _isComplete = true;
          });
          _triggerSuccessAnimation();
        },
        onChanged: (value) {
          log('OTP Value: $value');
          setState(() {
            _smsOTP = value;
            _isComplete = value.length == 6;
            if (_hasError) _hasError = false;
          });
        },
        beforeTextPaste: (text) {
          log("Pasting: $text");
          return true;
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔘 Verify Button
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildVerifyButton() {
    final btnHeight = ResponsiveUtils.buttonHeight(context, 54);
    final borderR = ResponsiveUtils.radius(context, 16);

    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      builder: (context, state) {
        final isLoading = ResetPasswordCubit.get(context).isLoading;
        final isEnabled = _isComplete && !isLoading;

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: btnHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderR),
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
                boxShadow: isEnabled
                    ? [
                  BoxShadow(
                    color: (_isDark ? AppBrandColors.purple : AppBrandColors.dark)
                        .withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? _handleVerify : null,
                  borderRadius: BorderRadius.circular(borderR),
                  child: Center(
                    child: isLoading
                        ? _buildLoadingIndicator()
                        : _buildButtonContent(),
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
            valueColor: AlwaysStoppedAnimation<Color>(AppBrandColors.lightGreen),
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 12)),
        Text(
          'Verifying...'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.font(context, 15),
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
          Icons.verified_rounded,
          color: Colors.white,
          size: ResponsiveUtils.icon(context, 20),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 8)),
        Text(
          'Verify Code'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.font(context, 15),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Future<void> _handleVerify() async {
    HapticFeedback.mediumImpact();

    await ResetPasswordCubit.get(context).confirmPhoneNumberAndResetPassword(
      context: context,
      code: _smsOTP,
      phone: widget.phone,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔄 Resend Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildResendSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            "Didn't receive the code?".tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 14),
              color: _isDark
                  ? AppBrandColors.darkGray
                  : AppBrandColors.dark.withOpacity(0.6),
            ),
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 10)),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _canResend
                ? _buildResendButton()
                : _buildCountdownTimer(),
          ),
        ],
      ),
    );
  }

  Widget _buildResendButton() {
    return TextButton.icon(
      onPressed: () {
        HapticFeedback.selectionClick();
        setState(() {
          _resendCountdown = 60;
          _canResend = false;
        });
        _startResendCountdown();
        // Call resend API here
      },
      icon: Icon(
        Icons.refresh_rounded,
        size: ResponsiveUtils.icon(context, 18),
        color: AppBrandColors.purple,
      ),
      label: Text(
        'Resend Code'.tr(),
        style: TextStyle(
          color: AppBrandColors.purple,
          fontWeight: FontWeight.w600,
          fontSize: ResponsiveUtils.font(context, 14),
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 18),
          vertical: ResponsiveUtils.spacing(context, 10),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.radius(context, 12),
          ),
          side: BorderSide(
            color: AppBrandColors.purple.withOpacity(_isDark ? 0.5 : 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 18),
        vertical: ResponsiveUtils.spacing(context, 8),
      ),
      decoration: BoxDecoration(
        color: _isDark
            ? AppBrandColors.white.withOpacity(0.1)
            : AppBrandColors.lightGray,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: ResponsiveUtils.icon(context, 18),
            color: AppBrandColors.darkGray,
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 6)),
          Text(
            '${'Resend in'.tr()} ${_formatTime(_resendCountdown)}',
            style: TextStyle(
              color: _isDark
                  ? AppBrandColors.darkGray
                  : AppBrandColors.dark.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveUtils.font(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
// 🔢 Arabic to English Number Formatter
// ═══════════════════════════════════════════════════════════════════════════
class ArabicToEnglishFormatter extends TextInputFormatter {
  static const Map<String, String> _arabicToEnglish = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
  };

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String newText = newValue.text.replaceAllMapped(
      RegExp(r'[٠-٩]'),
          (match) => _arabicToEnglish[match.group(0)!] ?? match.group(0)!,
    );

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
