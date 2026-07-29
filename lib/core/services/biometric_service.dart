// ══════════════════════════════════════════════════════════════════════════════
// 🔐 Biometric Service - App Lock System
// ══════════════════════════════════════════════════════════════════════════════
// 
// هذا السيرفس مسؤول عن إدارة نظام قفل التطبيق بالبصمة (App Lock)
// وليس كبديل لنظام تسجيل الدخول (Login)
//
// المنطق الأساسي:
// - Login: يُستخدم مرة واحدة لإثبات الهوية والحصول على Token
// - Biometric: تُستخدم لقفل/فتح التطبيق دون المساس بالـ Session
// - المستخدم يظل Logged In حتى يعمل Logout يدوي أو ينتهي Token
// ══════════════════════════════════════════════════════════════════════════════

import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/helpers/cache_helper.dart';
import 'dart:developer';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  static BiometricService get instance => _instance;
  
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Flag لتتبع ما إذا تمت المصادقة في الجلسة الحالية
  bool _hasAuthenticatedInSession = false;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 📋 Constants
  // ═══════════════════════════════════════════════════════════════════════════
  static const String _keyBiometricEnabled = 'biometric_app_lock_enabled';
  static const String _keyLastBackgroundTime = 'last_background_time';
  static const int _inactivityTimeoutSeconds = 30; // 30 seconds timeout

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ التحقق من دعم الجهاز للبصمة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      log('❌ BiometricService: Error checking biometric support: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ الحصول على أنواع البصمة المتاحة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      log('❌ BiometricService: Error getting available biometrics: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔓 التحقق من حالة تفعيل قفل التطبيق بالبصمة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> isBiometricLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyBiometricEnabled) ?? false;
    } catch (e) {
      log('❌ BiometricService: Error checking biometric lock status: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ تفعيل قفل التطبيق بالبصمة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<BiometricResult> enableBiometricLock() async {
    try {
      log('═══════════════════════════════════════════════════');
      log('🔐 BiometricService: تفعيل قفل التطبيق بالبصمة');
      log('═══════════════════════════════════════════════════');

      // 1️⃣ التحقق من دعم الجهاز
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        log('❌ الجهاز لا يدعم البصمة');
        return BiometricResult.deviceNotSupported;
      }

      // 2️⃣ التحقق من وجود Token (المستخدم مسجل دخول)
      final token = CacheHelper.getString(key: "access_token");
      if (token == null || token.isEmpty) {
        log('❌ المستخدم غير مسجل دخول');
        return BiometricResult.notLoggedIn;
      }

      // 3️⃣ طلب المصادقة بالبصمة من المستخدم
      final authenticated = await _authenticate(
        reason: 'قم بالمصادقة لتفعيل قفل التطبيق',
      );

      if (!authenticated) {
        log('❌ المصادقة فشلت');
        return BiometricResult.authenticationFailed;
      }

      // 4️⃣ حفظ حالة التفعيل
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricEnabled, true);
      
      log('✅ تم تفعيل قفل التطبيق بالبصمة بنجاح');
      return BiometricResult.success;

    } catch (e) {
      log('❌ BiometricService: خطأ في تفعيل البصمة: $e');
      return BiometricResult.error;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❌ تعطيل قفل التطبيق بالبصمة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> disableBiometricLock() async {
    try {
      log('🔓 BiometricService: تعطيل قفل التطبيق بالبصمة');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricEnabled, false);
      
      log('✅ تم تعطيل قفل التطبيق بالبصمة');
      return true;

    } catch (e) {
      log('❌ BiometricService: خطأ في تعطيل البصمة: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 المصادقة بالبصمة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = true,
  }) async {
    return await _authenticate(
      reason: reason,
      biometricOnly: biometricOnly,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 دالة خاصة للمصادقة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> _authenticate({
    required String reason,
    bool biometricOnly = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      log('❌ BiometricService: خطأ في المصادقة: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⏰ حفظ وقت الدخول للخلفية
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> saveBackgroundTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_keyLastBackgroundTime, now);
      log('⏰ BiometricService: تم حفظ وقت الخلفية: $now');
    } catch (e) {
      log('❌ BiometricService: خطأ في حفظ وقت الخلفية: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⏰ التحقق من انتهاء مهلة عدم النشاط
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> isInactivityTimeoutExceeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackgroundTime = prefs.getInt(_keyLastBackgroundTime);
      
      if (lastBackgroundTime == null) {
        return false;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final diffSeconds = (now - lastBackgroundTime) ~/ 1000;
      
      log('⏰ BiometricService: مدة عدم النشاط: $diffSeconds ثانية');
      
      return diffSeconds >= _inactivityTimeoutSeconds;

    } catch (e) {
      log('❌ BiometricService: خطأ في التحقق من مهلة عدم النشاط: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 التحقق من الحاجة لطلب البصمة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> shouldRequestBiometric({
    bool isAppStartup = false,
    bool isFromBackground = false,
  }) async {
    try {
      // 1️⃣ التحقق من تفعيل البصمة
      final isEnabled = await isBiometricLockEnabled();
      if (!isEnabled) {
        log('ℹ️ BiometricService: قفل البصمة غير مفعل');
        return false;
      }

      // 2️⃣ التحقق من تسجيل الدخول
      final token = CacheHelper.getString(key: "access_token");
      if (token == null || token.isEmpty) {
        log('ℹ️ BiometricService: المستخدم غير مسجل دخول');
        return false;
      }

      // 3️⃣ إذا تمت المصادقة بالفعل في هذه الجلسة، لا حاجة لطلبها مرة أخرى
      if (_hasAuthenticatedInSession) {
        log('ℹ️ BiometricService: تمت المصادقة بالفعل في هذه الجلسة');
        return false;
      }

      // 4️⃣ إذا كان من الخلفية، التحقق من مهلة عدم النشاط
      if (isFromBackground) {
        final timeoutExceeded = await isInactivityTimeoutExceeded();
        if (timeoutExceeded) {
          log('✅ BiometricService: مهلة عدم النشاط انتهت - طلب البصمة');
          return true;
        } else {
          log('ℹ️ BiometricService: المهلة لم تنته - لا حاجة للبصمة');
          return false;
        }
      }

      // 5️⃣ إذا كان بدء التطبيق، طلب البصمة دائماً
      if (isAppStartup) {
        log('✅ BiometricService: بدء التطبيق - طلب البصمة');
        return true;
      }

      return false;

    } catch (e) {
      log('❌ BiometricService: خطأ في التحقق من الحاجة للبصمة: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ تعيين flag المصادقة الناجحة
  // ═══════════════════════════════════════════════════════════════════════════
  void markAsAuthenticatedInSession() {
    _hasAuthenticatedInSession = true;
    log('✅ BiometricService: تم تعيين المصادقة في الجلسة');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🧹 إعادة تعيين flag المصادقة (عند الخروج للخلفية لمدة طويلة)
  // ═══════════════════════════════════════════════════════════════════════════
  void resetSessionAuthentication() {
    _hasAuthenticatedInSession = false;
    log('🔄 BiometricService: تم إعادة تعيين flag المصادقة');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🧹 مسح وقت الخلفية بعد المصادقة الناجحة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> clearBackgroundTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLastBackgroundTime);
      log('✅ BiometricService: تم مسح وقت الخلفية');
    } catch (e) {
      log('❌ BiometricService: خطأ في مسح وقت الخلفية: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🧹 تنظيف البيانات عند Logout
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> clearOnLogout() async {
    try {
      log('🧹 BiometricService: تنظيف بيانات البصمة عند Logout');
      
      // إعادة تعيين flag المصادقة
      _hasAuthenticatedInSession = false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyBiometricEnabled);
      await prefs.remove(_keyLastBackgroundTime);
      log('✅ تم تنظيف البيانات');
    } catch (e) {
      log('❌ BiometricService: خطأ في التنظيف: $e');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 📊 Biometric Result Enum
// ══════════════════════════════════════════════════════════════════════════════
enum BiometricResult {
  success,                  // تم التفعيل بنجاح
  deviceNotSupported,      // الجهاز لا يدعم البصمة
  notLoggedIn,             // المستخدم غير مسجل دخول
  authenticationFailed,    // فشلت المصادقة
  error,                   // خطأ عام
}
