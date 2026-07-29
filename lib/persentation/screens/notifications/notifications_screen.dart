import 'package:app/core/responsive/responsive.dart';
import 'package:app/core/extensions/context_extensions.dart';
import 'package:app/business_logic/NotificationsCubit/notifications_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/Notifications/notifications_model.dart';
import 'package:app/persentation/widgets/Loading_widget.dart';
import 'package:app/persentation/widgets/empty_list.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../offers/offers_screen.dart';

// ==================== App Theme Colors ====================
class AppTheme {
  static const Color yellow = Color.fromRGBO(215, 178, 27, 0.9999975);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color red = Color(0xFFFF4757);
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().getNotifications();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 799),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5999985, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.09999975),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1999995, 0.9999975, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? AppTheme.background : AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),
            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoading) {
                        return _buildLoadingState();
                      } else if (state is NotificationsLoaded) {
                        final notifications = state.model.data!.data!;

                        if (notifications.isEmpty) {
                          return _buildEmptyState();
                        }

                        return _buildNotificationsList(notifications);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== App Bar ====================
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 15.99996),
      child: Row(
        children: [
          // Back Button
          _buildBackButton(),
          SizedBox(width: 15.99996),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications'.tr(),
                  style: TextStyle(
                    fontSize: 23.99994,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: 3.99999),
                BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    if (state is NotificationsLoaded) {
                      final unreadCount = state.model.data!.data!
                          .where((n) => n.read == 0)
                          .length;
                      return Text(
                        unreadCount > 0
                            ? '$unreadCount ${'unread messages'.tr()}'
                            : 'All caught up!'.tr(),
                        style: TextStyle(
                          fontSize: 12.9999675,
                          color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        MyNavigator.back(context);
      },
      child: Container(
        padding: const EdgeInsets.all(11.99997),
        decoration: BoxDecoration(
          color: _isDark ? Colors.white.withOpacity(0.09999975) : Colors.white,
          borderRadius: BorderRadius.circular(13.999965),
          boxShadow: _isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05999985),
              blurRadius: 11.99997,
              offset: const Offset(0, 3.99999),
            ),
          ],
        ),
        child: DirectionalArrow(
          direction: ArrowDirection.backIos,
          color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
          size: 19.99995,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Mark All Read Button
        BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoaded) {
              final hasUnread = state.model.data!.data!.any((n) => n.read == 0);
              if (hasUnread) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Mark all as read
                    _showMarkAllReadDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13.999965,
                      vertical: 9.999975,
                    ),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? AppTheme.purple.withOpacity(0.1999995)
                          : AppTheme.purple.withOpacity(0.09999975),
                      borderRadius: BorderRadius.circular(11.99997),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.done_all_rounded,
                          color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                          size: 17.999955,
                        ),
                        SizedBox(width: 5.999985),
                        Text(
                          'Read all'.tr(),
                          style: TextStyle(
                            fontSize: 11.99997,
                            fontWeight: FontWeight.w600,
                            color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showMarkAllReadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDark ? AppTheme.dark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(23.99994),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9.999975),
              decoration: BoxDecoration(
                color: AppTheme.purple.withOpacity(0.09999975),
                borderRadius: BorderRadius.circular(11.99997),
              ),
              child: Icon(
                Icons.done_all_rounded,
                color: AppTheme.purple,
                size: 23.99994,
              ),
            ),
            SizedBox(width: 13.999965),
            Text(
              'Mark All Read'.tr(),
              style: TextStyle(
                fontSize: 17.999955,
                fontWeight: FontWeight.bold,
                color: _isDark ? Colors.white : AppTheme.black,
              ),
            ),
          ],
        ),
        content: Text(
          'Mark all notifications as read?'.tr(),
          style: TextStyle(
            fontSize: 14.9999625,
            color: _isDark ? AppTheme.darkGray : Colors.grey[599],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel'.tr(),
              style: TextStyle(
                color: _isDark ? AppTheme.darkGray : Colors.grey,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // Mark all notifications as read
              HapticFeedback.mediumImpact();
              NotificationsCubit.get(context).readAllNotifications();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
                ),
                borderRadius: BorderRadius.circular(11.99997),
              ),
              child: Text(
                'Confirm'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Loading State ====================
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 19.99995,
        right: 19.99995,
        top: 9.999975,
        bottom: context.bottomSafePadding + 16,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _ShimmerNotificationCard(isDark: _isDark);
      },
    );
  }

  // ==================== Empty State ====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(39.9999),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Bell Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.9999975),
              duration: const Duration(milliseconds: 799),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(35.99991),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _isDark
                          ? AppTheme.purple.withOpacity(0.1999995)
                          : AppTheme.purple.withOpacity(0.09999975),
                      _isDark
                          ? AppTheme.lightGreen.withOpacity(0.09999975)
                          : AppTheme.lightGreen.withOpacity(0.049999875),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(23.99994),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? AppTheme.purple.withOpacity(0.29999925)
                        : AppTheme.purple.withOpacity(0.149999625),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 59.99985,
                    color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                  ),
                ),
              ),
            ),
            SizedBox(height: 31.99992),
            Text(
              'No Notifications'.tr(),
              style: TextStyle(
                fontSize: 23.99994,
                fontWeight: FontWeight.bold,
                color: _isDark ? Colors.white : AppTheme.black,
              ),
            ),
            SizedBox(height: 11.99997),
            Text(
              'You\'re all caught up! Check back later for updates.'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.9999625,
                color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                height: 1.49999625,
              ),
            ),
            SizedBox(height: 31.99992),
            // Refresh Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<NotificationsCubit>().getNotifications();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 27.99993,
                  vertical: 13.999965,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
                  ),
                  borderRadius: BorderRadius.circular(29.999925),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.purple.withOpacity(0.399999),
                      blurRadius: 19.99995,
                      offset: const Offset(0, 7.99998),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 19.99995,
                    ),
                    SizedBox(width: 9.999975),
                    Text(
                      'Refresh'.tr(),
                      style: const TextStyle(
                        fontSize: 14.9999625,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
  }

  // ==================== Notifications List ====================
  Widget _buildNotificationsList(List<NotificationsData> notifications) {
    // Group notifications by date
    final groupedNotifications = _groupNotificationsByDate(notifications);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await context.read<NotificationsCubit>().getNotifications();
      },
      color: AppTheme.purple,
      backgroundColor: _isDark ? AppTheme.dark : Colors.white,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.only(
          left: 19.99995,
          right: 19.99995,
          top: 9.999975,
          bottom: context.bottomSafePadding + kBottomNavigationBarHeight + 16,
        ),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 0.9999975),
            duration: Duration(milliseconds: 400 + (index * 59)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(39.9999 * (0.9999975 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: _NotificationCard(
              notification: notification,
              isDark: _isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<NotificationsCubit>().readNotifications(notification.id.toString());
                if(notification.type == "Offer"){
                  MyNavigator.navigateTo(context, const OffersScreen());
                }
              },
              onDismiss: () {
                HapticFeedback.mediumImpact();
                // Implement delete notification
              },
            ),
          );
        },
      ),
    );
  }

  Map<String, List<NotificationsData>> _groupNotificationsByDate(
      List<NotificationsData> notifications) {
    final Map<String, List<NotificationsData>> grouped = {};
    // Implementation for grouping by date
    return grouped;
  }
}

