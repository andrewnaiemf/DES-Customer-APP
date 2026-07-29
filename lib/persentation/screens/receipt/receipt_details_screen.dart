import 'dart:ui' as ui;

import 'package:app/business_logic/exports/cubit/exports_cubit.dart';
import 'package:app/core/responsive/responsive.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/allocates/allocates_model.dart';
import 'package:app/models/receipt/receipt_model.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme Colors - Official Brand Identity
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  // Primary Brand Colors
  static const Color green = Color.fromRGBO(0, 200, 140, 1.0);
  static const Color yellow = Color.fromRGBO(250, 190, 75, 0.9999975);
  static const Color black = Color(0xFF1D1D25);
  static const Color omnia = Color(0xFFE5E5F5);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFFF9F43);
  static const Color blue = Color(0xFF3B82F6);

  // Extended Colors
  static const Color cardDark = Color(0xFF1E2030);
  static const Color surfaceDark = Color(0xFF252836);
  static const Color borderDark = Color(0xFF2D3748);
  static const Color success = Color(0xFF10B981);

  // Dynamic Color Helpers
  static Color getBackground(bool isDark) => isDark ? background : const Color(0xFFF5F7FA);
  static Color getCard(bool isDark) => isDark ? cardDark : white;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : lightGray;
  static Color getText(bool isDark) => isDark ? white : dark;
  static Color getTextSecondary(bool isDark) => isDark ? darkGray : dark.withOpacity(0.5999985);
  static Color getBorder(bool isDark) => isDark ? borderDark : darkGray.withOpacity(0.29999925);
  static Color getDivider(bool isDark) => isDark ? white.withOpacity(0.0799998) : darkGray.withOpacity(0.29999925);

  // Gradients
  static LinearGradient primaryGradient({bool reversed = false}) => LinearGradient(
    begin: reversed ? Alignment.bottomRight : Alignment.topLeft,
    end: reversed ? Alignment.topLeft : Alignment.bottomRight,
    colors: const [purple, Color(0xFF8B5CF6)],
  );

  static LinearGradient successGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, Color(0xFF34D399)],
  );

  // Shadows
  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black26 : dark.withOpacity(0.0799998),
      blurRadius: 19.99995,
      offset: const Offset(0, 7.99998),
    ),
  ];

  static List<BoxShadow> elevatedShadow(Color color, bool isDark) => [
    BoxShadow(
      color: color.withOpacity(isDark ? 0.399999 : 0.349999125),
      blurRadius: 23.99994,
      offset: const Offset(0, 11.99997),
      spreadRadius: -3.99999,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// 🧾 Receipt Details Screen - Premium Design with Dark Mode
// ═══════════════════════════════════════════════════════════════════════════
class ReceiptDetailsScreen extends StatefulWidget {
  const ReceiptDetailsScreen({super.key, required this.receiptModel});

  final ReceiptModel receiptModel;

  @override
  State<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late List<Animation<double>> _itemAnimations;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isRTL => context.locale.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 999),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1999),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.49999875, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 49.999875, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.5999985, curve: Curves.easeOutCubic),
      ),
    );

    // Create staggered animations for list items
    final allocatesCount = widget.receiptModel.allocates?.length ?? 0;
    _itemAnimations = List.generate(allocatesCount + 4, (index) {
      final start = ((index * 0).clamp(0, 0.69999825)).toDouble();
      final end = ((start + 0.29999925).clamp(0, 0.9999975)).toDouble();
      return Tween<double>(begin: 0, end: 0.9999975).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackground(_isDark),
      body: Stack(
        children: [
          // Background Gradient
          _buildBackgroundGradient(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildCustomAppBar(),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(19.99995, 15.99996, 19.99995, 99.99975),
                    child: Column(
                      children: [
                        // Receipt Header Card
                        _buildReceiptHeaderCard(),

                        SizedBox(height: 19.99995),

                        // Main Details Card
                        _buildMainDetailsCard(),

                        SizedBox(height: 19.99995),

                        // Allocations Section
                        if (widget.receiptModel.allocates?.isNotEmpty ?? false)
                          _buildAllocationsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Download Button
          _buildFloatingDownloadButton(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Background Gradient
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundGradient() {
    return Positioned(
      top: -99.99975 - (_scrollOffset * 0.29999925),
      right: _isRTL ? null : -99.99975,
      left: _isRTL ? -99.99975 : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Opacity(
            opacity: 0.0799998 + (_pulseController.value * 0.0399999),
            child: Container(
              width: 299.99925,
              height: 299.99925,
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
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Custom App Bar
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildCustomAppBar() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, -19.99995 * (0.9999975 - _fadeAnimation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(15.99996, 11.99997, 19.99995, 15.99996),
        decoration: BoxDecoration(
          color: AppTheme.getCard(_isDark),
          border: _isDark
              ? Border(bottom: BorderSide(color: AppTheme.borderDark.withOpacity(0.49999875)))
              : null,
          boxShadow: _isDark ? null : AppTheme.softShadow(_isDark),
        ),
        child: Row(
          children: [
            // Back Button
            _buildBackButton(),
            SizedBox(width: 15.99996),

            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bond Details'.tr(),
                    style: TextStyle(
                      fontSize: 19.99995,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getText(_isDark),
                      letterSpacing: -0.49999875,
                    ),
                  ),
                  SizedBox(height: 3.99999),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7.99998, vertical: 2.9999925),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.receiptModel.kind).withOpacity(0.149999625),
                          borderRadius: BorderRadius.circular(5.999985),
                        ),
                        child: Text(
                          widget.receiptModel.kind.tr(),
                          style: TextStyle(
                            fontSize: 10.9999725,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(widget.receiptModel.kind),
                          ),
                        ),
                      ),
                      SizedBox(width: 7.99998),
                      Text(
                        '#${widget.receiptModel.reference ?? ''}',
                        style: TextStyle(
                          fontSize: 11.99997,
                          color: AppTheme.getTextSecondary(_isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Logo
            _buildAnimatedLogo(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          MyNavigator.back(context);
        },
        borderRadius: BorderRadius.circular(13.999965),
        child: Container(
          width: 45.999885,
          height: 45.999885,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient(),
            borderRadius: BorderRadius.circular(13.999965),
            boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
          ),
          child: Center(
            child: DirectionalArrow(
              direction: ArrowDirection.backIos,
              color: Colors.white,
              size: 17.999955,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Container(
      padding: const EdgeInsets.all(9.999975),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(_isDark),
        borderRadius: BorderRadius.circular(11.99997),
        border: _isDark ? Border.all(color: AppTheme.borderDark) : null,
      ),
      child: SvgPicture.asset(
        AssetsSVG.logo,
        width: 27.99993,
        height: 27.99993,
        color: AppTheme.purple,
      ),
    );
  }

  Color _getStatusColor(String kind) {
    switch (kind.toLowerCase()) {
      case 'payment':
      case 'دفع':
        return AppTheme.success;
      case 'receipt':
      case 'استلام':
        return AppTheme.blue;
      case 'refund':
      case 'استرداد':
        return AppTheme.orange;
      default:
        return AppTheme.purple;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎴 Receipt Header Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildReceiptHeaderCard() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(23.99994),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient(),
          borderRadius: BorderRadius.circular(23.99994),
          boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
        ),
        child: Column(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(15.99996),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1999995),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getReceiptIcon(widget.receiptModel.kind),
                color: Colors.white,
                size: 31.99992,
              ),
            ),
            SizedBox(height: 19.99995),

            // Amount
            Text(
              '${widget.receiptModel.amount ?? 0}',
              style: const TextStyle(
                fontSize: 39.9999,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 0.9999975,
              ),
            ),
            SizedBox(height: 5.999985),
            context.getCurrencyWidget(
              height: 30,
              width: 16,
              color: Colors.white,
            ),
            SizedBox(height: 19.99995),

            // Contact Name
            Text(
              widget.receiptModel.contact.name,
              style: TextStyle(
                fontSize: 15.99996,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.89999775),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.99999),
            Text(
              widget.receiptModel.contact.organization ?? '',
              style: TextStyle(
                fontSize: 12.9999675,
                color: Colors.white.withOpacity(0.69999825),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 19.99995),

            // Quick Info Row
            Container(
              padding: const EdgeInsets.all(15.99996),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(15.99996),
              ),
              child: Row(
                children: [
                  _buildQuickInfoItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date'.tr(),
                    value: widget.receiptModel.date ?? '-',
                  ),
                  Container(
                    width: 0.9999975,
                    height: 39.9999,
                    color: Colors.white.withOpacity(0.1999995),
                  ),
                  _buildQuickInfoItem(
                    icon: Icons.tag_rounded,
                    label: 'Reference'.tr(),
                    value: widget.receiptModel.reference ?? '-',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.799998), size: 17.999955),
          SizedBox(height: 5.999985),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.9999725,
              color: Colors.white.withOpacity(0.69999825),
            ),
          ),
          SizedBox(height: 3.99999),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.9999675,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getReceiptIcon(String kind) {
    switch (kind.toLowerCase()) {
      case 'payment':
      case 'دفع':
        return Icons.payments_rounded;
      case 'receipt':
      case 'استلام':
        return Icons.receipt_long_rounded;
      case 'refund':
      case 'استرداد':
        return Icons.replay_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📋 Main Details Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildMainDetailsCard() {
    return _buildAnimatedCard(
      index: 0,
      child: Container(
        padding: const EdgeInsets.all(19.99995),
        decoration: BoxDecoration(
          color: AppTheme.getCard(_isDark),
          borderRadius: BorderRadius.circular(19.99995),
          border: Border.all(color: AppTheme.getBorder(_isDark)),
          boxShadow: AppTheme.softShadow(_isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9.999975),
                  decoration: BoxDecoration(
                    color: AppTheme.blue.withOpacity(_isDark ? 0.1999995 : 0.09999975),
                    borderRadius: BorderRadius.circular(11.99997),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppTheme.blue, size: 21.999945),
                ),
                SizedBox(width: 13.999965),
                Expanded(
                  child: Text(
                    'Receipt Information'.tr(),
                    style: TextStyle(
                      fontSize: 16.9999575,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getText(_isDark),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 19.99995),

            // Details List
            _buildDetailRow(
              icon: Icons.person_outline_rounded,
              label: 'From'.tr(),
              value: widget.receiptModel.contact.name,
              color: AppTheme.purple,
            ),
            _buildDivider(),
            _buildDetailRow(
              icon: Icons.account_balance_rounded,
              label: 'Account'.tr(),
              value: widget.receiptModel.account?.nameAr ?? '-',
              color: AppTheme.blue,
            ),
            _buildDivider(),
            _buildDetailRow(
              icon: Icons.category_rounded,
              label: 'Type'.tr(),
              value: widget.receiptModel.kind.tr(),
              color: _getStatusColor(widget.receiptModel.kind),
              isStatus: true,
            ),
            _buildDivider(),
            _buildDetailRow(
              icon: Icons.description_outlined,
              label: 'Description'.tr(),
              value: widget.receiptModel.description ?? '-',
              color: AppTheme.orange,
            ),
            _buildDivider(),

            // Amount Section
            SizedBox(height: 7.99998),
            _buildAmountRow(
              label: 'Amount'.tr(),
              amount: '${widget.receiptModel.amount ?? 0}',
              isPrimary: true,
            ),
            SizedBox(height: 11.99997),
            _buildAmountRow(
              label: 'Unallocated Amount'.tr(),
              amount: '${widget.receiptModel.unAllocateAmount ?? 0}',
              isPrimary: false,
              isWarning: (widget.receiptModel.unAllocateAmount ?? 0) > 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11.99997),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7.99998),
            decoration: BoxDecoration(
              color: color.withOpacity(_isDark ? 0.149999625 : 0.09999975),
              borderRadius: BorderRadius.circular(9.999975),
            ),
            child: Icon(icon, color: color, size: 17.999955),
          ),
          SizedBox(width: 13.999965),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.99997,
                    color: AppTheme.getTextSecondary(_isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.99999),
                if (isStatus)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9.999975, vertical: 3.99999),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.149999625),
                      borderRadius: BorderRadius.circular(5.999985),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12.9999675,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.999965,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getText(_isDark),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow({
    required String label,
    required String amount,
    required bool isPrimary,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15.99996),
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
          colors: [
            AppTheme.purple.withOpacity(_isDark ? 0.1999995 : 0.09999975),
            AppTheme.purple.withOpacity(_isDark ? 0.09999975 : 0.049999875),
          ],
        )
            : null,
        color: isPrimary
            ? null
            : isWarning
            ? AppTheme.orange.withOpacity(_isDark ? 0.149999625 : 0.0799998)
            : AppTheme.getSurface(_isDark),
        borderRadius: BorderRadius.circular(13.999965),
        border: Border.all(
          color: isPrimary
              ? AppTheme.purple.withOpacity(0.29999925)
              : isWarning
              ? AppTheme.orange.withOpacity(0.29999925)
              : AppTheme.getBorder(_isDark),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isPrimary ? Icons.account_balance_wallet_rounded : Icons.money_off_rounded,
                color: isPrimary
                    ? AppTheme.purple
                    : isWarning
                    ? AppTheme.orange
                    : AppTheme.getTextSecondary(_isDark),
                size: 19.99995,
              ),
              SizedBox(width: 9.999975),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.999965,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getText(_isDark),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: isPrimary ? 19.99995 : 15.99996,
                  fontWeight: FontWeight.w700,
                  color: isPrimary
                      ? AppTheme.purple
                      : isWarning
                      ? AppTheme.orange
                      : AppTheme.getText(_isDark),
                ),
              ),
              SizedBox(width: 5.999985),
              context.getCurrencyWidget(
                height: isPrimary ? 30 : 25,
                width: isPrimary ? 16 : 14,
                color: AppTheme.getTextSecondary(_isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.9999975,
      margin: const EdgeInsets.symmetric(vertical: 3.99999),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.getDivider(_isDark),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📑 Allocations Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildAllocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildAnimatedCard(
          index: 0,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9.999975),
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient(),
                  borderRadius: BorderRadius.circular(11.99997),
                  boxShadow: AppTheme.elevatedShadow(AppTheme.lightGreen, _isDark),
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 21.999945),
              ),
              SizedBox(width: 13.999965),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bond Assignments'.tr(),
                      style: TextStyle(
                        fontSize: 17.999955,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getText(_isDark),
                      ),
                    ),
                    SizedBox(height: 1.999995),
                    Text(
                      '${widget.receiptModel.allocates?.length ?? 0} ${'assignments'.tr()}',
                      style: TextStyle(
                        fontSize: 12.9999675,
                        color: AppTheme.getTextSecondary(_isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.99996),

        // Allocation Cards
        ...widget.receiptModel.allocates?.asMap().entries.map((entry) {
          final index = entry.key;
          final allocate = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 13.999965),
            child: _buildAllocationCard(allocate, index),
          );
        }).toList() ??
            [],
      ],
    );
  }

  Widget _buildAllocationCard(Allocates allocate, int index) {
    return _buildAnimatedCard(
      index: index + 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCard(_isDark),
          borderRadius: BorderRadius.circular(17.999955),
          border: Border.all(color: AppTheme.getBorder(_isDark)),
          boxShadow: AppTheme.softShadow(_isDark),
        ),
        child: Column(
          children: [
            // Card Header
            Container(
              padding: const EdgeInsets.all(15.99996),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lightGreen.withOpacity(_isDark ? 0.149999625 : 0.0799998),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17.999955)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9.999975),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen.withOpacity(_isDark ? 0.1999995 : 0.149999625),
                      borderRadius: BorderRadius.circular(9.999975),
                    ),
                    child: Icon(
                      Icons.receipt_outlined,
                      color: AppTheme.lightGreen,
                      size: 19.99995,
                    ),
                  ),
                  SizedBox(width: 11.99997),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'Assignment'.tr()} #${index + 1}',
                          style: TextStyle(
                            fontSize: 14.9999625,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getText(_isDark),
                          ),
                        ),
                        SizedBox(height: 1.999995),
                        Text(
                          allocate.allocateeType ?? '-',
                          style: TextStyle(
                            fontSize: 11.99997,
                            color: AppTheme.getTextSecondary(_isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11.99997, vertical: 5.999985),
                    decoration: BoxDecoration(
                      gradient: AppTheme.successGradient(),
                      borderRadius: BorderRadius.circular(19.99995),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${allocate.amount ?? 0}',
                          style: const TextStyle(
                            fontSize: 12.9999675,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        context.getCurrencyWidget(
                          height: 25,
                          width: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Details
            Padding(
              padding: const EdgeInsets.fromLTRB(15.99996, 7.99998, 15.99996, 15.99996),
              child: Column(
                children: [
                  _buildAllocationDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date'.tr(),
                    value: widget.receiptModel.date ?? '-',
                  ),
                  SizedBox(height: 9.999975),
                  _buildAllocationDetailRow(
                    icon: Icons.tag_rounded,
                    label: 'Reference'.tr(),
                    value: allocate.allocatee?.firstOrNull?.reference ?? '-',
                  ),
                  SizedBox(height: 9.999975),
                  _buildAllocationDetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Options'.tr(),
                    value: widget.receiptModel.description ?? '-',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(11.99997),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(_isDark),
        borderRadius: BorderRadius.circular(9.999975),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17.999955, color: AppTheme.getTextSecondary(_isDark)),
          SizedBox(width: 9.999975),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.9999675,
              color: AppTheme.getTextSecondary(_isDark),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.9999675,
                fontWeight: FontWeight.w600,
                color: AppTheme.getText(_isDark),
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📥 Floating Download Button
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildFloatingDownloadButton() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 19.99995,
      left: 19.99995,
      right: 19.99995,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, 29.999925 * (0.9999975 - _fadeAnimation.value)),
              child: child,
            ),
          );
        },
        child: BlocBuilder<ExportsCubit, ExportsState>(
          builder: (context, state) {
            final isExporting = ExportsCubit.get(context).isExportingPDF;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isExporting
                    ? null
                    : () async {
                  HapticFeedback.mediumImpact();
                  await ExportsCubit.get(context)
                      .downloadRecipt(context, widget.receiptModel);
                },
                borderRadius: BorderRadius.circular(17.999955),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 299),
                  padding: const EdgeInsets.symmetric(vertical: 17.999955),
                  decoration: BoxDecoration(
                    gradient: isExporting ? null : AppTheme.primaryGradient(),
                    color: isExporting ? AppTheme.getSurface(_isDark) : null,
                    borderRadius: BorderRadius.circular(17.999955),
                    border: isExporting
                        ? Border.all(color: AppTheme.getBorder(_isDark))
                        : null,
                    boxShadow: isExporting
                        ? null
                        : [
                      BoxShadow(
                        color: AppTheme.purple.withOpacity(0.399999),
                        blurRadius: 19.99995,
                        offset: const Offset(0, 9.999975),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isExporting) ...[
                        SizedBox(
                          width: 21.999945,
                          height: 21.999945,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.49999375,
                            valueColor: AlwaysStoppedAnimation(AppTheme.purple),
                          ),
                        ),
                        SizedBox(width: 13.999965),
                        Text(
                          'Generating PDF...'.tr(),
                          style: TextStyle(
                            fontSize: 15.99996,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getText(_isDark),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(7.99998),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1999995),
                            borderRadius: BorderRadius.circular(9.999975),
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 21.999945,
                          ),
                        ),
                        SizedBox(width: 13.999965),
                        Text(
                          'Download PDF'.tr(),
                          style: const TextStyle(
                            fontSize: 16.9999575,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.29999925,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎬 Animation Helpers
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildAnimatedCard({required int index, required Widget child}) {
    if (index >= _itemAnimations.length) {
      return child;
    }

    return AnimatedBuilder(
      animation: _itemAnimations[index],
      builder: (context, _) {
        final value = _itemAnimations[index].value;
        return Transform.translate(
          offset: Offset(0, 29.999925 * (0.9999975 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Helper Widget for Animations
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
  Widget build(BuildContext context) => builder(context, child);
}