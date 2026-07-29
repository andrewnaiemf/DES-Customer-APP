import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme - Modern Brand Colors + Ramadan Edition
// ═══════════════════════════════════════════════════════════════════════════
class AppColors {
  // Primary Colors
  static const Color primaryPurple = Color(0xFF6842E2);
  static const Color secondaryPurple = Color(0xFF8B6CEF);
  static const Color lightPurple = Color(0xFF5234B5);
  static const Color purpleLight = Color(0xFFF3EBFF);
  static const Color purpleMedium = Color(0xFFE8D9FF);

  // Background Colors
  static const Color darkBackground = Color(0xFF15172A);
  static const Color darkGray = Color(0xFF14141F);
  static const Color darkerBackground = Color(0xFF0A0A12);

  // Accent Colors
  static const Color accentGreen = Color(0xFF28E6C5);
  static const Color accentCyan = Color(0xFF00D9FF);

  // 🌙 Ramadan Special Colors - Green Theme
  static const Color ramadanGreen = Color(0xFF28E6C5); // اللون الأساسي
  static const Color ramadanGreenLight = Color(0xFF28E6C5); // أفتح
  static const Color ramadanGreenDark = Color(0xFF28E6C5); // أغمق
  static const Color starGlow = Color(0xFFE0F7F3); // توهج أخضر فاتح جداً

  // Text Colors
  static const Color grayText = Color(0xFFA0A3BB);
  static const Color white = Color(0xFFFFFFFF);

  // Status Colors
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, secondaryPurple, lightPurple],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2A2D3E),
      darkBackground,
      darkerBackground,
    ],
  );

  // 🌙 Ramadan Green Gradient
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ramadanGreenLight, ramadanGreen, ramadanGreenDark],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌙 Ramadan Splash Screen
// ═══════════════════════════════════════════════════════════════════════════
class RamadanSplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const RamadanSplashScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<RamadanSplashScreen> createState() => _RamadanSplashScreenState();
}

