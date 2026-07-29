import 'dart:developer';
import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📲 FCM Subscription Helper
// ═══════════════════════════════════════════════════════════════════════════
// يضمن اشتراك المستخدم في topic وحفظ Token في Firestore
// يُستدعى بعد تسجيل الدخول وعند فتح التطبيق
// ═══════════════════════════════════════════════════════════════════════════

class FCMSubscriptionHelper {
  static final FCMSubscriptionHelper _instance = FCMSubscriptionHelper._();
  factory FCMSubscriptionHelper() => _instance;
  FCMSubscriptionHelper._();

  /// يُستدعى بعد تسجيل الدخول أو عند فتح التطبيق
  Future<void> ensureSubscribed({String? userId}) async {
    final messaging = FirebaseMessaging.instance;

    try {
      // 1. الاشتراك في topic all_users
      await messaging.subscribeToTopic('all_users');
      log('✅ [FCM] Subscribed to all_users');

      // 2. الحصول على Token
      String? token;
      if (Platform.isIOS) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          token = await messaging.getToken();
        } else {
          await Future.delayed(const Duration(seconds: 3));
          final retryApns = await messaging.getAPNSToken();
          if (retryApns != null) {
            token = await messaging.getToken();
          }
        }
      } else {
        token = await messaging.getToken();
      }

      // 3. حفظ Token في Firestore
      // if (token != null && userId != null) {
      //   await FirebaseFirestore.instance
      //       .collection('customers')
      //       .doc(userId)
      //       .set({
      //     'fcmToken': token,
      //     'fcm_token': token,
      //     'platform': Platform.isIOS ? 'ios' : 'android',
      //     'deviceInfo': {
      //       'os': Platform.operatingSystem,
      //       'osVersion': Platform.operatingSystemVersion,
      //     },
      //     'lastTokenUpdate': FieldValue.serverTimestamp(),
      //     'tokenActive': true,
      //     'subscribedTopics': ['all_users'],
      //   }, SetOptions(merge: true));
      //   log('✅ [FCM] Token saved for user: $userId');
      // }
    } catch (e) {
      log('❌ [FCM] Subscription error: $e');
    }
  }

  /// تحقق من حالة الإذن وأعد الطلب إذا لزم الأمر
  Future<bool> ensurePermission() async {
    final messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    log('📱 [FCM] Permission status: ${settings.authorizationStatus} (granted: $granted)');
    return granted;
  }
}
