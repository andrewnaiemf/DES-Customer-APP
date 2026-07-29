import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'tour_step_model.dart';
import 'app_tour_service.dart';

/// Controller للتحكم في الجولة الإرشادية
class TourController {
  final AppTourService _service = AppTourService.instance;
  
  // ✅ Instance-level keys بدلاً من static
  late final GlobalKey notificationKey;
  late final GlobalKey themeToggleKey;
  late final GlobalKey balanceCardKey;
  late final GlobalKey quickActionsKey;
  late final GlobalKey statsChartKey;
  late final GlobalKey bottomNavKey;
  
  // ✅ Keys لشاشات أخرى
  late final GlobalKey addOrderKey;
  late final GlobalKey ordersListKey;
  late final GlobalKey orderFilterKey;
  late final GlobalKey orderSearchKey;
  late final GlobalKey invoicesTabKey;
  late final GlobalKey invoiceCardKey;
  late final GlobalKey invoiceActionsKey;
  late final GlobalKey overdueKey;
  
  bool _isDisposed = false;
  
  // ✅ Constructor - ينشئ keys فريدة لكل instance
  TourController() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Home Screen Keys
    notificationKey = GlobalKey(debugLabel: 'notification_$timestamp');
    themeToggleKey = GlobalKey(debugLabel: 'theme_$timestamp');
    balanceCardKey = GlobalKey(debugLabel: 'balance_$timestamp');
    quickActionsKey = GlobalKey(debugLabel: 'quick_$timestamp');
    statsChartKey = GlobalKey(debugLabel: 'stats_$timestamp');
    bottomNavKey = GlobalKey(debugLabel: 'bottom_nav_$timestamp');
    
    // Orders Screen Keys
    addOrderKey = GlobalKey(debugLabel: 'add_order_$timestamp');
    ordersListKey = GlobalKey(debugLabel: 'orders_list_$timestamp');
    orderFilterKey = GlobalKey(debugLabel: 'order_filter_$timestamp');
    orderSearchKey = GlobalKey(debugLabel: 'order_search_$timestamp');
    
    // Invoices Screen Keys
    invoicesTabKey = GlobalKey(debugLabel: 'invoices_tab_$timestamp');
    invoiceCardKey = GlobalKey(debugLabel: 'invoice_card_$timestamp');
    invoiceActionsKey = GlobalKey(debugLabel: 'invoice_actions_$timestamp');
    overdueKey = GlobalKey(debugLabel: 'overdue_$timestamp');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏠 Home Screen Tour
  // ─────────────────────────────────────────────────────────────────────────

