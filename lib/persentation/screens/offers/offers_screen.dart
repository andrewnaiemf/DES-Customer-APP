import 'package:app/business_logic/OffersCubit/offers_cubit.dart';
import 'package:app/core/responsive/responsive.dart';
import 'package:app/core/extensions/context_extensions.dart';
import 'package:app/core/deep_links/deep_link_config.dart';
import 'package:app/core/deep_links/deep_link_service.dart';
import 'dart:developer';

// import 'package:app/business_logic/orders/cubit/orders_cubit.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/data/constants/assets.dart';
// import 'package:app/data/constants/order_status.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/offers/OffersModel.dart';
import 'package:app/persentation/screens/offers/offers_details.dart';
// import 'package:app/models/order/order_model.dart';
// import 'package:app/persentation/screens/orders/add_order_screen.dart' hide AnimatedBuilder;
// import 'package:app/persentation/screens/orders/order_details_screen.dart';
import 'package:app/persentation/widgets/Loading_widget.dart';
import 'package:app/persentation/widgets/empty_list.dart';
import 'package:app/persentation/widgets/my_scaffold.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app/business_logic/tracking/tracking_cubit.dart';
import 'package:app/business_logic/tracking/tracking_state.dart';
import 'package:app/presentation/widgets/tracking/live_tracking_card.dart';
import 'package:app/presentation/widgets/tracking/order_tracking_indicator.dart';

import '../../../business_logic/orders/cubit/orders_cubit.dart';
import '../../widgets/PremiumBackground.dart';
import '../orders/order_details_screen.dart';

// ==================== App Theme Colors (محسّن) ====================
class AppTheme {
  static const Color primary = Color(0xFF6C3FE8);

  // ألوان ثابتة - const للأداء
  static const Color yellow = Color(0xFFD7B21B);
  static const LinearGradient cardGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C3FE8), Color(0xFF9B5FF3), Color(0xFFC47EF0)],
    stops: [0.0, 0.5, 1.0],
  );
  static const Color black = Color(0xFF1D1D25);
  static const LinearGradient cardGrad = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C3FE8), Color(0xFF9B5FF3), Color(0xFFC47EF0)],
    stops: [0.0, 0.5, 1.0],
  );
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color error = Color(0xFFFF4757);

  // Gradients معرّفة مسبقاً
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple, Color(0xFF7B52FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows محسّنة
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: purple.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get darkSoftShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
}

