import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Colors - ألوان الهوية البصرية
// ═══════════════════════════════════════════════════════════════════════════
class AppColors {
  static const Color primary = Color(0xFF6842E2);
  static const Color primaryLight = Color(0xFF8B6CEF);
  static const Color primaryDark = Color(0xFF5234B5);
  static const Color secondary = Color(0xFF00C88D);
  static const Color secondaryLight = Color(0xFF28E6C5);
  static const Color accent = Color(0xFFFBBF4D);
  static const Color dark = Color(0xFF081428);
  static const Color white = Colors.white;
  static const Color darkBackground = Color(0xFF0A0A12);
  static const Color darkCard = Color(0xFF14141F);
  static const Color darkCardLight = Color(0xFF1E1E2D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
}

// ═══════════════════════════════════════════════════════════════════════════
// 📅 Ramadan Calendar Screen
// ═══════════════════════════════════════════════════════════════════════════
class RamadanCalendarScreen extends StatefulWidget {
  const RamadanCalendarScreen({Key? key}) : super(key: key);

  @override
  State<RamadanCalendarScreen> createState() => _RamadanCalendarScreenState();
}

class _RamadanCalendarScreenState extends State<RamadanCalendarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late DateTime ramadanStart;
  late DateTime ramadanEnd;
  late List<RamadanDay> ramadanDays;

  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _initDates();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  void _initDates() {
    // 🇸🇦 رمضان 2026 في الرياض - التواريخ الصحيحة
    // بداية رمضان: 18 فبراير 2026
    // نهاية رمضان: 19 مارس 2026
    ramadanStart = DateTime(2026, 2, 18);
    ramadanEnd = DateTime(2026, 3, 19);

    ramadanDays = List.generate(30, (index) {
      final day = index + 1;
      return RamadanDay(
        day: day,
        date: ramadanStart.add(Duration(days: index)),
        fajr: _getFajrTime(day),
        iftar: _getIftarTime(day),
        suhoor: _getSuhoorTime(day),
      );
    });
  }

  // 🌅 أوقات الفجر - رمضان 2026 (الرياض)
  String _getFajrTime(int day) {
    final times = [
      '05:02', '05:01', '05:00', '04:59', '04:58', '04:57', '04:56',
      '04:55', '04:54', '04:53', '04:52', '04:51', '04:50', '04:49',
      '04:48', '04:47', '04:46', '04:45', '04:44', '04:43', '04:42',
      '04:41', '04:40', '04:39', '04:38', '04:37', '04:36', '04:35',
      '04:34', '04:33'
    ];
    return times[day - 1];
  }

  // 🌙 أوقات المغرب (الإفطار) - رمضان 2026 (الرياض)
  String _getIftarTime(int day) {
    final times = [
      '17:54', '17:55', '17:56', '17:57', '17:58', '17:59', '18:00',
      '18:01', '18:02', '18:03', '18:04', '18:05', '18:06', '18:07',
      '18:08', '18:09', '18:10', '18:11', '18:12', '18:13', '18:14',
      '18:15', '18:16', '18:17', '18:18', '18:19', '18:20', '18:21',
      '18:22', '18:23'
    ];
    return times[day - 1];
  }

  // 🌙 أوقات السحور (قبل الفجر بـ 10 دقائق) - رمضان 2026 (الرياض)
  String _getSuhoorTime(int day) {
    final times = [
      '04:52', '04:51', '04:50', '04:49', '04:48', '04:47', '04:46',
      '04:45', '04:44', '04:43', '04:42', '04:41', '04:40', '04:39',
      '04:38', '04:37', '04:36', '04:35', '04:34', '04:33', '04:32',
      '04:31', '04:30', '04:29', '04:28', '04:27', '04:26', '04:25',
      '04:24', '04:23'
    ];
    return times[day - 1];
  }

