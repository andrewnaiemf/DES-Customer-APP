import 'dart:developer';
import 'dart:io';

import 'package:app/business_logic/CheckLoyalty/cubit/check_loyalty_cubit.dart';
import 'package:app/business_logic/LoyalityPointsCubit/loyality_points_cubit.dart';
import 'package:app/business_logic/NotificationsCubit/notifications_cubit.dart';
import 'package:app/business_logic/Statistic_cubit/statistic_cubit.dart';
import 'package:app/business_logic/account_statement/cubit/account_statement_cubit.dart';
import 'package:app/business_logic/auth/CheckPhoneCubit/check_phone_cubit.dart';
import 'package:app/business_logic/auth/cubit/auth_cubit.dart';
import 'package:app/business_logic/exports/cubit/exports_cubit.dart';
import 'package:app/business_logic/invoce/cubit/invoice_cubit.dart';
import 'package:app/business_logic/layout/cubit/layout_cubit.dart';
import 'package:app/business_logic/orders/cubit/orders_cubit.dart';
import 'package:app/business_logic/products/cubit/products_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/business_logic/receipt/cubit/receipt_cubit.dart';
import 'package:app/business_logic/reset_password/cubit/reset_password_cubit.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/business_logic/tracking/tracking_cubit.dart';
import 'package:app/persentation/screens/offers/offers_screen.dart';
import 'package:app/services/tracking_error_handler.dart';
import 'package:app/theme/colors.dart';
import 'package:app/firebase_options.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:app/network/services/profile_service.dart';
import 'package:app/persentation/screens/auth/login_screen.dart';
import 'package:app/persentation/screens/layout/layout_screen.dart';
import 'package:app/persentation/screens/splash/splash_screen.dart';
// 🌙 Ramadan Splash Screen - Active during Ramadan season
import 'package:app/persentation/screens/splash/ramadan_splash_screen.dart';
import 'package:app/theme/theme.dart';
import 'package:app/core/tour/app_tour_service.dart';
import 'package:app/core/tour/tour_overlay.dart';
import 'package:app/core/live_tracking/services/live_order_tracking_service.dart';
import 'package:app/core/live_tracking/helpers/order_tracking_helper.dart';
import 'package:app/core/services/order_tracking_notification_test_screen.dart';
import 'package:app/core/services/biometric_service.dart';
import 'package:app/core/deep_links/deep_link_service.dart';
import 'package:app/persentation/screens/auth/biometric_lock_screen.dart';
import 'package:app/core/utils/performance_utils.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import 'business_logic/AppVersionCubit/app_version_cubit.dart';
import 'business_logic/OffersCubit/offers_cubit.dart';
import 'functions/my_navigation.dart';

