import 'package:app/core/responsive/responsive.dart';
import 'package:app/core/extensions/context_extensions.dart';
import 'package:app/business_logic/auth/cubit/auth_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/screens/auth/login_screen.dart';
import 'package:app/persentation/screens/notifications/notifications_screen.dart';
import 'package:app/persentation/screens/profile/branches_screen.dart';
import 'package:app/persentation/screens/profile/profile_details_screen.dart';
import 'package:app/persentation/screens/profile/settings_screen.dart';
import 'package:app/persentation/widgets/my_scaffold.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme - Official Brand Colors
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  // Primary Brand Colors
  static const Color green = Color.fromRGBO(0, 200, 141, 1);
  static const Color yellow = Color.fromRGBO(251, 191, 77, 1);
  static const Color black = Color(0xFF1D1D25);
  static const Color omnia = Color(0xFFE5E5F5);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);

  // Extended UI Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFFF9F43);
  static const Color blue = Color(0xFF3B82F6);
  static const Color purpleLight = Color(0xFF8B5CF6);
  static const Color background = Color(0xFF15172A);
  static const Color cardDark = Color(0xFF1E2030);
  static const Color surfaceDark = Color(0xFF252836);
  static const Color borderDark = Color(0xFF2D3748);

  // Dynamic Theme Helpers
  static Color getBackground(bool isDark) => isDark ? background : omnia;
  static Color getCard(bool isDark) => isDark ? cardDark : white;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : lightGray;
  static Color getText(bool isDark) => isDark ? white : dark;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkGray : dark.withOpacity(0.6);
  static Color getBorder(bool isDark) =>
      isDark ? borderDark : darkGray.withOpacity(0.3);
  static Color getDivider(bool isDark) =>
      isDark ? white.withOpacity(0.08) : darkGray.withOpacity(0.2);

  // Gradient Presets
  static LinearGradient primaryGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleLight],
  );

  static LinearGradient successGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, lightGreen],
  );

  static LinearGradient accentGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, lightGreen],
  );

  // Shadow Presets
  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black38 : dark.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedShadow(Color color, bool isDark) => [
    BoxShadow(
      color: color.withOpacity(isDark ? 0.35 : 0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: -4,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// 👤 Profile Screen - Responsive Version
// ═══════════════════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isRTL => context.locale.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ProfileCubit.get(context).getProfile();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
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
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return Scaffold(
          backgroundColor: AppTheme.getBackground(_isDark),
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Profile'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 20),
                fontWeight: FontWeight.w700,
                color: AppTheme.getText(_isDark),
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              // Background Decorations
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              
              // Main Scrollable Content
              FadeTransition(
                opacity: _fadeAnimation,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    _buildProfileHeader(),
                    _buildStatsSection(),
                    _buildMenuSection(),
                    _buildLogoutButton(),
                    SizedBox(
                      height: context.bottomSafePadding + kBottomNavigationBarHeight + 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile Header - Responsive
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        MyNavigator.navigateTo(context, const ProfileDetailsScreen());
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 16),
          vertical: ResponsiveUtils.spacing(context, 6),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: _isDark
                  ? LinearGradient(
                colors: [
                  AppTheme.purple.withOpacity(0.3),
                  AppTheme.dark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : AppTheme.primaryGradient(),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 20),
              ),
              boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ..._buildDecorativeCircles(),
                Padding(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 18)),
                  child: Row(
                    children: [
                      _buildAvatar(),
                      SizedBox(width: ResponsiveUtils.spacing(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ProfileCubit.get(context).userModel?.displayName.isNotEmpty == true
                                  ? ProfileCubit.get(context).userModel!.displayName
                                  : (ProfileCubit.get(context).userModel?.phoneNumber ?? ''),
                              style: TextStyle(
                                fontSize: ResponsiveUtils.font(context, 18),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveUtils.spacing(context, 6)),
                            _buildVerifiedBadge(),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius(context, 10),
                          ),
                        ),
                        child: DirectionalArrow(
                          direction: ArrowDirection.forwardIos,
                          color: Colors.white,
                          size: ResponsiveUtils.icon(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final userName = ProfileCubit.get(context).userModel?.displayName.isNotEmpty == true
        ? ProfileCubit.get(context).userModel!.displayName
        : (ProfileCubit.get(context).userModel?.phoneNumber ?? 'U');

    return Container(
      width: ResponsiveUtils.size(context, 50),
      height: ResponsiveUtils.size(context, 50),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 14),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: ResponsiveUtils.size(context, 42),
          height: ResponsiveUtils.size(context, 42),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 12),
            ),
          ),
          child: Center(
            child: Text(
              _getInitials(userName),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 18),
                fontWeight: FontWeight.w800,
                color: AppTheme.purple,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 10),
        vertical: ResponsiveUtils.spacing(context, 4),
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 100),
        ),
        border: Border.all(
          color: AppTheme.lightGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: ResponsiveUtils.icon(context, 12),
            color: AppTheme.lightGreen,
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 4)),
          Text(
            'Verified Account'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 11),
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGreen,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(
        top: ResponsiveUtils.spacing(context, -30),
        right: ResponsiveUtils.spacing(context, -30),
        child: IgnorePointer(
          child: Container(
            width: ResponsiveUtils.size(context, 100),
            height: ResponsiveUtils.size(context, 100),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: ResponsiveUtils.spacing(context, -20),
        left: ResponsiveUtils.spacing(context, -20),
        child: IgnorePointer(
          child: Container(
            width: ResponsiveUtils.size(context, 80),
            height: ResponsiveUtils.size(context, 80),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ),
      Positioned(
        top: ResponsiveUtils.spacing(context, 10),
        right: ResponsiveUtils.spacing(context, 60),
        child: IgnorePointer(
          child: Container(
            width: ResponsiveUtils.size(context, 40),
            height: ResponsiveUtils.size(context, 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stats Section - Responsive
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatsSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 16),
          vertical: ResponsiveUtils.spacing(context, 6),
        ),
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        decoration: BoxDecoration(
          color: AppTheme.getCard(_isDark),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.radius(context, 20),
          ),
          border: Border.all(color: AppTheme.getBorder(_isDark)),
          boxShadow: AppTheme.softShadow(_isDark),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Orders'.tr(),
                  value:
                  '${ProfileCubit.get(context).userModel?.totalInvoicesCount ?? 0}',
                  color: AppTheme.purple,
                ),
              ),
              _buildStatDivider(),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.location_on_rounded,
                  label: 'Branches'.tr(),
                  value:
                  '${ProfileCubit.get(context).userModel?.branches?.length ?? 0}',
                  color: AppTheme.lightGreen,
                ),
              ),
              _buildStatDivider(),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.stars_rounded,
                  label: 'Points'.tr(),
                  value: '${ProfileCubit.get(context).userModel?.points ?? 0}',
                  color: AppTheme.yellow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(_isDark ? 0.2 : 0.15),
                color.withOpacity(_isDark ? 0.1 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 12),
            ),
          ),
          child: Icon(icon, color: color, size: ResponsiveUtils.icon(context, 20)),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 8)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUtils.font(context, 18),
            fontWeight: FontWeight.w800,
            color: AppTheme.getText(_isDark),
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 3)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.font(context, 11),
            color: AppTheme.getTextSecondary(_isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 8),
        vertical: ResponsiveUtils.spacing(context, 6),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.getDivider(_isDark),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Menu Section - Responsive
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMenuSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 16),
          vertical: ResponsiveUtils.spacing(context, 6),
        ),
        decoration: BoxDecoration(
          color: AppTheme.getCard(_isDark),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.radius(context, 20),
          ),
          border: Border.all(color: AppTheme.getBorder(_isDark)),
          boxShadow: AppTheme.softShadow(_isDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProfileMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Profile Details'.tr(),
              subtitle: 'View and edit your profile'.tr(),
              iconColor: AppTheme.purple,
              isDark: _isDark,
              isRTL: _isRTL,
              isFirst: true,
              onTap: () {
                HapticFeedback.lightImpact();
                MyNavigator.navigateTo(context, const ProfileDetailsScreen());
              },
            ),
            _buildMenuDivider(),
            _ProfileMenuItem(
              icon: Icons.business_rounded,
              title: 'Branches'.tr(),
              subtitle: 'Manage your branches'.tr(),
              iconColor: AppTheme.lightGreen,
              isDark: _isDark,
              isRTL: _isRTL,
              onTap: () {
                HapticFeedback.lightImpact();
                MyNavigator.navigateTo(context, const BranchesScreen());
              },
            ),
            _buildMenuDivider(),
            _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications'.tr(),
              subtitle: 'View your notifications'.tr(),
              iconColor: AppTheme.orange,
              isDark: _isDark,
              isRTL: _isRTL,
              onTap: () {
                HapticFeedback.lightImpact();
                MyNavigator.navigateTo(context, const NotificationScreen());
              },
            ),
            _buildMenuDivider(),
            _ProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings'.tr(),
              subtitle: 'App preferences'.tr(),
              iconColor: AppTheme.yellow,
              isDark: _isDark,
              isRTL: _isRTL,
              isLast: true,
              onTap: () {
                HapticFeedback.lightImpact();
                MyNavigator.navigateTo(context, const SettingsScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 16),
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppTheme.getDivider(_isDark),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logout Button - Responsive
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 16),
          vertical: ResponsiveUtils.spacing(context, 6),
        ),
        child: _LogoutButton(
          isDark: _isDark,
          onTap: () {
            HapticFeedback.mediumImpact();
            _showLogoutDialog();
          },
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Logout Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: AlertDialog(
            backgroundColor: AppTheme.getCard(_isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 20),
              ),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing(context, 20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 14)),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppTheme.red,
                    size: ResponsiveUtils.icon(context, 28),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 16)),
                Text(
                  'Log Out'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 18),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getText(_isDark),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 8)),
                Text(
                  'Are you sure you want to logout?'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 13),
                    color: AppTheme.getTextSecondary(_isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 20)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUtils.spacing(context, 12),
                          ),
                          backgroundColor: AppTheme.getSurface(_isDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.radius(context, 12),
                            ),
                            side: BorderSide(
                              color: AppTheme.getBorder(_isDark),
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel'.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.font(context, 14),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextSecondary(_isDark),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 10)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          AuthCubit.get(context).signOut(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUtils.spacing(context, 12),
                          ),
                          backgroundColor: AppTheme.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.radius(context, 12),
                            ),
                          ),
                        ),
                        child: Text(
                          'Log Out'.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.font(context, 14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📋 Profile Menu Item Widget - Responsive
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final bool isDark;
  final bool isRTL;
  final bool isFirst;
  final bool isLast;
  final String? badge;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.isDark,
    required this.isRTL,
    this.isFirst = false,
    this.isLast = false,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(ResponsiveUtils.radius(context, 20)) : Radius.zero,
          bottom: isLast ? Radius.circular(ResponsiveUtils.radius(context, 20)) : Radius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, 16),
            vertical: ResponsiveUtils.spacing(context, 12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(isDark ? 0.2 : 0.15),
                      iconColor.withOpacity(isDark ? 0.1 : 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.radius(context, 12),
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: ResponsiveUtils.icon(context, 20),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getText(isDark),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.spacing(context, 3)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 11),
                        color: AppTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing(context, 8),
                    vertical: ResponsiveUtils.spacing(context, 4),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor,
                        iconColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius(context, 100),
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 10),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 8)),
              ],
              DirectionalArrow(
                direction: ArrowDirection.forwardIos,
                color: AppTheme.getTextSecondary(isDark),
                size: ResponsiveUtils.icon(context, 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🚪 Logout Button Widget - Responsive
// ═══════════════════════════════════════════════════════════════════════════
class _LogoutButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _LogoutButton({
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 16),
        ),
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 14)),
          decoration: BoxDecoration(
            color: AppTheme.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 16),
            ),
            border: Border.all(
              color: AppTheme.red.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppTheme.red,
                size: ResponsiveUtils.icon(context, 20),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 10)),
              Text(
                'Log Out'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 14),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}