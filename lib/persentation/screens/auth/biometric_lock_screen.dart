// // ══════════════════════════════════════════════════════════════════════════════
// // 🔐 Biometric Lock Screen - Premium Design
// // ══════════════════════════════════════════════════════════════════════════════
//
// import 'package:app/core/responsive/responsive.dart';
// import 'package:app/core/services/biometric_service.dart';
// import 'package:app/helpers/cache_helper.dart';
// import 'package:app/persentation/screens/auth/login_screen.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui' as ui;
// import 'dart:math' as math;
// import 'dart:developer';
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🎨 App Theme - موحد مع باقي التطبيق
// // ═══════════════════════════════════════════════════════════════════════════
// class AppTheme {
//   static const Color primary = Color(0xFF6842E2);
//   static const Color primaryLight = Color(0xFF8B6CEF);
//   static const Color primaryDark = Color(0xFF5234B5);
//   static const Color secondary = Color(0xFF00C88D);
//   static const Color secondaryLight = Color(0xFF28E6C5);
//   static const Color accent = Color(0xFFFBBF4D);
//   static const Color dark = Color(0xFF081428);
//   static const Color white = Colors.white;
//   static const Color darkBackground = Color(0xFF0A0A12);
//   static const Color darkCard = Color(0xFF14141F);
//   static const Color error = Color(0xFFEF4444);
//   static const Color errorLight = Color(0xFFFEE2E2);
//
//   // Light Theme Colors
//   static const Color lightBackground = Color(0xFFF5F7FA);
//   static const Color lightCard = Color(0xFFFFFFFF);
//   static const Color lightText = Color(0xFF1D1D25);
//   static const Color lightTextSecondary = Color(0xFF6B7280);
//
//   static LinearGradient get primaryGradient => const LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primary, primaryLight],
//   );
//
//   static LinearGradient get darkBackgroundGradient => const LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [
//       Color(0xFF1A1040),
//       Color(0xFF0D0D1A),
//       Color(0xFF0A0A12),
//     ],
//   );
//
//   static LinearGradient get lightBackgroundGradient => const LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [
//       Color(0xFFF8F9FC),
//       Color(0xFFF5F7FA),
//       Color(0xFFFFFFFF),
//     ],
//   );
//
//   // Theme-aware getters
//   static Color background(bool isDark) => isDark ? darkBackground : lightBackground;
//   static Color card(bool isDark) => isDark ? darkCard : lightCard;
//   static Color text(bool isDark) => isDark ? white : lightText;
//   static Color textSecondary(bool isDark) =>
//       isDark ? white.withOpacity(0.5) : lightTextSecondary;
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🔐 Biometric Lock Screen
// // ═══════════════════════════════════════════════════════════════════════════
// class BiometricLockScreen extends StatefulWidget {
//   final VoidCallback onAuthenticated;
//
//   const BiometricLockScreen({
//     Key? key,
//     required this.onAuthenticated,
//   }) : super(key: key);
//
//   @override
//   State<BiometricLockScreen> createState() => _BiometricLockScreenState();
// }
//
// class _BiometricLockScreenState extends State<BiometricLockScreen>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _mainController;
//   late AnimationController _pulseController;
//   late AnimationController _floatController;
//   late AnimationController _scanController;
//   late AnimationController _shakeController;
//
//   // Animations
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _floatAnimation;
//   late Animation<double> _scanAnimation;
//   late Animation<double> _iconScaleAnimation;
//   late Animation<double> _iconFadeAnimation;
//   late Animation<double> _contentFadeAnimation;
//   late Animation<Offset> _contentSlideAnimation;
//   late Animation<double> _shakeAnimation;
//
//   bool _isAuthenticating = false;
//   String _errorMessage = '';
//   bool _showError = false;
//
//   bool get _isDark => Theme.of(context).brightness == Brightness.dark;
//   bool get _isRTL => context.locale.languageCode == 'ar';
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _setSystemUIOverlay();
//     _mainController.forward();
//
//     // طلب البصمة تلقائياً عند فتح الشاشة
//     Future.delayed(const Duration(milliseconds: 800), () {
//       _authenticate();
//     });
//   }
//
//   void _setSystemUIOverlay() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
//           systemNavigationBarColor:
//           _isDark ? AppTheme.darkBackground : AppTheme.white,
//           systemNavigationBarIconBrightness:
//           _isDark ? Brightness.light : Brightness.dark,
//         ),
//       );
//     });
//   }
//
//   void _initAnimations() {
//     // Main Controller
//     _mainController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//
//     // Pulse Controller
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     )..repeat(reverse: true);
//
//     // Float Controller
//     _floatController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat(reverse: true);
//
//     // Scan Controller (للدوران حول الأيقونة)
//     _scanController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2500),
//     )..repeat();
//
//     // Shake Controller (عند الخطأ)
//     _shakeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//
//     // Fade Animation
//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0, 0.5, curve: Curves.easeOut),
//       ),
//     );
//
//     // Scale Animation
//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
//       ),
//     );
//
//     // Icon Scale
//     _iconScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
//       ),
//     );
//
//     // Icon Fade
//     _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
//       ),
//     );
//
//     // Pulse
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
//       CurvedAnimation(
//         parent: _pulseController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     // Float
//     _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
//       CurvedAnimation(
//         parent: _floatController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     // Scan
//     _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _scanController,
//         curve: Curves.linear,
//       ),
//     );
//
//     // Content Fade
//     _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
//       ),
//     );
//
//     // Content Slide
//     _contentSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _mainController,
//       curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
//     ));
//
//     // Shake Animation
//     _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _shakeController,
//         curve: Curves.elasticIn,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _mainController.dispose();
//     _pulseController.dispose();
//     _floatController.dispose();
//     _scanController.dispose();
//     _shakeController.dispose();
//     super.dispose();
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // 🔐 المصادقة بالبصمة
//   // ═══════════════════════════════════════════════════════════════════════════
//   Future<void> _authenticate() async {
//     if (_isAuthenticating) return;
//
//     setState(() {
//       _isAuthenticating = true;
//       _errorMessage = '';
//       _showError = false;
//     });
//
//     try {
//       final authenticated = await BiometricService.instance.authenticate(
//         reason: 'app_lock_reason'.tr(),
//         biometricOnly: false,
//       );
//
//       if (authenticated) {
//         log('✅ BiometricLockScreen: المصادقة نجحت');
//         HapticFeedback.mediumImpact();
//         widget.onAuthenticated();
//       } else {
//         log('❌ BiometricLockScreen: المصادقة فشلت');
//         _handleError('biometric_auth_failed'.tr());
//       }
//     } catch (e) {
//       log('❌ BiometricLockScreen: خطأ في المصادقة: $e');
//       _handleError('biometric_error'.tr());
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAuthenticating = false;
//         });
//       }
//     }
//   }
//
//   void _handleError(String message) {
//     HapticFeedback.heavyImpact();
//     _shakeController.forward().then((_) => _shakeController.reset());
//     setState(() {
//       _errorMessage = message;
//       _showError = true;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Directionality(
//       textDirection: _isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
//       child: Scaffold(
//         body: Container(
//           width: size.width,
//           height: size.height,
//           decoration: BoxDecoration(
//             gradient: _isDark
//                 ? AppTheme.darkBackgroundGradient
//                 : AppTheme.lightBackgroundGradient,
//           ),
//           child: Stack(
//             children: [
//               // Background Effects
//               _buildBackgroundEffects(size),
//
//               // Floating Particles
//               _buildFloatingParticles(size),
//
//               // Decorative Lines
//               _buildDecorativeLines(size),
//
//               // Main Content
//               SafeArea(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: Column(
//                     children: [
//                       // Header
//                       _buildHeader(),
//
//                       const Spacer(flex: 2),
//
//                       // Biometric Icon Section
//                       _buildBiometricSection(size),
//
//                       const Spacer(flex: 1),
//
//                       // Buttons Section
//                       _buildButtonsSection(),
//
//                       const Spacer(flex: 2),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 🎨 Background Effects
//   // ═══════════════════════════════════════════════════════════════════════
//   Widget _buildBackgroundEffects(Size size) {
//     return Stack(
//       children: [
//         // Top Right Glow
//         Positioned(
//           top: -size.height * 0.15,
//           right: -size.width * 0.3,
//           child: AnimatedBuilder(
//             animation: _pulseAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _pulseAnimation.value,
//                 child: Container(
//                   width: size.width * 0.8,
//                   height: size.width * 0.8,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         AppTheme.primary.withOpacity(_isDark ? 0.25 : 0.15),
//                         AppTheme.primary.withOpacity(_isDark ? 0.1 : 0.05),
//                         AppTheme.primary.withOpacity(0),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//
//         // Bottom Left Glow
//         Positioned(
//           bottom: -size.height * 0.1,
//           left: -size.width * 0.3,
//           child: AnimatedBuilder(
//             animation: _pulseAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: 2 - _pulseAnimation.value,
//                 child: Container(
//                   width: size.width * 0.7,
//                   height: size.width * 0.7,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         AppTheme.primaryLight.withOpacity(_isDark ? 0.2 : 0.1),
//                         AppTheme.primaryLight.withOpacity(_isDark ? 0.08 : 0.04),
//                         AppTheme.primaryLight.withOpacity(0),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//
//         // Center Glow (حول الأيقونة)
//         Center(
//           child: AnimatedBuilder(
//             animation: _pulseAnimation,
//             builder: (context, child) {
//               return Container(
//                 width: size.width * 0.6,
//                 height: size.width * 0.6,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       AppTheme.primary.withOpacity(
//                           (_isDark ? 0.12 : 0.08) * _pulseAnimation.value),
//                       AppTheme.primary.withOpacity(0),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // ✨ Floating Particles
//   // ═══════════════════════════════════════════════════════════════════════
//   Widget _buildFloatingParticles(Size size) {
//     return AnimatedBuilder(
//       animation: _floatController,
//       builder: (context, child) {
//         return Stack(
//           children: List.generate(15, (index) {
//             final random = math.Random(index);
//             final x = random.nextDouble() * size.width;
//             final y = random.nextDouble() * size.height;
//             final particleSize = 3 + random.nextDouble() * 6;
//             final delay = random.nextDouble();
//
//             return Positioned(
//               left: x,
//               top: y + (_floatAnimation.value * (index.isEven ? 1 : -1) * delay),
//               child: Container(
//                 width: particleSize,
//                 height: particleSize,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       AppTheme.primary.withOpacity(_isDark ? 0.6 : 0.4),
//                       AppTheme.primary.withOpacity(0),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 📐 Decorative Lines
//   // ═══════════════════════════════════════════════════════════════════════
//   Widget _buildDecorativeLines(Size size) {
//     return Positioned.fill(
//       child: CustomPaint(
//         painter: _LinesPainter(isDark: _isDark),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 📱 Header
//   // ═══════════════════════════════════════════════════════════════════════
//   Widget _buildHeader() {
//     return AnimatedBuilder(
//       animation: _mainController,
//       builder: (context, child) {
//         return SlideTransition(
//           position: _contentSlideAnimation,
//           child: Opacity(
//             opacity: _contentFadeAnimation.value,
//             child: child,
//           ),
//         );
//       },
//       child: Padding(
//         padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 20)),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // App Icon
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradient,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppTheme.primary.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.shield_rounded,
//                 color: AppTheme.white,
//                 size: ResponsiveUtils.icon(context, 20),
//               ),
//             ),
//             SizedBox(width: ResponsiveUtils.spacing(context, 12)),
//             Text(
//               'app_name'.tr(),
//               style: TextStyle(
//                 fontSize: ResponsiveUtils.font(context, 20),
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.text(_isDark),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 🔐 Biometric Section
//   // ═══════════════════════════════════════════════════════════════════════
//   Widget _buildBiometricSection(Size size) {
//     return Column(
//       children: [
//         // Animated Biometric Icon
//         AnimatedBuilder(
//           animation: _mainController,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _iconScaleAnimation.value,
//               child: Opacity(
//                 opacity: _iconFadeAnimation.value,
//                 child: AnimatedBuilder(
//                   animation: _floatAnimation,
//                   builder: (context, child) {
//                     return Transform.translate(
//                       offset: Offset(0, _floatAnimation.value),
//                       child: AnimatedBuilder(
//                         animation: _shakeAnimation,
//                         builder: (context, child) {
//                           final shake = math.sin(_shakeAnimation.value * math.pi * 4) * 10;
//                           return Transform.translate(
//                             offset: Offset(shake, 0),
//                             child: child,
//                           );
//                         },
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: _buildBiometricIconContainer(size),
//                 ),
//               ),
//             );
//           },
//         ),
//
//         SizedBox(height: ResponsiveUtils.spacing(context, 40)),
//
//         // Title & Subtitle
//         AnimatedBuilder(
//           animation: _mainController,
//           builder: (context, child) {
//             return SlideTransition(
//               position: _contentSlideAnimation,
//               child: Opacity(
//                 opacity: _contentFadeAnimation.value,
//                 child: child,
//               ),
//             );
//           },
//           child: Column(
//             children: [
//               Text(
//                 'app_locked'.tr(),
//                 style: TextStyle(
//                   fontSize: ResponsiveUtils.font(context, 28),
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.text(_isDark),
//                   letterSpacing: 0.5,
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveUtils.spacing(context, 12)),
//
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: ResponsiveUtils.spacing(context, 40),
//                 ),
//                 child: Text(
//                   'unlock_with_biometric'.tr(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: ResponsiveUtils.font(context, 16),
//                     color: AppTheme.textSecondary(_isDark),
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Error Message
//         AnimatedSize(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           child: _showError ? _buildErrorMessage() : const SizedBox.shrink(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBiometricIconContainer(Size size) {
//     final iconSize = ResponsiveUtils.size(context, 140);
//
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Container(
//           width: iconSize * _pulseAnimation.value,
//           height: iconSize * _pulseAnimation.value,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppTheme.primary.withOpacity(_isDark ? 0.15 : 0.1),
//                 AppTheme.primaryDark.withOpacity(_isDark ? 0.08 : 0.05),
//               ],
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: AppTheme.primary.withOpacity(_isDark ? 0.4 : 0.25),
//                 blurRadius: 50,
//                 spreadRadius: 5,
//               ),
//             ],
//             border: Border.all(
//               color: AppTheme.primary.withOpacity(_isDark ? 0.25 : 0.15),
//               width: 2,
//             ),
//           ),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Spinning Ring
//               if (_isAuthenticating)
//                 AnimatedBuilder(
//                   animation: _scanController,
//                   builder: (context, child) {
//                     return Transform.rotate(
//                       angle: _scanController.value * 2 * math.pi,
//                       child: Container(
//                         width: iconSize * 0.9,
//                         height: iconSize * 0.9,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: SweepGradient(
//                             colors: [
//                               AppTheme.primary.withOpacity(0),
//                               AppTheme.primary.withOpacity(0.6),
//                               AppTheme.secondaryLight.withOpacity(0.6),
//                               AppTheme.primary.withOpacity(0),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//
//               // Static Ring (when not authenticating)
//               if (!_isAuthenticating)
//                 Container(
//                   width: iconSize * 0.9,
//                   height: iconSize * 0.9,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: AppTheme.primary.withOpacity(0.2),
//                       width: 2,
//                     ),
//                   ),
//                 ),
//
//               // Inner Container
//               Container(
//                 width: iconSize * 0.7,
//                 height: iconSize * 0.7,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: _isDark
//                         ? [
//                       AppTheme.darkCard.withOpacity(0.95),
//                       AppTheme.darkBackground,
//                     ]
//                         : [
//                       AppTheme.white,
//                       AppTheme.lightBackground,
//                     ],
//                   ),
//                   border: Border.all(
//                     color: AppTheme.primary.withOpacity(0.1),
//                     width: 1,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppTheme.primary.withOpacity(0.2),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: _isAuthenticating
//                       ? _buildAuthenticatingIcon()
//                       : Icon(
//                     Icons.fingerprint_rounded,
//                     color: AppTheme.primary,
//                     size: ResponsiveUtils.icon(context, 50),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildAuthenticatingIcon() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // Pulsing Background
//         AnimatedBuilder(
//           animation: _pulseController,
//           builder: (context, child) {
//             return Container(
//               width: ResponsiveUtils.size(context, 60) * _pulseAnimation.value,
//               height: ResponsiveUtils.size(context, 60) * _pulseAnimation.value,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppTheme.primary.withOpacity(0.1),
//               ),
//             );
//           },
//         ),
//         // Icon
//         Icon(
//           Icons.fingerprint_rounded,
//           color: AppTheme.primary,
//           size: ResponsiveUtils.icon(context, 50),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildErrorMessage() {
//     return Padding(
//       padding: EdgeInsets.only(top: ResponsiveUtils.spacing(context, 24)),
//       child: Container(
//         margin: EdgeInsets.symmetric(
//           horizontal: ResponsiveUtils.spacing(context, 40),
//         ),
//         padding: EdgeInsets.symmetric(
//           horizontal: ResponsiveUtils.spacing(context, 16),
//           vertical: ResponsiveUtils.spacing(context, 12),
//         ),
//         decoration: BoxDecoration(
//           color: AppTheme.error.withOpacity(_isDark ? 0.15 : 0.08),
//           borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
//           border: Border.all(
//             color: AppTheme.error.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppTheme.error.withOpacity(0.15),
//               ),
//               child: Icon(
//                 Icons.error_outline_rounded,
//                 color: AppTheme.error,
//                 size: ResponsiveUtils.icon(context, 18),
//               ),
//             ),
//             SizedBox(width: ResponsiveUtils.spacing(context, 12)),
//             Expanded(
//               child: Text(
//                 _errorMessage,
//                 style: TextStyle(
//                   fontSize: ResponsiveUtils.font(context, 14),
//                   color: AppTheme.error,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 🎮 Buttons Section
//   // ═══════════════════════════════════════════════════════════════════════
//   Widget _buildButtonsSection() {
//     return AnimatedBuilder(
//       animation: _mainController,
//       builder: (context, child) {
//         return SlideTransition(
//           position: _contentSlideAnimation,
//           child: Opacity(
//             opacity: _contentFadeAnimation.value,
//             child: child,
//           ),
//         );
//       },
//       child: Column(
//         children: [
//           // Retry Button
//           _buildRetryButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRetryButton() {
//     return GestureDetector(
//       onTap: _isAuthenticating ? null : () {
//         HapticFeedback.lightImpact();
//         _authenticate();
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: ResponsiveUtils.width(context, 220),
//         padding: EdgeInsets.symmetric(
//           vertical: ResponsiveUtils.spacing(context, 16),
//         ),
//         decoration: BoxDecoration(
//           gradient: _isAuthenticating
//               ? null
//               : AppTheme.primaryGradient,
//           color: _isAuthenticating
//               ? AppTheme.primary.withOpacity(0.5)
//               : null,
//           borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
//           boxShadow: [
//             BoxShadow(
//               color: AppTheme.primary.withOpacity(0.3),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_isAuthenticating) ...[
//               SizedBox(
//                 width: 22,
//                 height: 22,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     AppTheme.white.withOpacity(0.9),
//                   ),
//                 ),
//               ),
//             ] else ...[
//               Icon(
//                 Icons.fingerprint_rounded,
//                 color: AppTheme.white,
//                 size: ResponsiveUtils.icon(context, 24),
//               ),
//             ],
//             SizedBox(width: ResponsiveUtils.spacing(context, 12)),
//             Text(
//               _isAuthenticating ? 'authenticating'.tr() : 'retry_biometric'.tr(),
//               style: TextStyle(
//                 fontSize: ResponsiveUtils.font(context, 16),
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🎨 Lines Painter
// // ═══════════════════════════════════════════════════════════════════════════
// class _LinesPainter extends CustomPainter {
//   final bool isDark;
//
//   _LinesPainter({required this.isDark});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = AppTheme.primary.withOpacity(isDark ? 0.03 : 0.02)
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     for (double i = -size.height; i < size.width + size.height; i += 50) {
//       canvas.drawLine(
//         Offset(i, 0),
//         Offset(i + size.height, size.height),
//         paint,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🔧 AnimatedBuilder Helper
// // ═══════════════════════════════════════════════════════════════════════════
// class AnimatedBuilder extends AnimatedWidget {
//   final Widget Function(BuildContext context, Widget? child) builder;
//   final Widget? child;
//
//   const AnimatedBuilder({
//     super.key,
//     required Animation<double> animation,
//     required this.builder,
//     this.child,
//   }) : super(listenable: animation);
//
//   @override
//   Widget build(BuildContext context) => builder(context, child);
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🔘 Dialog Button
// // ═══════════════════════════════════════════════════════════════════════════
// class _DialogButton extends StatelessWidget {
//   final String label;
//   final bool isDark;
//   final bool isOutlined;
//   final bool isDestructive;
//   final VoidCallback onTap;
//
//   const _DialogButton({
//     required this.label,
//     required this.isDark,
//     this.isOutlined = false,
//     this.isDestructive = false,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onTap();
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           vertical: ResponsiveUtils.spacing(context, 14),
//         ),
//         decoration: BoxDecoration(
//           gradient: isOutlined ? null : (isDestructive
//               ? LinearGradient(colors: [AppTheme.error, AppTheme.error.withOpacity(0.8)])
//               : AppTheme.primaryGradient),
//           color: isOutlined
//               ? (isDark ? AppTheme.darkCard : AppTheme.lightBackground)
//               : null,
//           borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
//           border: isOutlined ? Border.all(
//             color: isDark
//                 ? AppTheme.white.withOpacity(0.15)
//                 : AppTheme.dark.withOpacity(0.1),
//           ) : null,
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: ResponsiveUtils.font(context, 15),
//               fontWeight: FontWeight.w600,
//               color: isOutlined
//                   ? AppTheme.text(isDark)
//                   : AppTheme.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }