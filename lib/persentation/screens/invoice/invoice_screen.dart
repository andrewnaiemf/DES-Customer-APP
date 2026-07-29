import 'package:app/core/responsive/responsive.dart';
import 'package:app/core/extensions/context_extensions.dart';
import 'package:app/business_logic/invoce/cubit/invoice_cubit.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/invoice/invoice_model.dart';
import 'package:app/persentation/screens/invoice/invoice_details_screen.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== App Theme Colors ====================
class AppTheme {
  static const Color yellow = Color.fromRGBO(215, 178, 27, 0.9999975);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color purpleLight = Color(0xFF9B6DFF);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color red = Color(0xFFFF4757);
  static const Color orange = Color(0xFFFF9F43);

  // Purple Gradient - نفس التدرج من Bottom Nav Bar
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple, purpleLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class InVoiceScreen extends StatefulWidget {
  const InVoiceScreen({super.key});

  @override
  State<InVoiceScreen> createState() => _InVoiceScreenState();
}

class _InVoiceScreenState extends State<InVoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    // InVoiceCubit.get(context).getInvoices();

    super.initState();
    
    // Initialize controllers
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    
    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
    
    // Load invoices with pagination
    InVoiceCubit.get(context).getInvoices();

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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      InVoiceCubit.get(context).loadMore();
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
      backgroundColor: _isDark ? AppTheme.background : AppTheme.lightGray,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                _buildStatsHeader(),
                Expanded(child: _buildInvoiceList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== App Bar ====================
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 16),
        vertical: ResponsiveUtils.spacing(context, 12),
      ),
      child: Row(
        children: [
          _buildBackButton(),
          SizedBox(width: ResponsiveUtils.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoices'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 22),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 3)),
                BlocBuilder<InVoiceCubit, InVoiceState>(
                  builder: (context, state) {
                    int count = InVoiceCubit.get(context).allInVoice.length;
                    int total = count;

                    if (state is InVoiceGetSuccess) {
                      total = state.total;
                    }

                    String displayText = total > count
                      ? '$count of $total ${'invoices'.tr()}'
                      : '$count ${'invoices found'.tr()}';

                    return Text(
                      displayText,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 12),
                        color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildMenuButton(),
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
        padding: ResponsiveUtils.paddingAll(context, 10),
        decoration: BoxDecoration(
          color: _isDark ? Colors.white.withOpacity(0.09999975) : Colors.white,
          borderRadius: ResponsiveUtils.borderRadius(context, 12),
          boxShadow: _isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05999985),
              blurRadius: ResponsiveUtils.spacing(context, 10),
              offset: Offset(0, ResponsiveUtils.spacing(context, 3)),
            ),
          ],
        ),
        child: DirectionalArrow(
          direction: ArrowDirection.backIos,
          color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
          size: ResponsiveUtils.icon(context, 20),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      padding: ResponsiveUtils.paddingAll(context, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.purple.withOpacity(0.1999995),
            AppTheme.lightGreen.withOpacity(0.09999975),
          ],
        ),
        borderRadius: ResponsiveUtils.borderRadius(context, 12),
      ),
      child: Icon(
        Icons.receipt_long_rounded,
        color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
        size: ResponsiveUtils.icon(context, 22),
      ),
    );
  }

  // ==================== Stats Header ====================
  Widget _buildStatsHeader() {
    return BlocBuilder<InVoiceCubit, InVoiceState>(
      builder: (context, state) {
        final invoices = InVoiceCubit.get(context).allInVoice;
        double totalAmount = _calculateTotalAmount(invoices);

        // ========== DARK MODE ==========
        if (_isDark) {
          return Container(
            margin: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
            padding: ResponsiveUtils.paddingAll(context, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple.withOpacity(0.29999925), AppTheme.dark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: ResponsiveUtils.borderRadius(context, 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.29999925),
                  blurRadius: ResponsiveUtils.spacing(context, 16),
                  offset: Offset(0, ResponsiveUtils.spacing(context, 6)),
                ),
              ],
            ),
            child: _buildStatItem(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: AppTheme.purple,
              label: 'Total Invoice Count'.tr(),
              // label: 'Total Value'.tr(),
              value: '${invoices.length} ${"invoice".tr()}',
              // value: '${totalAmount.toStringAsFixed(0)} ${"SAR".tr()}',
              isLarge: true,
            ),
          );
        }

        // ========== LIGHT MODE - Purple Gradient Style ==========
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, 16),
            vertical: ResponsiveUtils.spacing(context, 8),
          ),
          child: ClipRRect(
            borderRadius: ResponsiveUtils.borderRadius(context, 24),
            child: Stack(
              children: [
                // البطاقة الرئيسية مع Purple Gradient
                Container(
                  padding: ResponsiveUtils.paddingAll(context, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6842E2), // AppTheme.purple
                        Color(0xFF9B6DFF), // AppTheme.purpleLight
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: ResponsiveUtils.borderRadius(context, 24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.purple.withOpacity(0.49999875),
                        blurRadius: ResponsiveUtils.spacing(context, 16),
                        offset: Offset(0, ResponsiveUtils.spacing(context, 6)),
                        spreadRadius: ResponsiveUtils.spacing(context, -2),
                      ),
                      BoxShadow(
                        color: const Color(0xFF9B6DFF).withOpacity(0.29999925),
                        blurRadius: ResponsiveUtils.spacing(context, 24),
                        spreadRadius: ResponsiveUtils.spacing(context, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الصف العلوي - الأيقونة والعنوان
                      Row(
                        children: [
                          // أيقونة مع تأثير زجاجي
                          Container(
                            padding: ResponsiveUtils.paddingAll(context, 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1999995),
                              borderRadius: ResponsiveUtils.borderRadius(context, 14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.29999925),
                                width: 1.49999625,
                              ),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: ResponsiveUtils.icon(context, 24),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, 12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                 'Total Invoice Count'.tr(),

                                  // 'Total Value'.tr(),
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.font(context, 16),
                                    color: Colors.white.withOpacity(0.89999775),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.49999875,
                                  ),
                                ),
                                // SizedBox(height: ResponsiveUtils.spacing(context, 2)),
                                // Text(
                                //    'Total Invoice Count'.tr(),
                                //   // 'Total Value'.tr(),
                                //   style: TextStyle(
                                //     fontSize: ResponsiveUtils.font(context, 10),
                                //     color: Colors.white.withOpacity(0.5999985),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          // أيقونة الترند
                          Container(
                            padding: ResponsiveUtils.paddingAll(context, 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.149999625),
                              borderRadius: ResponsiveUtils.borderRadius(context, 10),
                            ),
                            child: Icon(
                              Icons.trending_up_rounded,
                              color: Colors.white,
                              size: ResponsiveUtils.icon(context, 18),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, 20)),
                      // المبلغ الإجمالي
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            invoices.length.toString(),
                            // totalAmount.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: ResponsiveUtils.font(context, 38),
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              height: 0.9999975,
                              letterSpacing: -0.9999975,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                          Text(
                           "invoice".tr(),
                            // totalAmount.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: ResponsiveUtils.font(context, 18),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 0.9999975,
                              letterSpacing: -0.9999975,
                            ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.only(
                          //     bottom: ResponsiveUtils.spacing(context, 5),
                          //   ),
                          //   child: context.getCurrencyWidget(
                          //     height: ResponsiveUtils.font(context, 35),
                          //     width: ResponsiveUtils.font(context, 35),
                          //     color: Colors.white.withOpacity(0.849997875),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, 16)),
                      // الخط الفاصل
                      Container(
                        height: 0.9999975,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.399999),
                              Colors.white.withOpacity(0.09999975),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15.99996),
                      // الإحصائيات السفلية
                      Row(
                        children: [
                          // _buildMiniStat(
                          //   icon: Icons.receipt_long_rounded,
                          //   value: '${invoices.length}',
                          //   label: 'Invoices'.tr(),
                          // ),
                          // SizedBox(width: 27.99993),
                          _buildMiniStat(
                            icon: Icons.check_circle_outline_rounded,
                            value: '${_countByStatus(invoices, 'paid')}',
                            label: 'Paid'.tr(),
                          ),
                          SizedBox(width: 27.99993),
                          _buildMiniStat(
                            icon: Icons.pending_outlined,
                            value: '${_countByStatus(invoices, 'pending')}',
                            label: 'Pending'.tr(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // الدوائر الديكورية
                Positioned(
                  top: -39.9999,
                  right: -39.9999,
                  child: Container(
                    width: 139.99965,
                    height: 139.99965,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.09999975),
                    ),
                  ),
                ),
                Positioned(
                  top: -19.99995,
                  right: -19.99995,
                  child: Container(
                    width: 79.9998,
                    height: 79.9998,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1999995),
                        width: 0.9999975,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -24.9999375,
                  left: -24.9999375,
                  child: Container(
                    width: 89.999775,
                    height: 89.999775,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.0799998),
                    ),
                  ),
                ),
                // نمط إضافي
                Positioned(
                  bottom: 29.999925,
                  right: 19.99995,
                  child: Container(
                    width: 49.999875,
                    height: 49.999875,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.149999625),
                        width: 0.9999975,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== Mini Stat Widget ==========
  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5.999985),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.149999625),
            borderRadius: BorderRadius.circular(7.99998),
          ),
          child: Icon(
            icon,
            size: 15.99996,
            color: Colors.white.withOpacity(0.89999775),
          ),
        ),
        SizedBox(width: 9.999975),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 17.999955,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.999975,
                color: Colors.white.withOpacity(0.649998375),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== Count By Status ==========
  int _countByStatus(List<InVoiceModel> invoices, String status) {
    return invoices.where((inv) => inv.status?.toLowerCase() == status).length;
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9.999975),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(11.99997),
              ),
              child: Icon(icon, color: iconColor, size: 19.99995),
            ),
            SizedBox(width: 11.99997),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.99997,
                color: _isDark ? AppTheme.darkGray : Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 11.99997),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 21.999945 : 15.99996,
            fontWeight: FontWeight.bold,
            color: _isDark ? Colors.white : Colors.white,
          ),
        ),
      ],
    );
  }

  double _calculateTotalAmount(List<InVoiceModel> invoices) {
    double total = 0;
    for (var invoice in invoices) {
      total += double.tryParse(invoice.total?.toString() ?? '0') ?? 0;
    }
    return total;
  }

  // ==================== Invoice List ====================
  Widget _buildInvoiceList() {
    return BlocBuilder<InVoiceCubit, InVoiceState>(
      builder: (context, state) {
        final cubit = InVoiceCubit.get(context);
        final invoices = cubit.allInVoice;
        // Show loading for first load
        if (state is InVoiceGetLoading && (state as InVoiceGetLoading).isFirstLoad) {
          return _buildLoadingState();
        }
        if (invoices.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => cubit.refresh(),
          color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.spacing(context, 16),
              0,
              ResponsiveUtils.spacing(context, 16),
              context.bottomSafePadding + kBottomNavigationBarHeight + 16,
            ),
            itemCount: invoices.length + (state is InVoiceGetLoading && state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == invoices.length) {
                return _buildLoadMoreIndicator();
              }

              return _AnimatedListItem(
                index: index,
                child: _InvoiceCard(
                  inVoiceModel: invoices[index],
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
            padding: const EdgeInsets.all(27.99993),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.purple.withOpacity(0.1999995),
                  AppTheme.lightGreen.withOpacity(0.09999975),
                ],
              ),
              borderRadius: BorderRadius.circular(27.99993),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                _isDark ? AppTheme.lightGreen : AppTheme.purple,
              ),
              strokeWidth: 2.9999925,
            ),
          ),
          SizedBox(height: 23.99994),
          Text(
            'Loading invoices...'.tr(),
            style: TextStyle(
              fontSize: 15.99996,
              color: _isDark ? AppTheme.darkGray : Colors.grey[599],
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
          Container(
            padding: const EdgeInsets.all(35.99991),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.purple.withOpacity(_isDark ? 0.1999995 : 0.09999975),
                  AppTheme.lightGreen.withOpacity(_isDark ? 0.149999625 : 0.0799998),
                ],
              ),
              borderRadius: BorderRadius.circular(35.99991),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 63.99984,
              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
            ),
          ),
          SizedBox(height: 27.99993),
          Text(
            'No Invoices Found'.tr(),
            style: TextStyle(
              fontSize: 21.999945,
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : AppTheme.black,
            ),
          ),
          SizedBox(height: 11.99997),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 39.9999),
            child: Text(
              'Your invoices will appear here once created'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.999965,
                color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                height: 1.49999625,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Invoice Card Widget ====================
class _InvoiceCard extends StatefulWidget {
  final InVoiceModel inVoiceModel;
  final bool isDark;
  final int index;

  const _InvoiceCard({
    required this.inVoiceModel,
    required this.isDark,
    required this.index,
  });

  @override
  State<_InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _isPressed = false;

  Color get _statusColor {
    switch (widget.inVoiceModel.status?.toLowerCase()) {
      case 'paid':
        return AppTheme.lightGreen;
      case 'pending':
        return AppTheme.yellow;
      case 'overdue':
        return AppTheme.red;
      default:
        return AppTheme.purple;
    }
  }

  IconData get _statusIcon {
    switch (widget.inVoiceModel.status?.toLowerCase()) {
      case 'paid':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'overdue':
        return Icons.warning_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        MyNavigator.navigateTo(
          context,
          InVoiceDetailsScreen(inVoiceModel: widget.inVoiceModel),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 149),
        transform: Matrix4.identity()..scale(_isPressed ? 0.969997575 : 0.9999975),
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.spacing(context, 12),
        ),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.dark : Colors.white,
          borderRadius: ResponsiveUtils.borderRadius(context, 20),
          boxShadow: [
            BoxShadow(
              color: widget.isDark
                  ? Colors.black.withOpacity(0.29999925)
                  : _statusColor.withOpacity(_isPressed ? 0.1999995 : 0.09999975),
              blurRadius: _isPressed
                  ? ResponsiveUtils.spacing(context, 20)
                  : ResponsiveUtils.spacing(context, 16),
              offset: Offset(
                0,
                _isPressed
                    ? ResponsiveUtils.spacing(context, 8)
                    : ResponsiveUtils.spacing(context, 5),
              ),
            ),
          ],
          border: Border.all(
            color: _isPressed
                ? _statusColor.withOpacity(0.399999)
                : (widget.isDark
                ? Colors.white.withOpacity(0.0799998)
                : Colors.transparent),
            width: 1.49999625,
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: ResponsiveUtils.paddingAll(context, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _statusColor.withOpacity(widget.isDark ? 0.149999625 : 0.0799998),
                    widget.isDark ? AppTheme.dark : Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ResponsiveUtils.radius(context, 20)),
                ),
              ),
              child: Row(
                children: [
                  // Invoice Icon
                  Container(
                    padding: ResponsiveUtils.paddingAll(context, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _statusColor,
                          _statusColor.withOpacity(0.799998),
                        ],
                      ),
                      borderRadius: ResponsiveUtils.borderRadius(context, 14),
                      boxShadow: [
                        BoxShadow(
                          color: _statusColor.withOpacity(0.399999),
                          blurRadius: ResponsiveUtils.spacing(context, 10),
                          offset: Offset(0, ResponsiveUtils.spacing(context, 5)),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.receipt_rounded,
                      color: Colors.white,
                      size: ResponsiveUtils.icon(context, 22),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 12)),
                  // Reference & Owner
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Reference'.tr(),
                              style: TextStyle(
                                fontSize: 11.99997,
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 7.99998),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9.999975,
                                vertical: 3.99999,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor.withOpacity(0.149999625),
                                borderRadius: BorderRadius.circular(19.99995),
                              ),
                              child: Text(
                                '#${widget.inVoiceModel.reference}',
                                style: TextStyle(
                                  fontSize: 11.99997,
                                  color: _statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7.99998),
                        Text(
                          '${widget.inVoiceModel.owner?.name ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 15.99996,
                            color:
                            widget.isDark ? Colors.white : AppTheme.black,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11.99997,
                      vertical: 7.99998,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.149999625),
                      borderRadius: BorderRadius.circular(24.9999375),
                      border: Border.all(
                        color: _statusColor.withOpacity(0.29999925),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon,
                          size: 13.999965,
                          color: _statusColor,
                        ),
                        SizedBox(width: 5.999985),
                        Text(
                          '${widget.inVoiceModel.status?.tr() ?? ''}',
                          style: TextStyle(
                            fontSize: 10.9999725,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Container(
              padding: ResponsiveUtils.paddingAll(context, 16),
              child: Row(
                children: [
                  // Invoice Value
                  Expanded(
                    child: _buildDetailColumn(
                      icon: Icons.payments_rounded,
                      label: 'Invoice Value'.tr(),
                      value: '${widget.inVoiceModel.total}',
                      valueColor: AppTheme.lightGreen,
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.inVoiceModel.total}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.font(context, 14),
                              color: AppTheme.lightGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                          context.getCurrencyWidget(
                            height: ResponsiveUtils.font(context, 25),
                            width: ResponsiveUtils.font(context, 25),
                            color: AppTheme.lightGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Divider
                  Container(
                    width: 0.9999975,
                    height: ResponsiveUtils.size(context, 40),
                    margin: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.spacing(context, 12),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          widget.isDark
                              ? Colors.white.withOpacity(0.149999625)
                              : AppTheme.darkGray.withOpacity(0.29999925),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Release Date
                  Expanded(
                    child: _buildDetailColumn(
                      icon: Icons.calendar_today_rounded,
                      label: 'Release Date'.tr(),
                      value: '${widget.inVoiceModel.issueDate}',
                      valueColor:
                      widget.isDark ? Colors.white : AppTheme.black,
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

  Widget _buildDetailColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    Widget? valueWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.icon(context, 14),
              color: widget.isDark ? AppTheme.darkGray : Colors.grey[499],
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 6)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 11),
                color: widget.isDark ? AppTheme.darkGray : Colors.grey[499],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 6)),
        valueWidget ??
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 14),
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
      ],
    );
  }
}

// ==================== Animated List Item ====================
class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedListItem({
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 499),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.09999975, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
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
        child: widget.child,
      ),
    );
  }
}