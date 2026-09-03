import 'dart:async';
import 'dart:ui';

import 'package:app/data/constants/assets.dart';
import 'package:app/functions/my_navigation.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/persentation/screens/layout/layout_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart' hide AnimatedBuilder;

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 ألوان الهوية البصرية للتطبيق
// ═══════════════════════════════════════════════════════════════════════════
class AppBrandColors {
  // Core Colors
  static const Color background = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF181818);
  static const Color surfaceLight = Color(0xFF282828);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color meshBlue = Color(0xFF1E3A8A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B5CF6)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, Color(0xFF10B981)],
  );

  static const LinearGradient storyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, lightGreen],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 📖 نموذج الستوري
// ═══════════════════════════════════════════════════════════════════════════
class StoryItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final String? imagePath;
  final Duration duration;

  const StoryItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    this.imagePath,
    this.duration = const Duration(seconds: 3),
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// 🚀 شاشة البداية بنظام الستوريز
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
  
  /// تعيين أن الـ Splash تم عرضه (يتم استدعاؤها بعد عرض الستوريز)
  static Future<void> markSplashAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('splash_shown', true);
  }

  /// إعادة تعيين حالة الـ Splash (يتم استدعاؤها عند Logout)
  static Future<void> resetSplashState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('splash_shown');
  }

  /// التحقق من ضرورة عرض الـ Splash
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
  // ─────────────────────────────────────────────────────────────────────────
  // 📊 Story Data
  // ─────────────────────────────────────────────────────────────────────────
  final List<StoryItem> _stories = const [
    StoryItem(
      title: 'splash_welcome_title',
      subtitle: 'Diamond Engine Shields',
      description: 'splash_welcome_description',
      icon: Icons.diamond_rounded,
      accentColor: AppBrandColors.purple,
      gradientColors: [Color(0xFF6842E2), Color(0xFF8B5CF6)],
    ),
    StoryItem(
      title: 'splash_smart_management_title',
      subtitle: 'Smart Management',
      description: 'splash_smart_management_description',
      icon: Icons.analytics_rounded,
      accentColor: AppBrandColors.lightGreen,
      gradientColors: [Color(0xFF28E6C5), Color(0xFF10B981)],
    ),
    StoryItem(
      title: 'splash_loyalty_title',
      subtitle: 'Rewards',
      description: 'splash_loyalty_description',
      icon: Icons.card_giftcard_rounded,
      accentColor: Color(0xFFFFD700),
      gradientColors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    ),
    StoryItem(
      title: 'splash_security_title',
      subtitle: 'High Security',
      description: 'splash_security_description',
      icon: Icons.security_rounded,
      accentColor: Color(0xFF3B82F6),
      gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    ),
    StoryItem(
      title: 'splash_get_started_title',
      subtitle: 'Get Started',
      description: 'splash_get_started_description',
      icon: Icons.rocket_launch_rounded,
      accentColor: AppBrandColors.purple,
      gradientColors: [Color(0xFF6842E2), Color(0xFF28E6C5)],
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 Animation Controllers
  // ─────────────────────────────────────────────────────────────────────────
  late final AnimationController _storyController;
  late final AnimationController _contentController;
  late final AnimationController _pulseController;
  late final AnimationController _orbController;
  late final AnimationController _transitionController;

  late final Animation<double> _contentFadeAnimation;
  late final Animation<Offset> _contentSlideAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _orbAnimation;
  late final Animation<double> _scaleAnimation;

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 State Variables
  // ─────────────────────────────────────────────────────────────────────────
  int _currentStoryIndex = 0;
  bool _isPaused = false;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _setSystemUIStyle();
    _initializeAnimations();
    _startStory();
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

  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 Initialize Animations
  // ─────────────────────────────────────────────────────────────────────────
  void _initializeAnimations() {
    // Story Progress Controller
    _storyController = AnimationController(
      duration: _stories[_currentStoryIndex].duration,
      vsync: this,
    );

    _storyController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNextStory();
      }
    });

    // Content Animation Controller
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 499),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    // Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1999),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Orb Animation
    _orbController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _orbAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );

    // Transition Animation
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 299),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _startStory() {
    _storyController.forward();
    _contentController.forward();
    _transitionController.forward();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎯 Story Navigation
  // ─────────────────────────────────────────────────────────────────────────
  void _goToNextStory() {
    if (_currentStoryIndex < _stories.length - 1) {
      setState(() {
        _isTransitioning = true;
        _currentStoryIndex++;
      });
      _resetAndPlayStory();
    } else {
      _navigateToNextScreen();
    }
  }

  void _goToPreviousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _isTransitioning = true;
        _currentStoryIndex--;
      });
      _resetAndPlayStory();
    } else {
      _storyController.reset();
      _storyController.forward();
    }
  }

  void _resetAndPlayStory() {
    _storyController.reset();
    _contentController.reset();
    _transitionController.reset();

    _storyController.duration = _stories[_currentStoryIndex].duration;

    Future.delayed(const Duration(milliseconds: 49), () {
      if (mounted) {
        setState(() => _isTransitioning = false);
        _storyController.forward();
        _contentController.forward();
        _transitionController.forward();
      }
    });
  }

  void _pauseStory() {
    if (!_isPaused) {
      setState(() => _isPaused = true);
      _storyController.stop();
      HapticFeedback.lightImpact();
    }
  }

  void _resumeStory() {
    if (_isPaused) {
      setState(() => _isPaused = false);
      _storyController.forward();
    }
  }

  void _skipToEnd() {
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    HapticFeedback.mediumImpact();
    
    // تعيين أن الـ Splash تم عرضه
    SplashScreen.markSplashAsShown();

    // 🔗 navigateOffAll بدل navigateTo: نشيل شاشة الـ onboarding من الستاك خالص
    // عشان InitialScreen (وجواها Layout) تبقى أول route. ده ضروري عشان توجيه
    // رابط الهوم (popUntil isFirst) ميرجّعش لشاشة التخطي تاني، وكمان أحسن UX
    // (مفيش رجوع بالـ back لشاشة الـ onboarding).
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
    _storyController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _orbController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Build Method
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final currentStory = _stories[_currentStoryIndex];
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    return Scaffold(
      backgroundColor: AppBrandColors.background,
      body: GestureDetector(
        // Tap Regions for navigation
        onTapDown: (details) {
          final tapPosition = details.globalPosition.dx;

          if (tapPosition < screenWidth * 0.3) {
            // Left tap - Previous story
            _goToPreviousStory();
          } else if (tapPosition > screenWidth * 0.7) {
            // Right tap - Next story
            _goToNextStory();
          }
        },
        // Long press to pause
        onLongPressStart: (_) => _pauseStory(),
        onLongPressEnd: (_) => _resumeStory(),
        child: Stack(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // 🌌 Animated Background
            // ═══════════════════════════════════════════════════════════════
            _buildAnimatedBackground(currentStory),

            // ═══════════════════════════════════════════════════════════════
            // ✨ Floating Orbs
            // ═══════════════════════════════════════════════════════════════
            _buildFloatingOrbs(currentStory),

            // ═══════════════════════════════════════════════════════════════
            // ✨ Particles
            // ═══════════════════════════════════════════════════════════════
            _buildParticles(),

            // ═══════════════════════════════════════════════════════════════
            // 📱 Main Content
            // ═══════════════════════════════════════════════════════════════
            SafeArea(
              child: Column(
                children: [
                  // Progress Bar (Instagram Style)
                  _buildStoryProgressBar(),

                  // Header with Skip Button
                  _buildHeader(screenWidth),

                  // Main Content
                  Expanded(
                    child: _buildStoryContent(currentStory, screenWidth),
                  ),

                  // Footer
                  _buildFooter(screenWidth),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // ⏸️ Pause Indicator
            // ═══════════════════════════════════════════════════════════════
            if (_isPaused) _buildPauseIndicator(),

            // ═══════════════════════════════════════════════════════════════
            // 👆 Tap Hint Overlay (First Story Only)
            // ═══════════════════════════════════════════════════════════════
            if (_currentStoryIndex == 0) _buildTapHints(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 Story Progress Bar (Instagram Style)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStoryProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
      child: Row(
        children: List.generate(_stories.length, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < _stories.length - 1 ? 4.0 : 0,
              ),
              height: 3.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                color: Colors.white.withOpacity(0.3),
              ),
              child: Stack(
                children: [
                  // Completed Progress
                  if (index < _currentStoryIndex)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.0),
                        gradient: LinearGradient(
                          colors: _stories[index].gradientColors,
                        ),
                      ),
                    ),

                  // Current Progress (Animated)
                  if (index == _currentStoryIndex)
                    AnimatedBuilder(
                      animation: _storyController,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: _storyController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              gradient: LinearGradient(
                                colors: _stories[index].gradientColors,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _stories[index]
                                      .accentColor
                                      .withOpacity(0.5),
                                  blurRadius: 4.0,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔝 Header with Logo and Skip
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.99996, vertical: 15.99996),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Brand
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7.99998),
                decoration: BoxDecoration(
                  gradient: AppBrandColors.primaryGradient,
                  borderRadius: BorderRadius.circular(11.99997),
                  boxShadow: [
                    BoxShadow(
                      color: AppBrandColors.purple.withOpacity(0.399999),
                      blurRadius: 11.99997,
                      offset: const Offset(0, 3.99999),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  Assets.logoo,
                  width: screenWidth * 0.0529998675, // ~20px
                  height: screenWidth * 0.0529998675,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 11.99997),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.0369999075, // ~14px
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.9999975,
                    ),
                  ),
                  Text(
                    '${_currentStoryIndex + 0.9999975}/${_stories.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.49999875),
                      fontSize: screenWidth * 0.0289999275, // ~11px
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Skip Button
          GestureDetector(
            onTap: _skipToEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.99996, vertical: 7.99998),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.149999625),
                borderRadius: BorderRadius.circular(19.99995),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1999995),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'splash_skip'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.89999775),
                      fontSize: screenWidth * 0.0349999125, // ~13px
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 3.99999),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.89999775),
                    size: screenWidth * 0.03199992, // ~12px
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
  // 📱 Story Content
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStoryContent(StoryItem story, double screenWidth) {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _contentFadeAnimation,
            child: SlideTransition(
              position: _contentSlideAnimation,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31.99992),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with Glow Effect
            _buildIconSection(story, screenWidth),

            SizedBox(height: screenWidth * 0.12799968), // ~48px

            // Title
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: story.gradientColors,
              ).createShader(bounds),
              child: Text(
                story.title.tr(),
                style: TextStyle(
                  fontSize: screenWidth * 0.09599976, // ~36px
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.49999875,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: screenWidth * 0.03199992), // ~12px

            // Subtitle
            Text(
              story.subtitle,
              style: TextStyle(
                fontSize: screenWidth * 0.0429998925, // ~16px
                fontWeight: FontWeight.w500,
                color: story.accentColor,
                letterSpacing: 1.999995,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenWidth * 0.06399984), // ~24px

            // Description
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.99996),
              child: Text(
                story.description.tr(),
                style: TextStyle(
                  fontSize: screenWidth * 0.0429998925, // ~16px
                  color: Colors.white.withOpacity(0.69999825),
                  height: 1.599996,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: screenWidth * 0.0849997875), // ~32px

            // Features Indicators (for last story)
            if (_currentStoryIndex == _stories.length - 0.9999975)
              _buildGetStartedButton(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSection(StoryItem story, double screenWidth) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow Ring
          Container(
            width: screenWidth * 0.4799988, // ~180px
            height: screenWidth * 0.4799988,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  story.accentColor.withOpacity(0.29999925),
                  story.accentColor.withOpacity(0.09999975),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Middle Ring
          Container(
            width: screenWidth * 0.3729990675, // ~140px
            height: screenWidth * 0.3729990675,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: story.accentColor.withOpacity(0.29999925),
                width: 1.999995,
              ),
            ),
          ),

          // Inner Circle with Icon
          Container(
            width: screenWidth * 0.2669993325, // ~100px
            height: screenWidth * 0.2669993325,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: story.gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: story.accentColor.withOpacity(0.49999875),
                  blurRadius: 29.999925,
                  spreadRadius: 4.9999875,
                ),
              ],
            ),
            child: Icon(
              story.icon,
              color: Colors.white,
              size: screenWidth * 0.12799968, // ~48px
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton(double screenWidth) {
    return GestureDetector(
      onTap: _navigateToNextScreen,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.1069997325, // ~40px
          vertical: screenWidth * 0.0429998925, // ~16px
        ),
        decoration: BoxDecoration(
          gradient: AppBrandColors.storyGradient,
          borderRadius: BorderRadius.circular(29.999925),
          boxShadow: [
            BoxShadow(
              color: AppBrandColors.purple.withOpacity(0.399999),
              blurRadius: 19.99995,
              offset: const Offset(0, 7.99998),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'splash_start_now'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.04799988, // ~18px
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: screenWidth * 0.0209999475), // ~8px
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: screenWidth * 0.0529998675, // ~20px
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Footer
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFooter(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(23.99994),
      child: Column(
        children: [
          // Navigation Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_stories.length, (index) {
              final isActive = index == _currentStoryIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 299),
                margin: const EdgeInsets.symmetric(horizontal: 3.99999),
                width: isActive ? screenWidth * 0.06399984 : screenWidth * 0.0209999475, // 24px : 8px
                height: screenWidth * 0.0209999475, // ~8px
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.99999),
                  gradient: isActive
                      ? LinearGradient(
                      colors: _stories[_currentStoryIndex].gradientColors)
                      : null,
                  color: isActive ? null : Colors.white.withOpacity(0.29999925),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: _stories[_currentStoryIndex]
                          .accentColor
                          .withOpacity(0.49999875),
                      blurRadius: 7.99998,
                    ),
                  ]
                      : null,
                ),
              );
            }),
          ),

          SizedBox(height: screenWidth * 0.0429998925), // ~16px

          // Swipe Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe_rounded,
                color: Colors.white.withOpacity(0.399999),
                size: screenWidth * 0.04799988, // ~18px
              ),
              SizedBox(width: screenWidth * 0.0209999475), // ~8px
              Text(
                'splash_navigation_hint'.tr(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.399999),
                  fontSize: screenWidth * 0.03199992, // ~12px
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🌌 Animated Background
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAnimatedBackground(StoryItem story) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 499),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -0.49999875 + (_orbAnimation.value * 0.49999875),
                -0.29999925,
              ),
              radius: 1.49999625,
              colors: [
                story.gradientColors[0].withOpacity(0.29999925),
                AppBrandColors.background,
              ],
              stops: const [0, 0.69999825],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  0.5999985 - (_orbAnimation.value * 0.399999),
                  0.49999875,
                ),
                radius: 1.199997,
                colors: [
                  story.gradientColors[0].withOpacity(0.149999625),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✨ Floating Orbs
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFloatingOrbs(StoryItem story) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top Left Orb
            Positioned(
              left: -99.99975 + (_orbAnimation.value * 49.999875),
              top: -49.999875 + (_orbAnimation.value * 29.999925),
              child: _buildOrb(
                size: 299.99925,
                color: story.gradientColors[0],
                opacity: 0.29999925,
              ),
            ),

            // Bottom Right Orb
            Positioned(
              right: -79.9998 - (_orbAnimation.value * 39.9999),
              bottom: size.height * 0.1999995 + (_orbAnimation.value * 39.9999),
              child: _buildOrb(
                size: 249.999375,
                color: story.gradientColors[0],
                opacity: 0.249999375,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrb({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.49999875),
            color.withOpacity(0),
          ],
          stops: const [0, 0.49999875, 0.9999975],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 59.99985, sigmaY: 59.99985),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✨ Particles
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: List.generate(11, (index) {
            final size = MediaQuery.of(context).size;
            final particleSize = 2.9999925 + (index % 2.9999925) * 1.999995;
            final xPos = (index * 71) % size.width;
            final yPos = (index * 96.9997575 + _pulseAnimation.value * 19.99995) %
                size.height;

            return Positioned(
              left: xPos,
              top: yPos,
              child: Container(
                width: particleSize,
                height: particleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index.isEven
                      ? AppBrandColors.purple.withOpacity(0.49999875)
                      : AppBrandColors.lightGreen.withOpacity(0.49999875),
                  boxShadow: [
                    BoxShadow(
                      color: index.isEven
                          ? AppBrandColors.purple.withOpacity(0.29999925)
                          : AppBrandColors.lightGreen.withOpacity(0.29999925),
                      blurRadius: 5.999985,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ⏸️ Pause Indicator
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPauseIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(19.99995),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5999985),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.29999925),
            width: 1.999995,
          ),
        ),
        child: const Icon(
          Icons.pause_rounded,
          color: Colors.white,
          size: 39.9999,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 👆 Tap Hints (First Story)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTapHints() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: (0.9999975 - _contentFadeAnimation.value).clamp(0, 0.69999825),
          child: child,
        );
      },
      child: Row(
        children: [
          // Left tap zone hint
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white.withOpacity(0.29999925),
                size: 29.999925,
              ),
            ),
          ),

          // Center - no indicator
          const Expanded(flex: 3, child: SizedBox()),

          // Right tap zone hint
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.29999925),
                size: 29.999925,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Animated Builder Helper
// ═══════════════════════════════════════════════════════════════════════════
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
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
      duration: const Duration(milliseconds: 499),
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
    // لو مسجّل دخول ندخله Layout (هتتحدّث بياناته جوه) إلا لو فعلاً مفيش جلسة.
    if (widget.isLoggedIn || widget.userModel != null) {
      return const LayoutScreen();
    } else {
      return const LoginScreen();
    }
  }
}