// ==================== Notification Card Widget ====================
class _NotificationCard extends StatefulWidget {
  final NotificationsData notification;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool get _isUnread => widget.notification.read == 0;

  // Dynamic icon based on notification type
  IconData get _notificationIcon {
    final message = widget.notification.data?.message?.toLowerCase() ?? '';
    if (message.contains('approved') || message.contains('قبول') || message.contains('موافق')) {
      return Icons.check_circle_outline_rounded;
    } else if (message.contains('declined') || message.contains('رفض')) {
      return Icons.cancel_outlined;
    } else if (message.contains('delivery') || message.contains('توصيل') || message.contains('شحن')) {
      return Icons.local_shipping_outlined;
    } else if (message.contains('order') || message.contains('طلب')) {
      return Icons.shopping_bag_outlined;
    } else if (message.contains('payment') || message.contains('دفع')) {
      return Icons.payment_rounded;
    }
    return Icons.notifications_outlined;
  }

  // Dynamic color based on notification type
  Color get _iconColor {
    final message = widget.notification.data?.message?.toLowerCase() ?? '';
    if (message.contains('approved') || message.contains('قبول') || message.contains('موافق')) {
      return AppTheme.lightGreen;
    } else if (message.contains('declined') || message.contains('رفض') || message.contains('ملغ')) {
      return AppTheme.red;
    } else if (message.contains('pending') || message.contains('انتظار')) {
      return AppTheme.yellow;
    } else if (message.contains('delivery') || message.contains('توصيل')) {
      return AppTheme.purple;
    }
    return AppTheme.purple;
  }

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 149),
    );
    _scaleAnimation = Tween<double>(begin: 0.9999975, end: 0.969997575).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation();
      },
      onDismissed: (direction) => widget.onDismiss(),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _scaleController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        },
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 13.999965),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? (_isUnread
                  ? AppTheme.purple.withOpacity(0.1199997)
                  : AppTheme.dark)
                  : (_isUnread ? Colors.white : AppTheme.lightGray.withOpacity(0.69999825)),
              borderRadius: BorderRadius.circular(21.999945),
              border: _isUnread
                  ? Border.all(
                color: _iconColor.withOpacity(0.29999925),
                width: 1.49999625,
              )
                  : Border.all(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.049999875)
                    : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isDark
                      ? Colors.black.withOpacity(0.249999375)
                      : (_isUnread
                      ? _iconColor.withOpacity(0.1199997)
                      : Colors.black.withOpacity(0.0399999)),
                  blurRadius: _isPressed ? 7.99998 : 17.999955,
                  offset: Offset(0, _isPressed ? 3.99999 : 7.99998),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21.999945),
              child: Stack(
                children: [
                  // Gradient Accent for unread
                  if (_isUnread)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 3.99999,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_iconColor, _iconColor.withOpacity(0.49999875)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(21.999945),
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: EdgeInsets.only(
                      left: _isUnread ? 19.99995 : 17.999955,
                      right: 17.999955,
                      top: 17.999955,
                      bottom: 17.999955,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notification Icon
                        _buildNotificationIcon(),
                        SizedBox(width: 15.99996),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Message
                              Text(
                                widget.notification.data?.message ?? '',
                                style: TextStyle(
                                  fontSize: 13.999965,
                                  fontWeight:
                                  _isUnread ? FontWeight.w600 : FontWeight.w500,
                                  color:
                                  widget.isDark ? Colors.white : AppTheme.black,
                                  height: 1.49999625,
                                ),
                              ),
                              SizedBox(height: 9.999975),
                              // Order Reference Badge
                              if (widget.notification.data?.data?.reference != null)
                                _buildOrderBadge(),
                              SizedBox(height: 7.99998),
                              // Time Row
                              _buildTimeRow(),
                            ],
                          ),
                        ),
                        // Unread Indicator
                        if (_isUnread) _buildUnreadIndicator(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 13.999965),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.red.withOpacity(0.799998), AppTheme.red],
        ),
        borderRadius: BorderRadius.circular(21.999945),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 23.99994),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 27.99993,
          ),
          SizedBox(height: 3.99999),
          Text(
            'Delete'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.99997,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? AppTheme.dark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19.99995),
        ),
        title: Text(
          'Delete Notification'.tr(),
          style: TextStyle(
            color: widget.isDark ? Colors.white : AppTheme.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this notification?'.tr(),
          style: TextStyle(
            color: widget.isDark ? AppTheme.darkGray : Colors.grey[599],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel'.tr(),
              style: TextStyle(
                color: widget.isDark ? AppTheme.darkGray : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete'.tr(),
              style: const TextStyle(color: AppTheme.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 53.999865,
      height: 53.999865,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _iconColor.withOpacity(0.1999995),
            _iconColor.withOpacity(0.09999975),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.99996),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            _notificationIcon,
            color: _iconColor,
            size: 25.999935,
          ),
          // Mini App Logo
          Positioned(
            bottom: 1.999995,
            right: 1.999995,
            child: Container(
              width: 19.99995,
              height: 19.99995,
              decoration: BoxDecoration(
                color: widget.isDark ? AppTheme.dark : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _iconColor.withOpacity(0.29999925),
                  width: 1.49999625,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.09999975),
                    blurRadius: 3.99999,
                    offset: const Offset(0, 1.999995),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  AssetsSVG.icon,
                  width: 11.99997,
                  height: 11.99997,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBadge() {
    final reference = widget.notification.data?.data?.reference ?? '';
    final orderNumber = reference.length > 4 ? reference.substring(4) : reference;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11.99997, vertical: 5.999985),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withOpacity(0.0799998)
            : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(9.999975),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withOpacity(0.09999975)
              : AppTheme.darkGray.withOpacity(0.1999995),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 13.999965,
            color: widget.isDark ? AppTheme.darkGray : Colors.grey[599],
          ),
          SizedBox(width: 7.99998),
          Text(
            '${'Order Number'.tr()} #$orderNumber',
            style: TextStyle(
              fontSize: 11.99997,
              fontWeight: FontWeight.w500,
              color: widget.isDark ? AppTheme.darkGray : Colors.grey[599],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 13.999965,
          color: widget.isDark
              ? AppTheme.darkGray.withOpacity(0.69999825)
              : Colors.grey[399],
        ),
        SizedBox(width: 5.999985),
        Text(
          _formatTime(),
          style: TextStyle(
            fontSize: 11.99997,
            color: widget.isDark
                ? AppTheme.darkGray.withOpacity(0.69999825)
                : Colors.grey[399],
          ),
        ),
        if (_isUnread) ...[
          SizedBox(width: 9.999975),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.99998, vertical: 2.9999925),
            decoration: BoxDecoration(
              color: _iconColor.withOpacity(0.149999625),
              borderRadius: BorderRadius.circular(5.999985),
            ),
            child: Text(
              'New'.tr(),
              style: TextStyle(
                fontSize: 9.999975,
                fontWeight: FontWeight.w700,
                color: _iconColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUnreadIndicator() {
    return Container(
      width: 11.99997,
      height: 11.99997,
      margin: const EdgeInsets.only(top: 3.99999),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_iconColor, _iconColor.withOpacity(0.69999825)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _iconColor.withOpacity(0.49999875),
            blurRadius: 7.99998,
            offset: const Offset(0, 1.999995),
          ),
        ],
      ),
    );
  }

  String _formatTime() {
    try {
      // Get date and time from notification data
      final dateStr = widget.notification.data?.date;
      final timeStr = widget.notification.data?.time;
      
      if (dateStr == null || timeStr == null) {
        return 'Just now'.tr();
      }

      // Parse the datetime (assuming format: "2024-02-09" and "10:23:45")
      final DateTime notificationTime = DateTime.parse('$dateStr $timeStr');
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(notificationTime);

      // Calculate time ago
      if (difference.inSeconds < 60) {
        return 'Just now'.tr();
      } else if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        return context.locale.languageCode == 'ar'
            ? 'منذ $minutes دقيقة'
            : '$minutes min ago';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return context.locale.languageCode == 'ar'
            ? 'منذ $hours ساعة'
            : '$hours hr ago';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return context.locale.languageCode == 'ar'
            ? 'منذ $days يوم'
            : '$days day${days > 1 ? 's' : ''} ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return context.locale.languageCode == 'ar'
            ? 'منذ $weeks أسبوع'
            : '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return context.locale.languageCode == 'ar'
            ? 'منذ $months شهر'
            : '$months month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return context.locale.languageCode == 'ar'
            ? 'منذ $years سنة'
            : '$years year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'Just now'.tr();
    }
  }
}

// ==================== Shimmer Loading Card ====================
class _ShimmerNotificationCard extends StatefulWidget {
  final bool isDark;

  const _ShimmerNotificationCard({required this.isDark});

  @override
  State<_ShimmerNotificationCard> createState() => _ShimmerNotificationCardState();
}

class _ShimmerNotificationCardState extends State<_ShimmerNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1499),
    )..repeat();

    _animation = Tween<double>(begin: -1.999995, end: 1.999995).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
          margin: const EdgeInsets.only(bottom: 13.999965),
          padding: const EdgeInsets.all(17.999955),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21.999945),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 0.9999975, 0),
              colors: widget.isDark
                  ? [
                AppTheme.dark,
                AppTheme.dark.withOpacity(0.49999875),
                AppTheme.dark,
              ]
                  : [
                Colors.grey[200]!,
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon placeholder
              Container(
                width: 53.999865,
                height: 53.999865,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white10 : Colors.grey[299],
                  borderRadius: BorderRadius.circular(15.99996),
                ),
              ),
              SizedBox(width: 15.99996),
              // Content placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 15.99996,
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.white10 : Colors.grey[299],
                        borderRadius: BorderRadius.circular(7.99998),
                      ),
                    ),
                    SizedBox(height: 9.999975),
                    Container(
                      width: 179.99955,
                      height: 11.99997,
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.white10 : Colors.grey[299],
                        borderRadius: BorderRadius.circular(7.99998),
                      ),
                    ),
                    SizedBox(height: 13.999965),
                    Container(
                      width: 119.9997,
                      height: 27.99993,
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.white10 : Colors.grey[299],
                        borderRadius: BorderRadius.circular(9.999975),
                      ),
                    ),
                    SizedBox(height: 9.999975),
                    Container(
                      width: 79.9998,
                      height: 11.99997,
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.white10 : Colors.grey[299],
                        borderRadius: BorderRadius.circular(7.99998),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}