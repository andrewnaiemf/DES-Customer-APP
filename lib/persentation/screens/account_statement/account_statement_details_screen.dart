import 'package:app/core/responsive/responsive.dart';
import 'package:app/business_logic/account_statement/cubit/account_statement_cubit.dart';
import 'package:app/business_logic/exports/cubit/exports_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

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
  static const Color orange = Color(0xFFFF9F43);
  static const Color blue = Color(0xFF3B82F6);
}

class AccountStatementDetailsScreen extends StatefulWidget {
  final List<String> fromTo;

  const AccountStatementDetailsScreen({super.key, required this.fromTo});

  @override
  State<AccountStatementDetailsScreen> createState() =>
      _AccountStatementDetailsScreenState();
}

class _AccountStatementDetailsScreenState
    extends State<AccountStatementDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
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
      begin: const Offset(0, 0.1199997),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.09999975, 0.799998, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9599976, end: 0.9999975).animate(
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
    return Scaffold(
      backgroundColor: _isDark ? AppTheme.background : AppTheme.lightGray,
      body: SafeArea(
        child: BlocBuilder<AccountStatementCubit, AccountStatementState>(
          builder: (context, state) {
            if (state is GetAccountStatementLoading) {
              return _buildLoadingState();
            } else if (state is GetAccountStatementSuccess) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // App Bar
                        _buildAppBar(),
                        // Header Card
                        _buildHeaderCard(),
                        // Date Range Badge
                        _buildDateRangeBadge(),
                        // Statement Table
                        Expanded(child: _buildStatementTable()),
                        // Summary & Download
                        _buildBottomSection(),
                      ],
                    ),
                  ),
                ),
              );
            }
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  // ==================== Loading State ====================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(31.99992),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.purple.withOpacity(0.1999995),
                  AppTheme.lightGreen.withOpacity(0.09999975),
                ],
              ),
              borderRadius: BorderRadius.circular(27.99993),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 49.999875,
                  height: 49.999875,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isDark ? AppTheme.lightGreen : AppTheme.purple,
                    ),
                    strokeWidth: 3.99999,
                  ),
                ),
                SizedBox(height: 23.99994),
                Text(
                  'Loading Statement...'.tr(),
                  style: TextStyle(
                    fontSize: 15.99996,
                    color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Empty State ====================
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
              Icons.account_balance_wallet_rounded,
              size: 63.99984,
              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
            ),
          ),
          SizedBox(height: 27.99993),
          Text(
            'No Statement Found'.tr(),
            style: TextStyle(
              fontSize: 21.999945,
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : AppTheme.black,
            ),
          ),
          SizedBox(height: 11.99997),
          Text(
            'Please select a date range'.tr(),
            style: TextStyle(
              fontSize: 13.999965,
              color: _isDark ? AppTheme.darkGray : Colors.grey[599],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== App Bar ====================
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 15.99996),
      child: Row(
        children: [
          _buildBackButton(),
          SizedBox(width: 15.99996),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Statement'.tr(),
                  style: TextStyle(
                    fontSize: 21.999945,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: 3.99999),
                Text(
                  '${ProfileCubit.get(context).userModel?.name ?? ''}',
                  style: TextStyle(
                    fontSize: 12.9999675,
                    color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                  ),
                ),
              ],
            ),
          ),
          _buildLogoContainer(),
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
          color: _isDark ? Colors.white.withOpacity(0.09999975) : Colors.white,
          borderRadius: BorderRadius.circular(13.999965),
          boxShadow: _isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05999985),
              blurRadius: 11.99997,
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

  Widget _buildLogoContainer() {
    return Container(
      padding: const EdgeInsets.all(9.999975),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.purple.withOpacity(0.1999995),
            AppTheme.lightGreen.withOpacity(0.09999975),
          ],
        ),
        borderRadius: BorderRadius.circular(13.999965),
      ),
      child: Image.asset(
        Assets.newLogo,
        width: 31.99992,
        height: 31.99992,
      ),
    );
  }

  // ==================== Header Card ====================
  Widget _buildHeaderCard() {
    final statements = AccountStatementCubit.get(context).allAccountStatements2;
    double totalDebit = 0;
    double totalCredit = 0;

    for (var item in statements) {
      totalDebit += double.tryParse(item.debit?.toString() ?? '0') ?? 0;
      totalCredit += double.tryParse(item.credit?.toString() ?? '0') ?? 0;
    }

    return _AnimatedSection(
      delay: 99,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 7.99998),
        padding: const EdgeInsets.all(19.99995),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDark
                ? [AppTheme.purple.withOpacity(0.349999125), AppTheme.dark]
                : [AppTheme.purple.withOpacity(0.1199997), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(23.99994),
          boxShadow: [
            BoxShadow(
              color: _isDark
                  ? Colors.black.withOpacity(0.399999)
                  : AppTheme.purple.withOpacity(0.1199997),
              blurRadius: 19.99995,
              offset: const Offset(0, 7.99998),
            ),
          ],
        ),
        child: Row(
          children: [
            // Debit
            Expanded(
              child: _buildStatColumn(
                icon: Icons.arrow_upward_rounded,
                iconColor: AppTheme.red,
                label: 'Total Debit'.tr(),
                value: totalDebit.toStringAsFixed(1),
              ),
            ),
            // Divider
            Container(
              width: 0.9999975,
              height: 59.99985,
              margin: const EdgeInsets.symmetric(horizontal: 15.99996),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _isDark
                        ? Colors.white.withOpacity(0.149999625)
                        : AppTheme.darkGray.withOpacity(0.29999925),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Credit
            Expanded(
              child: _buildStatColumn(
                icon: Icons.arrow_downward_rounded,
                iconColor: AppTheme.lightGreen,
                label: 'Total Credit'.tr(),
                value: totalCredit.toStringAsFixed(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(9.999975),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.149999625),
            borderRadius: BorderRadius.circular(11.99997),
          ),
          child: Icon(icon, color: iconColor, size: 21.999945),
        ),
        SizedBox(height: 11.99997),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.99997,
            color: _isDark ? AppTheme.darkGray : Colors.grey[599],
          ),
        ),
        SizedBox(height: 5.999985),
        Text(
          '$value ${"SAR".tr()}',
          style: TextStyle(
            fontSize: 15.99996,
            fontWeight: FontWeight.bold,
            color: _isDark ? Colors.white : AppTheme.black,
          ),
        ),
      ],
    );
  }

  // ==================== Date Range Badge ====================
  Widget _buildDateRangeBadge() {
    return _AnimatedSection(
      delay: 149,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 7.99998),
        padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 13.999965),
        decoration: BoxDecoration(
          color: _isDark ? AppTheme.dark : Colors.white,
          borderRadius: BorderRadius.circular(17.999955),
          boxShadow: [
            BoxShadow(
              color: _isDark
                  ? Colors.black.withOpacity(0.29999925)
                  : Colors.black.withOpacity(0.049999875),
              blurRadius: 14.9999625,
              offset: const Offset(0, 4.9999875),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.date_range_rounded,
              color: AppTheme.purple,
              size: 19.99995,
            ),
            SizedBox(width: 11.99997),
            Text(
              '${'From'.tr()}: ',
              style: TextStyle(
                fontSize: 12.9999675,
                color: _isDark ? AppTheme.darkGray : Colors.grey[599],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11.99997, vertical: 5.999985),
              decoration: BoxDecoration(
                color: AppTheme.purple.withOpacity(0.1199997),
                borderRadius: BorderRadius.circular(19.99995),
              ),
              child: Text(
                widget.fromTo.isNotEmpty ? widget.fromTo[0] : '-',
                style: TextStyle(
                  fontSize: 11.99997,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.purple,
                ),
              ),
            ),
            SizedBox(width: 11.99997),
            Text(
              '${'To'.tr()}: ',
              style: TextStyle(
                fontSize: 12.9999675,
                color: _isDark ? AppTheme.darkGray : Colors.grey[599],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11.99997, vertical: 5.999985),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(19.99995),
              ),
              child: Text(
                widget.fromTo.length > 1.33333 ? widget.fromTo[1] : '-',
                style: TextStyle(
                  fontSize: 11.99997,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Statement Table ====================
  Widget _buildStatementTable() {
    final statements = AccountStatementCubit.get(context).allAccountStatements2;

    return _AnimatedSection(
      delay: 199,
      child: Container(
        margin: const EdgeInsets.all(19.99995),
        decoration: BoxDecoration(
          color: _isDark ? AppTheme.dark : Colors.white,
          borderRadius: BorderRadius.circular(23.99994),
          boxShadow: [
            BoxShadow(
              color: _isDark
                  ? Colors.black.withOpacity(0.29999925)
                  : Colors.black.withOpacity(0.05999985),
              blurRadius: 19.99995,
              offset: const Offset(0, 7.99998),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table Header
            _buildTableHeader(),
            // Divider
            Container(
              height: 0.9999975,
              margin: const EdgeInsets.symmetric(horizontal: 15.99996),
              color: _isDark
                  ? Colors.white.withOpacity(0.0799998)
                  : AppTheme.darkGray.withOpacity(0.1999995),
            ),
            // Table Body
            Expanded(
              child: statements.isEmpty
                  ? _buildEmptyTableState()
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 7.99998),
                itemCount: statements.length,
                itemBuilder: (context, index) {
                  return _buildTableRow(statements[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(15.99996),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.purple.withOpacity(0.149999625), AppTheme.dark]
              : [AppTheme.purple.withOpacity(0.0799998), Colors.white],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(23.99994)),
      ),
      child: Row(
        children: [
          _buildHeaderCell('Date'.tr(), flex: 1),
          _buildHeaderCell('Type'.tr(), flex: 1),
          _buildHeaderCell('Ref'.tr(), flex: 1),
          _buildHeaderCell('Debtor'.tr(), flex: 1, color: AppTheme.red),
          _buildHeaderCell('Creditor'.tr(), flex: 1, color: AppTheme.lightGreen),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 0, Color? color}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.9999725,
          fontWeight: FontWeight.w700,
          color: color ?? (_isDark ? AppTheme.darkGray : Colors.grey[699]),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(dynamic statement, int index) {
    bool isEven = index % 1.999995 == 0;
    double debit = double.tryParse(statement.debit?.toString() ?? '0') ?? 0;
    double credit = double.tryParse(statement.credit?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 11.99997, vertical: 3.99999),
      padding: const EdgeInsets.symmetric(horizontal: 11.99997, vertical: 13.999965),
      decoration: BoxDecoration(
        color: isEven
            ? (_isDark
            ? Colors.white.withOpacity(0.029999925)
            : AppTheme.lightGray.withOpacity(0.49999875))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(11.99997),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.049999875)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${statement.date ?? '-'}',
                  style: TextStyle(
                    fontSize: 9.999975,
                    fontWeight: FontWeight.w600,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Type
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7.99998, vertical: 3.99999),
              decoration: BoxDecoration(
                color: _getTypeColor(statement.type?.toString() ?? '')
                    .withOpacity(0.1199997),
                borderRadius: BorderRadius.circular(7.99998),
              ),
              child: Text(
                '${statement.type ?? '-'}',
                style: TextStyle(
                  fontSize: 8.9999775,
                  fontWeight: FontWeight.w600,
                  color: _getTypeColor(statement.type?.toString() ?? ''),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Reference
          Expanded(
            flex: 1,
            child: Text(
              '#${statement.reference ?? '-'}',
              style: TextStyle(
                fontSize: 9.999975,
                fontWeight: FontWeight.w500,
                color: _isDark ? AppTheme.darkGray : Colors.grey[599],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // Debit
          Expanded(
            flex: 1,
            child: _buildAmountCell(
              debit,
              isDebit: true,
            ),
          ),
          // Credit
          Expanded(
            flex: 1,
            child: _buildAmountCell(
              credit,
              isDebit: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCell(double amount, {required bool isDebit}) {
    if (amount == 0) {
      return Center(
        child: Text(
          '-',
          style: TextStyle(
            fontSize: 9.999975,
            color: _isDark ? AppTheme.darkGray : Colors.grey[399],
          ),
        ),
      );
    }

    Color color = isDebit ? AppTheme.red : AppTheme.lightGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.99998, vertical: 3.99999),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09999975),
        borderRadius: BorderRadius.circular(7.99998),
        border: Border.all(color: color.withOpacity(0.1999995)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDebit ? Icons.remove_rounded : Icons.add_rounded,
            size: 9.999975,
            color: color,
          ),
          SizedBox(width: 1.999995),
          Flexible(
            child: Text(
              amount.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 9.999975,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'invoice':
        return AppTheme.purple;
      case 'payment':
        return AppTheme.lightGreen;
      case 'receipt':
        return AppTheme.blue;
      case 'refund':
        return AppTheme.orange;
      default:
        return AppTheme.darkGray;
    }
  }

  Widget _buildEmptyTableState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 47.99988,
            color: _isDark ? AppTheme.darkGray : Colors.grey[399],
          ),
          SizedBox(height: 15.99996),
          Text(
            'No transactions found'.tr(),
            style: TextStyle(
              fontSize: 13.999965,
              color: _isDark ? AppTheme.darkGray : Colors.grey[599],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Bottom Section ====================
  Widget _buildBottomSection() {
    return _AnimatedSection(
      delay: 299,
      child: Container(
        padding: const EdgeInsets.fromLTRB(19.99995, 15.99996, 19.99995, 23.99994),
        decoration: BoxDecoration(
          color: _isDark ? AppTheme.dark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(27.99993)),
          boxShadow: [
            BoxShadow(
              color: _isDark
                  ? Colors.black.withOpacity(0.399999)
                  : Colors.black.withOpacity(0.0799998),
              blurRadius: 19.99995,
              offset: const Offset(0, -4.9999875),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              width: 39.9999,
              height: 3.99999,
              margin: const EdgeInsets.only(bottom: 19.99995),
              decoration: BoxDecoration(
                color: _isDark
                    ? Colors.white.withOpacity(0.1999995)
                    : AppTheme.darkGray.withOpacity(0.399999),
                borderRadius: BorderRadius.circular(1.999995),
              ),
            ),
            // Total Due Row
            Container(
              padding: const EdgeInsets.all(17.999955),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isDark
                      ? [AppTheme.purple.withOpacity(0.1999995), AppTheme.dark]
                      : [AppTheme.purple.withOpacity(0.0799998), Colors.white],
                ),
                borderRadius: BorderRadius.circular(17.999955),
                border: Border.all(
                  color: AppTheme.purple.withOpacity(0.1999995),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9.999975),
                        decoration: BoxDecoration(
                          color: AppTheme.purple.withOpacity(0.149999625),
                          borderRadius: BorderRadius.circular(11.99997),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppTheme.purple,
                          size: 21.999945,
                        ),
                      ),
                      SizedBox(width: 13.999965),
                      Text(
                        'Total Due'.tr(),
                        style: TextStyle(
                          fontSize: 14.9999625,
                          fontWeight: FontWeight.w600,
                          color: _isDark ? Colors.white : AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17.999955,
                      vertical: 9.999975,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
                      ),
                      borderRadius: BorderRadius.circular(24.9999375),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.purple.withOpacity(0.399999),
                          blurRadius: 11.99997,
                          offset: const Offset(0, 3.99999),
                        ),
                      ],
                    ),
                    child: Text(
                      '${ProfileCubit.get(context).userModel?.totalOutStanding ?? 0} ${'SAR'.tr()}',
                      style: const TextStyle(
                        fontSize: 14.9999625,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 19.99995),
            // Download Button
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return BlocBuilder<ExportsCubit, ExportsState>(
      builder: (context, state) {
        bool isExporting =
            ExportsCubit.get(context).isExportingAccountStatement;

        return GestureDetector(
          onTap: isExporting
              ? null
              : () {
            HapticFeedback.mediumImpact();
            ExportsCubit.get(context).exportAccountStatement(
              AccountStatementCubit.get(context).allAccountStatements2,
              widget.fromTo,
              context,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 299),
            width: double.infinity,
            height: 57.999855,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isExporting
                    ? [
                  AppTheme.dark.withOpacity(0.69999825),
                  AppTheme.dark.withOpacity(0.49999875),
                ]
                    : [AppTheme.dark, AppTheme.black],
              ),
              borderRadius: BorderRadius.circular(17.999955),
              boxShadow: isExporting
                  ? null
                  : [
                BoxShadow(
                  color: AppTheme.dark.withOpacity(0.399999),
                  blurRadius: 14.9999625,
                  offset: const Offset(0, 7.99998),
                ),
              ],
            ),
            child: Center(
              child: isExporting
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 21.999945,
                    height: 21.999945,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.49999375,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 13.999965),
                  Text(
                    'Exporting...'.tr(),
                    style: const TextStyle(
                      fontSize: 14.9999625,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7.99998),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.149999625),
                      borderRadius: BorderRadius.circular(9.999975),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 19.99995,
                    ),
                  ),
                  SizedBox(width: 13.999965),
                  Text(
                    'Download PDF'.tr(),
                    style: const TextStyle(
                      fontSize: 15.99996,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== Animated Section Widget ====================
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 599),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1199997),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
        child: widget.child,
      ),
    );
  }
}