/// 501538430 - Accounting72@@
// ═══════════════════════════════════════════════════════════════════════════
// 📱 Local Notifications Plugin
// ═══════════════════════════════════════════════════════════════════════════
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> globalNavigatorKey =
GlobalKey<NavigatorState>();
// ═══════════════════════════════════════════════════════════════════════════
// 📱 Background Message Handler (Must be top-level function)
// ═══════════════════════════════════════════════════════════════════════════
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background handler
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  log('📩 Background Message received!');
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
  log('Data: ${message.data}');
  
  // 🚀 Initialize required services for background handler
  await CacheHelper.init();
  await LiveOrderTrackingService.instance.initialize();
  
  // 🚀 CRITICAL: Handle order tracking for ALL order notifications
  final data = message.data;
  final hasOrderId = data.containsKey('order_id') || 
                     data.containsKey('orderId') || 
                     data.containsKey('id');
  final hasStatus = data.containsKey('shipping_status') || 
                    data.containsKey('shippingStatus') ||
                    data.containsKey('status');
  
  if (hasOrderId || hasStatus) {
    log('📦 Order notification detected in background - Starting/Updating Live Activity');
    await OrderTrackingHelper.handleOrderNotification(data);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔔 Show Local Notification
// ═══════════════════════════════════════════════════════════════════════════
Future<void> _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? 'إشعار جديد',
    message.notification?.body ?? '',
    platformDetails,
    payload: message.data.toString(),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await CacheHelper.init();
  
  // ═══════════════════════════════════════════════════════════════════════
  // 📱 إعداد Edge-to-Edge للتعامل مع Navigation Bar
  // ═══════════════════════════════════════════════════════════════════════
  if (!kIsWeb && Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // Status Bar
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        
        // Navigation Bar - شفاف لحل مشكلة Samsung
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
  
  // ✅ تهيئة متوازية للخدمات المستقلة (أسرع بكثير)
  // بدلاً من await واحدة تلو الأخرى
  DioHelper.init();
  DioHelperV2.init();
  DioHelperPublic.init();
  DioHelperWarranty.init();
  
  await Future.wait([
    AppTourService.instance.initialize(),
    LiveOrderTrackingService().initialize(),
    if (!kIsWeb)
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
          .catchError((e) {
        log('Firebase already initialized: $e');
        return Firebase.app();
      }),
  ]);

  if (!kIsWeb) {
    // Initialize Firebase Messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Initialize Local Notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log('📱 Local Notification tapped! Payload: ${response.payload}');
      },
    );

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('User granted permission: ${settings.authorizationStatus}');

    String? token;
    try {
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          log('APNS Token: $apnsToken');
          token = await messaging.getToken();
        } else {
          log('⚠️ APNS token not available yet, will retry...');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) {
            token = await messaging.getToken();
          }
        }
      } else {
        token = await messaging.getToken();
      }
      log('FCM Token: $token');
    } catch (e) {
      log('⚠️ Error getting FCM token: $e');
    }

    try {
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      log('✅ Subscribed to topic: all_users');
    } catch (e) {
      log('⚠️ Error subscribing to topic: $e');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📩 Foreground Message received!');
      log('Title: ${message.notification?.title}');
      log('Body: ${message.notification?.body}');
      log('Data: ${message.data}');

      final data = message.data;
      final type = data['type']?.toString().toLowerCase();

      if (type == 'offer') {
        log('🎁 Offer notification detected - Navigating to OffersScreen');
        globalNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => const OffersScreen(),
          ),
        );
      }

      final hasOrderId = data.containsKey('order_id') ||
          data.containsKey('orderId') ||
          data.containsKey('id');
      final hasStatus = data.containsKey('shipping_status') ||
          data.containsKey('shippingStatus') ||
          data.containsKey('status');

      if (hasOrderId || hasStatus) {
        log('📦 Order notification detected in foreground - Starting/Updating Live Activity');
        OrderTrackingHelper.handleOrderNotification(data);
      }

      _showLocalNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('📱 Notification tapped! (app was in background)');
      log('Data: ${message.data}');

      final data = message.data;
      final hasOrderId = data.containsKey('order_id') ||
          data.containsKey('orderId') ||
          data.containsKey('id');
      final hasStatus = data.containsKey('shipping_status') ||
          data.containsKey('shippingStatus') ||
          data.containsKey('status');

      if (hasOrderId || hasStatus) {
        log('📦 Order notification tapped - Starting/Updating Live Activity');
        OrderTrackingHelper.handleOrderNotification(data);
      }
    });

    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      log('📱 App opened from terminated state via notification');
      log('Data: ${initialMessage.data}');

      final data = initialMessage.data;
      final hasOrderId = data.containsKey('order_id') ||
          data.containsKey('orderId') ||
          data.containsKey('id');
      final hasStatus = data.containsKey('shipping_status') ||
          data.containsKey('shippingStatus') ||
          data.containsKey('status');

      if (hasOrderId || hasStatus) {
        log('📦 App opened from order notification - Starting/Updating Live Activity');
        await OrderTrackingHelper.handleOrderNotification(data);
      }
    }
  } else {
    log('ℹ️ Skipping Firebase Messaging on web (not configured)');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 تحديد حالة الجلسة عند بدء التطبيق
  // المشكلة القديمة: كان أي فشل في /profile (نت ضعيف/timeout/سيرفر) بيرجّع null
  // ويطرد المستخدم على شاشة Login رغم إن التوكن لسه صالح.
  // الحل: نطرد المستخدم بس لو فعلاً مفيش جلسة أو السيرفر رفض التوكن (401).
  // ═══════════════════════════════════════════════════════════════════════════
  final bool storedIsLoggedIn = CacheHelper.getBool(key: "is_logged_in") ?? false;
  final String? storedToken = CacheHelper.getString(key: "access_token");
  bool hasSession =
      storedIsLoggedIn && storedToken != null && storedToken.isNotEmpty;

  // Local 3-month inactivity: clear session before hitting APIs.
  if (hasSession) {
    final lastActivityRaw =
        CacheHelper.getString(key: 'last_app_activity_at');
    final lastActivity = lastActivityRaw != null
        ? DateTime.tryParse(lastActivityRaw)?.toUtc()
        : null;
    final cutoff =
        DateTime.now().toUtc().subtract(const Duration(days: 90)); // ~3 months
    if (lastActivity != null && lastActivity.isBefore(cutoff)) {
      await _clearCustomerSession();
      hasSession = false;
      log('🔐 Session cleared: inactive for 3+ months (local check)');
    }
  }

  UserModel? userModel;
  bool isLoggedIn = false;

  if (hasSession) {
    final profileResult = await ProfileServices.getProfileWithStatus();

    switch (profileResult.outcome) {
      case ProfileFetchOutcome.success:
        userModel = profileResult.user;
        isLoggedIn = true;
        await CacheHelper.setString(
          key: 'last_app_activity_at',
          value: DateTime.now().toUtc().toIso8601String(),
        );
        break;
      case ProfileFetchOutcome.unauthorized:
        // Token rejected / inactivity expiry from server → clear session
        await _clearCustomerSession();
        userModel = null;
        isLoggedIn = false;
        break;
      case ProfileFetchOutcome.transientError:
        // خطأ مؤقت -> حافظ على الجلسة وادخل التطبيق، والبيانات هتتحدّث جوه
        userModel = null;
        isLoggedIn = true;
        break;
    }
  }

  // Initialize AppThemeProvider and load saved theme
  final themeProvider = AppThemeProvider();
  // تحميل الثيم المحفوظ
  await themeProvider.loadTheme();

  // 🔗 تهيئة الـ Deep Links (App Links / Universal Links)
  // بنعملها قبل runApp عشان نمسك الرابط اللي فتح التطبيق وهو مقفول.
  await DeepLinkService.instance.init(globalNavigatorKey);

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: EasyLocalization(
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        startLocale: const Locale('ar'),
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        child: MyApp(userModel: userModel, isLoggedIn: isLoggedIn),
      ),
    ),
  );
}