// ==================== Spacing Constants ====================
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// ==================== Border Radius Constants ====================
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 30;
}

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // ✅ الحفاظ على حالة الشاشة عند التنقل
  @override
  bool get wantKeepAlive => true;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);

    // ✅ تحميل البيانات بعد بناء الـ Widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OffersCubit.get(context).getOffers();

      // // ✅ مزامنة أولية للتتبع - طلبات نشطة فقط
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   if (mounted) {
      //     final orders = OffersCubit.get(context).getOffers;
      //     // ✅ فلترة الطلبات النشطة فقط (غير ملغية وغير مسلمة)
      //     // final activeOrders = orders.where((order) {
      //     //   final isActive = order.status != OrderStatus.canceled &&
      //     //       order.status != OrderStatus.declined &&
      //     //       order.shippingStatus != OrderShippingStatus.delivered;
      //     //   return isActive;
      //     // }).toList();
      //     final activeOrderIds = activeOrders.map((o) => o.id.toString()).toList();
      //     context.read<TrackingCubit>().syncWithOrders(activeOrderIds);
      //   }
      // });
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _onScroll() {
    final cubit = OffersCubit.get(context);

    // // ✅ إيقاف الـ scroll listener إذا لم يكن هناك المزيد
    // if (!cubit.hasMore || cubit.isLoadingMore) {
    //   return;
    // }

    // ✅ استخدام النظام الجديد من الـ Cubit
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // cubit.loadMore();

      // ✅ مزامنة بعد التحميل - طلبات نشطة فقط
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // if (mounted) {
        //   final orders = OffersCubit.get(context).allOrders;
        //   // ✅ فلترة الطلبات النشطة فقط (غير ملغية وغير مسلمة)
        //   final activeOrders = orders.where((order) {
        //     final isActive = order.status != OrderStatus.canceled &&
        //         order.status != OrderStatus.declined &&
        //         order.shippingStatus != OrderShippingStatus.delivered;
        //     return isActive;
        //   }).toList();
        //   final activeOrderIds = activeOrders.map((o) => o.id.toString()).toList();
        //   context.read<TrackingCubit>().syncWithOrders(activeOrderIds);
        // }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ مطلوب لـ AutomaticKeepAliveClientMixin

    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        return MyScaffold(
          title: 'Offers'.tr(),
          showBackButton: true,
          showNotification: false,
          // 🔗 Share Offers (deep link)
          actions: [
            ScaffoldAction(
              icon: Icons.share_rounded,
              onTap: () => shareDeepLink(
                DeepLinkConfig.offersLink,
                message: 'share_offers_message'.tr(),
              ),
            ),
          ],
          // floatingActionButton: _buildAddOrderFAB(),
          fabLocation: FloatingActionButtonLocation.endFloat,
          // 🧪 Debug Button for Notification Test
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.notifications_active, color: Colors.amber),
          //     tooltip: 'اختبار إشعارات التتبع',
          //     onPressed: () {
          //       Navigator.pushNamed(context, '/notification_test');
          //     },
          //   ),
          // ],
          body: Column(
            children: [
              // ✅ SearchBar
              // _buildSearchBar(),

              Expanded(
                child: BlocListener<OffersCubit, OffersState>(
          listener: (context, state) {
            if (state is OffersActionSuccess) {
              if (context.mounted) {
                context.read<OrdersCubit>().getOrders();
                Navigator.pop(context);
              }
            }
          },
  child: BlocBuilder<OffersCubit, OffersState>(
                  builder: (context, state) {
                    final cubit = OffersCubit.get(context);
                    final orders = cubit.offersList;
                    // ✅ First Load Loading
                    if (state is OffersLoading ) {
                      return const _LoadingState();
                    }

                    // ✅ Empty State
                    if (orders.isEmpty) {
                      return _EmptyState(isDark: _isDark);
                    }

                    // ✅ Success with Data
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildOrdersList(orders),
                      ),
                    );
                  },
                ),
),
              ),
            ],
          ),
        );
      },
    );
  }

  // // ==================== Search Bar ====================
  // Widget _buildSearchBar() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
  //     child: TextField(
  //       controller: _searchController,
  //       onChanged: (value) => OffersCubit.get(context).search(value),
  //       style: TextStyle(
  //         color: _isDark ? Colors.white : AppTheme.black,
  //         fontSize: 15,
  //       ),
  //       decoration: InputDecoration(
  //         hintText: 'Search orders...'.tr(),
  //         hintStyle: TextStyle(
  //           color: (_isDark ? Colors.white : AppTheme.black).withOpacity(0.4),
  //           fontSize: 14,
  //         ),
  //         prefixIcon: Icon(
  //           Icons.search_rounded,
  //           color: (_isDark ? Colors.white : AppTheme.black).withOpacity(0.5),
  //           size: 22,
  //         ),
  //         suffixIcon: _searchController.text.isNotEmpty
  //             ? IconButton(
  //           icon: Icon(
  //             Icons.clear_rounded,
  //             color: (_isDark ? Colors.white : AppTheme.black).withOpacity(0.5),
  //             size: 20,
  //           ),
  //           onPressed: () {
  //             _searchController.clear();
  //             OffersCubit.get(context).search('');
  //           },
  //         )
  //             : null,
  //         filled: true,
  //         fillColor: _isDark
  //             ? Colors.white.withOpacity(0.05)
  //             : Colors.grey.withOpacity(0.08),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(AppRadius.md),
  //           borderSide: BorderSide.none,
  //         ),
  //         contentPadding: const EdgeInsets.symmetric(
  //           horizontal: 16,
  //           vertical: 12,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ==================== Premium Responsive FAB ====================
  // Widget _buildAddOrderFAB() {
  //   // ✅ استخدام safe padding بدلاً من قيمة ثابتة
  //   const kBottomNavigationBarHeight = 150.0;
  //   final bottomPadding = context.bottomSafePadding + kBottomNavigationBarHeight + 16;
  //   final isSmallScreen = MediaQuery.of(context).size.width < 360;
  //
  //   return Padding(
  //     padding: EdgeInsets.only(bottom: bottomPadding),
  //     child: _ResponsiveFAB(
  //       onPressed: () {
  //         HapticFeedback.mediumImpact();
  //         MyNavigator.navigateTo(context, const AddOrderScreen());
  //       },
  //       icon: Icons.add_rounded,
  //       label: 'Add Order'.tr(),
  //       // في الشاشات الصغيرة جداً، نعرض الأيقونة فقط
  //       showLabel: !isSmallScreen,
  //       isDark: _isDark,
  //     ),
  //   );
  // }
  // ==================== Orders List محسّن ====================
  Widget _buildOrdersList(List<OfferData> offers) {
    final cubit = OffersCubit.get(context);

    // ✅ فلترة الطلبات النشطة للمزامنة (غير ملغية وغير مسلمة)
    final activeOrders = offers.where((offer) {
      final isActive = offer.status=="Active";
      return isActive;
    }).toList();
    final activeOrderIds = activeOrders.map((o) => o.id.toString()).toList();

    return Column(
      children: [
        // ✅ Live Tracking Card
        LiveTrackingCard(
          onTap: () {
            // Navigate to order details if needed
            final trackingCubit = context.read<TrackingCubit>();
            if (trackingCubit.state.currentOrderId != null) {
              final currentOffer = offers.firstWhere(
                    (o) => o.id.toString() == trackingCubit.state.currentOrderId,
                orElse: () => offers.first,
              );
              MyNavigator.navigateTo(context, OffersDetailsScreen(offerData: currentOffer),);
            }
          },
        ),

        // ✅ Orders List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await cubit.getOffers();
              // // ✅ مزامنة بعد التحديث - طلبات نشطة فقط
              // if (context.mounted) {
              //   context.read<TrackingCubit>().syncWithOrders(activeOrderIds);
              // }
            },
            color: AppTheme.purple,
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(
                bottom: 100,
                top: 10,
                left: 20,
                right: 20,
              ),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemCount: offers.length ,
              itemBuilder: (context, index) {
                // // ✅ Load More Indicator
                // if (index == offer.length) {
                //   return cubit.isLoadingMore
                //       ? const _LoadMoreIndicator()
                //       : const _HasMoreIndicator();
                // }

                final offer = offers[index];
                final offerId = offer.id.toString();

                // ✅ Order Card without border
                return RepaintBoundary(
                  child: Stack(
                    children: [
                      _AnimatedOrderCard(
                        key: ValueKey(offer.id),
                        offer: offer,
                        index: index,
                        isDark: _isDark,
                      ),
                      // ✅ Tracking Indicator
                      Positioned(
                        top: 16,
                        left: 16,
                        child: OrderTrackingIndicator(orderId: offerId),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// // ==================== Status Filter Widget (ديناميكي ومحسّن) ====================
// class _StatusFilterWidget extends StatelessWidget {
//   final String? selectedStatus;
//   final bool isDark;
//   final ValueChanged<String?> onStatusChanged;
//
//   const _StatusFilterWidget({
//     required this.selectedStatus,
//     required this.isDark,
//     required this.onStatusChanged,
//   });
//
//   // ✅ ترتيب ثابت للحالات: الكل → قيد الانتظار → مقبول → مرفوض → ملغي
//   static const Map<String?, _StatusOption> _statusMap = {
//     null: _StatusOption(null, 'filter_all', Icons.list_rounded),
//     'Pending': _StatusOption('Pending', 'filter_pending', Icons.pending_rounded),
//     'Approved': _StatusOption('Approved', 'filter_approved', Icons.check_circle_rounded),
//     'Declined': _StatusOption('Declined', 'filter_declined', Icons.cancel_rounded),
//     'Canceled': _StatusOption('Canceled', 'filter_canceled', Icons.block_rounded),
//   };
//
//   // ✅ الفلاتر الثابتة: الكل + قيد الانتظار (دائماً تظهر)
//   static const List<String?> _staticFilters = [null, 'Pending'];
//
//   List<_StatusOption> _getAvailableStatuses(BuildContext context) {
//     // ✅ نستخدم unfilteredOrders بدلاً من allOrders لعرض كل الفلاتر
//     final allOrders = OffersCubitOffersCubit.get(context).unfilteredOrders;
//
//     // ✅ نبدأ بالفلاتر الثابتة: الكل + قيد الانتظار
//     final List<_StatusOption> availableStatuses = [
//       _statusMap[null]!,      // الكل
//       _statusMap['Pending']!, // قيد الانتظار (ثابت)
//     ];
//
//     // ✅ الحالات الأخرى تظهر فقط إذا كانت موجودة في الطلبات الأصلية
//     const dynamicKeys = ['Approved', 'Declined', 'Canceled'];
//
//     for (final key in dynamicKeys) {
//       if (allOrders.any((order) => order.status == key)) {
//         availableStatuses.add(_statusMap[key]!);
//       }
//     }
//
//     return availableStatuses;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final availableStatuses = _getAvailableStatuses(context);
//
//     return SizedBox(
//       height: 56,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//         physics: const BouncingScrollPhysics(),
//         itemCount: availableStatuses.length,
//         itemBuilder: (context, index) {
//           final status = availableStatuses[index];
//           final isSelected = selectedStatus == status.value;
//
//           return Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: _FilterChip(
//               status: status,
//               isSelected: isSelected,
//               isDark: isDark,
//               onTap: () => onStatusChanged(status.value),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// ==================== Error Banner Widget ====================
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppTheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Status Filter Widget (ديناميكي ومحسّن) ====================
class _StatusOption {
  final String? value;
  final String labelKey;
  final IconData icon;

  const _StatusOption(this.value, this.labelKey, this.icon);
}

class _FilterChip extends StatelessWidget {
  final _StatusOption status;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.status,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.purpleGradient : null,
          color: isSelected ? null : (isDark ? AppTheme.dark : Colors.white),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isSelected ? null : Border.all(
            color: isDark
                ? AppTheme.purple.withOpacity(0.3)
                : AppTheme.darkGray.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
            color: AppTheme.purple.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppTheme.lightGreen : AppTheme.purple),
            ),
            const SizedBox(width: 8),
            Text(
              status.labelKey.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : AppTheme.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Loading State محسّن ====================
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _OptimizedShimmerCard(isDark: isDark);
      },
    );
  }
}

// ==================== Shimmer Card محسّن (بدون AnimationController) ====================
class _OptimizedShimmerCard extends StatelessWidget {
  final bool isDark;

  const _OptimizedShimmerCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        color: isDark ? AppTheme.dark : Colors.grey[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerBox(width: 100, height: 16, isDark: isDark),
              _ShimmerBox(width: 60, height: 16, isDark: isDark),
            ],
          ),
          const SizedBox(height: 16),
          _ShimmerBox(width: 150, height: 20, isDark: isDark),
          const SizedBox(height: 20),
          _ShimmerBox(width: double.infinity, height: 1, isDark: isDark),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerBox(width: 80, height: 14, isDark: isDark),
              _ShimmerBox(width: 100, height: 14, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final bool isDark;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1 + (_controller.value * 2), 0),
              end: Alignment(_controller.value * 2, 0),
              colors: widget.isDark
                  ? [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ]
                  : [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================== Empty State ====================
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final String? message;
  final VoidCallback? onRetry;

  const _EmptyState({
    required this.isDark,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isError = message != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? (isError ? AppTheme.error : AppTheme.purple).withOpacity(0.1)
                  : (isError ? AppTheme.error : AppTheme.purple).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isError ? Icons.error_outline_rounded : Icons.local_offer,
              size: 80,
              color: isDark
                  ? (isError ? AppTheme.error : AppTheme.lightGreen)
                  : (isError ? AppTheme.error : AppTheme.purple),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isError ? 'Error Loading Offers'.tr() : 'No Offers Yet'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.black,
            ),
          ),
          // const SizedBox(height: 12),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 40),
          //   child: Text(
          //     message ?? 'Start by creating your first order'.tr(),
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //       fontSize: 16,
          //       color: isDark ? AppTheme.darkGray : Colors.grey[600],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 32),
          if (isError && onRetry != null)
            _RetryButton(isDark: isDark, onRetry: onRetry!)
          // else
          //   _CreateOrderButton(isDark: isDark),
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _RetryButton({
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onRetry();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.purpleGradient,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purple.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Retry'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _CreateOrderButton extends StatelessWidget {
//   final bool isDark;
//
//   const _CreateOrderButton({required this.isDark});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         // MyNavigator.navigateTo(context, const AddOrderScreen());
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//         decoration: BoxDecoration(
//           gradient: AppTheme.purpleGradient,
//           borderRadius: BorderRadius.circular(AppRadius.pill),
//           boxShadow: [
//             BoxShadow(
//               color: AppTheme.purple.withOpacity(0.4),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.add_rounded, color: Colors.white),
//             const SizedBox(width: 8),
//             Text(
//               'Create Order'.tr(),
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ==================== No Filter Results ====================
class _NoFilterResults extends StatelessWidget {
  final bool isDark;

  const _NoFilterResults({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Load More Indicator ====================
class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(
          color: AppTheme.purple,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ==================== Has More Indicator ====================
class _HasMoreIndicator extends StatelessWidget {
  const _HasMoreIndicator();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'اسحب لأعلى لتحميل المزيد',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Animated Order Card ====================
class _AnimatedOrderCard extends StatelessWidget {
  final OfferData offer;
  // final OffersModel offer;
  final int index;
  final bool isDark;

  const _AnimatedOrderCard({
    super.key,
    required this.offer,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ تحديد مدة الحركة بناءً على الـ index (للعناصر الأولى فقط)
    final animationDelay = index < 5 ? Duration(milliseconds: 100 * index) : Duration.zero;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: CardOrderWidget(
        offerData: offer,
        isDark: isDark,
      ),
    );
  }
}

// ==================== Order Card Widget محسّن ====================
class CardOrderWidget extends StatelessWidget {
  final OfferData offerData;
  final bool isDark;

  const CardOrderWidget({
    super.key,
    required this.offerData,
    required this.isDark,
  });

  Color get _statusColor {
    if (offerData.status == "Inactive") {
      return AppTheme.error;
    }
    // if (orderModel.shippingStatus == OrderShippingStatus.delivered) {
    //   return AppTheme.lightGreen;
    // }
    return AppTheme.lightGreen;
  }

  IconData get _statusIcon {
    if (offerData.status == "Inactive") {
      return Icons.cancel_rounded;
    }
    // if (orderModel.shippingStatus == OrderShippingStatus.delivered) {
    //   return Icons.check_circle_rounded;
    // }
    return Icons.access_time_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        MyNavigator.navigateTo(context, OffersDetailsScreen(offerData: offerData),);

      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: AppTheme.cardGradient,
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: Column(
            children: [
              // Status Bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_statusColor, _statusColor.withOpacity(0.5)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(
                      orderId: offerData.id!,
                      status: offerData.status!,
                      shippingStatus: "Active",
                      isUsed: offerData.isUsed??false,
                      statusColor: _statusColor,
                      statusIcon: _statusIcon,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _CustomerInfo(
                      customerName: offerData.title ?? '',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _CardDivider(isDark: isDark),
                    const SizedBox(height: 16),
                    _InfoGrid(
                      offer: offerData,
                      isDark: isDark,
                      statusColor: _statusColor,
                    ),
                    _HistoryItem(
                      label: 'Expiry Date'.tr(),
                      dateStr: offerData.expiryDate!,
                      color: _statusColor,
                      isDark: isDark,
                    ),
                    if(offerData.imageUrl!=null)
                      _CardDivider(isDark: isDark),
                    if(offerData.imageUrl!=null)
                      const SizedBox(height: 16),
                    if(offerData.imageUrl!=null)
                    _CardFooter(
                      offerData: offerData,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Card Header ====================
class _CardHeader extends StatelessWidget {
  final int orderId;
  final String status;
  final bool isUsed;
  final String? shippingStatus;
  final Color statusColor;
  final IconData statusIcon;
  final bool isDark;

  const _CardHeader({
    required this.orderId,
    required this.status,
    required this.shippingStatus,
    required this.statusColor,
    required this.isUsed,
    required this.statusIcon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.purple.withOpacity(0.2)
                : AppTheme.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 14,
                color: isDark ? AppTheme.lightGreen : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                '#$orderId',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.lightGreen : Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        //   decoration: BoxDecoration(
        //     color: (isUsed ? AppTheme.yellow : AppTheme.lightGreen).withOpacity(0.15),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(isUsed ?Icons.done:Icons.close, size: 14,
        //         color: isUsed ? AppTheme.yellow : AppTheme.lightGreen,
        //       ),
        //       const SizedBox(width: 4),
        //       Text(
        //         "${isUsed?"Used".tr():"NotUsed".tr()}",
        //         style: TextStyle(
        //           fontSize: 11,
        //           fontWeight: FontWeight.w600,
        //           color: isUsed ? AppTheme.yellow : AppTheme.lightGreen,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
               "${isUsed?"Used".tr():(status=="Active"?"Active".tr():"Inactive".tr())}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== Customer Info ====================
class _CustomerInfo extends StatelessWidget {
  final String customerName;
  final bool isDark;

  const _CustomerInfo({
    required this.customerName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : AppTheme.lightGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.title,
            size: 18,
            color: isDark ? AppTheme.darkGray : Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            customerName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              // color: isDark ? Colors.white : AppTheme.black,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== Card Divider ====================
class _CardDivider extends StatelessWidget {
  final bool isDark;

  const _CardDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDark
                ? Colors.white.withOpacity(0.1)
                : AppTheme.darkGray.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ==================== Info Grid ====================
class _InfoGrid extends StatelessWidget {
  final OfferData offer;
  final bool isDark;
  final Color statusColor;

  const _InfoGrid({
    required this.offer,
    required this.isDark,
    required this.statusColor,
  });

  Widget _getOrderValueWidget(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          offer.special_price_after_tax.toString(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 4),
        context.getCurrencyWidget(
          height: 25,
          color: statusColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.payments_outlined,
                label: 'Offer Value'.tr(),
                valueWidget: _getOrderValueWidget(context),
                isDark: false,
              ),
            ),
            // const SizedBox(width: 12),
            // Expanded(
            //   child: _InfoItem(
            //     icon: Icons.location_on_outlined,
            //     label: 'expiryDate'.tr(),
            //     value: '${offer.expiryDate}',
            //     isDark: isDark,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _InfoItem(
        //         icon: Icons.calendar_today_outlined,
        //         label: 'Expiry Date'.tr(),
        //         value: formatDate(context, ),
        //         isDark: isDark,
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     Expanded(
        //       child: _InfoItem(
        //         icon: Icons.access_time_outlined,
        //         label: 'Release Time'.tr(),
        //         value: formatTime(offer.checkoutDate),
        //         isDark: isDark,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

// ==================== Info Item ====================
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;
  final bool isDark;

  const _InfoItem({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // color: isDark
        //     ? Colors.white.withOpacity(0.05)
        //     : AppTheme.lightGray,
        // gradient: AppTheme.cardGrad,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isDark ? AppTheme.darkGray : Colors.white,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkGray : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          valueWidget ?? Text(
            value ?? '',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : AppTheme.black),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==================== History Dates ====================
class _HistoryDates extends StatelessWidget {
  final List<dynamic> orderHistory;
  final bool isDark;

  const _HistoryDates({
    required this.orderHistory,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    // Delivered
    final delivered = orderHistory
        .where((e) => e.event == "delivered_order")
        .toList();
    if (delivered.isNotEmpty) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(_HistoryItem(
        label: 'Delivered'.tr(),
        dateStr: delivered.first.createdAt!,
        color: AppTheme.lightGreen,
        isDark: isDark,
      ));
    }

    // Canceled
    final canceled = orderHistory
        .where((e) => e.event == "canceled_order")
        .toList();
    if (canceled.isNotEmpty) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(_HistoryItem(
        label: 'Canceled'.tr(),
        dateStr: canceled.first.createdAt!,
        color: AppTheme.error,
        isDark: isDark,
      ));
    }

    // Declined
    final declined = orderHistory
        .where((e) => e.event == "declined_order")
        .toList();
    if (declined.isNotEmpty) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(_HistoryItem(
        label: 'Declined'.tr(),
        dateStr: declined.first.createdAt!,
        color: AppTheme.error,
        isDark: isDark,
      ));
    }

    return Column(children: widgets);
  }
}

// ==================== History Item ====================
class _HistoryItem extends StatelessWidget {
  final String label;
  final String dateStr;
  final Color color;
  final bool isDark;

  const _HistoryItem({
    required this.label,
    required this.dateStr,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(dateStr);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            '${formatDate(context, date)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Card Footer ====================
class _CardFooter extends StatelessWidget {
  final OfferData offerData;
  final bool isDark;

  const _CardFooter({
    required this.offerData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if(offerData.imageUrl!=null)
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage("${offerData.imageUrl}"),fit: BoxFit.fill),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
        ),
        // SizedBox(width: 10,),
        // DirectionalArrow(
        //   direction: ArrowDirection.forwardIos,
        //   size: 16,
        //   color: isDark ? AppTheme.darkGray : Colors.grey[400],
        // ),
      ],
    );
  }
}

// ==================== Responsive FAB Widget ====================
class _ResponsiveFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool showLabel;
  final bool isDark;

  const _ResponsiveFAB({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.showLabel = true,
    required this.isDark,
  });

  @override
  State<_ResponsiveFAB> createState() => _ResponsiveFABState();
}

class _ResponsiveFABState extends State<_ResponsiveFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, widget.showLabel ? 20 : 16),
            vertical: ResponsiveUtils.spacing(context, 14),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isPressed
                  ? [
                AppTheme.purple.withOpacity(0.9),
                const Color(0xFF7B52FE).withOpacity(0.9),
              ]
                  : [
                AppTheme.purple,
                const Color(0xFF7B52FE),
              ],
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, widget.showLabel ? 28 : 50),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.purple.withOpacity(_isPressed ? 0.3 : 0.5),
                blurRadius: ResponsiveUtils.radius(context, _isPressed ? 15 : 20),
                offset: Offset(0, ResponsiveUtils.spacing(context, _isPressed ? 5 : 8)),
                spreadRadius: _isPressed ? 0 : 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: ResponsiveUtils.icon(context, 22),
              ),
              if (widget.showLabel) ...[
                SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.font(context, 14),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}