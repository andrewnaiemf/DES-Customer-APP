import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Premium Popup/Dialog System
// ═══════════════════════════════════════════════════════════════════════════

class PremiumDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    Color accentColor = const Color(0xFF6842E2),
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDark = false,
    DialogType type = DialogType.info,
    bool dismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale:
              Tween<double>(begin: 0.8, end: 1).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: _PremiumDialogContent(
              title: title,
              message: message,
              icon: icon,
              accentColor: _getColorForType(type, accentColor),
              confirmText: confirmText,
              cancelText: cancelText,
              onConfirm: onConfirm,
              onCancel: onCancel,
              isDark: isDark,
              type: type,
            ),
          ),
        );
      },
    );
  }

  static Color _getColorForType(DialogType type, Color defaultColor) {
    switch (type) {
      case DialogType.success:
        return const Color(0xFF10B981);
      case DialogType.error:
        return const Color(0xFFEF4444);
      case DialogType.warning:
        return const Color(0xFFF59E0B);
      case DialogType.info:
        return defaultColor;
    }
  }

  // Quick methods
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDark = false,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      icon: Icons.help_outline_rounded,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
      isDark: isDark,
      type: DialogType.info,
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    bool isDark = false,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      confirmText: buttonText,
      onConfirm: () => Navigator.of(context).pop(),
      isDark: isDark,
      type: DialogType.success,
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    bool isDark = false,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_rounded,
      confirmText: buttonText,
      onConfirm: () => Navigator.of(context).pop(),
      isDark: isDark,
      type: DialogType.error,
    );
  }

  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Continue',
    String? cancelText,
    VoidCallback? onConfirm,
    bool isDark = false,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      icon: Icons.warning_rounded,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm ?? () => Navigator.of(context).pop(),
      onCancel:
          cancelText != null ? () => Navigator.of(context).pop() : null,
      isDark: isDark,
      type: DialogType.warning,
    );
  }
}

enum DialogType { info, success, error, warning }

// ═══════════════════════════════════════════════════════════════════════════
// Dialog Content Widget
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumDialogContent extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDark;
  final DialogType type;

  const _PremiumDialogContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    required this.isDark,
    required this.type,
  });

  @override
  State<_PremiumDialogContent> createState() =>
      _PremiumDialogContentState();
}

class _PremiumDialogContentState extends State<_PremiumDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _iconController, curve: Curves.elasticOut),
    );

    _iconController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF14141F)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.accentColor
                  .withOpacity(widget.isDark ? 0.2 : 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor
                    .withOpacity(widget.isDark ? 0.3 : 0.2),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black
                    .withOpacity(widget.isDark ? 0.4 : 0.1),
                blurRadius: 48,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Section
                _buildIconSection(),

                // Content Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1D1D25),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Message
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      _buildButtons(),
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

  Widget _buildIconSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor
                .withOpacity(widget.isDark ? 0.15 : 0.1),
            widget.accentColor
                .withOpacity(widget.isDark ? 0.05 : 0.03),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _iconAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _iconAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.accentColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),

                // Icon container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor,
                        widget.accentColor.withOpacity(0.85),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            widget.accentColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtons() {
    final hasCancel =
        widget.cancelText != null && widget.onCancel != null;

    if (!hasCancel) {
      // Single button
      return _buildPrimaryButton(
        text: widget.confirmText ?? 'OK',
        onTap: widget.onConfirm,
      );
    }

    // Two buttons
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: _buildSecondaryButton(
            text: widget.cancelText!,
            onTap: widget.onCancel,
          ),
        ),
        const SizedBox(width: 12),

        // Confirm button
        Expanded(
          child: _buildPrimaryButton(
            text: widget.confirmText ?? 'OK',
            onTap: widget.onConfirm,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.accentColor,
              widget.accentColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? Colors.white.withOpacity(0.8)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔔 Premium Toast/Snackbar
// ═══════════════════════════════════════════════════════════════════════════

class PremiumToast {
  static void show({
    required BuildContext context,
    required String message,
    IconData? icon,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    bool isDark = false,
  }) {
    final overlay = Overlay.of(context);
    final color = _getColorForType(type);
    final defaultIcon = _getIconForType(type);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PremiumToastWidget(
        message: message,
        icon: icon ?? defaultIcon,
        color: color,
        isDark: isDark,
        onDismiss: () {
          overlayEntry.remove();
        },
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);
  }

  static Color _getColorForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF10B981);
      case ToastType.error:
        return const Color(0xFFEF4444);
      case ToastType.warning:
        return const Color(0xFFF59E0B);
      case ToastType.info:
        return const Color(0xFF3B82F6);
    }
  }

  static IconData _getIconForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }
}

enum ToastType { info, success, error, warning }

// ═══════════════════════════════════════════════════════════════════════════
// Toast Widget
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onDismiss;
  final Duration duration;

  const _PremiumToastWidget({
    required this.message,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_PremiumToastWidget> createState() => _PremiumToastWidgetState();
}

class _PremiumToastWidgetState extends State<_PremiumToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF14141F)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(widget.isDark ? 0.3 : 0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withOpacity(
                              widget.isDark ? 0.2 : 0.15),
                          widget.color.withOpacity(
                              widget.isDark ? 0.1 : 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Message
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1D1D25),
                      ),
                    ),
                  ),

                  // Close button
                  GestureDetector(
                    onTap: () {
                      _controller.reverse().then((_) {
                        if (mounted) {
                          widget.onDismiss();
                        }
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.5)
                          : const Color(0xFF6B7280),
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
}
