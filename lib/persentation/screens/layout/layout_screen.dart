import 'package:app/core/responsive/responsive.dart';
import 'package:app/core/extensions/context_extensions.dart';
import 'package:app/core/deep_links/deep_link_service.dart';
import 'dart:ui' as ui;

import 'package:app/business_logic/layout/cubit/layout_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/persentation/screens/layout/widgets/user_bottom_nav_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/repors_screen.dart';
import '../warranty/warranty_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  static const Color primary = Color(0xFF6842E2);
  static const Color primaryLight = Color(0xFF8B6CEF);
  static const Color primaryDark = Color(0xFF5234B5);
  static const Color white = Colors.white;
  static const Color darkBackground = Color(0xFF0A0A12);
  static const Color darkCard = Color(0xFF14141F);
  static const Color lightBackground = Color(0xFFF5F7FA);

  static LinearGradient get darkBackgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A1040), Color(0xFF0D0D1A), Color(0xFF0A0A12)],
      );

  static LinearGradient get lightBackgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF8F9FC), Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
      );

  static Color background(bool isDark) => isDark ? darkBackground : lightBackground;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏠 Layout Screen - Optimized & Fast
// ═══════════════════════════════════════════════════════════════════════════
class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  bool _forceEnter = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isRTL => context.locale.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _setSystemUIOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = ProfileCubit.get(context);
      profile.getProfile(forceRefresh: profile.userModel == null);
      DeepLinkService.instance.consumePending(context);
    });

    // 🚀 Safety Timer: Force enter after 1.2s to prevent getting stuck
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _forceEnter = true);
    });
  }

  void _setSystemUIOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDark ? AppTheme.darkBackground : AppTheme.white,
        systemNavigationBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      ));
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, translationState) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<LayoutCubit, LayoutState>(
              builder: (context, layoutState) {
                final cubit = LayoutCubit.get(context);
                final profileCubit = ProfileCubit.get(context);
                
                // ⚡ Fast Logic: Show content if (API success) OR (Safety Timer triggered)
                final bool shouldShowContent = _forceEnter || profileCubit.userModel != null;
                final bool isLoading = !shouldShowContent;

                return Directionality(
                  textDirection: _isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                  child: Scaffold(
                    extendBody: true,
                    backgroundColor: AppTheme.background(_isDark),
                    body: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: isLoading 
                          ? _buildSimpleLoading() 
                          : _buildMainContent(cubit),
                    ),
                    bottomNavigationBar: isLoading
                        ? null
                        : SafeArea(
                            top: false,
                            child: _buildBottomNavBar(),
                          ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSimpleLoading() {
    return Container(
      key: const ValueKey('loading_simple'),
      decoration: BoxDecoration(
        gradient: _isDark ? AppTheme.darkBackgroundGradient : AppTheme.lightBackgroundGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _mainController,
              // child: SvgPicture.asset('assets/images/deslogo.svg', width: 90, height: 90),
              child: Image.asset('assets/images/logo.png', width: 250, height: 90),
              // child: Image.asset('assets/images/playstore.png', width: 90, height: 90),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(LayoutCubit cubit) {
    return IndexedStack(
      index: cubit.bottomNavBarIndex,
      children: [
        const HomeScreen(),
        const OrdersScreen(),
        const ReportsScreen(),
        WarrantyMainScreen(
          key: const ValueKey('warranty'),
          isActive: cubit.bottomNavBarIndex == 3,
        ),
        const ProfileScreen(),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.darkCard.withOpacity(0.95) : AppTheme.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const BottomNavBar(),
    );
  }
}
