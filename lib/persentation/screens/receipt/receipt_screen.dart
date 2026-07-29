import 'package:app/core/extensions/context_extensions.dart';
import 'package:app/business_logic/receipt/cubit/receipt_cubit.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/receipt/receipt_model.dart';
import 'package:app/persentation/screens/receipt/receipt_details_screen.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  static const Color green = Color(0xFF00C88D);
  static const Color yellow = Color(0xFFFBBF4D);
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

  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleLight],
  );

  static List<BoxShadow> cardShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black38 : dark.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 28.0;
  static const double radiusFull = 100.0;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🧾 Receipt Screen
// ═══════════════════════════════════════════════════════════════════════════
class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    
    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
    
    // Load receipts with pagination
    ReceiptCubit.get(context).getReceipts();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ReceiptCubit.get(context).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackground(_isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildAppBar(),
              _buildHeaderStats(),
              Expanded(child: _buildReceiptsList()),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // App Bar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _BackButton(isDark: _isDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonds'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getText(_isDark),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                BlocBuilder<ReceiptCubit, ReceiptState>(
                  builder: (context, state) {
                    // ✅ استخدام total من state بدلاً من allReceipt.length
                    int count = ReceiptCubit.get(context).allReceipt.length;
                    if (state is ReceiptGetSuccess) {
                      count = state.total; // العدد الإجمالي من الباك إند
                    }
                    return Text(
                      '$count ${'bonds found'.tr()}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.getTextSecondary(_isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildReceiptIcon(),
        ],
      ),
    );
  }

  Widget _buildReceiptIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.purple.withOpacity(_isDark ? 0.25 : 0.12),
            AppTheme.lightGreen.withOpacity(_isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.purple.withOpacity(_isDark ? 0.3 : 0.2),
        ),
      ),
      child: Icon(
        Icons.receipt_long_rounded,
        color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
        size: 24,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header Stats - ✅ FIXED
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderStats() {
    return BlocBuilder<ReceiptCubit, ReceiptState>(
      builder: (context, state) {
        final receipts = ReceiptCubit.get(context).allReceipt;
        
        // ✅ استخدام total من state بدلاً من receipts.length
        int totalReceipts = receipts.length;
        if (state is ReceiptGetSuccess) {
          totalReceipts = state.total; // العدد الإجمالي من الباك إند
        }
        
        double totalAmount = _calculateTotalAmount(receipts);

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
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: _isDark
                  ? LinearGradient(
                colors: [
                  AppTheme.purple.withOpacity(0.35),
                  AppTheme.dark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
              boxShadow: AppTheme.elevatedShadow(AppTheme.purple),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // ✅ FIX: Decorative circles as List<Widget> with spread operator
                ..._buildDecorativeCircles(),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row
                      _buildStatsHeader(),
                      const SizedBox(height: 24),

                      // Total Amount
                      _buildTotalAmount(receipts.length??0),
                      // _buildTotalAmount(totalAmount),
                      const SizedBox(height: 20),

                      // Divider
                      // _buildGradientDivider(),
                      // const SizedBox(height: 16),

                      // Bottom Stats
                      // _buildBottomStats(totalReceipts, receipts),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ FIX: Changed to return List<Widget> instead of Stack
  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(
        top: -40,
        right: -40,
        child: IgnorePointer(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ),
      Positioned(
        top: -20,
        right: -20,
        child: IgnorePointer(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -25,
        left: -25,
        child: IgnorePointer(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 30,
        right: 20,
        child: IgnorePointer(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildStatsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Receipts'.tr(),
                // 'Total Value'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'All bonds combined'.tr(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: const Icon(
            Icons.trending_up_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmount(num totalAmount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          totalAmount.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "receipt".tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1,
            letterSpacing: -1,
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 6),
        //   child: context.getCurrencyWidget(
        //     height: 35,
        //     width: 35,
        //     color: Colors.white.withOpacity(0.85),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildGradientDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStats(int totalReceipts, List<ReceiptModel> receipts) {
    return Row(
      children: [
        // Expanded(
        //   child: _MiniStat(
        //     icon: Icons.receipt_long_rounded,
        //     value: '$totalReceipts',
        //     label: 'Bonds'.tr(),
        //   ),
        // ),
        // const SizedBox(width: 12),
        // Expanded(
        //   child: _MiniStat(
        //     icon: Icons.check_circle_outline_rounded,
        //     value: '${_countByType(receipts, 'in')}',
        //     label: 'Received'.tr(),
        //   ),
        // ),
        // const SizedBox(width: 12),
        // Expanded(
        //   child: _MiniStat(
        //     icon: Icons.arrow_outward_rounded,
        //     value: '${_countByType(receipts, 'out')}',
        //     label: 'Sent'.tr(),
        //   ),
        // ),
      ],
    );
  }

  int _countByType(List<ReceiptModel> receipts, String type) {
    return receipts.where((r) => r.kind.toLowerCase() == type).length;
  }

  double _calculateTotalAmount(List<ReceiptModel> receipts) {
    double total = 0;
    for (var receipt in receipts) {
      total += double.tryParse(receipt.amount.toString()) ?? 0;
    }
    return total;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Receipts List
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReceiptsList() {
    return BlocBuilder<ReceiptCubit, ReceiptState>(
      builder: (context, state) {
        final cubit = ReceiptCubit.get(context);
        final receipts = cubit.allReceipt;

        // Show loading for first load
        if (state is ReceiptGetLoading && (state as ReceiptGetLoading).isFirstLoad) {
          return _buildLoadingState();
        }

        if (receipts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => cubit.refresh(),
          color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              context.bottomSafePadding + kBottomNavigationBarHeight + 16,
            ),
            itemCount: receipts.length + (state is ReceiptGetLoading && state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == receipts.length) {
                return _buildLoadMoreIndicator();
              }

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: ReceiptCard(
                  receipt: receipts[index],
                  isDark: _isDark,
                  index: index,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            _isDark ? AppTheme.lightGreen : AppTheme.purple,
          ),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.purple.withOpacity(0.2),
                  AppTheme.lightGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                _isDark ? AppTheme.lightGreen : AppTheme.purple,
              ),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Bonds...'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getTextSecondary(_isDark),
              fontWeight: FontWeight.w500,
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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.purple.withOpacity(_isDark ? 0.2 : 0.1),
                    AppTheme.lightGreen.withOpacity(_isDark ? 0.15 : 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Bonds Found'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.getText(_isDark),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your bonds will appear here'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondary(_isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔙 Back Button Widget
// ═══════════════════════════════════════════════════════════════════════════
class _BackButton extends StatelessWidget {
  final bool isDark;

  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          MyNavigator.back(context);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            boxShadow: AppTheme.elevatedShadow(AppTheme.purple),
          ),
          child: DirectionalArrow(
            direction: ArrowDirection.backIos,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
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

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎴 Receipt Card Widget - ✅ FIXED (Stateless)
// ═══════════════════════════════════════════════════════════════════════════
class ReceiptCard extends StatelessWidget {
  final ReceiptModel receipt;
  final bool isDark;
  final int index;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.isDark,
    required this.index,
  });

  Color get _accentColor {
    final colors = [
      AppTheme.purple,
      AppTheme.green,
      AppTheme.yellow,
      AppTheme.lightGreen,
    ];
    return colors[index % colors.length];
  }

  List<Color> get _gradientColors {
    switch (index % 4) {
      case 0:
        return [AppTheme.purple, AppTheme.purpleLight];
      case 1:
        return [AppTheme.green, AppTheme.lightGreen];
      case 2:
        return [AppTheme.yellow, AppTheme.orange];
      default:
        return [AppTheme.lightGreen, AppTheme.green];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            MyNavigator.navigateTo(
              context,
              ReceiptDetailsScreen(receiptModel: receipt),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          child: Ink(
            decoration: BoxDecoration(
              color: AppTheme.getCard(isDark),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : _accentColor.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: AppTheme.getBorder(isDark)),
            ),
            child: Column(
              children: [
                // Header Section
                _buildHeader(context),
                // Details Section
                _buildDetails(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentColor.withOpacity(isDark ? 0.2 : 0.1),
            AppTheme.getCard(isDark),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: Row(
        children: [
          // Receipt Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _gradientColors),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Reference & Contact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Bond reference'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '#${receipt.reference}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  receipt.contact.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.getText(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Arrow
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.getSurface(isDark),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: DirectionalArrow(
              direction: ArrowDirection.forwardIos,
              color: AppTheme.getTextSecondary(isDark),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Bond Value
            Expanded(
              child: _DetailColumn(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Bond Value'.tr(),
                value: '${receipt.amount}',
                valueColor: AppTheme.green,
                isDark: isDark,
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${receipt.amount}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    context.getCurrencyWidget(
                      height: 25,
                      width: 25,
                      color: AppTheme.green,
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Release Date
            Expanded(
              child: _DetailColumn(
                icon: Icons.calendar_today_rounded,
                label: 'Release Date'.tr(),
                value: '${receipt.date}',
                valueColor: AppTheme.getText(isDark),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📋 Detail Column Widget
// ═══════════════════════════════════════════════════════════════════════════
class _DetailColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool isDark;
  final Widget? valueWidget;

  const _DetailColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isDark,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.getTextSecondary(isDark),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondary(isDark),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        valueWidget ??
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
      ],
    );
  }
}