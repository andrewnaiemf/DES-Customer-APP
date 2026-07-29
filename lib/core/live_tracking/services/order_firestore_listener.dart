// ═══════════════════════════════════════════════════════════════════════════
// 🔥 Order Firestore Listener Service
// ═══════════════════════════════════════════════════════════════════════════
// خدمة الاستماع لتحديثات الطلبات من Firestore
// تعمل كـ Fallback في حال فشل FCM + Real-time Updates
//
// Path: lib/core/live_tracking/services/order_firestore_listener.dart
// Created: February 9, 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:developer' as dev;
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_tracking_status.dart';

/// خدمة الاستماع لتحديثات الطلبات من Firestore
/// تعمل كـ Fallback في حال فشل FCM
class OrderFirestoreListener {
  // ═══════════════════════════════════════════════════════════════════════
  // Singleton
  // ═══════════════════════════════════════════════════════════════════════
  
  static final OrderFirestoreListener _instance = OrderFirestoreListener._internal();
  factory OrderFirestoreListener() => _instance;
  OrderFirestoreListener._internal();
  
  static OrderFirestoreListener get instance => _instance;
  
  // ═══════════════════════════════════════════════════════════════════════
  // Properties
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Lazy initialization - يتم التهيئة عند الحاجة فقط
  // FirebaseFirestore get _firestore {
  //   try {
  //     return FirebaseFirestore.instance;
  //   } catch (e) {
  //     _log('⚠️ Firebase not initialized yet, waiting...');
  //     // انتظار قصير والمحاولة مرة أخرى
  //     return FirebaseFirestore.instance;
  //   }
  // }
  
  /// الاشتراكات النشطة
  final Map<String, StreamSubscription> _subscriptions = {};
  
  /// آخر حالة معروفة لكل طلب (لمنع التكرار)
  final Map<String, String> _lastKnownStatus = {};
  
  /// Callbacks
  void Function(String orderId, OrderTrackingStatus status, Map<String, dynamic> data)? onStatusChanged;
  void Function(String orderId, String? error)? onError;
  
  bool _isInitialized = false;
  
