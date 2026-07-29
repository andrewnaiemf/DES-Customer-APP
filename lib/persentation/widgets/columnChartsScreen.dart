import 'package:app/business_logic/Statistic_cubit/statistic_cubit.dart';
import 'package:app/models/Statistics/statistics_model.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Brand Colors - الألوان الرسمية للتطبيق
// ═══════════════════════════════════════════════════════════════════════════
class AppColors {
  // Brand Colors
  static const Color yellow = Color.fromRGBO(217, 179, 29, 1.0);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color red = Color(0xFFEF4444);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purple, Color(0xFF8B6CEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [lightGreen, Color(0xFF4AECD3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 🌓 Theme-Aware Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Card Background Color
  static Color cardBackground(bool isDark) => isDark ? dark : white;

  /// Surface Background Color
  static Color surfaceBackground(bool isDark) => isDark ? background : lightGray;

  /// Primary Text Color
  static Color textPrimary(bool isDark) => isDark ? white : dark;

  /// Secondary Text Color
  static Color textSecondary(bool isDark) => isDark ? darkGray : const Color(0xFF6B7280);

  /// Divider/Border Color
  static Color divider(bool isDark) => isDark ? white.withOpacity(0.1) : darkGray.withOpacity(0.3);

  /// Shadow Color
  static Color shadow(bool isDark) => isDark ? Colors.black.withOpacity(0.4) : darkGray.withOpacity(0.25);

  /// Shimmer Base Color
  static Color shimmerBase(bool isDark) => isDark ? white.withOpacity(0.05) : darkGray.withOpacity(0.2);

  /// Shimmer Highlight Color
  static Color shimmerHighlight(bool isDark) => isDark ? white.withOpacity(0.1) : darkGray.withOpacity(0.1);

  /// Chart Grid Line Color
  static Color chartGridLine(bool isDark) => isDark ? white.withOpacity(0.08) : darkGray.withOpacity(0.15);

  /// Legend Background Color
  static Color legendBackground(bool isDark) => isDark ? white.withOpacity(0.05) : lightGray;
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Months Data - Fixed month names
// ═══════════════════════════════════════════════════════════════════════════
const List<String> _months = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
];

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Column Charts Screen - Main Widget
// ═══════════════════════════════════════════════════════════════════════════
class ColumnChartsScreen extends StatefulWidget {
  const ColumnChartsScreen({super.key});

  @override
  State<ColumnChartsScreen> createState() => _ColumnChartsScreenState();
}

class _ColumnChartsScreenState extends State<ColumnChartsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Theme Helper
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // ✅ تأخير تحميل البيانات لتجنب مشاكل الـ context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  void _loadData() {
    if (mounted) {
      context.read<StatisticCubit>().getStatistic();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      width: screenWidth,
      height: isTablet ? 280 : 240,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 4,
        vertical: 12,
      ),
      child: BlocConsumer<StatisticCubit, StatisticState>(
        listener: (context, state) {
          if (state is StatisticLoaded) {
            _animationController.forward();
          }
        },
        builder: (context, state) {
          if (state is StatisticLoading) {
            return _buildLoadingState();
          } else if (state is StatisticLoaded) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: ColumnChartWidget(
                      year: state.model.data?.year ?? [],
                      isDark: _isDark,
                    ),
                  ),
                );
              },
            );
          } else if (state is StatisticError) {
            return _buildErrorState();
          }
          return _buildEmptyState();
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔄 Loading State - Shimmer Effect
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDark),
        borderRadius: BorderRadius.circular(24),
        border: _isDark
            ? Border.all(color: AppColors.white.withOpacity(0.08))
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(_isDark),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Shimmer Background
            Positioned.fill(
              child: _ShimmerWidget(isDark: _isDark),
            ),
            // Content Placeholder
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Shimmer
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase(_isDark),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Chart Shimmer
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(6, (index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              width: 24,
                              height: 40.0 + (index * 15),
                              decoration: BoxDecoration(
                                color: AppColors.shimmerBase(_isDark),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 24,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.shimmerBase(_isDark),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Legend Shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendShimmer(),
                      const SizedBox(width: 24),
                      _buildLegendShimmer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendShimmer() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase(_isDark),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 60,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase(_isDark),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ❌ Error State
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDark),
        borderRadius: BorderRadius.circular(24),
        border: _isDark
            ? Border.all(color: AppColors.white.withOpacity(0.08))
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(_isDark),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(_isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Failed to load data".tr(),
              style: TextStyle(
                color: AppColors.textPrimary(_isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loadData,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            gradient: _isDark
                ? LinearGradient(
              colors: [AppColors.lightGreen, AppColors.lightGreen.withOpacity(0.8)],
            )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (_isDark ? AppColors.lightGreen : AppColors.purple).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                color: _isDark ? AppColors.dark : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Retry".tr(),
                style: TextStyle(
                  color: _isDark ? AppColors.dark : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📭 Empty State
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(_isDark),
        borderRadius: BorderRadius.circular(24),
        border: _isDark
            ? Border.all(color: AppColors.white.withOpacity(0.08))
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(_isDark),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isDark
                    ? AppColors.purple.withOpacity(0.15)
                    : AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                color: _isDark ? AppColors.lightGreen : AppColors.darkGray,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No data available".tr(),
              style: TextStyle(
                color: AppColors.textSecondary(_isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Check back later for updates".tr(),
              style: TextStyle(
                color: AppColors.textSecondary(_isDark).withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Column Chart Widget - Chart Display
// ═══════════════════════════════════════════════════════════════════════════
class ColumnChartWidget extends StatelessWidget {
  final List<Year> year;
  final bool isDark;

  const ColumnChartWidget({
    super.key,
    required this.year,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.white.withOpacity(0.08))
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(isDark),
            spreadRadius: 0,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: AppColors.purple.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Subtle Background Pattern
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.lightGreen.withOpacity(isDark ? 0.15 : 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.purple.withOpacity(isDark ? 0.12 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 6),
                  Expanded(child: _buildChart()),
                  const SizedBox(height: 8),
                  _buildLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Header Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.purple.withOpacity(0.3), AppColors.lightGreen.withOpacity(0.2)]
                      : [AppColors.purple.withOpacity(0.15), AppColors.lightGreen.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: isDark ? AppColors.lightGreen : AppColors.purple,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Status".tr(),
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "Monthly Overview".tr(),
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        // More Options Button
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.white.withOpacity(0.08)
                : AppColors.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.more_horiz_rounded,
            color: AppColors.textSecondary(isDark),
            size: 16,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 Chart Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
        labelPlacement: LabelPlacement.onTicks,
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: 1,
          color: AppColors.chartGridLine(isDark),
          dashArray: const <double>[5, 5],
        ),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 8,
          fontWeight: FontWeight.w500,
        ),
        labelFormat: '{value}',
        minimum: 0,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: isDark ? AppColors.white : AppColors.dark,
        textStyle: TextStyle(
          color: isDark ? AppColors.dark : Colors.white,
          fontSize: 12,
        ),
        duration: 2000,
        animationDuration: 300,
        builder: (data, point, series, pointIndex, seriesIndex) {
          final yearData = data as Year;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.white : AppColors.dark,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: seriesIndex == 0 ? AppColors.lightGreen : AppColors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      seriesIndex == 0
                          ? "${"Paid".tr()}: ${yearData.totalPaidAmount}"
                          : "${"Due".tr()}: ${yearData.totalDueAmount}",
                      style: TextStyle(
                        color: isDark ? AppColors.dark : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      series: <CartesianSeries>[
        // Total Paid Amount - Green
        ColumnSeries<Year, String>(
          dataSource: year,
          xValueMapper: (Year years, index) => _getMonthName(index),
          yValueMapper: (Year years, _) => years.totalPaidAmount,
          name: 'Total Paid Amount',
          color: AppColors.lightGreen,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          width: 0.7,
          spacing: 0.15,
          animationDuration: 1200,
          animationDelay: 200,
          gradient: LinearGradient(
            colors: [
              AppColors.lightGreen,
              AppColors.lightGreen.withOpacity(isDark ? 0.6 : 0.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Total Due Amount - Purple
        ColumnSeries<Year, String>(
          dataSource: year,
          xValueMapper: (Year years, index) => _getMonthName(index),
          yValueMapper: (Year years, _) => years.totalDueAmount,
          name: 'Total Due Amount',
          color: AppColors.purple,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          width: 0.7,
          spacing: 0.15,
          animationDuration: 1200,
          animationDelay: 400,
          gradient: LinearGradient(
            colors: [
              AppColors.purple,
              AppColors.purple.withOpacity(isDark ? 0.6 : 0.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int index) {
    if (index >= 0 && index < _months.length) {
      return _months[index];
    }
    return '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏷️ Legend Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.legendBackground(isDark),
        borderRadius: BorderRadius.circular(10),
        border: isDark
            ? Border.all(color: AppColors.white.withOpacity(0.05))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: AppColors.lightGreen,
            label: "Total Paid".tr(),
          ),
          const SizedBox(width: 24),
          _buildLegendItem(
            color: AppColors.purple,
            label: "Total Due".tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isDark ? 0.4 : 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ✨ Shimmer Widget - Loading Animation
// ═══════════════════════════════════════════════════════════════════════════
class _ShimmerWidget extends StatefulWidget {
  final bool isDark;

  const _ShimmerWidget({required this.isDark});

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                Colors.transparent,
                AppColors.shimmerHighlight(widget.isDark),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Helper Extension for AnimatedBuilder
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