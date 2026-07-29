import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// 🧪 صفحة اختبار لعداد أذان المغرب
class MaghribCountdownTest extends StatefulWidget {
  const MaghribCountdownTest({Key? key}) : super(key: key);

  @override
  State<MaghribCountdownTest> createState() => _MaghribCountdownTestState();
}

class _MaghribCountdownTestState extends State<MaghribCountdownTest> {
  Timer? _timer;
  Duration _timeRemaining = const Duration(minutes: 28, seconds: 45); // مثال: 28 دقيقة و45 ثانية

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        if (_timeRemaining.inSeconds > 0) {
          _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        } else {
          _timeRemaining = const Duration(minutes: 29, seconds: 59); // إعادة تعيين
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? '🧪 اختبار عداد المغرب' : '🧪 Maghrib Countdown Test'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 📱 العنوان
              Text(
                isArabic ? '🌙 شكل العداد في البنر' : '🌙 Countdown in Banner',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              
              const SizedBox(height: 30),

              // 🕌 العداد - نسخة من التصميم الأصلي
              _buildMaghribCountdown(isDark, isArabic),

              const SizedBox(height: 40),

              // 🎮 أزرار التحكم
              _buildControls(isArabic),

              const SizedBox(height: 20),

              // 📊 معلومات
              _buildInfo(isDark, isArabic),
            ],
          ),
        ),
      ),
    );
  }

  /// 🕌 عداد تنازلي لأذان المغرب (نسخة الاختبار)
  Widget _buildMaghribCountdown(bool isDark, bool isArabic) {
    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);
    final seconds = _timeRemaining.inSeconds.remainder(60);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF28E6C5).withOpacity(isDark ? 0.25 : 0.3),
            const Color(0xFF20C9AC).withOpacity(isDark ? 0.25 : 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF28E6C5).withOpacity(isDark ? 0.4 : 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28E6C5).withOpacity(isDark ? 0.3 : 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان العداد
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: isDark ? const Color(0xFF34F5D8) : const Color(0xFF14B8A6),
              ),
              const SizedBox(width: 6),
              Text(
                isArabic ? '⏰ موعد الإفطار قريب' : '⏰ Iftar Time Soon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF5B21B6),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // العداد التنازلي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit(hours, isArabic ? 'ساعة' : 'Hour', isDark),
              _buildTimeSeparator(isDark),
              _buildTimeUnit(minutes, isArabic ? 'دقيقة' : 'Min', isDark),
              _buildTimeSeparator(isDark),
              _buildTimeUnit(seconds, isArabic ? 'ثانية' : 'Sec', isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// وحدة زمنية في العداد
  Widget _buildTimeUnit(int value, String label, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF34F5D8).withOpacity(0.3)
                  : const Color(0xFF14B8A6).withOpacity(0.2),
            ),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF34F5D8) : const Color(0xFF14B8A6),
              fontFamily: 'Cairo',
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  /// فاصل بين الوحدات
  Widget _buildTimeSeparator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF34F5D8) : const Color(0xFF14B8A6),
          height: 1,
        ),
      ),
    );
  }

  /// 🎮 أزرار التحكم
  Widget _buildControls(bool isArabic) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _timeRemaining = const Duration(minutes: 5, seconds: 30);
            });
          },
          icon: const Icon(Icons.timer, size: 18),
          label: Text(isArabic ? '5 دقائق' : '5 min'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF28E6C5),
            foregroundColor: Colors.black87,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _timeRemaining = const Duration(minutes: 15, seconds: 0);
            });
          },
          icon: const Icon(Icons.timer, size: 18),
          label: Text(isArabic ? '15 دقيقة' : '15 min'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF20C9AC),
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _timeRemaining = const Duration(minutes: 29, seconds: 59);
            });
          },
          icon: const Icon(Icons.timer, size: 18),
          label: Text(isArabic ? '30 دقيقة' : '30 min'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14B8A6),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 📊 معلومات
  Widget _buildInfo(bool isDark, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? '📝 ملاحظات:' : '📝 Notes:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? '• العداد يظهر فقط قبل 30 دقيقة من المغرب\n'
                  '• يتحدث كل ثانية تلقائياً\n'
                  '• التصميم يدعم الوضع الداكن والفاتح\n'
                  '• الألوان رمضانية (أخضر تركواز)'
                : '• Countdown shows only 30 min before Maghrib\n'
                  '• Updates every second automatically\n'
                  '• Supports dark and light modes\n'
                  '• Ramadan colors (turquoise green)',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
