import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/screens/notifications/notifications_screen.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:flutter_svg/svg.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Modern App Colors
// ═══════════════════════════════════════════════════════════════════════════
class AppColors {
  // Light Mode
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Mode
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Brand Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color accent = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, accent],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏗️ Modern MyScaffold - Glassmorphism Design
// ═══════════════════════════════════════════════════════════════════════════
class MyScaffold extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget body;
  final bool showBackButton;
  final bool showNotification;
  final bool hasNotification;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? fabLocation;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationPressed;
  final Future<void> Function()? onRefresh;
  final Color? headerColor;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  const MyScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    required this.body,
    this.showBackButton = false,
    this.showNotification = true,
    this.hasNotification = false,
    this.actions,
    this.floatingActionButton,
    this.fabLocation,
    this.onBackPressed,
    this.onNotificationPressed,
    this.onRefresh,
    this.headerColor,
    this.bottomNavigationBar,
    this.extendBody = false,
  });

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 🌙 Theme Helper
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _bgColor => _isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get _cardColor => _isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get _textColor => _isDark ? AppColors.darkText : AppColors.lightText;
  Color get _textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _borderColor =>
      _isDark ? AppColors.darkBorder : AppColors.lightBorder;

  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 Animations
  // ─────────────────────────────────────────────────────────────────────────
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    _updateSystemUI();

    return Scaffold(
      backgroundColor: _bgColor,
      extendBody: widget.extendBody,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.fabLocation,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // 🎨 Background Decoration
          // ═══════════════════════════════════════════════════════════════
          _buildBackgroundDecoration(),

          // ═══════════════════════════════════════════════════════════════
          // 📱 Main Content
          // ═══════════════════════════════════════════════════════════════
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                FadeTransition(
                  opacity: _headerAnimation,
                  child: _buildModernHeader(),
                ),

                // Body
                Expanded(
                  child: widget.onRefresh != null
                      ? RefreshIndicator(
                    onRefresh: widget.onRefresh!,
                    color: AppColors.primary,
                    backgroundColor: _cardColor,
                    child: widget.body,
                  )
                      : widget.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _bgColor,
        systemNavigationBarIconBrightness:
        _isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Background Decoration
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top Gradient Blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(_isDark ? 0.15 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom Left Blob
          Positioned(
            bottom: -50,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(_isDark ? 0.1 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔝 Modern Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Left Section
          _buildLeftSection(),

          // Center - Title
          Expanded(
            child: widget.titleWidget ?? _buildTitleSection(),
          ),

          // Right Section - Actions
          _buildRightSection(),
        ],
      ),
    );
  }

  Widget _buildLeftSection() {
    if (widget.showBackButton) {
      return _ModernIconButton(
        icon: Icons.arrow_back_rounded,
        onTap: () {
          HapticFeedback.lightImpact();
          if (widget.onBackPressed != null) {
            widget.onBackPressed!();
          } else {
            MyNavigator.back(context);
          }
        },
        isDark: _isDark,
      );
    }

    if (widget.showNotification) {
      return _ModernIconButton(
        icon: Icons.notifications_outlined,
        onTap: () {
          HapticFeedback.lightImpact();
          if (widget.onNotificationPressed != null) {
            widget.onNotificationPressed!();
          } else {
            MyNavigator.navigateTo(context, const NotificationScreen());
          }
        },
        isDark: _isDark,
        showBadge: widget.hasNotification,
      );
    }

    return const SizedBox(width: 48);
  }

  Widget _buildTitleSection() {
    if (widget.title == null && widget.subtitle == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.subtitle!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildRightSection() {
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.actions!
            .map((action) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: action,
        ))
            .toList(),
      );
    }

    // Default Logo
    return _buildModernLogo();
  }

  Widget _buildModernLogo() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: SvgPicture.asset(
          'assets/svg/logoicon.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Modern Icon Button
// ═══════════════════════════════════════════════════════════════════════════
class _ModernIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool showBadge;

  const _ModernIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.showBadge = false,
  });

  @override
  State<_ModernIconButton> createState() => _ModernIconButtonState();
}

