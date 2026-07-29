// lib/core/realtime/home_realtime_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app/models/order/order_model.dart';
import 'package:app/core/live_tracking/models/order_tracking_model.dart';

/// 🔄 Home Screen Real-time Update Service
/// يدير كل التحديثات التلقائية لصفحة الهوم
class HomeRealtimeService {
  // ═══════════════════════════════════════════════════════════════════════
  // 🔒 Singleton Pattern
  // ═══════════════════════════════════════════════════════════════════════
  static final HomeRealtimeService _instance = HomeRealtimeService._internal();
  factory HomeRealtimeService() => _instance;
  HomeRealtimeService._internal();

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Stream Controllers
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Stream للإحصائيات
  final _statisticsController = StreamController<StatisticsUpdate>.broadcast();
  Stream<StatisticsUpdate> get statisticsStream => _statisticsController.stream;
  
  /// Stream للملف الشخصي
  final _profileController = StreamController<ProfileUpdate>.broadcast();
  Stream<ProfileUpdate> get profileStream => _profileController.stream;
  
  /// Stream للطلبات
  final _ordersController = StreamController<OrdersUpdate>.broadcast();
  Stream<OrdersUpdate> get ordersStream => _ordersController.stream;
  
  /// Stream للإشعارات الجديدة
  final _notificationController = StreamController<int>.broadcast();
  Stream<int> get notificationCountStream => _notificationController.stream;
  
  /// Stream عام لأي تحديث
  final _refreshController = StreamController<RefreshEvent>.broadcast();
  Stream<RefreshEvent> get refreshStream => _refreshController.stream;

  // ═══════════════════════════════════════════════════════════════════════
  // ⏱️ Polling Timer
  // ═══════════════════════════════════════════════════════════════════════
  Timer? _pollingTimer;
  bool _isPollingActive = false;
  
  /// فترة التحديث الدوري (بالثواني)
  int _pollingIntervalSeconds = 30;
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🚀 Public Methods
  // ═══════════════════════════════════════════════════════════════════════
  
  /// بدء التحديث التلقائي
  void startRealtimeUpdates({int intervalSeconds = 30}) {
    _pollingIntervalSeconds = intervalSeconds;
    _startPolling();
    debugPrint('🔄 HomeRealtimeService: Started real-time updates (${intervalSeconds}s interval)');
  }
  
  /// إيقاف التحديث التلقائي
  void stopRealtimeUpdates() {
    _stopPolling();
    debugPrint('⏹️ HomeRealtimeService: Stopped real-time updates');
  }
  
  /// تحديث فوري
  void triggerImmediateRefresh() {
    _refreshController.add(RefreshEvent(
      type: RefreshType.manual,
      timestamp: DateTime.now(),
    ));
    debugPrint('⚡ HomeRealtimeService: Triggered immediate refresh');
  }
  
  /// إرسال تحديث إحصائيات
  void pushStatisticsUpdate(StatisticsUpdate update) {
    if (!_statisticsController.isClosed) {
      _statisticsController.add(update);
    }
  }
  
  /// إرسال تحديث ملف شخصي
  void pushProfileUpdate(ProfileUpdate update) {
    if (!_profileController.isClosed) {
      _profileController.add(update);
    }
  }
  
  /// إرسال تحديث طلبات
  void pushOrdersUpdate(OrdersUpdate update) {
    if (!_ordersController.isClosed) {
      _ordersController.add(update);
    }
  }
  
  /// تحديث عدد الإشعارات
  void updateNotificationCount(int count) {
    if (!_notificationController.isClosed) {
      _notificationController.add(count);
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Private Methods
  // ═══════════════════════════════════════════════════════════════════════
  
  void _startPolling() {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    _pollingTimer = Timer.periodic(
      Duration(seconds: _pollingIntervalSeconds),
      (_) => _onPollingTick(),
    );
  }
  
  void _stopPolling() {
    _isPollingActive = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  void _onPollingTick() {
    _refreshController.add(RefreshEvent(
      type: RefreshType.polling,
      timestamp: DateTime.now(),
    ));
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🧹 Cleanup
  // ═══════════════════════════════════════════════════════════════════════
  
  void dispose() {
    _stopPolling();
    _statisticsController.close();
    _profileController.close();
    _ordersController.close();
    _notificationController.close();
    _refreshController.close();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Data Models
// ═══════════════════════════════════════════════════════════════════════════

enum RefreshType { manual, polling, websocket, push }

class RefreshEvent {
  final RefreshType type;
  final DateTime timestamp;
  final String? source;
  
  RefreshEvent({
    required this.type,
    required this.timestamp,
    this.source,
  });
}

class StatisticsUpdate {
  final double? totalBalance;
  final double? totalDue;
  final double? overdue;
  final int? invoicesCount;
  final DateTime timestamp;
  
  StatisticsUpdate({
    this.totalBalance,
    this.totalDue,
    this.overdue,
    this.invoicesCount,
    required this.timestamp,
  });
}

class ProfileUpdate {
  final String? name;
  final double? points;
  final double? closingBalance;
  final DateTime timestamp;
  
  ProfileUpdate({
    this.name,
    this.points,
    this.closingBalance,
    required this.timestamp,
  });
}

class OrdersUpdate {
  final List<OrderModel>? orders;
  final OrderModel? updatedOrder;
  final String? action; // 'add', 'update', 'delete'
  final DateTime timestamp;
  
  OrdersUpdate({
    this.orders,
    this.updatedOrder,
    this.action,
    required this.timestamp,
  });
}