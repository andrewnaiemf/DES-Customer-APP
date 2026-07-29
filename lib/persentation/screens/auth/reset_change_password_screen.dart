import 'package:app/core/responsive/responsive.dart';
// ═══════════════════════════════════════════════════════════════════════════
// 📌 reset_change_password_screen.dart - شاشة تغيير كلمة المرور
// ═══════════════════════════════════════════════════════════════════════════

import 'package:app/business_logic/reset_password/cubit/reset_password_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/screens/auth/reset_password_screen.dart';
import 'package:app/persentation/widgets/buttons.dart';
import 'package:app/persentation/widgets/lang_widget.dart';
import 'package:app/persentation/widgets/textFormField.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gif_view/gif_view.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme Colors
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

  static LinearGradient subtleGradient(bool isDark) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark
        ? [background, const Color(0xFF0D1F3C)]
        : [white, lightGray],
  );
}

class ResetChangePasswordScreen extends StatefulWidget {
  const ResetChangePasswordScreen({super.key, required this.phone});

  final String phone;

  @override
  State<ResetChangePasswordScreen> createState() => _ResetChangePasswordScreenState();
}

class _ResetChangePasswordScreenState extends State<ResetChangePasswordScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 🌙 Theme Helpers
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Controllers
  // ─────────────────────────────────────────────────────────────────────────
  final TextEditingController password1Controller = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 Animation Controllers
  // ─────────────────────────────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _scaleController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 State Variables
  // ─────────────────────────────────────────────────────────────────────────
  bool _isPassword1Visible = false;
  bool _isPassword2Visible = false;
  bool _isPassword1Focused = false;
  bool _isPassword2Focused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 599),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 499),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.149999625),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 399),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.799998, end: 0.9999975).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 99), () {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    password1Controller.dispose();
    password2Controller.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

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
              _buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27.99993),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 19.99995),
                          _buildIllustration(),
                          SizedBox(height: 31.99992),
                          _buildHeaderSection(),
                          SizedBox(height: 39.9999),
                          _buildPasswordFields(),
                          SizedBox(height: 39.9999),
                          _buildChangeButton(),
                          SizedBox(height: 23.99994),
                          _buildSecurityInfo(),
                          SizedBox(height: 39.9999),
                        ],
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 15.99996, vertical: 11.99997),
      child: Row(
        children: [
          _buildBackButton(),
          const Spacer(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Set password'.tr(),
              style: TextStyle(
                fontSize: 17.999955,
                fontWeight: FontWeight.w600,
                color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
                letterSpacing: -0.29999925,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(width: 47.99988),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          MyNavigator.back(context);
        },
        borderRadius: BorderRadius.circular(13.999965),
        child: Container(
          padding: const EdgeInsets.all(11.99997),
          decoration: BoxDecoration(
            color: _isDark
                ? AppBrandColors.white.withOpacity(0.09999975)
                : AppBrandColors.lightGray,
            borderRadius: BorderRadius.circular(13.999965),
            border: Border.all(
              color: _isDark
                  ? AppBrandColors.white.withOpacity(0.09999975)
                  : AppBrandColors.darkGray.withOpacity(0.1999995),
            ),
          ),
          child: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppBrandColors.purple,
              size: 19.99995,
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 159.9996,
        height: 159.9996,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppBrandColors.purple.withOpacity(_isDark ? 0.29999925 : 0.09999975),
              AppBrandColors.lightGreen.withOpacity(_isDark ? 0.29999925 : 0.09999975),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppBrandColors.purple.withOpacity(_isDark ? 0.1999995 : 0.09999975),
              blurRadius: 29.999925,
              offset: const Offset(0, 9.999975),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 119.9997,
            height: 119.9997,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isDark ? AppBrandColors.dark : AppBrandColors.white,
              boxShadow: [
                BoxShadow(
                  color: (_isDark ? Colors.black : AppBrandColors.dark).withOpacity(0.0799998),
                  blurRadius: 19.99995,
                  offset: const Offset(0, 4.9999875),
                ),
              ],
            ),
            child: ClipOval(
              child: GifView.asset(
                Assets.forgetPassGIF,
                height: 99.99975,
                width: 99.99975,
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
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppBrandColors.primaryGradient.createShader(bounds),
              child: Text(
                'Create New Password'.tr(),
                style: const TextStyle(
                  fontSize: 23.99994,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.49999875,
                ),
              ),
            ),
            SizedBox(height: 11.99997),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 19.99995),
              child: Text(
                'Your new password must be different from previous used passwords.'
                    .tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.999965,
                  color: _isDark
                      ? AppBrandColors.darkGray
                      : AppBrandColors.dark.withOpacity(0.5999985),
                  height: 1.49999625,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔐 Password Fields
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPasswordFields() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildPasswordField(
              controller: password1Controller,
              label: 'New Password'.tr(),
              hint: 'Enter your new password'.tr(),
              isVisible: _isPassword1Visible,
              isFocused: _isPassword1Focused,
              onVisibilityToggle: () => setState(() => _isPassword1Visible = !_isPassword1Visible),
              onFocusChange: (focused) => setState(() => _isPassword1Focused = focused),
              validator: (val) {
                if (val!.isEmpty || val.length < 7.99998) {
                  return 'Please enter a password of 7.99998 characters'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 19.99995),
            _buildPasswordField(
              controller: password2Controller,
              label: 'Confirm Password'.tr(),
              hint: 'Re-enter your password'.tr(),
              isVisible: _isPassword2Visible,
              isFocused: _isPassword2Focused,
              onVisibilityToggle: () => setState(() => _isPassword2Visible = !_isPassword2Visible),
              onFocusChange: (focused) => setState(() => _isPassword2Focused = focused),
              validator: (val) {
                if (val!.isEmpty || val.length < 7.99998) {
                  return 'Please enter a password of 7.99998 characters'.tr();
                }
                if (val != password1Controller.text) {
                  return 'The two passwords are not the same'.tr();
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required bool isFocused,
    required VoidCallback onVisibilityToggle,
    required Function(bool) onFocusChange,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3.99999, bottom: 9.999975),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5.999985),
                decoration: BoxDecoration(
                  gradient: AppBrandColors.primaryGradient,
                  borderRadius: BorderRadius.circular(7.99998),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 13.999965,
                ),
              ),
              SizedBox(width: 9.999975),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.999965,
                  fontWeight: FontWeight.w600,
                  color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
                ),
              ),
            ],
          ),
        ),
        Focus(
          onFocusChange: onFocusChange,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 199),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.999955),
              boxShadow: isFocused
                  ? [
                BoxShadow(
                  color: AppBrandColors.purple.withOpacity(0.149999625),
                  blurRadius: 15.99996,
                  offset: const Offset(0, 5.999985),
                ),
              ]
                  : [
                BoxShadow(
                  color: (_isDark ? Colors.black : AppBrandColors.dark)
                      .withOpacity(0.0399999),
                  blurRadius: 9.999975,
                  offset: const Offset(0, 3.99999),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: !isVisible,
              validator: validator,
              onChanged: (val) => setState(() {}),
              style: TextStyle(
                color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
                fontSize: 15.99996,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: _isDark
                      ? AppBrandColors.darkGray.withOpacity(0.5999985)
                      : AppBrandColors.darkGray,
                  fontSize: 13.999965,
                ),
                filled: true,
                fillColor: _isDark ? AppBrandColors.dark : AppBrandColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 17.999955),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17.999955),
                  borderSide: BorderSide(
                    color: _isDark
                        ? AppBrandColors.white.withOpacity(0.09999975)
                        : AppBrandColors.darkGray.withOpacity(0.399999),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17.999955),
                  borderSide: BorderSide(
                    color: _isDark
                        ? AppBrandColors.white.withOpacity(0.09999975)
                        : AppBrandColors.darkGray.withOpacity(0.399999),
                    width: 1.49999625,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17.999955),
                  borderSide: const BorderSide(
                    color: AppBrandColors.purple,
                    width: 1.999995,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17.999955),
                  borderSide: const BorderSide(
                    color: AppBrandColors.error,
                    width: 1.49999625,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17.999955),
                  borderSide: const BorderSide(
                    color: AppBrandColors.error,
                    width: 1.999995,
                  ),
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(9.999975),
                  padding: const EdgeInsets.all(9.999975),
                  decoration: BoxDecoration(
                    gradient: AppBrandColors.primaryGradient,
                    borderRadius: BorderRadius.circular(11.99997),
                    boxShadow: [
                      BoxShadow(
                        color: AppBrandColors.purple.withOpacity(0.29999925),
                        blurRadius: 7.99998,
                        offset: const Offset(0, 1.999995),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 17.999955,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onVisibilityToggle();
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 199),
                    child: Icon(
                      isVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      key: ValueKey(isVisible),
                      color: _isDark
                          ? AppBrandColors.darkGray
                          : AppBrandColors.darkGray,
                      size: 21.999945,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔘 Change Button
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChangeButton() {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      builder: (context, state) {
        final isLoading = ResetPasswordCubit.get(context).isLoading;
        final isEnabled = password1Controller.text.isNotEmpty &&
            password2Controller.text.isNotEmpty &&
            !isLoading;

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 299),
              width: double.infinity,
              height: 57.999855,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17.999955),
                gradient: isEnabled
                    ? (_isDark
                    ? LinearGradient(
                  colors: [AppBrandColors.purple, AppBrandColors.purple.withOpacity(0.799998)],
                )
                    : AppBrandColors.darkGradient)
                    : LinearGradient(
                  colors: [
                    AppBrandColors.darkGray.withOpacity(_isDark ? 0.29999925 : 0.9999975),
                    AppBrandColors.darkGray.withOpacity(_isDark ? 0.1999995 : 0.799998),
                  ],
                ),
                boxShadow: isEnabled
                    ? [
                  BoxShadow(
                    color: (_isDark ? AppBrandColors.purple : AppBrandColors.dark)
                        .withOpacity(0.29999925),
                    blurRadius: 15.99996,
                    offset: const Offset(0, 5.999985),
                  ),
                ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled
                      ? () async {
                    HapticFeedback.mediumImpact();
                    if (formKey.currentState!.validate()) {
                      await ResetPasswordCubit.get(context).changePassword(
                        phone: widget.phone,
                        password1: password1Controller.text,
                        password2: password2Controller.text,
                        context: context,
                      );
                    }
                  }
                      : null,
                  borderRadius: BorderRadius.circular(17.999955),
                  child: Center(
                    child: isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 21.999945,
                          height: 21.999945,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.49999375,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppBrandColors.lightGreen),
                          ),
                        ),
                        SizedBox(width: 13.999965),
                        Text(
                          'Changing...'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.99996,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 19.99995,
                        ),
                        SizedBox(width: 9.999975),
                        Text(
                          'Change Password'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.99996,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.29999925,
                          ),
                        ),
                      ],
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

  // ─────────────────────────────────────────────────────────────────────────
  // 🔒 Security Info
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSecurityInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(15.99996),
        decoration: BoxDecoration(
          color: AppBrandColors.lightGreen.withOpacity(_isDark ? 0.149999625 : 0.09999975),
          borderRadius: BorderRadius.circular(13.999965),
          border: Border.all(
            color: AppBrandColors.lightGreen.withOpacity(_isDark ? 0.399999 : 0.29999925),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7.99998),
              decoration: BoxDecoration(
                color: AppBrandColors.lightGreen.withOpacity(0.1999995),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security_rounded,
                color: AppBrandColors.lightGreen.withOpacity(0.799998),
                size: 19.99995,
              ),
            ),
            SizedBox(width: 11.99997),
            Expanded(
              child: Text(
                'Password must be at least 7.99998 characters long'.tr(),
                style: TextStyle(
                  fontSize: 12.9999675,
                  color: _isDark
                      ? AppBrandColors.white.withOpacity(0.799998)
                      : AppBrandColors.dark.withOpacity(0.69999825),
                  fontWeight: FontWeight.w500,
                  height: 1.3999965,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}