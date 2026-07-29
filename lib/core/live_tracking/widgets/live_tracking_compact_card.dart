// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Live Tracking Compact Card - Premium Live Activity Style
// ═══════════════════════════════════════════════════════════════════════════
// Widget مدمج لعرض حالة التتبع بأسلوب Live Activity
// مستوحى من تطبيقات: HungerStation / AlBaik / Uber Eats
//
// ✅ Features:
// - تصميم Compact وسريع الفهم
// - ألوان داكنة Modern (Black/Dark Gray)
// - Progress Bar أفقي
// - Accent Color واضح حسب الحالة
// - CTA Button (Track Order)
// - بدون Timeline - فقط المعلومات الأساسية
//
// ⚠️ Important: هذا الـ Widget لا يحتوي على أي Business Logic
// يعتمد بالكامل على OrderTrackingModel الموجود
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../models/order_tracking_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Live Activity Colors
// ═══════════════════════════════════════════════════════════════════════════
class LiveActivityColors {
  LiveActivityColors._();

  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color cardBackground = Color(0xFF2C2C2E);
  static const Color lightGray = Color(0xFF48484A);
  static const Color mediumGray = Color(0xFF636366);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAEAEB2);
  static const Color divider = Color(0xFF38383A);

  // Status Accent Colors
  static const Color yellowAccent = Color(0xFFFFD60A);
  static const Color greenAccent = Color(0xFF30D158);
  static const Color blueAccent = Color(0xFF0A84FF);
  static const Color purpleAccent = Color(0xFFBF5AF2);
  static const Color redAccent = Color(0xFFFF453A);
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Live Tracking Compact Card
// ═══════════════════════════════════════════════════════════════════════════
class LiveTrackingCompactCard extends StatefulWidget {
  final OrderTrackingModel tracking;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onCallDriver;
  final bool showDriverInfo;
  final bool elevated;
  final EdgeInsetsGeometry? margin;

  const LiveTrackingCompactCard({
    super.key,
    required this.tracking,
    this.onTrackOrder,
    this.onCallDriver,
    this.showDriverInfo = true,
    this.elevated = true,
    this.margin,
  });

  @override
  State<LiveTrackingCompactCard> createState() =>
      _LiveTrackingCompactCardState();
}

