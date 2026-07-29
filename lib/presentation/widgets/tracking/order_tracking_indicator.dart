import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/tracking/tracking_cubit.dart';
import '../../../business_logic/tracking/tracking_state.dart';

/// مؤشر التتبع على بطاقة الطلب
/// Tracking indicator on order card
class OrderTrackingIndicator extends StatelessWidget {
  final String orderId;

  const OrderTrackingIndicator({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingCubit, TrackingState>(
      builder: (context, state) {
        final isTracked = state.isOrderBeingTracked(orderId);

        if (!isTracked) {
          return const SizedBox.shrink();
        }

        return _buildPulsingDot();
      },
    );
  }

  /// نقطة نابضة خضراء
  /// Pulsing green dot
  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(value * 0.6),
                blurRadius: 8 * value,
                spreadRadius: 3 * value,
              ),
            ],
          ),
        );
      },
      onEnd: () {
        // Animation will restart automatically due to rebuild
      },
    );
  }
}

/// إطار مميز للطلبات القابلة للتتبع
/// Trackable order border wrapper
class TrackableOrderBorder extends StatelessWidget {
  final String orderId;
  final Widget child;

  const TrackableOrderBorder({
    super.key,
    required this.orderId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingCubit, TrackingState>(
      builder: (context, state) {
        final isTrackable = state.isOrderTrackable(orderId);
        final isTracked = state.isOrderBeingTracked(orderId);

        if (!isTrackable) {
          return child;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTracked ? Colors.green : Colors.blue.withOpacity(0.3),
              width: isTracked ? 2 : 1,
            ),
            boxShadow: isTracked
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
    );
  }
}