class _ModernIconButtonState extends State<_ModernIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.92 : 1.0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.darkCard
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // استخدام DirectionalArrow لزر الرجوع، الأيقونات العادية للباقي
            widget.icon == Icons.arrow_back_rounded
                ? DirectionalArrow(
                    direction: ArrowDirection.backIos,
                    color: widget.isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                    size: 22,
                  )
                : Icon(
                    widget.icon,
                    color: widget.isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                    size: 22,
                  ),
            if (widget.showBadge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isDark
                          ? AppColors.darkCard
                          : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Action Button (للاستخدام في actions)
// ═══════════════════════════════════════════════════════════════════════════
class ScaffoldAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;
  final Color? backgroundColor;
  final Color? iconColor;

  const ScaffoldAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Icon(
              icon,
              color: iconColor ??
                  (isDark ? AppColors.darkText : AppColors.lightText),
              size: 22,
            ),
            if (showBadge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Gradient Action Button
// ═══════════════════════════════════════════════════════════════════════════
class GradientAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Gradient? gradient;

  const GradientAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Modern Card Widget
// ═══════════════════════════════════════════════════════════════════════════
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 20,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color ?? (isDark ? AppColors.darkCard : Colors.white),
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Modern Section Header
// ═══════════════════════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
              letterSpacing: -0.3,
            ),
          ),
          if (actionText != null || actionIcon != null)
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actionText != null)
                      Text(
                        actionText!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    if (actionIcon != null) ...[
                      if (actionText != null) const SizedBox(width: 4),
                      Icon(
                        actionIcon,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Empty State Widget
// ═══════════════════════════════════════════════════════════════════════════
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Usage Examples
// ═══════════════════════════════════════════════════════════════════════════
/*

// 1️⃣ Basic Usage
MyScaffold(
  title: 'الصفحة الرئيسية',
  body: ListView(...),
)

// 2️⃣ With Back Button
MyScaffold(
  title: 'التفاصيل',
  showBackButton: true,
  showNotification: false,
  body: Content(),
)

// 3️⃣ With Subtitle
MyScaffold(
  title: 'مرحباً',
  subtitle: 'أحمد محمد',
  body: HomeContent(),
)

// 4️⃣ With Actions
MyScaffold(
  title: 'الإعدادات',
  showBackButton: true,
  showNotification: false,
  actions: [
    ScaffoldAction(
      icon: Icons.search_rounded,
      onTap: () => print('Search'),
    ),
    GradientAction(
      icon: Icons.add,
      onTap: () => print('Add'),
    ),
  ],
  body: SettingsContent(),
)

// 5️⃣ With Pull to Refresh
MyScaffold(
  title: 'الطلبات',
  onRefresh: () async {
    await fetchOrders();
  },
  body: OrdersList(),
)

// 6️⃣ With Custom Title Widget
MyScaffold(
  titleWidget: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.verified, color: Colors.green),
      SizedBox(width: 8),
      Text('متجر معتمد'),
    ],
  ),
  body: StoreContent(),
)

// 7️⃣ Using ModernCard
ModernCard(
  onTap: () => print('Tapped'),
  child: Row(
    children: [
      Icon(Icons.wallet),
      SizedBox(width: 16),
      Text('المحفظة'),
    ],
  ),
)

// 8️⃣ Using SectionHeader
SectionHeader(
  title: 'الفواتير الأخيرة',
  actionText: 'عرض الكل',
  actionIcon: Icons.arrow_forward_ios,
  onActionTap: () => navigateToAll(),
)

// 9️⃣ Using EmptyState
EmptyState(
  icon: Icons.inbox_outlined,
  title: 'لا توجد بيانات',
  subtitle: 'لم يتم العثور على أي عناصر',
  actionText: 'إعادة المحاولة',
  onAction: () => refresh(),
)

*/