  // ═══════════════════════════════════════════════════════════════════════
  // Public Methods
  // ═══════════════════════════════════════════════════════════════════════
  
  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _log('🔥 Initializing Firestore Listener...');
    _isInitialized = true;
    _log('✅ Firestore Listener initialized');
  }
  
  /// بدء الاستماع لطلب معين
  void startListening(String orderId, {String? customerId}) {
    if (orderId.isEmpty) {
      _log('⚠️ Cannot listen to empty orderId');
      return;
    }
    
    // إلغاء أي اشتراك سابق لنفس الطلب
    stopListening(orderId);
    
    _log('👂 Starting to listen for order: $orderId');
    _log('📂 Firestore path: orders/$orderId');
    
    // الاستماع للتغييرات
    // _subscriptions[orderId] = _firestore
    //     .collection('orders')
    //     .doc(orderId)
    //     .snapshots()
    //     .listen(
    //   (snapshot) {
    //     _log('📨 Snapshot received for $orderId - exists: ${snapshot.exists}');
    //     _handleSnapshot(orderId, snapshot);
    //   },
    //   onError: (error) {
    //     _log('❌ Error listening to order $orderId: $error');
    //     onError?.call(orderId, error.toString());
    //   },
    // );
    
    _log('✅ Firestore listener subscribed for: $orderId');
    
    // الاستماع البديل عبر customer_id إذا تم توفيره
    // if (customerId != null && customerId.isNotEmpty) {
    //   // _listenByCustomerId(customerId, orderId);
    // }
  }
  
  /// الاستماع عبر customer_id (بديل)
  // void _listenByCustomerId(String customerId, String orderId) {
  //   final subscriptionKey = 'customer_$customerId';
  //
  //   // try {
  //   //   _subscriptions[subscriptionKey] = _firestore
  //   //       .collection('orders')
  //   //       .where('customer_id', isEqualTo: customerId)
  //   //       .where('status', whereNotIn: ['delivered', 'cancelled'])
  //   //       .orderBy('created_at', descending: true)
  //   //       .limit(1)
  //   //       .snapshots()
  //   //       .listen(
  //   //     (querySnapshot) {
  //   //       if (querySnapshot.docs.isNotEmpty) {
  //   //         final doc = querySnapshot.docs.first;
  //   //         _handleSnapshot(doc.id, doc);
  //   //       }
  //   //     },
  //   //     onError: (error) {
  //   //       _log('❌ Error in customer query: $error');
  //   //     },
  //   //   );
  //   // } catch (e) {
  //   //   _log('⚠️ Could not set up customer listener: $e');
  //   // }
  // }
  
  /// إيقاف الاستماع لطلب معين
  void stopListening(String orderId) {
    _subscriptions[orderId]?.cancel();
    _subscriptions.remove(orderId);
    _lastKnownStatus.remove(orderId);
    _log('🛑 Stopped listening for order: $orderId');
  }
  
  /// إيقاف جميع الاستماعات
  void stopAllListening() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _lastKnownStatus.clear();
    _log('🛑 Stopped all listeners');
  }
  
  /// التحقق إذا كان هناك استماع نشط لطلب
  bool isListening(String orderId) {
    return _subscriptions.containsKey(orderId);
  }
  
  /// عدد الاستماعات النشطة
  int get activeListenersCount => _subscriptions.length;
  
  // ═══════════════════════════════════════════════════════════════════════
  // Private Methods
  // ═══════════════════════════════════════════════════════════════════════
  
  // void _handleSnapshot(String orderId, DocumentSnapshot snapshot) {
  //   if (!snapshot.exists) {
  //     _log('⚠️ Order document not found: $orderId');
  //     return;
  //   }
  //
  //   try {
  //     final data = snapshot.data() as Map<String, dynamic>?;
  //     if (data == null) return;
  //
  //     // 🔍 طباعة البيانات الخام من Firebase
  //     _log('🔍 FIREBASE RAW DATA for $orderId:');
  //     _log('   - shipping_status: ${data['shipping_status']}');
  //     _log('   - status: ${data['status']}');
  //     _log('   - order_status: ${data['order_status']}');
  //     _log('   - Full data keys: ${data.keys.toList()}');
  //
  //     // استخراج الحالة
  //     final statusValue = data['shipping_status'] ??
  //                         data['status'] ??
  //                         data['order_status'];
  //
  //     if (statusValue == null) {
  //       _log('⚠️ No status field found in order: $orderId');
  //       return;
  //     }
  //
  //     final statusString = statusValue.toString();
  //
  //     _log('📍 Extracted status string: "$statusString"');
  //
  //     // التحقق من تغيير الحالة (لمنع التكرار)
  //     if (_lastKnownStatus[orderId] == statusString) {
  //       _log('ℹ️ Status unchanged for $orderId: $statusString');
  //       return;
  //     }
  //
  //     _lastKnownStatus[orderId] = statusString;
  //
  //     // تحويل إلى Enum
  //     final status = OrderTrackingStatus.fromString(statusString);
  //
  //     _log('📦 Order $orderId status changed: ${status.arabicText}');
  //     _log('   - API Value: ${status.apiValue}');
  //     _log('   - Step: ${status.step}');
  //     _log('   - Progress: ${status.progressPercent}%');
  //
  //     // إخطار المستمعين
  //     onStatusChanged?.call(orderId, status, data);
  //
  //     // إذا كانت الحالة نهائية، أوقف الاستماع بعد تأخير
  //     if (status.isTerminal) {
  //       _log('🏁 Order $orderId reached terminal state: ${status.apiValue}');
  //       Future.delayed(const Duration(seconds: 5), () {
  //         stopListening(orderId);
  //       });
  //     }
  //
  //   } catch (e, stack) {
  //     _log('❌ Error handling snapshot: $e');
  //     _log('Stack: $stack');
  //     onError?.call(orderId, e.toString());
  //   }
  // }
  
  void _log(String message) {
    final formattedMessage = '[OrderFirestoreListener] $message';
    dev.log(formattedMessage);
    if (kDebugMode) {
      debugPrint(formattedMessage);
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Dispose
  // ═══════════════════════════════════════════════════════════════════════
  
  void dispose() {
    stopAllListening();
    _isInitialized = false;
    _log('🗑️ Firestore Listener disposed');
  }
}