class _LiveTrackingCompactCardState extends State<LiveTrackingCompactCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: widget.elevated
            ? [
                BoxShadow(
                  color: _getAccentColor().withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                LiveActivityColors.cardBackground,
                LiveActivityColors.darkBackground,
              ],
            ),
          ),
          child: Column(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Order Info + Status
                    _buildHeader(),

                    const SizedBox(height: 20),

                    // Status Info with Icon
                    _buildStatusInfo(),

                    const SizedBox(height: 16),

                    // Progress Bar
                    _buildProgressBar(),

                    // Driver Info
                    if (widget.showDriverInfo && widget.tracking.hasDriverInfo) ...[
                      const SizedBox(height: 16),
                      _buildDriverInfo(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏗️ Build Methods
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Row(
      children: [
        // Order Icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getAccentColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getAccentColor().withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            _getStatusIcon(),
            color: _getAccentColor(),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),

        // Order Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طلب #${widget.tracking.orderReference}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LiveActivityColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getAccentColor(),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getAccentColor().withOpacity(0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.tracking.statusText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getAccentColor(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Progress Percentage Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getAccentColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getAccentColor().withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            '${widget.tracking.progressPercent}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getAccentColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiveActivityColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LiveActivityColors.lightGray.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: LiveActivityColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.tracking.statusDescription,
              style: const TextStyle(
                fontSize: 14,
                color: LiveActivityColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقدم',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: LiveActivityColors.textSecondary,
              ),
            ),
            Text(
              _getProgressLabel(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getAccentColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Progress Bar Container
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: LiveActivityColors.lightGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Animated Progress
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth *
                        widget.tracking.progressPercentage,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getAccentColor(),
                          _getAccentColor().withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _getAccentColor().withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Progress Steps Indicators
        _buildProgressSteps(),
      ],
    );
  }

  Widget _buildProgressSteps() {
    final steps = [
      OrderTrackingStatus.orderPlaced,
      OrderTrackingStatus.preparing,
      OrderTrackingStatus.outForDelivery,
      OrderTrackingStatus.delivered,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.map((status) {
        final isCompleted = widget.tracking.status.isCompletedFor(status);
        final isCurrent = widget.tracking.status == status;

        return Column(
          children: [
            Container(
              width: isCurrent ? 10 : 6,
              height: isCurrent ? 10 : 6,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? _getAccentColor()
                    : LiveActivityColors.mediumGray,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: _getAccentColor().withOpacity(0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              status.shortDescription,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCompleted || isCurrent
                    ? LiveActivityColors.textPrimary
                    : LiveActivityColors.mediumGray,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LiveActivityColors.lightGray.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: LiveActivityColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Driver Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getAccentColor().withOpacity(0.3),
                  _getAccentColor().withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.tracking.driverImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.tracking.driverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person_rounded,
                        color: _getAccentColor(),
                        size: 24,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: _getAccentColor(),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),

          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'السائق',
                  style: TextStyle(
                    fontSize: 11,
                    color: LiveActivityColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.tracking.driverName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: LiveActivityColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Call Button
          if (widget.tracking.driverPhone != null && widget.onCallDriver != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onCallDriver?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      LiveActivityColors.greenAccent,
                      LiveActivityColors.greenAccent.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: LiveActivityColors.greenAccent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Helper Methods
  // ═══════════════════════════════════════════════════════════════════════

  Color _getAccentColor() {
    switch (widget.tracking.status) {
      case OrderTrackingStatus.orderPlaced:
        return LiveActivityColors.purpleAccent;
      case OrderTrackingStatus.preparing:
        return LiveActivityColors.yellowAccent;
      case OrderTrackingStatus.outForDelivery:
        return LiveActivityColors.blueAccent;
      case OrderTrackingStatus.delivered:
        return LiveActivityColors.greenAccent;
      case OrderTrackingStatus.cancelled:
        return LiveActivityColors.redAccent;
      default:
        return widget.tracking.status.color;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.tracking.status) {
      case OrderTrackingStatus.orderPlaced:
        return Icons.receipt_long_rounded;
      case OrderTrackingStatus.preparing:
        return Icons.inventory_2_rounded;
      case OrderTrackingStatus.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderTrackingStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderTrackingStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return widget.tracking.status.icon;
    }
  }

  String _getProgressLabel() {
    switch (widget.tracking.status) {
      case OrderTrackingStatus.orderPlaced:
        return 'بدأنا بطلبك';
      case OrderTrackingStatus.preparing:
        return 'جاري التحضير الآن';
      case OrderTrackingStatus.outForDelivery:
        return 'في الطريق إليك';
      case OrderTrackingStatus.delivered:
        return 'تم التسليم بنجاح';
      case OrderTrackingStatus.cancelled:
        return 'تم الإلغاء';
      default:
        return widget.tracking.status.arabicText;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔔 Live Tracking Compact Banner - Floating Version
// ═══════════════════════════════════════════════════════════════════════════
// نسخة مصغرة للعرض كـ Banner عائم في أعلى الشاشة
class LiveTrackingCompactBanner extends StatelessWidget {
  final OrderTrackingModel tracking;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const LiveTrackingCompactBanner({
    super.key,
    required this.tracking,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LiveActivityColors.cardBackground,
              LiveActivityColors.darkBackground,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _getAccentColor().withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getAccentColor().withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getAccentColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getAccentColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'طلب #${tracking.orderReference}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: LiveActivityColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _getAccentColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tracking.statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getAccentColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getAccentColor(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${tracking.progressPercent}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Dismiss Button
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onDismiss?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: LiveActivityColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getAccentColor() {
    switch (tracking.status) {
      case OrderTrackingStatus.orderPlaced:
        return LiveActivityColors.purpleAccent;
      case OrderTrackingStatus.preparing:
        return LiveActivityColors.yellowAccent;
      case OrderTrackingStatus.outForDelivery:
        return LiveActivityColors.blueAccent;
      case OrderTrackingStatus.delivered:
        return LiveActivityColors.greenAccent;
      case OrderTrackingStatus.cancelled:
        return LiveActivityColors.redAccent;
      default:
        return tracking.status.color;
    }
  }

  IconData _getStatusIcon() {
    switch (tracking.status) {
      case OrderTrackingStatus.orderPlaced:
        return Icons.receipt_long_rounded;
      case OrderTrackingStatus.preparing:
        return Icons.inventory_2_rounded;
      case OrderTrackingStatus.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderTrackingStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderTrackingStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return tracking.status.icon;
    }
  }
}
