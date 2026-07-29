// ═══════════════════════════════════════════════════════════════════════════
// 🧪 Order Tracking Notification Test Screen
// ═══════════════════════════════════════════════════════════════════════════
// Path: lib/screens/order_tracking_notification_test_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../theme/colors.dart';
import 'order_tracking_notification_service.dart' show OrderTrackingNotificationService, OrderStatus;

class OrderTrackingNotificationTestScreen extends StatefulWidget {
  const OrderTrackingNotificationTestScreen({super.key});

  @override
  State<OrderTrackingNotificationTestScreen> createState() =>
      _OrderTrackingNotificationTestScreenState();
}

class _OrderTrackingNotificationTestScreenState
    extends State<OrderTrackingNotificationTestScreen>
    with TickerProviderStateMixin {

  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 Controllers & State
  // ═══════════════════════════════════════════════════════════════════════
  final _notificationService = OrderTrackingNotificationService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  OrderStatus _currentStatus = OrderStatus.pending;
  String _orderId = 'test_${DateTime.now().millisecondsSinceEpoch}';
  String _orderReference = '175000';
  bool _isSimulating = false;
  bool _isInitialized = false;

  final List<String> _logs = [];
  Timer? _simulationTimer;

  // ═══════════════════════════════════════════════════════════════════════
  // 🎬 Lifecycle
  // ═══════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initNotificationService();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initNotificationService() async {
    _addLog('🚀 Initializing notification service...');

    final success = await _notificationService.initialize();

    // Setup callbacks
    _notificationService.onNotificationTapped = (orderId) {
      _addLog('📱 Notification tapped: $orderId');
      _showSnackBar('تم الضغط على إشعار الطلب: $orderId');
    };

    _notificationService.onNotificationAction = (orderId, action) {
      _addLog('🔘 Action: $action for order: $orderId');
      _showSnackBar('Action: $action');
    };

    setState(() => _isInitialized = success);
    _addLog(success ? '✅ Initialized successfully' : '❌ Initialization failed');
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '[${_formatTime(DateTime.now())}] $message');
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MyColors.perpel,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Show Notification
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> _showNotification(OrderStatus status) async {
    HapticFeedback.lightImpact();

    setState(() => _currentStatus = status);

    _addLog('📤 Showing notification: ${status.arabicText}');

    final success = await _notificationService.showTrackingNotification(
      orderId: _orderId,
      orderReference: _orderReference,
      status: status,
      estimatedTime: status.hasDriver ? '10-15 دقيقة' : null,
      driverName: status.hasDriver ? 'أحمد محمد' : null,
      driverPhone: status.hasDriver ? '+966501234567' : null,
    );

    _addLog(success ? '✅ Notification shown' : '❌ Failed to show notification');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Simulate Order Progress
  // ═══════════════════════════════════════════════════════════════════════
  void _startSimulation() {
    if (_isSimulating) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isSimulating = true;
      _currentStatus = OrderStatus.pending;
      _orderId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      _orderReference = (int.parse(_orderReference) + 1).toString();
    });

    _pulseController.repeat(reverse: true);
    _addLog('🎬 Starting simulation for order: $_orderReference');

    // Show initial notification
    _showNotification(OrderStatus.pending);

    // Simulate progress
    final statuses = OrderStatus.allSteps;
    int currentIndex = 0;

    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      currentIndex++;

      if (currentIndex >= statuses.length) {
        _stopSimulation();
        return;
      }

      _showNotification(statuses[currentIndex]);
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    setState(() => _isSimulating = false);
    _addLog('🛑 Simulation stopped');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🗑️ Cancel Notification
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> _cancelNotification() async {
    HapticFeedback.lightImpact();
    await _notificationService.cancelTrackingNotification(_orderId);
    _addLog('🗑️ Notification cancelled');
    _showSnackBar('تم إلغاء الإشعار');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏗️ Build UI
  // ═══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Status Card
            _buildStatusCard(),

            // Status Buttons Grid
            Expanded(
              flex: 2,
              child: _buildStatusGrid(),
            ),

            // Action Buttons
            _buildActionButtons(),

            // Logs
            Expanded(
              flex: 1,
              child: _buildLogsSection(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColors.dark,
      elevation: 0,
      title: const Text(
        '🔔 اختبار إشعارات التتبع',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Status Indicator
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isInitialized ? MyColors.lightgreen.withOpacity(0.2) : MyColors.red2.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isInitialized ? MyColors.lightgreen : MyColors.red2,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isInitialized ? MyColors.lightgreen : MyColors.red2,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isInitialized ? 'جاهز' : 'غير جاهز',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isInitialized ? MyColors.lightgreen : MyColors.red2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSimulating ? _pulseAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _currentStatus.color.withOpacity(0.2),
                  _currentStatus.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _currentStatus.color.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _currentStatus.color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Emoji & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStatus.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentStatus.arabicText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'طلب #$_orderReference',
                          style: TextStyle(
                            fontSize: 14,
                            color: MyColors.darkgray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress Bar
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التقدم',
                          style: TextStyle(
                            fontSize: 12,
                            color: MyColors.darkgray,
                          ),
                        ),
                        Text(
                          '${_currentStatus.progressPercent}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _currentStatus.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _currentStatus.progressValue,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(_currentStatus.color),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: OrderStatus.values.length,
      itemBuilder: (context, index) {
        final status = OrderStatus.values[index];
        final isSelected = status == _currentStatus;

        return GestureDetector(
          onTap: () => _showNotification(status),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? status.color.withOpacity(0.2)
                  : MyColors.dark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? status.color
                    : MyColors.darkgray.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: status.color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  status.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  status.arabicText,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? status.color : MyColors.darkgray,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Simulate Button
          Expanded(
            child: _ActionButton(
              label: _isSimulating ? 'إيقاف' : 'محاكاة',
              icon: _isSimulating ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: _isSimulating ? MyColors.red2 : MyColors.lightgreen,
              onPressed: _isSimulating ? _stopSimulation : _startSimulation,
            ),
          ),

          const SizedBox(width: 12),

          // Cancel Button
          Expanded(
            child: _ActionButton(
              label: 'إلغاء الإشعار',
              icon: Icons.notifications_off_rounded,
              color: MyColors.yellow,
              onPressed: _cancelNotification,
            ),
          ),

          const SizedBox(width: 12),

          // Clear Logs Button
          Expanded(
            child: _ActionButton(
              label: 'مسح السجل',
              icon: Icons.delete_sweep_rounded,
              color: MyColors.perpel,
              onPressed: () {
                setState(() => _logs.clear());
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: MyColors.dark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MyColors.darkgray.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.terminal_rounded,
                  size: 18,
                  color: MyColors.lightgreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  'سجل الأحداث',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_logs.length} سجل',
                  style: TextStyle(
                    fontSize: 12,
                    color: MyColors.darkgray,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: MyColors.background),

          // Logs List
          Expanded(
            child: _logs.isEmpty
                ? Center(
              child: Text(
                'لا توجد سجلات',
                style: TextStyle(
                  fontSize: 14,
                  color: MyColors.darkgray,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _logs[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: MyColors.darkgray,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Action Button Widget
// ═══════════════════════════════════════════════════════════════════════════
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color,
              widget.color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_isPressed ? 0.2 : 0.4),
              blurRadius: _isPressed ? 4 : 12,
              offset: Offset(0, _isPressed ? 2 : 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}