import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Brand Colors - With Dark Mode Support
// ═══════════════════════════════════════════════════════════════════════════
class _DatePickerColors {
  // Light Mode Colors
  static const Color purple = Color(0xFF6842E2);
  static const Color lightPurple = Color(0xFFEDE9FC);
  static const Color dark = Color(0xFF081428);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color gray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF15172A);
  static const Color darkCard = Color(0xFF1D1D25);
  static const Color darkSurface = Color(0xFF252836);
  static const Color darkBorder = Color(0xFF2D3748);

  // Dynamic Colors Based on Theme
  static Color background(bool isDark) => isDark ? darkBackground : white;
  static Color card(bool isDark) => isDark ? darkCard : white;
  static Color surface(bool isDark) => isDark ? darkSurface : lightGray;
  static Color text(bool isDark) => isDark ? white : dark;
  static Color textSecondary(bool isDark) => isDark ? gray : dark.withOpacity(0.6);
  static Color border(bool isDark) => isDark ? darkBorder : gray.withOpacity(0.3);
  static Color divider(bool isDark) => isDark ? white.withOpacity(0.1) : gray.withOpacity(0.2);

  static LinearGradient primaryGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [purple.withOpacity(0.8), const Color(0xFF8B5CF6).withOpacity(0.8)]
        : [purple, const Color(0xFF8B5CF6)],
  );

  static LinearGradient secondaryGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [purple.withOpacity(0.2), lightGreen.withOpacity(0.1)]
        : [purple.withOpacity(0.1), lightGreen.withOpacity(0.1)],
  );

  static LinearGradient headerGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [purple.withOpacity(0.9), const Color(0xFF8B5CF6).withOpacity(0.7)]
        : [purple, const Color(0xFF8B5CF6)],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 📅 Custom Date Picker - Main Class
