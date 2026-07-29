import 'dart:io';

import 'package:app/business_logic/AppVersionCubit/app_version_cubit.dart';
import 'package:app/core/responsive/responsive.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/screens/auth/reset_change_password_screen.dart';
import 'package:app/persentation/screens/orders/products_screen.dart';
import 'package:app/persentation/screens/profile/change_password_screen.dart';
import 'package:app/persentation/widgets/my_scaffold.dart';
import 'package:app/persentation/widgets/textFormField.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/theme/colors.dart';
import 'package:app/core/tour/app_tour_service.dart';
import 'package:app/core/tour/tour_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:app/core/services/biometric_service.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_success_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../functions/open_map.dart';
import '../../../models/VersionModel.dart';
// ==================== App Theme Colors ====================
class AppTheme {
  static const Color yellow = Color.fromRGBO(215, 178, 27, 0.9999975);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color red = Color(0xFFFF4757);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Biometric Authentication - تم حذف المتغيرات القديمة
  // سيتم استخدام BiometricService بدلاً من ذلك

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    context.read<AppVersionCubit>().getAppVersion();
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 799),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5999985, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.09999975),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1999995, 0.9999975, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }
  bool isLatestVersion(String appVersion, String currentVersion) {
    List<int> parse(String v) =>
        v.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final app = parse(appVersion);
    final current = parse(currentVersion);

    for (int i = 0; i < 3; i++) {
      final a = i < app.length ? app[i] : 0;
      final c = i < current.length ? current[i] : 0;

      if (a < c) return false; // update available
      if (a > c) return true;
    }
    return true;
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Settings'.tr(),
      showBackButton: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Section
                _buildHeader(),
                // Settings Sections
                _buildSecuritySection(),
                _buildAppearanceSection(),
                _buildLanguageSection(),
                _buildAboutSection(),
                // 🧪 Debug Section (only in debug mode)
                if (kDebugMode) _buildDebugSection(),
                // Bottom Spacing
                SizedBox(height: 99.99975),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Header ====================
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
      padding: const EdgeInsets.all(23.99994),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.purple.withOpacity(0.29999925), AppTheme.dark]
              : [AppTheme.purple.withOpacity(0.09999975), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23.99994),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withOpacity(0.29999925)
                : AppTheme.purple.withOpacity(0.09999975),
            blurRadius: 19.99995,
            offset: const Offset(0, 7.99998),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(15.99996),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
              ),
              borderRadius: BorderRadius.circular(17.999955),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withOpacity(0.399999),
                  blurRadius: 11.99997,
                  offset: const Offset(0, 5.999985),
                ),
              ],
            ),
            child: SvgPicture.asset(
              Assets.logoicon,
              width: 27.99993,
              height: 27.99993,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 17.999955),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customize Your Experience'.tr(),
                  style: TextStyle(
                    fontSize: 16.9999575,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: 5.999985),
                Text(
                  'Personalize app settings'.tr(),
                  style: TextStyle(
                    fontSize: 12.9999675,
                    color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Security Section ====================
  Widget _buildSecuritySection() {
    return _SettingsSection(
      title: 'Security'.tr(),
      icon: Icons.shield_outlined,
      isDark: _isDark,
      children: [
        _SettingsItem(
          icon: Icons.lock_outline_rounded,
          iconColor: AppTheme.purple,
          title: 'Password'.tr(),
          subtitle: 'Change your password'.tr(),
          isDark: _isDark,
          onTap: () {
            HapticFeedback.lightImpact();
            MyNavigator.navigateTo(context, ChangePasswordScreen());
          },
          trailing: _buildArrowIcon(),
        ),
        _SettingsItem(
          key: TourController.biometricKey, // 🔐 مفتاح التور للبصمة
          icon: Icons.fingerprint_rounded,
          iconColor: AppTheme.lightGreen,
          title: 'Biometric Login'.tr(),
          subtitle: 'Use fingerprint or face ID'.tr(),
          isDark: _isDark,
          isLast: true,  // ✅ آخر عنصر الآن
          trailing: _buildBiometricSwitch(),  // ✅ ربط بنظام البصمة
        ),
      ],
    );
  }

  // ==================== Biometric Switch ====================
  Widget _buildBiometricSwitch() {
    return FutureBuilder<bool>(
      future: BiometricService.instance.isBiometricLockEnabled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;
        return _buildSwitch(isEnabled, (val) async {
          await _handleBiometricToggle(val);
        });
      },
    );
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      // تفعيل قفل التطبيق بالبصمة
      await _enableBiometricLock();
    } else {
      // إلغاء تفعيل قفل التطبيق
      await _disableBiometricLock();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 تفعيل قفل التطبيق بالبصمة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _enableBiometricLock() async {
    log('═══════════════════════════════════════════════════');
    log('� Settings: تفعيل قفل التطبيق بالبصمة');
    log('═══════════════════════════════════════════════════');

    try {
      final result = await BiometricService.instance.enableBiometricLock();

      String message;
      bool isError;

      switch (result) {
        case BiometricResult.success:
          message = 'app_lock_enabled'.tr();
          isError = false;
          log('✅ تم تفعيل قفل التطبيق بنجاح');
          break;

        case BiometricResult.deviceNotSupported:
          message = 'device_not_support_biometric'.tr();
          isError = true;
          log('❌ الجهاز لا يدعم البصمة');
          break;

        case BiometricResult.notLoggedIn:
          message = 'please_login_first'.tr();
          isError = true;
          log('❌ المستخدم غير مسجل دخول');
          break;

        case BiometricResult.authenticationFailed:
          message = 'biometric_auth_failed'.tr();
          isError = true;
          log('❌ فشلت المصادقة');
          break;

        case BiometricResult.error:
          message = 'biometric_error'.tr();
          isError = true;
          log('❌ خطأ في التفعيل');
          break;
      }

      setState(() {});
      _showSnackBar(message, isError: isError);

    } catch (e) {
      log('❌ Settings: خطأ في تفعيل البصمة: $e');
      _showSnackBar('biometric_error'.tr(), isError: true);
    }

    log('═══════════════════════════════════════════════════\n');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❌ تعطيل قفل التطبيق بالبصمة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _disableBiometricLock() async {
    log('═══════════════════════════════════════════════════');
    log('� Settings: تعطيل قفل التطبيق بالبصمة');
    log('═══════════════════════════════════════════════════');

    try {
      final success = await BiometricService.instance.disableBiometricLock();

      if (success) {
        log('✅ تم تعطيل قفل التطبيق بنجاح');
        setState(() {});
        _showSnackBar('app_lock_disabled'.tr(), isError: false);
      } else {
        log('❌ فشل تعطيل قفل التطبيق');
        _showSnackBar('biometric_error'.tr(), isError: true);
      }

    } catch (e) {
      log('❌ Settings: خطأ في تعطيل البصمة: $e');
      _showSnackBar('biometric_error'.tr(), isError: true);
    }

    log('═══════════════════════════════════════════════════\n');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.red : AppTheme.lightGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(19.99995),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11.99997),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==================== Appearance Section ====================
  Widget _buildAppearanceSection() {
    return Consumer<AppThemeProvider>(
      builder: (context, themeProvider, child) {
        return _SettingsSection(
          title: 'Appearance'.tr(),
          icon: Icons.palette_outlined,
          isDark: _isDark,
          children: [
            _SettingsItem(
              key: TourController.darkModeSettingKey, // 🌙 مفتاح التور
              icon: themeProvider.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              iconColor: themeProvider.isDarkMode
                  ? AppTheme.purple
                  : AppTheme.yellow,
              title: 'Dark Mode'.tr(),
              subtitle: themeProvider.isDarkMode
                  ? 'Currently using dark theme'.tr()
                  : 'Currently using light theme'.tr(),
              isDark: _isDark,
              isLast: true,
              trailing: _buildAnimatedThemeSwitch(themeProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedThemeSwitch(AppThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        themeProvider.toggleTheme();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 299),
        width: 69.999825,
        height: 35.99991,
        padding: const EdgeInsets.all(2.9999925),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.isDarkMode
                ? [AppTheme.purple, AppTheme.purple.withBlue(254)]
                : [AppTheme.darkGray.withOpacity(0.29999925), AppTheme.darkGray.withOpacity(0.1999995)],
          ),
          borderRadius: BorderRadius.circular(19.99995),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 299),
          curve: Curves.easeOutCubic,
          alignment: themeProvider.isDarkMode
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 29.999925,
            height: 29.999925,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1999995),
                  blurRadius: 5.999985,
                  offset: const Offset(0, 1.999995),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 199),
                child: Icon(
                  themeProvider.isDarkMode
                      ? Icons.nights_stay_rounded
                      : Icons.wb_sunny_rounded,
                  key: ValueKey(themeProvider.isDarkMode),
                  size: 17.999955,
                  color: themeProvider.isDarkMode
                      ? AppTheme.purple
                      : AppTheme.yellow,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Language Section ====================
  Widget _buildLanguageSection() {
    return _SettingsSection(
      key: TourController.languageKey, // 🌐 مفتاح التور
      title: 'Language'.tr(),
      icon: Icons.language_rounded,
      isDark: _isDark,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.99996),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9.999975),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen.withOpacity(0.149999625),
                      borderRadius: BorderRadius.circular(11.99997),
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      color: AppTheme.lightGreen,
                      size: 21.999945,
                    ),
                  ),
                  SizedBox(width: 13.999965),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Language'.tr(),
                          style: TextStyle(
                            fontSize: 14.9999625,
                            fontWeight: FontWeight.w600,
                            color: _isDark ? Colors.white : AppTheme.black,
                          ),
                        ),
                        SizedBox(height: 3.99999),
                        Text(
                          'Choose your preferred language'.tr(),
                          style: TextStyle(
                            fontSize: 11.99997,
                            color: _isDark ? AppTheme.darkGray : Colors.grey[499],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 19.99995),
              // Language Options
              _buildLanguageOptions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOptions() {
    return Row(
      children: [
        Expanded(
          child: _LanguageOption(
            language: 'العربية',
            flag: '🇸🇦',
            isSelected: context.locale.languageCode == 'ar',
            isDark: _isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              TranslationCubit.get(context).changAppLang(context, 'ar');
            },
          ),
        ),
        SizedBox(width: 11.99997),
        Expanded(
          child: _LanguageOption(
            language: 'English',
            flag: '🇺🇸',
            isSelected: context.locale.languageCode == 'en',
            isDark: _isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              TranslationCubit.get(context).changAppLang(context, 'en');
            },
          ),
        ),
      ],
    );
  }

  // ==================== About Section ====================
  Widget _buildAboutSection() {
    return _SettingsSection(
      title: 'About'.tr(),
      icon: Icons.info_outline_rounded,
      isDark: _isDark,
      children: [
        _SettingsItem(
          key: TourController.restartTourKey, // 🔄 مفتاح التور
          icon: Icons.help_outline_rounded,
          iconColor: AppTheme.purple,
          title: 'الجولة الإرشادية',
          subtitle: 'شاهد شرح التطبيق مرة أخرى',
          isDark: _isDark,
          onTap: () {
            HapticFeedback.lightImpact();
            _showRestartTourDialog();
          },
          trailing: _buildArrowIcon(),
        ),
        _SettingsItem(
          icon: Icons.privacy_tip_outlined,
          iconColor: AppTheme.lightGreen,
          title: 'Privacy Policy'.tr(),
          subtitle: 'How we handle your data'.tr(),
          isDark: _isDark,
          onTap: () async {
            HapticFeedback.lightImpact();
            final url = Uri.parse('https://destrading.net/privacy-policy/');
            try {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          },
          trailing: _buildArrowIcon(),
        ),
        BlocBuilder<AppVersionCubit, AppVersionState>(
          builder: (context, state) {

            if (state is AppVersionLoading) {
              return const CircularProgressIndicator();
            }
            //
            // if (state is AppVersionError) {
            //   return const Text("Version Error");
            // }

            if (state is AppVersionLoaded) {

              final platformName = Platform.isIOS ? "ios" : "android";

              final platform = state.model.data
                  ?.first.platforms
                  ?.firstWhere(
                    (e) => e.platform == platformName,
                orElse: () => Platforms(currentVersion: "0.0.0"),
              );

              final isLatest = isLatestVersion(
                state.localVersion,
                platform?.currentVersion ?? "0.0.0",
              );

              return _SettingsItem(
                icon: Icons.info_outline_rounded,
                iconColor: AppTheme.darkGray,
                title: 'App Version'.tr(),
                subtitle: 'Version ${state.localVersion}',
                isDark: _isDark,
                isLast: true,
                onTap: (){
                  if(!isLatest){
                    if(Platform.isIOS){
                      openUrl(Constants.appleStore);
                    }else{
                      openUrl(Constants.googleStore);

                    }
                  }
                },
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLatest?(_isDark
                        ? AppTheme.lightGreen.withOpacity(0.2)
                        : AppTheme.lightGreen.withOpacity(0.15)):
                    (_isDark
                        ? AppTheme.red.withOpacity(0.2)
                        : AppTheme.red.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isLatest ? 'Latest'.tr() : 'Not Updated'.tr(),
                    style:  TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isLatest?AppTheme.lightGreen:AppTheme.red,
                    ),
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        )
      ],
    );
  }

  // ==================== 🧪 Debug Section (kDebugMode only) ====================
  Widget _buildDebugSection() {
    return _SettingsSection(
      title: '🧪 Developer Tools',
      icon: Icons.bug_report_rounded,
      isDark: _isDark,
      children: [
        _SettingsItem(
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF4CAF50),
          title: 'Warranty Success Screen',
          subtitle: 'Preview the success widget after warranty creation',
          isDark: _isDark,
          isLast: true,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WarrantySuccessScreen(),
              ),
            );
          },
          trailing: _buildArrowIcon(),
        ),
      ],
    );
  }

  // ==================== Helper Widgets ====================
  Widget _buildArrowIcon() {
    return Container(
      padding: const EdgeInsets.all(7.99998),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.09999975)
            : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(9.999975),
      ),
      child: DirectionalArrow(
        direction: ArrowDirection.forwardIos,
        color: _isDark ? AppTheme.darkGray : Colors.grey[399],
        size: 13.999965,
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.purple,
      activeTrackColor: AppTheme.purple.withOpacity(0.29999925),
    );
  }

  // ==================== Show Restart Tour Dialog ====================
  void _showRestartTourDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23.99994)),
        backgroundColor: _isDark ? AppTheme.dark : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9.999975),
              decoration: BoxDecoration(
                color: AppTheme.purple.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(11.99997),
              ),
              child: const Icon(Icons.help_outline_rounded, color: AppTheme.purple, size: 23.99994),
            ),
            SizedBox(width: 11.99997),
            Text(
              'الجولة الإرشادية',
              style: TextStyle(
                fontSize: 17.999955,
                fontWeight: FontWeight.bold,
                color: _isDark ? Colors.white : AppTheme.black,
              ),
            ),
          ],
        ),
        content: Text(
          'هل تريد مشاهدة الجولة الإرشادية مرة أخرى؟ سيتم عرض شرح لجميع ميزات التطبيق.',
          style: TextStyle(fontSize: 14.9999625, height: 1.49999625, color: _isDark ? AppTheme.darkGray : Colors.grey[699]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AppTourService.instance.resetAllTours();
              if (context.mounted) {
                // بدء جولة الإعدادات مباشرة بعد إعادة التعيين
                await Future.delayed(const Duration(milliseconds: 300));
                TourController().startSettingsTour(force: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white),
            child: const Text('إعادة الجولة'),
          ),
        ],
      ),
    );
  }
}