class _RamadanSplashScreenState extends State<RamadanSplashScreen>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════
  // Animation Controllers
  // ═══════════════════════════════════════════════════════════════════════
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final AnimationController _particleController;
  late final AnimationController _rotationController;
  late final AnimationController _fadeOutController;
  late final AnimationController _shimmerController;
  late final AnimationController _waveController;
  late final AnimationController _lanternController;
  late final AnimationController _starsController;
  late final AnimationController _crescentController;

  // Animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textSlide;
  late final Animation<double> _textOpacity;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _loadingOpacity;
  late final Animation<double> _fadeOut;
  late final Animation<double> _shimmer;
  late final Animation<double> _wave;
  late final Animation<double> _lanternSwing;
  late final Animation<double> _crescentScale;
  late final Animation<double> _crescentGlow;
  late final Animation<double> _crescentRotate;

  // Cached Data
  late final List<_Particle> _particles;
  late final List<_Star> _stars;
  late final List<_GreenParticle> _greenParticles;

  @override
  void initState() {
    super.initState();
    _initializeCachedData();
    _initAnimations();
    _startSequence();
    _setSystemUI();
  }

  void _initializeCachedData() {
    final random = math.Random(42);

    // Regular particles
    _particles = List.generate(
        50,
            (index) => _Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 2 + random.nextDouble() * 4,
          speed: 0.2 + random.nextDouble() * 0.5,
          opacity: 0.3 + random.nextDouble() * 0.5,
          delay: random.nextDouble(),
        ));

    // ⭐ Stars for Ramadan - خفيفة
    _stars = List.generate(
        35,
            (index) => _Star(
          x: random.nextDouble(),
          y: random.nextDouble() * 0.5,
          size: 1.2 + random.nextDouble() * 2,
          twinkleSpeed: 0.5 + random.nextDouble() * 0.5,
          delay: random.nextDouble(),
        ));

    // ✨ Green particles
    _greenParticles = List.generate(
        25,
            (index) => _GreenParticle(
          x: random.nextDouble(),
          startY: 1.0 + random.nextDouble() * 0.2,
          size: 2 + random.nextDouble() * 4,
          speed: 0.2 + random.nextDouble() * 0.3,
          delay: random.nextDouble(),
          swayAmount: 15 + random.nextDouble() * 20,
        ));
  }

  void _initAnimations() {
    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Pulse controller for glow effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    // Rotation for loading
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Fade out controller
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // 🏮 Lantern swing
    _lanternController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // ⭐ Stars twinkle
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // 🌙 Crescent animation
    _crescentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Text animations
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Loading animation
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Fade out
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeInOut,
      ),
    );

    // Shimmer
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    // Wave
    _wave = Tween<double>(begin: 0.0, end: 1.0).animate(_waveController);

    // 🏮 Lantern swing animation
    _lanternSwing = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(
        parent: _lanternController,
        curve: Curves.easeInOut,
      ),
    );

    // 🌙 Crescent animations
    _crescentScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _crescentController,
        curve: Curves.elasticOut,
      ),
    );

    _crescentGlow = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _crescentRotate = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _crescentController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mainController.forward();
    _crescentController.forward();

    await Future.delayed(const Duration(milliseconds: 3500));
    await _fadeOutController.forward();

    widget.onFinish();
  }

  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.darkerBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _rotationController.dispose();
    _fadeOutController.dispose();
    _shimmerController.dispose();
    _waveController.dispose();
    _lanternController.dispose();
    _starsController.dispose();
    _crescentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: AnimatedBuilder(
        animation: _fadeOut,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeOut,
            child: child,
          );
        },
        child: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Stack(
            children: [
              // Background Elements
              _buildStarsLayer(size),
              _buildBackgroundWaves(size),
              _buildFloatingParticles(size),
              _buildGreenParticles(size),
              _buildGlowingOrbs(size),
              _buildGridPattern(size),

              // 🌙 Ramadan Decorations
              _buildTopRamadanDecoration(size),
              _buildBottomRamadanDecoration(size),

              // Content
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _buildMainCrescentLogo(size),
                    const SizedBox(height: 20),
                    _buildLanternRow(size),
                    const SizedBox(height: 30),
                    _buildTextSection(size),
                    const Spacer(flex: 2),
                    _buildLoadingSection(size),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🌙 Main Crescent Logo - الهلال الأخضر الرئيسي
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildMainCrescentLogo(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoScale,
        _logoOpacity,
        _pulseAnimation,
        _crescentGlow,
        _crescentRotate,
        _shimmer,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Transform.rotate(
              angle: _crescentRotate.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Ring 1 - Green
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.ramadanGreen.withOpacity(0.0),
                            AppColors.ramadanGreen.withOpacity(0.1),
                            AppColors.ramadanGreen.withOpacity(0.0),
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Outer Glow Ring 2 - Purple
                  Transform.scale(
                    scale: _crescentGlow.value,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryPurple.withOpacity(0.0),
                            AppColors.primaryPurple.withOpacity(0.15),
                            AppColors.primaryPurple.withOpacity(0.0),
                          ],
                          stops: const [0.5, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Middle Decorative Ring
                  Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.ramadanGreen.withOpacity(0.2),
                          AppColors.primaryPurple.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.ramadanGreen.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                  ),

                  // Inner Ring
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.ramadanGreen.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),

                  // Main Crescent Container with Shimmer
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        colors: [
                          AppColors.ramadanGreen.withOpacity(0.3),
                          AppColors.ramadanGreen.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ramadanGreen
                              .withOpacity(0.4 * _crescentGlow.value),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.2),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shimmer Effect Layer
                        ClipOval(
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                stops: [
                                  (_shimmer.value - 0.3).clamp(0.0, 1.0),
                                  _shimmer.value.clamp(0.0, 1.0),
                                  (_shimmer.value + 0.3).clamp(0.0, 1.0),
                                ],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: Container(
                              width: 130,
                              height: 130,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),

                        // 🌙 Main Green Crescent
                        CustomPaint(
                          size: const Size(85, 85),
                          painter: _MainCrescentPainter(
                            glowValue: _crescentGlow.value,
                          ),
                        ),

                        // ⭐ Green Star beside crescent
                        Positioned(
                          top: 22,
                          right: 28,
                          child: _buildGlowingStar(18),
                        ),
                      ],
                    ),
                  ),

                  // Orbiting Elements
                  ...List.generate(4, (index) {
                    return AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        final angle = (_rotationController.value * 2 * math.pi) +
                            (index * 2 * math.pi / 4);
                        const radius = 85.0;

                        Widget orbitElement;
                        if (index == 0) {
                          // Green star
                          orbitElement = Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: AppColors.ramadanGreen,
                          );
                        } else if (index == 2) {
                          // Cyan dot
                          orbitElement = Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentCyan,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentCyan.withOpacity(0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Purple/Light dots
                          orbitElement = Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 1
                                  ? AppColors.lightPurple
                                  : AppColors.ramadanGreenLight,
                              boxShadow: [
                                BoxShadow(
                                  color: (index == 1
                                      ? AppColors.lightPurple
                                      : AppColors.ramadanGreenLight)
                                      .withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          );
                        }

                        return Transform.translate(
                          offset: Offset(
                            math.cos(angle) * radius,
                            math.sin(angle) * radius,
                          ),
                          child: orbitElement,
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowingStar(double size) {
    return AnimatedBuilder(
      animation: _crescentGlow,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color:
                AppColors.ramadanGreen.withOpacity(0.8 * _crescentGlow.value),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.star_rounded,
            color: AppColors.ramadanGreen,
            size: size,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⭐ Stars Layer
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildStarsLayer(Size size) {
    return AnimatedBuilder(
      animation: _starsController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _StarsPainter(
            stars: _stars,
            animation: _starsController.value,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✨ Green Particles
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildGreenParticles(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _GreenParticlesPainter(
            particles: _greenParticles,
            animation: _particleController.value,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏮 Lantern Row
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildLanternRow(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoOpacity, _lanternSwing]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLantern(30, -0.5, AppColors.primaryPurple),
              const SizedBox(width: 18),
              _buildLantern(40, 0, AppColors.ramadanGreen),
              const SizedBox(width: 18),
              _buildLantern(30, 0.5, AppColors.accentCyan),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLantern(double height, double phaseOffset, Color color) {
    return AnimatedBuilder(
      animation: _lanternController,
      builder: (context, child) {
        final swing = math.sin(
            (_lanternController.value * 2 * math.pi) + (phaseOffset * 2)) *
            0.08;
        return Transform.rotate(
          angle: swing,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              // Chain
              Container(
                width: 2,
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      color.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // Lantern Body
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow
                  AnimatedBuilder(
                    animation: _crescentGlow,
                    builder: (context, child) {
                      return Container(
                        width: height * 1.5 * _crescentGlow.value,
                        height: height * 1.5 * _crescentGlow.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              color.withOpacity(0.5),
                              color.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Lantern
                  CustomPaint(
                    size: Size(height * 0.6, height),
                    painter: _LanternPainter(
                      color: color,
                      glowValue: _crescentGlow.value,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎀 Top Ramadan Decoration
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTopRamadanDecoration(Size size) {
    return AnimatedBuilder(
      animation: _logoOpacity,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: _logoOpacity.value * 0.7,
            child: CustomPaint(
              size: Size(size.width, 80),
              painter: _TopDecorationPainter(),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎀 Bottom Ramadan Decoration
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBottomRamadanDecoration(Size size) {
    return AnimatedBuilder(
      animation: _logoOpacity,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: _logoOpacity.value * 0.7,
            child: CustomPaint(
              size: Size(size.width, 80),
              painter: _BottomDecorationPainter(),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🌊 Background Waves
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundWaves(Size size) {
    return AnimatedBuilder(
      animation: _wave,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _WavePainter(
            animation: _wave.value,
            color1: AppColors.primaryPurple.withOpacity(0.1),
            color2: AppColors.secondaryPurple.withOpacity(0.05),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✨ Floating Particles
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildFloatingParticles(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _ParticlePainter(
            particles: _particles,
            animation: _particleController.value,
            primaryColor: AppColors.primaryPurple,
            secondaryColor: AppColors.ramadanGreen,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 💫 Glowing Orbs
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildGlowingOrbs(Size size) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Top Right Orb - Green
            Positioned(
              top: -size.height * 0.08,
              right: -size.width * 0.15,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.ramadanGreen.withOpacity(0.25),
                        AppColors.ramadanGreen.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Center Purple Orb
            Positioned(
              top: size.height * 0.25,
              left: -size.width * 0.1,
              child: Transform.scale(
                scale: _crescentGlow.value,
                child: Container(
                  width: size.width * 0.35,
                  height: size.width * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryPurple.withOpacity(0.2),
                        AppColors.primaryPurple.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Left Orb - Cyan
            Positioned(
              bottom: -size.height * 0.12,
              left: -size.width * 0.25,
              child: Transform.scale(
                scale: 2.15 - _pulseAnimation.value,
                child: Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentCyan.withOpacity(0.2),
                        AppColors.accentCyan.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📐 Grid Pattern
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildGridPattern(Size size) {
    return Opacity(
      opacity: 0.03,
      child: CustomPaint(
        size: size,
        painter: _GridPainter(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Text Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTextSection(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_textSlide, _textOpacity]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // 🌙 Ramadan Kareem Text - Green Gradient
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [
                  AppColors.ramadanGreenLight,
                  AppColors.ramadanGreen,
                  AppColors.ramadanGreenDark,
                  AppColors.ramadanGreen,
                  AppColors.ramadanGreenLight,
                ],
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ).createShader(bounds);
            },
            child: const Text(
              'رمضان كريم',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Ramadan Kareem English
          Text(
            'Ramadan Kareem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.lightPurple.withOpacity(0.9),
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 20),

          // Decorative Line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorativeLine(isLeft: true),
              const SizedBox(width: 12),
              _buildGlowingStar(14),
              const SizedBox(width: 12),
              _buildDecorativeLine(isLeft: false),
            ],
          ),

          const SizedBox(height: 20),

          // Blessing Text
          Text(
            'تقبل الله منا ومنكم',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeLine({required bool isLeft}) {
    return Container(
      width: 50,
      height: 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            AppColors.ramadanGreen.withOpacity(0.8),
            AppColors.ramadanGreen.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⏳ Loading Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildLoadingSection(Size size) {
    return AnimatedBuilder(
      animation: _loadingOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _loadingOpacity.value,
          child: child,
        );
      },
      child: Column(
        children: [
          // Modern Loading Indicator
          SizedBox(
            width: 45,
            height: 45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(45, 45),
                        painter: _ModernLoadingPainter(
                          progress: _rotationController.value,
                          primaryColor: AppColors.ramadanGreen,
                          secondaryColor: AppColors.primaryPurple,
                        ),
                      ),
                    );
                  },
                ),

                // Center crescent
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value * 0.85,
                      child: CustomPaint(
                        size: const Size(18, 18),
                        painter: _MiniCrescentPainter(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Loading Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'جاري التحميل',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grayText,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              _buildAnimatedDots(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final progress = (_rotationController.value + delay) % 1.0;
            final opacity = (math.sin(progress * math.pi)).clamp(0.3, 1.0);

            return Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Opacity(
                opacity: opacity,
                child: const Text(
                  '.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ramadanGreen,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Data Classes
// ═══════════════════════════════════════════════════════════════════════════

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double delay;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.delay,
  });
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  final double delay;

  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.delay,
  });
}

class _GreenParticle {
  final double x;
  final double startY;
  final double size;
  final double speed;
  final double delay;
  final double swayAmount;

  const _GreenParticle({
    required this.x,
    required this.startY,
    required this.size,
    required this.speed,
    required this.delay,
    required this.swayAmount,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Custom Painters
// ═══════════════════════════════════════════════════════════════════════════

// 🌙 Main Green Crescent Painter
class _MainCrescentPainter extends CustomPainter {
  final double glowValue;

  _MainCrescentPainter({required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer strong glow
    final outerGlowPaint = Paint()
      ..color = AppColors.ramadanGreen.withOpacity(0.4 * glowValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius, outerGlowPaint);

    // Inner glow
    final innerGlowPaint = Paint()
      ..color = AppColors.ramadanGreen.withOpacity(0.3 * glowValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius * 0.9, innerGlowPaint);

    // Moon gradient fill
    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.ramadanGreenLight,
          AppColors.ramadanGreen,
          AppColors.ramadanGreenDark,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, moonPaint);

    // Inner shadow/cutout for crescent shape
    final cutoutPaint = Paint()
      ..color = AppColors.darkerBackground
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.08),
      radius * 0.72,
      cutoutPaint,
    );

    // Highlight/shine effect
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.center,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width * 0.6, size.height * 0.6));

    canvas.drawCircle(center, radius, shinePaint);

    // Edge glow
    final edgeGlowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        colors: [
          Colors.transparent,
          AppColors.ramadanGreenLight.withOpacity(0.3),
        ],
        stops: const [0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, edgeGlowPaint);
  }

  @override
  bool shouldRepaint(covariant _MainCrescentPainter oldDelegate) {
    return oldDelegate.glowValue != glowValue;
  }
}

// 🌙 Mini Green Crescent for Loading
class _MiniCrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Moon
    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.ramadanGreenLight,
          AppColors.ramadanGreen,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, moonPaint);

    // Cutout
    final cutoutPaint = Paint()
      ..color = AppColors.darkerBackground
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.1),
      radius * 0.7,
      cutoutPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarsPainter extends CustomPainter {
  final List<_Star> stars;
  final double animation;

  _StarsPainter({required this.stars, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = ((animation * star.twinkleSpeed + star.delay) % 1.0);
      final opacity = (math.sin(twinkle * math.pi * 2) + 1) / 2 * 0.4 + 0.1;

      // Glow
      final glowPaint = Paint()
        ..color = AppColors.starGlow.withOpacity(opacity * 0.15)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.8);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * 1.2,
        glowPaint,
      );

      // Core
      final corePaint = Paint()..color = Colors.white.withOpacity(opacity * 0.3);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * 0.4,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _GreenParticlesPainter extends CustomPainter {
  final List<_GreenParticle> particles;
  final double animation;

  _GreenParticlesPainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final progress = (animation + particle.delay) % 1.0;
      final y = (particle.startY - progress * particle.speed) * size.height;

      if (y < 0 || y > size.height) continue;

      final sway = math.sin(progress * math.pi * 4) * particle.swayAmount;
      final x = particle.x * size.width + sway;

      final fadeIn = progress < 0.1 ? progress * 10 : 1.0;
      final fadeOut = progress > 0.9 ? (1 - progress) * 10 : 1.0;
      final opacity = fadeIn * fadeOut * 0.7;

      // Glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.ramadanGreen.withOpacity(opacity),
            AppColors.ramadanGreen.withOpacity(opacity * 0.3),
            Colors.transparent,
          ],
        ).createShader(
            Rect.fromCircle(center: Offset(x, y), radius: particle.size * 2));

      canvas.drawCircle(Offset(x, y), particle.size * 2, glowPaint);

      // Core
      final corePaint = Paint()
        ..color = AppColors.ramadanGreenLight.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), particle.size * 0.4, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GreenParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _LanternPainter extends CustomPainter {
  final Color color;
  final double glowValue;

  _LanternPainter({required this.color, required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Top cap
    final topCapPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.9),
          color,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.15))
      ..style = PaintingStyle.fill;

    final topCapPath = Path()
      ..moveTo(centerX - 8, 0)
      ..lineTo(centerX + 8, 0)
      ..lineTo(centerX + 10, size.height * 0.12)
      ..lineTo(centerX - 10, size.height * 0.12)
      ..close();

    canvas.drawPath(topCapPath, topCapPaint);

    // Lantern body
    final bodyGradient = RadialGradient(
      center: Alignment.center,
      colors: [
        Color.lerp(color, Colors.white, glowValue * 0.3)!,
        color,
        color.withOpacity(0.8),
      ],
    );

    final bodyPaint = Paint()
      ..shader = bodyGradient.createShader(
        Rect.fromLTWH(0, size.height * 0.12, size.width, size.height * 0.73),
      )
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(centerX - 10, size.height * 0.12)
      ..lineTo(centerX - 18, size.height * 0.35)
      ..lineTo(centerX - 18, size.height * 0.65)
      ..lineTo(centerX - 10, size.height * 0.85)
      ..lineTo(centerX + 10, size.height * 0.85)
      ..lineTo(centerX + 18, size.height * 0.65)
      ..lineTo(centerX + 18, size.height * 0.35)
      ..lineTo(centerX + 10, size.height * 0.12)
      ..close();

    canvas.drawPath(bodyPath, bodyPaint);

    // Decorative lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = -12; i <= 12; i += 8) {
      canvas.drawLine(
        Offset(centerX + i, size.height * 0.18),
        Offset(centerX + i, size.height * 0.80),
        linePaint,
      );
    }

    // Bottom cap
    final bottomCapPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          color.withOpacity(0.8),
        ],
      ).createShader(Rect.fromLTWH(
          0, size.height * 0.85, size.width, size.height * 0.15))
      ..style = PaintingStyle.fill;

    final bottomCapPath = Path()
      ..moveTo(centerX - 10, size.height * 0.85)
      ..lineTo(centerX - 8, size.height)
      ..lineTo(centerX + 8, size.height)
      ..lineTo(centerX + 10, size.height * 0.85)
      ..close();

    canvas.drawPath(bottomCapPath, bottomCapPaint);
  }

  @override
  bool shouldRepaint(covariant _LanternPainter oldDelegate) {
    return oldDelegate.glowValue != glowValue || oldDelegate.color != color;
  }
}

class _TopDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.ramadanGreen.withOpacity(0.5),
          AppColors.ramadanGreen.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);

    for (double x = 0; x <= size.width; x += 15) {
      final y = 20 + math.sin((x / size.width) * math.pi * 8) * 12;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Decorative dots
    final dotPaint = Paint()
      ..color = AppColors.ramadanGreen.withOpacity(0.4);

    for (double x = 30; x < size.width; x += 60) {
      canvas.drawCircle(Offset(x, 28), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppColors.primaryPurple.withOpacity(0.4),
          AppColors.primaryPurple.withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 15) {
      final y =
          size.height - 20 - math.sin((x / size.width) * math.pi * 8) * 12;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  _ParticlePainter({
    required this.particles,
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final progress = (animation + particle.delay) % 1.0;

      final x = particle.x * size.width;
      final y = (particle.y - progress * particle.speed) % 1.0 * size.height;

      final paint = Paint()
        ..color = (i % 2 == 0 ? primaryColor : secondaryColor)
            .withOpacity(particle.opacity * (1 - progress * 0.5))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size / 2);

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _WavePainter extends CustomPainter {
  final double animation;
  final Color color1;
  final Color color2;

  _WavePainter({
    required this.animation,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    // First wave
    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.7 +
          math.sin((x / size.width * 4 * math.pi) + (animation * 2 * math.pi)) *
              30;
      path1.lineTo(x, y);
    }

    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    canvas.drawPath(path1, paint1);

    // Second wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.8 +
          math.sin((x / size.width * 3 * math.pi) - (animation * 2 * math.pi)) *
              25;
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withOpacity(0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ModernLoadingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  _ModernLoadingPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.darkGray.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: [
        primaryColor,
        secondaryColor,
        primaryColor.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ModernLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}