import 'package:app/core/responsive/responsive.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme - موحد مع باقي التطبيق
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  static const Color primary = Color(0xFF6842E2);
  static const Color primaryLight = Color(0xFF8B6CEF);
  static const Color primaryDark = Color(0xFF5234B5);
  static const Color secondary = Color(0xFF00C88D);
  static const Color secondaryLight = Color(0xFF28E6C5);
  static const Color accent = Color(0xFFFBBF4D);
  static const Color dark = Color(0xFF081428);
  static const Color white = Colors.white;
  static const Color darkBackground = Color(0xFF0A0A12);
  static const Color darkCard = Color(0xFF14141F);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1D1D25);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryLight],
      );

  static LinearGradient get secondaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [secondary, secondaryLight],
      );

  static LinearGradient get darkBackgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A1040),
          Color(0xFF0D0D1A),
          Color(0xFF0A0A12),
        ],
      );

  static LinearGradient get lightBackgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8F9FC),
          Color(0xFFF5F7FA),
          Color(0xFFFFFFFF),
        ],
      );

  // Theme-aware getters
  static Color background(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color text(bool isDark) => isDark ? white : lightText;
  static Color textSecondary(bool isDark) =>
      isDark ? white.withOpacity(0.5) : lightTextSecondary;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🚧 Warranty Coming Soon Screen - Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyComingSoonScreen extends StatefulWidget {
  const WarrantyComingSoonScreen({super.key});

  @override
  State<WarrantyComingSoonScreen> createState() => _WarrantyComingSoonScreenState();
}

class _WarrantyComingSoonScreenState extends State<WarrantyComingSoonScreen>
    with TickerProviderStateMixin {
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🎬 Animation Controllers
  // ═══════════════════════════════════════════════════════════════════════
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<Offset> _titleSlideAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isRTL => context.locale.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setSystemUIOverlay();
  }

  void _initAnimations() {
    // Main Controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Pulse Controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Float Controller
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Rotate Controller
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Shimmer Controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Fade Animation
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Scale Animation
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
      ),
    );

    // Icon Scale
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Icon Fade
    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Pulse
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Float
    _floatAnimation = Tween<double>(begin: -12.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // Content Fade
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Content Slide
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    // Title Slide
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    ));

    // Start animations
    _mainController.forward();
  }

  void _setSystemUIOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor:
              _isDark ? AppTheme.darkBackground : AppTheme.white,
          systemNavigationBarIconBrightness:
              _isDark ? Brightness.light : Brightness.dark,
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUIOverlay();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: _isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppTheme.background(_isDark),
        appBar: _buildAppBar(),
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: _isDark
                ? AppTheme.darkBackgroundGradient
                : AppTheme.lightBackgroundGradient,
          ),
          child: Stack(
            children: [
              // Background Effects
              _buildBackgroundEffects(size),

              // Floating Particles
              _buildFloatingParticles(size),

              // Decorative Lines
              _buildDecorativeLines(size),

              // Orbiting Rings
              _buildOrbitingRings(size),

              // Main Content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.spacing(context, 24),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: ResponsiveUtils.spacing(context, 40)),
                        _buildIconSection(size),
                        SizedBox(height: ResponsiveUtils.spacing(context, 40)),
                        _buildTitleSection(),
                        SizedBox(height: ResponsiveUtils.spacing(context, 24)),
                        _buildDescriptionSection(),
                        SizedBox(height: ResponsiveUtils.spacing(context, 48)),
                        _buildProgressSection(size),
                        SizedBox(height: ResponsiveUtils.spacing(context, 48)),
                        _buildNotifyButton(),
                        SizedBox(height: ResponsiveUtils.spacing(context, 40)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔝 App Bar
  // ═══════════════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              'warranty_registration'.tr(),
              style: TextStyle(
                color: AppTheme.text(_isDark),
                fontSize: ResponsiveUtils.font(context, 18),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          );
        },
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, // ✅ This removes the back button
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Background Effects
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundEffects(Size size) {
    return Stack(
      children: [
        // Top Right Glow
        Positioned(
          top: -size.height * 0.1,
          right: -size.width * 0.3,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primary.withOpacity(_isDark ? 0.3 : 0.15),
                        AppTheme.primary.withOpacity(_isDark ? 0.1 : 0.05),
                        AppTheme.primary.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Left Glow
        Positioned(
          bottom: -size.height * 0.15,
          left: -size.width * 0.4,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 2 - _pulseAnimation.value,
                child: Container(
                  width: size.width * 0.9,
                  height: size.width * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.secondary.withOpacity(_isDark ? 0.2 : 0.1),
                        AppTheme.secondary.withOpacity(_isDark ? 0.08 : 0.04),
                        AppTheme.secondary.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Center Accent Glow
        Positioned(
          top: size.height * 0.3,
          left: size.width * 0.5 - size.width * 0.25,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accent.withOpacity(
                          (_isDark ? 0.12 : 0.08) * _pulseAnimation.value),
                      AppTheme.accent.withOpacity(0),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✨ Floating Particles
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildFloatingParticles(Size size) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final random = math.Random(index);
            final x = random.nextDouble() * size.width;
            final y = random.nextDouble() * size.height;
            final particleSize = 2 + random.nextDouble() * 6;
            final delay = random.nextDouble();
            final color = index % 3 == 0
                ? AppTheme.primary
                : index % 3 == 1
                    ? AppTheme.secondary
                    : AppTheme.accent;

            return Positioned(
              left: x,
              top: y + (_floatAnimation.value * (index.isEven ? 1 : -1) * delay),
              child: Container(
                width: particleSize,
                height: particleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(_isDark ? 0.7 : 0.5),
                      color.withOpacity(0),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📐 Decorative Lines
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDecorativeLines(Size size) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _LinesPainter(isDark: _isDark),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Orbiting Rings
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildOrbitingRings(Size size) {
    return Positioned(
      top: size.height * 0.15,
      left: size.width * 0.5 - ResponsiveUtils.size(context, 100),
      child: AnimatedBuilder(
        animation: _rotateController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateController.value * 2 * math.pi,
            child: Container(
              width: ResponsiveUtils.size(context, 200),
              height: ResponsiveUtils.size(context, 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withOpacity(_isDark ? 0.08 : 0.05),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Orbiting Dot 1
                  Positioned(
                    top: 0,
                    left: ResponsiveUtils.size(context, 100) - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Orbiting Dot 2
                  Positioned(
                    bottom: 0,
                    left: ResponsiveUtils.size(context, 100) - 3,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.secondaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Icon Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildIconSection(Size size) {
    final iconContainerSize = ResponsiveUtils.size(context, 140);

    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconScaleAnimation.value,
          child: Opacity(
            opacity: _iconFadeAnimation.value,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: _buildMainIcon(iconContainerSize),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainIcon(double containerSize) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: containerSize * _pulseAnimation.value,
          height: containerSize * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withOpacity(_isDark ? 0.2 : 0.12),
                AppTheme.primaryDark.withOpacity(_isDark ? 0.1 : 0.06),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(_isDark ? 0.4 : 0.25),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
            border: Border.all(
              color: AppTheme.primary.withOpacity(_isDark ? 0.3 : 0.2),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Spinning Ring
              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateController.value * 2 * math.pi,
                    child: Container(
                      width: containerSize * 0.85,
                      height: containerSize * 0.85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppTheme.primary.withOpacity(0),
                            AppTheme.primary.withOpacity(0.6),
                            AppTheme.secondary.withOpacity(0.6),
                            AppTheme.primary.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Inner Container with Icon
              Container(
                width: containerSize * 0.65,
                height: containerSize * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isDark
                        ? [
                            AppTheme.darkCard.withOpacity(0.98),
                            AppTheme.darkBackground,
                          ]
                        : [
                            AppTheme.white,
                            AppTheme.lightBackground,
                          ],
                  ),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.25),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => AppTheme.primaryGradient
                        .createShader(bounds),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: AppTheme.white,
                      size: ResponsiveUtils.icon(context, 48),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Title Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTitleSection() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return SlideTransition(
          position: _titleSlideAnimation,
          child: Opacity(
            opacity: _contentFadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Coming Soon Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 20),
              vertical: ResponsiveUtils.spacing(context, 8),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accent.withOpacity(_isDark ? 0.2 : 0.15),
                  AppTheme.accent.withOpacity(_isDark ? 0.08 : 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 20),
              ),
              border: Border.all(
                color: AppTheme.accent.withOpacity(_isDark ? 0.3 : 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 10)),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 20)),

          // Main Title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppTheme.text(_isDark),
                AppTheme.text(_isDark).withOpacity(0.8),
              ],
            ).createShader(bounds),
            child: Text(
              'Warranty Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 28),
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📄 Description Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDescriptionSection() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return SlideTransition(
          position: _contentSlideAnimation,
          child: Opacity(
            opacity: _contentFadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Text(
            'We are working on the new warranty registration system',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 16),
              color: AppTheme.textSecondary(_isDark),
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),

          SizedBox(height: ResponsiveUtils.spacing(context, 12)),

          Text(
            'It will be available soon with a modern and easy-to-use design',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 14),
              color: AppTheme.textSecondary(_isDark).withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⏳ Progress Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildProgressSection(Size size) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentFadeAnimation.value,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 24)),
        decoration: BoxDecoration(
          color: AppTheme.card(_isDark).withOpacity(_isDark ? 0.6 : 0.8),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.radius(context, 24),
          ),
          border: Border.all(
            color: AppTheme.primary.withOpacity(_isDark ? 0.15 : 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(_isDark ? 0.1 : 0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text(_isDark),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing(context, 12),
                    vertical: ResponsiveUtils.spacing(context, 4),
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius(context, 12),
                    ),
                  ),
                  child: Text(
                    '75%',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 12),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.spacing(context, 16)),

            // Progress Bar
            _buildAnimatedProgressBar(),

            SizedBox(height: ResponsiveUtils.spacing(context, 20)),

            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoadingDots(),
                SizedBox(width: ResponsiveUtils.spacing(context, 12)),
                Text(
                  'Under Development...',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 13),
                    color: AppTheme.textSecondary(_isDark),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressBar() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: ResponsiveUtils.height(context, 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(_isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 4),
            ),
          ),
          child: Stack(
            children: [
              // Progress Fill
              FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius(context, 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // Shimmer Effect
              Positioned(
                left: (_shimmerController.value * ResponsiveUtils.width(context, 250)) - 50,
                child: Container(
                  width: 50,
                  height: ResponsiveUtils.height(context, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.white.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius(context, 4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingDots() {
    return SizedBox(
      width: 32,
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final delay = index * 0.3;
              final animValue = ((_pulseController.value + delay) % 1.0);
              final scale = 0.5 + (animValue < 0.5 ? animValue : 1 - animValue);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Notify Button
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildNotifyButton() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentFadeAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You will be notified when the feature is launched',
              ),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.spacing(context, 16),
          ),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: AppTheme.white,
                size: ResponsiveUtils.icon(context, 22),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 12)),
              Text(
                'Notify Me on Launch',
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                  letterSpacing: 0.5,
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
// 🎨 Lines Painter
// ═══════════════════════════════════════════════════════════════════════════
class _LinesPainter extends CustomPainter {
  final bool isDark;

  _LinesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(isDark ? 0.04 : 0.025)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width + size.height; i += 60) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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