// ═══════════════════════════════════════════════════════════════════════════
// 🚀 Live Order Tracking Service - Premium Edition (Fixed)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart'; // ✅ إضافة rxdart

import '../models/order_tracking_model.dart';
import '../theme/tracking_colors.dart';
import 'order_firestore_listener.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🚀 Live Order Tracking Service
// ═══════════════════════════════════════════════════════════════════════════
class LiveOrderTrackingService {
  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Singleton Pattern
  // ═══════════════════════════════════════════════════════════════════════
  static final LiveOrderTrackingService _instance =
      LiveOrderTrackingService._internal();

  factory LiveOrderTrackingService() => _instance;
  
  static LiveOrderTrackingService get instance => _instance;

  LiveOrderTrackingService._internal();

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Properties
  // ═══════════════════════════════════════════════════════════════════════
  
  static const MethodChannel _channel = MethodChannel('live_activities_plugin');
  
  FlutterLocalNotificationsPlugin? _notificationsPlugin;
  SharedPreferences? _prefs;

  final Map<String, String> _activityIds = {};
  
  OrderFirestoreListener get _firestoreListener => OrderFirestoreListener.instance;
  
  /// Public access to Firestore Listener (for manual retry)
  OrderFirestoreListener get firestoreListener => _firestoreListener;
  
  bool _isInitialized = false;
  bool _isIOSLiveActivitiesAvailable = false;
  
  String _currentLanguage = 'en';
  
