// ═══════════════════════════════════════════════════════════════════════════
// 📦 Order Tracking Notification Service - Premium Enhanced Version
// ═══════════════════════════════════════════════════════════════════════════
// إشعار واحد يتحدث مع كل تغيير في حالة الطلب
// بتصميم احترافي ومتوافق مع الهوية البصرية للتطبيق
//
// Path: lib/core/services/order_tracking_notification_service.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Brand Colors - الألوان الرسمية للتطبيق
// ═══════════════════════════════════════════════════════════════════════════
class MyColors {
  MyColors._();
  
  // Brand Colors
  static const Color yellow = Color.fromRGBO(217, 179, 29, 1.0);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightgreen = Color(0xFF28E6C5);
  static const Color darkgray = Color(0xFFC6CBE0);
  static const Color lightgray = Color(0xFFF9FAFB);
  
  // Status Colors
  static const Color success = Color(0xFF28E6C5);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF3B82F6);
  
  static const MaterialColor mainColorSwatch = MaterialColor(
    0xFF6842E2,
    <int, Color>{
      50: Color(0xFFEDE7FC),
      100: Color(0xFFD1C3F7),
      200: Color(0xFFB39BF2),
      300: Color(0xFF9473ED),
      400: Color(0xFF7E55E9),
      500: Color(0xFF6842E2),
      600: Color(0xFF603CDF),
      700: Color(0xFF5533DA),
      800: Color(0xFF4B2BD6),
      900: Color(0xFF3A1DCF),
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Order Status Enum - Enhanced with Brand Colors
// ═══════════════════════════════════════════════════════════════════════════
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  arriving,
  delivered,
  cancelled;

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Arabic Text
  // ═══════════════════════════════════════════════════════════════════════
  String get arabicText {
    switch (this) {
      case OrderStatus.pending:
        return 'في انتظار التأكيد';
      case OrderStatus.confirmed:
        return 'تم تأكيد الطلب';
      case OrderStatus.preparing:
        return 'جاري التحضير';
      case OrderStatus.ready:
        return 'جاهز للتوصيل';
      case OrderStatus.outForDelivery:
        return 'خرج للتوصيل';
      case OrderStatus.arriving:
        return 'السائق في الطريق إليك';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'تم الإلغاء';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📜 Description
  // ═══════════════════════════════════════════════════════════════════════
  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'طلبك قيد المراجعة وسيتم تأكيده قريباً ⏳';
      case OrderStatus.confirmed:
        return 'تم استلام طلبك وجاري البدء في التحضير ✅';
      case OrderStatus.preparing:
        return 'يتم تحضير طلبك الآن بعناية 👨‍🍳';
      case OrderStatus.ready:
        return 'طلبك جاهز وفي انتظار السائق 📦';
      case OrderStatus.outForDelivery:
        return 'السائق في طريقه إليك الآن 🚗';
      case OrderStatus.arriving:
        return 'السائق على وشك الوصول! استعد للاستلام 📍';
      case OrderStatus.delivered:
        return 'تم توصيل طلبك بنجاح! شكراً لثقتك بنا 🎉';
      case OrderStatus.cancelled:
        return 'تم إلغاء الطلب. نأسف لذلك ❌';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 😊 Emoji
  // ═══════════════════════════════════════════════════════════════════════
  String get emoji {
    switch (this) {
      case OrderStatus.pending:
        return '⏳';
      case OrderStatus.confirmed:
        return '✅';
      case OrderStatus.preparing:
        return '👨‍🍳';
      case OrderStatus.ready:
        return '📦';
      case OrderStatus.outForDelivery:
        return '🚗';
      case OrderStatus.arriving:
        return '📍';
      case OrderStatus.delivered:
        return '🎉';
      case OrderStatus.cancelled:
        return '❌';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Progress Percentage
  // ═══════════════════════════════════════════════════════════════════════
  int get progressPercent {
    switch (this) {
      case OrderStatus.pending:
        return 10;
      case OrderStatus.confirmed:
        return 25;
      case OrderStatus.preparing:
        return 45;
      case OrderStatus.ready:
        return 60;
      case OrderStatus.outForDelivery:
        return 75;
      case OrderStatus.arriving:
        return 90;
      case OrderStatus.delivered:
        return 100;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  double get progressValue => progressPercent / 100.0;

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Progress Bar Visual
  // ═══════════════════════════════════════════════════════════════════════
  String get progressBar {
    final filled = (progressPercent / 10).round();
    final empty = 10 - filled;
    return '${'█' * filled}${'░' * empty}';
  }

  String get progressBarEmoji {
    final filled = (progressPercent / 10).round();
    final empty = 10 - filled;
    return '${'🟩' * filled}${'⬜' * empty}';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Colors (Using Brand Colors)
  // ═══════════════════════════════════════════════════════════════════════
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return MyColors.warning;
      case OrderStatus.confirmed:
        return MyColors.purple;
      case OrderStatus.preparing:
        return MyColors.yellow;
      case OrderStatus.ready:
        return MyColors.info;
      case OrderStatus.outForDelivery:
        return const Color(0xFF29B6F6);
      case OrderStatus.arriving:
        return const Color(0xFF26C6DA);
      case OrderStatus.delivered:
        return MyColors.lightgreen;
      case OrderStatus.cancelled:
        return MyColors.error;
    }
  }

  Color get lightColor => color.withOpacity(0.15);
  Color get darkColor => Color.lerp(color, Colors.black, 0.2)!;

  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Helper Properties
  // ═══════════════════════════════════════════════════════════════════════
  bool get isCompleted => this == OrderStatus.delivered || this == OrderStatus.cancelled;
  
  bool get isActive => !isCompleted;
  
  bool get hasDriver => this == OrderStatus.outForDelivery || 
                        this == OrderStatus.arriving || 
                        this == OrderStatus.delivered;
  
  bool get shouldPlaySound => this == OrderStatus.confirmed || 
                              this == OrderStatus.outForDelivery || 
                              this == OrderStatus.arriving ||
                              this == OrderStatus.delivered;

  bool get isUrgent => this == OrderStatus.arriving;

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Parse from String
  // ═══════════════════════════════════════════════════════════════════════
  static OrderStatus fromString(String status) {
    switch (status.toLowerCase().replaceAll('_', '').replaceAll(' ', '')) {
      case 'pending':
      case 'معلق':
        return OrderStatus.pending;
      case 'confirmed':
      case 'مؤكد':
        return OrderStatus.confirmed;
      case 'preparing':
      case 'جاريالتحضير':
        return OrderStatus.preparing;
      case 'ready':
      case 'جاهز':
        return OrderStatus.ready;
      case 'outfordelivery':
      case 'خرجللتوصيل':
        return OrderStatus.outForDelivery;
      case 'arriving':
      case 'فيالطريق':
        return OrderStatus.arriving;
      case 'delivered':
      case 'تمالتسليم':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
      case 'ملغي':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ➡️ Get Next Status
  // ═══════════════════════════════════════════════════════════════════════
  OrderStatus? get nextStatus {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery:
        return OrderStatus.arriving;
      case OrderStatus.arriving:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📋 Get All Steps
  // ═══════════════════════════════════════════════════════════════════════
  static List<OrderStatus> get allSteps => [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.outForDelivery,
    OrderStatus.arriving,
    OrderStatus.delivered,
  ];

  int get stepIndex => allSteps.indexOf(this);
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔔 Order Tracking Notification Service
// ═══════════════════════════════════════════════════════════════════════════
class OrderTrackingNotificationService {
  // Singleton Pattern
  static final OrderTrackingNotificationService _instance =
      OrderTrackingNotificationService._internal();
  factory OrderTrackingNotificationService() => _instance;
  OrderTrackingNotificationService._internal();

  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Properties
  // ═══════════════════════════════════════════════════════════════════════
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Callbacks
  Function(String orderId, String action)? onNotificationAction;
  Function(String orderId)? onNotificationTapped;

  // Active Tracking
  final Map<String, OrderStatus> _activeTrackings = {};
  Map<String, OrderStatus> get activeTrackings => Map.unmodifiable(_activeTrackings);

  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Notification ID Generator
  // ═══════════════════════════════════════════════════════════════════════
  int _getNotificationId(String orderId) {
    return orderId.hashCode.abs() % 100000;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🚀 Initialize
  // ═══════════════════════════════════════════════════════════════════════
  Future<bool> initialize() async {
    if (_isInitialized) {
      _log('⚠️ Already initialized');
      return true;
    }

    _log('🚀 Initializing...');

    try {
      // Android Settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS Settings
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'order_tracking',
            actions: [
              DarwinNotificationAction.plain(
                'view_details',
                'عرض التفاصيل',
                options: const {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                'call_driver',
                'اتصل بالسائق',
                options: {DarwinNotificationActionOption.foreground},
              ),
            ],
          ),
        ],
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotification,
      );

      if (initialized != true) {
        _log('❌ Initialization returned false');
        return false;
      }

      // Request Permissions
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        _log('⚠️ Notification permission not granted');
      }

      // Create Notification Channels (Android)
      await _createNotificationChannels();

      _isInitialized = true;
      _log('✅ Initialized successfully');
      return true;

    } catch (e, stack) {
      _log('❌ Initialization error: $e');
      _log('Stack: $stack');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔐 Request Permissions
  // ═══════════════════════════════════════════════════════════════════════
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
        
        return granted ?? false;
        
      } else if (Platform.isAndroid) {
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        final granted = await androidPlugin?.requestNotificationsPermission();
        return granted ?? false;
      }
      
      return true;
    } catch (e) {
      _log('❌ Permission request error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📺 Create Android Notification Channels
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Main Tracking Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'order_tracking',
        'تتبع الطلبات',
        description: 'إشعارات تتبع حالة الطلبات',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Urgent Channel (Arriving)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'order_tracking_urgent',
        'إشعارات عاجلة',
        description: 'إشعارات وصول السائق',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Silent Channel (Updates)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'order_tracking_silent',
        'تحديثات صامتة',
        description: 'تحديثات بدون صوت',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );

    _log('📺 Android notification channels created');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Handle Notification Response
  // ═══════════════════════════════════════════════════════════════════════
  void _handleNotificationResponse(NotificationResponse response) {
    _log('📱 Notification tapped: ${response.payload}');
    _log('   Action: ${response.actionId}');

    final orderId = response.payload;
    if (orderId == null || orderId.isEmpty) return;

    // Handle Action
    if (response.actionId != null && response.actionId!.isNotEmpty) {
      onNotificationAction?.call(orderId, response.actionId!);
    } else {
      onNotificationTapped?.call(orderId);
    }
  }

  @pragma('vm:entry-point')
  static void _handleBackgroundNotification(NotificationResponse response) {
    // Handle background notification
    print('📱 Background notification: ${response.payload}');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Show/Update Tracking Notification
  // ═══════════════════════════════════════════════════════════════════════
  Future<bool> showTrackingNotification({
    required String orderId,
    required String orderReference,
    required OrderStatus status,
    String? estimatedTime,
    String? driverName,
    String? driverPhone,
    bool silent = false,
  }) async {
    // Ensure initialized
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return false;
    }

    final notificationId = _getNotificationId(orderId);
    
    _log('📱 Showing notification for order: $orderReference');
    _log('   Status: ${status.arabicText}');
    _log('   Progress: ${status.progressPercent}%');
    _log('   Silent: $silent');

    try {
      // Store active tracking
      _activeTrackings[orderId] = status;

      // Build notification details
      final androidDetails = _buildAndroidNotificationDetails(
        status: status,
        orderReference: orderReference,
        estimatedTime: estimatedTime,
        driverName: driverName,
        silent: silent,
      );

      final iosDetails = _buildIOSNotificationDetails(
        status: status,
        orderId: orderId,
        silent: silent,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Build notification content
      final title = _buildNotificationTitle(orderReference, status);
      final body = _buildNotificationBody(status, estimatedTime, driverName);

      // Show notification
      await _notifications.show(
        notificationId,
        title,
        body,
        details,
        payload: orderId,
      );

      // Haptic feedback for important statuses
      if (status.shouldPlaySound && !silent) {
        HapticFeedback.mediumImpact();
      }

      // Auto-cancel for completed orders
      if (status.isCompleted) {
        _activeTrackings.remove(orderId);
        
        // Auto dismiss after 30 seconds for delivered
        if (status == OrderStatus.delivered) {
          Future.delayed(const Duration(seconds: 30), () {
            cancelTrackingNotification(orderId);
          });
        }
      }

      _log('✅ Notification shown successfully');
      return true;

    } catch (e, stack) {
      _log('❌ Error showing notification: $e');
      _log('Stack: $stack');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🤖 Build Android Notification Details
  // ═══════════════════════════════════════════════════════════════════════
  AndroidNotificationDetails _buildAndroidNotificationDetails({
    required OrderStatus status,
    required String orderReference,
    String? estimatedTime,
    String? driverName,
    bool silent = false,
  }) {
    // Choose channel based on urgency
    String channelId;
    Importance importance;
    Priority priority;

    if (silent) {
      channelId = 'order_tracking_silent';
      importance = Importance.low;
      priority = Priority.low;
    } else if (status.isUrgent) {
      channelId = 'order_tracking_urgent';
      importance = Importance.max;
      priority = Priority.max;
    } else {
      channelId = 'order_tracking';
      importance = Importance.high;
      priority = Priority.high;
    }

    return AndroidNotificationDetails(
      channelId,
      status.isUrgent ? 'إشعارات عاجلة' : 'تتبع الطلبات',
      channelDescription: 'إشعارات تتبع حالة الطلبات',
      importance: importance,
      priority: priority,
      
      // Ongoing notification (can't be swiped away until completed)
      ongoing: status.isActive,
      autoCancel: status.isCompleted,
      
      // ⚠️ NO Progress Bar - using Stepper instead
      showProgress: false,
      
      // Styling
      color: status.color,
      colorized: true,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      
      // Sound & Vibration
      playSound: status.shouldPlaySound && !silent,
      enableVibration: status.shouldPlaySound && !silent,
      
      // Actions
      actions: _buildAndroidActions(status, driverName),
      
      // Big Text Style with Stepper
      styleInformation: BigTextStyleInformation(
        _buildNotificationBody(status, estimatedTime, driverName),
        htmlFormatBigText: false,
        contentTitle: 'طلب #$orderReference',
        htmlFormatContentTitle: false,
        summaryText: '${status.emoji} ${status.arabicText}',
        htmlFormatSummaryText: false,
      ),
      
      // Category
      category: status.isActive 
          ? AndroidNotificationCategory.progress 
          : AndroidNotificationCategory.status,
      
      // Visibility
      visibility: NotificationVisibility.public,
      
      // Ticker
      ticker: '${status.emoji} ${status.arabicText}',
      
      // Chronometer for active orders
      usesChronometer: status.isActive && status != OrderStatus.pending,
      chronometerCountDown: false,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🍎 Build iOS Notification Details
  // ═══════════════════════════════════════════════════════════════════════
  DarwinNotificationDetails _buildIOSNotificationDetails({
    required OrderStatus status,
    required String orderId,
    bool silent = false,
  }) {
    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: status.shouldPlaySound && !silent,
      
      // Thread identifier groups notifications
      threadIdentifier: 'order_$orderId',
      
      // Category for actions
      categoryIdentifier: 'order_tracking',
      
      // Subtitle
      subtitle: status.arabicText,
      
      // Interruption Level
      interruptionLevel: _getIOSInterruptionLevel(status, silent),
      
      // Badge number (active orders count)
      badgeNumber: _activeTrackings.length,
    );
  }

  InterruptionLevel _getIOSInterruptionLevel(OrderStatus status, bool silent) {
    if (silent) return InterruptionLevel.passive;
    if (status.isCompleted) return InterruptionLevel.passive;
    if (status.isUrgent) return InterruptionLevel.timeSensitive;
    return InterruptionLevel.active;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔘 Build Android Actions
  // ═══════════════════════════════════════════════════════════════════════
  List<AndroidNotificationAction>? _buildAndroidActions(
    OrderStatus status,
    String? driverName,
  ) {
    final actions = <AndroidNotificationAction>[];
    
    // View Details Action
    actions.add(const AndroidNotificationAction(
      'view_details',
      '📋 التفاصيل',
      showsUserInterface: true,
      cancelNotification: false,
    ));
    
    // Call Driver Action (if driver is assigned)
    if (status.hasDriver && driverName != null && driverName.isNotEmpty) {
      actions.add(const AndroidNotificationAction(
        'call_driver',
        '📞 اتصل بالسائق',
        showsUserInterface: true,
        cancelNotification: false,
      ));
    }
    
    // Cancel Order Action (only for pending/confirmed)
    if (status == OrderStatus.pending || status == OrderStatus.confirmed) {
      actions.add(const AndroidNotificationAction(
        'cancel_order',
        '❌ إلغاء',
        showsUserInterface: true,
        cancelNotification: false,
      ));
    }
    
    return actions.isNotEmpty ? actions : null;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Build Notification Title
  // ═══════════════════════════════════════════════════════════════════════
  String _buildNotificationTitle(String orderReference, OrderStatus status) {
    return 'طلب #$orderReference ${status.emoji}';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Build Notification Body - Stepper Style
  // ═══════════════════════════════════════════════════════════════════════
  String _buildNotificationBody(
    OrderStatus status,
    String? estimatedTime,
    String? driverName,
  ) {
    final buffer = StringBuffer();
    
    // Build Stepper (all steps)
    buffer.writeln(_buildStepper(status));
    buffer.writeln('');
    
    // Current Status Description
    buffer.writeln('${status.emoji} ${status.arabicText}');
    buffer.writeln(status.description);
    
    // Additional Info
    if (estimatedTime != null && estimatedTime.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('⏱️ الوصول المتوقع: $estimatedTime');
    }
    
    // Driver Info
    if (driverName != null && driverName.isNotEmpty && status.hasDriver) {
      buffer.writeln('🚗 السائق: $driverName');
    }
    
    return buffer.toString().trim();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🪜 Build Stepper Visual
  // ═══════════════════════════════════════════════════════════════════════
  String _buildStepper(OrderStatus currentStatus) {
    final buffer = StringBuffer();
    final allSteps = OrderStatus.allSteps;
    final currentIndex = currentStatus.stepIndex;
    
    for (int i = 0; i < allSteps.length; i++) {
      final step = allSteps[i];
      final isPast = i < currentIndex;
      final isCurrent = i == currentIndex;
      final isFuture = i > currentIndex;
      
      // Step Icon
      if (isPast) {
        buffer.write('✅ '); // Completed
      } else if (isCurrent) {
        buffer.write('${step.emoji} '); // Current (animated)
      } else {
        buffer.write('⚪ '); // Future
      }
      
      // Step Text
      buffer.write(step.arabicText);
      
      // Add connector line (except last step)
      if (i < allSteps.length - 1) {
        buffer.writeln();
        if (isPast) {
          buffer.writeln('  ┃'); // Solid line (completed)
        } else {
          buffer.writeln('  ┆'); // Dotted line (pending)
        }
      }
    }
    
    return buffer.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Update Notification (Convenience Method)
  // ═══════════════════════════════════════════════════════════════════════
  Future<bool> updateTrackingNotification({
    required String orderId,
    required String orderReference,
    required OrderStatus newStatus,
    String? estimatedTime,
    String? driverName,
    String? driverPhone,
  }) async {
    // Determine if update should be silent
    final currentStatus = _activeTrackings[orderId];
    final silent = currentStatus != null && 
                   newStatus.progressPercent - currentStatus.progressPercent < 10;

    return showTrackingNotification(
      orderId: orderId,
      orderReference: orderReference,
      status: newStatus,
      estimatedTime: estimatedTime,
      driverName: driverName,
      driverPhone: driverPhone,
      silent: silent && !newStatus.shouldPlaySound,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🗑️ Cancel Notifications
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> cancelTrackingNotification(String orderId) async {
    final notificationId = _getNotificationId(orderId);
    await _notifications.cancel(notificationId);
    _activeTrackings.remove(orderId);
    _log('🗑️ Cancelled notification for order: $orderId');
  }

  Future<void> cancelAllTrackingNotifications() async {
    await _notifications.cancelAll();
    _activeTrackings.clear();
    _log('🗑️ Cancelled all notifications');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Get Pending Notifications
  // ═══════════════════════════════════════════════════════════════════════
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.getActiveNotifications() ?? [];
    }
    return [];
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 Logging
  // ═══════════════════════════════════════════════════════════════════════
  void _log(String message) {
    debugPrint('[OrderNotification] $message');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Order Tracking Model (Optional - for structured data)
// ═══════════════════════════════════════════════════════════════════════════
class OrderTrackingData {
  final String orderId;
  final String orderReference;
  final OrderStatus status;
  final String? estimatedTime;
  final String? driverName;
  final String? driverPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderTrackingData({
    required this.orderId,
    required this.orderReference,
    required this.status,
    this.estimatedTime,
    this.driverName,
    this.driverPhone,
    this.createdAt,
    this.updatedAt,
  });

  OrderTrackingData copyWith({
    String? orderId,
    String? orderReference,
    OrderStatus? status,
    String? estimatedTime,
    String? driverName,
    String? driverPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderTrackingData(
      orderId: orderId ?? this.orderId,
      orderReference: orderReference ?? this.orderReference,
      status: status ?? this.status,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'orderReference': orderReference,
    'status': status.name,
    'estimatedTime': estimatedTime,
    'driverName': driverName,
    'driverPhone': driverPhone,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory OrderTrackingData.fromJson(Map<String, dynamic> json) {
    return OrderTrackingData(
      orderId: json['orderId'] as String,
      orderReference: json['orderReference'] as String,
      status: OrderStatus.fromString(json['status'] as String),
      estimatedTime: json['estimatedTime'] as String?,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }
}