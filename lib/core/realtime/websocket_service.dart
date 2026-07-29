// // lib/core/realtime/websocket_service.dart
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:flutter/foundation.dart';
// import 'home_realtime_service.dart';
//
// class WebSocketService {
//   static final WebSocketService _instance = WebSocketService._internal();
//   factory WebSocketService() => _instance;
//   WebSocketService._internal();
//
//   WebSocketChannel? _channel;
//   StreamSubscription? _subscription;
//   bool _isConnected = false;
//
//   final HomeRealtimeService _realtimeService = HomeRealtimeService();
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 🔌 Connection
//   // ═══════════════════════════════════════════════════════════════════════
//
//   Future<void> connect(String url, {String? token}) async {
//     if (_isConnected) return;
//
//     try {
//       final uri = Uri.parse(url);
//       _channel = WebSocketChannel.connect(uri);
//
//       // إرسال التوثيق
//       if (token != null) {
//         _channel!.sink.add(jsonEncode({'type': 'auth', 'token': token}));
//       }
//
//       // الاستماع للرسائل
//       _subscription = _channel!.stream.listen(
//         _onMessage,
//         onError: _onError,
//         onDone: _onDone,
//       );
//
//       _isConnected = true;
//       debugPrint('✅ WebSocket connected to $url');
//
//     } catch (e) {
//       debugPrint('❌ WebSocket connection error: $e');
//       _scheduleReconnect();
//     }
//   }
//
//   void disconnect() {
//     _subscription?.cancel();
//     _channel?.sink.close();
//     _isConnected = false;
//     debugPrint('🔌 WebSocket disconnected');
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 📨 Message Handlers
//   // ═══════════════════════════════════════════════════════════════════════
//
//   void _onMessage(dynamic message) {
//     try {
//       final data = jsonDecode(message as String);
//       final type = data['type'] as String?;
//
//       debugPrint('📨 WebSocket message: $type');
//
//       switch (type) {
//         case 'statistics_update':
//           _handleStatisticsUpdate(data['payload']);
//           break;
//         case 'profile_update':
//           _handleProfileUpdate(data['payload']);
//           break;
//         case 'order_update':
//           _handleOrderUpdate(data['payload']);
//           break;
//         case 'tracking_update':
//           _handleTrackingUpdate(data['payload']);
//           break;
//         case 'notification':
//           _handleNotification(data['payload']);
//           break;
//       }
//
//     } catch (e) {
//       debugPrint('❌ Error parsing WebSocket message: $e');
//     }
//   }
//
//   void _handleStatisticsUpdate(Map<String, dynamic> payload) {
//     _realtimeService.pushStatisticsUpdate(StatisticsUpdate(
//       totalBalance: payload['total_balance']?.toDouble(),
//       totalDue: payload['total_due']?.toDouble(),
//       overdue: payload['overdue']?.toDouble(),
//       invoicesCount: payload['invoices_count'],
//       timestamp: DateTime.now(),
//     ));
//   }
//
//   void _handleProfileUpdate(Map<String, dynamic> payload) {
//     _realtimeService.pushProfileUpdate(ProfileUpdate(
//       name: payload['name'],
//       points: payload['points']?.toDouble(),
//       closingBalance: payload['closing_balance']?.toDouble(),
//       timestamp: DateTime.now(),
//     ));
//   }
//
//   void _handleOrderUpdate(Map<String, dynamic> payload) {
//     _realtimeService.pushOrdersUpdate(OrdersUpdate(
//       action: payload['action'],
//       timestamp: DateTime.now(),
//     ));
//
//     // تحديث فوري
//     _realtimeService.triggerImmediateRefresh();
//   }
//
//   void _handleTrackingUpdate(Map<String, dynamic> payload) {
//     // يتم التعامل معها عبر LiveOrderTrackingService
//   }
//
//   void _handleNotification(Map<String, dynamic> payload) {
//     final count = payload['unread_count'] as int? ?? 0;
//     _realtimeService.updateNotificationCount(count);
//   }
//
//   void _onError(error) {
//     debugPrint('❌ WebSocket error: $error');
//     _isConnected = false;
//     _scheduleReconnect();
//   }
//
//   void _onDone() {
//     debugPrint('🔌 WebSocket connection closed');
//     _isConnected = false;
//     _scheduleReconnect();
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 🔄 Reconnection
//   // ═══════════════════════════════════════════════════════════════════════
//
//   Timer? _reconnectTimer;
//   int _reconnectAttempts = 0;
//
//   void _scheduleReconnect() {
//     if (_reconnectAttempts >= 5) {
//       debugPrint('⚠️ Max reconnection attempts reached');
//       return;
//     }
//
//     final delay = Duration(seconds: 2 * (_reconnectAttempts + 1));
//
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(delay, () {
//       _reconnectAttempts++;
//       // connect(previousUrl);
//     });
//   }
//
//   void dispose() {
//     _reconnectTimer?.cancel();
//     disconnect();
//   }
// }