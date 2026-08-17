import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:app/business_logic/OffersCubit/offers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app/core/responsive/responsive.dart';
import 'package:app/core/extensions/context_extensions.dart';
import 'package:app/core/deep_links/deep_link_config.dart';
import 'package:app/core/deep_links/deep_link_service.dart';
import 'package:app/functions/functions.dart';
import 'package:app/business_logic/Statistic_cubit/statistic_cubit.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/business_logic/translation/cubit/translation_cubit.dart';
import 'package:app/core/live_tracking/models/order_tracking_model.dart';
import 'package:app/core/live_tracking/services/live_order_tracking_service.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/persentation/screens/invoice/invoice_screen.dart';
import 'package:app/persentation/screens/loyalityPointsScreen/LoyalityPointsScreen.dart';
import 'package:app/persentation/screens/notifications/notifications_screen.dart';
import 'package:app/persentation/screens/orders/order_details_screen.dart';
import 'package:app/persentation/screens/overdue/overdue_screen.dart';
import 'package:app/persentation/screens/receipt/receipt_screen.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/network/services/orders_services.dart';
import 'package:app/models/order/order_model.dart';
import 'package:app/persentation/widgets/columnChartsScreen.dart' hide AnimatedBuilder;
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/theme/colors.dart';
import 'package:app/core/tour/tour_controller.dart';
import 'package:app/core/tour/tour_target_widget.dart';