// ═══════════════════════════════════════════════════════════════════════════
class CustomDatePicker {
  /// عرض تقويم مخصص (Material Design)
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
  }) async {
    HapticFeedback.selectionClick();

    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
      locale: context.locale,
      builder: (context, child) {
        return Theme(
          data: _buildDatePickerTheme(context),
          child: child!,
        );
      },
    );
  }

  /// عرض تقويم مخصص مع Bottom Sheet (للموبايل)
  static Future<DateTime?> showBottomSheet({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
    Locale? locale, // إضافة locale parameter
  }) async {
    print('🎯 [CustomDatePicker] showBottomSheet called!');
    print('🌍 [CustomDatePicker] Locale parameter: $locale');
    print('📆 [CustomDatePicker] Initial date: $initialDate');
    
    HapticFeedback.selectionClick();

    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        print('🏗️ [CustomDatePicker] Building bottom sheet...');
        print('🌍 [CustomDatePicker] Locale to use: ${locale ?? "default from context"}');
        
        // إذا كان locale محدد، نستخدم Localizations.override
        if (locale != null) {
          print('✅ [CustomDatePicker] Using Localizations.override with locale: $locale');
          return Localizations.override(
            context: context,
            locale: locale,
            child: Builder(
              builder: (localizedContext) {
                print('🎨 [CustomDatePicker] Creating _EnhancedDatePickerBottomSheet with forceLocale: $locale');
                return _EnhancedDatePickerBottomSheet(
                  initialDate: initialDate ?? DateTime.now(),
                  firstDate: firstDate ?? DateTime(2020),
                  lastDate: lastDate ?? DateTime.now(),
                  title: title,
                  forceLocale: locale, // Pass locale to widget
                );
              },
            ),
          );
        }
        
        print('⚠️ [CustomDatePicker] No locale specified, using default');
        // بدون locale محدد، نستخدم locale الافتراضي من الـ context
        return _EnhancedDatePickerBottomSheet(
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime.now(),
          title: title,
        );
      },
    );
  }

  /// عرض تقويم مخصص كـ Dialog احترافي
  static Future<DateTime?> showDialog({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
    Locale? locale, // Add locale parameter
  }) async {
    HapticFeedback.selectionClick();

    return await showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Date Picker',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: _EnhancedDatePickerDialog(
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2020),
              lastDate: lastDate ?? DateTime.now(),
              title: title,
              forceLocale: locale, // Pass locale
            ),
          ),
        );
      },
    );
  }

  static ThemeData _buildDatePickerTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme.of(context).copyWith(
      colorScheme: isDark
          ? ColorScheme.dark(
        primary: _DatePickerColors.purple,
        onPrimary: Colors.white,
        surface: _DatePickerColors.darkCard,
        onSurface: _DatePickerColors.white,
        secondary: _DatePickerColors.lightGreen,
        onSecondary: Colors.white,
      )
          : const ColorScheme.light(
        primary: _DatePickerColors.purple,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: _DatePickerColors.dark,
        secondary: _DatePickerColors.lightGreen,
        onSecondary: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? _DatePickerColors.darkCard : Colors.white,
        elevation: 16,
        shadowColor: _DatePickerColors.purple.withOpacity(isDark ? 0.3 : 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDark ? _DatePickerColors.darkCard : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        headerBackgroundColor: _DatePickerColors.purple,
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headerHelpStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
        weekdayStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark
              ? _DatePickerColors.gray
              : _DatePickerColors.dark.withOpacity(0.5),
        ),
        dayStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? _DatePickerColors.white : _DatePickerColors.dark,
        ),
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _DatePickerColors.purple;
          }
          return isDark
              ? _DatePickerColors.purple.withOpacity(0.2)
              : _DatePickerColors.lightPurple;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return _DatePickerColors.purple;
        }),
        todayBorder: const BorderSide(
          color: _DatePickerColors.purple,
          width: 2,
        ),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _DatePickerColors.purple;
          }
          return Colors.transparent;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return isDark
                ? _DatePickerColors.gray.withOpacity(0.4)
                : _DatePickerColors.gray;
          }
          return isDark ? _DatePickerColors.white : _DatePickerColors.dark;
        }),
        dayOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return isDark
                ? _DatePickerColors.purple.withOpacity(0.2)
                : _DatePickerColors.lightPurple.withOpacity(0.5);
          }
          if (states.contains(WidgetState.pressed)) {
            return isDark
                ? _DatePickerColors.purple.withOpacity(0.3)
                : _DatePickerColors.lightPurple;
          }
          return Colors.transparent;
        }),
        yearStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? _DatePickerColors.white : _DatePickerColors.dark,
        ),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _DatePickerColors.purple;
          }
          return Colors.transparent;
        }),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return isDark ? _DatePickerColors.white : _DatePickerColors.dark;
        }),
        surfaceTintColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _DatePickerColors.purple,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          hoverColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Enhanced Bottom Sheet Date Picker
// ═══════════════════════════════════════════════════════════════════════════
class _EnhancedDatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? title;
  final Locale? forceLocale; // Add locale parameter

  const _EnhancedDatePickerBottomSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title,
    this.forceLocale, // Add to constructor
  });

  @override
  State<_EnhancedDatePickerBottomSheet> createState() =>
      _EnhancedDatePickerBottomSheetState();
}