Future<void> _clearCustomerSession() async {
  await CacheHelper.removeKey(key: 'access_token');
  await CacheHelper.setBool(key: 'is_logged_in', value: false);
  await CacheHelper.removeKey(key: 'last_app_activity_at');
  await CacheHelper.removeKey(key: 'cached_user_json');
  await CacheHelper.setBool(key: 'can_use_biometric', value: false);
  try {
    const storage = FlutterSecureStorage();
    // Keep phone for convenience; drop password so biometric can't bypass OTP.
    await storage.delete(key: 'password');
  } catch (_) {}
  DioHelper.init();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.userModel, required this.isLoggedIn});

  final UserModel? userModel;
  final bool isLoggedIn;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _showBiometricLock = false;
  bool _isBiometricLockVisible = false; // 🔐 منع فتح أكثر من lock screen
  // final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricOnStartup();
    // 📊 بدء مراقبة أداء الفريمات في وضع Debug فقط
    PerformanceMonitor.startFrameMonitoring(intervalSeconds: 30);
  }

  @override
  void dispose() {
    PerformanceMonitor.stopFrameMonitoring();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 App Lifecycle Observer - مراقبة حالة التطبيق
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    log('📱 App Lifecycle State Changed: $state');

    switch (state) {
      case AppLifecycleState.paused:
        // التطبيق ذهب للخلفية
        log('⏸️ App paused - Saving background time');
        BiometricService.instance.saveBackgroundTime();
        break;

      case AppLifecycleState.resumed:
        // التطبيق عاد من الخلفية
        log('▶️ App resumed - Checking if biometric needed');
        _checkBiometricAfterResume();
        break;

      case AppLifecycleState.inactive:
        // التطبيق غير نشط (مثل أثناء مكالمة)
        log('⏯️ App inactive');
        break;

      case AppLifecycleState.detached:
        // التطبيق على وشك الإغلاق
        log('🔴 App detached');
        break;
        
      case AppLifecycleState.hidden:
        log('👁️ App hidden');
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 التحقق من البصمة عند بدء التطبيق
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _checkBiometricOnStartup() async {
    final shouldRequest = await BiometricService.instance.shouldRequestBiometric(
      isAppStartup: true,
    );

    if (shouldRequest && mounted) {
      setState(() {
        _showBiometricLock = true;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 التحقق من البصمة بعد العودة من الخلفية
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _checkBiometricAfterResume() async {
    // منع فتح أكثر من lock screen
    if (_isBiometricLockVisible) {
      log('ℹ️ Biometric lock screen already visible - skipping');
      return;
    }
    
    // أولاً نتحقق من انتهاء المهلة
    final timeoutExceeded = await BiometricService.instance.isInactivityTimeoutExceeded();
    
    // إذا انتهت المهلة، نعيد تعيين flag المصادقة
    if (timeoutExceeded) {
      BiometricService.instance.resetSessionAuthentication();
    }
    
    // final shouldRequest = await BiometricService.instance.shouldRequestBiometric(
    //   isFromBackground: true,
    // );

    // if (shouldRequest && mounted) {
    //   _pushBiometricLockScreen();
    // }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ callback عند نجاح المصادقة
  // ═══════════════════════════════════════════════════════════════════════════
  // void _onBiometricAuthenticated() {
  //   log('✅ Biometric authenticated - Hiding lock screen');
  //
  //   // تعيين flag المصادقة الناجحة في الجلسة
  //   BiometricService.instance.markAsAuthenticatedInSession();
  //
  //   // مسح وقت الخلفية لمنع طلب البصمة مرة أخرى
  //   BiometricService.instance.clearBackgroundTime();
  //
  //   _isBiometricLockVisible = false;
  //
  //   if (mounted) {
  //     setState(() {
  //       _showBiometricLock = false;
  //     });
  //
  //     // 🔐 Pop the lock screen if it was pushed via Navigator
  //     final nav = _navigatorKey.currentState;
  //     if (nav != null && nav.canPop()) {
  //       nav.pop();
  //     }
  //   }
  // }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 فتح شاشة القفل عبر Navigator (تعمل في أي وقت)
  // ═══════════════════════════════════════════════════════════════════════════
  // void _pushBiometricLockScreen() {
  //   if (_isBiometricLockVisible) return;
  //
  //   _isBiometricLockVisible = true;
  //   log('🔐 Pushing BiometricLockScreen via Navigator');
  //
  //   final nav = _navigatorKey.currentState;
  //   if (nav != null) {
  //     nav.push(
  //       PageRouteBuilder(
  //         opaque: true,
  //         pageBuilder: (context, animation, secondaryAnimation) {
  //           return BiometricLockScreen(
  //             onAuthenticated: _onBiometricAuthenticated,
  //           );
  //         },
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return FadeTransition(opacity: animation, child: child);
  //         },
  //         transitionDuration: const Duration(milliseconds: 300),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => CheckPhoneCubit()),
        BlocProvider(create: (BuildContext context) => AuthCubit()),
        BlocProvider(create: (BuildContext context) => LayoutCubit()),
        BlocProvider(create: (BuildContext context) => TranslationCubit()),
        BlocProvider(create: (BuildContext context) => ProfileCubit(initialUserModel: widget.userModel)),
        BlocProvider(create: (BuildContext context) => OrdersCubit()),
        BlocProvider(create: (BuildContext context) => ProductsCubit()),
        BlocProvider(create: (BuildContext context) => InVoiceCubit()),
        BlocProvider(create: (BuildContext context) => ReceiptCubit()),
        BlocProvider(create: (BuildContext context) => AccountStatementCubit()),
        BlocProvider(create: (BuildContext context) => ResetPasswordCubit()),
        BlocProvider(create: (BuildContext context) => ExportsCubit()),
        BlocProvider(create: (BuildContext context) => StatisticCubit()),
        BlocProvider(create: (BuildContext context) => NotificationsCubit()),
        BlocProvider(create: (BuildContext context) => CheckLoyaltyCubit()),
        BlocProvider(create: (BuildContext context) => LoyalityPointsCubit()),
        BlocProvider(create: (BuildContext context) => OffersCubit()),
        BlocProvider(create: (BuildContext context) => AppVersionCubit()),
        // ✅ Live Tracking Cubit
        BlocProvider(
          create: (BuildContext context) => TrackingCubit(
            trackingService: LiveOrderTrackingService.instance,
            errorHandler: TrackingErrorHandler(),
          ),
        ),
      ],
      child: BlocBuilder<TranslationCubit, TranslationState>(
        builder: (context, state) {
          // ✅ تحديث اللغة في Live Tracking Service
          final languageCode = context.locale.languageCode;
          LiveOrderTrackingService.instance.updateLanguage(languageCode);
          
          return Consumer<AppThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                navigatorKey: globalNavigatorKey,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                title: 'DES',
                debugShowCheckedModeBanner: false,
                theme: AppThemeProvider.lightTheme,
                darkTheme: AppThemeProvider.darkTheme,
                themeMode: themeProvider.themeMode,
                // navigatorKey: _navigatorKey,
                home: FutureBuilder<bool>(
                  future: SplashScreen.shouldShowSplash(),
                  builder: (context, snapshot) {
                    // أثناء التحميل
                    if (!snapshot.hasData) {
                      return const Scaffold(
                        backgroundColor: Color(0xFF121212),
                        body: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6842E2),
                          ),
                        ),
                      );
                    }

                    // التحقق من ضرورة عرض الـ Splash
                    final shouldShow = snapshot.data!;

                    // 🔗 لو التطبيق اتفتح من رابط عميق (Deep Link) منتظر، نتخطّى
                    // شاشة الـ onboarding القصصية (التخطي) وندخل على طول للوجهة
                    // (Layout لو مسجّل دخول / Login لو لأ)، وبعدها الرابط بيتنفّذ.
                    if (DeepLinkService.instance.hasPending) {
                      return InitialScreen(
                        userModel: widget.userModel,
                        isLoggedIn: widget.isLoggedIn,
                      );
                    }

                    // 🌙 عرض Splash Screen الرمضاني دائماً (موسم رمضان)
                    // 🔄 للعودة للـ Splash العادي: استبدل RamadanSplashScreen بـ SplashScreen
                    // return RamadanSplashScreen(
                    //   onFinish: () async {
                    //     // تحديد الشاشة التالية بناءً على حالة المستخدم
                    //     Widget nextScreen;
                    //
                    //     if (widget.userModel != null) {
                    //       // المستخدم مسجل دخول - دائماً نذهب لـ LayoutScreen
                    //       nextScreen = const LayoutScreen();
                    //     } else {
                    //       // المستخدم غير مسجل دخول - الذهاب مباشرة لشاشة تسجيل الدخول
                    //       nextScreen = const LoginScreen();
                    //     }
                    //
                    //     // الانتقال للشاشة التالية
                    //     if (context.mounted) {
                    //       Navigator.of(context).pushReplacement(
                    //         MaterialPageRoute(builder: (_) => nextScreen),
                    //       );
                    //
                    //       // 🔐 إذا كان قفل البصمة مطلوب، نفتحه فوق الشاشة الرئيسية
                    //       if (_showBiometricLock && widget.userModel != null) {
                    //         // تأخير بسيط للسماح بإكمال الانتقال الأول
                    //         Future.delayed(const Duration(milliseconds: 300), () {
                    //           _pushBiometricLockScreen();
                    //         });
                    //       }
                    //     }
                    //   },
                    // );
                    
                    // ⚠️ للعودة للـ Splash العادي استخدم هذا:
                    return SplashScreen(
                      userModel: widget.userModel,
                      isLoggedIn: widget.isLoggedIn,
                    );
                  },
                ),
                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/notification_test': (context) => const OrderTrackingNotificationTestScreen(),
                },
                builder: (context, child) {
                  // تثبيت حجم النص ومنع التكبير من إعدادات النظام
                  final mediaQuery = MediaQuery.of(context);
                  final textScaledChild = MediaQuery(
                    data: mediaQuery.copyWith(
                      textScaler: const TextScaler.linear(0.95), // ✅ استبدال textScaleFactor المهمل
                      boldText: false, // إلغاء النص العريض من النظام
                    ),
                    child: child!,
                  );
                  
                  // 🎯 لف التطبيق بـ TourOverlay
                  return TourOverlay(
                    child: textScaledChild,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
/// عميل نفدي
/// 590387779 - 123456789 // dont use this