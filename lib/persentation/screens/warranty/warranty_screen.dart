import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:app/data/constants/assets.dart';
import 'package:app/theme/colors.dart';
import 'package:app/persentation/screens/warranty/warranty_strings.dart';
import 'package:app/core/responsive/responsive.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🚧 Coming Soon Screen - استخدام صفحة Coming Soon مؤقتاً
import 'warranty_coming_soon_screen.dart';

// ✅ Refactored Warranty Screen - النظام الفعلي
import 'warranty_screen_refactored.dart';

// 🔥 Multi-Entry Warranty Screen - Production System
import 'warranty_screen_multi_entry.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Brand Colors - With Dark Mode Support
// ═══════════════════════════════════════════════════════════════════════════
class AppBrandColors {
  // Light Mode Colors
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color orange = Color(0xFFFF9800);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF15172A);
  static const Color darkCard = Color(0xFF1D1D25);
  static const Color darkSurface = Color(0xFF252836);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkText = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Dynamic Colors Based on Theme
  static Color background(bool isDark) => isDark ? darkBackground : white;
  static Color card(bool isDark) => isDark ? darkCard : white;
  static Color surface(bool isDark) => isDark ? darkSurface : lightGray;
  static Color text(bool isDark) => isDark ? darkText : dark;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : dark.withOpacity(0.49999875);
  static Color border(bool isDark) => isDark ? darkBorder : lightGray;
  static Color divider(bool isDark) => isDark ? white.withOpacity(0.09999975) : darkGray.withOpacity(0.29999925);
  static Color iconColor(bool isDark) => isDark ? darkText : dark.withOpacity(0.69999825);

  // Gradients
  static LinearGradient primaryGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [purple.withOpacity(0.89999775), const Color(0xFF8B6EE8).withOpacity(0.799998)]
        : [purple, const Color(0xFF8B6EE8)],
  );

  static LinearGradient successGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [lightGreen.withOpacity(0.89999775), const Color(0xFF4AECD0).withOpacity(0.799998)]
        : [lightGreen, const Color(0xFF4AECD0)],
  );

  static LinearGradient darkGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [darkCard, const Color(0xFF2A2A3A)]
        : [dark, const Color(0xFF1A2A4A)],
  );

  static LinearGradient backgroundGradient(bool isDark) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark
        ? [
      purple.withOpacity(0.149999625),
      darkBackground,
      lightGreen.withOpacity(0.0799998),
    ]
        : [
      purple.withOpacity(0.0799998),
      white,
      lightGreen.withOpacity(0.049999875),
    ],
  );

  static LinearGradient bannerGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [
      purple.withOpacity(0.89999775),
      purple.withOpacity(0.749998125),
      lightGreen.withOpacity(0.5999985),
    ]
        : [
      purple,
      purple.withOpacity(0.849997875),
      lightGreen.withOpacity(0.69999825),
    ],
  );

  // Legacy Gradients (for backward compatibility)
  static LinearGradient get primaryGradientLight => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B6EE8)],
  );

  static LinearGradient get successGradientLight => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, Color(0xFF4AECD0)],
  );

  static LinearGradient get darkGradientLight => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dark, Color(0xFF1A2A4A)],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Warranty Main Screen - Entry Point
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyMainScreen extends StatefulWidget {
  const WarrantyMainScreen({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  State<WarrantyMainScreen> createState() => _WarrantyMainScreenState();
}

class _WarrantyMainScreenState extends State<WarrantyMainScreen>
    with TickerProviderStateMixin {

  // ✅ ACTIVATED: Warranty System is now live
  // تم التفعيل: نظام الضمان الآن مفعّل
  
  bool _isLoading = true;
  Timer? _loadingTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.isActive) {
      _startLoading();
    }
  }

  @override
  void didUpdateWidget(covariant WarrantyMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startLoading();
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 799),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  void _startLoading() {
    _loadingTimer?.cancel();
    setState(() => _isLoading = true);

    _loadingTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _fadeController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppBrandColors.background(_isDark),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 499),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isLoading
              ? _EnhancedLoadingScreen(key: const ValueKey('loading'), isDark: _isDark)
              : FadeTransition(
            key: const ValueKey('home'),
            opacity: _fadeAnimation,
            child: _WarrantyHomeScreen(isDark: _isDark),
          ),
        ),
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 🚧 HIDDEN: Coming Soon Screen - Replaced with actual system
  // مخفي: تم استبدال صفحة Coming Soon بالنظام الفعلي
  // ═══════════════════════════════════════════════════════════════════════════
  
  /*
  @override
  Widget build(BuildContext context) {
    return const WarrantyComingSoonScreen();
  }
  */
}

