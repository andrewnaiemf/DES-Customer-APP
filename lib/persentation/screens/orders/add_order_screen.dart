import 'package:app/core/responsive/responsive.dart';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app/business_logic/CheckLoyalty/cubit/check_loyalty_cubit.dart';
import 'package:app/business_logic/orders/cubit/orders_cubit.dart';
import 'package:app/business_logic/products/cubit/products_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/product/product_model.dart';
import 'package:app/models/selected_products/selected_products.dart';
import 'package:app/persentation/screens/orders/order_done_screen.dart';
import 'package:app/persentation/screens/orders/products_screen.dart';
import 'package:app/persentation/widgets/Loading_widget.dart';
import 'package:app/persentation/widgets/buttons.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/persentation/widgets/force_makeAlert.dart';
import 'package:app/persentation/widgets/image_loading.dart';
import 'package:app/persentation/widgets/my_scaffold.dart';
import 'package:app/persentation/widgets/textFormField.dart';
import 'package:app/persentation/widgets/custom_date_picker.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📐 Layout Helper - للخصائص الإضافية
// ═══════════════════════════════════════════════════════════════════════════
class LayoutHelper {
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 414) return 16.0;
    if (width < 600) return 20.0;
    if (width < 900) return 32.0;
    return 48.0;
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return width;
    if (width < 900) return 600.0;
    return 700.0;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    return 2;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme - Premium Design System
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  // Primary Colors
  static const Color primary = Color(0xFF6842E2);
  static const Color primaryLight = Color(0xFF8B6CEF);
  static const Color primaryDark = Color(0xFF5234B5);

  // Accent Colors
  static const Color accent = Color(0xFF28E6C5);
  static const Color accentLight = Color(0xFF5EEFD8);
  static const Color yellow = Color(0xFFD7B21B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color black = Color(0xFF1D1D25);
  static const Color dark = Color(0xFF081428);
  static const Color darkCard = Color(0xFF0F1C2E);
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color background = Color(0xFF15172A);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color white = Colors.white;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF34D399)],
  );

  static LinearGradient darkBackgroundGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1040), Color(0xFF0D0D1A), Color(0xFF0A0A12)],
  );

  // Shadows
  static List<BoxShadow> primaryShadow(double opacity) => [
    BoxShadow(
      color: primary.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> cardShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.3) : primary.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> accentShadow(double opacity) => [
    BoxShadow(
      color: accent.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Add Order Screen - Full Responsive Premium UI
// ═══════════════════════════════════════════════════════════════════════════
class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen>
    with TickerProviderStateMixin {
  // Controllers
  DateTime selectedDate = DateTime.now();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  bool _isChecked = false;

  // Animation Controllers
  late AnimationController _pageController;
  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerScaleAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pageController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _headerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _formController.forward();
    });
  }

  void _loadData() {
    context.read<CheckLoyaltyCubit>().getCheckLoyaltyCubit();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerController.dispose();
    _formController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    dateController.dispose();
    branchController.dispose();
    addressController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isTablet => LayoutHelper.isTablet(context);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Add Order'.tr(),
      showBackButton: true,
      body: Stack(
        children: [
          // Background Effects
          if (_isDark) _buildBackgroundEffects(),

          // Main Content with Center Constraint for Tablets
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: LayoutHelper.getMaxContentWidth(context),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutHelper.getHorizontalPadding(context),
                  ),
                  child: BlocBuilder<OrdersCubit, OrdersState>(
                    builder: (context, state) {
                      return BlocBuilder<ProductsCubit, ProductsState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              SizedBox(height: ResponsiveUtils.spacing(context, 10)),

                              // Header Section
                              _buildHeader(),

                              SizedBox(height: ResponsiveUtils.spacing(context, 28)),

                              // Form Section
                              SlideTransition(
                                position: _formSlideAnimation,
                                child: _buildForm(),
                              ),

                              SizedBox(height: ResponsiveUtils.spacing(context, 20)),

                              // Add Product Button
                              _buildAddProductButton(),

                              SizedBox(height: ResponsiveUtils.spacing(context, 16)),

                              // Products List
                              _buildProductsList(),

                              // Loyalty Switch & Footer
                              if (SelectedProductsModel.selectedProducts.isNotEmpty) ...[
                                SizedBox(height: ResponsiveUtils.spacing(context, 20)),
                                _buildLoyaltySwitch(),
                                SizedBox(height: ResponsiveUtils.spacing(context, 24)),
                                _buildFooter(),
                              ],

                              SizedBox(height: ResponsiveUtils.spacing(context, 40)),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Background Effects
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundEffects() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -ResponsiveUtils.size(context, 100),
              right: -ResponsiveUtils.size(context, 80),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: ResponsiveUtils.size(context, 250),
                      height: ResponsiveUtils.size(context, 250),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primary.withOpacity(0.15),
                            AppTheme.primary.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: ResponsiveUtils.size(context, 200),
              left: -ResponsiveUtils.size(context, 60),
              child: Container(
                width: ResponsiveUtils.size(context, 180),
                height: ResponsiveUtils.size(context, 180),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accent.withOpacity(0.1),
                      AppTheme.accent.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Header Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return ScaleTransition(
      scale: _headerScaleAnimation,
      child: Column(
        children: [
          // Animated Icon Container
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 6)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isDark
                        ? [AppTheme.primary.withOpacity(0.25), AppTheme.accent.withOpacity(0.1)]
                        : [AppTheme.primary.withOpacity(0.1), AppTheme.accent.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 30 * _pulseAnimation.value,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_shopping_cart_rounded,
                  size: ResponsiveUtils.icon(context, 32),
                  color: _isDark ? AppTheme.accent : AppTheme.primary,
                ),
              );
            },
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 12)),

          // Title
          Text(
            'New Purchase Order'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 20),
              fontWeight: FontWeight.bold,
              color: _isDark ? AppTheme.white : AppTheme.black,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 6)),

          // Subtitle Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 14),
              vertical: ResponsiveUtils.spacing(context, 6),
            ),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.primary.withOpacity(0.12)
                  : AppTheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
              border: Border.all(
                color: _isDark
                    ? AppTheme.primary.withOpacity(0.2)
                    : AppTheme.primary.withOpacity(0.1),
              ),
            ),
            child: Text(
              'Fill in the details below'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 12),
                color: _isDark ? AppTheme.darkGray : AppTheme.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Form Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 18)),
        decoration: BoxDecoration(
          color: _isDark ? AppTheme.darkCard : AppTheme.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
          border: Border.all(
            color: _isDark
                ? AppTheme.primary.withOpacity(0.12)
                : AppTheme.gray200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isDark
                  ? Colors.black.withOpacity(0.3)
                  : AppTheme.primary.withOpacity(0.08),
              blurRadius: ResponsiveUtils.size(context, 20),
              offset: Offset(0, ResponsiveUtils.size(context, 8)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Field
            _buildFormField(
              icon: Icons.calendar_today_rounded,
              label: 'Date'.tr(),
              child: _buildDateField(),
              delay: 0,
            ),

            SizedBox(height: ResponsiveUtils.spacing(context, 16)),

            // Branch Field
            _buildFormField(
              icon: Icons.business_rounded,
              label: 'Branches'.tr(),
              child: _buildBranchField(),
              delay: 1,
            ),

            SizedBox(height: ResponsiveUtils.spacing(context, 16)),

            // Location Field
            _buildFormField(
              icon: Icons.location_on_rounded,
              label: 'Location'.tr(),
              child: _buildLocationField(),
              delay: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required Widget child,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (delay * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withOpacity(_isDark ? 0.2 : 0.1),
                            AppTheme.accent.withOpacity(_isDark ? 0.1 : 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 10)),
                      ),
                      child: Icon(
                        icon,
                        size: ResponsiveUtils.icon(context, 18),
                        color: _isDark ? AppTheme.accent : AppTheme.primary,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 10)),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.w600,
                        color: _isDark ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 10)),
                child,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField() {
    return _PremiumInputField(
      context: context,
      onTap: () => _showDatePicker(context),
      isDark: _isDark,
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateController.text.isEmpty
                  ? 'Select the invoice date'.tr()
                  : dateController.text,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 13),
                color: dateController.text.isEmpty
                    ? (_isDark ? AppTheme.gray400 : AppTheme.gray500)
                    : (_isDark ? AppTheme.white : AppTheme.black),
              ),
            ),
          ),
          _buildFieldIcon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }

  Widget _buildBranchField() {
    return _PremiumInputField(
      context: context,
      onTap: () => _showBranchPicker(context),
      isDark: _isDark,
      child: Row(
        children: [
          Expanded(
            child: Text(
              branchController.text.isEmpty
                  ? 'Select the institution'.tr()
                  : branchController.text,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 13),
                color: branchController.text.isEmpty
                    ? (_isDark ? AppTheme.gray400 : AppTheme.gray500)
                    : (_isDark ? AppTheme.white : AppTheme.black),
              ),
            ),
          ),
          _buildFieldIcon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.white.withOpacity(0.05) : AppTheme.gray100,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
        border: Border.all(
          color: _isDark
              ? AppTheme.white.withOpacity(0.1)
              : AppTheme.gray300,
        ),
      ),
      child: TextFormField(
        controller: addressController,
        style: TextStyle(
          color: _isDark ? AppTheme.white : AppTheme.black,
          fontSize: ResponsiveUtils.font(context, 14),
        ),
        decoration: InputDecoration(
          hintText: 'Choose the city of receipt'.tr(),
          hintStyle: TextStyle(
            color: _isDark ? AppTheme.gray400 : AppTheme.gray500,
            fontSize: ResponsiveUtils.font(context, 13),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, 14),
            vertical: ResponsiveUtils.spacing(context, 14),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: ResponsiveUtils.spacing(context, 8)),
            child: Icon(
              Icons.edit_location_alt_outlined,
              color: _isDark ? AppTheme.gray400 : AppTheme.gray500,
              size: ResponsiveUtils.icon(context, 20),
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: ResponsiveUtils.size(context, 36),
          ),
        ),
        validator: (val) {
          if (val!.isEmpty) {
            return 'Choose the city of receipt'.tr();
          }
          return null;
        },
      ),
    );
  }

  Widget _buildFieldIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 5)),
      decoration: BoxDecoration(
        color: _isDark
            ? AppTheme.white.withOpacity(0.08)
            : AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 8)),
      ),
      child: Icon(
        icon,
        color: _isDark ? AppTheme.gray400 : AppTheme.primary,
        size: ResponsiveUtils.icon(context, 18),
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    HapticFeedback.selectionClick();

    final DateTime? value = await CustomDatePicker.showBottomSheet(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      title: 'تاريخ التسليم',
    );

    if (value != null) {
      setState(() {
        selectedDate = value;
        dateController.text = formatDate(context, value);
      });
    }
  }

  void _showBranchPicker(BuildContext context) {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BranchPickerSheet(
        isDark: _isDark,
        selectedBranch: OrdersCubit.get(context).selectedBranch,
        branches: ProfileCubit.get(context).userModel?.branches ?? [],
        onSelect: (branch) {
          setState(() {
            OrdersCubit.get(context).selectBranch(branch);
            branchController.text = branch.name;
          });
          MyNavigator.back(context);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ➕ Add Product Button
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildAddProductButton() {
    return _PremiumButton(
      context: context,
      onTap: () {
        HapticFeedback.lightImpact();
        MyNavigator.navigateTo(context, const ProductsScreen());
      },
      gradient: AppTheme.primaryGradient,
      shadowColor: AppTheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppTheme.white,
                  size: ResponsiveUtils.icon(context, 20),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 12)),
              Text(
                'Add Product'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 15),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_rounded,
              color: AppTheme.white,
              size: ResponsiveUtils.icon(context, 20),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📦 Products List
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildProductsList() {
    final products = SelectedProductsModel.selectedProducts;

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use Grid for Tablets
    if (_isTablet && products.length > 1) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: LayoutHelper.getGridColumns(context),
          crossAxisSpacing: ResponsiveUtils.spacing(context, 16),
          mainAxisSpacing: ResponsiveUtils.spacing(context, 16),
          childAspectRatio: 1.8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildAnimatedProductCard(products[index], index);
        },
      );
    }

    // List for Phones
    return Column(
      children: List.generate(products.length, (index) {
        return _buildAnimatedProductCard(products[index], index);
      }),
    );
  }

  Widget _buildAnimatedProductCard(SelectedProductsModel product, int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(product.productModel.id),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _ProductCard(
              product: product,
              isDark: _isDark,
              onAdd: () {
                HapticFeedback.selectionClick();
                ProductsCubit.get(context).addQtyProduct(context, product.productModel);
              },
              onRemove: () {
                HapticFeedback.selectionClick();
                ProductsCubit.get(context).qtyMinusProduct(context, product.productModel);
              },
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⭐ Loyalty Switch
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildLoyaltySwitch() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.darkCard : AppTheme.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
        border: Border.all(
          color: _isChecked
              ? (_isDark ? AppTheme.accent : AppTheme.primary)
              : (_isDark ? AppTheme.white.withOpacity(0.1) : AppTheme.gray200),
          width: _isChecked ? 2 : 1.5,
        ),
        boxShadow: _isChecked
            ? [
          BoxShadow(
            color: (_isDark ? AppTheme.accent : AppTheme.primary).withOpacity(0.2),
            blurRadius: ResponsiveUtils.size(context, 16),
            offset: Offset(0, ResponsiveUtils.size(context, 6)),
          ),
        ]
            : AppTheme.cardShadow(_isDark),
      ),
      child: Row(
        children: [
          // Icon Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
            decoration: BoxDecoration(
              gradient: _isChecked
                  ? (_isDark ? AppTheme.accentGradient : AppTheme.primaryGradient)
                  : null,
              color: _isChecked
                  ? null
                  : (_isDark ? AppTheme.white.withOpacity(0.05) : AppTheme.gray100),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
            ),
            child: Icon(
              Icons.stars_rounded,
              color: _isChecked
                  ? (_isDark ? AppTheme.dark : AppTheme.white)
                  : (_isDark ? AppTheme.gray400 : AppTheme.gray500),
              size: ResponsiveUtils.icon(context, 22),
            ),
          ),

          SizedBox(width: ResponsiveUtils.spacing(context, 12)),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use Rewards'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 15),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 2)),
                Text(
                  'Get discount with your points'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 12),
                    color: _isDark ? AppTheme.gray400 : AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ),

          // Custom Switch
          _PremiumSwitch(
            context: context,
            value: _isChecked,
            isDark: _isDark,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _isChecked = value);
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Footer Section - Full Light & Dark Support
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildFooter() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _isDark ? null : AppTheme.white,
        gradient: _isDark
            ? LinearGradient(
          colors: [
            const Color(0xFF1E2433),
            const Color(0xFF151A24),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 24)),
        border: Border.all(
          color: _isDark
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.gray200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withOpacity(0.5)
                : AppTheme.primary.withOpacity(0.12),
            blurRadius: ResponsiveUtils.size(context, 24),
            offset: Offset(0, ResponsiveUtils.size(context, 8)),
            spreadRadius: _isDark ? 0 : 3,
          ),
          if (!_isDark)
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.08),
              blurRadius: ResponsiveUtils.size(context, 40),
              offset: Offset(0, ResponsiveUtils.size(context, 12)),
              spreadRadius: 5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: _isDark ? 15 : 5,
            sigmaY: _isDark ? 15 : 5,
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 20)),
            child: BlocBuilder<CheckLoyaltyCubit, CheckLoyaltyState>(
              builder: (context, state) {
                if (state is CheckLoyaltyLoaded) {
                  return Column(
                    children: [
                      // Header
                      _buildFooterHeader(),

                      SizedBox(height: ResponsiveUtils.spacing(context, 16)),

                      // Summary Items
                      _buildSummaryItem(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Total'.tr(),
                        value: '${ProductsCubit.get(context).totalPrice}',
                        currencyWidget: context.getCurrencyWidget(
                          height: ResponsiveUtils.font(context, 25),
                          color: _isDark ? AppTheme.white : AppTheme.black,
                        ),
                      ),

                      if (_isChecked) ...[
                        SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                        _buildSummaryItem(
                          icon: Icons.stars_rounded,
                          label: 'Loyalty Points'.tr(),
                          value: _getLoyaltyDiscountValue(state),
                          currencyWidget: context.getCurrencyWidget(
                            height: ResponsiveUtils.font(context, 25),
                            color: _isDark ? AppTheme.accent : AppTheme.success,
                          ),
                          type: SummaryItemType.discount,
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                        _buildSummaryItem(
                          icon: Icons.discount_outlined,
                          label: 'الإجمالي بعد الخصم'.tr(),
                          value: _getTotalAfterDiscountValue(state),
                          currencyWidget: context.getCurrencyWidget(
                            height: ResponsiveUtils.font(context, 25),
                            color: _isDark ? AppTheme.white : AppTheme.black,
                          ),
                        ),
                      ],

                      SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                      _buildSummaryItem(
                        icon: Icons.receipt_outlined,
                        label: 'Tax'.tr(),
                        value: _getTaxValue(state),
                        currencyWidget: context.getCurrencyWidget(
                          height: ResponsiveUtils.font(context, 25),
                          color: _isDark ? AppTheme.yellow : AppTheme.warning,
                        ),
                        type: SummaryItemType.tax,
                      ),

                      SizedBox(height: ResponsiveUtils.spacing(context, 16)),

                      // Divider
                      _buildPremiumDivider(),

                      SizedBox(height: ResponsiveUtils.spacing(context, 16)),

                      // Total & Confirm
                      _buildTotalSection(state),
                    ],
                  );
                }
                return _buildFooterLoading();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 14),
        vertical: ResponsiveUtils.spacing(context, 12),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.primary.withOpacity(0.2), AppTheme.accent.withOpacity(0.1)]
              : [AppTheme.primary.withOpacity(0.08), AppTheme.accent.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.white.withOpacity(0.1)
                  : AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 10)),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: ResponsiveUtils.icon(context, 18),
              color: _isDark ? AppTheme.accent : AppTheme.primary,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 2)),
                Text(
                  '${SelectedProductsModel.selectedProducts.length} ${'items'.tr()}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 12),
                    color: _isDark ? AppTheme.gray400 : AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 12),
              vertical: ResponsiveUtils.spacing(context, 6),
            ),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.accent.withOpacity(0.2)
                  : AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
            ),
            child: Text(
              '${SelectedProductsModel.selectedProducts.length}',
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 14),
                fontWeight: FontWeight.bold,
                color: _isDark ? AppTheme.accent : AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    Widget? currencyWidget,
    String? currency,
    SummaryItemType type = SummaryItemType.normal,
  }) {
    // Determine colors based on type and theme
    Color valueColor;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case SummaryItemType.discount:
        valueColor = _isDark ? AppTheme.accent : AppTheme.success;
        iconColor = _isDark ? AppTheme.accent : AppTheme.success;
        bgColor = _isDark
            ? AppTheme.accent.withOpacity(0.12)
            : AppTheme.success.withOpacity(0.08);
        break;
      case SummaryItemType.tax:
        valueColor = _isDark ? AppTheme.yellow : AppTheme.warning;
        iconColor = _isDark ? AppTheme.yellow : AppTheme.warning;
        bgColor = _isDark
            ? AppTheme.yellow.withOpacity(0.12)
            : AppTheme.warning.withOpacity(0.08);
        break;
      case SummaryItemType.normal:
      default:
        valueColor = _isDark ? AppTheme.white : AppTheme.black;
        iconColor = _isDark ? AppTheme.gray400 : AppTheme.gray600;
        bgColor = _isDark
            ? AppTheme.white.withOpacity(0.04)
            : AppTheme.gray100;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 12),
        vertical: ResponsiveUtils.spacing(context, 12),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
        border: type == SummaryItemType.discount
            ? Border.all(
          color: (_isDark ? AppTheme.accent : AppTheme.success).withOpacity(0.3),
          width: 1,
        )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
            decoration: BoxDecoration(
              color: _isDark
                  ? iconColor.withOpacity(0.15)
                  : iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 8)),
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.icon(context, 16),
              color: iconColor,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 10)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 13),
                fontWeight: FontWeight.w500,
                color: _isDark ? AppTheme.gray400 : AppTheme.gray600,
              ),
            ),
          ),
          Row(
            children: [
              if (type == SummaryItemType.discount)
                Container(
                  margin: EdgeInsets.only(right: ResponsiveUtils.spacing(context, 8)),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing(context, 6),
                    vertical: ResponsiveUtils.spacing(context, 3),
                  ),
                  decoration: BoxDecoration(
                    color: valueColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 6)),
                  ),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 12),
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 14),
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              if (currencyWidget != null) ...[
                SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                currencyWidget,
              ] else if (currency != null) ...[
                SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                Text(
                  currency,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _isDark
                      ? AppTheme.white.withOpacity(0.15)
                      : AppTheme.primary.withOpacity(0.2),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing(context, 18)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 14),
              vertical: ResponsiveUtils.spacing(context, 8),
            ),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.primary.withOpacity(0.15)
                  : AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 24)),
            ),
            child: Text(
              'TOTAL',
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 11),
                fontWeight: FontWeight.bold,
                color: _isDark ? AppTheme.accent : AppTheme.primary,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _isDark
                      ? AppTheme.white.withOpacity(0.15)
                      : AppTheme.primary.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection(CheckLoyaltyLoaded state) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.primary.withOpacity(0.2), AppTheme.accent.withOpacity(0.1)]
              : [AppTheme.primary.withOpacity(0.1), AppTheme.accent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
        border: Border.all(
          color: _isDark
              ? AppTheme.primary.withOpacity(0.25)
              : AppTheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: _isTablet
          ? Row(
        children: [
          Expanded(flex: 2, child: _buildTotalDisplay(state)),
          SizedBox(width: ResponsiveUtils.spacing(context, 16)),
          Expanded(flex: 1, child: _buildConfirmButtonSection(state)),
        ],
      )
          : Column(
        children: [
          _buildTotalDisplay(state),
          SizedBox(height: ResponsiveUtils.spacing(context, 14)),
          _buildConfirmButtonSection(state),
        ],
      ),
    );
  }

  Widget _buildTotalDisplay(CheckLoyaltyLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.payments_rounded,
              size: ResponsiveUtils.icon(context, 16),
              color: _isDark ? AppTheme.gray400 : AppTheme.gray600,
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 6)),
            Text(
              'Total Amount'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 12),
                fontWeight: FontWeight.w500,
                color: _isDark ? AppTheme.gray400 : AppTheme.gray600,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 8)),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: _isDark
                ? [AppTheme.accent, AppTheme.accentLight]
                : [AppTheme.primary, AppTheme.primaryLight],
          ).createShader(bounds),
          child: Text(
            _getFinalTotal(state),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 22),
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButtonSection(CheckLoyaltyLoaded state) {
    return OrdersCubit.get(context).isLoadingAction
        ? _buildConfirmLoading()
        : _buildConfirmButton(state);
  }

  Widget _buildFooterLoading() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: ResponsiveUtils.size(context, 45),
            height: ResponsiveUtils.size(context, 45),
            child: CircularProgressIndicator(
              color: _isDark ? AppTheme.accent : AppTheme.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 14)),
          Text(
            'Loading...'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 14),
              color: _isDark ? AppTheme.gray400 : AppTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmLoading() {
    return Container(
      width: _isTablet ? double.infinity : null,
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.accent, AppTheme.accentLight]
              : [AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
        boxShadow: [
          BoxShadow(
            color: (_isDark ? AppTheme.accent : AppTheme.primary).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: ResponsiveUtils.size(context, 26),
          height: ResponsiveUtils.size(context, 26),
          child: CircularProgressIndicator(
            color: _isDark ? AppTheme.dark : AppTheme.white,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(CheckLoyaltyLoaded state) {
    return _PremiumButton(
      context: context,
      onTap: () => _handleConfirm(state),
      gradient: LinearGradient(
        colors: _isDark
            ? [AppTheme.accent, AppTheme.accentLight]
            : [AppTheme.primary, AppTheme.primaryLight],
      ),
      shadowColor: _isDark ? AppTheme.accent : AppTheme.primary,
      fullWidth: _isTablet,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 20),
        vertical: ResponsiveUtils.spacing(context, 14),
      ),
      child: Row(
        mainAxisSize: _isTablet ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: _isDark ? AppTheme.dark : AppTheme.white,
            size: ResponsiveUtils.icon(context, 20),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 8)),
          Text(
            'Confirm'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 15),
              fontWeight: FontWeight.bold,
              color: _isDark ? AppTheme.dark : AppTheme.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 4)),
          Icon(
            Icons.arrow_forward_rounded,
            color: _isDark ? AppTheme.dark : AppTheme.white,
            size: ResponsiveUtils.icon(context, 18),
          ),
        ],
      ),
    );
  }

  void _handleConfirm(CheckLoyaltyLoaded state) async {
    HapticFeedback.mediumImpact();

    if (formKey.currentState!.validate()) {
      if (SelectedProductsModel.selectedProducts.isEmpty) {
        showMessage(
          context: context,
          message: 'Please Select A Product'.tr(),
          color: AppTheme.black,
        );
      } else {
        await OrdersCubit.get(context).addOrder(
          context: context,
          dateTime: selectedDate,
          brancheModel: OrdersCubit.get(context).selectedBranch!,
          address: addressController.text,
          useLoyalty: _isChecked,
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 💰 Helper Methods for Values
  // ═══════════════════════════════════════════════════════════════════════
  String _getLoyaltyDiscount(CheckLoyaltyLoaded state) {
    final totalDiscount = double.parse("${state.model.data?.totalDiscount}");
    final totalPrice = double.parse("${ProductsCubit.get(context).totalPrice}");

    if (totalDiscount >= totalPrice) {
      return "$totalPrice ${'SAR'.tr()}";
    }
    return '${state.model.data?.totalDiscount} ${'SAR'.tr()}';
  }

  String _getLoyaltyDiscountValue(CheckLoyaltyLoaded state) {
    final totalDiscount = double.parse("${state.model.data?.totalDiscount}");
    final totalPrice = double.parse("${ProductsCubit.get(context).totalPrice}");

    if (totalDiscount >= totalPrice) {
      return "$totalPrice";
    }
    return '${state.model.data?.totalDiscount}';
  }

  String _getTotalAfterDiscount(CheckLoyaltyLoaded state) {
    final totalDiscount = double.parse(state.model.data!.totalDiscount.toString());
    final totalPrice = double.parse(ProductsCubit.get(context).totalPrice.toString());

    if (totalDiscount > totalPrice) {
      return "0 ${'SAR'.tr()}";
    }
    return '${totalPrice - totalDiscount} ${'SAR'.tr()}';
  }

  String _getTotalAfterDiscountValue(CheckLoyaltyLoaded state) {
    final totalDiscount = double.parse(state.model.data!.totalDiscount.toString());
    final totalPrice = double.parse(ProductsCubit.get(context).totalPrice.toString());

    if (totalDiscount > totalPrice) {
      return "0";
    }
    return '${totalPrice - totalDiscount}';
  }

  String _getTax(CheckLoyaltyLoaded state) {
    final totalDiscount = double.parse(state.model.data!.totalDiscount.toString());
    final totalPrice = double.parse(ProductsCubit.get(context).totalPrice.toString());

    if (_isChecked && totalDiscount >= totalPrice) {
      return "0 ${'SAR'.tr()}";
    }
    if (_isChecked && totalDiscount < totalPrice) {
      return "${((totalPrice - totalDiscount) * 0.15).toStringAsFixed(2)} ${'SAR'.tr()}";
    }
    return '${(ProductsCubit.get(context).totalPrice * 0.15).toStringAsFixed(2)} ${'SAR'.tr()}';
  }

  String _getTaxValue(CheckLoyaltyLoaded state) {
    final totalDiscount = double.parse(state.model.data!.totalDiscount.toString());
    final totalPrice = double.parse(ProductsCubit.get(context).totalPrice.toString());

    if (_isChecked && totalDiscount >= totalPrice) {
      return "0";
    }
    if (_isChecked && totalDiscount < totalPrice) {
      return "${((totalPrice - totalDiscount) * 0.15).toStringAsFixed(2)}";
    }
    return '${(ProductsCubit.get(context).totalPrice * 0.15).toStringAsFixed(2)}';
  }

  String _getFinalTotal(CheckLoyaltyLoaded state) {
    final totalDiscount = double.parse(state.model.data!.totalDiscount.toString());
    final totalPrice = double.parse(ProductsCubit.get(context).totalPrice.toString());
    final tax = totalPrice * 0.15;

    // استخدام رمز الريال (﷼) في العربية
    final currencySymbol = context.locale.languageCode == 'ar' ? '﷼' : 'SAR';

    if (_isChecked && totalDiscount >= (totalPrice + tax)) {
      return "0 $currencySymbol";
    }
    if (_isChecked && totalDiscount < (totalPrice + tax)) {
      final afterDiscount = totalPrice - totalDiscount;
      final taxAfterDiscount = afterDiscount * 0.15;
      return "${(afterDiscount + taxAfterDiscount).toStringAsFixed(2)} $currencySymbol";
    }
    return '${(totalPrice + tax).toStringAsFixed(2)} $currencySymbol';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🧩 Reusable Widgets
// ═══════════════════════════════════════════════════════════════════════════

enum SummaryItemType { normal, discount, tax }

// Premium Input Field
class _PremiumInputField extends StatelessWidget {
  final BuildContext context;
  final VoidCallback onTap;
  final bool isDark;
  final Widget child;

  const _PremiumInputField({
    required this.context,
    required this.onTap,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 14),
          vertical: ResponsiveUtils.spacing(context, 13),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.white.withOpacity(0.05) : AppTheme.gray100,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
          border: Border.all(
            color: isDark
                ? AppTheme.white.withOpacity(0.1)
                : AppTheme.gray300,
          ),
        ),
        child: child,
      ),
    );
  }
}

// Premium Button
class _PremiumButton extends StatefulWidget {
  final BuildContext context;
  final VoidCallback onTap;
  final Gradient gradient;
  final Color shadowColor;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool fullWidth;

  const _PremiumButton({
    required this.context,
    required this.onTap,
    required this.gradient,
    required this.shadowColor,
    required this.child,
    this.padding,
    this.fullWidth = false,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              padding: widget.padding ??
                  EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing(context, 22),
                    vertical: ResponsiveUtils.spacing(context, 18),
                  ),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 22)),
                boxShadow: [
                  BoxShadow(
                    color: widget.shadowColor.withOpacity(0.4),
                    blurRadius: ResponsiveUtils.size(context, 20),
                    offset: Offset(0, ResponsiveUtils.size(context, 8)),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// Premium Switch
class _PremiumSwitch extends StatelessWidget {
  final BuildContext context;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _PremiumSwitch({
    required this.context,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: ResponsiveUtils.size(context, 60),
        height: ResponsiveUtils.size(context, 34),
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 4)),
        decoration: BoxDecoration(
          gradient: value
              ? (isDark ? AppTheme.accentGradient : AppTheme.primaryGradient)
              : null,
          color: value ? null : (isDark ? AppTheme.gray600 : AppTheme.gray300),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
          boxShadow: value
              ? [
            BoxShadow(
              color: (isDark ? AppTheme.accent : AppTheme.primary).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: ResponsiveUtils.size(context, 26),
            height: ResponsiveUtils.size(context, 26),
            decoration: BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: value
                ? Icon(
              Icons.check_rounded,
              size: ResponsiveUtils.icon(context, 16),
              color: isDark ? AppTheme.accent : AppTheme.primary,
            )
                : null,
          ),
        ),
      ),
    );
  }
}

// Branch Picker Sheet
class _BranchPickerSheet extends StatelessWidget {
  final bool isDark;
  final dynamic selectedBranch;
  final List<dynamic> branches;
  final Function(dynamic) onSelect;

  const _BranchPickerSheet({
    required this.isDark,
    required this.selectedBranch,
    required this.branches,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
        maxWidth: LayoutHelper.getMaxContentWidth(context),
      ),
      margin: LayoutHelper.isTablet(context)
          ? EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing(context, 40))
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark : AppTheme.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.radius(context, 32)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: ResponsiveUtils.spacing(context, 14)),

          // Handle
          Container(
            width: ResponsiveUtils.size(context, 45),
            height: ResponsiveUtils.size(context, 5),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.gray600 : AppTheme.gray300,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 3)),
            ),
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 24)),

          // Title
          Text(
            'Select Branch'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 20),
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.white : AppTheme.black,
            ),
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 24)),

          // Branch List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, 24),
              ),
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                final isSelected = selectedBranch == branch;

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 200 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: GestureDetector(
                          onTap: () => onSelect(branch),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                              bottom: ResponsiveUtils.spacing(context, 14),
                            ),
                            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 18)),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? (isDark
                                  ? AppTheme.accentGradient
                                  : AppTheme.primaryGradient)
                                  : null,
                              color: isSelected
                                  ? null
                                  : (isDark
                                  ? AppTheme.white.withOpacity(0.05)
                                  : AppTheme.gray100),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.radius(context, 18),
                              ),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                color: isDark
                                    ? AppTheme.white.withOpacity(0.1)
                                    : AppTheme.gray200,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: (isDark
                                      ? AppTheme.accent
                                      : AppTheme.primary)
                                      .withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? (isDark ? AppTheme.dark : AppTheme.white)
                                      : (isDark ? AppTheme.gray400 : AppTheme.gray500),
                                  size: ResponsiveUtils.icon(context, 24),
                                ),
                                SizedBox(width: ResponsiveUtils.spacing(context, 14)),
                                Expanded(
                                  child: Text(
                                    branch.name,
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.font(context, 16),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? (isDark ? AppTheme.dark : AppTheme.white)
                                          : (isDark ? AppTheme.white : AppTheme.black),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 6)),
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppTheme.dark : AppTheme.white)
                                          .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: ResponsiveUtils.icon(context, 16),
                                      color: isDark ? AppTheme.dark : AppTheme.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 24)),
        ],
      ),
    );
  }
}

