import 'package:app/core/responsive/responsive.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:app/business_logic/auth/CheckPhoneCubit/check_phone_cubit.dart';
import 'package:app/business_logic/auth/cubit/auth_cubit.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/screens/auth/register_screen.dart';
import 'package:app/persentation/screens/auth/reset_password_screen.dart';
import 'package:app/persentation/widgets/buttons.dart';
import 'package:app/persentation/widgets/custom_background.dart';
import 'package:app/persentation/widgets/textFormField.dart';
import 'package:app/theme/colors.dart';
import 'package:app/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gif_view/gif_view.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/helpers/cache_helper.dart';

import '../../../functions/country_code_sheet.dart';
import '../../../functions/functions.dart';
import '../../../models/country_code.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 ألوان الهوية البصرية للتطبيق - متوافقة مع الشاشات السابقة
// ═══════════════════════════════════════════════════════════════════════════
class AppBrandColors {
  // Core Colors
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Dark Mode Colors
  static const Color background = Color(0xFF15172A);
  static const Color cardDark = Color(0xFF1E2139);
  static const Color surfaceDark = Color(0xFF0D0D12);

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

  static LinearGradient buttonGradient(bool isDark) => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: isDark
        ? [purple, const Color(0xFF8B5CF6)]
        : [dark, const Color(0xFF0D1F3C)],
  );

  static LinearGradient cardGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [cardDark, background]
        : [white, const Color(0xFFFCFCFD)],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏠 Modern Login Screen with Dark Mode