  bool _isCreatingActivity = false;
  final Map<String, Completer<bool>> _pendingCreations = {};

  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 5);
  
  Future<OrderTrackingModel?> Function(String orderId)? onFetchTrackingUpdate;

  // ═══════════════════════════════════════════════════════════════════════
  // ✅ استخدام BehaviorSubject بدلاً من StreamController.broadcast()
  // BehaviorSubject يحتفظ بآخر قيمة ويرسلها للمشتركين الجدد فوراً
  // ═══════════════════════════════════════════════════════════════════════
  final BehaviorSubject<OrderTrackingModel?> _trackingSubject = 
      BehaviorSubject<OrderTrackingModel?>.seeded(null);

  // Constants
  static const String _prefKeyCurrentOrder = 'live_tracking_current_order';
  static const String _prefKeyActivityIds = 'activity_ids';
  static const int _foregroundNotificationId = 99999;
  static const String _channelId = 'order_tracking_channel';
  static const String _channelName = 'تتبع الطلبات';

  // ═══════════════════════════════════════════════════════════════════════
  // 🔍 Getters
  // ═══════════════════════════════════════════════════════════════════════

  /// ✅ الطلب الحالي قيد التتبع - من الـ BehaviorSubject
  OrderTrackingModel? get currentTracking => _trackingSubject.valueOrNull;

  /// هل يوجد تتبع نشط
  bool get hasActiveTracking => currentTracking?.isActive ?? false;

  /// هل تم التهيئة
  bool get isInitialized => _isInitialized;

  /// ✅ Stream للتحديثات - يحتفظ بآخر قيمة
  Stream<OrderTrackingModel?> get trackingStream => _trackingSubject.stream;
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🌍 Language Management
  // ═══════════════════════════════════════════════════════════════════════
  
  void updateLanguage(String languageCode) {
    _currentLanguage = languageCode;
    _log('🌍 Language updated to: $languageCode');
    
    if (currentTracking != null && !kIsWeb && Platform.isIOS) {
      _updateIOSLiveActivity(currentTracking!);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Initialization
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> initialize() async {
    if (_isInitialized) {
      _log('⚠️ Service already initialized');
      if (currentTracking != null && currentTracking!.isActive && _pollingTimer == null) {
        _startPolling();
      }
      return;
    }

    try {
      _log('🚀 Initializing LiveOrderTrackingService...');

      _prefs = await SharedPreferences.getInstance();

      await _loadCurrentTracking();

      if (!kIsWeb && Platform.isIOS) {
        await _initializeIOS();
      } else if (!kIsWeb && Platform.isAndroid) {
        await _initializeAndroid();
      }

      _isInitialized = true;
      _log('✅ LiveOrderTrackingService initialized successfully');

      await _initializeFirestoreListener();

      if (currentTracking != null && currentTracking!.isActive) {
        await _restoreTracking();
      }
    } catch (e, stack) {
      _log('⚠️ Error initializing LiveOrderTrackingService: $e');
      _log('Stack: $stack');
      _isInitialized = true;
    }
  }

  Future<void> _initializeIOS() async {
    try {
      final enabled = await _channel.invokeMethod<bool>('areActivitiesEnabled');
      _isIOSLiveActivitiesAvailable = enabled ?? false;
      
      if (_isIOSLiveActivitiesAvailable) {
        await _channel.invokeMethod('initialize');
        _log('📱 iOS Live Activities initialized (Native Plugin)');
      } else {
        _log('⚠️ iOS Live Activities not enabled');
      }

      final activityIdsJson = _prefs?.getString(_prefKeyActivityIds);
      if (activityIdsJson != null) {
        final Map<String, dynamic> ids = jsonDecode(activityIdsJson);
        _activityIds.addAll(ids.map((k, v) => MapEntry(k, v.toString())));
        _log('📦 Activity IDs restored: $_activityIds');
      }
      
      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onActivityEnded':
            final orderId = call.arguments['orderId'] as String?;
            _log('📢 Received onActivityEnded for: $orderId');
            if (orderId != null) {
              _activityIds.remove(orderId);
              await _saveActivityIds();
            }
            break;
        }
      });
      
    } catch (e) {
      _log('⚠️ iOS Live Activities not available: $e');
      _isIOSLiveActivitiesAvailable = false;
    }
  }

  Future<void> _initializeAndroid() async {
    try {
      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      final status = await Permission.notification.status;
      if (!status.isGranted) {
        _log('📱 Requesting notification permission...');
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          _log('❌ Notification permission denied');
          return;
        }
      }

      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );

      await _notificationsPlugin!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'إشعارات تتبع الطلبات في الوقت الفعلي',
        importance: Importance.high,
        enableVibration: false,
        playSound: false,
        showBadge: true,
      );

      await _notificationsPlugin!
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _log('✅ Android notifications initialized');
    } catch (e) {
      _log('❌ Error initializing Android notifications: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    _log('📱 Notification tapped: ${response.payload}');
    HapticFeedback.lightImpact();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔥 Firestore Listener Integration
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _initializeFirestoreListener() async {
    try {
      _log('🔥 Initializing Firestore Listener...');
      
      await _firestoreListener.initialize();
      
      _firestoreListener.onStatusChanged = _handleFirestoreStatusChange;
      _firestoreListener.onError = _handleFirestoreError;
      
      _log('✅ Firestore Listener integrated successfully');
    } catch (e) {
      _log('⚠️ Firestore Listener initialization failed: $e');
    }
  }

  /// ✅ معالجة تغيير الحالة من Firestore - مُحسَّن
  void _handleFirestoreStatusChange(
    String orderId,
    OrderTrackingStatus status,
    Map<String, dynamic> data,
  ) {
    _log('');
    _log('🔥 ════════════════════════════════════════════');
    _log('🔥 FIRESTORE REAL-TIME UPDATE RECEIVED!');
    _log('🔥 ════════════════════════════════════════════');
    _log('   Order: $orderId');
    _log('   Status: ${status.arabicText} (${status.apiValue})');
    _log('   Progress: ${status.progressPercent}%');
    
    final current = currentTracking;
    
    // التحقق من أن هذا الطلب هو الحالي
    if (current?.orderId != orderId) {
      _log('⚠️ Received update for different order, ignoring');
      return;
    }
    
    // التحقق من تغيير الحالة
    if (current?.status.apiValue == status.apiValue) {
      _log('ℹ️ Status unchanged, skipping update');
      return;
    }
    
    _log('🎯 Status changed! Updating tracking...');
    _log('   Old: ${current?.status.arabicText}');
    _log('   New: ${status.arabicText}');
    
    // ✅ إنشاء نموذج مُحدَّث
    final updatedTracking = OrderTrackingModel.fromFirestoreEvent({
      'order_id': orderId,
      'order_reference': current!.orderReference,
      'status': status.apiValue,
      'shipping_status': status.apiValue,
      'driver_name': data['driver_name'],
      'driver_phone': data['driver_phone'],
      'driver_image': data['driver_image'],
      'estimated_delivery_time': data['estimated_delivery_time'] ?? data['estimated_time'],
      'delivery_address': data['delivery_address'] ?? data['location'],
      'total_amount': data['total_amount'],
      'currency': data['currency'],
      'created_at': current.startTime?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'metadata': {
        'driver_location': data['driver_location'],
        'previous_status': current.status.apiValue,
        'update_source': 'firestore_realtime',
      },
    });
    
    // ✅ تحديث الـ BehaviorSubject - هذا سيُخطر كل المستمعين فوراً
    _trackingSubject.add(updatedTracking);
    
    // حفظ في التخزين المحلي
    _saveCurrentTracking();
    
    _log('✅ Tracking updated and broadcasted!');
    _log('   Listeners will receive update immediately');
    
    // ✅ تحديث iOS Live Activity
    if (Platform.isIOS) {
      _updateIOSLiveActivity(updatedTracking);
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // ✅ مهم: لا نوقف التتبع عند التوصيل!
    // ═══════════════════════════════════════════════════════════════════════
    if (status.isDelivered) {
      _log('📦 Order delivered - Live Activity will stay visible');
      _log('   User must dismiss it manually from Lock Screen');
      // لا نستدعي stopTracking() هنا
    } else if (status.isCancelled) {
      // فقط عند الإلغاء نوقف بعد فترة
      _log('❌ Order cancelled, will stop tracking in 10 seconds');
      Future.delayed(const Duration(seconds: 10), () {
        stopTracking();
      });
    }
    
    _log('🔥 ════════════════════════════════════════════');
    _log('');
  }

  void _handleFirestoreError(String orderId, String? error) {
    _log('❌ Firestore error for $orderId: $error');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎬 Start Tracking
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> startTracking(OrderTrackingModel tracking) async {
    try {
      _log('🎬 Starting tracking for order: ${tracking.orderReference}');
      _log('📱 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      _log('🔧 Initialized: $_isInitialized');

      if (!_isInitialized) {
        _log('⚠️ Not initialized, initializing now...');
        await initialize();
      }

      // Stop any existing tracking
      if (currentTracking != null) {
        _log('🛑 Stopping existing tracking...');
        await stopTracking(silent: true);
      }

      // ✅ تحديث الـ BehaviorSubject
      _trackingSubject.add(tracking);
      await _saveCurrentTracking();
      _log('💾 Tracking saved and broadcasted');

      bool success = false;

      _log('🚀 Starting platform-specific tracking...');
      
      if (Platform.isIOS) {
        _log('📱 Attempting iOS Live Activity...');
        success = await _startIOSLiveActivity(tracking);
        _log('iOS Live Activity result: $success');
      }

      if (success) {
        _log('✅ Tracking started successfully');
        HapticFeedback.mediumImpact();
        
        // ✅ بدء Firestore Listener
        _firestoreListener.startListening(tracking.orderId);
        _log('👂 Firestore Listener started for: ${tracking.orderId}');
        
        // ✅ بدء API polling كـ fallback
        _startPolling();
        _log('⏱️ API polling started as fallback');
      } else {
        _log('⚠️ Platform-specific tracking failed');
      }

      return success;
    } catch (e) {
      _log('❌ Error starting tracking: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Update Tracking
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> updateTracking(OrderTrackingModel tracking) async {
    try {
      _log('🔄 Updating tracking: ${tracking.orderReference} → ${tracking.status.name}');

      final statusChanged = currentTracking?.status != tracking.status;

      // ✅ تحديث الـ BehaviorSubject
      _trackingSubject.add(tracking);
      await _saveCurrentTracking();

      _log('📢 Update broadcasted to all listeners');

      bool success = false;

      if (Platform.isIOS) {
        success = await _updateIOSLiveActivity(tracking);
      }

      if (statusChanged && success) {
        HapticFeedback.mediumImpact();
      }

      // Check if tracking should end
      if (!tracking.isActive) {
        _log('📦 Order completed, scheduling tracking end');
        Future.delayed(const Duration(seconds: 5), () => stopTracking());
      }

      return success;
    } catch (e) {
      _log('❌ Error updating tracking: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🛑 Stop Tracking - مُحسَّن
  // ═══════════════════════════════════════════════════════════════════════

  /// إيقاف التتبع - مع خيار الإنهاء الفوري
  Future<void> stopTracking({
    bool silent = false, 
    bool forceEnd = false,
  }) async {
    try {
      _log('🛑 Stopping tracking (forceEnd: $forceEnd)');
      
      final current = currentTracking;
      
      // 🛑 Stop Firestore Listener
      if (current != null) {
        _firestoreListener.stopListening(current.orderId);
      }

      _stopPolling();

      // ✅ إنهاء Live Activity فقط إذا forceEnd أو cancelled
      final shouldEndActivity = forceEnd || 
                                (current?.status.isCancelled ?? false);
      
      if (shouldEndActivity) {
        if (Platform.isIOS) {
          await _channel.invokeMethod('endActivity', {
            'orderId': current?.orderId,
            'dismissImmediately': forceEnd,
          });
        } else if (Platform.isAndroid) {
          await _cancelAndroidNotification();
        }
      } else {
        _log('📦 Keeping Live Activity visible for user to dismiss');
      }

      // ✅ مسح الـ BehaviorSubject
      _trackingSubject.add(null);
      
      _activityIds.clear();
      await _clearCurrentTracking();

      if (!silent) {
        HapticFeedback.lightImpact();
      }

      _log('✅ Tracking stopped');
    } catch (e) {
      _log('❌ Error stopping tracking: $e');
    }
  }
  
  /// إنهاء Live Activity يدوياً (للمستخدم)
  Future<void> dismissLiveActivity() async {
    if (!Platform.isIOS) return;
    
    final current = currentTracking;
    if (current == null) return;
    
    try {
      await _channel.invokeMethod('endActivity', {
        'orderId': current.orderId,
        'dismissImmediately': true,
      });
      
      _log('✅ Live Activity dismissed by user');
    } catch (e) {
      _log('❌ Error dismissing Live Activity: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🍎 iOS Live Activity Methods
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> _startIOSLiveActivity(OrderTrackingModel tracking) async {
    if (!_isIOSLiveActivitiesAvailable) return false;
    
    if (_isCreatingActivity) {
      _log('⏳ Activity creation already in progress, waiting...');
      final completer = Completer<bool>();
      _pendingCreations[tracking.orderId] = completer;
      return completer.future;
    }

    _isCreatingActivity = true;
    _log('🔍 Starting iOS Live Activity for: ${tracking.orderId}');

    try {
      final data = {
        'orderId': tracking.orderId,
        'orderReference': tracking.orderReference,
        'status': tracking.status.apiValue,
        'statusDescription': tracking.statusDescription,
        'progress': tracking.progressPercentage,
        'estimatedTime': tracking.estimatedDeliveryTime,
        'driverName': tracking.driverName,
        'driverPhone': tracking.driverPhone,
        'language': _currentLanguage,
      };

      _log('📦 Creating activity with data: $data');

      final result = await _channel.invokeMethod('createActivity', data);

      if (result is bool) {
        if (result) {
          final activityId = 'activity_${tracking.orderId}';
          _activityIds[tracking.orderId] = activityId;
          await _saveActivityIds();
          
          _log('✅ iOS Live Activity created (bool): $activityId');
          _completePendingCreations(tracking.orderId, true);
          return true;
        } else {
          _log('❌ Failed to create activity - native returned false');
          _completePendingCreations(tracking.orderId, false);
          return false;
        }
      } else if (result is String && result.isNotEmpty) {
        _activityIds[tracking.orderId] = result;
        await _saveActivityIds();
        
        _log('✅ iOS Live Activity created (String): $result');
        _completePendingCreations(tracking.orderId, true);
        return true;
      } else {
        _log('❌ Failed to create activity - unexpected return type: ${result.runtimeType}');
        _completePendingCreations(tracking.orderId, false);
        return false;
      }
    } catch (e, stack) {
      _log('❌ Error creating iOS Live Activity: $e');
      _log('Stack: $stack');
      _completePendingCreations(tracking.orderId, false);
      return false;
    } finally {
      _isCreatingActivity = false;
    }
  }

  void _completePendingCreations(String orderId, bool success) {
    final pending = _pendingCreations.remove(orderId);
    pending?.complete(success);
  }

  Future<bool> _updateIOSLiveActivity(OrderTrackingModel tracking) async {
    if (!_isIOSLiveActivitiesAvailable) return false;

    final activityId = _activityIds[tracking.orderId];
    
    _log('');
    _log('🔄 ====== UPDATING IOS LIVE ACTIVITY ======');
    _log('   - Order ID: ${tracking.orderId}');
    _log('   - Activity ID: $activityId');
    _log('   - Status: ${tracking.status.name}');

    if (activityId == null || activityId.isEmpty) {
      _log('⚠️ No activity ID found, creating new activity');
      return await _startIOSLiveActivity(tracking);
    }

    try {
      final data = {
        'activityId': activityId,
        'orderId': tracking.orderId,
        'status': tracking.status.apiValue,
        'statusDescription': tracking.statusDescription,
        'progress': tracking.progressPercentage,
        'estimatedTime': tracking.estimatedDeliveryTime,
        'driverName': tracking.driverName,
        'driverPhone': tracking.driverPhone,
        'language': _currentLanguage,
      };

      _log('📤 Sending update data to iOS: $data');
      
      await _channel.invokeMethod('updateActivity', data);
      _log('✅ iOS Live Activity updated successfully');
      return true;
      
    } on PlatformException catch (e) {
      _log('❌ Error updating iOS Live Activity: ${e.message}');
      
      if (e.code == 'ACTIVITY_ERROR' && e.message?.contains('not found') == true) {
        _log('⚠️ Activity not found, creating new one');
        _activityIds.remove(tracking.orderId);
        await _saveActivityIds();
        return await _startIOSLiveActivity(tracking);
      }
      
      return false;
    } catch (e) {
      _log('❌ Unexpected error: $e');
      return false;
    }
  }

  Future<void> _stopIOSLiveActivity() async {
    if (!_isIOSLiveActivitiesAvailable) return;

    _log('🛑 Stopping iOS Live Activity');

    try {
      await _channel.invokeMethod('endAllActivities');
      _activityIds.clear();
      await _saveActivityIds();
      _log('✅ All iOS Live Activities ended');
    } catch (e) {
      _log('❌ Error stopping iOS Live Activity: $e');
    }
  }

  Future<void> _saveActivityIds() async {
    try {
      await _prefs?.setString(_prefKeyActivityIds, jsonEncode(_activityIds));
      _log('💾 Activity IDs saved');
    } catch (e) {
      _log('❌ Error saving activity IDs: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🤖 Android Notification Methods
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _cancelAndroidNotification() async {
    try {
      await _notificationsPlugin?.cancel(_foregroundNotificationId);
      _log('✅ Android notification cancelled');
    } catch (e) {
      _log('❌ Error cancelling Android notification: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 💾 Storage Methods
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _saveCurrentTracking() async {
    final current = currentTracking;
    if (current == null || _prefs == null) return;

    try {
      final json = jsonEncode(current.toJson());
      await _prefs!.setString(_prefKeyCurrentOrder, json);
      _log('💾 Tracking saved');
    } catch (e) {
      _log('❌ Error saving tracking: $e');
    }
  }

  Future<void> _loadCurrentTracking() async {
    try {
      final json = _prefs?.getString(_prefKeyCurrentOrder);
      if (json != null && json.isNotEmpty) {
        final tracking = OrderTrackingModel.fromJson(jsonDecode(json));
        // ✅ تحديث الـ BehaviorSubject
        _trackingSubject.add(tracking);
        _log('📂 Loaded tracking: ${tracking.orderReference}');
      }
      
      final savedIdsJson = _prefs?.getString(_prefKeyActivityIds);
      if (savedIdsJson != null && savedIdsJson.isNotEmpty) {
        try {
          final Map<String, dynamic> savedMap = jsonDecode(savedIdsJson);
          _activityIds.clear();
          savedMap.forEach((key, value) {
            if (value is String) {
              _activityIds[key] = value;
            }
          });
          _log('📂 Loaded ${_activityIds.length} Activity IDs');
        } catch (e) {
          _log('⚠️ Error parsing activity IDs: $e');
        }
      }
    } catch (e) {
      _log('❌ Error loading tracking: $e');
      await _clearCurrentTracking();
    }
  }

  Future<void> _clearCurrentTracking() async {
    try {
      await _prefs?.remove(_prefKeyCurrentOrder);
      await _prefs?.remove(_prefKeyActivityIds);
      _log('🗑️ Tracking cleared');
    } catch (e) {
      _log('❌ Error clearing tracking: $e');
    }
  }

  Future<void> _restoreTracking() async {
    final current = currentTracking;
    if (current == null) return;

    _log('🔄 Restoring active tracking...');
    _log('   Order ID: ${current.orderId}');
    _log('   Saved Status: ${current.status.arabicText}');

    // ✅ التحقق من حالة الطلب قبل الاستعادة
    if (current.status.isCancelled || current.status.isDelivered) {
      _log('🛑 Restore aborted: Saved order status is ${current.status.arabicText}');
      _log('💾 Clearing saved tracking data...');
      await stopTracking(forceEnd: true);
      return;
    }

    // ✅ CRITICAL: جلب الحالة الفعلية من الباك إند قبل الاستعادة
    if (onFetchTrackingUpdate != null) {
      try {
        _log('🔄 Fetching CURRENT order status from API...');
        final updatedTracking = await onFetchTrackingUpdate!(current.orderId);
        
        if (updatedTracking != null) {
          _log('✅ API Status: ${updatedTracking.status.arabicText}');
          
          // ✅ إذا كان الطلب ملغي/مسلم، لا نستعيد التتبع
          if (updatedTracking.status.isCancelled || 
              updatedTracking.status.isDelivered) {
            _log('🛑 Order is ${updatedTracking.status.arabicText}, stopping tracking permanently');
            await stopTracking(forceEnd: true);
            return;
          }
          
          // ✅ تحديث بالبيانات الجديدة
          _trackingSubject.add(updatedTracking);
          await _saveCurrentTracking();
          _log('💾 Updated with fresh data from API');
        } else {
          _log('⚠️ API returned null, checking if order exists...');
          // إذا كان API يعيد null، قد يكون الطلب محذوف أو ملغي
          _log('🛑 Stopping tracking - order may be cancelled or deleted');
          await stopTracking(forceEnd: true);
          return;
        }
      } catch (e) {
        _log('❌ Error fetching current status: $e');
        _log('🛑 For safety, stopping tracking - please restart manually if order is still active');
        await stopTracking(forceEnd: true);
        return;
      }
    } else {
      _log('⚠️ WARNING: onFetchTrackingUpdate callback not set!');
      _log('⚠️ Cannot verify order status - will use saved data (may be outdated)');
      _log('🛑 For safety, stopping tracking - callback must be set before restore');
      await stopTracking(forceEnd: true);
      return;
    }

    // ✅ تأخير بسيط للتأكد من تهيئة Firebase
    await Future.delayed(const Duration(milliseconds: 500));

    // ✅ بدء Firestore Listener
    try {
      _firestoreListener.startListening(current.orderId);
      _log('👂 Firestore Listener started during restore');
    } catch (e) {
      _log('⚠️ Could not start Firestore Listener: $e');
      _log('   Will retry after Firebase initialization');
    }

    // ✅ بدء API polling كـ fallback
    _startPolling();
    _log('⏱️ API polling started as fallback');

    if (Platform.isIOS) {
      await _updateIOSLiveActivity(currentTracking!);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⏱️ Real-time Polling
  // ═══════════════════════════════════════════════════════════════════════

  void _startPolling() {
    _stopPolling();
    
    _log('⏱️ Starting real-time polling (every ${_pollingInterval.inSeconds}s)');
    
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      await _checkForUpdates();
    });
  }

  void _stopPolling() {
    if (_pollingTimer != null) {
      _log('⏱️ Stopping polling');
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  Future<void> _checkForUpdates() async {
    final current = currentTracking;
    if (current == null || onFetchTrackingUpdate == null) {
      return;
    }

    try {
      _log('🔄 Checking for updates: ${current.orderId}');
      
      final updatedTracking = await onFetchTrackingUpdate!(current.orderId);
      
      if (updatedTracking == null) {
        _log('⚠️ No update received from server');
        return;
      }

      if (updatedTracking.status != current.status) {
        _log('🔔 API: Status changed: ${current.status.name} → ${updatedTracking.status.name}');
        await updateTracking(updatedTracking);
        
        // ✅ إذا كان الطلب delivered أو cancelled، أوقف التتبع
        if (updatedTracking.status.isDelivered || updatedTracking.status.isCancelled) {
          _log('📦 API: Order ${updatedTracking.status.isCancelled ? "cancelled" : "delivered"}, stopping tracking');
          Future.delayed(const Duration(seconds: 3), () {
            stopTracking();
          });
        }
      } else if (updatedTracking.driverName != current.driverName ||
                 updatedTracking.driverPhone != current.driverPhone) {
        _log('👨‍✈️ Driver info updated');
        await updateTracking(updatedTracking);
      } else {
        _log('✓ No changes detected');
      }
      
    } catch (e) {
      _log('❌ Error checking updates: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Utility Methods
  // ═══════════════════════════════════════════════════════════════════════

  void _log(String message) {
    final formattedMessage = '[LiveTracking] $message';
    log(formattedMessage);
    debugPrint(formattedMessage);
  }

  /// ✅ تنظيف الموارد - لا تغلق الـ BehaviorSubject لأنه Singleton
  Future<void> dispose() async {
    _stopPolling();
    _firestoreListener.dispose();
    // ❌ لا تغلق الـ BehaviorSubject لأنه Singleton
    // await _trackingSubject.close();
    _log('🗑️ Service disposed (keeping stream open)');
  }
  
  /// ✅ إغلاق كامل للـ Service (للاستخدام عند إغلاق التطبيق فقط)
  Future<void> closeCompletely() async {
    _stopPolling();
    _firestoreListener.dispose();
    await _trackingSubject.close();
    _log('🗑️ Service completely closed');
  }
}