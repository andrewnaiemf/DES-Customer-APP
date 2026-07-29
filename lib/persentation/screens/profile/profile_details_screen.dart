import 'package:app/core/responsive/responsive.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme Constants
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color purple = Color(0xFF6842E2);
  static const Color purpleLight = Color(0xFF8B5CF6);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color green = Color(0xFF10B981);
  static const Color yellow = Color(0xFFFBBF4D);
  static const Color orange = Color(0xFFFF9F43);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color black = Color(0xFF1D1D25);
  static const Color dark = Color(0xFF081428);
  static const Color background = Color(0xFF0F1120);
  static const Color cardDark = Color(0xFF1A1D2E);
  static const Color surfaceDark = Color(0xFF252836);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF5F6FA);
  static const Color white = Color(0xFFFFFFFF);

  // Dynamic Theme Helpers
  static Color getBackground(bool isDark) => isDark ? background : lightGray;
  static Color getCard(bool isDark) => isDark ? cardDark : white;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : lightGray;
  static Color getText(bool isDark) => isDark ? white : black;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkGray.withOpacity(0.7) : black.withOpacity(0.5);
  static Color getBorder(bool isDark) =>
      isDark ? white.withOpacity(0.06) : darkGray.withOpacity(0.2);
}

// ═══════════════════════════════════════════════════════════════════════════
// 👤 Profile Details Screen
// ═══════════════════════════════════════════════════════════════════════════
class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    await ProfileCubit.get(context).getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackground(_isDark),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user = ProfileCubit.get(context).userModel;
          final isLoading = state is GetProfileLoading;

          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.purple,
              backgroundColor: AppTheme.getCard(_isDark),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader(user)),

                  // Content
                  if (isLoading)
                    SliverToBoxAdapter(child: _buildLoading())
                  else ...[
                    // Quick Stats
                    SliverToBoxAdapter(child: _buildQuickStats(user)),

                    // Info Sections
                    SliverToBoxAdapter(child: _buildInfoSections(user)),

                    // Bottom Space
                    SliverToBoxAdapter(
                      child: SizedBox(height: ResponsiveUtils.spacing(context, 100)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(UserModel? user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.purple.withOpacity(_isDark ? 0.2 : 0.1),
            AppTheme.getBackground(_isDark),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, 16),
                vertical: ResponsiveUtils.spacing(context, 12),
              ),
              child: Row(
                children: [
                  _IconButton(
                    icon: Icons.arrow_back_ios_rounded,
                    onTap: () => MyNavigator.back(context),
                    isDark: _isDark,
                  ),
                  const Spacer(),
                  Text(
                    'Profile'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 18),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getText(_isDark),
                    ),
                  ),
                  const Spacer(),
                  _IconButton(
                    icon: Icons.refresh_rounded,
                    onTap: _onRefresh,
                    isDark: _isDark,
                  ),
                ],
              ),
            ),

            // Avatar & Name
            SizedBox(height: ResponsiveUtils.spacing(context, 20)),
            _buildAvatar(user),
            SizedBox(height: ResponsiveUtils.spacing(context, 16)),
            Text(
              user?.name ?? 'User Name',
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 22),
                fontWeight: FontWeight.bold,
                color: AppTheme.getText(_isDark),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 6)),
            Text(
              user?.organization ?? 'Organization',
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 14),
                color: AppTheme.getTextSecondary(_isDark),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel? user) {
    final initials = _getInitials(user?.name ?? 'U');

    return Container(
      width: ResponsiveUtils.size(context, 90),
      height: ResponsiveUtils.size(context, 90),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.purple, AppTheme.purpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: ResponsiveUtils.font(context, 28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Quick Stats
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuickStats(UserModel? user) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 16),
      ),
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 4)),
      decoration: BoxDecoration(
        color: AppTheme.getCard(_isDark),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
        border: Border.all(color: AppTheme.getBorder(_isDark)),
      ),
      child: Row(
        children: [
          _StatItem(
            value: '${user?.totalInvoicesCount ?? 0}',
            label: 'Orders'.tr(),
            color: AppTheme.purple,
            isDark: _isDark,
          ),
          _VerticalDivider(isDark: _isDark),
          _StatItem(
            value: '${user?.points ?? 0}',
            label: 'Points'.tr(),
            color: AppTheme.yellow,
            isDark: _isDark,
          ),
          _VerticalDivider(isDark: _isDark),
          _StatItem(
            value: '${user?.branches?.length ?? 0}',
            label: 'Branches'.tr(),
            color: AppTheme.lightGreen,
            isDark: _isDark,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Info Sections
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildInfoSections(UserModel? user) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Section
          _SectionCard(
            title: 'Contact'.tr(),
            isDark: _isDark,
            children: [
              _InfoRow(
                icon: Icons.phone_rounded,
                label: 'Phone'.tr(),
                value: user?.phoneNumber ?? 'N/A',
                color: AppTheme.lightGreen,
                isDark: _isDark,
              ),
              _InfoRow(
                icon: Icons.email_rounded,
                label: 'Email'.tr(),
                value: user?.email ?? 'N/A',
                color: AppTheme.blue,
                isDark: _isDark,
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 16)),

          // Company Section
          _SectionCard(
            title: 'Company'.tr(),
            isDark: _isDark,
            children: [
              _InfoRow(
                icon: Icons.business_rounded,
                label: 'Organization'.tr(),
                value: user?.organization ?? 'N/A',
                color: AppTheme.purple,
                isDark: _isDark,
              ),
              _InfoRow(
                icon: Icons.receipt_long_rounded,
                label: 'Tax Number'.tr(),
                value: user?.taxNumber ?? 'N/A',
                color: AppTheme.orange,
                isDark: _isDark,
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 16)),

          // Financial Section
          _SectionCard(
            title: 'Financial'.tr(),
            isDark: _isDark,
            children: [
              _FinanceRow(
                items: [
                  _FinanceItem(
                    label: 'Balance'.tr(),
                    value: '${user?.closingBalance ?? 0}',
                    color: AppTheme.green,
                  ),
                  _FinanceItem(
                    label: 'Outstanding'.tr(),
                    value: '${user?.totalOutStanding ?? 0}',
                    color: AppTheme.orange,
                  ),
                  _FinanceItem(
                    label: 'Overdue'.tr(),
                    value: '${user?.overdue ?? 0}',
                    color: AppTheme.red,
                  ),
                ],
                isDark: _isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Loading State
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      child: Column(
        children: [
          _Shimmer(
            height: ResponsiveUtils.size(context, 80),
            borderRadius: 20,
            isDark: _isDark,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 16)),
          _Shimmer(
            height: ResponsiveUtils.size(context, 150),
            borderRadius: 20,
            isDark: _isDark,
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 16)),
          _Shimmer(
            height: ResponsiveUtils.size(context, 150),
            borderRadius: 20,
            isDark: _isDark,
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🧩 Components
// ═══════════════════════════════════════════════════════════════════════════

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: ResponsiveUtils.size(context, 44),
        height: ResponsiveUtils.size(context, 44),
        decoration: BoxDecoration(
          color: AppTheme.getCard(isDark),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
          border: Border.all(color: AppTheme.getBorder(isDark)),
        ),
        child: Icon(
          icon,
          size: ResponsiveUtils.icon(context, 20),
          color: AppTheme.getText(isDark),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.spacing(context, 16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 20),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 4)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 12),
                color: AppTheme.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final bool isDark;

  const _VerticalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: ResponsiveUtils.size(context, 40),
      color: AppTheme.getBorder(isDark),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;

  const _SectionCard({
    required this.title,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDark),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 16),
                fontWeight: FontWeight.w600,
                color: AppTheme.getText(isDark),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.getBorder(isDark),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  void _copy(BuildContext context) {
    if (value == 'N/A') return;
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied'.tr()),
        backgroundColor: AppTheme.lightGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _copy(context),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
        child: Row(
          children: [
            Container(
              width: ResponsiveUtils.size(context, 40),
              height: ResponsiveUtils.size(context, 40),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.icon(context, 20),
                color: color,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 12),
                      color: AppTheme.getTextSecondary(isDark),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 15),
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getText(isDark),
                    ),
                  ),
                ],
              ),
            ),
            if (value != 'N/A')
              Icon(
                Icons.copy_rounded,
                size: ResponsiveUtils.icon(context, 18),
                color: AppTheme.getTextSecondary(isDark),
              ),
          ],
        ),
      ),
    );
  }
}

class _FinanceItem {
  final String label;
  final String value;
  final Color color;

  const _FinanceItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _FinanceRow extends StatelessWidget {
  final List<_FinanceItem> items;
  final bool isDark;

  const _FinanceRow({
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, 4),
              ),
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 14)),
              decoration: BoxDecoration(
                color: item.color.withOpacity(isDark ? 0.1 : 0.08),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
              ),
              child: Column(
                children: [
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 16),
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                  Text(
                    'SAR'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 10),
                      color: AppTheme.getTextSecondary(isDark),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 6)),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 11),
                      color: AppTheme.getTextSecondary(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double height;
  final double borderRadius;
  final bool isDark;

  const _Shimmer({
    required this.height,
    required this.borderRadius,
    required this.isDark,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-2 + (_controller.value * 4), 0),
              end: Alignment(-1 + (_controller.value * 4), 0),
              colors: widget.isDark
                  ? [
                AppTheme.cardDark,
                AppTheme.surfaceDark,
                AppTheme.cardDark,
              ]
                  : [
                Colors.grey[200]!,
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, null);
}