// Product Card
class _ProductCard extends StatelessWidget {
  final SelectedProductsModel product;
  final bool isDark;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 12)),
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 14)),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
        border: Border.all(
          color: isDark
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.gray200,
          width: 1.5,
        ),
        boxShadow: AppTheme.cardShadow(isDark),
      ),
      child: Column(
        children: [
          // Product Info Row
          Row(
            children: [
              // Product Image
              Hero(
                tag: 'product_${product.productModel.id}',
                child: Container(
                  width: ResponsiveUtils.size(context, 65),
                  height: ResponsiveUtils.size(context, 65),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
                    child: loadingImage(
                      image: ApiConstants.stoarge + "${product.productModel.picture}",
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(width: ResponsiveUtils.spacing(context, 12)),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productModel.nameAr,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.spacing(context, 3)),
                    Text(
                      product.productModel.description,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 12),
                        color: isDark ? AppTheme.gray400 : AppTheme.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.spacing(context, 8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.spacing(context, 10),
                        vertical: ResponsiveUtils.spacing(context, 5),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withOpacity(isDark ? 0.15 : 0.1),
                            AppTheme.accent.withOpacity(isDark ? 0.08 : 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${product.productModel.customers?.first.pivot.price}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.font(context, 13),
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.accent : AppTheme.primary,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                          context.getCurrencyWidget(
                            height: ResponsiveUtils.font(context, 25),
                            color: isDark ? AppTheme.accent : AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 14)),

          // Quantity & Price Row
          Row(
            children: [
              // Quantity Control
              Expanded(
                child: _buildControlSection(
                  context,
                  label: 'Quantity'.tr(),
                  child: _buildQuantityControl(context),
                ),
              ),

              SizedBox(width: ResponsiveUtils.spacing(context, 12)),

              // Total Price
              Expanded(
                child: _buildControlSection(
                  context,
                  label: 'Price'.tr(),
                  child: _buildPriceDisplay(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(
      BuildContext context, {
        required String label,
        required Widget child,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.font(context, 12),
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.gray400 : AppTheme.gray600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 10)),
        child,
      ],
    );
  }

  Widget _buildQuantityControl(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 10),
        vertical: ResponsiveUtils.spacing(context, 8),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.white.withOpacity(0.05) : AppTheme.gray100,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
        border: Border.all(
          color: isDark
              ? AppTheme.white.withOpacity(0.1)
              : AppTheme.gray200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlButton(
            context,
            icon: Icons.remove_rounded,
            onTap: onRemove,
            isDecrease: true,
          ),
          Text(
            '${product.qty}',
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 18),
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.white : AppTheme.black,
            ),
          ),
          _buildControlButton(
            context,
            icon: Icons.add_rounded,
            onTap: onAdd,
            isDecrease: false,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      BuildContext context, {
        required IconData icon,
        required VoidCallback onTap,
        required bool isDecrease,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
        decoration: BoxDecoration(
          gradient: isDecrease
              ? null
              : (isDark ? AppTheme.accentGradient : AppTheme.primaryGradient),
          color: isDecrease
              ? (isDark
              ? AppTheme.white.withOpacity(0.1)
              : AppTheme.gray200)
              : null,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 10)),
        ),
        child: Icon(
          icon,
          size: ResponsiveUtils.icon(context, 18),
          color: isDecrease
              ? (isDark ? AppTheme.gray400 : AppTheme.gray600)
              : (isDark ? AppTheme.dark : AppTheme.white),
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(BuildContext context) {
    final totalPrice =
        double.parse("${product.productModel.customers?.first.pivot.price}") *
            product.qty;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 16),
        vertical: ResponsiveUtils.spacing(context, 14),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.primary.withOpacity(0.2), AppTheme.accent.withOpacity(0.1)]
              : [AppTheme.primary.withOpacity(0.1), AppTheme.accent.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
        border: Border.all(
          color: (isDark ? AppTheme.accent : AppTheme.primary).withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              totalPrice.toStringAsFixed(2),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 16),
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.accent : AppTheme.primary,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 4)),
            context.getCurrencyWidget(
              height: ResponsiveUtils.font(context, 25),
              color: isDark ? AppTheme.accent : AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 AnimatedBuilder Helper
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