  int get currentDay {
    // 🇸🇦 التوقيت السعودي (الرياض) = UTC+3
    final nowUtc = DateTime.now().toUtc();
    final now = nowUtc.add(const Duration(hours: 3)); // توقيت الرياض
    
    if (now.isBefore(ramadanStart)) return 0;
    if (now.isAfter(ramadanEnd)) return 31;
    return now.difference(ramadanStart).inDays + 1;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(isDark, isRTL),
          SliverToBoxAdapter(child: _buildHeader(isDark, isRTL)),
          if (currentDay > 0 && currentDay <= 30)
            SliverToBoxAdapter(child: _buildTodaySection(isDark, isRTL)),
          SliverToBoxAdapter(child: _buildCalendarHeader(isDark, isRTL)),
          _buildCalendarGrid(isDark, isRTL),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📱 App Bar
  // ═══════════════════════════════════════════════════════════════════════
  SliverAppBar _buildAppBar(bool isDark, bool isRTL) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F7),
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
            ],
          ),
          child: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? AppColors.white : AppColors.dark,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => _showLocationSheet(isDark, isRTL),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
              ],
            ),
            child: Row(
              // children: [
              //   Icon(
              //     Icons.location_on,
              //     size: 16,
              //     color: AppColors.primary,
              //   ),
              //   const SizedBox(width: 4),
              //   Text(
              //     isRTL ? 'الرياض' : 'Riyadh',
              //     style: TextStyle(
              //       fontSize: 13,
              //       fontWeight: FontWeight.w600,
              //       color: isDark ? AppColors.white : AppColors.dark,
              //     ),
              //   ),
              // ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🌙 Header Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark, bool isRTL) {
    final daysLeft = currentDay > 0 ? 30 - currentDay : 30;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRTL ? 'رمضان مبارك' : 'Ramadan Mubarak',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '1447 هـ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 40)),
                ),
              ),
            ],
          ),

          if (currentDay > 0 && currentDay <= 30) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildStatBox(
                    value: '$currentDay',
                    label: isRTL ? 'اليوم' : 'Day',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.white.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _buildStatBox(
                    value: '$daysLeft',
                    label: isRTL ? 'متبقي' : 'Left',
                  ),
                  const Spacer(),
                  _buildProgressRing(currentDay / 30),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBox({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing(double progress) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: AppColors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🕌 Today Section
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTodaySection(bool isDark, bool isRTL) {
    final today = ramadanDays[currentDay - 1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'اليوم' : 'Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.nights_stay_rounded,
                  title: isRTL ? 'السحور' : 'Suhoor',
                  time: today.suhoor,
                  color: AppColors.primaryLight,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.wb_sunny_rounded,
                  title: isRTL ? 'الفجر' : 'Fajr',
                  time: today.fajr,
                  color: AppColors.accent,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.wb_twilight_rounded,
                  title: isRTL ? 'الإفطار' : 'Iftar',
                  time: today.iftar,
                  color: AppColors.secondary,
                  isDark: isDark,
                  isHighlighted: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
    required bool isDark,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color
            : (isDark ? AppColors.darkCard : AppColors.white),
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? null
            : Border.all(
          color: isDark ? AppColors.darkCardLight : AppColors.divider,
        ),
        boxShadow: isHighlighted
            ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isHighlighted ? AppColors.white : color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlighted
                  ? AppColors.white
                  : (isDark ? AppColors.white : AppColors.dark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isHighlighted
                  ? AppColors.white.withOpacity(0.8)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📅 Calendar Header
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildCalendarHeader(bool isDark, bool isRTL) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isRTL ? 'أيام رمضان' : 'Ramadan Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.dark,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '30 ${isRTL ? "يوم" : "days"}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📆 Calendar Grid
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildCalendarGrid(bool isDark, bool isRTL) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final day = index + 1;
            final isPassed = day < currentDay;
            final isCurrent = day == currentDay;
            final isSelected = day == _selectedDay;

            return _DayCell(
              day: day,
              isPassed: isPassed,
              isCurrent: isCurrent,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedDay = day);
                _showDayDetails(ramadanDays[day - 1], isDark, isRTL);
              },
            );
          },
          childCount: 30,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📋 Day Details Sheet
  // ═══════════════════════════════════════════════════════════════════════
  void _showDayDetails(RamadanDay day, bool isDark, bool isRTL) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DayDetailsSheet(
        day: day,
        isDark: isDark,
        isRTL: isRTL,
        currentDay: currentDay,
      ),
    );
  }

  void _showLocationSheet(bool isDark, bool isRTL) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.location_on,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'الرياض، المملكة العربية السعودية' : 'Riyadh, Saudi Arabia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRTL ? 'التوقيت: +03:00' : 'Timezone: +03:00',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📆 Day Cell Widget
// ═══════════════════════════════════════════════════════════════════════════
class _DayCell extends StatelessWidget {
  final int day;
  final bool isPassed;
  final bool isCurrent;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isPassed,
    required this.isCurrent,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;
    List<BoxShadow>? shadow;

    if (isCurrent) {
      bgColor = AppColors.primary;
      textColor = AppColors.white;
      shadow = [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (isPassed) {
      bgColor = isDark
          ? AppColors.darkCard.withOpacity(0.5)
          : const Color(0xFFE8E8E8);
      textColor = AppColors.textSecondary;
    } else {
      bgColor = isDark ? AppColors.darkCard : AppColors.white;
      textColor = isDark ? AppColors.white : AppColors.dark;
      border = Border.all(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkCardLight : AppColors.divider),
        width: isSelected ? 2 : 1,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: border,
          boxShadow: shadow,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isPassed)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.check_circle,
                  size: 12,
                  color: AppColors.secondary.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📋 Day Details Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════
class _DayDetailsSheet extends StatelessWidget {
  final RamadanDay day;
  final bool isDark;
  final bool isRTL;
  final int currentDay;

  const _DayDetailsSheet({
    required this.day,
    required this.isDark,
    required this.isRTL,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = day.day < currentDay;
    final isCurrent = day.day == currentDay;

    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Day Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCurrent
                      ? [AppColors.primary, AppColors.primaryLight]
                      : isPassed
                      ? [AppColors.secondary, AppColors.secondaryLight]
                      : [AppColors.primaryLight, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCurrent
                        ? Icons.today
                        : isPassed
                        ? Icons.check_circle
                        : Icons.event,
                    color: AppColors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRTL ? 'اليوم ${day.day}' : 'Day ${day.day}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Date
            Text(
              '${day.day} ${isRTL ? "رمضان" : "Ramadan"} 1447',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // Iftar Card - Main
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.secondary, Color(0xFF00A878)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRTL ? 'موعد الإفطار' : 'Iftar Time',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    day.iftar,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Other Prayer Times
            Row(
              children: [
                Expanded(
                  child: _buildPrayerCard(
                    icon: Icons.nights_stay_rounded,
                    title: isRTL ? 'السحور' : 'Suhoor',
                    time: day.suhoor,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPrayerCard(
                    icon: Icons.wb_sunny_rounded,
                    title: isRTL ? 'الفجر' : 'Fajr',
                    time: day.fajr,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkBackground
                      : const Color(0xFFF5F5F7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isRTL ? 'إغلاق' : 'Close',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.dark,
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Ramadan Day Model
// ═══════════════════════════════════════════════════════════════════════════
class RamadanDay {
  final int day;
  final DateTime date;
  final String fajr;
  final String iftar;
  final String suhoor;

  const RamadanDay({
    required this.day,
    required this.date,
    required this.fajr,
    required this.iftar,
    required this.suhoor,
  });
}