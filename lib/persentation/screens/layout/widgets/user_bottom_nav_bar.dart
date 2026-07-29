import 'package:app/business_logic/layout/cubit/layout_cubit.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/core/responsive/responsive.dart';
import 'package:app/data/constants/assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Brand Colors - Light & Dark Mode
// ═══════════════════════════════════════════════════════════════════════════
class AppColors {
  // Core Brand Colors
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color white = Colors.white;

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF081428);
  static const Color lightTextSecondary = Color(0xFFC6CBE0);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF15172A);
  static const Color darkSurface = Color(0xFF1D1D25);
  static const Color darkCard = Color(0xFF081428);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2D2D3A);

  // Gradients - Light Mode
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B6EE8)],
  );

  static const LinearGradient activeGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDE8FC), Color(0xFFF5F2FD)],
  );

  // Gradients - Dark Mode
  static const LinearGradient activeGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D2B55), Color(0xFF1F1D35)],
  );

  // Helper methods for theme-aware colors
  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;

  static Color cardColor(bool isDark) => isDark ? darkCard : lightSurface;

  static Color textPrimary(bool isDark) => isDark ? darkText : lightText;

  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static Color borderColor(bool isDark) => isDark ? darkBorder : lightBorder;

  static LinearGradient activeGradient(bool isDark) =>
      isDark ? activeGradientDark : activeGradientLight;

  static Color activeIconColor(bool isDark) => isDark ? lightGreen : purple;

  static Color inactiveIconColor(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Bottom Nav Bar Item Model
// ═══════════════════════════════════════════════════════════════════════════
class BottomNavBarItem {
  final String title;
  final String icon;
  final int id;
  final bool isIconData;

  const BottomNavBarItem({
    required this.title,
    required this.icon,
    required this.id,
    this.isIconData = false,
  });

  static const List<BottomNavBarItem> navBar = [
    BottomNavBarItem(title: 'Home', icon: AssetsSVG.home, id: 0),
    BottomNavBarItem(title: 'Orders', icon: AssetsSVG.orders, id: 1),
    BottomNavBarItem(title: 'Reports', icon: AssetsSVG.reports, id: 2),
    BottomNavBarItem(
        title: 'P3 Warranty', icon: 'shield', id: 3, isIconData: true),
    BottomNavBarItem(title: 'Profile', icon: AssetsSVG.profile, id: 4),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Bottom Navigation Bar Widget
// ═══════════════════════════════════════════════════════════════════════════
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, _) {
        return BlocBuilder<LayoutCubit, LayoutState>(
          builder: (context, state) {
            final cubit = LayoutCubit.get(context);
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return _AnimatedBottomNavBar(
              currentIndex: cubit.bottomNavBarIndex,
              isDark: isDark,
              onItemTapped: (index) {
                HapticFeedback.lightImpact();
                cubit.changeScreen(index);
              },
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Animated Bottom Navigation Bar
// ═══════════════════════════════════════════════════════════════════════════
class _AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onItemTapped;

  const _AnimatedBottomNavBar({
    required this.currentIndex,
    required this.isDark,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // الحصول على ارتفاع شريط التنقل السفلي للنظام
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(
        ResponsiveUtils.spacing(context, 10),
        ResponsiveUtils.spacing(context, 8),
        ResponsiveUtils.spacing(context, 10),
        ResponsiveUtils.spacing(context, 10) ,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 28),
        ),
        border: isDark
            ? Border.all(
          color: AppColors.white.withOpacity(0.08),
          width: 1.0,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : AppColors.lightText.withOpacity(0.08),
            blurRadius: ResponsiveUtils.radius(context, 20),
            offset: Offset(0, -ResponsiveUtils.spacing(context, 3)),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? AppColors.purple.withOpacity(0.15)
                : AppColors.purple.withOpacity(0.05),
            blurRadius: ResponsiveUtils.radius(context, 32),
            offset: Offset(0, -ResponsiveUtils.spacing(context, 6)),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 28),
        ),
        child: Container(
          height: ResponsiveUtils.height(context, 70),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              BottomNavBarItem.navBar.length,
                  (index) => Expanded(
                child: _NavBarItemWidget(
                  item: BottomNavBarItem.navBar[index],
                  isSelected: currentIndex == index,
                  isDark: isDark,
                  onTap: () => onItemTapped(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Navigation Bar Item Widget
// ═══════════════════════════════════════════════════════════════════════════
class _NavBarItemWidget extends StatefulWidget {
  final BottomNavBarItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_NavBarItemWidget> createState() => _NavBarItemWidgetState();
}

class _NavBarItemWidgetState extends State<_NavBarItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_NavBarItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Active colors based on theme
    final activeColor = AppColors.activeIconColor(widget.isDark);
    final inactiveColor = AppColors.inactiveIconColor(widget.isDark);
    final textColor = widget.isSelected
        ? activeColor
        : AppColors.textSecondary(widget.isDark);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected
                ? ResponsiveUtils.spacing(context, 12)
                : ResponsiveUtils.spacing(context, 8),
            vertical: ResponsiveUtils.spacing(context, 6),
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? AppColors.activeGradient(widget.isDark)
                : null,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 18),
            ),
            border: widget.isSelected && widget.isDark
                ? Border.all(
              color: activeColor.withOpacity(0.3),
              width: 1.0,
            )
                : null,
            boxShadow: widget.isSelected
                ? [
              BoxShadow(
                color: activeColor
                    .withOpacity(widget.isDark ? 0.25 : 0.15),
                blurRadius: ResponsiveUtils.radius(context, 6),
                offset: Offset(0, ResponsiveUtils.spacing(context, 3)),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()
                  ..translate(0.0, widget.isSelected ? -0.5 : 0.0, 0.0),
                child: _buildIcon(context, activeColor, inactiveColor),
              ),

              SizedBox(height: ResponsiveUtils.spacing(context, 2)),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'SF-Arabic',
                  fontSize: widget.isSelected
                      ? ResponsiveUtils.font(context, 10)
                      : ResponsiveUtils.font(context, 9),
                  fontWeight:
                  widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                  letterSpacing: 0.2,
                  height: 1.0,
                ),
                child: Text(
                  widget.item.title.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Active indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  top: ResponsiveUtils.spacing(context, 2),
                ),
                width: widget.isSelected
                    ? ResponsiveUtils.size(context, 4)
                    : 0,
                height: widget.isSelected
                    ? ResponsiveUtils.size(context, 4)
                    : 0,
                decoration: BoxDecoration(
                  gradient: widget.isDark
                      ? LinearGradient(
                    colors: [
                      AppColors.lightGreen,
                      AppColors.lightGreen.withOpacity(0.7)
                    ],
                  )
                      : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: ResponsiveUtils.radius(context, 6),
                      spreadRadius: 0,
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

  Widget _buildIcon(
      BuildContext context, Color activeColor, Color inactiveColor) {
    final color = widget.isSelected ? activeColor : inactiveColor;

    if (widget.item.isIconData) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 1)),
        child: Icon(
          Icons.shield_rounded,
          size: widget.isSelected
              ? ResponsiveUtils.icon(context, 22)
              : ResponsiveUtils.icon(context, 20),
          color: color,
        ),
      );
    }

    return SvgPicture.asset(
      widget.item.icon,
      width: widget.isSelected
          ? ResponsiveUtils.icon(context, 22)
          : ResponsiveUtils.icon(context, 20),
      height: widget.isSelected
          ? ResponsiveUtils.icon(context, 22)
          : ResponsiveUtils.icon(context, 20),
      color: color,
    );
  }
}