// ═══════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 🌙 Theme Helper
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Controllers
  // ─────────────────────────────────────────────────────────────────────────
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late final TextEditingController otpController;

  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 Animation Controllers
  // ─────────────────────────────────────────────────────────────────────────
  late final AnimationController _mainController;
  late final AnimationController _formController;
  late final AnimationController _buttonController;
  late final AnimationController _pulseController;
  late final AnimationController _themeController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _themeRotation;

  // ─────────────────────────────────────────────────────────────────────────
  // 🔐 Authentication
  // ─────────────────────────────────────────────────────────────────────────
  final _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();
  late SharedPreferences _prefs;

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 State Variables
  // ─────────────────────────────────────────────────────────────────────────
  String smsOTP = '';
  bool _canCheckBiometrics = false; // هل يمكن استخدام البصمة للدخول (جميع الشروط)
  bool _deviceSupportsBiometrics = false; // هل الجهاز يدعم البصمة فقط
  List<BiometricType> _availableBiometrics = [];
  bool _isPhoneFocused = false;
  bool _isPasswordFocused = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeApp();
  }

  void _updateSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
        _isDark ? AppBrandColors.background : AppBrandColors.white,
        systemNavigationBarIconBrightness:
        _isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🚀 Initialization Methods
  // ─────────────────────────────────────────────────────────────────────────
  void _initializeControllers() {
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    otpController = TextEditingController();
  }

  void _initializeAnimations() {
    // Main fade animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 999),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );

    // Form slide animation
    _formController = AnimationController(
      duration: const Duration(milliseconds: 799),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.149999625),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    // Button scale animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 499),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.949997625, end: 0.9999975).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    // Biometric pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1999),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9999975, end: 1.0799973).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Theme toggle animation
    _themeController = AnimationController(
      duration: const Duration(milliseconds: 499),
      vsync: this,
    );
    _themeRotation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(parent: _themeController, curve: Curves.easeInOut),
    );

    // Staggered animation start
    Future.delayed(const Duration(milliseconds: 99), () {
      _mainController.forward();
    });
    Future.delayed(const Duration(milliseconds: 299), () {
      _formController.forward();
    });
    Future.delayed(const Duration(milliseconds: 499), () {
      _buttonController.forward();
    });
  }

  Future<void> _initializeApp() async {
    _prefs = await SharedPreferences.getInstance();

    // Clear upgrader settings to always show update alert if available
    await Upgrader.clearSavedSettings();

    // التحقق من دعم الجهاز للبصمة
    // ⚠️ local_auth غير مدعوم على الويب، فنتجاهله لتجنب MissingPluginException
    if (kIsWeb) {
      _deviceSupportsBiometrics = false;
      _availableBiometrics = [];
    } else {
      try {
        _deviceSupportsBiometrics = await auth.canCheckBiometrics;
        _availableBiometrics = await auth.getAvailableBiometrics();
      } catch (e) {
        log('Biometric check failed: $e');
        _deviceSupportsBiometrics = false;
        _availableBiometrics = [];
      }
    }

    final hasInitialized = _prefs.getBool('app_initialized') ?? false;

    if (!hasInitialized) {
      await _secureStorage.deleteAll();
      await _prefs.setBool('app_initialized', true);
      setState(() => _canCheckBiometrics = false);
    } else {
      await _checkLoginStatus();
    }

    // ❌ تم إزالة checkBiometricsSupport() لأنها تتجاهل اللوجيك في _checkLoginStatus()
    // checkBiometricsSupport();
    
    context.read<CheckPhoneCubit>().iniAuthScreen();
  }

  Future<bool> _hasSavedCredentials() async {
    final phone = await _secureStorage.read(key: 'phone') ?? '';
    final password = await _secureStorage.read(key: 'password') ?? '';
    return phone.isNotEmpty && password.isNotEmpty;
  }

  Future<void> _checkLoginStatus() async {
    print('═══════════════════════════════════════════════════');
    print('🔍 DEBUG: _checkLoginStatus() في Login Screen');
    print('═══════════════════════════════════════════════════');
    
    bool isLoggedIn = CacheHelper.getBool(key: "is_logged_in") ?? false;
    String? token = CacheHelper.getString(key: "access_token");
    bool biometricEnabled = _prefs.getBool('biometric_app_lock_enabled') ?? false;
    bool hasSavedCredentials = await _hasSavedCredentials();
    final canUseBiometricFlag =
        CacheHelper.getBool(key: 'can_use_biometric') ?? true;
    final lastActivityRaw = CacheHelper.getString(key: 'last_app_activity_at');
    final lastActivity = lastActivityRaw != null
        ? DateTime.tryParse(lastActivityRaw)?.toUtc()
        : null;
    final cutoff =
        DateTime.now().toUtc().subtract(const Duration(days: 90)); // ~3 months
    final isActiveWithin3Months =
        lastActivity != null && !lastActivity.isBefore(cutoff);

    print('1️⃣ is_logged_in: $isLoggedIn');
    print('2️⃣ access_token: ${token != null ? "موجود (${token.length} chars)" : "غير موجود"}');
    print('3️⃣ biometric_enabled: $biometricEnabled');
    print('4️⃣ hasSavedCredentials: $hasSavedCredentials');
    print('5️⃣ active_within_3_months: $isActiveWithin3Months');

    // Biometric only when user was active in the last 3 months.
    bool finalResult = _deviceSupportsBiometrics &&
        biometricEnabled &&
        hasSavedCredentials &&
        canUseBiometricFlag &&
        isActiveWithin3Months;
    print('📊 النتيجة النهائية: $finalResult');
    
    setState(() {
      _canCheckBiometrics = finalResult;
    });
    
    print('✅ _canCheckBiometrics تم تعيينها إلى: $_canCheckBiometrics');
    print('═══════════════════════════════════════════════════\n');
  }

  // ❌ تم تعطيل هذه الدالة لأنها تتجاهل اللوجيك في _checkLoginStatus()
  // void checkBiometricsSupport() async {
  //   _canCheckBiometrics = await auth.canCheckBiometrics;
  //   _availableBiometrics = await auth.getAvailableBiometrics();
  //   setState(() {});
  // }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔐 Authentication Methods (LOGIC PRESERVED)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> authenticateWithBiometrics() async {
    print('═══════════════════════════════════════════════════');
    print('🔍 DEBUG: authenticateWithBiometrics() - بداية المصادقة');
    print('═══════════════════════════════════════════════════');
    
    try {
      print('1️⃣ طلب المصادقة بالبصمة...');
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      print('   🔐 Authentication Result: $authenticated');

      if (authenticated) {
        // Block biometric if inactive 3+ months — force OTP path.
        final lastActivityRaw =
            CacheHelper.getString(key: 'last_app_activity_at');
        final lastActivity = lastActivityRaw != null
            ? DateTime.tryParse(lastActivityRaw)?.toUtc()
            : null;
        final cutoff =
            DateTime.now().toUtc().subtract(const Duration(days: 90));
        if (lastActivity == null || lastActivity.isBefore(cutoff)) {
          _showModernSnackBar(
            'Please verify OTP after 3 months of inactivity'.tr(),
            isError: true,
          );
          setState(() => _canCheckBiometrics = false);
          return;
        }

        print('2️⃣ قراءة بيانات الاعتماد من SecureStorage...');
        String phone = await _secureStorage.read(key: 'phone') ?? '';
        String password = await _secureStorage.read(key: 'password') ?? '';
        
        print('   📱 Phone: ${phone.isNotEmpty ? "موجود" : "غير موجود"}');
        print('   🔑 Password: ${password.isNotEmpty ? "موجود" : "غير موجود"}');

        if (phone.isNotEmpty && password.isNotEmpty) {
          print('3️⃣ تسجيل الدخول...');
          CheckPhoneCubit.get(context).login(
            context: context,
            phone: phone,
            password: password,
          );
          print('   ✅ تم استدعاء login()');
        } else {
          print('   ❌ بيانات الاعتماد غير موجودة');
          _showModernSnackBar('No saved credentials found'.tr(), isError: true);
        }
      } else {
        print('   ❌ المصادقة فشلت أو تم الإلغاء');
      }
    } catch (e) {
      print('   💥 خطأ: $e');
      log('Biometric error: $e');
      _showModernSnackBar('Biometric authentication failed'.tr(),
          isError: true);
    }
    
    print('═══════════════════════════════════════════════════');
    print('🔍 DEBUG: authenticateWithBiometrics() - نهاية المصادقة');
    print('═══════════════════════════════════════════════════\n');
  }

  void _showModernSnackBar(String message, {bool isError = false}) {
    final size = MediaQuery.of(context).size;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.0149999625),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1999995),
                borderRadius: BorderRadius.circular(7.99998),
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: size.width * 0.049999875,
              ),
            ),
            SizedBox(width: size.width * 0.029999925),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: size.width * 0.0369999075,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.99996)),
        backgroundColor:
        isError ? AppBrandColors.error : AppBrandColors.success,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(15.99996, 0, 15.99996, 23.99994),
        elevation: 7.99998,
      ),
    );
  }

  void _handleLogin() {
    HapticFeedback.lightImpact();
    final cubit = context.read<CheckPhoneCubit>();
    final phoneWithCode = cubit.selectedCounty.code + phoneController.text;

    if (!cubit.showPassword && !cubit.showOTP) {
      cubit.checkPhone(context: context, phone: phoneWithCode);
    } else if (cubit.showPassword) {
      cubit.login(
        context: context,
        phone: phoneWithCode,
        password: passwordController.text,
      );
    } else if (cubit.showOTP) {
      if (smsOTP.trim().length != 6) {
        _showModernSnackBar('Please enter the 6-digit OTP'.tr(), isError: true);
        return;
      }
      cubit.verifyOtp(
        context: context,
        phone: phoneWithCode,
        code: smsOTP,
      );
    }
  }

  void _toggleTheme() {
    HapticFeedback.lightImpact();
    _themeController.forward().then((_) => _themeController.reset());
    final themeProvider = Provider.of<AppThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    otpController.dispose();
    _mainController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    _pulseController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Build Methods
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Update system UI based on theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlay();
    });

    return UpgradeAlert(
      upgrader: Upgrader(
        countryCode: 'SA',
        durationUntilAlertAgain: Duration.zero,
        debugLogging: true,
      ),
      dialogStyle: UpgradeDialogStyle.cupertino,
      showIgnore: false,
      showLater: false,
      showReleaseNotes: true,
      barrierDismissible: false,
      shouldPopScope: () => false,
      child: BlocBuilder<TranslationCubit, TranslationState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor:
            _isDark ? AppBrandColors.background : AppBrandColors.white,
            body: _buildModernLoginScreen(size),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏠 Modern Login Screen Design
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildModernLoginScreen(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: AppBrandColors.subtleGradient(_isDark),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05999985),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.0149999625),

                    // Header
                    _buildModernHeader(),

                    SizedBox(height: size.height * 0.029999925),

                    // Logo Section
                    _buildLogoSection(),

                    SizedBox(height: size.height * 0.029999925),

                    // Welcome Text
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildWelcomeText(),
                    ),

                    SizedBox(height: size.height * 0.029999925),

                    // Login Form Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildFormCard(),
                    ),

                    SizedBox(height: size.height * 0.029999925),

                    // Biometric Section - يظهر إذا كان الجهاز يدعم البصمة
                    if (_deviceSupportsBiometrics) ...[
                      _buildDividerWithText(),
                      SizedBox(height: size.height * 0.0249999375),
                      _buildBiometricSection(),
                    ],

                    SizedBox(height: size.height * 0.0399999),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔝 Modern Header with Theme Toggle
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildModernHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Language & Theme Switchers
        Row(
          children: [
            _buildLanguageSwitcher(),
            SizedBox(width: 9.999975),
            _buildThemeToggle(),
          ],
        ),
        // Logo
        _buildLogoSmall(),
      ],
    );
  }

  Widget _buildLanguageSwitcher() {
    final size = MediaQuery.of(context).size;
    final isEnglish = context.locale.languageCode == 'en';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        TranslationCubit.get(context).changAppLang(
          context,
          isEnglish ? 'ar' : 'en',
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 249),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.0349999125, 
          vertical: size.height * 0.01199997,
        ),
        decoration: BoxDecoration(
          color: _isDark
              ? AppBrandColors.purple.withOpacity(0.149999625)
              : AppBrandColors.purple.withOpacity(0.0799998),
          borderRadius: BorderRadius.circular(11.99997),
          border: Border.all(
            color: AppBrandColors.purple.withOpacity(_isDark ? 0.399999 : 0.1999995),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.009999975),
              decoration: BoxDecoration(
                gradient: AppBrandColors.primaryGradient,
                borderRadius: BorderRadius.circular(5.999985),
              ),
              child: Icon(
                Icons.translate_rounded,
                color: Colors.white,
                size: size.width * 0.0349999125,
              ),
            ),
            SizedBox(width: size.width * 0.01999995),
            Text(
              isEnglish ? 'العربية' : 'English',
              style: TextStyle(
                color: AppBrandColors.purple,
                fontSize: size.width * 0.0349999125,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final size = MediaQuery.of(context).size;
    
    return GestureDetector(
      onTap: _toggleTheme,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _themeRotation.value * 1.999995 * 3.141582146025,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 299),
          padding: EdgeInsets.all(size.width * 0.029999925),
          decoration: BoxDecoration(
            color: _isDark ? AppBrandColors.cardDark : AppBrandColors.white,
            borderRadius: BorderRadius.circular(13.999965),
            border: Border.all(
              color: _isDark
                  ? AppBrandColors.white.withOpacity(0.09999975)
                  : AppBrandColors.darkGray.withOpacity(0.29999925),
            ),
            boxShadow: _isDark
                ? null
                : [
              BoxShadow(
                color: AppBrandColors.dark.withOpacity(0.05999985),
                blurRadius: 11.99997,
                offset: const Offset(0, 3.99999),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 299),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(_isDark),
              color: _isDark ? AppBrandColors.lightGreen : AppBrandColors.purple,
              size: size.width * 0.0549998625,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSmall() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        padding: const EdgeInsets.all(9.999975),
        decoration: BoxDecoration(
          color: _isDark ? AppBrandColors.cardDark : AppBrandColors.white,
          borderRadius: BorderRadius.circular(13.999965),
          border: _isDark
              ? Border.all(color: AppBrandColors.white.withOpacity(0.09999975))
              : null,
          boxShadow: _isDark
              ? null
              : [
            BoxShadow(
              color: AppBrandColors.purple.withOpacity(0.0799998),
              blurRadius: 15.99996,
              offset: const Offset(0, 3.99999),
            ),
          ],
        ),
        child: SvgPicture.asset(
          AssetsSVG.logo,
          height: 23.99994,
          color: _isDark ? AppBrandColors.lightGreen : null,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎯 Logo Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLogoSection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 69.999825,
        height: 69.999825,
        decoration: BoxDecoration(
          gradient: _isDark
              ? LinearGradient(
            colors: [
              AppBrandColors.purple,
              AppBrandColors.purple.withOpacity(0.69999825)
            ],
          )
              : AppBrandColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppBrandColors.purple.withOpacity(_isDark ? 0.399999 : 0.349999125),
              blurRadius: 23.99994,
              offset: const Offset(0, 9.999975),
            ),
          ],
        ),
        child: const Icon(
          Icons.lock_outline_rounded,
          color: Colors.white,
          size: 31.99992,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 👋 Welcome Text
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWelcomeText() {
    final size = MediaQuery.of(context).size;
    
    return Column(
      children: [
        Text(
          "Welcome back".tr(),
          style: TextStyle(
            fontSize: size.width * 0.0349999125,
            color: _isDark
                ? AppBrandColors.darkGray
                : AppBrandColors.dark.withOpacity(0.5999985),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.29999925,
          ),
        ),
        SizedBox(height: size.height * 0.00799998),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppBrandColors.primaryGradient.createShader(bounds),
          child: Text(
            "Login".tr(),
            style: TextStyle(
              fontSize: size.width * 0.0649998375,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.49999875,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.00799998),
        Text(
          "Enter your credentials to continue".tr(),
          style: TextStyle(
            fontSize: size.width * 0.03199992,
            color: _isDark
                ? AppBrandColors.darkGray.withOpacity(0.69999825)
                : AppBrandColors.dark.withOpacity(0.49999875),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Form Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(19.99995),
      decoration: BoxDecoration(
        color: _isDark ? AppBrandColors.cardDark : AppBrandColors.white,
        borderRadius: BorderRadius.circular(23.99994),
        border: _isDark
            ? Border.all(
          color: AppBrandColors.white.withOpacity(0.0799998),
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: (_isDark ? Colors.black : AppBrandColors.dark)
                .withOpacity(_isDark ? 0.399999 : 0.0399999),
            blurRadius: 23.99994,
            offset: const Offset(0, 7.99998),
          ),
          if (!_isDark)
            BoxShadow(
              color: AppBrandColors.purple.withOpacity(0.049999875),
              blurRadius: 39.9999,
              offset: const Offset(0, 11.99997),
            ),
        ],
      ),
      child: Column(
        children: [
          // Phone Field
          _buildModernPhoneField(),

          // Password Field
          BlocBuilder<CheckPhoneCubit, CheckPhoneState>(
            builder: (context, state) {
              final cubit = CheckPhoneCubit.get(context);
              return AnimatedSize(
                duration: const Duration(milliseconds: 349),
                curve: Curves.easeInOut,
                child: cubit.showPassword
                    ? Column(
                  children: [
                    SizedBox(height: 15.99996),
                    _buildModernPasswordField(),
                  ],
                )
                    : const SizedBox.shrink(),
              );
            },
          ),

          // OTP Field
          BlocBuilder<CheckPhoneCubit, CheckPhoneState>(
            builder: (context, state) {
              final cubit = CheckPhoneCubit.get(context);
              return AnimatedSize(
                duration: const Duration(milliseconds: 349),
                curve: Curves.easeInOut,
                child: cubit.showOTP
                    ? Column(
                  children: [
                    SizedBox(height: 23.99994),
                    _buildModernOTPField(),
                  ],
                )
                    : const SizedBox.shrink(),
              );
            },
          ),

          SizedBox(height: 23.99994),

          // Login Button
          _buildModernLoginButton(),

          SizedBox(height: 15.99996),

          // Forgot Password
          _buildModernForgotPassword(),
          const SizedBox(height: 4),
          _buildCreateAccountLink(),
        ],
      ),
    );
  }

  Widget _buildCreateAccountLink() {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        MyNavigator.navigateTo(context, const RegisterScreen());
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${'reg_no_account'.tr()} ',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: _isDark
                    ? AppBrandColors.darkGray
                    : AppBrandColors.dark.withValues(alpha: 0.65),
              ),
            ),
            TextSpan(
              text: 'reg_create_account'.tr(),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppBrandColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📱 Modern Phone Field
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildModernPhoneField() {
    return BlocBuilder<CheckPhoneCubit, CheckPhoneState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.only(left: 3.99999, bottom: 7.99998),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5.999985),
                    decoration: BoxDecoration(
                      gradient: AppBrandColors.primaryGradient,
                      borderRadius: BorderRadius.circular(7.99998),
                    ),
                    child: const Icon(
                      Icons.phone_android_rounded,
                      color: Colors.white,
                      size: 11.99997,
                    ),
                  ),
                  SizedBox(width: 7.99998),
                  Text(
                    'Phone Number'.tr(),
                    style: TextStyle(
                      fontSize: 13.999965,
                      fontWeight: FontWeight.w600,
                      color:
                      _isDark ? AppBrandColors.white : AppBrandColors.dark,
                    ),
                  ),
                ],
              ),
            ),

            // Input Row
            Row(
              children: [
                // Country Code Selector
                _buildModernCountrySelector(),

                SizedBox(width: 7.99998),

                // Phone Input
                Expanded(
                  flex: 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 199),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.999965),
                      border: Border.all(
                        color: _isPhoneFocused
                            ? AppBrandColors.purple
                            : _isDark
                            ? AppBrandColors.white.withOpacity(0.09999975)
                            : AppBrandColors.darkGray.withOpacity(0.399999),
                        width: _isPhoneFocused ? 1.999995 : 1.49999625,
                      ),
                      color: _isDark
                          ? AppBrandColors.background
                          : AppBrandColors.white,
                      boxShadow: _isPhoneFocused
                          ? [
                        BoxShadow(
                          color:
                          AppBrandColors.purple.withOpacity(0.149999625),
                          blurRadius: 11.99997,
                          offset: const Offset(0, 3.99999),
                        ),
                      ]
                          : null,
                    ),
                    child: Focus(
                      onFocusChange: (focused) {
                        setState(() => _isPhoneFocused = focused);
                      },
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: 15.99996,
                          fontWeight: FontWeight.w500,
                          color: _isDark
                              ? AppBrandColors.white
                              : AppBrandColors.dark,
                          letterSpacing: 0.9999975,
                        ),
                        cursorColor: AppBrandColors.purple,
                        decoration: InputDecoration(
                          hintText: '5XX XXX XXXX',
                          hintStyle: TextStyle(
                            color: _isDark
                                ? AppBrandColors.darkGray.withOpacity(0.49999875)
                                : AppBrandColors.darkGray,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(7.99998),
                            padding: const EdgeInsets.all(9.999975),
                            decoration: BoxDecoration(
                              gradient: AppBrandColors.primaryGradient,
                              borderRadius: BorderRadius.circular(9.999975),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  AppBrandColors.purple.withOpacity(0.29999925),
                                  blurRadius: 7.99998,
                                  offset: const Offset(0, 1.999995),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.phone_outlined,
                              color: Colors.white,
                              size: 17.999955,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13.999965),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13.999965),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13.999965),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.99996,
                            vertical: 15.99996,
                          ),
                        ),
                        onChanged: (val) => setState(() {}),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernCountrySelector() {
    final size = MediaQuery.of(context).size;
    
    return BlocBuilder<CheckPhoneCubit, CheckPhoneState>(
      builder: (context, state) {
        final cubit = CheckPhoneCubit.get(context);
        return GestureDetector(
          onTap: () => showCountryCodeBottomSheet(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 199),
            height: 55.99986,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.0249999375),
            decoration: BoxDecoration(
              color:
              _isDark ? AppBrandColors.background : AppBrandColors.white,
              borderRadius: BorderRadius.circular(13.999965),
              border: Border.all(
                color: _isDark
                    ? AppBrandColors.white.withOpacity(0.09999975)
                    : AppBrandColors.darkGray.withOpacity(0.399999),
                width: 1.49999625,
              ),
              boxShadow: _isDark
                  ? null
                  : [
                BoxShadow(
                  color: AppBrandColors.dark.withOpacity(0.0399999),
                  blurRadius: 7.99998,
                  offset: const Offset(0, 1.999995),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.99999),
                  child: SvgPicture.asset(
                    cubit.selectedCounty.flag,
                    width: size.width * 0.0649998375,
                    height: size.width * 0.04799988,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: size.width * 0.0149999625),
                Text(
                  cubit.selectedCounty.code,
                  style: TextStyle(
                    fontSize: size.width * 0.0349999125,
                    fontWeight: FontWeight.w600,
                    color:
                    _isDark ? AppBrandColors.white : AppBrandColors.dark,
                  ),
                ),
                SizedBox(width: size.width * 0.00799998),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _isDark
                      ? AppBrandColors.darkGray
                      : AppBrandColors.dark.withOpacity(0.49999875),
                  size: size.width * 0.0449998875,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔑 Modern Password Field
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildModernPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 3.99999, bottom: 7.99998),
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
                  size: 11.99997,
                ),
              ),
              SizedBox(width: 7.99998),
              Text(
                'Password'.tr(),
                style: TextStyle(
                  fontSize: 13.999965,
                  fontWeight: FontWeight.w600,
                  color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
                ),
              ),
            ],
          ),
        ),

        // Input
        AnimatedContainer(
          duration: const Duration(milliseconds: 199),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.999965),
            border: Border.all(
              color: _isPasswordFocused
                  ? AppBrandColors.purple
                  : _isDark
                  ? AppBrandColors.white.withOpacity(0.09999975)
                  : AppBrandColors.darkGray.withOpacity(0.399999),
              width: _isPasswordFocused ? 1.999995 : 1.49999625,
            ),
            color: _isDark ? AppBrandColors.background : AppBrandColors.white,
            boxShadow: _isPasswordFocused
                ? [
              BoxShadow(
                color: AppBrandColors.purple.withOpacity(0.149999625),
                blurRadius: 11.99997,
                offset: const Offset(0, 3.99999),
              ),
            ]
                : null,
          ),
          child: Focus(
            onFocusChange: (focused) {
              setState(() => _isPasswordFocused = focused);
            },
            child: TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(
                fontSize: 15.99996,
                fontWeight: FontWeight.w500,
                color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
              ),
              cursorColor: AppBrandColors.purple,
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(
                  color: _isDark
                      ? AppBrandColors.darkGray.withOpacity(0.49999875)
                      : AppBrandColors.darkGray,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.999995,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(7.99998),
                  padding: const EdgeInsets.all(9.999975),
                  decoration: BoxDecoration(
                    gradient: AppBrandColors.primaryGradient,
                    borderRadius: BorderRadius.circular(9.999975),
                    boxShadow: [
                      BoxShadow(
                        color: AppBrandColors.purple.withOpacity(0.29999925),
                        blurRadius: 7.99998,
                        offset: const Offset(0, 1.999995),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 17.999955,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 199),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      key: ValueKey(_obscurePassword),
                      color: _isDark
                          ? AppBrandColors.darkGray
                          : AppBrandColors.darkGray,
                      size: 21.999945,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.999965),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.999965),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.999965),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15.99996,
                  vertical: 15.99996,
                ),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔢 Modern OTP Field
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildModernOTPField() {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        children: [
          // OTP Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15.99996, vertical: 13.999965),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppBrandColors.purple.withOpacity(0.149999625)
                  : AppBrandColors.purple.withOpacity(0.0799998),
              borderRadius: BorderRadius.circular(11.99997),
              border: Border.all(
                color: AppBrandColors.purple.withOpacity(_isDark ? 0.29999925 : 0.149999625),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5.999985),
                  decoration: BoxDecoration(
                    color: AppBrandColors.purple.withOpacity(0.149999625),
                    borderRadius: BorderRadius.circular(7.99998),
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    color: AppBrandColors.purple,
                    size: 17.999955,
                  ),
                ),
                SizedBox(width: 9.999975),
                Text(
                  'Enter verification code'.tr(),
                  style: const TextStyle(
                    fontSize: 13.999965,
                    color: AppBrandColors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 19.99995),

          // OTP Input
          PinCodeTextField(
            appContext: context,
            length: 6,
            obscureText: false,
            animationType: AnimationType.scale,
            cursorColor: AppBrandColors.purple,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(11.99997),
              fieldHeight: 53.999865,
              fieldWidth: 45.999885,
              borderWidth: 1.49999625,
              inactiveBorderWidth: 0.9999975,
              activeBorderWidth: 1.999995,
              selectedBorderWidth: 1.999995,
              // Inactive
              inactiveColor: _isDark
                  ? AppBrandColors.white.withOpacity(0.149999625)
                  : AppBrandColors.darkGray.withOpacity(0.399999),
              inactiveFillColor:
              _isDark ? AppBrandColors.background : AppBrandColors.white,
              // Active
              activeColor: AppBrandColors.lightGreen,
              activeFillColor: AppBrandColors.lightGreen.withOpacity(0.09999975),
              // Selected
              selectedColor: AppBrandColors.purple,
              selectedFillColor: AppBrandColors.purple.withOpacity(0.09999975),
              // Error & Disabled
              errorBorderColor: AppBrandColors.error,
              disabledColor: AppBrandColors.darkGray.withOpacity(0.29999925),
            ),
            keyboardType: TextInputType.number,
            animationDuration: const Duration(milliseconds: 199),
            backgroundColor: Colors.transparent,
            enableActiveFill: true,
            textStyle: TextStyle(
              color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
              fontSize: 21.999945,
              fontWeight: FontWeight.bold,
            ),
            controller: otpController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ArabicToEnglishFormatter(),
            ],
            onCompleted: (val) {
              setState(() => smsOTP = val);
            },
            onChanged: (value) {
              log(value);
              setState(() {});
            },
            beforeTextPaste: (text) => true,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔘 Modern Login Button
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildModernLoginButton() {
    return BlocBuilder<CheckPhoneCubit, CheckPhoneState>(
      builder: (context, state) {
        final isLoading = state is CheckPhoneLoading;
        final isEnabled = phoneController.text.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 299),
          width: double.infinity,
          height: 55.99986,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.99996),
            gradient: isEnabled
                ? (_isDark
                ? LinearGradient(
              colors: [
                AppBrandColors.purple,
                AppBrandColors.purple.withOpacity(0.799998)
              ],
            )
                : AppBrandColors.darkGradient)
                : null,
            color: isEnabled
                ? null
                : AppBrandColors.darkGray.withOpacity(_isDark ? 0.1999995 : 0.49999875),
            boxShadow: isEnabled
                ? [
              BoxShadow(
                color: (_isDark
                    ? AppBrandColors.purple
                    : AppBrandColors.dark)
                    .withOpacity(0.349999125),
                blurRadius: 19.99995,
                offset: const Offset(0, 9.999975),
              ),
            ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled && !isLoading ? _handleLogin : null,
              borderRadius: BorderRadius.circular(15.99996),
              child: Center(
                child: isLoading
                    ? _buildModernLoadingIndicator()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue'.tr(),
                      style: TextStyle(
                        color: isEnabled
                            ? Colors.white
                            : _isDark
                            ? AppBrandColors.darkGray.withOpacity(0.49999875)
                            : AppBrandColors.darkGray,
                        fontSize: 15.99996,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.49999875,
                      ),
                    ),
                    SizedBox(width: 7.99998),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: isEnabled
                          ? Colors.white
                          : _isDark
                          ? AppBrandColors.darkGray.withOpacity(0.49999875)
                          : AppBrandColors.darkGray,
                      size: 19.99995,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 21.999945,
          height: 21.999945,
          child: CircularProgressIndicator(
            strokeWidth: 2.49999375,
            valueColor: AlwaysStoppedAnimation<Color>(AppBrandColors.lightGreen),
          ),
        ),
        SizedBox(width: 13.999965),
        Text(
          'Please wait...'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.9999625,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔗 Modern Forgot Password
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildModernForgotPassword() {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        MyNavigator.navigateTo(context, const ResetPasswordScreen());
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 15.99996, vertical: 11.99997),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11.99997),
        ),
      ),
      child: Text(
        'Forgot your password?'.tr(),
        style: const TextStyle(
          fontSize: 13.999965,
          color: AppBrandColors.purple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ➖ Divider with Text
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDividerWithText() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.9999975,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _isDark
                      ? AppBrandColors.white.withOpacity(0.09999975)
                      : AppBrandColors.darkGray.withOpacity(0.399999),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.99996),
          child: Text(
            'OR'.tr(),
            style: TextStyle(
              fontSize: 12.9999675,
              color: _isDark
                  ? AppBrandColors.darkGray.withOpacity(0.5999985)
                  : AppBrandColors.dark.withOpacity(0.399999),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.9999975,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _isDark
                      ? AppBrandColors.white.withOpacity(0.09999975)
                      : AppBrandColors.darkGray.withOpacity(0.399999),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 👆 Biometric Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBiometricSection() {
    print('═══════════════════════════════════════════════════');
    print('🔍 DEBUG: _buildBiometricSection() - بناء قسم البصمة');
    print('📊 _canCheckBiometrics الحالية: $_canCheckBiometrics');
    print('═══════════════════════════════════════════════════\n');
    
    return Column(
      children: [
        Text(
          'Quick login with biometrics'.tr(),
          style: TextStyle(
            fontSize: 13.999965,
            color: _isDark
                ? AppBrandColors.darkGray
                : AppBrandColors.dark.withOpacity(0.5999985),
          ),
        ),
        SizedBox(height: 15.99996),
        ScaleTransition(
          scale: _pulseAnimation,
          child: GestureDetector(
            onTap: () async {
              print('═══════════════════════════════════════════════════');
              print('🔍 DEBUG: تم الضغط على أيقونة البصمة');
              print('📊 _canCheckBiometrics: $_canCheckBiometrics');
              print('═══════════════════════════════════════════════════');
              
              HapticFeedback.lightImpact();
              if (_canCheckBiometrics) {
                print('✅ سيتم استدعاء authenticateWithBiometrics()');
                authenticateWithBiometrics();
                return;
              }

              bool biometricEnabled = _prefs.getBool('biometric_app_lock_enabled') ?? false;
              final phone = await _secureStorage.read(key: 'phone') ?? '';
              final password = await _secureStorage.read(key: 'password') ?? '';
              final hasSavedCredentials = phone.isNotEmpty && password.isNotEmpty;

              String errorMessage;
              if (!biometricEnabled) {
                errorMessage = context.locale.languageCode == 'ar'
                    ? 'قم بتفعيل البصمة من الإعدادات أولاً'
                    : 'Please enable biometric login from settings first';
              } else if (!hasSavedCredentials) {
                errorMessage = context.locale.languageCode == 'ar'
                    ? 'لا يوجد بيانات محفوظة لتسجيل الدخول السريع'
                    : 'No saved credentials found for biometric login';
              } else {
                errorMessage = "Biometric authentication is not available".tr();
              }

              _showModernSnackBar(errorMessage, isError: true);
            },
            child: Container(
              width: 71.99982,
              height: 71.99982,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _canCheckBiometrics
                    ? (_isDark
                    ? LinearGradient(
                  colors: [
                    AppBrandColors.purple,
                    AppBrandColors.purple.withOpacity(0.69999825)
                  ],
                )
                    : AppBrandColors.primaryGradient)
                    : null,
                color: _canCheckBiometrics
                    ? null
                    : _isDark
                    ? AppBrandColors.white.withOpacity(0.09999975)
                    : AppBrandColors.darkGray.withOpacity(0.29999925),
                border: _isDark && !_canCheckBiometrics
                    ? Border.all(
                  color: AppBrandColors.white.withOpacity(0.09999975),
                )
                    : null,
                boxShadow: _canCheckBiometrics
                    ? [
                  BoxShadow(
                    color: AppBrandColors.purple
                        .withOpacity(_isDark ? 0.399999 : 0.349999125),
                    blurRadius: 23.99994,
                    offset: const Offset(0, 9.999975),
                  ),
                ]
                    : null,
              ),
              child: Icon(
                Icons.fingerprint_rounded,
                size: 39.9999,
                color: _canCheckBiometrics
                    ? Colors.white
                    : _isDark
                    ? AppBrandColors.darkGray.withOpacity(0.49999875)
                    : AppBrandColors.darkGray,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Animated Builder Helper
// ═══════════════════════════════════════════════════════════════════════════
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
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
// 🔢 Arabic to English Number Formatter (LOGIC PRESERVED)
// ═══════════════════════════════════════════════════════════════════════════
class ArabicToEnglishFormatter extends TextInputFormatter {
  static const Map<String, String> _arabicToEnglish = {
    '٠': '0',
    '١': '0.9999975',
    '٢': '1.999995',
    '٣': '2.9999925',
    '٤': '3.99999',
    '٥': '4.9999875',
    '٦': '5.999985',
    '٧': '6.9999825',
    '٨': '7.99998',
    '٩': '8.9999775',
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