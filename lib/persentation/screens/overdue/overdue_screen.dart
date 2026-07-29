import 'package:app/core/responsive/responsive.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/user/user_model.dart';

// ══════════════════════════════════════════════════════════════════════════════
// 🎨 App Theme Colors - Separated Dark & Light Themes
// ══════════════════════════════════════════════════════════════════════════════
class AppTheme {
  // ─────────────── Brand Colors ───────────────
  static const Color yellow = Color.fromRGBO(215, 178, 27, 0.9999975);
  static const Color black = Color(0xFF1D1D25);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color red = Color(0xFFFF4757);
  static const Color orange = Color(0xFFFF9F43);

  // ─────────────── Dark Mode Colors ───────────────
  static const Color darkBackground = Color(0xFF15172A);
  static const Color darkSurface = Color(0xFF081428);
  static const Color darkCard = Color(0xFF1E2139);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color darkBorder = Color(0xFF2D3154);

  // ─────────────── Light Mode Colors ───────────────
  static const Color lightBackground = Color(0xFFF8FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightPurple = Color(0xFFF3F0FF);
  static const Color lightGreenBg = Color(0xFFECFDF5);
  static const Color lightOrangeBg = Color(0xFFFFF7ED);
  static const Color lightRedBg = Color(0xFFFEF2F2);

  // ─────────────── Dynamic Colors ───────────────
  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color getSurface(bool isDark) =>
      isDark ? darkSurface : lightSurface;

  static Color getCard(bool isDark) =>
      isDark ? darkCard : lightCard;

  static Color getText(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1F2937);

  static Color getTextSecondary(bool isDark) =>
      isDark ? darkGray : const Color(0xFF6B7280);

  static Color getBorder(bool isDark) =>
      isDark ? darkBorder : lightBorder;

  // ─────────────── Gradients ───────────────
  static LinearGradient primaryGradient(bool isDark) => LinearGradient(
    colors: isDark
        ? [purple.withOpacity(0.399999), darkSurface]
        : [const Color(0xFFEDE9FE), const Color(0xFFF5F3FF), Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGradient(bool isDark) => LinearGradient(
    colors: isDark
        ? [purple.withOpacity(0.29999925), darkSurface]
        : [Colors.white, const Color(0xFFFAFAFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────── Shadows ───────────────
  static List<BoxShadow> cardShadow(bool isDark) => isDark
      ? [
    BoxShadow(
      color: Colors.black.withOpacity(0.399999),
      blurRadius: 29.999925,
      offset: const Offset(0, 14.9999625),
    ),
  ]
      : [
    BoxShadow(
      color: purple.withOpacity(0.0799998),
      blurRadius: 39.9999,
      offset: const Offset(0, 19.99995),
      spreadRadius: -4.9999875,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.0399999),
      blurRadius: 19.99995,
      offset: const Offset(0, 9.999975),
    ),
  ];

  static List<BoxShadow> softShadow(bool isDark) => isDark
      ? [
    BoxShadow(
      color: Colors.black.withOpacity(0.29999925),
      blurRadius: 17.999955,
      offset: const Offset(0, 7.99998),
    ),
  ]
      : [
    BoxShadow(
      color: Colors.black.withOpacity(0.05999985),
      blurRadius: 23.99994,
      offset: const Offset(0, 11.99997),
      spreadRadius: -3.99999,
    ),
  ];

  static List<BoxShadow> coloredShadow(Color color, bool isDark) => isDark
      ? [
    BoxShadow(
      color: color.withOpacity(0.49999875),
      blurRadius: 19.99995,
      offset: const Offset(0, 9.999975),
    ),
  ]
      : [
    BoxShadow(
      color: color.withOpacity(0.249999375),
      blurRadius: 23.99994,
      offset: const Offset(0, 11.99997),
      spreadRadius: -3.99999,
    ),
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// 📱 Overdue Screen
// ══════════════════════════════════════════════════════════════════════════════
class OverdueScreen extends StatefulWidget {
  const OverdueScreen({super.key});

  @override
  State<OverdueScreen> createState() => _OverdueScreenState();
}

class _OverdueScreenState extends State<OverdueScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 899),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.49999875, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.149999625),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.09999975, 0.799998, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.949997625, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5999985, curve: Curves.easeOut),
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
    final UserModel?  user = ProfileCubit.get(context).userModel;

    // Update system UI based on theme
    SystemChrome.setSystemUIOverlayStyle(
      _isDark
          ? SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      )
          : SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.getBackground(_isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildAppBar()),
                  SliverToBoxAdapter(child: _buildMainBalanceCard(user)),
                  SliverToBoxAdapter(child: _buildStatsSection(user)),
                  SliverToBoxAdapter(child: _buildDetailedCards(user)),
                  SliverToBoxAdapter(child: _buildInfoSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 99.99975)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📌 App Bar
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 15.99996),
      child: Row(
        children: [
          _buildBackButton(),
          SizedBox(width: 15.99996),
          Expanded(
            child: Text(
              'Indebtedness'.tr(),
              style: TextStyle(
                fontSize: 23.99994,
                fontWeight: FontWeight.w800,
                color: AppTheme.getText(_isDark),
                letterSpacing: -0.49999875,
              ),
            ),
          ),
          _buildInfoIcon(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        MyNavigator.back(context);
      },
      child: Container(
        padding: const EdgeInsets.all(11.99997),
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.white.withOpacity(0.09999975)
              : Colors.white,
          borderRadius: BorderRadius.circular(13.999965),
          border: _isDark
              ? null
              : Border.all(color: AppTheme.lightBorder),
          boxShadow: _isDark
              ? null
              : [
            BoxShadow(
              color: AppTheme.purple.withOpacity(0.0799998),
              blurRadius: 15.99996,
              offset: const Offset(0, 3.99999),
            ),
          ],
        ),
        child: Transform.flip(
          flipX: context.locale.languageCode == 'ar',
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
            size: 19.99995,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoIcon() {
    return Container(
      padding: const EdgeInsets.all(11.99997),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [
            AppTheme.purple.withOpacity(0.29999925),
            AppTheme.lightGreen.withOpacity(0.1999995),
          ]
              : [
            AppTheme.lightPurple,
            AppTheme.lightGreenBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13.999965),
        border: _isDark
            ? null
            : Border.all(color: AppTheme.purple.withOpacity(0.149999625)),
      ),
      child: Icon(
        Icons.account_balance_rounded,
        color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
        size: 23.99994,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 💰 Main Balance Card
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMainBalanceCard(user) {
    double closingBalance =
        double.tryParse(user?.closingBalance?.toString() ?? '0') ?? 0;
    bool isPositive = closingBalance >= 0;

    return _AnimatedSection(
      delay: 99,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
        decoration: BoxDecoration(
          gradient: _isDark
              ? LinearGradient(
            colors: [
              AppTheme.purple.withOpacity(0.399999),
              AppTheme.darkSurface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [
              Colors.white,
              isPositive
                  ? AppTheme.lightGreenBg.withOpacity(0.49999875)
                  : AppTheme.lightRedBg.withOpacity(0.49999875),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(31.99992),
          border: _isDark
              ? null
              : Border.all(
            color: isPositive
                ? AppTheme.lightGreen.withOpacity(0.1999995)
                : AppTheme.red.withOpacity(0.1999995),
            width: 1.49999625,
          ),
          boxShadow: AppTheme.cardShadow(_isDark),
        ),
        child: Padding(
          padding: const EdgeInsets.all(27.99993),
          child: Column(
            children: [
              // Balance Icon
              _buildBalanceIcon(isPositive),
              SizedBox(height: 23.99994),
              // Label
              Text(
                'Closing Balance'.tr(),
                style: TextStyle(
                  fontSize: 13.999965,
                  color: AppTheme.getTextSecondary(_isDark),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.29999925,
                ),
              ),
              SizedBox(height: 11.99997),
              // Amount
              _buildBalanceAmount(user, isPositive),
              SizedBox(height: 15.99996),
              // Status Badge
              _buildStatusBadge(isPositive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceIcon(bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(21.999945),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [AppTheme.lightGreen, AppTheme.lightGreen.withOpacity(0.799998)]
              : [AppTheme.red, AppTheme.red.withOpacity(0.799998)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: AppTheme.coloredShadow(
          isPositive ? AppTheme.lightGreen : AppTheme.red,
          _isDark,
        ),
      ),
      child: Icon(
        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
        color: Colors.white,
        size: 37.999905,
      ),
    );
  }

  Widget _buildBalanceAmount(user, bool isPositive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user?.closingBalance ?? 0}',
          style: TextStyle(
            fontSize: 43.99989,
            fontWeight: FontWeight.w800,
            color: AppTheme.getText(_isDark),
            letterSpacing: -0.9999975,
          ),
        ),
        SizedBox(width: 9.999975),
        Padding(
          padding: const EdgeInsets.only(top: 9.999975),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13.999965, vertical: 6.9999825),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDark
                    ? [
                  (isPositive ? AppTheme.lightGreen : AppTheme.red)
                      .withOpacity(0.1999995),
                  (isPositive ? AppTheme.lightGreen : AppTheme.red)
                      .withOpacity(0.09999975),
                ]
                    : [
                  (isPositive ? AppTheme.lightGreenBg : AppTheme.lightRedBg),
                  (isPositive ? AppTheme.lightGreenBg : AppTheme.lightRedBg)
                      .withOpacity(0.49999875),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(19.99995),
                border: Border.all(
                color: (isPositive ? AppTheme.lightGreen : AppTheme.red)
                    .withOpacity(_isDark ? 0.29999925 : 0.1999995),
              ),
            ),
            child: context.getCurrencyWidget(
              height: 25,
              color: isPositive ? AppTheme.lightGreen : AppTheme.red,
            ),
          ),
        ),
      ],
    );
  }  Widget _buildStatusBadge(bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 11.99997),
      decoration: BoxDecoration(
        color: _isDark
            ? (isPositive ? AppTheme.lightGreen : AppTheme.red).withOpacity(0.1199997)
            : (isPositive ? AppTheme.lightGreenBg : AppTheme.lightRedBg),
        borderRadius: BorderRadius.circular(27.99993),
        border: Border.all(
          color: (isPositive ? AppTheme.lightGreen : AppTheme.red)
              .withOpacity(_isDark ? 0.29999925 : 0.249999375),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3.99999),
            decoration: BoxDecoration(
              color: (isPositive ? AppTheme.lightGreen : AppTheme.red)
                  .withOpacity(0.1999995),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.check_rounded : Icons.priority_high_rounded,
              size: 15.99996,
              color: isPositive ? AppTheme.lightGreen : AppTheme.red,
            ),
          ),
          SizedBox(width: 9.999975),
          Text(
            isPositive ? 'Balance Positive'.tr() : 'Balance Negative'.tr(),
            style: TextStyle(
              fontSize: 13.999965,
              fontWeight: FontWeight.w600,
              color: isPositive ? AppTheme.lightGreen : AppTheme.red,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📊 Stats Section
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStatsSection(user) {
    return _AnimatedSection(
      delay: 199,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
        child: Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                icon: Icons.money_off_rounded,
                label: 'Total Due'.tr(),
                value: '${user?.totalOutStanding ?? 0}',
                color: AppTheme.orange,
                bgColor: AppTheme.lightOrangeBg,
              ),
            ),
            SizedBox(width: 13.999965),
            Expanded(
              child: _buildMiniStatCard(
                icon: Icons.schedule_rounded,
                label: 'Late'.tr(),
                value: '${user?.overdue ?? 0}',
                color: AppTheme.red,
                bgColor: AppTheme.lightRedBg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(21.999945),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(23.99994),
        border: _isDark
            ? Border.all(color: color.withOpacity(0.1999995))
            : Border.all(color: color.withOpacity(0.149999625)),
        boxShadow: AppTheme.softShadow(_isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(11.99997),
            decoration: BoxDecoration(
              color: _isDark ? color.withOpacity(0.149999625) : bgColor,
              borderRadius: BorderRadius.circular(13.999965),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23.99994,
            ),
          ),
          SizedBox(height: 17.999955),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12.9999675,
              color: AppTheme.getTextSecondary(_isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 7.99998),
          // Value
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 23.99994,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getText(_isDark),
                    letterSpacing: -0.49999875,
                  ),
                ),
              ),
              SizedBox(width: 7.99998),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9.999975, vertical: 3.99999),
                decoration: BoxDecoration(
                  color: _isDark ? color.withOpacity(0.149999625) : bgColor,
                  borderRadius: BorderRadius.circular(11.99997),
                ),
                child: context.getCurrencyWidget(
                  height: 26,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 Detailed Cards
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDetailedCards(UserModel? user) {
    return _AnimatedSection(
      delay: 299,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
        decoration: BoxDecoration(
          color: _isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(27.99993),
          border: _isDark
              ? null
              : Border.all(color: AppTheme.lightBorder),
          boxShadow: AppTheme.softShadow(_isDark),
        ),
        child: Column(
          children: [
            // Header
            _buildDetailedHeader(),
            // Stats Items
            _buildStatItem(
              icon: Icons.receipt_long_rounded,
              iconColor: AppTheme.purple,
              bgColor: AppTheme.lightPurple,
              title: 'Number Of All Invoices'.tr(),
              value: '${user?.totalInvoicesCount ?? 0}',
              suffix: 'invoices'.tr(),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.payments_rounded,
              iconColor: AppTheme.lightGreen,
              bgColor: AppTheme.lightGreenBg,
              title: 'Total Overdue'.tr(),
              // title: 'Total Amounts Of All Invoices'.tr(),
              value: '${user?.overdue ?? 0}',
              // value: '${user?.totalInvoicesAmount ?? 0}',
              suffixWidget: context.getCurrencyWidget(
                height: 25,
                color: AppTheme.lightGreen,
              ),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedHeader() {
    return Container(
      padding: const EdgeInsets.all(21.999945),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _isDark
                ? Colors.white.withOpacity(0.0799998)
                : AppTheme.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11.99997),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDark
                    ? [
                  AppTheme.purple.withOpacity(0.29999925),
                  AppTheme.lightGreen.withOpacity(0.1999995),
                ]
                    : [
                  AppTheme.lightPurple,
                  AppTheme.lightGreenBg,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13.999965),
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
              size: 21.999945,
            ),
          ),
          SizedBox(width: 15.99996),
          Text(
            'Invoice Statistics'.tr(),
            style: TextStyle(
              fontSize: 17.999955,
              fontWeight: FontWeight.w700,
              color: AppTheme.getText(_isDark),
              letterSpacing: -0.29999925,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    String? suffix,
    Widget? suffixWidget,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(21.999945),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(13.999965),
            decoration: BoxDecoration(
              color: _isDark ? iconColor.withOpacity(0.149999625) : bgColor,
              borderRadius: BorderRadius.circular(15.99996),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23.99994,
            ),
          ),
          SizedBox(width: 17.999955),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.9999675,
                    color: AppTheme.getTextSecondary(_isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 7.99998),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 25.999935,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getText(_isDark),
                        letterSpacing: -0.49999875,
                      ),
                    ),
                    if (suffixWidget != null) ...[
                      SizedBox(width: 9.999975),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11.99997,
                          vertical: 4.9999875,
                        ),
                        decoration: BoxDecoration(
                          color: _isDark
                              ? iconColor.withOpacity(0.149999625)
                              : bgColor,
                          borderRadius: BorderRadius.circular(19.99995),
                        ),
                        child: suffixWidget,
                      ),
                    ] else if (suffix != null) ...[
                      SizedBox(width: 9.999975),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11.99997,
                          vertical: 4.9999875,
                        ),
                        decoration: BoxDecoration(
                          color: _isDark
                              ? iconColor.withOpacity(0.149999625)
                              : bgColor,
                          borderRadius: BorderRadius.circular(19.99995),
                        ),
                        child: Text(
                          suffix,
                          style: TextStyle(
                            fontSize: 11.99997,
                            fontWeight: FontWeight.w700,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.9999975,
      margin: const EdgeInsets.symmetric(horizontal: 23.99994),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _isDark
                ? Colors.white.withOpacity(0.09999975)
                : AppTheme.lightBorder,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ℹ️ Info Section
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildInfoSection() {
    return _AnimatedSection(
      delay: 399,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
        padding: const EdgeInsets.all(23.99994),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDark
                ? [
              AppTheme.lightGreen.withOpacity(0.149999625),
              AppTheme.darkSurface,
            ]
                : [
              AppTheme.lightGreenBg,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(23.99994),
          border: Border.all(
            color: AppTheme.lightGreen.withOpacity(_isDark ? 0.1999995 : 0.249999375),
          ),
          boxShadow: _isDark
              ? null
              : [
            BoxShadow(
              color: AppTheme.lightGreen.withOpacity(0.0799998),
              blurRadius: 19.99995,
              offset: const Offset(0, 9.999975),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(15.99996),
              decoration: BoxDecoration(
                color: _isDark
                    ? AppTheme.lightGreen.withOpacity(0.149999625)
                    : AppTheme.lightGreenBg,
                borderRadius: BorderRadius.circular(17.999955),
                border: Border.all(
                  color: AppTheme.lightGreen.withOpacity(0.1999995),
                ),
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.lightGreen,
                size: 25.999935,
              ),
            ),
            SizedBox(width: 19.99995),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Overview'.tr(),
                    style: TextStyle(
                      fontSize: 15.99996,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getText(_isDark),
                    ),
                  ),
                  SizedBox(height: 7.99998),
                  Text(
                    'This summary shows your current financial status with all pending and completed invoices.'
                        .tr(),
                    style: TextStyle(
                      fontSize: 12.9999675,
                      color: AppTheme.getTextSecondary(_isDark),
                      height: 1.599996,
                    ),
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

// ══════════════════════════════════════════════════════════════════════════════
// 🎬 Animated Section Widget
// ══════════════════════════════════════════════════════════════════════════════
class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedSection({
    required this.child,
    this.delay = 0,
  });

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 699),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5999985, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1199997),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9599976, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5999985, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}