// ═══════════════════════════════════════════════════════════════════════════
// 🔔 Notification Action Handler
// ═══════════════════════════════════════════════════════════════════════════
// معالجة تفاعلات المستخدم مع الإشعارات
// - فتح صفحة التتبع
// - الاتصال بالسائق
// - إيقاف التتبع
//
// Path: lib/core/live_tracking/helpers/notification_action_handler.dart
// Created: February 9, 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/live_order_tracking_service.dart';

/// معالجة تفاعلات الإشعارات
class NotificationActionHandler {
  // ═══════════════════════════════════════════════════════════════════════
  // Singleton
  // ═══════════════════════════════════════════════════════════════════════
  
  static final NotificationActionHandler _instance = NotificationActionHandler._internal();
  factory NotificationActionHandler() => _instance;
  NotificationActionHandler._internal();
  
  static NotificationActionHandler get instance => _instance;
  
  // ═══════════════════════════════════════════════════════════════════════
  // Properties
  // ═══════════════════════════════════════════════════════════════════════
  
  bool _isInitialized = false;
  
  /// Callback عند فتح صفحة التتبع
  Function(String orderId)? onOpenTracking;
  
  /// Callback عند الاتصال بالسائق
  Function(String orderId, String phone)? onCallDriver;
  
  /// Callback عند إيقاف التتبع
  Function(String orderId)? onStopTracking;
  
  // ═══════════════════════════════════════════════════════════════════════
  // Public Methods
  // ═══════════════════════════════════════════════════════════════════════
  
  /// تهيئة معالج الـ Actions
  Future<void> initialize(FlutterLocalNotificationsPlugin notificationsPlugin) async {
    if (_isInitialized) return;
    
    _log('🔔 Initializing Notification Action Handler...');
    
    try {
      // Initialize with action handlers
      await notificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        ),
        onDidReceiveNotificationResponse: _handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotificationResponse,
      );
      
      _isInitialized = true;
      _log('✅ Notification Action Handler initialized');
    } catch (e) {
      _log('❌ Error initializing Notification Action Handler: $e');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Response Handlers
  // ═══════════════════════════════════════════════════════════════════════
  
  /// معالجة الاستجابة للإشعار (Foreground/Background)
  void _handleNotificationResponse(NotificationResponse response) {
    _log('📱 Notification response received');
    _log('   - Action ID: ${response.actionId ?? "tap"}');
    _log('   - Payload: ${response.payload}');
    
    _processAction(response.actionId, response.payload);
  }
  
  /// معالجة الاستجابة للإشعار (Background/Terminated)
  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationResponse(NotificationResponse response) {
    dev.log('[NotificationActionHandler] Background response received');
    dev.log('   - Action ID: ${response.actionId ?? "tap"}');
    dev.log('   - Payload: ${response.payload}');
    
    _processAction(response.actionId, response.payload);
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Action Processing
  // ═══════════════════════════════════════════════════════════════════════
  
  /// معالجة Action محدد
  static void _processAction(String? actionId, String? payload) {
    if (payload == null || payload.isEmpty) {
      dev.log('[NotificationActionHandler] No payload provided');
      return;
    }
    
    // استخراج Order ID من الـ payload
    final orderId = _extractOrderId(payload);
    
    if (orderId == null || orderId.isEmpty) {
      dev.log('[NotificationActionHandler] Could not extract order ID from payload');
      return;
    }
    
    // معالجة حسب نوع الـ Action
    if (actionId == null) {
      // النقر على الإشعار نفسه
      _openTrackingScreen(orderId);
    } else {
      switch (actionId) {
        case 'view_details':
          _openTrackingScreen(orderId);
          break;
          
        case 'call_driver':
          _callDriver(orderId);
          break;
          
        case 'stop_tracking':
          _stopTracking(orderId);
          break;
          
        default:
          dev.log('[NotificationActionHandler] Unknown action: $actionId');
      }
    }
  }
  
  /// استخراج Order ID من الـ payload
  static String? _extractOrderId(String payload) {
    try {
      // إذا كان JSON
      if (payload.startsWith('{')) {
        // يمكن تحسينه بـ jsonDecode إذا لزم الأمر
        final regex = RegExp(r'"order_id"\s*:\s*"([^"]+)"');
        final match = regex.firstMatch(payload);
        if (match != null) {
          return match.group(1);
        }
      }
      
      // إذا كان Order ID مباشرة
      return payload;
    } catch (e) {
      dev.log('[NotificationActionHandler] Error extracting order ID: $e');
      return null;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Action Implementations
  // ═══════════════════════════════════════════════════════════════════════
  
  /// فتح صفحة التتبع
  static void _openTrackingScreen(String orderId) {
    dev.log('[NotificationActionHandler] 📱 Opening tracking screen for: $orderId');
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // استدعاء الـ callback
    instance.onOpenTracking?.call(orderId);
    
    // يمكن إضافة navigation مباشر هنا
    // مثال:
    // navigatorKey.currentState?.pushNamed(
    //   '/order-tracking',
    //   arguments: orderId,
    // );
  }
  
  /// الاتصال بالسائق
  static Future<void> _callDriver(String orderId) async {
    dev.log('[NotificationActionHandler] 📞 Calling driver for order: $orderId');
    
    try {
      // الحصول على معلومات التتبع الحالي
      final tracking = LiveOrderTrackingService.instance.currentTracking;
      
      if (tracking?.driverPhone == null || tracking!.driverPhone!.isEmpty) {
        dev.log('[NotificationActionHandler] ⚠️ No driver phone available');
        return;
      }
      
      final phone = tracking.driverPhone!;
      final phoneUrl = Uri.parse('tel:$phone');
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      // استدعاء الـ callback
      instance.onCallDriver?.call(orderId, phone);
      
      // فتح تطبيق الهاتف
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
        dev.log('[NotificationActionHandler] ✅ Phone dialer opened: $phone');
      } else {
        dev.log('[NotificationActionHandler] ❌ Cannot launch phone dialer');
      }
    } catch (e) {
      dev.log('[NotificationActionHandler] ❌ Error calling driver: $e');
    }
  }
  
  /// إيقاف التتبع
  static Future<void> _stopTracking(String orderId) async {
    dev.log('[NotificationActionHandler] 🛑 Stopping tracking for: $orderId');
    
    try {
      // Haptic feedback
      HapticFeedback.lightImpact();
      
      // استدعاء الـ callback
      instance.onStopTracking?.call(orderId);
      
      // إيقاف التتبع
      await LiveOrderTrackingService.instance.stopTracking();
      
      dev.log('[NotificationActionHandler] ✅ Tracking stopped successfully');
    } catch (e) {
      dev.log('[NotificationActionHandler] ❌ Error stopping tracking: $e');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Utility Methods
  // ═══════════════════════════════════════════════════════════════════════
  
  void _log(String message) {
    final formattedMessage = '[NotificationActionHandler] $message';
    dev.log(formattedMessage);
    if (kDebugMode) {
      debugPrint(formattedMessage);
    }
  }
  
  /// تنظيف
  void dispose() {
    _isInitialized = false;
    onOpenTracking = null;
    onCallDriver = null;
    onStopTracking = null;
  }
}