import '../../widgets/offers_slider_section.dart';
import '../offers/offers_details.dart';
import '../offers/offers_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme Colors
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  static const Color yellow = Color(0xFFD7B21B);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFFF9F43);
  static const Color blue = Color(0xFF3B82F6);
  static const Color teal = Color(0xFF14B8A6);
  static const Color indigo = Color(0xFF6366F1);

  // 🌙 Enhanced Ramadan Colors (Green Theme)
  static const Color ramadanGreen = Color(0xFF28E6C5); // Main green
  static const Color ramadanGreenDark = Color(0xFF20C9AC); // Darker green
  static const Color ramadanGreenDeep = Color(0xFF14B8A6); // Deep green (teal)
  static const Color ramadanDarkPurple = Color(0xFF1A0B2E);
  static const Color ramadanPurple = Color(0xFF4A1D96);
  static const Color ramadanLightPurple = Color(0xFF7C3AED);
  
  // Light Mode Ramadan Colors (Green Vibrant)
  static const Color ramadanGreenLight = Color(0xFF34F5D8);
  static const Color ramadanBgLight = Color(0xFFE7FFF8); // Mint background
  static const Color ramadanPurpleLight = Color(0xFFEDE9FE);
  static const Color ramadanGreenMint = Color(0xFF1FA88A);
  static const Color ramadanGreenDarkest = Color(0xFF0D9488);
  static const Color ramadanPurpleText = Color(0xFF5B21B6);
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏠 Home Screen - Premium Responsive Design with Ramadan Theme
// ═══════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Controllers & Variables
  // ═══════════════════════════════════════════════════════════════════════
  final ScrollController _scrollController = ScrollController();
  final LiveOrderTrackingService _trackingService = LiveOrderTrackingService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double _scrollOffset = 0;

  TourController? _tourController;
  bool _isInitialized = false;
  bool _isDisposed = false;

  late AnimationController _bannerAnimationController;
  late Animation<double> _bannerShimmerAnimation;
  late AnimationController _bnplController;
  late Animation<double> _pulseAnimation;

  StreamSubscription<OrderTrackingModel?>? _trackingSubscription;
  OrderTrackingModel? _currentTrackingData;
  Timer? _autoRefreshTimer;

  // ═══════════════════════════════════════════════════════════════════════
  // 🌙 Ramadan Variables
  // ═══════════════════════════════════════════════════════════════════════
  bool _isRamadan = false;
  int _ramadanDaysLeft = 0;
  int _currentRamadanDay = 0;
  late AnimationController _ramadanStarsController;
  late AnimationController _crescentController;
  late Animation<double> _crescentRotateAnimation;
  late Animation<double> _starsOpacityAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isRTL => context.locale.languageCode == 'ar';

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Lifecycle Methods
  // ═══════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _initAnimations();
    // _checkRamadanPeriod();
    _scrollController.addListener(_onScrollChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    if (!mounted || _isDisposed) return;

    try {
      _tourController = TourController();
      _setupTrackingPolling();
      _onRefresh();
      _initLiveTrackingListener();

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_isDisposed && _tourController != null) {
          _tourController!.startHomeTour();
        }
      });
    } catch (e) {
      print('❌ Error initializing HomeScreen: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🌙 Check if it's Ramadan Period
  // ═══════════════════════════════════════════════════════════════════════
  void _checkRamadanPeriod() {
    // 🇸🇦 التوقيت السعودي (الرياض) = UTC+3
    final nowUtc = DateTime.now().toUtc();
    final now = nowUtc.add(const Duration(hours: 3)); // توقيت الرياض

    // 🇸🇦 رمضان 2026 في المملكة العربية السعودية
    // بداية رمضان: 18 فبراير 2026 الساعة 00:00 (منتصف الليل)
    // نهاية رمضان: 19 مارس 2026 (30 رمضان 1447 هـ)
    final ramadanStart = DateTime(2026, 2, 18, 0, 0, 0);
    final ramadanEnd = DateTime(2026, 3, 19, 23, 59, 59);

    // Show Ramadan theme starting from Feb 17 (one day before)
    final showRamadanThemeFrom = DateTime(2026, 2, 17, 0, 0, 0);

    if (now.isAfter(showRamadanThemeFrom) && now.isBefore(ramadanEnd.add(Duration(days: 1)))) {
      _isRamadan = true;

      if (now.isBefore(ramadanStart)) {
        // قبل بداية رمضان - عرض "قريباً"
        _ramadanDaysLeft = 0; // سنستخدم هذا للتحقق من "قريباً"
        _currentRamadanDay = 0;
        print('🌙 رمضان قريباً! سيبدأ في ${ramadanStart.toString().split(' ')[0]} | الوقت الحالي: ${now.toString()}');
      } else {
        // خلال رمضان - عرض الأيام
        // حساب الأيام المتبقية
        final daysLeft = ramadanEnd.difference(now).inDays + 1;
        _ramadanDaysLeft = daysLeft > 0 ? daysLeft : 0;

        // حساب اليوم الحالي من رمضان (1-30)
        _currentRamadanDay = now.difference(ramadanStart).inDays + 1;
        if (_currentRamadanDay > 30) _currentRamadanDay = 30;
        if (_currentRamadanDay < 1) _currentRamadanDay = 1;

        print('🌙 رمضان كريم! اليوم: $_currentRamadanDay | الأيام المتبقية: $_ramadanDaysLeft | الوقت الحالي: ${now.toString()}');
      }
    } else {
      _isRamadan = false;
      _ramadanDaysLeft = 0;
      _currentRamadanDay = 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // � Get Ramadan Day Text
  // ═══════════════════════════════════════════════════════════════════════
  String _getRamadanDayText() {
    // قبل بداية رمضان - عرض "قريباً"
    if (_currentRamadanDay == 0 && _ramadanDaysLeft == 0) {
      return _isRTL ? 'قريباً 🌙' : 'Coming Soon 🌙';
    }
    
    if (_isRTL) {
      // النصوص العربية
      if (_currentRamadanDay == 1) {
        return '🌙 اليوم الأول من رمضان';
      } else if (_ramadanDaysLeft <= 3) {
        // آخر 3 أيام - نبرز باقي الأيام
        return 'متبقي $_ramadanDaysLeft ${_ramadanDaysLeft == 1 ? "يوم" : "أيام"}';
      } else {
        // اليوم الحالي من رمضان
        return 'اليوم $_currentRamadanDay من رمضان';
      }
    } else {
      // English texts
      if (_currentRamadanDay == 1) {
        return '🌙 First day of Ramadan';
      } else if (_ramadanDaysLeft <= 3) {
        // Last 3 days - highlight remaining days
        return '$_ramadanDaysLeft ${_ramadanDaysLeft == 1 ? "day" : "days"} left';
      } else {
        // Current day of Ramadan
        return 'Day $_currentRamadanDay of Ramadan';
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // �🔄 API Polling Fallback
  // ═══════════════════════════════════════════════════════════════════════
  void _setupTrackingPolling() {
    _trackingService.onFetchTrackingUpdate = (String orderId) async {
      try {
        print('🔄 Fetching tracking update from API for: $orderId');

        await OrdersServices.getData();

        final orderModel = OrdersServices.data.firstWhere(
              (order) => order.id.toString() == orderId || order.reference == orderId,
          orElse: () => throw Exception('Order not found in API response'),
        );

        print('✅ Found order in API: ${orderModel.reference}');

        if (orderModel.status?.toLowerCase() == 'canceled' ||
            orderModel.status?.toLowerCase() == 'cancelled' ||
            orderModel.status?.toLowerCase() == 'declined') {
          print('🚫 Order is ${orderModel.status}, marking as cancelled');

          final tracking = OrderTrackingModel.fromOrderData(
            orderId: orderModel.id.toString(),
            orderReference: orderModel.reference ?? 'ORD-${orderModel.id}',
            shippingStatus: 'cancelled',
            orderDate: orderModel.checkoutDate,
            driverName: null,
            driverPhone: null,
            estimatedDeliveryTime: null,
            deliveryAddress: orderModel.location,
            totalAmount: orderModel.totalWithTax,
            currency: 'SAR',
          );

          return tracking;
        }

        final tracking = OrderTrackingModel.fromOrderData(
          orderId: orderModel.id.toString(),
          orderReference: orderModel.reference ?? 'ORD-${orderModel.id}',
          shippingStatus: orderModel.shippingStatus ?? orderModel.status ?? 'pending',
          orderDate: orderModel.checkoutDate,
          driverName: null,
          driverPhone: null,
          estimatedDeliveryTime: null,
          deliveryAddress: orderModel.location,
          totalAmount: orderModel.totalWithTax,
          currency: 'SAR',
        );

        return tracking;
      } catch (e) {
        print('❌ Error fetching tracking from API: $e');
        return null;
      }
    };

    print('✅ API polling callback configured');
  }

  void _onScrollChanged() {
    if (!mounted || _isDisposed) return;
    // ✅ تحسين الأداء: تحديث فقط عند تغيير كبير في الـ offset
    final newOffset = _scrollController.offset;
    if ((newOffset - _scrollOffset).abs() > 5) {
      setState(() => _scrollOffset = newOffset);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Live Tracking Listener
  // ═══════════════════════════════════════════════════════════════════════
  void _initLiveTrackingListener() {
    if (!mounted || _isDisposed) return;

    print('🚀 HOME - Initializing live tracking listener...');

    final currentTracking = _trackingService.currentTracking;

    if (_shouldShowLiveTracking(currentTracking)) {
      _currentTrackingData = currentTracking;
    } else {
      _currentTrackingData = null;
    }

    _trackingSubscription?.cancel();
    _trackingSubscription = _trackingService.trackingStream.listen(
          (tracking) {
        if (!mounted || _isDisposed) return;

        if (!_shouldShowLiveTracking(tracking)) {
          if (_currentTrackingData != null) {
            setState(() {
              _currentTrackingData = null;
            });
          }
          return;
        }

        if (_hasTrackingChanged(_currentTrackingData, tracking)) {
          setState(() {
            _currentTrackingData = tracking;
          });
        }
      },
      onError: (error) {
        print('❌ HOME - Tracking stream error: $error');
      },
      cancelOnError: false,
    );

    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 60), // ✅ تقليل التحديث التلقائي من 30 إلى 60 ثانية لتقليل الضغط
          (_) {
        if (mounted && !_isDisposed) {
          _refreshTrackingData();
        }
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentTrackingData != null) {
        try {
          _trackingService.firestoreListener.startListening(_currentTrackingData!.orderId);
        } catch (e) {
          print('⚠️ HOME - Could not start Firestore Listener: $e');
        }
      }
    });
  }

  bool _hasTrackingChanged(OrderTrackingModel? oldTracking, OrderTrackingModel? newTracking) {
    if (oldTracking == null && newTracking == null) return false;
    if (oldTracking == null || newTracking == null) return true;

    return oldTracking.orderId != newTracking.orderId ||
        oldTracking.status != newTracking.status ||
        oldTracking.driverName != newTracking.driverName ||
        oldTracking.driverPhone != newTracking.driverPhone;
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  void _refreshTrackingData() {
    if (!mounted || _isDisposed) return;

    try {
      final latestTracking = _trackingService.currentTracking;

      if (!_shouldShowLiveTracking(latestTracking)) {
        _safeSetState(() {
          _currentTrackingData = null;
        });
        return;
      }

      if (latestTracking != _currentTrackingData) {
        _safeSetState(() {
          _currentTrackingData = latestTracking;
        });
      }
    } catch (e) {
      print('⚠️ HOME - Error refreshing tracking data: $e');
    }
  }

  bool _shouldShowLiveTracking(OrderTrackingModel? tracking) {
    if (tracking == null) return false;

    try {
      final status = tracking.status;

      if (status == OrderTrackingStatus.delivered ||
          status == OrderTrackingStatus.cancelled) {
        return false;
      }

      return true;
    } catch (e) {
      print('⚠️ HOME - Error checking tracking status: $e');
      return true;
    }
  }

  void _initAnimations() {
    // Banner Animation
    _bannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bannerShimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _bannerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // BNPL Animation
    _bnplController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _bnplController, curve: Curves.easeInOut),
    );

    // 🌙 عدل هذا الجزء ليعمل فقط إذا كان رمضان مفعل
    _ramadanStarsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _crescentController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (_isRamadan) {
      _ramadanStarsController.repeat(reverse: true);
      _crescentController.repeat(reverse: true);
    }
    _crescentRotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _crescentController,
        curve: Curves.easeInOut,
      ),
    );

    _starsOpacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _ramadanStarsController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _loadData() {
    if (!mounted || _isDisposed) return;

    try {
      context.read<ProfileCubit>().getProfile();
      context.read<StatisticCubit>().getStatistic();
      context.read<OffersCubit>().getOffers();
    } catch (e) {
      print('⚠️ HOME - Error loading data: $e');
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted || _isDisposed) return;

    HapticFeedback.mediumImpact();
    _loadData();
    _refreshTrackingData();
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _launchBuyNowPayLater() async {
    final Uri url = Uri.parse('https://ldun.com.sa/');
    try {
      HapticFeedback.mediumImpact();
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (mounted && !_isDisposed) {
        context.showError('Could not open link'.tr());
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    _trackingSubscription?.cancel();
    _trackingSubscription = null;

    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;

    _tourController?.dispose();
    _tourController = null;

    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();

    _bannerAnimationController.dispose();
    _bnplController.dispose();
    _ramadanStarsController.dispose();
    _crescentController.dispose();

    print('🧹 HOME - Disposed all resources');
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏗️ Build Method
  // ═══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: _isDark ? AppTheme.background : const Color(0xFFF5F7FA),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return UpgradeAlert(
      upgrader: Upgrader(
        // countryCode: 'SA',
        durationUntilAlertAgain: Duration.zero,
        debugLogging: true,
      ),
      dialogStyle: UpgradeDialogStyle.cupertino,
      showIgnore: false,
      showLater: false,
      showReleaseNotes: true,
      barrierDismissible: false,
      shouldPopScope: () => false,
      child: BlocBuilder<TranslationCubit, TranslationState>(
        builder: (context, state) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              return Scaffold(
            key: _scaffoldKey,
            backgroundColor: _isDark ? AppTheme.background : const Color(0xFFF5F7FA),
            body: Stack(
              children: [
                _buildBackgroundGradient(),
                SafeArea(
                  child: Directionality(
                    textDirection: _isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                      backgroundColor: _isDark ? AppTheme.dark : AppTheme.white,
                      child: CustomScrollView(
                        key: const ValueKey('home_custom_scroll_view'),
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_app_bar'),
                            child: _buildPremiumAppBar(),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_user_profile'),
                            child: _buildUserProfileCard(),
                          ),
                          if (_isRamadan)
                            SliverToBoxAdapter(
                              key: const ValueKey('sliver_ramadan_banner'),
                              child: _buildRamadanBanner(),
                            ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_live_tracking'),
                            child: _buildLiveTrackingCard(),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_charts'),
                            child: _buildChartsSection(),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_financial_summary'),
                            child: _buildFinancialSummary(),
                          ),
                          const SliverToBoxAdapter(
                            key: ValueKey('sliver_offers_slider'),
                            child: OffersSliderSection(),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_quick_actions'),
                            child: _buildQuickActions(),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_section_header'),
                            child: _buildSectionHeader('Financial Details'.tr()),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_indebtedness'),
                            child: _buildIndebtednessCard(),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_services_grid'),
                            child: _buildServicesGrid(),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_bnpl'),
                            child: _buildBuyNowPayLaterCard(),
                          ),


                          SliverToBoxAdapter(
                            key: const ValueKey('sliver_bottom_padding'),
                            child: SizedBox(
                              height: context.bottomSafePadding + kBottomNavigationBarHeight + 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
            },
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Background Gradient
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: ResponsiveUtils.height(context, 280),
      child: Stack(
        children: [
          // 🎨 Enhanced Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDark
                    ? [
                        _isRamadan
                            ? const Color(0xFF0D2E29).withOpacity(0.8) // Dark green tint
                            : AppTheme.purple.withOpacity(0.3),
                        AppTheme.background,
                      ]
                    : _isRamadan
                        ? [
                            // 🌙 Light Mode Ramadan - Green Theme
                            const Color(0xFFE7FFF8), // Mint cream
                            const Color(0xFFEDE9FE), // Light purple
                            const Color(0xFFF5F7FA),
                          ]
                        : [
                            AppTheme.purple.withOpacity(0.08),
                            const Color(0xFFF5F7FA),
                          ],
              ),
            ),
          ),

          // ✨ Ramadan Decorative Overlay for Light Mode
          if (_isRamadan && !_isDark)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF28E6C5).withOpacity(0.15), // Green
                    const Color(0xFF7C3AED).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

          // Ramadan Stars
          if (_isRamadan) RepaintBoundary(child: _buildRamadanStars()),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✨ Ramadan Stars Background - Enhanced Visibility
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildRamadanStars() {
    return AnimatedBuilder(
      animation: _starsOpacityAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final random = math.Random(index);
            final x = random.nextDouble() * MediaQuery.of(context).size.width;
            final y = random.nextDouble() * 280;
            final starSize = _isDark 
                ? 2.0 + random.nextDouble() * 4 
                : 3.0 + random.nextDouble() * 5; // Larger in light mode
            final delay = random.nextDouble();

            final opacity = (((_starsOpacityAnimation.value + delay) % 1.0) < 0.5
                ? (_starsOpacityAnimation.value + delay) % 1.0
                : 1.0 - (_starsOpacityAnimation.value + delay) % 1.0) * 2;

            return Positioned(
              left: x,
              top: y,
              child: Opacity(
                opacity: opacity * (_isDark ? 0.7 : 0.85), // More visible in light mode
                child: Container(
                  decoration: _isDark
                      ? null
                      : BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF28E6C5).withOpacity(0.6), // Green glow
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                  child: Icon(
                    Icons.star_rounded,
                    size: starSize,
                    color: _isDark 
                        ? const Color(0xFF28E6C5) // Green
                        : const Color(0xFF14B8A6), // Deep teal for light mode
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Premium App Bar
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildPremiumAppBar() {
    final opacity = (1.0 - (_scrollOffset / 100)).clamp(0.0, 1.0);

    return Padding(
      padding: ResponsiveUtils.paddingOnly(
        context,
        left: 16,
        right: 16,
        top: 12,
        bottom: 8,
      ),
      child: Row(
        children: [
          _wrapWithTourTarget(
            tourKey: _tourController?.notificationKey,
            child: _buildIconButton(
              icon: Icons.notifications_rounded,
              hasNotification: true,
              onTap: () {
                if (!mounted || _isDisposed) return;
                MyNavigator.navigateTo(context, const NotificationScreen());
              },
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 10)),
          _wrapWithTourTarget(
            tourKey: _tourController?.themeToggleKey,
            child: _buildIconButton(
              icon: _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              onTap: () {
                if (!mounted || _isDisposed) return;
                final themeProvider = Provider.of<AppThemeProvider>(context, listen: false);
                themeProvider.toggleTheme();
              },
            ),
          ),

          // 🔗 Share App (Home deep link)
          SizedBox(width: ResponsiveUtils.spacing(context, 10)),
          _buildIconButton(
            icon: Icons.share_rounded,
            onTap: () {
              if (!mounted || _isDisposed) return;
              shareDeepLink(
                DeepLinkConfig.homeLink,
                message: 'share_app_message'.tr(),
              );
            },
          ),

          // Ramadan Crescent
          if (_isRamadan) ...[
            SizedBox(width: ResponsiveUtils.spacing(context, 10)),
            _buildRamadanCrescent(),
          ],

          const Spacer(),
          Opacity(
            opacity: opacity,
            child: _buildAnimatedLogo(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🌙 Ramadan Crescent Icon - Enhanced Light Mode
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildRamadanCrescent() {
    final size = ResponsiveUtils.size(context, 44);
    final radius = ResponsiveUtils.radius(context, 12);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // رمز رمضاني فقط - بدون تنقل
      },
      child: AnimatedBuilder(
        animation: _crescentController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _crescentRotateAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                // 🌙 Enhanced gradient for light mode - Green Theme
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isDark
                      ? [
                          const Color(0xFF28E6C5).withOpacity(0.25),
                          const Color(0xFF28E6C5).withOpacity(0.15),
                        ]
                      : [
                          const Color(0xFF28E6C5).withOpacity(0.4),
                          const Color(0xFF20C9AC).withOpacity(0.3),
                        ],
                ),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: _isDark
                      ? const Color(0xFF28E6C5).withOpacity(0.4)
                      : const Color(0xFF14B8A6).withOpacity(0.5),
                  width: _isDark ? 1 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF28E6C5).withOpacity(_isDark ? 0.3 : 0.45),
                    blurRadius: _isDark ? 12 : 16,
                    offset: const Offset(0, 3),
                    spreadRadius: _isDark ? 0 : 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(
                      ResponsiveUtils.size(context, 22),
                      ResponsiveUtils.size(context, 22),
                    ),
                    painter: _MiniCrescentPainter(
                      color: _isDark 
                          ? const Color(0xFF28E6C5)
                          : const Color(0xFF14B8A6), // Deep teal for light mode
                    ),
                  ),
                  Positioned(
                    top: ResponsiveUtils.spacing(context, 7),
                    right: ResponsiveUtils.spacing(context, 9),
                    child: Icon(
                      Icons.star_rounded,
                      color: _isDark 
                          ? const Color(0xFF28E6C5)
                          : const Color(0xFF14B8A6),
                      size: ResponsiveUtils.icon(context, 9),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _wrapWithTourTarget({GlobalKey? tourKey, required Widget child}) {
    if (tourKey != null && _tourController != null) {
      return TourTarget(
        tourKey: tourKey,
        child: child,
      );
    }
    return child;
  }

  Widget _buildIconButton({
    required IconData icon,
    bool hasNotification = false,
    required VoidCallback onTap,
  }) {
    final size = ResponsiveUtils.size(context, 42);
    final iconSize = ResponsiveUtils.icon(context, 20);
    final radius = ResponsiveUtils.radius(context, 12);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _isDark ? AppTheme.white.withOpacity(0.1) : AppTheme.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: _isDark
                ? AppTheme.white.withOpacity(0.1)
                : AppTheme.darkGray.withOpacity(0.2),
          ),
          boxShadow: _isDark
              ? null
              : [
            BoxShadow(
              color: AppTheme.darkGray.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: _isDark ? AppTheme.white : AppTheme.dark,
              size: iconSize,
            ),
            if (hasNotification)
              Positioned(
                right: ResponsiveUtils.spacing(context, 10),
                top: ResponsiveUtils.spacing(context, 10),
                child: Container(
                  width: ResponsiveUtils.size(context, 8),
                  height: ResponsiveUtils.size(context, 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.red, Color(0xFFFF6B6B)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isDark ? AppTheme.dark : AppTheme.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    final logoSize = ResponsiveUtils.size(context, 40);
    final horizontalPadding = ResponsiveUtils.spacing(context, 16);
    final radius = ResponsiveUtils.radius(context, 14);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.purple, AppTheme.purple.withOpacity(0.7)]
              : [AppTheme.purple, const Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/deslogo.png',
        width: logoSize,
        height: logoSize,
        color: AppTheme.white,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 👤 User Profile Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildUserProfileCard() {
    UserModel? user;
    try {
      user = ProfileCubit.get(context).userModel;
    } catch (e) {
      print('⚠️ HOME - Error accessing ProfileCubit: $e');
      user = null;
    }

    final hour = DateTime.now().hour;
    final companyName = () {
      final fromUser = user?.displayName.trim() ?? '';
      if (fromUser.isNotEmpty) return fromUser;
      return '';
    }();

    String greeting;
    IconData icon;
    Color iconColor;

    if (hour < 12) {
      greeting = 'Good Morning'.tr();
      icon = Icons.wb_sunny_rounded;
      iconColor = AppTheme.yellow;
    } else if (hour < 17) {
      greeting = 'Good Afternoon'.tr();
      icon = Icons.wb_cloudy_rounded;
      iconColor = AppTheme.orange;
    } else {
      greeting = 'Good Evening'.tr();
      icon = Icons.nights_stay_rounded;
      iconColor = AppTheme.purple;
    }

    final horizontalMargin = ResponsiveUtils.spacing(context, 16);
    final verticalMargin = ResponsiveUtils.spacing(context, 6);
    final padding = ResponsiveUtils.spacing(context, 14);
    final radius = ResponsiveUtils.radius(context, 20);
    final avatarSize = ResponsiveUtils.size(context, 50);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.dark : AppTheme.white,
        borderRadius: BorderRadius.circular(radius),
        border: _isDark
            ? Border.all(color: AppTheme.white.withOpacity(0.08))
            : null,
        boxShadow: [
          BoxShadow(
            color: (_isDark ? Colors.black : AppTheme.purple)
                .withOpacity(_isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple, AppTheme.purple.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 14),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(companyName),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),

          SizedBox(width: ResponsiveUtils.spacing(context, 12)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: ResponsiveUtils.icon(context, 16),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                    Text(
                      greeting.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 12),
                        color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 2)),
                Text(
                  companyName.isNotEmpty ? companyName : '...',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 17),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? AppTheme.white : AppTheme.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((user?.phoneNumber.trim().isNotEmpty ?? false) &&
                    user!.phoneNumber.trim() != companyName) ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, 2)),
                  Text(
                    user.phoneNumber,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 12),
                      color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: ResponsiveUtils.spacing(context, 4)),
                _buildVerifiedBadge(),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.white.withOpacity(0.08)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 10),
              ),
            ),
            child: Icon(
              Icons.settings_rounded,
              color: _isDark ? AppTheme.darkGray : Colors.grey[600],
              size: ResponsiveUtils.icon(context, 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 8),
        vertical: ResponsiveUtils.spacing(context, 3),
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: ResponsiveUtils.icon(context, 12),
            color: AppTheme.lightGreen,
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 3)),
          Text(
            'Verified Account'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 10),
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🌙 Ramadan Welcome Banner
  // ═══════════════════════════════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════
  // 🌙 Ramadan Welcome Banner - Enhanced Light Mode
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildRamadanBanner() {
    final horizontalMargin = ResponsiveUtils.spacing(context, 16);
    final verticalMargin = ResponsiveUtils.spacing(context, 8);
    final padding = ResponsiveUtils.spacing(context, 16);
    final radius = ResponsiveUtils.radius(context, 20);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: _isDark
              ? const Color(0xFF28E6C5).withOpacity(0.3)
              : const Color(0xFF14B8A6).withOpacity(0.4),
          width: _isDark ? 1.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? const Color(0xFF28E6C5).withOpacity(0.15)
                : const Color(0xFF14B8A6).withOpacity(0.25),
            blurRadius: _isDark ? 20 : 25,
            offset: const Offset(0, 6),
            spreadRadius: _isDark ? 0 : 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // Background Gradient - Enhanced for light mode - Green Theme
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isDark
                      ? [
                          const Color(0xFF1B4E42), // Dark teal
                          const Color(0xFF0E3328), // Darker teal
                        ]
                      : [
                          const Color(0xFFE7FFF8), // Mint cream
                          const Color(0xFFC7FEF0), // Light mint
                          const Color(0xFFEDE9FE), // Soft lavender
                        ],
                ),
              ),
            ),

            // 🎨 Accent Bar (Light Mode Only) - Green Theme
            if (!_isDark)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF14B8A6), // Deep teal
                        Color(0xFF1FA88A), // Mint
                        Color(0xFF0D9488), // Darkest teal
                      ],
                    ),
                  ),
                ),
              ),

            // Decorative Pattern
            CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width,
                ResponsiveUtils.height(context, 120),
              ),
              painter: _RamadanPatternPainter(isDark: _isDark),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  _buildRamadanLanternIcon(),

                  SizedBox(width: ResponsiveUtils.spacing(context, 14)),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // 🌙 Enhanced gradient text for light mode - Green Theme
                            Text(
                              _isRTL ? '🌙 رمضان كريم' : '🌙 Ramadan Kareem',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.font(context, 16),
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: _isDark
                                        ? [
                                            const Color(0xFF28E6C5),
                                            const Color(0xFF34F5D8),
                                          ]
                                        : [
                                            const Color(0xFF14B8A6), // Deep teal
                                            const Color(0xFF1FA88A), // Mint
                                            const Color(0xFF0D9488), // Darkest teal
                                          ],
                                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                                shadows: _isDark
                                    ? null
                                    : [
                                        Shadow(
                                          color: const Color(0xFF14B8A6).withOpacity(0.3),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, 6)),
                        // 🕌 Blessing text with enhanced purple for light mode
                        Text(
                          _currentRamadanDay == 0 && _ramadanDaysLeft == 0
                              ? (_isRTL 
                                  ? 'رمضان على الأبواب، استعدوا بالطاعات'
                                  : 'Ramadan is approaching, prepare with good deeds')
                              : (_isRTL
                                  ? 'تقبل الله منا ومنكم الصيام والقيام'
                                  : 'May Allah accept your fasting and prayers'),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.font(context, 11),
                            fontWeight: _isDark ? FontWeight.normal : FontWeight.w500,
                            color: _isDark
                                ? AppTheme.white.withOpacity(0.7)
                                : const Color(0xFF5B21B6), // Purple text
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, 8)),
                        // ═══════════════════════════════════════════════════════
                        //  عداد أيام رمضان
                        // ═══════════════════════════════════════════════════════
                        _buildRamadanCountdown(),
                      ],
                    ),
                  ),

                  _buildRamadanStarsDecoration(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏮 Ramadan Lantern Icon - Enhanced Light Mode
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildRamadanLanternIcon() {
    final size = ResponsiveUtils.size(context, _isDark ? 56 : 60);

    return AnimatedBuilder(
      animation: _crescentController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _crescentRotateAnimation.value * 0.5,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _isDark
                    ? [
                        const Color(0xFF28E6C5).withOpacity(0.2),
                        const Color(0xFF28E6C5).withOpacity(0.1),
                      ]
                    : [
                        const Color(0xFF20C9AC).withOpacity(0.5),
                        const Color(0xFF14B8A6).withOpacity(0.4),
                      ],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 14),
              ),
              border: _isDark
                  ? null
                  : Border.all(
                      color: const Color(0xFF14B8A6).withOpacity(0.5),
                      width: 1.5,
                    ),
              boxShadow: [
                BoxShadow(
                  color: _isDark
                      ? const Color(0xFF28E6C5).withOpacity(0.3)
                      : const Color(0xFF14B8A6).withOpacity(0.4),
                  blurRadius: _isDark ? 15 : 20,
                  offset: const Offset(0, 4),
                  spreadRadius: _isDark ? 0 : 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '🏮',
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 32),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📅 Ramadan Countdown - Enhanced Light Mode
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildRamadanCountdown() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 10),
        vertical: ResponsiveUtils.spacing(context, 5),
      ),
      decoration: BoxDecoration(
        gradient: _isDark
            ? null
            : LinearGradient(
                colors: [
                  const Color(0xFFC7FEF0).withOpacity(0.35), // Light mint
                  const Color(0xFFE7FFF8).withOpacity(0.25), // Mint cream
                ],
              ),
        color: _isDark ? const Color(0xFF28E6C5).withOpacity(0.15) : null,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 12),
        ),
        border: Border.all(
          color: _isDark
              ? const Color(0xFF28E6C5).withOpacity(0.3)
              : const Color(0xFF14B8A6).withOpacity(0.5),
          width: _isDark ? 1 : 1.5,
        ),
        boxShadow: _isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF14B8A6).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: ResponsiveUtils.icon(context, 12),
            color: _isDark ? const Color(0xFF28E6C5) : const Color(0xFF1FA88A), // Mint
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 6)),
          Text(
            _getRamadanDayText(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 10),
              fontWeight: _isDark ? FontWeight.w600 : FontWeight.w700,
              color: _isDark ? AppTheme.white : const Color(0xFF0D9488), // Dark teal
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🕌 Maghrib Countdown Widget
  // ═══════════════════════════════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════
  // ⭐ Ramadan Stars Decoration - Enhanced Light Mode
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildRamadanStarsDecoration() {
    return AnimatedBuilder(
      animation: _starsOpacityAnimation,
      builder: (context, child) {
        return SizedBox(
          width: ResponsiveUtils.size(context, 40),
          height: ResponsiveUtils.size(context, 60),
          child: Stack(
            children: [
              // Star 1
              Positioned(
                top: 5,
                right: 5,
                child: Opacity(
                  opacity: _starsOpacityAnimation.value,
                  child: Container(
                    decoration: _isDark
                        ? null
                        : BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6).withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                    child: Icon(
                      Icons.star_rounded,
                      color: _isDark ? const Color(0xFF28E6C5) : const Color(0xFF14B8A6),
                      size: ResponsiveUtils.icon(context, 12),
                    ),
                  ),
                ),
              ),
              // Star 2
              Positioned(
                top: 25,
                right: 15,
                child: Opacity(
                  opacity: 1.0 - _starsOpacityAnimation.value,
                  child: Container(
                    decoration: _isDark
                        ? null
                        : BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6).withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                    child: Icon(
                      Icons.star_rounded,
                      color: _isDark ? const Color(0xFF28E6C5) : const Color(0xFF14B8A6),
                      size: ResponsiveUtils.icon(context, 8),
                    ),
                  ),
                ),
              ),
              // Star 3
              Positioned(
                top: 45,
                right: 8,
                child: Opacity(
                  opacity: _starsOpacityAnimation.value * 0.7,
                  child: Container(
                    decoration: _isDark
                        ? null
                        : BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6).withOpacity(0.45),
                                blurRadius: 5,
                                spreadRadius: 0.8,
                              ),
                            ],
                          ),
                    child: Icon(
                      Icons.star_rounded,
                      color: _isDark ? const Color(0xFF28E6C5) : const Color(0xFF14B8A6),
                      size: ResponsiveUtils.icon(context, 10),
                    ),
                  ),
                ),
              ),
              // 🌟 Extra Star for Light Mode (Purple accent)
              if (!_isDark)
                Positioned(
                  top: 15,
                  right: 25,
                  child: Opacity(
                    opacity: _starsOpacityAnimation.value * 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFF7C3AED), // Purple sparkle
                        size: ResponsiveUtils.icon(context, 9),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📍 Live Tracking Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildLiveTrackingCard() {
    final tracking = _currentTrackingData;

    if (!_shouldShowLiveTracking(tracking)) {
      return const SizedBox.shrink();
    }

    return _buildTrackingCardContent(tracking!);
  }

  Widget _buildTrackingCardContent(OrderTrackingModel tracking) {
    final trackingColor = _getTrackingColor(tracking.status);
    final trackingIcon = _getTrackingIcon(tracking.status);

    final horizontalMargin = ResponsiveUtils.spacing(context, 16);
    final verticalMargin = ResponsiveUtils.spacing(context, 8);
    final padding = ResponsiveUtils.spacing(context, 16);
    final radius = ResponsiveUtils.radius(context, 22);

    return GestureDetector(
      onTap: () async {
        if (!mounted || _isDisposed) return;
        HapticFeedback.mediumImpact();

        try {
          final orders = OrdersServices.data;
          OrderModel? orderModel;

          try {
            orderModel = orders.firstWhere(
                  (order) => order.id.toString() == tracking.orderId,
            );
          } catch (e) {
            orderModel = orders.firstWhere(
                  (order) => order.reference == tracking.orderReference,
            );
          }

          if (!mounted || _isDisposed) return;
          MyNavigator.navigateTo(
            context,
            OrderDetailsScreen(orderModel: orderModel),
          );
        } catch (e) {
          if (!mounted || _isDisposed) return;
          context.showError('Unable to load order details'.tr());
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey('tracking_${tracking.orderId}_${tracking.status.index}'),
          margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
            vertical: verticalMargin,
          ),
          decoration: BoxDecoration(
            color: _isDark ? AppTheme.dark : AppTheme.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: _isDark
                  ? trackingColor.withOpacity(0.3)
                  : trackingColor.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: trackingColor.withOpacity(_isDark ? 0.2 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrackingHeader(tracking, trackingColor, trackingIcon),
                SizedBox(height: ResponsiveUtils.spacing(context, 16)),
                _buildTrackingProgress(tracking, trackingColor),
                SizedBox(height: ResponsiveUtils.spacing(context, 16)),
                _buildTrackingDetails(tracking),
                if (tracking.driverName != null) ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, 14)),
                  _buildDriverInfo(tracking),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTrackingColor(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return const Color(0xFFFF9F43);
      case OrderTrackingStatus.preparing:
        return const Color(0xFF6842E2);
      case OrderTrackingStatus.outForDelivery:
        return const Color(0xFF3B82F6);
      case OrderTrackingStatus.delivered:
        return const Color(0xFF28E6C5);
      case OrderTrackingStatus.cancelled:
        return const Color(0xFFEF4444);
      default:
        return status.color;
    }
  }

  IconData _getTrackingIcon(OrderTrackingStatus status) {
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

  Widget _buildTrackingHeader(
      OrderTrackingModel tracking,
      Color trackingColor,
      IconData trackingIcon,
      ) {
    final iconContainerSize = ResponsiveUtils.size(context, 48);

    return Row(
      children: [
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                trackingColor,
                trackingColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 14),
            ),
            boxShadow: [
              BoxShadow(
                color: trackingColor.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            trackingIcon,
            color: AppTheme.white,
            size: ResponsiveUtils.icon(context, 22),
          ),
        ),

        SizedBox(width: ResponsiveUtils.spacing(context, 12)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLiveIndicator(trackingColor),
                  SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                  Flexible(
                    child: Text(
                      _getTrackingStatusText(tracking.status).tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 14),
                        fontWeight: FontWeight.bold,
                        color: _isDark ? AppTheme.white : AppTheme.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.spacing(context, 4)),
              Text(
                '${'Order'.tr()}: ${tracking.orderReference}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 12),
                  color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            if (!mounted || _isDisposed) return;
            HapticFeedback.lightImpact();
            _trackingService.stopTracking();
            _safeSetState(() {
              _currentTrackingData = null;
            });
          },
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.white.withOpacity(0.1)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 10),
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: _isDark ? AppTheme.darkGray : Colors.grey[600],
              size: ResponsiveUtils.icon(context, 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveIndicator(Color trackingColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 8),
        vertical: ResponsiveUtils.spacing(context, 3),
      ),
      decoration: BoxDecoration(
        color: trackingColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: trackingColor),
          SizedBox(width: ResponsiveUtils.spacing(context, 4)),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 9),
              fontWeight: FontWeight.w800,
              color: trackingColor,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingProgress(
      OrderTrackingModel tracking,
      Color trackingColor,
      ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
      decoration: BoxDecoration(
        color: _isDark
            ? AppTheme.white.withOpacity(0.05)
            : AppTheme.lightGray.withOpacity(0.7),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 14),
        ),
      ),
      child: Row(
        children: [
          _buildProgressStepItem(
            icon: Icons.pending_actions_rounded,
            label: 'Pending'.tr(),
            isCompleted:
            tracking.status.index >= OrderTrackingStatus.orderPlaced.index,
            isActive: tracking.status == OrderTrackingStatus.orderPlaced,
            activeColor: trackingColor,
          ),
          Expanded(
            child: _buildProgressConnector(
              isCompleted:
              tracking.status.index > OrderTrackingStatus.orderPlaced.index,
              activeColor: trackingColor,
            ),
          ),
          _buildProgressStepItem(
            icon: Icons.inventory_2_rounded,
            label: 'Preparing'.tr(),
            isCompleted:
            tracking.status.index >= OrderTrackingStatus.preparing.index,
            isActive: tracking.status == OrderTrackingStatus.preparing,
            activeColor: trackingColor,
          ),
          Expanded(
            child: _buildProgressConnector(
              isCompleted:
              tracking.status.index > OrderTrackingStatus.preparing.index,
              activeColor: trackingColor,
            ),
          ),
          _buildProgressStepItem(
            icon: Icons.local_shipping_rounded,
            label: 'On Way'.tr(),
            isCompleted: tracking.status.index >=
                OrderTrackingStatus.outForDelivery.index,
            isActive: tracking.status == OrderTrackingStatus.outForDelivery,
            activeColor: trackingColor,
          ),
          Expanded(
            child: _buildProgressConnector(
              isCompleted: tracking.status == OrderTrackingStatus.delivered,
              activeColor: trackingColor,
            ),
          ),
          _buildProgressStepItem(
            icon: Icons.check_circle_rounded,
            label: 'Delivered'.tr(),
            isCompleted: tracking.status == OrderTrackingStatus.delivered,
            isActive: tracking.status == OrderTrackingStatus.delivered,
            activeColor: trackingColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepItem({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isActive,
    required Color activeColor,
  }) {
    final containerSize = ResponsiveUtils.size(context, 36);
    final iconSize = ResponsiveUtils.icon(context, 16);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? activeColor.withOpacity(isActive ? 1 : 0.8)
                : (_isDark
                ? AppTheme.white.withOpacity(0.1)
                : AppTheme.darkGray.withOpacity(0.2)),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
              BoxShadow(
                color: activeColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Icon(
            icon,
            color: isCompleted || isActive
                ? AppTheme.white
                : (_isDark ? AppTheme.darkGray : Colors.grey[500]),
            size: iconSize,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 6)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.font(context, 9),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? activeColor
                : (_isDark ? AppTheme.darkGray : Colors.grey[600]),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressConnector({
    required bool isCompleted,
    required Color activeColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 3,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 4),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: isCompleted
            ? activeColor
            : (_isDark
            ? AppTheme.white.withOpacity(0.15)
            : AppTheme.darkGray.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildTrackingDetails(OrderTrackingModel tracking) {
    return _buildTrackingDetailItem(
      icon: Icons.location_on_rounded,
      label: 'Delivery Address'.tr(),
      value: tracking.deliveryAddress ?? 'Not specified'.tr(),
      color: AppTheme.purple,
    );
  }

  Widget _buildTrackingDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
      decoration: BoxDecoration(
        color: _isDark
            ? AppTheme.white.withOpacity(0.05)
            : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 12),
        ),
        border: Border.all(
          color: _isDark
              ? AppTheme.white.withOpacity(0.08)
              : color.withOpacity(0.1),
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
                size: ResponsiveUtils.icon(context, 14),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 6)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 10),
                    color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 6)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 12),
              fontWeight: FontWeight.w600,
              color: _isDark ? AppTheme.white : AppTheme.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(OrderTrackingModel tracking) {
    final avatarSize = ResponsiveUtils.size(context, 44);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
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
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 14),
        ),
        border: Border.all(
          color: AppTheme.purple.withOpacity(_isDark ? 0.2 : 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple, AppTheme.purple.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(tracking.driverName ?? 'D'),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),

          SizedBox(width: ResponsiveUtils.spacing(context, 12)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 10),
                    color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 2)),
                Text(
                  tracking.driverName ?? '',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 14),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
                if (tracking.driverPhone != null) ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, 2)),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: ResponsiveUtils.icon(context, 12),
                        color: AppTheme.lightGreen,
                      ),
                      SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                      Text(
                        tracking.driverPhone!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.font(context, 11),
                          color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 10),
              vertical: ResponsiveUtils.spacing(context, 6),
            ),
            decoration: BoxDecoration(
              color: AppTheme.yellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppTheme.yellow,
                  size: ResponsiveUtils.icon(context, 14),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                Text(
                  '4.9',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 12),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Charts Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildChartsSection() {
    return _wrapWithTourTarget(
      tourKey: _tourController?.statsChartKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Account Overview'.tr()),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ColumnChartsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: ResponsiveUtils.paddingOnly(
        context,
        left: 16,
        right: 16,
        top: 16,
        bottom: 10,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.font(context, 16),
          fontWeight: FontWeight.bold,
          color: _isDark ? AppTheme.white : AppTheme.black,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 💰 Financial Summary Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildFinancialSummary() {
    dynamic user;
    try {
      user = ProfileCubit.get(context).userModel;
    } catch (e) {
      user = null;
    }

    final balance = double.tryParse(user?.closingBalance?.toString() ?? '0') ?? 0;
    final isPositive = balance >= 0;

    final horizontalMargin = ResponsiveUtils.spacing(context, 16);
    final padding = ResponsiveUtils.spacing(context, 16);
    final radius = ResponsiveUtils.radius(context, 22);

    return _wrapWithTourTarget(
      tourKey: _tourController?.balanceCardKey,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDark
                ? [AppTheme.purple.withOpacity(0.4), AppTheme.dark]
                : [AppTheme.purple, const Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purple.withOpacity(_isDark ? 0.25 : 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Balance'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 13),
                    color: AppTheme.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildBalanceIndicator(isPositive),
              ],
            ),

            SizedBox(height: ResponsiveUtils.spacing(context, 12)),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user?.closingBalance ?? 0}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 28),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                    height: 1,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 6)),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveUtils.spacing(context, 4),
                  ),
                  child: context.getCurrencyWidget(
                    height: ResponsiveUtils.font(context, 25),
                    color: AppTheme.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.spacing(context, 16)),

            Row(
              children: [
                _buildMiniStat(
                  icon: Icons.receipt_long_rounded,
                  label: 'Invoices'.tr(),
                  value: '${user?.totalInvoicesCount ?? 0}',
                ),
                _buildStatDivider(),
                _buildMiniStat(
                  icon: Icons.stars_rounded,
                  label: 'Points'.tr(),
                  value: '${user?.points ?? 0}',
                ),
                _buildStatDivider(),
                _buildMiniStat(
                  icon: Icons.store_rounded,
                  label: 'Branches'.tr(),
                  value: '${user?.branches?.length ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceIndicator(bool isPositive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 10),
        vertical: ResponsiveUtils.spacing(context, 4),
      ),
      decoration: BoxDecoration(
        color: (isPositive ? AppTheme.lightGreen : AppTheme.red).withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isPositive ? AppTheme.lightGreen : AppTheme.red,
            size: ResponsiveUtils.icon(context, 14),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 3)),
          Text(
            isPositive ? 'Positive'.tr() : 'Negative'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 10),
              fontWeight: FontWeight.w600,
              color: isPositive ? AppTheme.lightGreen : AppTheme.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.white.withOpacity(0.7),
            size: ResponsiveUtils.icon(context, 16),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 14),
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, 1)),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 9),
              color: AppTheme.white.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: ResponsiveUtils.height(context, 32),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 8),
      ),
      color: AppTheme.white.withOpacity(0.2),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🛒 Buy Now Pay Later Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBuyNowPayLaterCard() {
    final horizontalMargin = ResponsiveUtils.spacing(context, 16);
    final verticalMargin = ResponsiveUtils.spacing(context, 12);
    final padding = ResponsiveUtils.spacing(context, 18);
    final radius = ResponsiveUtils.radius(context, 24);

    return AnimatedBuilder(
      animation: _bnplController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (!mounted || _isDisposed) return;
            HapticFeedback.mediumImpact();
            _launchBuyNowPayLater();
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalMargin,
              vertical: verticalMargin,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.purple.withOpacity(0.4 * _pulseAnimation.value),
                          blurRadius: 25,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: _isDark
                          ? AppTheme.purple.withOpacity(0.4)
                          : AppTheme.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _isDark
                                  ? [
                                AppTheme.purple.withOpacity(0.3),
                                AppTheme.purple.withOpacity(0.5),
                              ]
                                  : [
                                AppTheme.purple.withOpacity(0.85),
                                AppTheme.purple,
                              ],
                            ),
                          ),
                        ),

                        ..._buildBNPLDecorations(),

                        Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            children: [
                              _buildBNPLHeader(),
                              SizedBox(height: ResponsiveUtils.spacing(context, 14)),
                              _buildBNPLContent(),
                              SizedBox(height: ResponsiveUtils.spacing(context, 16)),
                              _buildBNPLButton(),
                            ],
                          ),
                        ),

                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppTheme.white.withOpacity(0.6),
                                  AppTheme.white.withOpacity(0.8),
                                  AppTheme.white.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBNPLDecorations() {
    return [
      Positioned(
        right: _isRTL ? null : -40,
        left: _isRTL ? -40 : null,
        top: -40,
        child: Container(
          width: ResponsiveUtils.size(context, 120),
          height: ResponsiveUtils.size(context, 120),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.white.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      Positioned(
        left: _isRTL ? null : -25,
        right: _isRTL ? -25 : null,
        bottom: -25,
        child: Container(
          width: ResponsiveUtils.size(context, 80),
          height: ResponsiveUtils.size(context, 80),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildBNPLHeader() {
    final logoContainerSize = ResponsiveUtils.size(context, 44);

    return Row(
      children: [
        Container(
          width: logoContainerSize,
          height: logoContainerSize,
          padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/svg/logo-en.25718180530e7f68dcf29a46bfbfea32.svg',
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(width: ResponsiveUtils.spacing(context, 10)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveUtils.spacing(context, 1)),
              Text(
                'Buy Now, Pay Later'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 12),
                  fontWeight: FontWeight.w500,
                  color: AppTheme.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),

        _buildExclusiveBadge(),
      ],
    );
  }

  Widget _buildExclusiveBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing(context, 10),
        vertical: ResponsiveUtils.spacing(context, 5),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD93D), Color(0xFFFF6B6B)],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD93D).withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: Colors.white,
            size: ResponsiveUtils.icon(context, 12),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 3)),
          Text(
            'Exclusive'.tr(),
            style: TextStyle(
              fontSize: ResponsiveUtils.font(context, 9),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBNPLContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buy your products now'.tr(),
          style: TextStyle(
            fontSize: ResponsiveUtils.font(context, 18),
            fontWeight: FontWeight.w600,
            color: AppTheme.white.withOpacity(0.95),
            height: 1.3,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, 4)),
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    AppTheme.yellow,
                    Color(0xFFFCD34D),
                    AppTheme.lightGreen,
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'Pay later'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 24),
                  fontWeight: FontWeight.w900,
                  color: AppTheme.white,
                  height: 1.1,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, 8)),
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 6)),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.radius(context, 8),
                ),
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                color: AppTheme.lightGreen,
                size: ResponsiveUtils.icon(context, 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBNPLButton() {
    final buttonHeight = ResponsiveUtils.buttonHeight(context, 48);
    final radius = ResponsiveUtils.radius(context, 14);

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!mounted || _isDisposed) return;
            HapticFeedback.mediumImpact();
            _launchBuyNowPayLater();
          },
          borderRadius: BorderRadius.circular(radius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 6)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.purple, AppTheme.purple.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.radius(context, 8),
                  ),
                ),
                child: Icon(
                  Icons.person_add_rounded,
                  color: AppTheme.white,
                  size: ResponsiveUtils.icon(context, 14),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 10)),
              Text(
                'Register now for free'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 14),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.purple,
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, 8)),
              DirectionalArrow(
                direction: ArrowDirection.forward,
                color: AppTheme.purple,
                size: ResponsiveUtils.icon(context, 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⚡ Quick Actions
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    final height = ResponsiveUtils.height(context, 85);
    final horizontalPadding = ResponsiveUtils.spacing(context, 12);

    return _wrapWithTourTarget(
      tourKey: _tourController?.quickActionsKey,
      child: SizedBox(
        height: height,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          children: [
            _QuickActionButton(
              icon: Icons.receipt_long_rounded,
              label: 'Invoices'.tr(),
              color: AppTheme.purple,
              isDark: _isDark,
              onTap: () {
                if (!mounted || _isDisposed) return;
                MyNavigator.navigateTo(context, const InVoiceScreen());
              },
            ),
            _QuickActionButton(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Payments'.tr(),
              color: AppTheme.lightGreen,
              isDark: _isDark,
              onTap: () {
                if (!mounted || _isDisposed) return;
                MyNavigator.navigateTo(context, const OverdueScreen());
              },
            ),
            _QuickActionButton(
              icon: Icons.card_giftcard_rounded,
              label: 'Rewards'.tr(),
              color: AppTheme.yellow,
              isDark: _isDark,
              onTap: () {
                if (!mounted || _isDisposed) return;
                MyNavigator.navigateTo(context, const LoyalityPointsScreen());
              },
            ),
            _QuickActionButton(
              icon: Icons.receipt_rounded,
              label: 'Bonds'.tr(),
              color: AppTheme.blue,
              isDark: _isDark,
              onTap: () {
                if (!mounted || _isDisposed) return;
                MyNavigator.navigateTo(context, const ReceiptScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 💳 Indebtedness Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildIndebtednessCard() {
    dynamic user;
    try {
      user = ProfileCubit.get(context).userModel;
    } catch (e) {
      user = null;
    }

    final hasOverdue = (double.tryParse(user?.overdue?.toString() ?? '0') ?? 0) > 0;

    final horizontalMargin = ResponsiveUtils.spacing(context, 16);
    final verticalMargin = ResponsiveUtils.spacing(context, 6);
    final radius = ResponsiveUtils.radius(context, 20);

    return GestureDetector(
      onTap: () {
        if (!mounted || _isDisposed) return;
        HapticFeedback.lightImpact();
        MyNavigator.navigateTo(context, const OverdueScreen());
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin,
          vertical: verticalMargin,
        ),
        decoration: BoxDecoration(
          color: _isDark ? AppTheme.dark : AppTheme.white,
          borderRadius: BorderRadius.circular(radius),
          border: _isDark
              ? Border.all(color: AppTheme.white.withOpacity(0.08))
              : null,
          boxShadow: [
            BoxShadow(
              color: (_isDark ? Colors.black : AppTheme.darkGray).withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildIndebtednessHeader(),
            _buildIndebtednessStats(user),
            if (hasOverdue) _buildOverdueWarning(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndebtednessHeader() {
    final padding = ResponsiveUtils.spacing(context, 14);
    final iconPadding = ResponsiveUtils.spacing(context, 10);
    final iconRadius = ResponsiveUtils.radius(context, 12);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.purple.withOpacity(0.2), Colors.transparent]
              : [AppTheme.purple.withOpacity(0.05), Colors.transparent],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.radius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple, AppTheme.purple.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(iconRadius),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.account_balance_rounded,
              color: AppTheme.white,
              size: ResponsiveUtils.icon(context, 20),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Indebtedness'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 16),
                    fontWeight: FontWeight.bold,
                    color: _isDark ? AppTheme.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, 2)),
                Text(
                  'Financial Overview'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 11),
                    color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.white.withOpacity(0.1)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 10),
              ),
            ),
            child: DirectionalArrow(
              direction: ArrowDirection.forwardIos,
              color: _isDark ? AppTheme.white : AppTheme.dark,
              size: ResponsiveUtils.icon(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndebtednessStats(dynamic user) {
    final padding = ResponsiveUtils.spacing(context, 14);
    final innerPadding = ResponsiveUtils.spacing(context, 12);

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
      child: Container(
        padding: EdgeInsets.all(innerPadding),
        decoration: BoxDecoration(
          color: _isDark ? AppTheme.white.withOpacity(0.05) : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.radius(context, 14),
          ),
        ),
        child: Column(
          children: [
            _buildStatRow(
              icon: Icons.payments_rounded,
              label: 'Total Due'.tr(),
              value: '${user?.totalOutStanding ?? 0}',
              currencyWidget: context.getCurrencyWidget(
                height: ResponsiveUtils.font(context, 25),
                color: _isDark ? AppTheme.darkGray : Colors.grey[600],
              ),
              color: AppTheme.lightGreen,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.spacing(context, 10),
              ),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _isDark
                          ? AppTheme.white.withOpacity(0.1)
                          : AppTheme.darkGray.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            _buildStatRow(
              icon: Icons.warning_amber_rounded,
              label: 'Overdue'.tr(),
              value: '${user?.overdue ?? 0}',
              currencyWidget: context.getCurrencyWidget(
                height: ResponsiveUtils.font(context, 25),
                color: _isDark ? AppTheme.darkGray : Colors.grey[600],
              ),
              color: AppTheme.red,
              isWarning: (double.tryParse(user?.overdue?.toString() ?? '0') ?? 0) > 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? currencyWidget,
    String? currency,
    required Color color,
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 8)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.radius(context, 10),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveUtils.icon(context, 18),
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.font(context, 12),
                  color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                ),
              ),
              SizedBox(height: ResponsiveUtils.spacing(context, 2)),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 18),
                      fontWeight: FontWeight.bold,
                      color: _isDark ? AppTheme.white : AppTheme.black,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                  if (currencyWidget != null)
                    currencyWidget
                  else if (currency != null)
                    Text(
                      currency,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.font(context, 22),
                        color: _isDark ? AppTheme.darkGray : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (isWarning)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, 10),
              vertical: ResponsiveUtils.spacing(context, 4),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.radius(context, 12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  color: color,
                  size: ResponsiveUtils.icon(context, 12),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 3)),
                Text(
                  'Action'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.font(context, 10),
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOverdueWarning() {
    final margin = ResponsiveUtils.spacing(context, 14);
    final padding = ResponsiveUtils.spacing(context, 12);

    return Container(
      margin: EdgeInsets.fromLTRB(margin, 0, margin, margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.red.withOpacity(_isDark ? 0.2 : 0.1),
            AppTheme.orange.withOpacity(_isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.radius(context, 12),
        ),
        border: Border.all(color: AppTheme.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppTheme.red,
            size: ResponsiveUtils.icon(context, 18),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, 10)),
          Expanded(
            child: Text(
              'You have pending payments. Tap to view details.'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 11),
                color: _isDark ? AppTheme.white : AppTheme.dark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Services Grid
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildServicesGrid() {
    dynamic user;
    try {
      user = ProfileCubit.get(context).userModel;
    } catch (e) {
      user = null;
    }

    final padding = ResponsiveUtils.spacing(context, 16);
    final spacing = ResponsiveUtils.spacing(context, 12);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          // Expanded(
          //   child: _ServiceCard(
          //     icon: Icons.trending_up_rounded,
          //     title: 'Arrears'.tr(),
          //     value: '${user?.totalInvoicesAmount ?? 0}',
          //     suffixWidget: context.getCurrencyWidget(
          //       height: ResponsiveUtils.font(context, 25),
          //       color: AppTheme.white.withOpacity(0.7),
          //     ),
          //     gradient: const LinearGradient(
          //       colors: [AppTheme.purple, Color(0xFF8B5CF6)],
          //     ),
          //     isDark: _isDark,
          //     onTap: () {
          //       if (!mounted || _isDisposed) return;
          //       MyNavigator.navigateTo(context, const OverdueScreen());
          //     },
          //   ),
          // ),
          // Expanded(
          //   child: BlocBuilder<OffersCubit, OffersState>(
          //     builder: (context, state) {
          //       return _ServiceCard(
          //         icon: Icons.local_offer_outlined,
          //         title: 'Offers'.tr(),
          //         value: '${OffersCubit.get(context).totalOffers}',
          //         // value: '${user?.totalInvoicesAmount ?? 0}',
          //         suffix: 'Offer'.tr(),
          //         gradient: const LinearGradient(
          //           colors: [AppTheme.purple, Color(0xFF8B5CF6)],
          //         ),
          //         isDark: _isDark,
          //         onTap: () {
          //           if (!mounted || _isDisposed) return;
          //           MyNavigator.navigateTo(context, const OffersScreen());
          //         },
          //       );
          //     },
          //   ),
          // ),
          // SizedBox(width: spacing),
          Expanded(
            child: _ServiceCard(
              icon: Icons.card_giftcard_rounded,
              title: 'Loyalty'.tr(),
              value: '${user?.points ?? 0}',
              suffix: 'Points'.tr(),
              gradient: const LinearGradient(
                colors: [AppTheme.lightGreen, Color(0xFF34D399)],
              ),
              isDark: _isDark,
              onTap: () {
                if (!mounted || _isDisposed) return;
                MyNavigator.navigateTo(context, const LoyalityPointsScreen());
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔴 Pulsing Dot Widget
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
          width: ResponsiveUtils.size(context, 6),
          height: ResponsiveUtils.size(context, 6),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚡ Quick Action Button Widget
// ═══════════════════════════════════════════════════════════════════════════
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = ResponsiveUtils.width(context, 68);
    final iconContainerSize = ResponsiveUtils.size(context, 46);
    final horizontalMargin = ResponsiveUtils.spacing(context, 5);
    final iconSize = ResponsiveUtils.icon(context, 22);
    final radius = ResponsiveUtils.radius(context, 14);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: buttonWidth,
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.dark : AppTheme.white,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: color.withOpacity(isDark ? 0.3 : 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isDark ? 0.15 : 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: iconSize),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 10),
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkGray : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Service Card Widget
// ═══════════════════════════════════════════════════════════════════════════
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? suffixWidget;
  final String? suffix;
  final Gradient gradient;
  final bool isDark;
  final bool? isMoney;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.value,
    this.suffixWidget,
    this.suffix,
    this.isMoney,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.spacing(context, 14);
    final radius = ResponsiveUtils.radius(context, 18);
    final iconContainerSize = ResponsiveUtils.size(context, 36);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius(context, 10),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.white,
                    size: ResponsiveUtils.icon(context, 18),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 6)),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius(context, 8),
                    ),
                  ),
                  child: DirectionalArrow(
                    direction: ArrowDirection.forwardIos,
                    color: AppTheme.white,
                    size: ResponsiveUtils.icon(context, 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 14)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, 12),
                fontWeight: FontWeight.w600,
                color: AppTheme.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 6)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.font(context, 18),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 4)),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveUtils.spacing(context, 2),
                  ),
                  child: suffixWidget ??
                      Text(
                        suffix ?? '',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.font(context, 10),
                          fontWeight: FontWeight.w500,
                          color: AppTheme.white.withOpacity(0.7),
                        ),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Mini Crescent Painter
// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════
// 🌙 Mini Crescent Painter - Enhanced with Glow Effect
// ═══════════════════════════════════════════════════════════════════════
class _MiniCrescentPainter extends CustomPainter {
  final Color color;

  _MiniCrescentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 🌟 Outer glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(center, radius + 2, glowPaint);

    // 🌙 Main crescent
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final innerPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.1),
      radius * 0.75,
      innerPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🕌 Ramadan Pattern Painter
// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════
// 🎨 Ramadan Pattern Painter - Enhanced with Islamic Geometry
// ═══════════════════════════════════════════════════════════════════════
class _RamadanPatternPainter extends CustomPainter {
  final bool isDark;

  _RamadanPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Enhanced color and stroke for light mode - Green Theme
    final paint = Paint()
      ..color = const Color(0xFF14B8A6).withOpacity(isDark ? 0.04 : 0.12) // Teal
      ..strokeWidth = isDark ? 1 : 1.5
      ..style = PaintingStyle.stroke;

    // 🕌 Islamic 8-point stars pattern
    for (double i = 0; i < size.width; i += 30) {
      for (double j = 0; j < size.height; j += 30) {
        _drawIslamicStar(canvas, Offset(i, j), 12, paint);
      }
    }

    // 🌙 Enhanced crescent decorations - Green
    final crescentPaint = Paint()
      ..color = const Color(0xFF14B8A6).withOpacity(isDark ? 0.06 : 0.15)
      ..style = PaintingStyle.fill;

    for (double x = 40; x < size.width; x += 100) {
      final center = Offset(x, size.height * 0.3);
      _drawCrescent(canvas, center, crescentPaint);
    }

    // 🏮 Lantern silhouettes (light mode only) - Mint
    if (!isDark) {
      final lanternPaint = Paint()
        ..color = const Color(0xFF1FA88A).withOpacity(0.08) // Mint green
        ..style = PaintingStyle.fill;

      for (double x = 70; x < size.width; x += 120) {
        _drawLanternSilhouette(canvas, Offset(x, size.height * 0.7), lanternPaint);
      }
    }
  }

  // 🌟 Draw 8-point Islamic star
  void _drawIslamicStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Inner points
      final innerAngle = angle + math.pi / 8;
      final innerRadius = radius * 0.4;
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // 🌙 Draw crescent with proper cutout
  void _drawCrescent(Canvas canvas, Offset center, Paint crescentPaint) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, 1000, 1000), Paint());
    canvas.drawCircle(center, 8, crescentPaint);

    final innerPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    canvas.drawCircle(Offset(center.dx + 4, center.dy - 1), 6, innerPaint);
    canvas.restore();
  }

  // 🏮 Draw decorative lantern silhouette
  void _drawLanternSilhouette(Canvas canvas, Offset center, Paint paint) {
    final path = Path();

    // Top dome
    path.moveTo(center.dx, center.dy - 8);
    path.lineTo(center.dx - 4, center.dy - 5);
    path.lineTo(center.dx - 3, center.dy);

    // Body
    path.lineTo(center.dx - 3, center.dy + 6);
    path.lineTo(center.dx - 4, center.dy + 8);

    // Bottom
    path.lineTo(center.dx, center.dy + 10);
    path.lineTo(center.dx + 4, center.dy + 8);

    // Right side
    path.lineTo(center.dx + 3, center.dy + 6);
    path.lineTo(center.dx + 3, center.dy);
    path.lineTo(center.dx + 4, center.dy - 5);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}