class _EnhancedDatePickerBottomSheetState
    extends State<_EnhancedDatePickerBottomSheet>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _slideDirection = 0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    print('🎨 [_EnhancedDatePickerBottomSheet] initState called');
    print('🌍 [_EnhancedDatePickerBottomSheet] forceLocale: ${widget.forceLocale}');
    print('📅 [_EnhancedDatePickerBottomSheet] initialDate: ${widget.initialDate}');
    
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Helper method to get translated text with forced locale
  String _getLocalizedText(String key) {
    if (widget.forceLocale != null) {
      // Return English text directly when forceLocale is set
      final englishTexts = {
        'date_today': 'Today',
        'date_yesterday': 'Yesterday',
        'date_month_start': 'Month Start',
        'date_selected_date': 'Selected Date',
        'date_cancel': 'Cancel',
        'date_confirm': 'Confirm',
        'date_select_date': 'Select Date',
      };
      return englishTexts[key] ?? key;
    }
    return key.tr();
  }

  void _navigateMonth(int direction) async {
    HapticFeedback.lightImpact();

    setState(() {
      _slideDirection = direction;
    });

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(direction.toDouble(), 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInCubic,
    ));

    await _slideController.forward();

    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + direction,
      );
    });

    _slideAnimation = Tween<Offset>(
      begin: Offset(-direction.toDouble(), 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.reset();
    await _slideController.forward();
  }

  void _selectDate(DateTime date) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DatePickerColors.card(_isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: _isDark
            ? Border.all(color: _DatePickerColors.border(_isDark))
            : null,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildCalendar(),
            _buildSelectedDateDisplay(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: _isDark
            ? _DatePickerColors.white.withOpacity(0.2)
            : _DatePickerColors.gray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: _DatePickerColors.headerGradient(_isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _DatePickerColors.purple.withOpacity(_isDark ? 0.3 : 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavigationButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => _navigateMonth(-1),
            isDark: _isDark,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.title ?? _getLocalizedText('date_select_date'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(_slideDirection.toDouble() * 0.2, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    DateFormat('MMMM yyyy', widget.forceLocale?.toString() ?? context.locale.toString())
                        .format(_displayedMonth),
                    key: ValueKey(_displayedMonth),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _NavigationButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () => _navigateMonth(1),
            isDark: _isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _QuickActionChip(
            label: _getLocalizedText('date_today'),
            isSelected: _isToday(_selectedDate),
            isDark: _isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDate = DateTime.now();
                _displayedMonth = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                );
              });
            },
          ),
          const SizedBox(width: 12),
          _QuickActionChip(
            label: _getLocalizedText('date_yesterday'),
            isSelected: _isYesterday(_selectedDate),
            isDark: _isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              final yesterday = DateTime.now().subtract(const Duration(days: 1));
              setState(() {
                _selectedDate = yesterday;
                _displayedMonth = DateTime(yesterday.year, yesterday.month);
              });
            },
          ),
          const SizedBox(width: 12),
          _QuickActionChip(
            label: _getLocalizedText('date_month_start'),
            isSelected: _isFirstOfMonth(_selectedDate),
            isDark: _isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDate = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month,
                  1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          const SizedBox(height: 12),
          SlideTransition(
            position: _slideAnimation,
            child: _buildDaysGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = _getLocalizedWeekdays(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.asMap().entries.map((entry) {
        final day = entry.value;
        final index = entry.key;
        // Weekend is Saturday (index 5) and Sunday (index 6)
        final isWeekend = index == 5 || index == 6;
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isWeekend
                    ? _DatePickerColors.purple.withOpacity(_isDark ? 0.9 : 0.7)
                    : _DatePickerColors.textSecondary(_isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<String> _getLocalizedWeekdays(BuildContext context) {
    final locale = widget.forceLocale?.languageCode ?? context.locale.languageCode;
    if (locale == 'ar') {
      return ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
    } else {
      return ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    }
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth =
    DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth =
    DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = (firstDayOfMonth.weekday % 7);

    final totalCells = daysInMonth + firstWeekday;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Row(
          children: List.generate(7, (colIndex) {
            final index = rowIndex * 7 + colIndex;
            if (index < firstWeekday || index >= daysInMonth + firstWeekday) {
              return const Expanded(child: SizedBox(height: 48));
            }

            final day = index - firstWeekday + 1;
            final date = DateTime(
              _displayedMonth.year,
              _displayedMonth.month,
              day,
            );

            return Expanded(
              child: _DayCell(
                date: date,
                isSelected: _isSameDay(date, _selectedDate),
                isToday: _isSameDay(date, DateTime.now()),
                isDisabled: date.isAfter(widget.lastDate) ||
                    date.isBefore(widget.firstDate),
                isDark: _isDark,
                onTap: () => _selectDate(date),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildSelectedDateDisplay() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _DatePickerColors.secondaryGradient(_isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _DatePickerColors.purple.withOpacity(_isDark ? 0.3 : 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _DatePickerColors.purple.withOpacity(_isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.event_rounded,
              color: _DatePickerColors.purple,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedText('date_selected_date'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _DatePickerColors.textSecondary(_isDark),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    DateFormat('EEEE، d MMMM yyyy', widget.forceLocale?.toString() ?? context.locale.toString())
                        .format(_selectedDate),
                    key: ValueKey(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _DatePickerColors.text(_isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DatePickerColors.surface(_isDark),
        border: Border(
          top: BorderSide(
            color: _DatePickerColors.divider(_isDark),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: _getLocalizedText('date_cancel'),
              isPrimary: false,
              isDark: _isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: _getLocalizedText('date_confirm'),
              isPrimary: true,
              isDark: _isDark,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context, _selectedDate);
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());

  bool _isYesterday(DateTime date) =>
      _isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));

  bool _isFirstOfMonth(DateTime date) => date.day == 1;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Enhanced Dialog Date Picker
// ═══════════════════════════════════════════════════════════════════════════
class _EnhancedDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? title;
  final Locale? forceLocale; // Add locale parameter

  const _EnhancedDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title,
    this.forceLocale, // Add to constructor
  });

  @override
  State<_EnhancedDatePickerDialog> createState() =>
      _EnhancedDatePickerDialogState();
}

class _EnhancedDatePickerDialogState extends State<_EnhancedDatePickerDialog>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  late AnimationController _monthController;
  int _slideDirection = 0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );

    _monthController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    super.dispose();
  }

  void _navigateMonth(int direction) async {
    HapticFeedback.lightImpact();
    setState(() => _slideDirection = direction);
    await _monthController.forward();
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + direction,
      );
    });
    _monthController.reset();
  }

  // Helper method to get translated text with forced locale
  String _getLocalizedText(String key) {
    if (widget.forceLocale != null) {
      // Return English text directly when forceLocale is set
      final englishTexts = {
        'date_today': 'Today',
        'date_yesterday': 'Yesterday',
        'date_month_start': 'Month Start',
        'date_selected_date': 'Selected Date',
        'date_cancel': 'Cancel',
        'date_confirm': 'Confirm',
        'date_select_date': 'Select Date',
      };
      return englishTexts[key] ?? key;
    }
    return key.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: _DatePickerColors.card(_isDark),
        borderRadius: BorderRadius.circular(28),
        border: _isDark
            ? Border.all(color: _DatePickerColors.border(_isDark))
            : null,
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withOpacity(0.4)
                : _DatePickerColors.dark.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDialogWeekdayHeaders(),
                const SizedBox(height: 12),
                _buildDialogDaysGrid(),
              ],
            ),
          ),
          _buildDialogActions(),
        ],
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _DatePickerColors.headerGradient(_isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title ?? _getLocalizedText('date_select_date'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    DateFormat('EEEE، d MMMM yyyy', widget.forceLocale?.toString() ?? context.locale.toString())
                        .format(_selectedDate),
                    key: ValueKey(_selectedDate),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavigationButton(
                icon: Icons.arrow_back_ios_rounded,
                onTap: () => _navigateMonth(-1),
                isDark: _isDark,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  DateFormat('MMMM yyyy', widget.forceLocale?.toString() ?? context.locale.toString())
                      .format(_displayedMonth),
                  key: ValueKey(_displayedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              _NavigationButton(
                icon: Icons.arrow_forward_ios_rounded,
                onTap: () => _navigateMonth(1),
                isDark: _isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogWeekdayHeaders() {
    final locale = widget.forceLocale?.languageCode ?? context.locale.languageCode;
    final weekdays = locale == 'ar' 
        ? ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج']
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.asMap().entries.map((entry) {
        final day = entry.value;
        final index = entry.key;
        // Weekend is Saturday (index 5) and Sunday (index 6)
        final isWeekend = index == 5 || index == 6;
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isWeekend
                    ? _DatePickerColors.purple.withOpacity(_isDark ? 0.9 : 0.7)
                    : _DatePickerColors.textSecondary(_isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDialogDaysGrid() {
    final firstDayOfMonth =
    DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth =
    DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = (firstDayOfMonth.weekday % 7);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        if (index < firstWeekday || index >= daysInMonth + firstWeekday) {
          return const SizedBox.shrink();
        }

        final day = index - firstWeekday + 1;
        final date = DateTime(
          _displayedMonth.year,
          _displayedMonth.month,
          day,
        );

        final isSelected = _isSameDay(date, _selectedDate);
        final isToday = _isSameDay(date, DateTime.now());
        final isDisabled =
            date.isAfter(widget.lastDate) || date.isBefore(widget.firstDate);

        return _DayCell(
          date: date,
          isSelected: isSelected,
          isToday: isToday,
          isDisabled: isDisabled,
          isDark: _isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedDate = date);
          },
        );
      },
    );
  }

  Widget _buildDialogActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DatePickerColors.surface(_isDark),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: _DatePickerColors.divider(_isDark),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _DatePickerColors.textSecondary(_isDark),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, _selectedDate);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _DatePickerColors.purple,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تأكيد',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Day Cell Widget
// ═══════════════════════════════════════════════════════════════════════════
class _DayCell extends StatefulWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final bool isDark;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
      onTapDown: widget.isDisabled ? null : (_) => _controller.forward(),
      onTapUp: widget.isDisabled
          ? null
          : (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: widget.isDisabled ? null : () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? _DatePickerColors.primaryGradient(widget.isDark)
                : null,
            color: widget.isSelected
                ? null
                : widget.isToday
                ? (widget.isDark
                ? _DatePickerColors.purple.withOpacity(0.2)
                : _DatePickerColors.lightPurple)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isToday && !widget.isSelected
                ? Border.all(
              color: _DatePickerColors.purple,
              width: 2,
            )
                : null,
            boxShadow: widget.isSelected
                ? [
              BoxShadow(
                color: _DatePickerColors.purple
                    .withOpacity(widget.isDark ? 0.3 : 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              '${widget.date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: widget.isSelected || widget.isToday
                    ? FontWeight.bold
                    : FontWeight.w600,
                color: widget.isDisabled
                    ? (widget.isDark
                    ? _DatePickerColors.gray.withOpacity(0.4)
                    : _DatePickerColors.gray)
                    : widget.isSelected
                    ? Colors.white
                    : widget.isToday
                    ? _DatePickerColors.purple
                    : _DatePickerColors.text(widget.isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Navigation Button Widget
// ═══════════════════════════════════════════════════════════════════════════
class _NavigationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _NavigationButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(widget.isDark ? 0.15 : 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏷️ Quick Action Chip Widget
// ═══════════════════════════════════════════════════════════════════════════
class _QuickActionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
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
          gradient: isSelected
              ? _DatePickerColors.primaryGradient(isDark)
              : null,
          color: isSelected
              ? null
              : _DatePickerColors.surface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
            color: _DatePickerColors.border(isDark),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _DatePickerColors.purple
                  .withOpacity(isDark ? 0.25 : 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : _DatePickerColors.text(isDark),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Action Button Widget
// ═══════════════════════════════════════════════════════════════════════════
class _ActionButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? _DatePickerColors.primaryGradient(widget.isDark)
                : null,
            color: widget.isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: widget.isPrimary
                ? null
                : Border.all(
              color: _DatePickerColors.border(widget.isDark),
              width: 1.5,
            ),
            boxShadow: widget.isPrimary
                ? [
              BoxShadow(
                color: _DatePickerColors.purple
                    .withOpacity(widget.isDark ? 0.3 : 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: widget.isPrimary
                    ? Colors.white
                    : _DatePickerColors.textSecondary(widget.isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}