// ==================== Settings Section Widget ====================
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final List<Widget> children;

  const _SettingsSection({
    super.key, // ✅ إضافة key
    required this.title,
    required this.icon,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark : Colors.white,
        borderRadius: BorderRadius.circular(23.99994),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1999995)
                : Colors.black.withOpacity(0.049999875),
            blurRadius: 14.9999625,
            offset: const Offset(0, 4.9999875),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(19.99995, 19.99995, 19.99995, 9.999975),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7.99998),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.purple.withOpacity(0.1999995)
                        : AppTheme.purple.withOpacity(0.09999975),
                    borderRadius: BorderRadius.circular(9.999975),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? AppTheme.lightGreen : AppTheme.purple,
                    size: 17.999955,
                  ),
                ),
                SizedBox(width: 11.99997),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.999965,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkGray : Colors.grey[599],
                    letterSpacing: 0.49999875,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 0.9999975,
            margin: const EdgeInsets.symmetric(horizontal: 19.99995),
            color: isDark
                ? Colors.white.withOpacity(0.049999875)
                : AppTheme.darkGray.withOpacity(0.1999995),
          ),
          // Children
          ...children,
        ],
      ),
    );
  }
}

// ==================== Settings Item Widget ====================
class _SettingsItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final bool isLast;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsItem({
    super.key, // ✅ إضافة key
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.isLast = false,
    this.onTap,
    this.trailing,
  });

  @override
  State<_SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<_SettingsItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 149),
        padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 13.999965),
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.isDark
              ? Colors.white.withOpacity(0.049999875)
              : AppTheme.lightGray)
              : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            bottom: widget.isLast ? const Radius.circular(23.99994) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(9.999975),
              decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(11.99997),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 19.99995,
              ),
            ),
            SizedBox(width: 13.999965),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14.9999625,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  SizedBox(height: 3.99999),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 11.99997,
                      color: widget.isDark ? AppTheme.darkGray : Colors.grey[499],
                    ),
                  ),
                ],
              ),
            ),
            // Trailing
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
}

// ==================== Language Option Widget ====================
class _LanguageOption extends StatelessWidget {
  final String language;
  final String flag;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.flag,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 199),
        padding: const EdgeInsets.symmetric(vertical: 15.99996),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
          )
              : null,
          color: isSelected
              ? null
              : (isDark
              ? Colors.white.withOpacity(0.049999875)
              : AppTheme.lightGray),
          borderRadius: BorderRadius.circular(15.99996),
          border: isSelected
              ? null
              : Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.09999975)
                : AppTheme.darkGray.withOpacity(0.29999925),
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppTheme.purple.withOpacity(0.29999925),
              blurRadius: 11.99997,
              offset: const Offset(0, 5.999985),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 21.999945),
            ),
            SizedBox(width: 9.999975),
            Text(
              language,
              style: TextStyle(
                fontSize: 14.9999625,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : AppTheme.black),
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 7.99998),
              Container(
                padding: const EdgeInsets.all(3.99999),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1999995),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 13.999965,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
