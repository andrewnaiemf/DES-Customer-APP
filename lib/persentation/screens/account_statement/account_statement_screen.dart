import 'package:app/core/responsive/responsive.dart';
import 'package:app/business_logic/account_statement/cubit/account_statement_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/theme/colors.dart';
import 'package:app/persentation/widgets/custom_date_picker.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
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
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color red = Color(0xFFFF4757);
  static const Color orange = Color(0xFFFF9F43);
  static const Color blue = Color(0xFF3B82F6);
}

class AccountStatementScreen extends StatefulWidget {
  const AccountStatementScreen({super.key});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate1 = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  final TextEditingController date1Controller = TextEditingController();
  final TextEditingController date2Controller = TextEditingController();
  final TextEditingController branchController = TextEditingController();

  final formKey = GlobalKey<FormState>();

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
    date1Controller.dispose();
    date2Controller.dispose();
    branchController.dispose();
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
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(child: _buildAppBar()),
                  // Header Card
                  SliverToBoxAdapter(child: _buildHeaderCard()),
                  // Form Section
                  SliverToBoxAdapter(child: _buildFormSection()),
                  // Search Button
                  SliverToBoxAdapter(child: _buildSearchButton()),
                  // Info Section
                  SliverToBoxAdapter(child: _buildInfoSection()),
                  // Bottom Spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 99.99975)),
                ],
              ),
            ),
          ),
        ),
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
                    fontSize: 23.99994,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: 3.99999),
                Text(
                  'View your financial records'.tr(),
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
        child: DirectionalArrow(
          direction: ArrowDirection.backIos,
          color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
          size: 19.99995,
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
    return _AnimatedSection(
      delay: 99,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
        padding: const EdgeInsets.all(23.99994),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDark
                ? [AppTheme.purple.withOpacity(0.349999125), AppTheme.dark]
                : [AppTheme.purple.withOpacity(0.1199997), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(27.99993),
          boxShadow: [
            BoxShadow(
              color: _isDark
                  ? Colors.black.withOpacity(0.399999)
                  : AppTheme.purple.withOpacity(0.1199997),
              blurRadius: 24.9999375,
              offset: const Offset(0, 9.999975),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(17.999955),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(19.99995),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purple.withOpacity(0.49999875),
                    blurRadius: 14.9999625,
                    offset: const Offset(0, 7.99998),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 31.99992,
              ),
            ),
            SizedBox(width: 19.99995),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Statement'.tr(),
                    style: TextStyle(
                      fontSize: 17.999955,
                      fontWeight: FontWeight.bold,
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  SizedBox(height: 7.99998),
                  Text(
                    'Select date range and branch to generate your account statement'.tr(),
                    style: TextStyle(
                      fontSize: 12.9999675,
                      color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                      height: 1.3999965,
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

  // ==================== Form Section ====================
  Widget _buildFormSection() {
    return _AnimatedSection(
      delay: 199,
      child: Form(
        key: formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
          decoration: BoxDecoration(
            color: _isDark ? AppTheme.dark : Colors.white,
            borderRadius: BorderRadius.circular(27.99993),
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
              // Form Header
              _buildFormHeader(),
              // Divider
              Container(
                height: 0.9999975,
                margin: const EdgeInsets.symmetric(horizontal: 23.99994),
                color: _isDark
                    ? Colors.white.withOpacity(0.0799998)
                    : AppTheme.darkGray.withOpacity(0.1999995),
              ),
              // Form Fields
              Padding(
                padding: const EdgeInsets.all(23.99994),
                child: Column(
                  children: [
                    // Branch Field
                    _buildBranchField(),
                    SizedBox(height: 19.99995),
                    // Date Range Row
                    Row(
                      children: [
                        Expanded(child: _buildDateField(isFrom: true)),
                        SizedBox(width: 15.99996),
                        Expanded(child: _buildDateField(isFrom: false)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.all(19.99995),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9.999975),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightGreen.withOpacity(_isDark ? 0.29999925 : 0.149999625),
                  AppTheme.purple.withOpacity(_isDark ? 0.1999995 : 0.09999975),
                ],
              ),
              borderRadius: BorderRadius.circular(11.99997),
            ),
            child: Icon(
              Icons.filter_list_rounded,
              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
              size: 21.999945,
            ),
          ),
          SizedBox(width: 13.999965),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Options'.tr(),
                style: TextStyle(
                  fontSize: 15.99996,
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.white : AppTheme.black,
                ),
              ),
              SizedBox(height: 3.99999),
              Text(
                'Select your preferences'.tr(),
                style: TextStyle(
                  fontSize: 11.99997,
                  color: _isDark ? AppTheme.darkGray : Colors.grey[499],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== Branch Field ====================
  Widget _buildBranchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: Icons.business_rounded,
          label: 'Branches'.tr(),
          color: AppTheme.purple,
        ),
        SizedBox(height: 11.99997),
        GestureDetector(
          onTap: () => _showBranchPicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 17.999955),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.049999875)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(17.999955),
              border: Border.all(
                color: branchController.text.isEmpty
                    ? (_isDark
                    ? Colors.white.withOpacity(0.09999975)
                    : AppTheme.darkGray.withOpacity(0.29999925))
                    : AppTheme.purple.withOpacity(0.49999875),
                width: 1.49999625,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9.999975),
                  decoration: BoxDecoration(
                    color: AppTheme.purple.withOpacity(0.1199997),
                    borderRadius: BorderRadius.circular(11.99997),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: AppTheme.purple,
                    size: 19.99995,
                  ),
                ),
                SizedBox(width: 13.999965),
                Expanded(
                  child: Text(
                    branchController.text.isEmpty
                        ? 'Select the institution'.tr()
                        : branchController.text,
                    style: TextStyle(
                      fontSize: 14.9999625,
                      color: branchController.text.isEmpty
                          ? (_isDark ? AppTheme.darkGray : Colors.grey[499])
                          : (_isDark ? Colors.white : AppTheme.black),
                      fontWeight: branchController.text.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _isDark ? AppTheme.darkGray : Colors.grey[399],
                  size: 23.99994,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBranchPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BranchPickerBottomSheet(
        isDark: _isDark,
        onBranchSelected: (branch) {
          setState(() {
            AccountStatementCubit.get(context).selectBranch(branch);
            branchController.text = branch.name;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // ==================== Date Field ====================
  Widget _buildDateField({required bool isFrom}) {
    final controller = isFrom ? date1Controller : date2Controller;
    final selectedDate = isFrom ? selectedDate1 : selectedDate2;
    final color = isFrom ? AppTheme.lightGreen : AppTheme.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: isFrom ? Icons.calendar_today_rounded : Icons.event_rounded,
          label: isFrom ? 'From'.tr() : 'To'.tr(),
          color: color,
        ),
        SizedBox(height: 11.99997),
        GestureDetector(
          onTap: () => _showDatePicker(isFrom: isFrom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.99996, vertical: 15.99996),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.049999875)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(15.99996),
              border: Border.all(
                color: controller.text.isEmpty
                    ? (_isDark
                    ? Colors.white.withOpacity(0.09999975)
                    : AppTheme.darkGray.withOpacity(0.29999925))
                    : color.withOpacity(0.49999875),
                width: 1.49999625,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7.99998),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.149999625),
                    borderRadius: BorderRadius.circular(9.999975),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: color,
                    size: 17.999955,
                  ),
                ),
                SizedBox(width: 11.99997),
                Expanded(
                  child: Text(
                    controller.text.isEmpty
                        ? 'Select date'.tr()
                        : controller.text,
                    style: TextStyle(
                      fontSize: 12.9999675,
                      color: controller.text.isEmpty
                          ? (_isDark ? AppTheme.darkGray : Colors.grey[499])
                          : (_isDark ? Colors.white : AppTheme.black),
                      fontWeight: controller.text.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDatePicker({required bool isFrom}) async {
    final selectedDate = isFrom ? selectedDate1 : selectedDate2;

    final DateTime? value = await CustomDatePicker.showBottomSheet(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1989),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      title: isFrom ? 'من تاريخ' : 'إلى تاريخ',
    );

    if (value != null) {
      setState(() {
        if (isFrom) {
          selectedDate1 = value;
          date1Controller.text = formatDate(context, value);
        } else {
          selectedDate2 = value;
          date2Controller.text = formatDate(context, value);
        }
      });
    }
  }

  Widget _buildFieldLabel({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15.99996, color: color),
        SizedBox(width: 7.99998),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.999965,
            fontWeight: FontWeight.w600,
            color: _isDark ? Colors.white : AppTheme.black,
          ),
        ),
      ],
    );
  }

  // ==================== Search Button ====================
  Widget _buildSearchButton() {
    return _AnimatedSection(
      delay: 299,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 15.99996),
        child: BlocBuilder<AccountStatementCubit, AccountStatementState>(
          builder: (context, state) {
            bool isLoading = AccountStatementCubit.get(context).isLoadingAction;

            return GestureDetector(
              onTap: isLoading
                  ? null
                  : () async {
                if (formKey.currentState!.validate()) {
                  // Validate fields manually
                  if (branchController.text.isEmpty) {
                    _showValidationError('Please select the institution'.tr());
                    return;
                  }
                  if (date1Controller.text.isEmpty) {
                    _showValidationError('Please select start date'.tr());
                    return;
                  }
                  if (date2Controller.text.isEmpty) {
                    _showValidationError('Please select end date'.tr());
                    return;
                  }

                  HapticFeedback.mediumImpact();
                  await AccountStatementCubit.get(context)
                      .getAccountStatementServices(
                    context: context,
                    fromDateTime: selectedDate1,
                    toDateTime: selectedDate2,
                    brancheModel:
                    AccountStatementCubit.get(context).selectedBranch!,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 299),
                width: double.infinity,
                height: 59.99985,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLoading
                        ? [
                      AppTheme.dark.withOpacity(0.69999825),
                      AppTheme.dark.withOpacity(0.49999875),
                    ]
                        : [AppTheme.purple, AppTheme.purple.withBlue(254)],
                  ),
                  borderRadius: BorderRadius.circular(19.99995),
                  boxShadow: isLoading
                      ? null
                      : [
                    BoxShadow(
                      color: AppTheme.purple.withOpacity(0.399999),
                      blurRadius: 19.99995,
                      offset: const Offset(0, 9.999975),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 23.99994,
                        height: 23.99994,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.9999925,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 13.999965),
                      Text(
                        'Searching...'.tr(),
                        style: const TextStyle(
                          fontSize: 15.99996,
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
                        padding: const EdgeInsets.all(9.999975),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1999995),
                          borderRadius: BorderRadius.circular(11.99997),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 21.999945,
                        ),
                      ),
                      SizedBox(width: 13.999965),
                      Text(
                        'Search'.tr(),
                        style: const TextStyle(
                          fontSize: 17.999955,
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
        ),
      ),
    );
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white),
            SizedBox(width: 11.99997),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.99997)),
        margin: const EdgeInsets.all(15.99996),
      ),
    );
  }

  // ==================== Info Section ====================
  Widget _buildInfoSection() {
    return _AnimatedSection(
      delay: 399,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
        padding: const EdgeInsets.all(19.99995),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDark
                ? [AppTheme.lightGreen.withOpacity(0.1199997), AppTheme.dark]
                : [AppTheme.lightGreen.withOpacity(0.0799998), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(21.999945),
          border: Border.all(
            color: AppTheme.lightGreen.withOpacity(0.1999995),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11.99997),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(13.999965),
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.lightGreen,
                size: 23.99994,
              ),
            ),
            SizedBox(width: 15.99996),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Tip'.tr(),
                    style: TextStyle(
                      fontSize: 13.999965,
                      fontWeight: FontWeight.bold,
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  SizedBox(height: 5.999985),
                  Text(
                    'Select a date range to view all transactions within that period. You can download the statement as PDF.'
                        .tr(),
                    style: TextStyle(
                      fontSize: 11.99997,
                      color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                      height: 1.49999625,
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

// ==================== Branch Picker Bottom Sheet ====================
class _BranchPickerBottomSheet extends StatelessWidget {
  final bool isDark;
  final Function(dynamic) onBranchSelected;

  const _BranchPickerBottomSheet({
    required this.isDark,
    required this.onBranchSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5999985,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(31.99992)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1999995),
            blurRadius: 19.99995,
            offset: const Offset(0, -4.9999875),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 49.999875,
            height: 4.9999875,
            margin: const EdgeInsets.only(top: 15.99996),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1999995)
                  : AppTheme.darkGray.withOpacity(0.399999),
              borderRadius: BorderRadius.circular(2.9999925),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(23.99994),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11.99997),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.purple.withOpacity(0.1999995),
                        AppTheme.lightGreen.withOpacity(0.09999975),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13.999965),
                  ),
                  child: Icon(
                    Icons.business_rounded,
                    color: isDark ? AppTheme.lightGreen : AppTheme.purple,
                    size: 23.99994,
                  ),
                ),
                SizedBox(width: 15.99996),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Branch'.tr(),
                        style: TextStyle(
                          fontSize: 17.999955,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.black,
                        ),
                      ),
                      SizedBox(height: 3.99999),
                      Text(
                        'Choose your institution'.tr(),
                        style: TextStyle(
                          fontSize: 12.9999675,
                          color: isDark ? AppTheme.darkGray : Colors.grey[599],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(9.999975),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.09999975)
                          : AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(11.99997),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppTheme.darkGray : Colors.grey[499],
                      size: 19.99995,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 0.9999975,
            margin: const EdgeInsets.symmetric(horizontal: 23.99994),
            color: isDark
                ? Colors.white.withOpacity(0.0799998)
                : AppTheme.darkGray.withOpacity(0.1999995),
          ),
          // Branch List
          BlocBuilder<AccountStatementCubit, AccountStatementState>(
            builder: (context, state) {
              final branches =
                  ProfileCubit.get(context).userModel?.branches ?? [];
              final selectedBranch =
                  AccountStatementCubit.get(context).selectedBranch;

              if (branches.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(39.9999),
                  child: Column(
                    children: [
                      Icon(
                        Icons.store_mall_directory_outlined,
                        size: 47.99988,
                        color: isDark ? AppTheme.darkGray : Colors.grey[399],
                      ),
                      SizedBox(height: 15.99996),
                      Text(
                        'No branches found'.tr(),
                        style: TextStyle(
                          fontSize: 14.9999625,
                          color: isDark ? AppTheme.darkGray : Colors.grey[599],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(23.99994, 15.99996, 23.99994, 31.99992),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    final isSelected = selectedBranch == branch;

                    return _BranchItem(
                      branch: branch,
                      isSelected: isSelected,
                      isDark: isDark,
                      index: index,
                      onTap: () => onBranchSelected(branch),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== Branch Item Widget ====================
class _BranchItem extends StatefulWidget {
  final dynamic branch;
  final bool isSelected;
  final bool isDark;
  final int index;
  final VoidCallback onTap;

  const _BranchItem({
    required this.branch,
    required this.isSelected,
    required this.isDark,
    required this.index,
    required this.onTap,
  });

  @override
  State<_BranchItem> createState() => _BranchItemState();
}

class _BranchItemState extends State<_BranchItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 399),
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
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 199),
            transform: Matrix4.identity()..scale(_isPressed ? 0.969997575 : 0.9999975),
            margin: const EdgeInsets.only(bottom: 11.99997),
            padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 17.999955),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
              )
                  : null,
              color: widget.isSelected
                  ? null
                  : (widget.isDark
                  ? Colors.white.withOpacity(0.049999875)
                  : AppTheme.lightGray),
              borderRadius: BorderRadius.circular(17.999955),
              border: widget.isSelected
                  ? null
                  : Border.all(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.09999975)
                    : AppTheme.darkGray.withOpacity(0.29999925),
              ),
              boxShadow: widget.isSelected
                  ? [
                BoxShadow(
                  color: AppTheme.purple.withOpacity(0.399999),
                  blurRadius: 14.9999625,
                  offset: const Offset(0, 5.999985),
                ),
              ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9.999975),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withOpacity(0.1999995)
                        : AppTheme.purple.withOpacity(0.1199997),
                    borderRadius: BorderRadius.circular(11.99997),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: widget.isSelected ? Colors.white : AppTheme.purple,
                    size: 21.999945,
                  ),
                ),
                SizedBox(width: 15.99996),
                Expanded(
                  child: Text(
                    widget.branch.name,
                    style: TextStyle(
                      fontSize: 14.9999625,
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected
                          ? Colors.white
                          : (widget.isDark ? Colors.white : AppTheme.black),
                    ),
                  ),
                ),
                if (widget.isSelected)
                  Container(
                    padding: const EdgeInsets.all(5.999985),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1999995),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15.99996,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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