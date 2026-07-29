import 'package:app/core/responsive/responsive.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io'; // ✅ للتحقق من المنصة (iOS/Android)

import 'package:app/business_logic/orders/cubit/orders_cubit.dart';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/data/constants/order_status.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/order/order_model.dart';
import 'package:app/models/order_item/order_item_model.dart';
import 'package:app/models/orderhistory/order_history_model.dart';
import 'package:app/persentation/widgets/Loading_widget.dart';
import 'package:app/persentation/widgets/buttons.dart';
import 'package:app/persentation/widgets/image_loading.dart';
import 'package:app/persentation/widgets/my_scaffold.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide AnimatedBuilder;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../business_logic/products/cubit/products_cubit.dart';
import '../../../functions/downloadPDF.dart';
import '../../../models/product/product_model.dart';
import '../../../models/selected_products/selected_products.dart';
import '../../widgets/image_slider.dart';
import '../../widgets/textFormField.dart';

// Live Tracking Imports
import 'package:app/core/live_tracking/services/live_order_tracking_service.dart';
import 'package:app/core/live_tracking/models/order_tracking_model.dart';
import 'package:app/core/live_tracking/widgets/live_tracking_compact_card.dart';
import 'package:url_launcher/url_launcher.dart';

// ==================== App Theme Colors ====================
class AppTheme {
  static const Color yellow = Color.fromRGBO(215, 178, 27, 1);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color red = Color(0xFFFF4757);
  static const Color green = Color(0xFF2ED573);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFFF9F43);
}

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen(
      {super.key, required this.orderModel, this.withEdit});

  final OrderModel orderModel;
  final bool? withEdit;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with TickerProviderStateMixin {
  bool isEditProduct = false;
  static List<SelectedProductsModel> currentList = [];
  List<ProductModel>? searchedProducts;
  TextEditingController searchController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ✅ Live Tracking Animation Controllers
  late AnimationController _trackingPulseController;
  late Animation<double> _trackingPulseAnimation;
  late AnimationController _trackingProgressController;

  // ✅ Live Tracking Variables
  StreamSubscription<OrderTrackingModel?>? _trackingSubscription;
  OrderTrackingModel? _currentTrackingData;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isRTL => context.locale.languageCode == 'ar';

  // Status helpers
  Color get _statusColor {
    if (widget.orderModel.status == OrderStatus.declined ||
        widget.orderModel.status == OrderStatus.canceled) {
      return AppTheme.red;
    }
    if (widget.orderModel.shippingStatus == OrderShippingStatus.delivered) {
      return AppTheme.lightGreen;
    }
    return AppTheme.yellow;
  }

  String get _statusText {
    if (widget.orderModel.shippingStatus == OrderShippingStatus.delivered) {
      return 'Delivered'.tr();
    }
    return '${widget.orderModel.status}'.tr();
  }

  IconData get _statusIcon {
    if (widget.orderModel.status == OrderStatus.declined ||
        widget.orderModel.status == OrderStatus.canceled) {
      return Icons.cancel_rounded;
    }
    if (widget.orderModel.shippingStatus == OrderShippingStatus.delivered) {
      return Icons.check_circle_rounded;
    }
    return Icons.schedule_rounded;
  }

  @override
  void initState() {
    super.initState();
    ProductsCubit.get(context).getProducts();
    currentList = [];
    fillData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
      ),
    );

    // ✅ Initialize Live Tracking Animations - فقط للطلبات النشطة
    if (_shouldShowLiveTracking()) {
      _trackingPulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);

      _trackingPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(
          parent: _trackingPulseController,
          curve: Curves.easeInOut,
        ),
      );

      _trackingProgressController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..repeat();
    } else {
      // ✅ تهيئة بدون تشغيل لتجنب null errors
      _trackingPulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      _trackingPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(
          parent: _trackingPulseController,
          curve: Curves.easeInOut,
        ),
      );
      _trackingProgressController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      );
    }

    _animationController.forward();

    // 🚀 Start Live Tracking if order is active
    _initializeLiveTracking();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🚀 Live Tracking Initialization
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> _initializeLiveTracking() async {
    if (_shouldShowLiveTracking()) {
      try {
        final trackingService = LiveOrderTrackingService();

        // Create tracking model from order
        final trackingModel = OrderTrackingModel.fromOrderData(
          orderId: widget.orderModel.id.toString(),
          orderReference:
          widget.orderModel.reference ?? widget.orderModel.id.toString(),
          shippingStatus: widget.orderModel.shippingStatus ?? 'pending',
          orderDate: widget.orderModel.checkoutDate,
          driverName: null,
          driverPhone: null,
          estimatedDeliveryTime: null,
          deliveryAddress: widget.orderModel.location,
          totalAmount: widget.orderModel.totalWithTax,
        );

        // Start tracking
        await trackingService.startTracking(trackingModel);

        // ✅ Listen to tracking updates
        _trackingSubscription = trackingService.trackingStream.listen(
              (tracking) {
            if (mounted &&
                tracking?.orderId == widget.orderModel.id.toString()) {
              setState(() {
                _currentTrackingData = tracking;
              });
            }
          },
        );

        // Set initial data
        _currentTrackingData = trackingService.currentTracking;

        log('✅ Live Tracking started for order: ${widget.orderModel.reference}');
      } catch (e) {
        log('⚠️ Live Tracking init error: $e');
      }
    }
  }

  // Check if order should show live tracking
  bool _shouldShowLiveTracking() {
    if (widget.orderModel.shippingStatus == OrderShippingStatus.delivered ||
        widget.orderModel.status == OrderStatus.declined ||
        widget.orderModel.status == OrderStatus.canceled) {
      return false;
    }
    return true;
  }

  void fillData() async {
    for (int i = 0; i < widget.orderModel.orderItems!.length; i++) {
      currentList.add(SelectedProductsModel(
        productModel: widget.orderModel.orderItems![i].product,
        qty: double.parse(
            "${widget.orderModel.orderItems![i].quantity.trim()}")
            .toInt(),
        price: double.parse(
            "${widget.orderModel.orderItems![i].unitPrice.trim()}")
            .toInt(),
      ));
    }
    if (widget.withEdit != null && widget.withEdit == true) {
      isEditProduct = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _trackingPulseController.dispose();
    _trackingProgressController.dispose();
    _trackingSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Order Details'.tr(),
      subtitle: '#${widget.orderModel.id}',
      showBackButton: true,
      actions: [
        if (widget.orderModel.delivery_document_url != null &&
            widget.orderModel.delivery_document_url != "")
          GradientAction(
            icon: Icons.download_rounded,
            onTap: () async {
              HapticFeedback.mediumImpact();
              await DownloadPDFClass.downloadPDF(
                "${widget.orderModel.customer!.name}${widget.orderModel.id}",
                '${ApiConstants.stoarge}${widget.orderModel.delivery_document_url}',
              );
            },
          ),
      ],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 20)),
              child: Column(
                children: [
                  // 🚀 Live Tracking Card (if active)
                  if (_shouldShowLiveTracking()) ...[
                    _buildPremiumLiveTrackingCard(),
                    SizedBox(height: ResponsiveUtils.spacing(context, 24)),
                  ],

                  // Order Status Header
                  _buildStatusHeader(),
                  SizedBox(height: ResponsiveUtils.spacing(context, 24)),

                  // Products Section
                  _buildProductsSection(),
                  SizedBox(height: ResponsiveUtils.spacing(context, 20)),

                  // Price Details Card
                  _buildPriceDetailsCard(),
                  SizedBox(height: ResponsiveUtils.spacing(context, 20)),

                  // Timeline Section
                  _buildTimelineSection(),
                  SizedBox(height: ResponsiveUtils.spacing(context, 20)),

                  // Action Buttons
                  _buildActionButtons(),

                  // Decline Reason
                  if (widget.orderModel.status == "Declined" &&
                      widget.orderModel.declineReason != null)
                    _buildDeclineReason(),

                  // Delivery Note Section
                  _buildDeliveryNoteSection(),

                  // Order Images
                  _buildOrderImages(),

                  SizedBox(height: ResponsiveUtils.spacing(context, 40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚀 Premium Live Tracking Card - تصميم مطور بالكامل
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPremiumLiveTrackingCard() {
    final tracking = _currentTrackingData;

    // If no tracking data, create from order
    final trackingStatus = _getTrackingStatusFromOrder();
    final trackingColor = _getTrackingColorForStatus(trackingStatus);
    final trackingIcon = _getTrackingIconForStatus(trackingStatus);

    return AnimatedBuilder(
      animation: _trackingPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _trackingPulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 28)),
              boxShadow: [
                BoxShadow(
                  color: trackingColor.withOpacity(_isDark ? 0.3 : 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 28)),
              child: Container(
                decoration: BoxDecoration(
                  color: _isDark ? AppTheme.dark : Colors.white,
                  borderRadius:
                  BorderRadius.circular(ResponsiveUtils.radius(context, 28)),
                  border: Border.all(
                    color: trackingColor.withOpacity(_isDark ? 0.4 : 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // ✅ Animated Top Gradient Bar
                    _buildAnimatedTopBar(trackingColor),

                    // ✅ Main Content
                    Padding(
                      padding: EdgeInsets.all(
                          ResponsiveUtils.spacing(context, 20)),
                      child: Column(
                        children: [
                          // Header with Live Badge
                          _buildTrackingHeader(
                              trackingStatus, trackingColor, trackingIcon),

                          SizedBox(
                              height: ResponsiveUtils.spacing(context, 20)),

                          // Progress Steps
                          _buildTrackingProgressSteps(
                              trackingStatus, trackingColor),

                          SizedBox(
                              height: ResponsiveUtils.spacing(context, 20)),

                          // Delivery Info Row
                          _buildDeliveryInfoRow(tracking, trackingColor),

                          // Driver Info (if available)
                          if (tracking?.driverName != null) ...[
                            SizedBox(
                                height: ResponsiveUtils.spacing(context, 16)),
                            _buildDriverInfoCard(tracking!),
                          ],

                          SizedBox(
                              height: ResponsiveUtils.spacing(context, 16)),

                          // Action Buttons Row
                          _buildTrackingActionButtons(tracking, trackingColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 Animated Top Bar
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAnimatedTopBar(Color trackingColor) {
    return AnimatedBuilder(
      animation: _trackingProgressController,
      builder: (context, child) {
        return Container(
          height: ResponsiveUtils.spacing(context, 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                trackingColor.withOpacity(0.3),
                trackingColor,
                trackingColor.withOpacity(0.3),
              ],
              stops: [
                0,
                _trackingProgressController.value,
                1,
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📍 Tracking Header with Live Badge
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTrackingHeader(
      OrderTrackingStatus status,
      Color trackingColor,
      IconData trackingIcon,
      ) {
    return Row(
      children: [
        // Icon Container with Glow
        Container(
          width: ResponsiveUtils.size(context, 56),
          height: ResponsiveUtils.size(context, 56),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                trackingColor,
                trackingColor.withOpacity(0.7),
              ],
            ),
            borderRadius:
            BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
            boxShadow: [
              BoxShadow(
                color: trackingColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            trackingIcon,
            color: Colors.white,
            size: ResponsiveUtils.icon(context, 28),
          ),
        ),

        SizedBox(width: ResponsiveUtils.spacing(context, 14)),

        // Title & Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Live Pulsing Badge
                  _buildLiveBadge(trackingColor),
                  SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                  Expanded(
                    child: Text(
                      _getTrackingStatusText(status).tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 16),
                        fontWeight: FontWeight.bold,
                        color: _isDark ? Colors.white : AppTheme.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.spacing(context, 4)),
              Text(
                '${'Order'.tr()}: #${widget.orderModel.id}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 13),
                  color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Refresh Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _initializeLiveTracking();
          },
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppTheme.lightGray,
              borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: _isDark ? AppTheme.darkGray : Colors.grey[600],
              size: ResponsiveUtils.icon(context, 20),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔴 Live Pulsing Badge
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLiveBadge(Color trackingColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 10),
        vertical: ResponsiveUtils.spacing(context, 4),
      ),
      decoration: BoxDecoration(
        color: trackingColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 10)),
        border: Border.all(
          color: trackingColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: trackingColor),
          SizedBox(width: ResponsiveUtils.spacing(context, 5)),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 10),
              fontWeight: FontWeight.w800,
              color: trackingColor,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 Tracking Progress Steps
  // ✨ Works on ALL platforms (Android + iOS)
  // 🔄 Real-time updates with live status
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTrackingProgressSteps(
      OrderTrackingStatus status, Color trackingColor) {
    // 🎨 Show beautiful progress steps on all platforms
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.05)
            : AppTheme.lightGray.withOpacity(0.7),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 18)),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.08)
              : AppTheme.darkGray.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          // Step 1: Pending
          _buildProgressStep(
            icon: Icons.pending_actions_rounded,
            label: 'Pending'.tr(),
            isCompleted: status.index >= OrderTrackingStatus.orderPlaced.index,
            isActive: status == OrderTrackingStatus.orderPlaced,
            activeColor: trackingColor,
          ),

          _buildProgressConnector(
            isCompleted: status.index > OrderTrackingStatus.orderPlaced.index,
            activeColor: trackingColor,
          ),

          // Step 2: Preparing
          _buildProgressStep(
            icon: Icons.inventory_2_rounded,
            label: 'Preparing'.tr(),
            isCompleted: status.index >= OrderTrackingStatus.preparing.index,
            isActive: status == OrderTrackingStatus.preparing,
            activeColor: trackingColor,
          ),

          _buildProgressConnector(
            isCompleted: status.index > OrderTrackingStatus.preparing.index,
            activeColor: trackingColor,
          ),

          // Step 3: On The Way
          _buildProgressStep(
            icon: Icons.local_shipping_rounded,
            label: 'On Way'.tr(),
            isCompleted:
            status.index >= OrderTrackingStatus.outForDelivery.index,
            isActive: status == OrderTrackingStatus.outForDelivery,
            activeColor: trackingColor,
          ),

          _buildProgressConnector(
            isCompleted: status == OrderTrackingStatus.delivered,
            activeColor: trackingColor,
          ),

          // Step 4: Delivered
          _buildProgressStep(
            icon: Icons.check_circle_rounded,
            label: 'Delivered'.tr(),
            isCompleted: status == OrderTrackingStatus.delivered,
            isActive: status == OrderTrackingStatus.delivered,
            activeColor: trackingColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isActive,
    required Color activeColor,
  }) {
    final containerSize = ResponsiveUtils.size(context, 40);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              gradient: isCompleted || isActive
                  ? LinearGradient(
                colors: [
                  activeColor,
                  activeColor.withOpacity(0.7),
                ],
              )
                  : null,
              color: isCompleted || isActive
                  ? null
                  : (_isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppTheme.darkGray.withOpacity(0.2)),
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isCompleted || isActive
                  ? Colors.white
                  : (_isDark ? AppTheme.darkGray : Colors.grey[500]),
              size: ResponsiveUtils.icon(context, 18),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 8)),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 10),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? activeColor
                  : (_isDark ? AppTheme.darkGray : Colors.grey[600]),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressConnector({
    required bool isCompleted,
    required Color activeColor,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 3,
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.spacing(context, 24),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: isCompleted
              ? LinearGradient(
            colors: [activeColor, activeColor.withOpacity(0.7)],
          )
              : null,
          color: isCompleted
              ? null
              : (_isDark
              ? Colors.white.withOpacity(0.15)
              : AppTheme.darkGray.withOpacity(0.3)),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📋 Delivery Info Row
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDeliveryInfoRow(
      OrderTrackingModel? tracking, Color trackingColor) {
    // ✅ عرض عنوان التوصيل فقط (حذف الوقت المتوقع)
    return _buildInfoCard(
      icon: Icons.location_on_rounded,
      label: 'Delivery Address'.tr(),
      value: widget.orderModel.location ?? 'Not specified'.tr(),
      color: AppTheme.purple,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 14)),
      decoration: BoxDecoration(
        color: _isDark ? Colors.white.withOpacity(0.05) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
        border: Border.all(
          color:
          _isDark ? Colors.white.withOpacity(0.08) : color.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: ResponsiveUtils.icon(context, 16),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 6)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 11),
                    color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 8)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 13),
              fontWeight: FontWeight.w600,
              color: _isDark ? Colors.white : AppTheme.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚗 Driver Info Card
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDriverInfoCard(OrderTrackingModel tracking) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [
            AppTheme.purple.withOpacity(0.15),
            AppTheme.purple.withOpacity(0.05),
          ]
              : [
            AppTheme.purple.withOpacity(0.08),
            AppTheme.purple.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
        border: Border.all(
          color: AppTheme.purple.withOpacity(_isDark ? 0.25 : 0.12),
        ),
      ),
      child: Row(
        children: [
          // Driver Avatar
          Container(
            width: ResponsiveUtils.size(context, 50),
            height: ResponsiveUtils.size(context, 50),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple, AppTheme.purple.withOpacity(0.7)],
              ),
              borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(tracking.driverName ?? 'D'),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: ResponsiveUtils.spacing(context, 14)),

          // Driver Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 11),
                    color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 3)),
                Text(
                  tracking.driverName ?? '',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 15),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                if (tracking.driverPhone != null) ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: ResponsiveUtils.icon(context, 13),
                        color: AppTheme.lightGreen,
                      ),
                      SizedBox(width: ResponsiveUtils.spacing(context, 5)),
                      Text(
                        tracking.driverPhone!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.font(context, 12),
                          color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Rating Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 12),
              vertical: ResponsiveUtils.spacing(context, 8),
            ),
            decoration: BoxDecoration(
              color: AppTheme.yellow.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppTheme.yellow,
                  size: ResponsiveUtils.icon(context, 16),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                Text(
                  '4.9',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 13),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 Tracking Action Buttons
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTrackingActionButtons(
      OrderTrackingModel? tracking, Color trackingColor) {
    // ✅ عرض زر الاتصال بالسائق فقط (حذف زر تتبع على الخريطة)
    if (tracking?.driverPhone == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _callDriver(tracking!.driverPhone!),
      child: Container(
        height: ResponsiveUtils.buttonHeight(context, 50),
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.lightGray,
          borderRadius:
          BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
          border: Border.all(
            color: _isDark
                ? Colors.white.withOpacity(0.15)
                : AppTheme.darkGray.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_rounded,
              color: AppTheme.lightGreen,
              size: ResponsiveUtils.icon(context, 20),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 6)),
            Text(
              'Call'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 14),
                fontWeight: FontWeight.w600,
                color: _isDark ? Colors.white : AppTheme.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 Helper Methods
  // ═══════════════════════════════════════════════════════════════════════════

  OrderTrackingStatus _getTrackingStatusFromOrder() {
    if (widget.orderModel.status == OrderStatus.declined) {
      return OrderTrackingStatus.cancelled;
    }
    if (widget.orderModel.status == OrderStatus.canceled) {
      return OrderTrackingStatus.cancelled;
    }
    if (widget.orderModel.shippingStatus == OrderShippingStatus.delivered) {
      return OrderTrackingStatus.delivered;
    }
    if (widget.orderModel.shippingStatus == OrderShippingStatus.delivery) {
      return OrderTrackingStatus.outForDelivery;
    }
    if (widget.orderModel.shippingStatus == OrderShippingStatus.processing) {
      return OrderTrackingStatus.preparing;
    }
    return OrderTrackingStatus.orderPlaced;
  }

  Color _getTrackingColorForStatus(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return AppTheme.orange;
      case OrderTrackingStatus.preparing:
        return AppTheme.purple;
      case OrderTrackingStatus.outForDelivery:
        return AppTheme.blue;
      case OrderTrackingStatus.delivered:
        return AppTheme.lightGreen;
      case OrderTrackingStatus.cancelled:
        return AppTheme.red;
      default:
        return status.color;
    }
  }

  IconData _getTrackingIconForStatus(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return Icons.pending_actions_rounded;
      case OrderTrackingStatus.preparing:
        return Icons.inventory_2_rounded;
      case OrderTrackingStatus.outForDelivery:
        return Icons.local_shipping_rounded;
      case OrderTrackingStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderTrackingStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return status.icon;
    }
  }

  String _getTrackingStatusText(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return 'Order Pending';
      case OrderTrackingStatus.preparing:
        return 'Preparing Order';
      case OrderTrackingStatus.outForDelivery:
        return 'On The Way';
      case OrderTrackingStatus.delivered:
        return 'Delivered';
      case OrderTrackingStatus.cancelled:
        return 'Cancelled';
      default:
        return status.englishText;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'D';
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatEstimatedTime(String? isoTime) {
    if (isoTime == null) return '--:--';
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return '--:--';
    }
  }

  Future<void> _callDriver(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      HapticFeedback.mediumImpact();
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('Error calling driver: $e');
    }
  }

  // ==================== Status Header ====================
  Widget _buildStatusHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _statusColor.withOpacity(0.15),
            _statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 24)),
        border: Border.all(
          color: _statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon,
              color: _statusColor,
              size: ResponsiveUtils.icon(context, 32),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 16)),
          // Order Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Order Number'.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 12),
                        color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.spacing(context, 10),
                        vertical: ResponsiveUtils.spacing(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: _isDark
                            ? AppTheme.purple.withOpacity(0.2)
                            : AppTheme.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius(context, 12)),
                      ),
                      child: Text(
                        '#${widget.orderModel.id}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.font(context, 13),
                          fontWeight: FontWeight.bold,
                          color:
                          _isDark ? AppTheme.lightGreen : AppTheme.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 8)),
                Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 20),
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
                if (widget.orderModel.customer?.name != null) ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                  Text(
                    widget.orderModel.customer!.name,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 14),
                      color: _isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 5)),
                  if(widget.orderModel.is_offer==true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 14,
                            color:  AppTheme.purple,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Offer'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:AppTheme.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Products Section ====================
  Widget _buildProductsSection() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 20)),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.dark : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 24)),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withOpacity(0.3)
                : AppTheme.purple.withOpacity(0.08),
            blurRadius: ResponsiveUtils.radius(context, 20),
            offset: Offset(0, ResponsiveUtils.spacing(context, 8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                    EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? AppTheme.purple.withOpacity(0.2)
                          : AppTheme.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius(context, 12)),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                      size: ResponsiveUtils.icon(context, 20),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 12)),
                  Text(
                    'Products'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 18),
                      fontWeight: FontWeight.bold,
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                ],
              ),
              // Edit Button
              if (!isEditProduct &&
                  widget.orderModel.status != OrderStatus.canceled &&
                  widget.orderModel.status != OrderStatus.declined &&
                  widget.orderModel.shippingStatus !=
                      OrderShippingStatus.delivered &&widget.orderModel.is_offer!=true)
                _buildEditButton(),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 20)),

          // Products List
          if (!isEditProduct)
            ...List.generate(
              widget.orderModel.orderItems?.length ?? 0,
                  (index) =>
                  _buildProductItem(widget.orderModel.orderItems![index]),
            )
          else
            _buildEditProductsSection(),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => isEditProduct = true);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, 14),
            vertical: ResponsiveUtils.spacing(context, 8)),
        decoration: BoxDecoration(
          color: _isDark
              ? AppTheme.purple.withOpacity(0.2)
              : AppTheme.purple.withOpacity(0.1),
          borderRadius:
          BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_outlined,
              size: ResponsiveUtils.icon(context, 16),
              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 6)),
            Text(
              'Edit'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 13),
                fontWeight: FontWeight.w600,
                color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(OrderItemModel orderItem) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 16)),
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.05)
            : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
      ),
      child: Row(
        children: [
          // Product Image
          Hero(
            tag: 'product_${orderItem.product.id}',
            child: Container(
              width: ResponsiveUtils.size(context, 70),
              height: ResponsiveUtils.size(context, 70),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(ResponsiveUtils.radius(context, 14)),
                child: loadingImage(
                  image:
                  ApiConstants.stoarge + "${orderItem.product.picture}",
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 14)),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderItem.product.nameAr.toString(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                Text(
                  orderItem.product.description.toString(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 12),
                    color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if(widget.orderModel.is_offer!=true)
                  SizedBox(height: ResponsiveUtils.spacing(context, 8)),
                if(widget.orderModel.is_offer!=true)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.spacing(context, 10),
                      vertical: ResponsiveUtils.spacing(context, 4)),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? AppTheme.lightGreen.withOpacity(0.15)
                        : AppTheme.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius(context, 8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${orderItem.unitPrice}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.font(context, 13),
                          fontWeight: FontWeight.bold,
                          color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                      context.getCurrencyWidget(
                        height: ResponsiveUtils.font(context,25),
                        color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quantity Badge
          Container(
            width: ResponsiveUtils.spacing(context, 45),
            height: ResponsiveUtils.spacing(context, 45),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDark
                    ? [
                  AppTheme.purple.withOpacity(0.3),
                  AppTheme.lightGreen.withOpacity(0.2)
                ]
                    : [
                  AppTheme.purple.withOpacity(0.15),
                  AppTheme.lightGreen.withOpacity(0.1)
                ],
              ),
              borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
            ),
            child: Center(
              child: Text(
                'x${double.parse(orderItem.quantity.toString()).toInt()}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 16),
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.white : AppTheme.purple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Edit Products Section ====================
  Widget _buildEditProductsSection() {
    return Column(
      children: [
        // Editable Products List
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentList.length,
          separatorBuilder: (_, __) =>
              SizedBox(height: ResponsiveUtils.spacing(context, 16)),
          itemBuilder: (context, index) => _buildEditableProductCard(index),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 20)),

        // Add Product Button
        _buildAddProductButton(),
        SizedBox(height: ResponsiveUtils.spacing(context, 16)),

        // Save Button
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildEditableProductCard(int index) {
    final product = currentList[index];
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: _isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 20)),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.darkGray.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Product Info Row
          Row(
            children: [
              if (product.productModel.picture != null)
                Container(
                  width: ResponsiveUtils.size(context, 60),
                  height: ResponsiveUtils.size(context, 60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius(context, 12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius(context, 12)),
                    child: loadingImage(
                      image: ApiConstants.stoarge +
                          product.productModel.picture!,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(width: ResponsiveUtils.spacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.locale.languageCode == 'ar'
                          ? product.productModel.nameAr ?? ""
                          : product.productModel.nameEn ?? "",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.w600,
                        color: _isDark ? Colors.white : AppTheme.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                    Text(
                      product.productModel.description ?? "",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 12),
                        color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Delete Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => currentList.removeAt(index));
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius(context, 10)),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.red,
                    size: ResponsiveUtils.icon(context, 20),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 16)),

          // Quantity Control
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity'.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 12),
                        color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.spacing(context, 8)),
                    _buildQuantityControl(index),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price'.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 12),
                        color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.spacing(context, 8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.spacing(context, 16),
                          vertical: ResponsiveUtils.spacing(context, 12)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isDark
                              ? [
                            AppTheme.lightGreen.withOpacity(0.2),
                            AppTheme.lightGreen.withOpacity(0.1)
                          ]
                              : [
                            AppTheme.purple.withOpacity(0.1),
                            AppTheme.lightGreen.withOpacity(0.05)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius(context, 12)),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(product.price ?? 0) * (product.qty ?? 0)}',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.font(context, 14),
                                fontWeight: FontWeight.bold,
                                color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                            context.getCurrencyWidget(
                              height: ResponsiveUtils.font(context, 25),
                              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, 8),
          vertical: ResponsiveUtils.spacing(context, 6)),
      decoration: BoxDecoration(
        color: _isDark ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.darkGray.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuantityButton(
            icon: Icons.add_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => currentList[index].qty += 1);
            },
          ),
          Text(
            '${currentList[index].qty}',
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 18),
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : AppTheme.black,
            ),
          ),
          _buildQuantityButton(
            icon: Icons.remove_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              if (currentList[index].qty > 1) {
                setState(() => currentList[index].qty -= 1);
              } else {
                setState(() => currentList.removeAt(index));
              }
            },
            isDecrease: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isDecrease = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
        decoration: BoxDecoration(
          color: isDecrease
              ? (_isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.darkGray.withOpacity(0.3))
              : AppTheme.purple,
          borderRadius:
          BorderRadius.circular(ResponsiveUtils.radius(context, 8)),
        ),
        child: Icon(
          icon,
          size: ResponsiveUtils.icon(context, 18),
          color: isDecrease
              ? (_isDark ? AppTheme.darkGray : Colors.grey[600])
              : Colors.white,
        ),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return GestureDetector(
      onTap: () => _showAddProductSheet(),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, 20),
            vertical: ResponsiveUtils.spacing(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
          ),
          borderRadius:
          BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purple.withOpacity(0.4),
              blurRadius: ResponsiveUtils.radius(context, 15),
              offset: Offset(0, ResponsiveUtils.spacing(context, 6)),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white),
            SizedBox(width: ResponsiveUtils.spacing(context, 10)),
            Text(
              'Add Product'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 15),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: _isDark ? AppTheme.dark : Colors.white,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ResponsiveUtils.radius(context, 28))),
              ),
              child: Column(
                children: [
                  SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                  Container(
                    width: ResponsiveUtils.spacing(context, 40),
                    height: ResponsiveUtils.spacing(context, 4),
                    decoration: BoxDecoration(
                      color: _isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius(context, 2)),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 20)),
                  Text(
                    'Add Product'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 18),
                      fontWeight: FontWeight.bold,
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 20)),

                  // Search Field
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.spacing(context, 20)),
                    child: _buildSearchField(setModalState),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 16)),

                  // Products List
                  Expanded(
                    child: BlocBuilder<ProductsCubit, ProductsState>(
                      builder: (context, state) {
                        if (state is ProductsGetLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        List<ProductModel> products = searchedProducts ??
                            ProductsCubit.get(context).allProducts;

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                              ResponsiveUtils.spacing(context, 20)),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildSelectableProductCard(products[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchField(StateSetter setModalState) {
    return Container(
      decoration: BoxDecoration(
        color:
        _isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.darkGray.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: ResponsiveUtils.spacing(context, 16)),
          Icon(
            Icons.search_rounded,
            color: _isDark ? AppTheme.darkGray : Colors.grey,
          ),
          Expanded(
            child: TextField(
              controller: searchController,
              style: TextStyle(
                color: _isDark ? Colors.white : AppTheme.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search products...'.tr(),
                hintStyle: TextStyle(
                  color: _isDark ? AppTheme.darkGray : Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing(context, 12),
                    vertical: ResponsiveUtils.spacing(context, 14)),
              ),
              onChanged: (value) {
                setModalState(() {
                  if (value.isNotEmpty) {
                    searchedProducts = ProductsCubit.get(context)
                        .allProducts
                        .where((e) => e.nameAr!
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                        .toList();
                  } else {
                    searchedProducts = null;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableProductCard(ProductModel product) {
    final isAlreadyAdded =
    currentList.any((e) => e.productModel.id == product.id);

    return GestureDetector(
      onTap: () {
        if (!isAlreadyAdded) {
          HapticFeedback.mediumImpact();
          setState(() {
            currentList.add(SelectedProductsModel(
              productModel: product,
              qty: 0,
              price: double.parse("${product.customers!.first.pivot.price}")
                  .toInt(),
            ));
          });
          Navigator.pop(context);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 12)),
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 14)),
        decoration: BoxDecoration(
          color: isAlreadyAdded
              ? AppTheme.lightGreen.withOpacity(0.1)
              : (_isDark
              ? Colors.white.withOpacity(0.05)
              : AppTheme.lightGray),
          borderRadius:
          BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
          border: isAlreadyAdded
              ? Border.all(color: AppTheme.lightGreen.withOpacity(0.5))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveUtils.size(context, 60),
              height: ResponsiveUtils.size(context, 60),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
                child: loadingImage(
                  image: ApiConstants.stoarge + "${product.picture}",
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameAr ?? "",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 14),
                      fontWeight: FontWeight.w600,
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                  Text(
                    product.description ?? "",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 12),
                      color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.customers?.isNotEmpty ?? false) ...[
                    SizedBox(height: ResponsiveUtils.spacing(context, 6)),
                    Row(
                      children: [
                        Text(
                          '${product.customers!.first.pivot.price}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.font(context, 13),
                            fontWeight: FontWeight.bold,
                            color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                        context.getCurrencyWidget(
                          height: ResponsiveUtils.font(context, 25),
                          color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isAlreadyAdded
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              color: isAlreadyAdded ? AppTheme.lightGreen : AppTheme.purple,
              size: ResponsiveUtils.icon(context, 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<OrdersCubit>().editOrder(
          context: context,
          orderId: widget.orderModel.id.toString(),
          currentList: currentList,
        );
        setState(() => isEditProduct = false);
      },
      child: Container(
        width: double.infinity,
        padding:
        EdgeInsets.symmetric(vertical: ResponsiveUtils.spacing(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.lightGreen, AppTheme.lightGreen.withGreen(254)],
          ),
          borderRadius:
          BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightGreen.withOpacity(0.4),
              blurRadius: ResponsiveUtils.radius(context, 15),
              offset: Offset(0, ResponsiveUtils.spacing(context, 6)),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Save'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 16),
              fontWeight: FontWeight.bold,
              color: AppTheme.dark,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Price Details Card ====================
  Widget _buildPriceDetailsCard() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 24)),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.dark : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 24)),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withOpacity(0.3)
                : AppTheme.purple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppTheme.lightGreen.withOpacity(0.2)
                      : AppTheme.lightGreen.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                  size: ResponsiveUtils.icon(context, 20),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 12)),
              Text(
                'Price Details'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 18),
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.white : AppTheme.black,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 20)),

          if(widget.orderModel.is_offer!=true)
          Column(children: [
            // Total
            _buildPriceRow('Total'.tr(), valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.orderModel.total}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                context.getCurrencyWidget(
                  height: ResponsiveUtils.font(context, 25),
                  color: _isDark ? Colors.white : AppTheme.black,
                ),
              ],
            )),
            _buildDivider(),

            // Loyalty Points
            if (widget.orderModel.loyaltyPoints != null &&
                widget.orderModel.loyaltyPoints != 0) ...[
              _buildPriceRow(
                'Loyalty Points'.tr(),
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.orderModel.loyaltyPoints}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightGreen,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                    context.getCurrencyWidget(
                      height: ResponsiveUtils.font(context, 25),
                      color: AppTheme.lightGreen,
                    ),
                  ],
                ),
              ),
              _buildDivider(),
            ],
            // Total After Discount
            if (widget.orderModel.loyaltyDiscount != null &&
                double.parse("${widget.orderModel.loyaltyDiscount}") != 0) ...[
              _buildPriceRow(
                'Total After Discount'.tr(),
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${double.parse("${widget.orderModel.total}") - double.parse("${widget.orderModel.loyaltyDiscount}")}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.bold,
                        color: _isDark ? Colors.white : AppTheme.black,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                    context.getCurrencyWidget(
                      height: ResponsiveUtils.font(context, 25),
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                  ],
                ),
              ),
              _buildDivider(),
            ],

            // Tax
            _buildPriceRow('Tax'.tr(), valueWidget: _calculateTaxWidget()),
            _buildDivider(),

            // Total Including Tax
            _buildPriceRow(
              'Total (Including Tax)'.tr(),
              valueWidget: _calculateFinalTotalWidget(),
              isTotal: true,
            ),
          ],),

          // Total Including Tax
          if(widget.orderModel.is_offer==true)
            Column(
              children: [
                _buildPriceRow('Total'.tr(), isTotal: true,valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.orderModel.offer?.specialPrice}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.bold,
                        color: _isDark ? Colors.white : AppTheme.black,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                    context.getCurrencyWidget(
                      height: ResponsiveUtils.font(context, 25),
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                  ],
                )),
                _buildDivider(),
                _buildPriceRow('Tax'.tr(), isTotal: true,valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.orderModel.offer?.specialPriceTax}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.bold,
                        color: _isDark ? Colors.white : AppTheme.black,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                    context.getCurrencyWidget(
                      height: ResponsiveUtils.font(context, 25),
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                  ],
                )),
                _buildDivider(),
                _buildPriceRow('Total (Including Tax)'.tr(), isTotal: true,valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.orderModel.offer?.specialPriceAfterTax}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.bold,
                        color: _isDark ? Colors.white : AppTheme.black,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                    context.getCurrencyWidget(
                      height: ResponsiveUtils.font(context, 25),
                      color: _isDark ? Colors.white : AppTheme.black,
                    ),
                  ],
                )),
              ],
            ),

        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, {String? value, Widget? valueWidget,
      Color? valueColor, bool isTotal = false}) {
    return Padding(
      padding:
      EdgeInsets.symmetric(vertical: ResponsiveUtils.spacing(context, 8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, isTotal ? 15 : 14),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: _isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          valueWidget ?? Text(
            value ?? '',
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, isTotal ? 17 : 14),
              fontWeight: FontWeight.bold,
              color: valueColor ?? (_isDark ? Colors.white : AppTheme.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin:
      EdgeInsets.symmetric(vertical: ResponsiveUtils.spacing(context, 4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _isDark
                ? Colors.white.withOpacity(0.1)
                : AppTheme.darkGray.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _calculateTaxWidget() {
    String taxValue;
    if (widget.orderModel.loyaltyDiscount != null &&
        double.parse("${widget.orderModel.loyaltyDiscount}") != 0) {
      final afterDiscount = double.parse("${widget.orderModel.total}") -
          double.parse("${widget.orderModel.loyaltyDiscount}");
      taxValue = (afterDiscount * 0.15).toStringAsFixed(1);
    } else {
      taxValue = (double.parse("${widget.orderModel.total}") * 0.15).toStringAsFixed(1);
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          taxValue,
          style: TextStyle(
            fontSize: ResponsiveUtils.font(context, 14),
            fontWeight: FontWeight.bold,
            color: _isDark ? Colors.white : AppTheme.black,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 4)),
        context.getCurrencyWidget(
          height: ResponsiveUtils.font(context, 25),
          color: _isDark ? Colors.white : AppTheme.black,
        ),
      ],
    );
  }

  Widget _calculateFinalTotalWidget() {
    String totalValue;
    if (widget.orderModel.loyaltyDiscount != null &&
        double.parse("${widget.orderModel.loyaltyDiscount}") != 0) {
      final afterDiscount = double.parse("${widget.orderModel.total}") -
          double.parse("${widget.orderModel.loyaltyDiscount}");
      final withTax = afterDiscount + (afterDiscount * 0.15);
      totalValue = withTax.toStringAsFixed(1);
    } else {
      totalValue = '${widget.orderModel.totalWithTax}';
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          totalValue,
          style: TextStyle(
            fontSize: ResponsiveUtils.font(context, 17),
            fontWeight: FontWeight.bold,
            color: _isDark ? Colors.white : AppTheme.black,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 4)),
        context.getCurrencyWidget(
          height: ResponsiveUtils.font(context, 25),
          color: _isDark ? Colors.white : AppTheme.black,
        ),
      ],
    );
  }

  // ==================== Timeline Section ====================
  Widget _buildTimelineSection() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 24)),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.dark : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 24)),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withOpacity(0.3)
                : AppTheme.purple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppTheme.purple.withOpacity(0.2)
                      : AppTheme.purple.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                  size: ResponsiveUtils.icon(context, 20),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 12)),
              Text(
                'Order Timeline'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 18),
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.white : AppTheme.black,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 24)),

          // Timeline Items
          if (widget.orderModel.status == OrderStatus.draft ||
              widget.orderModel.status == OrderStatus.approved) ...[
            _buildTimelineItem(
              title: 'Pending'.tr(),
              isActive: true,
              isFirst: true,
              history: widget.orderModel.orderHistory!
                  .where((e) => e.event == "created_at")
                  .toList(),
            ),
            _buildTimelineItem(
              title: 'Been Approved'.tr(),
              isActive: widget.orderModel.status == OrderStatus.approved,
              history: widget.orderModel.orderHistory!
                  .where((e) => e.event == "received_order")
                  .toList(),
            ),
            _buildTimelineItem(
              title: 'The Order Is Being Prepared'.tr(),
              isActive: widget.orderModel.status == OrderStatus.approved &&
                  (widget.orderModel.shippingStatus ==
                      OrderShippingStatus.processing ||
                      widget.orderModel.shippingStatus ==
                          OrderShippingStatus.delivery ||
                      widget.orderModel.shippingStatus ==
                          OrderShippingStatus.delivered),
              history: widget.orderModel.orderHistory!
                  .where((e) => e.event == "processing_order")
                  .toList(),
            ),
            _buildTimelineItem(
              title: 'Delivery Is In Progress'.tr(),
              isActive: widget.orderModel.status == OrderStatus.approved &&
                  (widget.orderModel.shippingStatus ==
                      OrderShippingStatus.delivery ||
                      widget.orderModel.shippingStatus ==
                          OrderShippingStatus.delivered),
              history: widget.orderModel.orderHistory!
                  .where((e) => e.event == "delivery_order")
                  .toList(),
            ),
            _buildTimelineItem(
              title: 'Delivered'.tr(),
              isActive: widget.orderModel.shippingStatus ==
                  OrderShippingStatus.delivered,
              isLast: true,
              history: widget.orderModel.orderHistory!
                  .where((e) => e.event == "delivered_order")
                  .toList(),
            ),
          ],

          if (widget.orderModel.status == OrderStatus.declined)
            _buildTimelineItem(
              title: 'Declined'.tr(),
              isActive: true,
              isFirst: true,
              isLast: true,
              isFailed: true,
              history: widget.orderModel.orderHistory!
                  .where((e) => e.event == "declined_order")
                  .toList(),
            ),

          if (widget.orderModel.status == OrderStatus.canceled)
            _buildTimelineItem(
              title: 'Canceled'.tr(),
              isActive: true,
              isFirst: true,
              isLast: true,
              isFailed: true,
              history: widget.orderModel.orderHistory!
                  .where((e) => e.event == "canceled_order")
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required bool isActive,
    bool isFirst = false,
    bool isLast = false,
    bool isFailed = false,
    List<OrderHistory>? history,
  }) {
    final color = isFailed
        ? AppTheme.red
        : (isActive ? AppTheme.lightGreen : AppTheme.darkGray);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Line & Dot
        Column(
          children: [
            Container(
              width: ResponsiveUtils.size(context, 24),
              height: ResponsiveUtils.size(context, 24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: isActive
                  ? Icon(
                isFailed ? Icons.close_rounded : Icons.check_rounded,
                size: ResponsiveUtils.icon(context, 14),
                color: color,
              )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: ResponsiveUtils.spacing(context, 50),
                color: isActive
                    ? color
                    : AppTheme.darkGray.withOpacity(0.3),
              ),
          ],
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 16)),

        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: isLast ? 0 : ResponsiveUtils.spacing(context, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? (_isDark ? Colors.white : AppTheme.black)
                        : (_isDark ? AppTheme.darkGray : Colors.grey),
                  ),
                ),
                if (history != null && history.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                  Text(
                    '${formatTime(DateTime.parse(history[0].createdAt!))} • ${history[0].createdAt!.substring(0, 10)}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 12),
                      color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Action Buttons ====================
  Widget _buildActionButtons() {
    if (widget.orderModel.status != OrderStatus.draft)
      return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 20)),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.read<OrdersCubit>().cancelOrder(
            context: context,
            orderId: widget.orderModel.id.toString(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.spacing(context, 16)),
          decoration: BoxDecoration(
            color: AppTheme.red.withOpacity(0.1),
            borderRadius:
            BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
            border: Border.all(color: AppTheme.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined,
                  color: AppTheme.red,
                  size: ResponsiveUtils.icon(context, 22)),
              SizedBox(width: ResponsiveUtils.spacing(context, 10)),
              Text(
                'Cancel Order'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 15),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Decline Reason ====================
  Widget _buildDeclineReason() {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 20)),
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
      decoration: BoxDecoration(
        color: AppTheme.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
        border: Border.all(color: AppTheme.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.red),
          SizedBox(width: ResponsiveUtils.spacing(context, 12)),
          Expanded(
            child: Text(
              widget.orderModel.declineReason!,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 14),
                color: _isDark ? Colors.white : AppTheme.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Delivery Note Section ====================
  Widget _buildDeliveryNoteSection() {
    return Column(
      children: [
        if (widget.orderModel.shippingStatus == OrderShippingStatus.delivered &&
            widget.orderModel.signature_image != null &&
            widget.orderModel.delivery_document_url == "")
          Container(
            margin:
            EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 20)),
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
            decoration: BoxDecoration(
              color: AppTheme.yellow.withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
              border: Border.all(color: AppTheme.yellow.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: AppTheme.yellow),
                SizedBox(width: ResponsiveUtils.spacing(context, 12)),
                Text(
                  'Waiting for delivery note'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.w500,
                    color: AppTheme.yellow,
                  ),
                ),
              ],
            ),
          ),
        if (widget.orderModel.delivery_document_url != null &&
            widget.orderModel.delivery_document_url != "")
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              await DownloadPDFClass.downloadPDF(
                "${widget.orderModel.customer!.name}${widget.orderModel.id}",
                '${ApiConstants.stoarge}${widget.orderModel.delivery_document_url}',
              );
            },
            child: Container(
              margin:
              EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 20)),
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 16)),
              decoration: BoxDecoration(
                color: _isDark ? AppTheme.dark : Colors.white,
                borderRadius:
                BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
                border: Border.all(
                  color: _isDark
                      ? Colors.white.withOpacity(0.1)
                      : AppTheme.darkGray.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isDark
                        ? Colors.black.withOpacity(0.2)
                        : AppTheme.purple.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                    EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius(context, 10)),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: AppTheme.purple,
                      size: ResponsiveUtils.icon(context, 22),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 14)),
                  Expanded(
                    child: Text(
                      'Delivery note'.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 15),
                        fontWeight: FontWeight.w500,
                        color: _isDark ? Colors.white : AppTheme.black,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? AppTheme.lightGreen.withOpacity(0.2)
                          : AppTheme.lightGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius(context, 10)),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: AppTheme.lightGreen,
                      size: ResponsiveUtils.icon(context, 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ==================== Order Images ====================
  Widget _buildOrderImages() {
    if (widget.orderModel.confirmationImages == null ||
        widget.orderModel.confirmationImages!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 10)),
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppTheme.purple.withOpacity(0.2)
                      : AppTheme.purple.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(ResponsiveUtils.radius(context, 12)),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                  size: ResponsiveUtils.icon(context, 20),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 12)),
              Text(
                'Delivery Images'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 16),
                  fontWeight: FontWeight.bold,
                  color: _isDark ? Colors.white : AppTheme.black,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 16)),
          ImageSlider(images: widget.orderModel.confirmationImages!),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔴 Pulsing Dot Widget - نقطة متحركة للدلالة على التحديث التلقائي
// ═══════════════════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: ResponsiveUtils.size(context, 8),
          height: ResponsiveUtils.size(context, 8),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.5),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}