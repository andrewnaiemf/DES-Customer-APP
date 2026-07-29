import 'package:app/core/responsive/responsive.dart';
import 'package:app/business_logic/products/cubit/products_cubit.dart';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/product/product_model.dart';
import 'package:app/persentation/widgets/Loading_widget.dart';
import 'package:app/persentation/widgets/image_loading.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme - Official Brand Colors & Design System
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────
  // Primary Brand Colors
  // ─────────────────────────────────────────────────────────────────────────
  static const Color green = Color.fromRGBO(0, 200, 141, 1);
  static const Color yellow = Color.fromRGBO(251, 191, 77, 1);
  static const Color black = Color(0xFF1D1D25);
  static const Color omnia = Color(0xFFE5E5F5);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);

  // Extended UI Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFFF9F43);
  static const Color blue = Color(0xFF3B82F6);
  static const Color purpleLight = Color(0xFF8B5CF6);
  static const Color background = Color(0xFF15172A);
  static const Color cardDark = Color(0xFF1E2030);
  static const Color surfaceDark = Color(0xFF252836);
  static const Color borderDark = Color(0xFF2D3748);
  static const Color teal = Color(0xFF14B8A6);
  static const Color pink = Color(0xFFEC4899);

  // ─────────────────────────────────────────────────────────────────────────
  // Dynamic Theme Helpers
  // ─────────────────────────────────────────────────────────────────────────
  static Color getBackground(bool isDark) => isDark ? background : omnia;
  static Color getCard(bool isDark) => isDark ? cardDark : white;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : lightGray;
  static Color getText(bool isDark) => isDark ? white : dark;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkGray : dark.withOpacity(0.6);
  static Color getBorder(bool isDark) =>
      isDark ? borderDark : darkGray.withOpacity(0.3);
  static Color getDivider(bool isDark) =>
      isDark ? white.withOpacity(0.08) : darkGray.withOpacity(0.2);

  // ─────────────────────────────────────────────────────────────────────────
  // Gradient Presets
  // ─────────────────────────────────────────────────────────────────────────
  static LinearGradient primaryGradient({bool reversed = false}) =>
      LinearGradient(
        begin: reversed ? Alignment.bottomRight : Alignment.topLeft,
        end: reversed ? Alignment.topLeft : Alignment.bottomRight,
        colors: const [purple, purpleLight],
      );

  static LinearGradient successGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, lightGreen],
  );

  static LinearGradient accentGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, teal],
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Shadow Presets
  // ─────────────────────────────────────────────────────────────────────────
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
    BoxShadow(
      color: color.withOpacity(isDark ? 0.2 : 0.15),
      blurRadius: 40,
      offset: const Offset(0, 20),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> cardShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black26 : dark.withOpacity(0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Border Radius & Duration Presets
  // ─────────────────────────────────────────────────────────────────────────
  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 28.0;

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
}

// ═══════════════════════════════════════════════════════════════════════════
// 🛍️ Products Screen - Premium E-Commerce UI
// ═══════════════════════════════════════════════════════════════════════════
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _searchController2;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // State
  List<ProductModel>? _searchedProducts;
  bool _isSearchFocused = false;
  double _scrollOffset = 0;
  int _selectedCategory = 0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Categories for filter
  final List<String> _categories = [
    'All',
    'Popular',
    'New',
    'Sale',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
    _setupAnimations();
    _setupListeners();
  }

  void _initData() {
    if (ProductsCubit.get(context).allProducts.isEmpty) {
      ProductsCubit.get(context).getProducts();
    }
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _searchController2 = AnimationController(
      vsync: this,
      duration: AppTheme.durationNormal,
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.forward();
  }

  void _setupListeners() {
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  void _onSearchFocusChange() {
    setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    if (_isSearchFocused) {
      _searchController2.forward();
    } else {
      _searchController2.reverse();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _searchController2.dispose();
    _floatingController.dispose();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    setState(() {
      if (value.isNotEmpty) {
        _searchedProducts = ProductsCubit.get(context)
            .allProducts
            .where((element) =>
        element.nameAr.toLowerCase().contains(value.toLowerCase()) ||
            element.description.toLowerCase().contains(value.toLowerCase()))
            .toList();
      } else {
        _searchedProducts = null;
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchedProducts = null);
    _searchFocusNode.unfocus();
  }

  Future<void> _refreshProducts() async {
    HapticFeedback.mediumImpact();
    await ProductsCubit.get(context).getProducts();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackground(_isDark),
      body: Stack(
        children: [
          // Background Decorations
          _buildBackgroundDecorations(size),

          // Main Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  _buildAppBar(size),
                  _buildSearchBar(size),
                  Expanded(
                    child: BlocBuilder<ProductsCubit, ProductsState>(
                      builder: (context, state) {
                        if (ProductsCubit.get(context).isLoadingData) {
                          return _buildLoadingGrid();
                        }

                        List<ProductModel> products =
                            _searchedProducts ?? ProductsCubit.get(context).allProducts;

                        if (products.isEmpty) {
                          return _buildEmptyState(size);
                        }

                        return _buildProductsGrid(products);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Background Decorations
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBackgroundDecorations(Size size) {
    return Stack(
      children: [
        // Top Right Orb
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Positioned(
              top: -60 - (_scrollOffset * 0.1),
              right: -50 + (_floatingController.value * 12),
              child: Opacity(
                opacity: _isDark ? 0.08 : 0.12,
                child: Container(
                  width: 200,
                  height: 200,
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
            );
          },
        ),

        // Bottom Left Orb
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Positioned(
              bottom: size.height * 0.3,
              left: -80 - (_floatingController.value * 8),
              child: Opacity(
                opacity: _isDark ? 0.06 : 0.1,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.lightGreen,
                        AppTheme.lightGreen.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // App Bar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAppBar(Size size) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            _buildBackButton(size),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products'.tr(),
                    style: TextStyle(
                      fontSize: size.width * 0.055,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.getText(_isDark),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  BlocBuilder<ProductsCubit, ProductsState>(
                    builder: (context, state) {
                      final count = ProductsCubit.get(context).allProducts.length;
                      return Text(
                        '$count ${'items available'.tr()}',
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          color: AppTheme.getTextSecondary(_isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildCartButton(size),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(Size size) {
    return _PressableScale(
      onPressed: () {
        HapticFeedback.lightImpact();
        MyNavigator.back(context);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient(),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
        ),
        child: DirectionalArrow(
          direction: ArrowDirection.backIos,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildCartButton(Size size) {
    return _PressableScale(
      onPressed: () {
        HapticFeedback.lightImpact();
        // Navigate to cart
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDark
                ? [
              AppTheme.purple.withOpacity(0.25),
              AppTheme.lightGreen.withOpacity(0.15),
            ]
                : [
              AppTheme.purple.withOpacity(0.12),
              AppTheme.lightGreen.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: _isDark
                ? AppTheme.purple.withOpacity(0.3)
                : AppTheme.purple.withOpacity(0.2),
          ),
        ),
        child: Stack(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
              size: size.width * 0.06,
            ),
            // Cart Badge
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.getBackground(_isDark),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Search Bar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.getCard(_isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(
            color: _isSearchFocused
                ? AppTheme.purple
                : AppTheme.getBorder(_isDark),
            width: _isSearchFocused ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isSearchFocused
                  ? AppTheme.purple.withOpacity(0.15)
                  : (_isDark
                  ? Colors.black.withOpacity(0.2)
                  : AppTheme.dark.withOpacity(0.04)),
              blurRadius: _isSearchFocused ? 20 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Search Icon Container
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: size.width * 0.05,
              ),
            ),

            // Search Input
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(
                  color: AppTheme.getText(_isDark),
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...'.tr(),
                  hintStyle: TextStyle(
                    color: AppTheme.getTextSecondary(_isDark),
                    fontSize: size.width * 0.038,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                ),
                onChanged: _onSearch,
              ),
            ),

            // Clear Button
            AnimatedSwitcher(
              duration: AppTheme.durationFast,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _searchController.text.isNotEmpty
                  ? _PressableScale(
                key: const ValueKey('clear'),
                onPressed: _clearSearch,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurface(_isDark),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppTheme.getTextSecondary(_isDark),
                    size: 18,
                  ),
                ),
              )
                  : const SizedBox(key: ValueKey('empty'), width: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Category Filter
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCategoryFilter(Size size) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return Padding(
            padding: EdgeInsets.only(right: index < _categories.length - 1 ? 10 : 0),
            child: _PressableScale(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = index);
              },
              child: AnimatedContainer(
                duration: AppTheme.durationNormal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient() : null,
                  color: isSelected ? null : AppTheme.getCard(_isDark),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: isSelected
                      ? null
                      : Border.all(color: AppTheme.getBorder(_isDark)),
                  boxShadow: isSelected
                      ? AppTheme.elevatedShadow(AppTheme.purple, _isDark)
                      : null,
                ),
                child: Text(
                  _categories[index].tr(),
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.getTextSecondary(_isDark),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Loading Grid
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _ShimmerProductCard(isDark: _isDark),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty State
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container
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
                    AppTheme.purple.withOpacity(_isDark ? 0.15 : 0.1),
                    AppTheme.lightGreen.withOpacity(_isDark ? 0.1 : 0.06),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: size.width * 0.15,
                color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No products found'.tr(),
            style: TextStyle(
              fontSize: size.width * 0.048,
              fontWeight: FontWeight.w700,
              color: AppTheme.getText(_isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords'.tr(),
            style: TextStyle(
              fontSize: size.width * 0.036,
              color: AppTheme.getTextSecondary(_isDark),
            ),
          ),
          const SizedBox(height: 24),
          _PressableScale(
            onPressed: _clearSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
              ),
              child: Text(
                'Clear Search'.tr(),
                style: TextStyle(
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Products Grid
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProductsGrid(List<ProductModel> products) {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      color: AppTheme.purple,
      backgroundColor: AppTheme.getCard(_isDark),
      child: GridView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: _ProductCard(
              product: products[index],
              isDark: _isDark,
              index: index,
              onTap: () {
                HapticFeedback.mediumImpact();
                ProductsCubit.get(context).selectProduct(context, products[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ✨ Shimmer Loading Card
// ═══════════════════════════════════════════════════════════════════════════
class _ShimmerProductCard extends StatefulWidget {
  final bool isDark;

  const _ShimmerProductCard({required this.isDark});

  @override
  State<_ShimmerProductCard> createState() => _ShimmerProductCardState();
}

class _ShimmerProductCardState extends State<_ShimmerProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: widget.isDark
                  ? [
                AppTheme.cardDark,
                AppTheme.cardDark.withOpacity(0.5),
                AppTheme.cardDark,
              ]
                  : [
                AppTheme.lightGray,
                Colors.white,
                AppTheme.lightGray,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppTheme.surfaceDark
                        : AppTheme.darkGray.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusXL),
                    ),
                  ),
                ),
              ),
              // Content placeholder
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppTheme.surfaceDark
                              : AppTheme.darkGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppTheme.surfaceDark
                              : AppTheme.darkGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 28,
                        width: 70,
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppTheme.surfaceDark
                              : AppTheme.darkGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎴 Product Card - Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isDark;
  final int index;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: AppTheme.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _hoverController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _hoverController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hasPrice = widget.product.customers?.isNotEmpty ?? false;

    // Generate unique gradient colors based on index
    final gradientColors = _getGradientColors(widget.index);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          decoration: BoxDecoration(
            color: widget.isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            border: Border.all(
              color: _isPressed
                  ? gradientColors[0].withOpacity(0.4)
                  : AppTheme.getBorder(widget.isDark),
              width: _isPressed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.black.withOpacity(0.3)
                    : gradientColors[0].withOpacity(_isPressed ? 0.15 : 0.08),
                blurRadius: _isPressed ? 16 : 20,
                offset: Offset(0, _isPressed ? 4 : 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            child: Stack(
              children: [
                // Background Gradient Accent
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradientColors[0].withOpacity(0.2),
                          gradientColors[1].withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Expanded(
                      flex: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image
                          Hero(
                            tag: 'product_${widget.product.id}',
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? AppTheme.surfaceDark.withOpacity(0.5)
                                    : AppTheme.lightGray,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppTheme.radiusXL),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppTheme.radiusXL),
                                ),
                                child: loadingImage(
                                  image: ApiConstants.stoarge +
                                      "${widget.product.picture}",
                                  boxFit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // Add Button
                          Positioned(
                            top: 10,
                            right: 10,
                            child: _AddButton(
                              gradientColors: gradientColors,
                              onTap: widget.onTap,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Product Info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              widget.product.nameAr,
                              style: TextStyle(
                                fontSize: size.width * 0.036,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getText(widget.isDark),
                                height: 1.2,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),

                            // Description
                            Expanded(
                              child: Text(
                                widget.product.description,
                                style: TextStyle(
                                  fontSize: size.width * 0.028,
                                  color: AppTheme.getTextSecondary(widget.isDark),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Price
                            if (hasPrice)
                              _PriceTag(
                                price:
                                '${widget.product.customers!.first.pivot.price}',
                                isDark: widget.isDark,
                                gradientColors: gradientColors,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(int index) {
    // كل الأزرار بنفسجي موحد
    return [AppTheme.purple, AppTheme.purpleLight];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ❤️ Favorite Button
// ═══════════════════════════════════════════════════════════════════════════
class _FavoriteButton extends StatefulWidget {
  final bool isDark;

  const _FavoriteButton({required this.isDark});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    setState(() => _isFavorite = !_isFavorite);
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppTheme.dark.withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            color: _isFavorite ? AppTheme.red : AppTheme.getTextSecondary(widget.isDark),
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ➕ Add Button
// ═══════════════════════════════════════════════════════════════════════════
class _AddButton extends StatelessWidget {
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _AddButton({
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏷️ Product Badge
// ═══════════════════════════════════════════════════════════════════════════
class _ProductBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ProductBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXS),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 💰 Price Tag
// ═══════════════════════════════════════════════════════════════════════════
class _PriceTag extends StatelessWidget {
  final String price;
  final bool isDark;
  final List<Color> gradientColors;

  const _PriceTag({
    required this.price,
    required this.isDark,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            gradientColors[0].withOpacity(0.2),
            gradientColors[1].withOpacity(0.1),
          ]
              : [
            gradientColors[0].withOpacity(0.12),
            gradientColors[1].withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXS),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? gradientColors[1] : gradientColors[0],
            ),
          ),
          const SizedBox(width: 4),
          context.getCurrencyWidget(
            height: 18,
            width: 25,
            color: isDark ? gradientColors[1] : gradientColors[0],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 👆 Pressable Scale Widget
// ═══════════════════════════════════════════════════════════════════════════
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scaleFactor;

  const _PressableScale({
    super.key,
    required this.child,
    required this.onPressed,
    this.scaleFactor = 0.96,
  });

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
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
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Animated Builder Helper
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