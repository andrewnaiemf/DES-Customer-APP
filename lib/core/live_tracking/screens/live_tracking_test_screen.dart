// // ═══════════════════════════════════════════════════════════════════════════
// // 🧪 Live Tracking Test Screen - لتجربة Live Activity على الآيفون
// // ═══════════════════════════════════════════════════════════════════════════
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:io';
//
// import '../services/live_order_tracking_service.dart';
// import '../models/order_tracking_model.dart';
// import '../widgets/live_tracking_compact_card.dart';
//
// class LiveTrackingTestScreen extends StatefulWidget {
//   const LiveTrackingTestScreen({super.key});
//
//   @override
//   State<LiveTrackingTestScreen> createState() => _LiveTrackingTestScreenState();
// }
//
// class _LiveTrackingTestScreenState extends State<LiveTrackingTestScreen> {
//   final _trackingService = LiveOrderTrackingService();
//   bool _isInitialized = false;
//   String _statusMessage = 'جاري التهيئة...';
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     try {
//       await _trackingService.initialize();
//       setState(() {
//         _isInitialized = true;
//         _statusMessage = '✅ جاهز للاختبار';
//       });
//     } catch (e) {
//       setState(() {
//         _statusMessage = '❌ خطأ في التهيئة: $e';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0C),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1C1C1E),
//         elevation: 0,
//         title: const Text(
//           '🧪 اختبار Live Tracking',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Status Card
//             _buildStatusCard(),
//
//             const SizedBox(height: 20),
//
//             // Platform Info
//             _buildPlatformInfo(),
//
//             const SizedBox(height: 20),
//
//             // Test Buttons
//             _buildTestButtons(),
//
//             const SizedBox(height: 20),
//
//             // Live Preview
//             StreamBuilder<OrderTrackingModel?>(
//               stream: _trackingService.trackingStream,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData || snapshot.data == null) {
//                   return const SizedBox.shrink();
//                 }
//
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.only(bottom: 12),
//                       child: Text(
//                         '📱 معاينة مباشرة',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     LiveTrackingCompactCard(
//                       tracking: snapshot.data!,
//                       onTrackOrder: () {
//                         _showMessage('تم النقر على تتبع الطلب');
//                       },
//                       onCallDriver: snapshot.data!.driverPhone != null
//                           ? () => _showMessage('محاكاة الاتصال بالسائق')
//                           : null,
//                     ),
//                   ],
//                 );
//               },
//             ),
//
//             const SizedBox(height: 20),
//
//             // Instructions
//             _buildInstructions(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF2C2C2E),
//             const Color(0xFF1C1C1E),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: _isInitialized ? Colors.green : Colors.orange,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             _isInitialized ? Icons.check_circle : Icons.sync_rounded,
//             color: _isInitialized ? Colors.green : Colors.orange,
//             size: 48,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             _statusMessage,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPlatformInfo() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C2C2E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Platform.isIOS ? Icons.apple : Icons.android,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 Platform.isIOS ? 'iOS Device' : 'Android Device',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _buildInfoRow(
//             'Platform',
//             Platform.operatingSystem,
//           ),
//           _buildInfoRow(
//             'Service',
//             _isInitialized ? 'Initialized ✅' : 'Not Ready ⏳',
//           ),
//           if (Platform.isIOS)
//             _buildInfoRow(
//               'Live Activities',
//               'iOS 16.2+ Required',
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.white.withOpacity(0.6),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTestButtons() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const Text(
//           '🎯 اختبر الحالات المختلفة',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // Order Placed
//         _buildTestButton(
//           'تم استلام الطلب',
//           '🟣 Order Placed',
//           Colors.purple,
//           () => _startTest(OrderTrackingStatus.orderPlaced),
//         ),
//
//         const SizedBox(height: 12),
//
//         // Preparing
//         _buildTestButton(
//           'جاري التحضير',
//           '🟡 Preparing',
//           const Color(0xFFFFD60A),
//           () => _startTest(OrderTrackingStatus.preparing),
//         ),
//
//         const SizedBox(height: 12),
//
//         // Out for Delivery
//         _buildTestButton(
//           'خرج للتوصيل',
//           '🔵 Out for Delivery',
//           const Color(0xFF0A84FF),
//           () => _startTest(OrderTrackingStatus.outForDelivery),
//         ),
//
//         const SizedBox(height: 12),
//
//         // Delivered
//         _buildTestButton(
//           'تم التسليم',
//           '🟢 Delivered',
//           const Color(0xFF30D158),
//           () => _startTest(OrderTrackingStatus.delivered),
//         ),
//
//         const SizedBox(height: 20),
//
//         // Update Progress
//         _buildTestButton(
//           'تحديث تلقائي (محاكاة)',
//           '⚡ Auto Progress',
//           Colors.orange,
//           _simulateProgress,
//           icon: Icons.auto_fix_high_rounded,
//         ),
//
//         const SizedBox(height: 12),
//
//         // Stop Tracking
//         _buildTestButton(
//           'إيقاف التتبع',
//           '🛑 Stop',
//           Colors.red,
//           _stopTest,
//           icon: Icons.stop_circle_rounded,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTestButton(
//     String title,
//     String subtitle,
//     Color color,
//     VoidCallback onPressed, {
//     IconData? icon,
//   }) {
//     return ElevatedButton(
//       onPressed: _isInitialized ? onPressed : null,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color.withOpacity(0.2),
//         foregroundColor: color,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: color.withOpacity(0.4)),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(icon ?? Icons.play_circle_rounded, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInstructions() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C2C2E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.blue.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.info_outline, color: Colors.blue, size: 20),
//               SizedBox(width: 8),
//               Text(
//                 'تعليمات الاختبار',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _buildInstructionItem(
//             '1',
//             'اختر حالة من الأزرار أعلاه',
//           ),
//           _buildInstructionItem(
//             '2',
//             Platform.isIOS
//                 ? 'سيظهر Live Activity في Lock Screen'
//                 : 'سيظهر إشعار دائم في Notification Bar',
//           ),
//           _buildInstructionItem(
//             '3',
//             'اضغط على زر التحديث التلقائي لمحاكاة التقدم',
//           ),
//           _buildInstructionItem(
//             '4',
//             'راقب التغييرات في الـ UI',
//           ),
//           const SizedBox(height: 8),
//           if (Platform.isIOS)
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.orange.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.warning_amber_rounded,
//                       color: Colors.orange, size: 20),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'تحتاج iOS 16.2+ لدعم Live Activities',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.orange.shade200,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInstructionItem(String number, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 number,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════
//   // 🎯 Test Actions
//   // ═══════════════════════════════════════════════════════════════════════
//
//   Future<void> _startTest(OrderTrackingStatus status) async {
//     try {
//       HapticFeedback.mediumImpact();
//
//       final testOrder = OrderTrackingModel.withDefaultSteps(
//         orderId: 'test_${DateTime.now().millisecondsSinceEpoch}',
//         orderReference: '${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}',
//         status: status,
//         driverName: status == OrderTrackingStatus.outForDelivery ||
//                 status == OrderTrackingStatus.delivered
//             ? 'أحمد محمد'
//             : null,
//         driverPhone: status == OrderTrackingStatus.outForDelivery ||
//                 status == OrderTrackingStatus.delivered
//             ? '+966501234567'
//             : null,
//         estimatedDeliveryTime:
//             status.isActive ? '${15 + status.orderIndex * 5} دقيقة' : null,
//         totalAmount: 125.50,
//       );
//
//       final success = await _trackingService.startTracking(testOrder);
//
//       if (success) {
//         _showMessage('✅ تم بدء التتبع - ${status.arabicText}');
//       } else {
//         _showMessage('❌ فشل بدء التتبع');
//       }
//     } catch (e) {
//       _showMessage('❌ خطأ: $e');
//     }
//   }
//
//   Future<void> _simulateProgress() async {
//     if (_trackingService.currentTracking == null) {
//       _showMessage('⚠️ ابدأ تتبع أولاً');
//       return;
//     }
//
//     HapticFeedback.mediumImpact();
//     _showMessage('⚡ بدء المحاكاة التلقائية...');
//
//     final statuses = [
//       OrderTrackingStatus.orderPlaced,
//       OrderTrackingStatus.preparing,
//       OrderTrackingStatus.outForDelivery,
//       OrderTrackingStatus.delivered,
//     ];
//
//     final currentIndex =
//         statuses.indexOf(_trackingService.currentTracking!.status);
//
//     for (var i = currentIndex + 1; i < statuses.length; i++) {
//       await Future.delayed(const Duration(seconds: 3));
//
//       if (!mounted) break;
//
//       final updatedOrder = _trackingService.currentTracking!.copyWith(
//         status: statuses[i],
//         driverName: i >= 2 ? 'أحمد محمد' : null,
//         driverPhone: i >= 2 ? '+966501234567' : null,
//         estimatedDeliveryTime: i < 3 ? '${15 - i * 5} دقيقة' : null,
//         lastUpdateTime: DateTime.now(),
//       );
//
//       await _trackingService.updateTracking(updatedOrder);
//       _showMessage('📊 تم التحديث - ${statuses[i].arabicText}');
//     }
//
//     _showMessage('✅ اكتملت المحاكاة');
//   }
//
//   Future<void> _stopTest() async {
//     try {
//       HapticFeedback.mediumImpact();
//       await _trackingService.stopTracking();
//       _showMessage('🛑 تم إيقاف التتبع');
//     } catch (e) {
//       _showMessage('❌ خطأ: $e');
//     }
//   }
//
//   void _showMessage(String message) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFF2C2C2E),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }
