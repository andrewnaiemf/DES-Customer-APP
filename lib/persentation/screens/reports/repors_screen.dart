import 'package:app/core/responsive/responsive.dart';
import 'package:app/core/extensions/context_extensions.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/business_logic/invoce/cubit/invoice_cubit.dart';
import 'package:app/business_logic/receipt/cubit/receipt_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/screens/account_statement/account_statement_screen.dart';
import 'package:app/persentation/screens/invoice/invoice_screen.dart';
import 'package:app/persentation/screens/overdue/overdue_screen.dart';
import 'package:app/persentation/screens/receipt/receipt_screen.dart';
import 'package:app/persentation/widgets/my_scaffold.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme - Official Brand Colors
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  static const Color green = Color.fromRGBO(0, 200, 141, 1);
  static const Color yellow = Color.fromRGBO(251, 191, 77, 1);
  static const Color black = Color(0xFF1D1D25);
  static const Color omnia = Color(0xFFE5E5F5);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFFF9F43);
  static const Color purpleLight = Color(0xFF8B5CF6);
  static const Color background = Color(0xFF15172A);
  static const Color cardDark = Color(0xFF1E2030);
  static const Color surfaceDark = Color(0xFF252836);
  static const Color borderDark = Color(0xFF2D3748);

  static Color getBackground(bool isDark) => isDark ? background : omnia;
  static Color getCard(bool isDark) => isDark ? cardDark : white;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : lightGray;
  static Color getText(bool isDark) => isDark ? white : dark;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkGray : dark.withOpacity(0.6);
  static Color getBorder(bool isDark) =>
      isDark ? borderDark : darkGray.withOpacity(0.3);

  static LinearGradient primaryGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleLight],
  );

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

  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 28.0;
  static const double radiusFull = 100.0;

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Reports Screen
// ═══════════════════════════════════════════════════════════════════════════
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  List<_ReportItemData> _getReportItems() {
    final totalOutStanding = ProfileCubit.get(context).userModel?.totalOutStanding.toInt() ?? 0;

    return [
      _ReportItemData(
        title: 'Invoices'.tr(),
        subtitle: 'View all invoices'.tr(),
        icon: Icons.receipt_long_rounded,
        color: AppTheme.purple,
        gradient: const [AppTheme.purple, AppTheme.purpleLight],
        onTap: () => MyNavigator.navigateTo(context, const InVoiceScreen()),
      ),
      _ReportItemData(
        title: 'Bonds'.tr(),
        subtitle: 'Payment receipts'.tr(),
        icon: Icons.account_balance_wallet_rounded,
        color: AppTheme.green,
        gradient: const [AppTheme.green, AppTheme.lightGreen],
        onTap: () => MyNavigator.navigateTo(context, const ReceiptScreen()),
      ),
      _ReportItemData(
        title: 'Indebtedness'.tr(),
        subtitle: 'Outstanding payments'.tr(),
        icon: Icons.trending_down_rounded,
        color: AppTheme.red,
        gradient: [AppTheme.red, AppTheme.red.withOpacity(0.8)],
        badge: '$totalOutStanding',
        isWarning: true,
        onTap: () => MyNavigator.navigateTo(context, const OverdueScreen()),
      ),
      _ReportItemData(
        title: 'Account Statement'.tr(),
        subtitle: 'Transaction history'.tr(),
        icon: Icons.analytics_rounded,
        color: AppTheme.yellow,
        gradient: const [AppTheme.yellow, AppTheme.orange],
        onTap: () =>
            MyNavigator.navigateTo(context, AccountStatementScreen()),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<InVoiceCubit, InVoiceState>(
      builder: (context, invoiceState) {
        return BlocBuilder<ReceiptCubit, ReceiptState>(
          builder: (context, receiptState) {
            return BlocBuilder<TranslationCubit, TranslationState>(
              builder: (context, translationState) {
                return MyScaffold(
                  title: 'Reports'.tr(),
                  showBackButton: false,
                  body: Stack(
                    children: [
                      // Static Background Decorations
                      _BackgroundDecorations(isDark: _isDark),

                      // Main Content
                      FadeTransition(
                        opacity: _controller,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                    _buildHeroHeader(screenWidth),
                    _buildQuickStats(screenWidth),
                    _buildSectionTitle(screenWidth),
                    _buildReportsGrid(screenWidth),
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
      },
    );
  }

  Widget _buildHeroHeader(double screenWidth) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, ResponsiveUtils.spacing(context, 20) * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          ResponsiveUtils.spacing(context, 16),
          ResponsiveUtils.spacing(context, 12),
          ResponsiveUtils.spacing(context, 16),
          ResponsiveUtils.spacing(context, 6),
        ),
        padding: ResponsiveUtils.paddingAll(context, 18),
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
          borderRadius: ResponsiveUtils.borderRadius(context, 24),
          boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderBadge(screenWidth),
                  SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                  Text(
                    'Reports'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 26),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 6)),
                  Text(
                    'Control Your Finances With Ease!'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 12),
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 14)),
                  _buildHeaderStats(screenWidth),
                ],
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 10)),
            _buildHeaderIllustration(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 12),
        vertical: ResponsiveUtils.spacing(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: ResponsiveUtils.borderRadius(context, 20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: AppTheme.lightGreen),
          SizedBox(width: ResponsiveUtils.spacing(context, 6)),
          Text(
            'Financial Hub'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 11),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(double screenWidth) {
    return Row(
      children: [
        Flexible(
          child: _MiniStat(
            icon: Icons.pie_chart_rounded,
            value: '4',
            label: 'Reports'.tr(),
            screenWidth: screenWidth,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 16)),
        Flexible(
          child: _MiniStat(
            icon: Icons.touch_app_rounded,
            value: '',
            label: 'Tap to explore'.tr(),
            screenWidth: screenWidth,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIllustration(double screenWidth) {
    return Container(
      width: ResponsiveUtils.size(context, 70),
      height: ResponsiveUtils.size(context, 70),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: ResponsiveUtils.borderRadius(context, 18),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          Assets.reportsGIF,
          width: ResponsiveUtils.size(context, 46),
          height: ResponsiveUtils.size(context, 46),
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildQuickStats(double screenWidth) {
    final profileCubit = ProfileCubit.get(context);
    final totalInvoicesAmount = profileCubit.userModel?.totalInvoicesAmount.toInt() ?? 0;
    final totalOverdue = profileCubit.userModel?.overdue.toInt() ?? 0;
    final overdue = profileCubit.userModel?.overdue.toInt() ?? 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.spacing(context, 16),
        ResponsiveUtils.spacing(context, 12),
        ResponsiveUtils.spacing(context, 16),
        ResponsiveUtils.spacing(context, 6),
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              icon: Icons.receipt_long_rounded,
              value: '$totalOverdue',
              // value: '$totalInvoicesAmount',
              label: 'Total Overdue'.tr(),
              color: AppTheme.purple,
              isDark: _isDark,
              delay: 100,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 10)),
          Expanded(
            child: _QuickStatCard(
              icon: Icons.warning_amber_rounded,
              value: '$overdue',
              label: 'Pending'.tr(),
              color: AppTheme.yellow,
              isDark: _isDark,
              delay: 200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(double screenWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.spacing(context, 16),
        ResponsiveUtils.spacing(context, 20),
        ResponsiveUtils.spacing(context, 16),
        ResponsiveUtils.spacing(context, 12),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveUtils.size(context, 3),
            height: ResponsiveUtils.size(context, 20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(),
              borderRadius: ResponsiveUtils.borderRadius(context, 2),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 10)),
          Text(
            'Browse Reports'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 17),
              fontWeight: FontWeight.w700,
              color: AppTheme.getText(_isDark),
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 10),
              vertical: ResponsiveUtils.spacing(context, 5),
            ),
            decoration: BoxDecoration(
              color: AppTheme.getSurface(_isDark),
              borderRadius: ResponsiveUtils.borderRadius(context, 20),
              border: Border.all(color: AppTheme.getBorder(_isDark)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: ResponsiveUtils.icon(context, 14),
                  color: AppTheme.getTextSecondary(_isDark),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 5)),
                Text(
                  'All'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 11),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextSecondary(_isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsGrid(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 16),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.95,
          crossAxisSpacing: ResponsiveUtils.spacing(context, 12),
          mainAxisSpacing: ResponsiveUtils.spacing(context, 12),
        ),
        itemCount: _getReportItems().length,
        itemBuilder: (context, index) {
          final reportItems = _getReportItems();
          return _ReportCard(
            data: reportItems[index],
            isDark: _isDark,
            screenWidth: screenWidth,
            delay: 300 + (index * 100),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌈 Background Decorations (Static - No Animation)
// ═══════════════════════════════════════════════════════════════════════════
class _BackgroundDecorations extends StatelessWidget {
  final bool isDark;

  const _BackgroundDecorations({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: ResponsiveUtils.spacing(context, -70),
            right: ResponsiveUtils.spacing(context, -50),
            child: Opacity(
              opacity: isDark ? 0.08 : 0.12,
              child: Container(
                width: ResponsiveUtils.size(context, 200),
                height: ResponsiveUtils.size(context, 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.purple,
                      AppTheme.purple.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.2,
            left: ResponsiveUtils.spacing(context, -80),
            child: Opacity(
              opacity: isDark ? 0.06 : 0.1,
              child: Container(
                width: ResponsiveUtils.size(context, 160),
                height: ResponsiveUtils.size(context, 160),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.green,
                      AppTheme.green.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.4,
            right: ResponsiveUtils.spacing(context, -40),
            child: Opacity(
              opacity: isDark ? 0.04 : 0.06,
              child: Container(
                width: ResponsiveUtils.size(context, 120),
                height: ResponsiveUtils.size(context, 120),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.yellow,
                      AppTheme.yellow.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 💚 Pulsing Dot
// ═══════════════════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
      builder: (context, child) {
        return Container(
          width: ResponsiveUtils.size(context, 7),
          height: ResponsiveUtils.size(context, 7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5 + (_controller.value * 0.3)),
                blurRadius: ResponsiveUtils.spacing(context, 5),
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Mini Stat Widget
// ═══════════════════════════════════════════════════════════════════════════
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final double screenWidth;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: ResponsiveUtils.paddingAll(context, 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: ResponsiveUtils.borderRadius(context, 8),
          ),
          child: Icon(icon, size: ResponsiveUtils.icon(context, 14), color: Colors.white.withOpacity(0.9)),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 8)),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.isNotEmpty)
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 10),
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📈 Quick Stat Card
// ═══════════════════════════════════════════════════════════════════════════
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final int delay;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
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
        padding: ResponsiveUtils.paddingAll(context, 14),
        decoration: BoxDecoration(
          color: AppTheme.getCard(isDark),
          borderRadius: ResponsiveUtils.borderRadius(context, 18),
          border: Border.all(color: AppTheme.getBorder(isDark)),
          boxShadow: AppTheme.softShadow(isDark),
        ),
        child: Row(
          children: [
            Container(
              padding: ResponsiveUtils.paddingAll(context, 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(isDark ? 0.2 : 0.15),
                    color.withOpacity(isDark ? 0.1 : 0.08),
                  ],
                ),
                borderRadius: ResponsiveUtils.borderRadius(context, 11),
              ),
              child: Icon(icon, color: color, size: ResponsiveUtils.icon(context, 20)),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 20),
                      fontWeight: FontWeight.w800,
                      color: AppTheme.getText(isDark),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 10),
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextSecondary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Report Item Data
// ═══════════════════════════════════════════════════════════════════════════
class _ReportItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final String? badge;
  final bool isWarning;
  final VoidCallback onTap;

  const _ReportItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
    this.badge,
    this.isWarning = false,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎴 Report Card
// ═══════════════════════════════════════════════════════════════════════════
class _ReportCard extends StatefulWidget {
  final _ReportItemData data;
  final bool isDark;
  final double screenWidth;
  final int delay;

  const _ReportCard({
    required this.data,
    required this.isDark,
    required this.screenWidth,
    required this.delay,
  });

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + widget.delay),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          HapticFeedback.mediumImpact();
          widget.data.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: AppTheme.durationFast,
          child: AnimatedContainer(
            duration: AppTheme.durationFast,
            decoration: BoxDecoration(
              color: widget.isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: ResponsiveUtils.borderRadius(context, 20),
              border: Border.all(
                color: _isPressed
                    ? widget.data.color.withOpacity(0.4)
                    : AppTheme.getBorder(widget.isDark),
                width: _isPressed ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isDark
                      ? Colors.black.withOpacity(0.3)
                      : widget.data.color.withOpacity(_isPressed ? 0.2 : 0.08),
                  blurRadius: _isPressed ? 16 : 20,
                  offset: Offset(0, _isPressed ? 4 : 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: ResponsiveUtils.borderRadius(context, 20),
              child: Stack(
                children: [
                  // Background Accent
                  Positioned(
                    top: ResponsiveUtils.spacing(context, -25),
                    right: ResponsiveUtils.spacing(context, -25),
                    child: Container(
                      width: ResponsiveUtils.size(context, 80),
                      height: ResponsiveUtils.size(context, 80),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.data.color.withOpacity(0.25),
                            widget.data.color.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: ResponsiveUtils.paddingOnly(
                      context,
                      top: 19,
                      bottom: 18,
                      left: 15,
                      right: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: ResponsiveUtils.paddingAll(context, 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: widget.data.gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: ResponsiveUtils.borderRadius(context, 14),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.data.color.withOpacity(0.35),
                                    blurRadius: ResponsiveUtils.spacing(context, 10),
                                    offset: Offset(0, ResponsiveUtils.spacing(context, 5)),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.data.icon,
                                color: Colors.white,
                                size: ResponsiveUtils.icon(context, 20),
                              ),
                            ),
                            if (widget.data.badge != null)
                              _buildBadge(widget.data.badge!),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          widget.data.title,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.font(context, 16),
                            fontWeight: FontWeight.w700,
                            color: widget.isDark
                                ? Colors.white
                                : AppTheme.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, 3)),
                        Text(
                          widget.data.subtitle,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.font(context, 11),
                            color: widget.isDark
                                ? AppTheme.darkGray
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: List.generate(3, (index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    right: ResponsiveUtils.spacing(context, 3),
                                  ),
                                  width: ResponsiveUtils.size(context, index == 0 ? 14 : 5),
                                  height: ResponsiveUtils.size(context, 5),
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? widget.data.color
                                        : widget.data.color.withOpacity(0.3),
                                    borderRadius: ResponsiveUtils.borderRadius(context, 3),
                                  ),
                                );
                              }),
                            ),
                            Container(
                              padding: ResponsiveUtils.paddingAll(context, 8),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : widget.data.color.withOpacity(0.1),
                                borderRadius: ResponsiveUtils.borderRadius(context, 10),
                              ),
                              child: DirectionalArrow(
                                direction: ArrowDirection.forward,
                                color: widget.data.color,
                                size: ResponsiveUtils.icon(context, 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String value) {
    final isWarning = widget.data.isWarning;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 8),
        vertical: ResponsiveUtils.spacing(context, 4),
      ),
      // decoration: BoxDecoration(
      //   gradient: isWarning
      //       ? LinearGradient(
      //     colors: [AppTheme.red, AppTheme.red.withOpacity(0.8)],
      //   )
      //       : LinearGradient(
      //     colors: [
      //       widget.data.color.withOpacity(widget.isDark ? 0.25 : 0.15),
      //       widget.data.color.withOpacity(widget.isDark ? 0.15 : 0.08),
      //     ],
      //   ),
      //   borderRadius: ResponsiveUtils.borderRadius(context, 16),
      //   border: isWarning
      //       ? null
      //       : Border.all(color: widget.data.color.withOpacity(0.3)),
      //   boxShadow: isWarning
      //       ? [
      //     BoxShadow(
      //       color: AppTheme.red.withOpacity(0.3),
      //       blurRadius: ResponsiveUtils.spacing(context, 6),
      //       offset: Offset(0, ResponsiveUtils.spacing(context, 2)),
      //     ),
      //   ]
      //       : null,
      // ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: ResponsiveUtils.font(context, 11),
          fontWeight: FontWeight.w700,
          color: isWarning ? Colors.white : widget.data.color,
        ),
      ),
    );
  }
}