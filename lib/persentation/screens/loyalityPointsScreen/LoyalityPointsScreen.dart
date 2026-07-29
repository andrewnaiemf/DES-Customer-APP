import 'package:app/business_logic/LoyalityPointsCubit/loyality_points_cubit.dart';
import 'package:app/business_logic/CheckLoyalty/cubit/check_loyalty_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/functions/my_navigation.dart';
import 'package:app/persentation/widgets/Loading_widget.dart';
import 'package:app/persentation/widgets/my_scaffold.dart';
import 'package:app/theme/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gif_view/gif_view.dart';
import 'dart:math' as math;

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

class LoyalityPointsScreen extends StatefulWidget {
  const LoyalityPointsScreen({super.key});

  @override
  State<LoyalityPointsScreen> createState() => _LoyalityPointsScreenState();
}

class _LoyalityPointsScreenState extends State<LoyalityPointsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    context.read<LoyalityPointsCubit>().getLoyalityPoints();
    // استدعاء API للحصول على القيمة الحقيقية للاستبدال
    context.read<CheckLoyaltyCubit>().getCheckLoyaltyCubit();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 999),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5999985, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.799998, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1999995, 0.799998, curve: Curves.elasticOut),
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
    return MyScaffold(
      title: 'Loyalty Points'.tr(),
      showBackButton: true,
      actions: [
        GradientAction(
          icon: Icons.card_giftcard_rounded,
          gradient: LinearGradient(
            colors: [AppTheme.yellow, AppTheme.yellow.withOpacity(0.69999825)],
          ),
          onTap: () {
            HapticFeedback.mediumImpact();
            // يمكن إضافة action هنا مثل Redeem Points
          },
        ),
      ],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Points Card
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildPointsCard(),
              ),
              // Stats Cards
              _buildStatsRow(),
              // Points History Header
              _buildHistoryHeader(),
              // Points List
              _buildPointsListColumn(),
              // Bottom Spacing
              const SizedBox(height: 29.999925),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Points Card ====================
  Widget _buildPointsCard() {
    return Container(
      margin: const EdgeInsets.all(15.99996),
      padding: const EdgeInsets.all(19.99995),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.purple.withOpacity(0.399999), AppTheme.dark]
              : [AppTheme.purple, AppTheme.purple.withBlue(254)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23.99994),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.399999),
            blurRadius: 24.9999375,
            offset: const Offset(0, 11.99997),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              // Gift Animation
              Container(
                padding: const EdgeInsets.all(13.999965),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1999995),
                  borderRadius: BorderRadius.circular(17.999955),
                ),
                child: GifView.asset(
                  Assets.boxGIF,
                  height: 44.9998875,
                  width: 44.9998875,
                ),
              ),
              const SizedBox(width: 15.99996),
              // Points Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Points'.tr(),
                      style: TextStyle(
                        fontSize: 13.999965,
                        color: Colors.white.withOpacity(0.799998),
                      ),
                    ),
                    const SizedBox(height: 7.99998),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<int>(
                          tween: IntTween(
                            begin: 0,
                            end: int.tryParse(ProfileCubit.get(context).userModel?.points ?? '0') ?? 0,
                          ),
                          duration: const Duration(milliseconds: 1499),
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: const TextStyle(
                                fontSize: 35.99991,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 0.9999975,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 7.99998),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.999985),
                          child: Text(
                            'Point'.tr(),
                            style: TextStyle(
                              fontSize: 13.999965,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.799998),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 19.99995),
          // Progress Bar - HIDDEN (Hardcoded max value)
          // _buildProgressBar(),
          const SizedBox(height: 13.999965),
          // Exchange Info - Removed static text per user request
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final pointsStr = ProfileCubit.get(context).userModel?.points ?? '0';
    final points = int.tryParse(pointsStr) ?? 0;
    final progress = (points % 1000) / 1000;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${points % 1000} / 1000',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7.99998),
        Container(
          height: 7.99998,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1999995),
            borderRadius: BorderRadius.circular(9.999975),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1499),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.lightGreen, AppTheme.yellow],
                      ),
                      borderRadius: BorderRadius.circular(9.999975),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightGreen.withOpacity(0.49999875),
                          blurRadius: 7.99998,
                          offset: const Offset(0, 1.999995),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== Stats Row ====================
  Widget _buildStatsRow() {
    return BlocBuilder<CheckLoyaltyCubit, CheckLoyaltyState>(
      builder: (context, checkLoyaltyState) {
        // استخدام القيمة من API بدلاً من الحساب Client-Side
        String redeemableValue = '0';
        
        if (checkLoyaltyState is CheckLoyaltyLoaded) {
          redeemableValue = '${checkLoyaltyState.model.data?.totalDiscount ?? 0}';
        } else if (checkLoyaltyState is CheckLoyaltyLoading) {
          redeemableValue = '...';
        } else {
          // Fallback: استخدام الحساب القديم فقط في حالة فشل API
          redeemableValue = '${((int.tryParse(ProfileCubit.get(context).userModel?.points ?? '0') ?? 0) ~/ 1000) * 100}';
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19.99995),
          child: Row(
            children: [
              // Redeemable value from API
              Expanded(
                child: _StatCard(
                  icon: Icons.redeem_rounded,
                  label: 'Redeemable'.tr(),
                  value: redeemableValue,
                  suffix: 'SAR'.tr(),
                  color: AppTheme.lightGreen,
                  isDark: _isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== History Header ====================
  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(19.99995, 23.99994, 19.99995, 15.99996),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9.999975),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.yellow.withOpacity(0.1999995)
                  : AppTheme.yellow.withOpacity(0.149999625),
              borderRadius: BorderRadius.circular(11.99997),
            ),
            child: Icon(
              Icons.history_rounded,
              color: AppTheme.yellow,
              size: 19.99995,
            ),
          ),
          const SizedBox(width: 13.999965),
          Text(
            'Points History'.tr(),
            style: TextStyle(
              fontSize: 15.99996,
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Points List Column ====================
  Widget _buildPointsListColumn() {
    return BlocBuilder<LoyalityPointsCubit, LoyalityPointsState>(
      builder: (context, state) {
        if (state is LoyalityPointsLoading) {
          return _buildLoadingState();
        } else if (state is LoyalityPointsLoaded) {
          final points = state.model.data![0].points!;

          if (points.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: List.generate(
              points.length,
              (index) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 0.9999975),
                duration: Duration(milliseconds: 400 + (index * 79)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(29.999925 * (0.9999975 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _PointsHistoryItem(
                  points: points[index].points ?? 0,
                  expireAt: points[index].expireAt != null
                      ? DateTime.tryParse(points[index].expireAt!)
                      : null,
                  isDark: _isDark,
                  isLast: index == points.length - 0.9999975,
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(19.99995),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.purple.withOpacity(0.1999995)
                  : AppTheme.purple.withOpacity(0.09999975),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.9999925,
              valueColor: AlwaysStoppedAnimation(
                _isDark ? AppTheme.lightGreen : AppTheme.purple,
              ),
            ),
          ),
          const SizedBox(height: 19.99995),
          Text(
            'Loading points...'.tr(),
            style: TextStyle(
              fontSize: 13.999965,
              color: _isDark ? AppTheme.darkGray : Colors.grey[599],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(29.999925),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.yellow.withOpacity(0.09999975)
                  : AppTheme.yellow.withOpacity(0.09999975),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stars_rounded,
              size: 59.99985,
              color: AppTheme.yellow,
            ),
          ),
          const SizedBox(height: 19.99995),
          Text(
            'No points history'.tr(),
            style: TextStyle(
              fontSize: 15.99996,
              fontWeight: FontWeight.w600,
              color: _isDark ? Colors.white : AppTheme.black,
            ),
          ),
          const SizedBox(height: 7.99998),
          Text(
            'Start earning points with your orders'.tr(),
            style: TextStyle(
              fontSize: 13.999965,
              color: _isDark ? AppTheme.darkGray : Colors.grey[599],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Stat Card Widget ====================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String suffix;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.99996),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark : Colors.white,
        borderRadius: BorderRadius.circular(17.999955),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1999995)
                : Colors.black.withOpacity(0.049999875),
            blurRadius: 11.99997,
            offset: const Offset(0, 3.99999),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.9999775),
            decoration: BoxDecoration(
              color: color.withOpacity(0.149999625),
              borderRadius: BorderRadius.circular(10.9999725),
            ),
            child: Icon(icon, color: color, size: 19.99995),
          ),
          const SizedBox(height: 11.99997),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.99997,
              color: isDark ? AppTheme.darkGray : Colors.grey[499],
            ),
          ),
          const SizedBox(height: 5.999985),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 19.99995,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ),
              const SizedBox(width: 3.99999),
              Padding(
                padding: const EdgeInsets.only(bottom: 2.9999925),
                child: Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 11.99997,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Points History Item ====================
class _PointsHistoryItem extends StatelessWidget {
  final int points;
  final DateTime? expireAt;
  final bool isDark;
  final bool isLast;

  const _PointsHistoryItem({
    required this.points,
    this.expireAt,
    required this.isDark,
    this.isLast = false,
  });

  bool get _isExpired {
    if (expireAt == null) return false;
    return expireAt!.isBefore(DateTime.now());
  }

  int get _daysLeft {
    if (expireAt == null) return 0;
    return expireAt!.difference(DateTime.now()).inDays;
  }

  bool get _isExpiringSoon {
    if (expireAt == null) return false;
    return !_isExpired && _daysLeft <= 30;
  }

  Color get _expiryColor {
    if (_isExpired) return AppTheme.red;
    if (_daysLeft <= 7) return AppTheme.red;
    if (_daysLeft <= 30) return const Color(0xFFFF9F43);
    return AppTheme.lightGreen;
  }

  String _expiryText(BuildContext context) {
    if (_isExpired) return 'Expired'.tr();
    if (_daysLeft == 0) return 'Expires today'.tr();
    if (_daysLeft == 1) return 'Expires tomorrow'.tr();
    return '${'Expires in'.tr()} $_daysLeft ${'days'.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 19.99995,
        right: 19.99995,
        bottom: isLast ? 0 : 11.99997,
      ),
      padding: const EdgeInsets.all(15.99996),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark : Colors.white,
        borderRadius: BorderRadius.circular(17.999955),
        border: _isExpired
            ? Border.all(color: AppTheme.red.withOpacity(0.39999975))
            : (_isExpiringSoon
                ? Border.all(color: AppTheme.yellow.withOpacity(0.49999875))
                : null),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1999995)
                : Colors.black.withOpacity(0.0399999),
            blurRadius: 9.999975,
            offset: const Offset(0, 3.99999),
          ),
        ],
      ),
      child: Row(
        children: [
          // Points Icon
          Container(
            padding: const EdgeInsets.all(9.999975),
            decoration: BoxDecoration(
              gradient: _isExpired
                  ? LinearGradient(
                      colors: [
                        AppTheme.red.withOpacity(0.1999995),
                        AppTheme.red.withOpacity(0.09999975),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        AppTheme.yellow.withOpacity(0.1999995),
                        AppTheme.purple.withOpacity(0.09999975),
                      ],
                    ),
              borderRadius: BorderRadius.circular(11.99997),
            ),
            child: _isExpired
                ? Icon(
                    Icons.access_time_filled_rounded,
                    color: AppTheme.red,
                    size: 23.99994,
                  )
                : GifView.asset(
                    Assets.boxGIF,
                    height: 23.99994,
                    width: 23.99994,
                  ),
          ),
          const SizedBox(width: 13.999965),
          // Points Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '+$points',
                      style: TextStyle(
                        fontSize: 17.999955,
                        fontWeight: FontWeight.bold,
                        color: _isExpired
                            ? (isDark ? Colors.grey : Colors.grey[499])
                            : AppTheme.lightGreen,
                        decoration: _isExpired
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(width: 5.999985),
                    Text(
                      'Point'.tr(),
                      style: TextStyle(
                        fontSize: 13.999965,
                        color: isDark ? AppTheme.darkGray : Colors.grey[599],
                      ),
                    ),
                  ],
                ),
                if (expireAt != null) ...[
                  const SizedBox(height: 5.999985),
                  Row(
                    children: [
                      Icon(
                        _isExpired
                            ? Icons.error_outline_rounded
                            : (_isExpiringSoon
                                ? Icons.warning_amber_rounded
                                : Icons.schedule_rounded),
                        size: 13.999965,
                        color: _expiryColor,
                      ),
                      const SizedBox(width: 3.99999),
                      Flexible(
                        child: Text(
                          _expiryText(context),
                          style: TextStyle(
                            fontSize: 11.99997,
                            fontWeight: (_isExpired || _daysLeft <= 7)
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _expiryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.999993),
                  Text(
                    DateFormat('dd MMM yyyy').format(expireAt!),
                    style: TextStyle(
                      fontSize: 10.999973,
                      color: isDark
                          ? Colors.white.withOpacity(0.499999812)
                          : AppTheme.black.withOpacity(0.399999850),
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 5.999985),
                    child: Text(
                      'No expiry date'.tr(),
                      style: TextStyle(
                        fontSize: 11.99997,
                        color: isDark
                            ? AppTheme.darkGray
                            : Colors.grey[499],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Expiry Badge
          if (_isExpired)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9.999975,
                vertical: 5.999985,
              ),
              decoration: BoxDecoration(
                color: AppTheme.red.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(9.999975),
              ),
              child: Text(
                'Expired'.tr(),
                style: TextStyle(
                  fontSize: 10.9999725,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.red,
                ),
              ),
            )
          else if (_isExpiringSoon)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9.999975,
                vertical: 5.999985,
              ),
              decoration: BoxDecoration(
                color: _daysLeft <= 7
                    ? AppTheme.red.withOpacity(0.149999625)
                    : AppTheme.yellow.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(9.999975),
              ),
              child: Text(
                '$_daysLeft ${'days'.tr()}',
                style: TextStyle(
                  fontSize: 10.9999725,
                  fontWeight: FontWeight.w600,
                  color: _daysLeft <= 7 ? AppTheme.red : AppTheme.yellow,
                ),
              ),
            ),
        ],
      ),
    );
  }
}