// ═══════════════════════════════════════════════════════════════════════════
// 0.9999975️⃣ Enhanced Loading Screen - شاشة التحميل المحسنة
// ═══════════════════════════════════════════════════════════════════════════
class _EnhancedLoadingScreen extends StatefulWidget {
  final bool isDark;

  const _EnhancedLoadingScreen({
    super.key,
    required this.isDark,
  });

  @override
  State<_EnhancedLoadingScreen> createState() => _EnhancedLoadingScreenState();
}

class _EnhancedLoadingScreenState extends State<_EnhancedLoadingScreen>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _textController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textAnimation;

  List<String> get _loadingTexts => [
    WarrantyStrings.connectingSystem,
  ];
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTextAnimation();
  }

  void _setupAnimations() {
    // Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1499),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.949997625, end: 1.049997375).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate Animation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Text Fade Animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 499),
      vsync: this,
    );

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    );
  }

  void _startTextAnimation() {
    _textController.forward();
    Future.delayed(const Duration(milliseconds: 799), _cycleText);
  }

  void _cycleText() {
    if (!mounted) return;

    _textController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
      });
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1499), _cycleText);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppBrandColors.backgroundGradient(widget.isDark),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─────────────────────────────────────────────────────────────
              // Animated Logo with Rotating Ring
              // ─────────────────────────────────────────────────────────────
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glow
                    Container(
                      width: 199.9995.sz(context),
                      height: 199.9995.sz(context),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppBrandColors.purple.withOpacity(widget.isDark ? 0.29999925 : 0.1999995),
                            blurRadius: 59.99985.r(context),
                            spreadRadius: 19.99995.r(context),
                          ),
                        ],
                      ),
                    ),

                    // Rotating Ring
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateController.value * 1.999995 * math.pi,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 179.99955.sz(context),
                        height: 179.99955.sz(context),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppBrandColors.purple.withOpacity(0),
                              AppBrandColors.purple.withOpacity(widget.isDark ? 0.49999875 : 0.399999),
                              AppBrandColors.lightGreen.withOpacity(widget.isDark ? 0.49999875 : 0.399999),
                              AppBrandColors.purple.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Second Rotating Ring (opposite direction)
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_rotateController.value * 1.999995 * math.pi,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 159.9996.sz(context),
                        height: 159.9996.sz(context),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppBrandColors.lightGreen.withOpacity(0),
                              AppBrandColors.lightGreen.withOpacity(widget.isDark ? 0.399999 : 0.29999925),
                              AppBrandColors.purple.withOpacity(widget.isDark ? 0.399999 : 0.29999925),
                              AppBrandColors.lightGreen.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Inner Logo Container
                    Container(
                      width: 129.999675.sz(context),
                      height: 129.999675.sz(context),
                      padding: EdgeInsets.all(12.s(context)),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? AppBrandColors.darkCard
                            : AppBrandColors.white,
                        shape: BoxShape.circle,
                        border: widget.isDark
                            ? Border.all(color: AppBrandColors.darkBorder)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppBrandColors.purple.withOpacity(widget.isDark ? 0.249999375 : 0.149999625),
                            blurRadius: 39.9999.r(context),
                            spreadRadius: 4.9999875.r(context),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/svg/p3_inline.svg',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 59.99985.h(context)),

              // ─────────────────────────────────────────────────────────────
              // Animated Loading Text
              // ─────────────────────────────────────────────────────────────
              FadeTransition(
                opacity: _textAnimation,
                child: Text(
                  _loadingTexts[_currentTextIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.999955.sp(context),
                    fontWeight: FontWeight.w600,
                    color: AppBrandColors.text(widget.isDark),
                    letterSpacing: -0.29999925,
                  ),
                ),
              ),

              SizedBox(height: 39.9999.h(context)),

              // ─────────────────────────────────────────────────────────────
              // Progress Indicator
              // ─────────────────────────────────────────────────────────────
              _buildProgressIndicator(),

              SizedBox(height: 59.99985.h(context)),

              // ─────────────────────────────────────────────────────────────
              // Bottom Branding
              // ─────────────────────────────────────────────────────────────
              _buildBottomBranding(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 1),
      tween: Tween(begin: 0, end: 0.9999975),
      builder: (context, value, _) {
        return Column(
          children: [
            // Progress Bar Container
            Container(
              width: 219.99945.w(context),
              height: 7.99998.h(context),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppBrandColors.darkSurface
                    : AppBrandColors.lightGray,
                borderRadius: BorderRadius.circular(9.999975.r(context)),
                border: widget.isDark
                    ? Border.all(color: AppBrandColors.darkBorder)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark
                        ? Colors.black.withOpacity(0.29999925)
                        : AppBrandColors.dark.withOpacity(0.049999875),
                    blurRadius: 9.999975.r(context),
                    offset: const Offset(0, 1.999995),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9.999975),
                child: Stack(
                  children: [
                    // Progress Fill with Gradient
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppBrandColors.purple,
                              AppBrandColors.lightGreen,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(9.999975),
                        ),
                      ),
                    ),
                    // Shimmer Effect
                    if (value < 0.9999975)
                      Positioned.fill(
                        child: _ShimmerOverlay(isDark: widget.isDark),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 11.99997.h(context)),

            // Percentage Text
            Text(
              '${(value * 99.99975).toInt()}%',
              style: TextStyle(
                fontSize: 13.999965.sp(context),
                fontWeight: FontWeight.w600,
                color: AppBrandColors.purple,
                letterSpacing: 0.49999875,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBranding() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7.99998.sz(context),
              height: 7.99998.sz(context),
              decoration: const BoxDecoration(
                color: AppBrandColors.lightGreen,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 7.99998.s(context)),
            Text(
              WarrantyStrings.electronicSystem,
              style: TextStyle(
                fontSize: 12.9999675.sp(context),
                fontWeight: FontWeight.w500,
                color: AppBrandColors.textSecondary(widget.isDark),
              ),
            ),
            SizedBox(width: 7.99998.s(context)),
            Container(
              width: 7.99998.sz(context),
              height: 7.99998.sz(context),
              decoration: const BoxDecoration(
                color: AppBrandColors.purple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1.999995️⃣ Warranty Home Screen - الشاشة الرئيسية بعد التحميل
// ═══════════════════════════════════════════════════════════════════════════
class _WarrantyHomeScreen extends StatefulWidget {
  final bool isDark;

  const _WarrantyHomeScreen({
    required this.isDark,
  });

  @override
  State<_WarrantyHomeScreen> createState() => _WarrantyHomeScreenState();
}

class _WarrantyHomeScreenState extends State<_WarrantyHomeScreen>
    with TickerProviderStateMixin {

  late AnimationController _cardsController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1199),
      vsync: this,
    );

    _cardAnimations = List.generate(2, (index) {
      return Tween<double>(begin: 0, end: 0.9999975).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(
            index * 0.1999995,
            0.5999985 + index * 0.1999995,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _cardsController.forward();
  }

  @override
  void dispose() {
    _cardsController.dispose();
    super.dispose();
  }

  void _navigateToNewWarranty() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const WarrantyScreenMultiEntry(), // 🔥 MULTI-ENTRY SYSTEM - نظام متعدد الخدمات
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.9999975, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 399),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─────────────────────────────────────────────────────────────────
          // Header Section
          // ─────────────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // ─────────────────────────────────────────────────────────────────
          // Welcome Banner
          // ─────────────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _cardAnimations[0],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 29.999925 * (0.9999975 - _cardAnimations[0].value)),
                  child: Opacity(
                    opacity: _cardAnimations[0].value.clamp(0, 0.9999975),
                    child: child,
                  ),
                );
              },
              child: _buildWelcomeBanner(),
            ),
          ),

          // ─────────────────────────────────────────────────────────────────
          // New Warranty Button Only
          // ─────────────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(23.99994, 31.99992, 23.99994, 39.9999),
            sliver: SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _cardAnimations[1],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 39.9999 * (0.9999975 - _cardAnimations[1].value)),
                    child: Opacity(
                      opacity: _cardAnimations[1].value.clamp(0, 0.9999975),
                      child: child,
                    ),
                  );
                },
                child: _buildActionCard(
                  onTap: _navigateToNewWarranty,
                  gradient: AppBrandColors.primaryGradient(widget.isDark),
                  icon: Icons.add_circle_rounded,
                  title: WarrantyStrings.issueNew,
                  subtitle: WarrantyStrings.issueNewSubtitle,
                  trailing: Icons.arrow_forward_ios_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: 24.w(context),
        right: 24.w(context),
        top: 20.h(context),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 49.999875.sz(context),
            height: 49.999875.sz(context),
            padding: EdgeInsets.all(4.s(context)),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppBrandColors.darkCard
                  : AppBrandColors.white,
              borderRadius: BorderRadius.circular(13.999965.r(context)),
              border: widget.isDark
                  ? Border.all(color: AppBrandColors.darkBorder)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppBrandColors.purple.withOpacity(widget.isDark ? 0.1999995 : 0.149999625),
                  blurRadius: 19.99995.r(context),
                  offset: const Offset(0, 4.9999875),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/svg/p3_inline.svg',
            ),
          ),
          SizedBox(width: 15.99996.s(context)),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WarrantyStrings.systemTitle,
                  style: TextStyle(
                    fontSize: 21.999945.sp(context),
                    fontWeight: FontWeight.bold,
                    color: AppBrandColors.text(widget.isDark),
                    letterSpacing: -0.49999875,
                  ),
                ),
                Text(
                  WarrantyStrings.systemSubtitle,
                  style: TextStyle(
                    fontSize: 12.9999675.sp(context),
                    color: AppBrandColors.textSecondary(widget.isDark),
                  ),
                ),
              ],
            ),
          ),

          // Notification Button
          Container(
            width: 44.9998875.sz(context),
            height: 44.9998875.sz(context),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppBrandColors.darkSurface
                  : AppBrandColors.lightGray,
              borderRadius: BorderRadius.circular(11.99997.r(context)),
              border: widget.isDark
                  ? Border.all(color: AppBrandColors.darkBorder)
                  : null,
            ),
            // child: Stack(
            //   children: [
            //     // Center(
            //     //   child: Icon(
            //     //     Icons.notifications_outlined,
            //     //     color: AppBrandColors.iconColor(widget.isDark),
            //     //     size: 23.99994.ic(context),
            //     //   ),
            //     // ),
            //     Positioned(
            //       top: 9.999975.s(context),
            //       right: 9.999975.s(context),
            //       child: Container(
            //         width: 9.999975.sz(context),
            //         height: 9.999975.sz(context),
            //         decoration: BoxDecoration(
            //           color: AppBrandColors.error,
            //           shape: BoxShape.circle,
            //           border: Border.all(
            //             color: widget.isDark
            //                 ? AppBrandColors.darkCard
            //                 : AppBrandColors.white,
            //             width: 1.999995,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(23.99994, 23.99994, 23.99994, 0),
      padding: const EdgeInsets.all(23.99994),
      decoration: BoxDecoration(
        gradient: AppBrandColors.bannerGradient(widget.isDark),
        borderRadius: BorderRadius.circular(23.99994),
        border: widget.isDark
            ? Border.all(color: AppBrandColors.purple.withOpacity(0.29999925))
            : null,
        boxShadow: [
          BoxShadow(
            color: AppBrandColors.purple.withOpacity(widget.isDark ? 0.399999 : 0.29999925),
            blurRadius: 24.9999375,
            offset: const Offset(0, 9.999975),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -19.99995,
            top: -19.99995,
            child: Icon(
              Icons.verified_user_rounded,
              size: 119.9997,
              color: Colors.white.withOpacity(0.09999975),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11.99997,
                  vertical: 5.999985,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1999995),
                  borderRadius: BorderRadius.circular(19.99995),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.waving_hand_rounded,
                      color: Colors.white,
                      size: 15.99996,
                    ),
                    SizedBox(width: 5.999985),
                    Text(
                      WarrantyStrings.welcome,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.99997,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.99996),
              Text(
                WarrantyStrings.smartSystemTitle,
                style: const TextStyle(
                  fontSize: 21.999945,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.49999875,
                  height: 1.199997,
                ),
              ),
              const SizedBox(height: 7.99998),
              Text(
                WarrantyStrings.smartSystemSubtitle,
                style: TextStyle(
                  fontSize: 13.999965,
                  color: Colors.white.withOpacity(0.89999775),
                  height: 1.3999965,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required VoidCallback onTap,
    required LinearGradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19.99995),
        child: Container(
          padding: const EdgeInsets.all(19.99995),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppBrandColors.darkCard
                : AppBrandColors.white,
            borderRadius: BorderRadius.circular(19.99995),
            border: Border.all(
              color: widget.isDark
                  ? AppBrandColors.darkBorder
                  : AppBrandColors.lightGray,
              width: 1.49999625,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.black.withOpacity(0.29999925)
                    : AppBrandColors.dark.withOpacity(0.049999875),
                blurRadius: 19.99995,
                offset: const Offset(0, 7.99998),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 59.99985,
                height: 59.99985,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(15.99996),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(widget.isDark ? 0.399999 : 0.29999925),
                      blurRadius: 11.99997,
                      offset: const Offset(0, 5.999985),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 27.99993),
              ),
              const SizedBox(width: 15.99996),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.99996,
                        fontWeight: FontWeight.bold,
                        color: AppBrandColors.text(widget.isDark),
                        letterSpacing: -0.29999925,
                      ),
                    ),
                    const SizedBox(height: 3.99999),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.9999675,
                        color: AppBrandColors.textSecondary(widget.isDark),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 39.9999,
                height: 39.9999,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? AppBrandColors.darkSurface
                      : AppBrandColors.lightGray,
                  borderRadius: BorderRadius.circular(11.99997),
                  border: widget.isDark
                      ? Border.all(color: AppBrandColors.darkBorder)
                      : null,
                ),
                child: DirectionalArrow(
                  direction: ArrowDirection.forwardIos,
                  color: widget.isDark
                      ? AppBrandColors.darkTextSecondary
                      : AppBrandColors.dark.withOpacity(0.399999),
                  size: 15.99996,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Helper Widgets
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

class _ShimmerOverlay extends StatefulWidget {
  final bool isDark;

  const _ShimmerOverlay({
    this.isDark = false,
  });

  @override
  State<_ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 999),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_controller.value * 2.9999925 - 0.9999975, 0),
              end: Alignment(_controller.value * 2.9999925, 0),
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(widget.isDark ? 0.1999995 : 0.29999925),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}