  List<TourStep> get homeScreenSteps => [
    TourStep(
      id: 'home_notification',
      targetKey: notificationKey,
      title: 'Notifications'.tr(),
      description: 'View all your new notifications and important alerts'.tr(),
      icon: Icons.notifications_rounded,
      accentColor: const Color(0xFFF59E0B),
      spotlightShape: SpotlightShape.circle,
    ),
    TourStep(
      id: 'home_theme',
      targetKey: themeToggleKey,
      title: 'Dark Mode'.tr(),
      description: 'Switch between light and dark mode for your comfort'.tr(),
      icon: Icons.dark_mode_rounded,
      accentColor: const Color(0xFF6366F1),
      spotlightShape: SpotlightShape.circle,
    ),
    TourStep(
      id: 'home_balance',
      targetKey: balanceCardKey,
      title: 'Your Balance'.tr(),
      description: 'Here you can find your balance summary and total dues and payments'.tr(),
      icon: Icons.account_balance_wallet_rounded,
      accentColor: const Color(0xFF10B981),
      spotlightShape: SpotlightShape.roundedRectangle,
      spotlightPadding: 12,
    ),
    TourStep(
      id: 'home_quick_actions',
      targetKey: quickActionsKey,
      title: 'Quick Actions'.tr(),
      description: 'Quick access to invoices, orders, loyalty points, and more'.tr(),
      icon: Icons.flash_on_rounded,
      accentColor: const Color(0xFF22D3EE),
      spotlightShape: SpotlightShape.roundedRectangle,
      spotlightPadding: 8,
    ),
    TourStep(
      id: 'home_stats',
      targetKey: statsChartKey,
      title: 'Statistics'.tr(),
      description: 'Track your payment and invoice statistics visually'.tr(),
      icon: Icons.bar_chart_rounded,
      accentColor: const Color(0xFF8B5CF6),
      spotlightShape: SpotlightShape.roundedRectangle,
    ),
    TourStep(
      id: 'home_bottom_nav',
      targetKey: bottomNavKey,
      title: 'Navigation Bar'.tr(),
      description: 'Use the navigation bar to move between main screens'.tr(),
      icon: Icons.menu_rounded,
      accentColor: const Color(0xFF6366F1),
      spotlightShape: SpotlightShape.roundedRectangle,
      tooltipPosition: TooltipPosition.top,
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 Orders Screen Tour
  // ─────────────────────────────────────────────────────────────────────────

  List<TourStep> get ordersScreenSteps => [
    TourStep(
      id: 'orders_add',
      targetKey: addOrderKey,
      title: 'Add New Order'.tr(),
      description: 'Click here to create a new order easily'.tr(),
      icon: Icons.add_circle_rounded,
      accentColor: const Color(0xFF10B981),
      spotlightShape: SpotlightShape.circle,
    ),
    TourStep(
      id: 'orders_filter',
      targetKey: orderFilterKey,
      title: 'Filter Orders'.tr(),
      description: 'Filter orders by status or date'.tr(),
      icon: Icons.filter_list_rounded,
      accentColor: const Color(0xFF6366F1),
    ),
    TourStep(
      id: 'orders_search',
      targetKey: orderSearchKey,
      title: 'Search'.tr(),
      description: 'Search for a specific order by order number or customer name'.tr(),
      icon: Icons.search_rounded,
      accentColor: const Color(0xFF22D3EE),
    ),
    TourStep(
      id: 'orders_list',
      targetKey: ordersListKey,
      title: 'Orders List'.tr(),
      description: 'Click on any order to view its full details'.tr(),
      icon: Icons.list_alt_rounded,
      accentColor: const Color(0xFF8B5CF6),
      spotlightShape: SpotlightShape.roundedRectangle,
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // 🧾 Invoices Screen Tour
  // ─────────────────────────────────────────────────────────────────────────

  List<TourStep> get invoicesScreenSteps => [
    TourStep(
      id: 'invoices_tabs',
      targetKey: invoicesTabKey,
      title: 'Invoice Tabs'.tr(),
      description: 'Navigate between pending, paid, and overdue invoices'.tr(),
      icon: Icons.tab_rounded,
      accentColor: const Color(0xFF6366F1),
    ),
    TourStep(
      id: 'invoices_card',
      targetKey: invoiceCardKey,
      title: 'Invoice Details'.tr(),
      description: 'Click on an invoice to view full details and items'.tr(),
      icon: Icons.receipt_long_rounded,
      accentColor: const Color(0xFF10B981),
      spotlightShape: SpotlightShape.roundedRectangle,
    ),
    TourStep(
      id: 'invoices_overdue',
      targetKey: overdueKey,
      title: 'Overdue Invoices'.tr(),
      description: 'Track overdue invoices and pay on time'.tr(),
      icon: Icons.warning_amber_rounded,
      accentColor: const Color(0xFFEF4444),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // ⚙️ Settings Screen Tour
  // ─────────────────────────────────────────────────────────────────────────
  
  static final GlobalKey profileKey = GlobalKey();
  static final GlobalKey languageKey = GlobalKey();
  static final GlobalKey darkModeSettingKey = GlobalKey();
  static final GlobalKey biometricKey = GlobalKey(); // 🔐 مفتاح البصمة
  static final GlobalKey notificationSettingKey = GlobalKey();
  static final GlobalKey helpKey = GlobalKey();
  static final GlobalKey restartTourKey = GlobalKey();

  List<TourStep> get settingsScreenSteps => [
    TourStep(
      id: 'settings_profile',
      targetKey: profileKey,
      title: 'Profile'.tr(),
      description: 'Edit your personal data and account information'.tr(),
      icon: Icons.person_rounded,
      accentColor: const Color(0xFF6366F1),
    ),
    TourStep(
      id: 'settings_language',
      targetKey: languageKey,
      title: 'Language'.tr(),
      description: 'Change app language (Arabic / English)'.tr(),
      icon: Icons.language_rounded,
      accentColor: const Color(0xFF22D3EE),
    ),
    TourStep(
      id: 'settings_dark_mode',
      targetKey: darkModeSettingKey,
      title: 'Dark Mode'.tr(),
      description: 'Enable dark mode for eye comfort'.tr(),
      icon: Icons.dark_mode_rounded,
      accentColor: const Color(0xFF8B5CF6),
    ),
    TourStep(
      id: 'settings_biometric',
      targetKey: biometricKey,
      title: 'App Lock with Biometric'.tr(),
      description: 'Enable biometric authentication to protect the app and quick access without password'.tr(),
      icon: Icons.fingerprint_rounded,
      accentColor: const Color(0xFFF59E0B),
      spotlightShape: SpotlightShape.roundedRectangle,
      spotlightPadding: 8,
    ),
    TourStep(
      id: 'settings_restart_tour',
      targetKey: restartTourKey,
      title: 'Restart Tour'.tr(),
      description: 'Click here to watch the tour again'.tr(),
      icon: Icons.replay_rounded,
      accentColor: const Color(0xFF10B981),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // 🎯 Tour Methods
  // ─────────────────────────────────────────────────────────────────────────
  
  // ✅ Safe methods - تتحقق من _isDisposed
  Future<bool> startHomeTour({bool force = false}) {
    if (_isDisposed) return Future.value(false);
    return _service.startTour(
      screenId: 'home_screen',
      steps: homeScreenSteps,
      forceShow: force,
    );
  }

  Future<bool> startOrdersTour({bool force = false}) {
    if (_isDisposed) return Future.value(false);
    return _service.startTour(
      screenId: 'orders_screen',
      steps: ordersScreenSteps,
      forceShow: force,
    );
  }

  Future<bool> startInvoicesTour({bool force = false}) {
    if (_isDisposed) return Future.value(false);
    return _service.startTour(
      screenId: 'invoices_screen',
      steps: invoicesScreenSteps,
      forceShow: force,
    );
  }

  Future<bool> startSettingsTour({bool force = false}) {
    if (_isDisposed) return Future.value(false);
    return _service.startTour(
      screenId: 'settings_screen',
      steps: settingsScreenSteps,
      forceShow: force,
    );
  }

  void next() {
    if (_isDisposed) return;
    _service.nextStep();
  }
  
  void previous() {
    if (_isDisposed) return;
    _service.previousStep();
  }
  
  void skip() {
    if (_isDisposed) return;
    _isDisposed = true;
    _service.skipTour();
  }
  
  void complete() {
    if (_isDisposed) return;
    _isDisposed = true;
    _service.completeTour();
  }
  
  // ✅ Dispose method
  void dispose() {
    _isDisposed = true;
  }
}
