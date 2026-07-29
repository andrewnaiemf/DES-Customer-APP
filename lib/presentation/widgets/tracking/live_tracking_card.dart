import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/tracking/tracking_cubit.dart';
import '../../../business_logic/tracking/tracking_state.dart';
import 'package:easy_localization/easy_localization.dart';

/// بطاقة التتبع المباشر على شاشة الطلبات
/// Live tracking card on orders screen
class LiveTrackingCard extends StatelessWidget {
  final VoidCallback? onTap;

  const LiveTrackingCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingCubit, TrackingState>(
      builder: (context, state) {
        // Don't show card if no active tracking
        if (!state.hasActiveTracking || state.currentTrackingData == null) {
          return const SizedBox.shrink();
        }

        final trackingData = state.currentTrackingData!;
        final orderId = trackingData['orderId'] as String? ?? '';
        final displayOrderId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
        final status = trackingData['shippingStatus'] as String? ?? '';
        final statusAr = _getStatusTextAr(status);
        final statusEn = _getStatusTextEn(status);
        final progress = _getProgressValue(status);
        final statusColor = _getStatusColor(status);

        return Dismissible(
          key: Key('live_tracking_$orderId'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            context.read<TrackingCubit>().stopTracking();
          },
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.1),
                    statusColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated wave pattern
                  _buildWavePattern(statusColor),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Live badge
                        Row(
                          children: [
                            _buildLiveBadge(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.locale.languageCode == 'ar'
                                        ? 'تتبع مباشر'
                                        : 'Live Tracking',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '#$displayOrderId',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                context.read<TrackingCubit>().stopTracking();
                              },
                              color: Colors.grey[600],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _getStatusIcon(status),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.locale.languageCode == 'ar'
                                        ? statusAr
                                        : statusEn,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 8,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Status description
                        Text(
                          _getStatusDescription(status, context),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء شارة Live النابضة
  /// Build pulsing Live badge
  Widget _buildLiveBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(value * 0.5),
                blurRadius: 10 * value,
                spreadRadius: 2 * value,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(value),
                      blurRadius: 6 * value,
                      spreadRadius: 2 * value,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
      onEnd: () {
        // Loop animation
      },
    );
  }

  /// بناء نمط الأمواج المتحركة
  /// Build animated wave pattern
  Widget _buildWavePattern(Color color) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _WavePainter(color: color),
        ),
      ),
    );
  }

  // Helper methods for status
  String _getStatusTextAr(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      case 'shipped':
        return 'تم الشحن';
      case 'out_for_delivery':
        return 'في الطريق للتوصيل';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  String _getStatusTextEn(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  double _getProgressValue(String status) {
    switch (status) {
      case 'pending':
        return 0.1;
      case 'processing':
        return 0.3;
      case 'shipped':
        return 0.5;
      case 'out_for_delivery':
        return 0.8;
      case 'delivered':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.0;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'out_for_delivery':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Icon _getStatusIcon(String status) {
    IconData iconData;
    switch (status) {
      case 'pending':
        iconData = Icons.hourglass_empty;
        break;
      case 'processing':
        iconData = Icons.settings;
        break;
      case 'shipped':
        iconData = Icons.local_shipping;
        break;
      case 'out_for_delivery':
        iconData = Icons.delivery_dining;
        break;
      case 'delivered':
        iconData = Icons.check_circle;
        break;
      case 'cancelled':
        iconData = Icons.cancel;
        break;
      default:
        iconData = Icons.help_outline;
    }
    return Icon(iconData, size: 16, color: _getStatusColor(status));
  }

  String _getStatusDescription(String status, BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    switch (status) {
      case 'pending':
        return isAr ? 'طلبك قيد المراجعة' : 'Your order is under review';
      case 'processing':
        return isAr ? 'جاري تجهيز طلبك' : 'Your order is being prepared';
      case 'shipped':
        return isAr ? 'تم شحن طلبك' : 'Your order has been shipped';
      case 'out_for_delivery':
        return isAr ? 'طلبك في الطريق إليك' : 'Your order is on its way';
      case 'delivered':
        return isAr ? 'تم توصيل طلبك بنجاح' : 'Your order has been delivered';
      case 'cancelled':
        return isAr ? 'تم إلغاء طلبك' : 'Your order has been cancelled';
      default:
        return isAr ? 'حالة غير معروفة' : 'Unknown status';
    }
  }
}

/// رسام نمط الأمواج
/// Wave pattern painter
class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    // Create wave pattern
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.7 + 20 * (i % 40 < 20 ? 1 : -1),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
