import 'dart:math' as math;

import 'package:app/data/constants/assets.dart';
import 'package:app/functions/my_navigation.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/persentation/screens/layout/layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart' hide AnimatedBuilder;

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 ألوان الهوية البصرية للتطبيق
// ═══════════════════════════════════════════════════════════════════════════
class AppBrandColors {
  static const Color background = Color(0xFF0B0B12);
  static const Color surfaceDark = Color(0xFF181818);
  static const Color purple = Color(0xFF6842E2);
  static const Color purpleLight = Color(0xFF9B5CFF);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color white = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B5CF6)],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleLight, purple, lightGreen],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🚀 شاشة البداية (شاشة واحدة بحركة احترافية)
// ═══════════════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.userModel,
    this.isLoggedIn = false,
  });

  final UserModel? userModel;
  final bool isLoggedIn;

  // ─────────────────────────────────────────────────────────────────────────
  // 🔧 Splash Management Methods
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> markSplashAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('splash_shown', true);
  }

  static Future<void> resetSplashState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('splash_shown');
  }

  static Future<bool> shouldShowSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownSplash = prefs.getBool('splash_shown') ?? false;
    return !hasShownSplash;
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // 🎬 حركة الدخول الرئيسية (تشغّل التسلسل ثم الانتقال)
  late final AnimationController _introController;
  // 🔁 حركة مستمرة (توهّج + دوران الجزيئات)
  late final AnimationController _ambientController;

  // Intro animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringProgress;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _barProgress;
  late final Animation<double> _bgReveal;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _setSystemUIStyle();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _bgReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.05, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.05, 0.40, curve: Curves.easeOut),
    );

    _ringProgress = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.15, 0.70, curve: Curves.easeInOutCubic),
    );

    _titleOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );

    _titleSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.45, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.60, 0.88, curve: Curves.easeOut),
    );

    _barProgress = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.70, 1.0, curve: Curves.easeInOut),
    );

    _introController.forward();
    _introController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  void _setSystemUIStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppBrandColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _navigateToNextScreen() {
    if (_navigated) return;
    _navigated = true;

    HapticFeedback.lightImpact();
    SplashScreen.markSplashAsShown();

    MyNavigator.navigateOffAll(
      context,
      InitialScreen(
        userModel: widget.userModel,
        isLoggedIn: widget.isLoggedIn,
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoBox = math.min(size.width * 0.30, 150.0);
    final ringBox = logoBox * 1.7;

    return Scaffold(
      backgroundColor: AppBrandColors.background,
      body: GestureDetector(
        onTap: _navigateToNextScreen, // اضغط للتخطي
        child: AnimatedBuilder(
          animation: Listenable.merge([_introController, _ambientController]),
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // 🌌 خلفية متدرّجة متحركة
                _buildBackground(size),

                // ✨ جزيئات دوّارة خفيفة (بدون blur)
                Opacity(
                  opacity: _logoOpacity.value,
                  child: CustomPaint(
                    size: Size(size.width, size.height),
                    painter: _ParticlesPainter(
                      progress: _ambientController.value,
                    ),
                  ),
                ),

                // المحتوى الرئيسي
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 5),

                    // 🔵 اللوجو + الحلقات
                    _buildLogo(logoBox, ringBox),

                    SizedBox(height: size.height * 0.045),

                    // ✦ اسم التطبيق
                    _buildTitle(size),

                    const SizedBox(height: 10),

                    // العبارة التعريفية
                    _buildTagline(),

                    const Spacer(flex: 5),

                    // ▂ شريط التحميل
                    _buildProgressBar(size),

                    const SizedBox(height: 18),

                    Opacity(
                      opacity: _taglineOpacity.value * 0.6,
                      child: const Text(
                        'Diamond Engine Shields',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          letterSpacing: 3,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🌌 الخلفية
  Widget _buildBackground(Size size) {
    // مركز التوهّج يتحرك بلطف
    final t = _ambientController.value;
    final dx = math.sin(t * 2 * math.pi) * 0.3;
    final dy = math.cos(t * 2 * math.pi) * 0.25;

    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(dx, -0.35 + dy),
            radius: 1.25,
            colors: [
              AppBrandColors.purple.withOpacity(0.35 * _bgReveal.value),
              AppBrandColors.background,
            ],
            stops: const [0.0, 0.75],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-dx, 0.6 - dy),
              radius: 1.1,
              colors: [
                AppBrandColors.lightGreen.withOpacity(0.12 * _bgReveal.value),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔵 اللوجو والحلقات
  Widget _buildLogo(double logoBox, double ringBox) {
    final pulse = 1 + math.sin(_ambientController.value * 2 * math.pi) * 0.04;

    return SizedBox(
      width: ringBox,
      height: ringBox,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // حلقة خارجية تُرسم تدريجياً + تدور
          Transform.rotate(
            angle: _ambientController.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(ringBox, ringBox),
              painter: _RingPainter(progress: _ringProgress.value),
            ),
          ),

          // هالة توهّج (BoxShadow رخيص بدل الـ blur)
          Transform.scale(
            scale: _logoScale.value * pulse,
            child: Opacity(
              opacity: _logoOpacity.value,
              child: Container(
                width: logoBox,
                height: logoBox,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppBrandColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppBrandColors.purple.withOpacity(0.55),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: AppBrandColors.lightGreen.withOpacity(0.20),
                      blurRadius: 60,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(logoBox * 0.26),
                child: SvgPicture.asset(
                  Assets.logoo,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✦ العنوان
  Widget _buildTitle(Size size) {
    return Opacity(
      opacity: _titleOpacity.value,
      child: Transform.translate(
        offset: Offset(0, _titleSlide.value),
        child: ShaderMask(
          shaderCallback: (bounds) =>
              AppBrandColors.brandGradient.createShader(bounds),
          child: Text(
            'DES',
            style: TextStyle(
              fontSize: math.min(size.width * 0.16, 64),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 6,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  // العبارة التعريفية
  Widget _buildTagline() {
    return Opacity(
      opacity: _taglineOpacity.value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: const Text(
          'Diamond Engine Shields',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // ▂ شريط التحميل
  Widget _buildProgressBar(Size size) {
    final width = size.width * 0.5;
    return Opacity(
      opacity: _titleOpacity.value,
      child: Container(
        width: width,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: _barProgress.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppBrandColors.brandGradient,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppBrandColors.purple.withOpacity(0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 رسّام الحلقة (تُرسم تدريجياً)
// ═══════════════════════════════════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // مسار خافت كامل
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.06);
    canvas.drawCircle(center, radius, bgPaint);

    // القوس المتدرّج
    final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          AppBrandColors.lightGreen,
          AppBrandColors.purple,
          AppBrandColors.purpleLight,
          AppBrandColors.lightGreen,
        ],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
// ✨ رسّام الجزيئات (خفيف بدون blur)
// ═══════════════════════════════════════════════════════════════════════════
class _ParticlesPainter extends CustomPainter {
  final double progress;

  _ParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    const count = 14;

    for (int i = 0; i < count; i++) {
      final seed = i / count;
      final angle = seed * 2 * math.pi + progress * 2 * math.pi;
      final orbit = size.width * (0.28 + (i % 3) * 0.10);
      final wobble = math.sin((progress * 2 * math.pi) + i) * 6;

      final dx = center.dx + math.cos(angle) * (orbit + wobble);
      final dy = center.dy + math.sin(angle) * (orbit * 0.7 + wobble);

      final r = 1.5 + (i % 3) * 1.0;
      final paint = Paint()
        ..color = (i.isEven
                ? AppBrandColors.purpleLight
                : AppBrandColors.lightGreen)
            .withOpacity(0.35 + (i % 3) * 0.15);

      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏠 شاشة التوجيه الأولية
// ═══════════════════════════════════════════════════════════════════════════
class InitialScreen extends StatefulWidget {
  const InitialScreen({
    super.key,
    required this.userModel,
    this.isLoggedIn = false,
  });

  final UserModel? userModel;
  final bool isLoggedIn;

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transitionController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildDestinationScreen(),
    );
  }

  Widget _buildDestinationScreen() {
    // 🔐 التوجيه يعتمد على حالة الجلسة مش على وجود userModel،
    // عشان خطأ شبكة مؤقت مايطردش المستخدم على Login.
    if (widget.isLoggedIn || widget.userModel != null) {
      return const LayoutScreen();
    } else {
      return const LoginScreen();
    }
  }
}
