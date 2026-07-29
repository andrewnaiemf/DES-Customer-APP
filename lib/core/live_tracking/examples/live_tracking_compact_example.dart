 // ═══════════════════════════════════════════════════════════════════════════
// 📖 Live Tracking Compact Card - Usage Example
// ═══════════════════════════════════════════════════════════════════════════
// مثال توضيحي لكيفية استخدام LiveTrackingCompactCard
// مع LiveOrderTrackingService الموجود
//
// ⚠️ Important: هذا المثال يوضح كيفية الاستخدام فقط
// لم يتم تعديل أي Business Logic
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/live_order_tracking_service.dart';
import '../models/order_tracking_model.dart';
import '../widgets/live_tracking_compact_card.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Example Screen: Live Tracking with Compact Card
// ═══════════════════════════════════════════════════════════════════════════
class LiveTrackingCompactExample extends StatefulWidget {
  const LiveTrackingCompactExample({super.key});

  @override
  State<LiveTrackingCompactExample> createState() =>
      _LiveTrackingCompactExampleState();
}

class _LiveTrackingCompactExampleState
    extends State<LiveTrackingCompactExample> {
  final _trackingService = LiveOrderTrackingService();

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    await _trackingService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: const Text(
          'تتبع الطلب',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<OrderTrackingModel?>(
        // ✅ استخدام نفس الـ Stream من الـ Service الموجود
        stream: _trackingService.trackingStream,
        builder: (context, snapshot) {
          // No active tracking
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildNoTrackingState();
          }

          final tracking = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ═══════════════════════════════════════════════════════
                // 🎯 الـ Widget الجديد - Live Activity Style
                // ═══════════════════════════════════════════════════════
                LiveTrackingCompactCard(
                  tracking: tracking,
                  showDriverInfo: true,
                  elevated: true,
                  onTrackOrder: () {
                    // Navigate to full tracking map
                    _navigateToTrackingMap(tracking);
                  },
                  onCallDriver: tracking.driverPhone != null
                      ? () => _callDriver(tracking.driverPhone!)
                      : null,
                ),

                const SizedBox(height: 20),

                // Additional Info Section (Optional)
                if (tracking.hasDeliveryAddress)
                  _buildDeliveryAddress(tracking),

                const SizedBox(height: 20),

                // Order Summary (Optional)
                _buildOrderSummary(tracking),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏗️ UI Components
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildNoTrackingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'لا يوجد طلب قيد التتبع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'سيظهر هنا عندما تقوم بطلب جديد',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(OrderTrackingModel tracking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C2C2E),
            Color(0xFF1C1C1E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عنوان التوصيل',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tracking.deliveryAddress!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderTrackingModel tracking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C2C2E),
            Color(0xFF1C1C1E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الطلب',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'رقم الطلب',
            '#${tracking.orderReference}',
            Icons.receipt_long_rounded,
          ),
          if (tracking.totalAmount != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'الإجمالي',
              tracking.formattedAmount,
              Icons.payment_rounded,
            ),
          ],
          if (tracking.startTime != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'وقت الطلب',
              _formatDateTime(tracking.startTime!),
              Icons.access_time_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.6),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Actions
  // ═══════════════════════════════════════════════════════════════════════

  void _navigateToTrackingMap(OrderTrackingModel tracking) {
    // Navigate to full tracking map screen
    // يمكنك هنا الانتقال إلى شاشة الخريطة الكاملة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('الانتقال إلى خريطة التتبع...'),
        backgroundColor: Color(0xFF0A84FF),
      ),
    );
  }

  Future<void> _callDriver(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن الاتصال بالسائق'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Helper Methods
  // ═══════════════════════════════════════════════════════════════════════

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';

    return '${dateTime.day}/${dateTime.month} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Example 2: Compact Banner Usage
// ═══════════════════════════════════════════════════════════════════════════
// استخدام الـ Banner المصغر في أعلى الشاشة (في Home مثلاً)

class HomeScreenWithTrackingBanner extends StatelessWidget {
  const HomeScreenWithTrackingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final trackingService = LiveOrderTrackingService();

    return Scaffold(
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // 🔔 Live Tracking Banner - يظهر في أعلى الشاشة
          // ═══════════════════════════════════════════════════════════════
          StreamBuilder<OrderTrackingModel?>(
            stream: trackingService.trackingStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox.shrink();
              }

              final tracking = snapshot.data!;

              // Only show banner if tracking is active
              if (!tracking.isActive) {
                return const SizedBox.shrink();
              }

              return SafeArea(
                child: LiveTrackingCompactBanner(
                  tracking: tracking,
                  onTap: () {
                    // Navigate to full tracking screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LiveTrackingCompactExample(),
                      ),
                    );
                  },
                  onDismiss: () {
                    // Optional: minimize the banner
                  },
                ),
              );
            },
          ),

          // ═══════════════════════════════════════════════════════════════
          // 🏠 Rest of your home screen content
          // ═══════════════════════════════════════════════════════════════
          Expanded(
            child: Center(
              child: Text(
                'محتوى الشاشة الرئيسية',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Example 3: Integration with Existing Screens
// ═══════════════════════════════════════════════════════════════════════════
// كيفية استبدال الـ Widget القديم بالجديد في الشاشات الموجودة

/*
// ❌ الطريقة القديمة (TrackingCard)
TrackingCard(
  tracking: tracking,
  onTap: () => _navigateToDetails(),
  onCallDriver: () => _callDriver(),
  showTimeline: true,
  compact: false,
)

// ✅ الطريقة الجديدة (LiveTrackingCompactCard)
LiveTrackingCompactCard(
  tracking: tracking,  // ✅ نفس الـ Model بدون تغيير
  onTrackOrder: () => _navigateToDetails(),
  onCallDriver: () => _callDriver(),
  showDriverInfo: true,
  elevated: true,
)
*/

// ═══════════════════════════════════════════════════════════════════════════
// 🔄 Example 4: Using with StreamBuilder (Recommended)
// ═══════════════════════════════════════════════════════════════════════════

class TrackingWidgetExample extends StatelessWidget {
  const TrackingWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderTrackingModel?>(
      // ✅ استخدام نفس الـ Service الموجود - بدون أي تعديل في Logic
      stream: LiveOrderTrackingService().trackingStream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF0A84FF)),
            ),
          );
        }

        // No data
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final tracking = snapshot.data!;

        // ✅ عرض الـ Widget الجديد مع البيانات الموجودة
        return LiveTrackingCompactCard(
          tracking: tracking,
          onTrackOrder: () {
            // Your navigation logic
          },
          onCallDriver: tracking.driverPhone != null
              ? () {
                  // Your call logic
                }
              : null,
        );
      },
    );
  }
}
