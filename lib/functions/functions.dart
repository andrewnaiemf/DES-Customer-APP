import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎨 FONTS CONFIGURATION
/// ═══════════════════════════════════════════════════════════════════════════

class MyFonts {
  const MyFonts._();
  
  static const String font = 'SF-Arabic';
  static const String fontBold = 'SF-Arabic-Bold';
  static const String fontLight = 'SF-Arabic-Light';
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 📬 MESSAGE TYPES ENUM
/// ═══════════════════════════════════════════════════════════════════════════

enum MessageType {
  success,
  error,
  warning,
  info,
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔔 PROFESSIONAL SNACKBAR MESSAGE SYSTEM
/// ═══════════════════════════════════════════════════════════════════════════

void showMessage({
  required BuildContext context,
  required String message,
  MessageType type = MessageType.info,
  Color? color,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  VoidCallback? onAction,
  bool showIcon = true,
  SnackBarBehavior behavior = SnackBarBehavior.floating,
}) {
  if (!context.mounted) return;

  // 🔊 Haptic feedback based on message type
  _triggerHapticFeedback(type);

  // 🎨 Get theme colors based on type
  final messageTheme = _getMessageTheme(type, color);

  // ❌ Dismiss any existing snackbar
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: behavior,
      duration: duration,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      content: _AnimatedMessageContent(
        message: message,
        theme: messageTheme,
        showIcon: showIcon,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

/// 🎨 Message Theme Data
class _MessageTheme {
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final List<Color> gradientColors;

  const _MessageTheme({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.gradientColors,
  });
}

/// 🎨 Get Message Theme based on Type
_MessageTheme _getMessageTheme(MessageType type, Color? customColor) {
  if (customColor != null) {
    return _MessageTheme(
      backgroundColor: customColor,
      iconColor: Colors.white,
      textColor: Colors.white,
      icon: Icons.info_outline_rounded,
      gradientColors: [customColor, customColor.withOpacity(0.85)],
    );
  }

  switch (type) {
    case MessageType.success:
      return _MessageTheme(
        backgroundColor: MyColors.lightgreen,
        iconColor: Colors.white,
        textColor: Colors.white,
        icon: Icons.check_circle_outline_rounded,
        gradientColors: [
          MyColors.lightgreen,
          MyColors.lightgreen.withOpacity(0.85),
        ],
      );

    case MessageType.error:
      return const _MessageTheme(
        backgroundColor: Color(0xFFE53935),
        iconColor: Colors.white,
        textColor: Colors.white,
        icon: Icons.error_outline_rounded,
        gradientColors: [
          Color(0xFFE53935),
          Color(0xFFD32F2F),
        ],
      );

    case MessageType.warning:
      return _MessageTheme(
        backgroundColor: MyColors.yellow,
        iconColor: Colors.white,
        textColor: Colors.white,
        icon: Icons.warning_amber_rounded,
        gradientColors: [
          MyColors.yellow,
          MyColors.yellow.withOpacity(0.85),
        ],
      );

    case MessageType.info:
    default:
      return _MessageTheme(
        backgroundColor: MyColors.perpel,
        iconColor: Colors.white,
        textColor: Colors.white,
        icon: Icons.info_outline_rounded,
        gradientColors: [
          MyColors.perpel,
          MyColors.mainColorSwatch.shade700,
        ],
      );
  }
}

/// 🔊 Trigger Haptic Feedback
void _triggerHapticFeedback(MessageType type) {
  switch (type) {
    case MessageType.success:
      HapticFeedback.lightImpact();
      break;
    case MessageType.error:
      HapticFeedback.heavyImpact();
      break;
    case MessageType.warning:
      HapticFeedback.mediumImpact();
      break;
    case MessageType.info:
      HapticFeedback.selectionClick();
      break;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎬 ANIMATED MESSAGE CONTENT WIDGET
/// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedMessageContent extends StatefulWidget {
  final String message;
  final _MessageTheme theme;
  final bool showIcon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _AnimatedMessageContent({
    required this.message,
    required this.theme,
    required this.showIcon,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_AnimatedMessageContent> createState() => _AnimatedMessageContentState();
}

class _AnimatedMessageContentState extends State<_AnimatedMessageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _buildMessageContainer(),
        ),
      ),
    );
  }

  Widget _buildMessageContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // 🌈 Gradient Background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.theme.gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        // 🌟 Soft Shadow
        boxShadow: [
          BoxShadow(
            color: widget.theme.backgroundColor.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🎯 Icon
          if (widget.showIcon) ...[
            _buildIcon(),
            const SizedBox(width: 12),
          ],

          // 📝 Message Text
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(
                fontFamily: MyFonts.font,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.theme.textColor,
                height: 1.4,
              ),
            ),
          ),

          // 🎯 Action Button (if provided)
          if (widget.actionLabel != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(),
          ],

          // ❌ Dismiss Button
          const SizedBox(width: 8),
          _buildDismissButton(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        widget.theme.icon,
        color: widget.theme.iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildActionButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onAction,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.actionLabel!,
            style: TextStyle(
              fontFamily: MyFonts.font,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.theme.textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onDismiss,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.close_rounded,
            color: widget.theme.iconColor.withOpacity(0.8),
            size: 16,
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎯 QUICK MESSAGE HELPERS
/// ═══════════════════════════════════════════════════════════════════════════

/// ✅ Show Success Message
void showSuccessMessage(BuildContext context, String message) {
  showMessage(
    context: context,
    message: message,
    type: MessageType.success,
  );
}

/// ❌ Show Error Message
void showErrorMessage(BuildContext context, String message) {
  showMessage(
    context: context,
    message: message,
    type: MessageType.error,
    duration: const Duration(seconds: 4),
  );
}

/// ⚠️ Show Warning Message
void showWarningMessage(BuildContext context, String message) {
  showMessage(
    context: context,
    message: message,
    type: MessageType.warning,
  );
}

/// ℹ️ Show Info Message
void showInfoMessage(BuildContext context, String message) {
  showMessage(
    context: context,
    message: message,
    type: MessageType.info,
  );
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 📅 DATE FORMATTING UTILITIES
/// ═══════════════════════════════════════════════════════════════════════════

/// 📅 Format DateTime to Readable String
String formatDate(BuildContext context, DateTime date) {
  final locale = context.locale.languageCode == 'en' ? 'en' : 'ar_SA';
  final formatter = DateFormat.yMMMMEEEEd(locale);
  return formatter.format(date);
}

/// 📅 Format Date - Short Version
String formatDateShort(BuildContext context, DateTime date) {
  final locale = context.locale.languageCode == 'en' ? 'en' : 'ar_SA';
  final formatter = DateFormat.yMMMd(locale);
  return formatter.format(date);
}

/// 📅 Format Date - Relative (Today, Yesterday, etc.)
String formatDateRelative(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(date.year, date.month, date.day);
  final difference = today.difference(dateOnly).inDays;

  if (difference == 0) {
    return 'today'.tr();
  } else if (difference == 1) {
    return 'yesterday'.tr();
  } else if (difference == -1) {
    return 'tomorrow'.tr();
  } else if (difference > 0 && difference < 7) {
    return '$difference ${'days_ago'.tr()}';
  } else {
    return formatDateShort(context, date);
  }
}

/// ⏰ Format Time (HH:mm)
String formatTime(DateTime time) {
  return DateFormat('HH:mm').format(time);
}

/// ⏰ Format Time with AM/PM
String formatTimeWithPeriod(DateTime time, {bool isArabic = false}) {
  final formatted = DateFormat('hh:mm a').format(time);
  
  if (isArabic) {
    return formatted
        .replaceAll('AM', 'ص')
        .replaceAll('PM', 'م');
  }
  
  return formatted;
}

/// ⏰ Format AM/PM from API String
String formatAMorPMFromAPI(String time, {bool toArabic = true}) {
  try {
    final parts = time.split(' ');
    if (parts.length != 2) return time;

    final timePart = parts[0];
    final period = parts[1].toUpperCase();

    if (toArabic) {
      final arabicPeriod = period == 'PM' ? 'م' : 'ص';
      return '$timePart $arabicPeriod';
    }

    return '$timePart $period';
  } catch (e) {
    return time;
  }
}

/// 📅 Format Date from API String (DD-MM-YYYY)
String formatDateFromAPI(BuildContext context, String date) {
  try {
    final dt = dateFromAPI(date);
    return formatDate(context, dt);
  } catch (e) {
    return date;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔄 DATE/TIME PARSING UTILITIES
/// ═══════════════════════════════════════════════════════════════════════════

/// ⏰ Parse TimeOfDay from API String
TimeOfDay timeOfDayFromAPI(String time) {
  try {
    final parts = time.split(' ');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $time');
    }

    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);
    final String period = parts[1].toUpperCase();

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    debugPrint('Error parsing time: $e');
    return const TimeOfDay(hour: 0, minute: 0);
  }
}

/// 📅 Parse DateTime from API String (DD-MM-YYYY)
DateTime dateFromAPI(String date) {
  try {
    final parts = date.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid date format: $date');
    }

    final int day = int.parse(parts[0]);
    final int month = int.parse(parts[1]);
    final int year = int.parse(parts[2]);

    return DateTime(year, month, day);
  } catch (e) {
    debugPrint('Error parsing date: $e');
    return DateTime.now();
  }
}

/// 📅 Convert DateTime to API Format (DD-MM-YYYY)
String dateToAPI(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';
}

/// ⏰ Convert TimeOfDay to API Format
String timeToAPI(TimeOfDay time, {bool use12Hour = true}) {
  final hour = use12Hour ? (time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod) : time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';

  if (use12Hour) {
    return '$hour:$minute $period';
  }
  
  return '${time.hour.toString().padLeft(2, '0')}:$minute';
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔍 VALIDATION UTILITIES
/// ═══════════════════════════════════════════════════════════════════════════

/// 🔗 Check if String is Valid URL
bool isURL(String url) {
  if (url.isEmpty) return false;

  // More comprehensive URL regex
  final urlPattern = RegExp(
    r'^(https?:\/\/)?' // Protocol (optional)
    r'((([a-zA-Z\d]([a-zA-Z\d-]*[a-zA-Z\d])*)\.)+[a-zA-Z]{2,}|' // Domain name
    r'((\d{1,3}\.){3}\d{1,3}))' // OR IP address
    r'(\:\d+)?' // Port (optional)
    r'(\/[-a-zA-Z\d%_.~+]*)*' // Path
    r'(\?[;&a-zA-Z\d%_.~+=-]*)?' // Query string
    r'(\#[-a-zA-Z\d_]*)?$', // Fragment
    caseSensitive: false,
  );

  return urlPattern.hasMatch(url);
}

/// 📧 Check if String is Valid Email
bool isEmail(String email) {
  if (email.isEmpty) return false;

  final emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );

  return emailPattern.hasMatch(email);
}

/// 📱 Check if String is Valid Phone Number
bool isPhoneNumber(String phone) {
  if (phone.isEmpty) return false;

  // Supports various formats including international
  final phonePattern = RegExp(
    r'^\+?[\d\s\-\(\)]{8,}$',
  );

  return phonePattern.hasMatch(phone);
}

/// 🔢 Check if String is Numeric
bool isNumeric(String str) {
  if (str.isEmpty) return false;
  return double.tryParse(str) != null;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🛠️ STRING EXTENSION UTILITIES
/// ═══════════════════════════════════════════════════════════════════════════

extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncate with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if string is blank (empty or only whitespace)
  bool get isBlank => trim().isEmpty;

  /// Check if string is not blank
  bool get isNotBlank => !isBlank;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 📅 DATETIME EXTENSION UTILITIES
/// ═══════════════════════════════════════════════════════════════════════════

extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Format to API date string
  String get toAPIFormat => dateToAPI(this);
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎯 CONTEXT EXTENSION UTILITIES
/// ═══════════════════════════════════════════════════════════════════════════

extension ContextExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Check if device is tablet
  bool get isTablet => screenWidth >= 600;

  /// Check if device is in landscape mode
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Show quick success message
  void showSuccess(String message) => showSuccessMessage(this, message);

  /// Show quick error message
  void showError(String message) => showErrorMessage(this, message);

  /// Show quick warning message
  void showWarning(String message) => showWarningMessage(this, message);

  /// Show quick info message
  void showInfo(String message) => showInfoMessage(this, message);
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 💱 CURRENCY DISPLAY WIDGET
/// ═══════════════════════════════════════════════════════════════════════════

/// Currency widget that shows SAR.svg for Arabic or "SAR" text for English
class CurrencyWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;

  const CurrencyWidget({
    Key? key,
    this.height,
    this.width,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if current locale is Arabic
    final isArabic = context.locale.languageCode == 'ar';

    if (isArabic) {
      // Show SVG for Arabic
      return SvgPicture.asset(
        'assets/svg/SAR.svg',
        height: height ?? 32,
        width: width ?? 32,
        color: color,
      );
    } else {
      // Show text for English
      return Text(
        'SAR',
        style: TextStyle(
          fontSize: height ?? 22,
          color: color,
          fontFamily: MyFonts.font,
        ),
      );
    }
  }
}

/// Extension to easily get currency widget
extension CurrencyExtension on BuildContext {
  /// Get currency widget (SVG for Arabic, text for English)
  Widget getCurrencyWidget({double? height, double? width, Color? color}) {
    return CurrencyWidget(
      height: height,
      width: width,
      color: color,
    );
  }
}