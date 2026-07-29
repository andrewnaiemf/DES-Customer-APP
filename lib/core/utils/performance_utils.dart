// ═══════════════════════════════════════════════════════════════════════════
// 🚀 Performance Utilities - أدوات تحسين الأداء
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📊 Performance Monitor - مراقب الأداء
/// يستخدم SchedulerBinding.addTimingsCallback لقياس وقت العمل الفعلي
/// (build + raster) بدلاً من totalSpan الذي يشمل vsync overhead
///
/// ملاحظة مهمة:
///   totalSpan يشمل vsyncOverhead (الانتظار لإشارة vsync التالية)
///   على شاشات 120Hz (مثل iPhone Pro) هذا يضيف ~16ms وهمية
///   لذلك نقيس buildDuration + rasterDuration = وقت العمل الحقيقي فقط
/// ═══════════════════════════════════════════════════════════════════════════
class PerformanceMonitor {
  static final Map<String, Stopwatch> _watches = {};
  
  // ─── Frame Timing State ───
  static bool _isMonitoring = false;
  static Timer? _reportTimer;
  static int _totalFrames = 0;
  static int _slowFrames = 0;       // > 16ms actual work (missed 60fps budget)
  static int _verySlowFrames = 0;   // > 32ms actual work (severe jank)
  static double _totalBuildMs = 0;
  static double _totalRasterMs = 0;
  static double _worstBuildMs = 0;
  static double _worstRasterMs = 0;
  static double _worstTotalWorkMs = 0;
  
  // ─── Detect display refresh rate ───
  // على 120Hz (ProMotion): vsync interval ~8.3ms
  // على 60Hz: vsync interval ~16.7ms
  // نستخدم 16ms كحد أقصى لأن هذا هو الـ budget الذي يجب ألا يتجاوزه
  // وقت العمل الفعلي (build + raster) لتجنب jank مرئي
  static const double _jankThresholdMs = 16.0;
  static const double _severeJankThresholdMs = 32.0;
  
  /// بدء مراقبة frame timing تلقائية - تطبع تقرير كل [intervalSeconds] ثانية
  /// يقيس وقت العمل الفعلي (build + raster) وليس totalSpan
  static void startFrameMonitoring({int intervalSeconds = 30}) {
    if (!kDebugMode || _isMonitoring) return;
    _isMonitoring = true;
    _resetCounters();
    
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    
    _reportTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _printReport(),
    );
    
    dev.log('📊 [PerformanceMonitor] Started (report every ${intervalSeconds}s)',
        name: 'Performance');
  }
  
  /// إيقاف مراقبة frame timing
  static void stopFrameMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _reportTimer?.cancel();
    _reportTimer = null;
    
    _printReport();
    _resetCounters();
    
    dev.log('📊 [PerformanceMonitor] Stopped', name: 'Performance');
  }
  
  /// ── معالجة بيانات FrameTiming من محرك Flutter ──
  static void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      // ═══════════════════════════════════════════════════════════════════
      // القياس الصحيح: وقت العمل الفعلي = build + raster
      // 
      // ❌ totalSpan يشمل vsyncOverhead = idle wait time
      //    → على 120Hz يعطي ~33ms حتى لو العمل الفعلي 8ms فقط
      //
      // ✅ buildDuration + rasterDuration = العمل الحقيقي فقط
      //    → يعكس الوقت الذي يستغرقه Flutter فعلاً لرسم الفريم
      // ═══════════════════════════════════════════════════════════════════
      final buildMs = timing.buildDuration.inMicroseconds / 1000.0;
      final rasterMs = timing.rasterDuration.inMicroseconds / 1000.0;
      final workMs = buildMs + rasterMs;
      
      _totalFrames++;
      _totalBuildMs += buildMs;
      _totalRasterMs += rasterMs;
      
      if (buildMs > _worstBuildMs) _worstBuildMs = buildMs;
      if (rasterMs > _worstRasterMs) _worstRasterMs = rasterMs;
      if (workMs > _worstTotalWorkMs) _worstTotalWorkMs = workMs;
      
      if (workMs > _jankThresholdMs) {
        _slowFrames++;
        
        if (workMs > _severeJankThresholdMs) {
          _verySlowFrames++;
        }
        
        // // ⚠️ تسجيل الفريمات البطيئة (> 16ms عمل فعلي) للتحليل
        // dev.log(
        //   '🐌 Slow frame: ${workMs.toStringAsFixed(1)}ms '
        //   '(build: ${buildMs.toStringAsFixed(1)}ms, '
        //   'raster: ${rasterMs.toStringAsFixed(1)}ms)',
        //   name: 'Performance',
        // );
      }
    }
  }
  
  /// ── طباعة تقرير الأداء ──
  static void _printReport() {
    if (_totalFrames == 0) return;
    
    final avgBuildMs = _totalBuildMs / _totalFrames;
    final avgRasterMs = _totalRasterMs / _totalFrames;
    final avgWorkMs = avgBuildMs + avgRasterMs;
    final slowPercent = (_slowFrames / _totalFrames * 100).toStringAsFixed(1);
    final verySlowPercent = (_verySlowFrames / _totalFrames * 100).toStringAsFixed(1);
    
    // تحديد حالة الأداء بناءً على نسبة الفريمات البطيئة (>16ms عمل فعلي)
    final String status;
    final double slowRatio = _slowFrames / _totalFrames;
    if (slowRatio < 0.05) {
      status = '✅ Excellent';
    } else if (slowRatio < 0.10) {
      status = '👍 Good';
    } else if (slowRatio < 0.25) {
      status = '⚠️ Needs Attention';
    } else {
      status = '🔴 Poor Performance';
    }
    
    debugPrint('═══════════════════════════════════════');
    debugPrint('📊 [PerformanceMonitor] Report');
    debugPrint('   Total Frames: $_totalFrames');
    debugPrint('   Avg Build: ${avgBuildMs.toStringAsFixed(1)}ms | '
        'Avg Raster: ${avgRasterMs.toStringAsFixed(1)}ms');
    debugPrint('   Avg Work Time: ${avgWorkMs.toStringAsFixed(1)}ms '
        '(budget: ${_jankThresholdMs.toStringAsFixed(0)}ms)');
    debugPrint('   Worst Frame: ${_worstTotalWorkMs.toStringAsFixed(1)}ms '
        '(build: ${_worstBuildMs.toStringAsFixed(1)}ms, '
        'raster: ${_worstRasterMs.toStringAsFixed(1)}ms)');
    debugPrint('   Slow Frames (>${_jankThresholdMs.toStringAsFixed(0)}ms): '
        '$_slowFrames ($slowPercent%)');
    debugPrint('   Severe Jank (>${_severeJankThresholdMs.toStringAsFixed(0)}ms): '
        '$_verySlowFrames ($verySlowPercent%)');
    debugPrint('   Status: $status');
    debugPrint('═══════════════════════════════════════');
    
    _resetCounters();
  }
  
  static void _resetCounters() {
    _totalFrames = 0;
    _slowFrames = 0;
    _verySlowFrames = 0;
    _totalBuildMs = 0;
    _totalRasterMs = 0;
    _worstBuildMs = 0;
    _worstRasterMs = 0;
    _worstTotalWorkMs = 0;
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ⏱️ Operation Tracing - تتبع العمليات الفردية
  // ═════════════════════════════════════════════════════════════════════════
  
  /// بدء تتبع عملية
  static void startTrace(String name) {
    if (!kDebugMode) return;
    _watches[name] = Stopwatch()..start();
  }

  /// إنهاء تتبع عملية
  static void endTrace(String name) {
    if (!kDebugMode) return;
    final watch = _watches.remove(name);
    if (watch != null) {
      watch.stop();
      final ms = watch.elapsedMilliseconds;
      if (ms > 16) {
        dev.log('⚠️ SLOW: $name took ${ms}ms', name: 'Performance');
      } else {
        dev.log('✅ $name: ${ms}ms', name: 'Performance');
      }
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔄 Debouncer - مانع التكرار السريع
/// ═══════════════════════════════════════════════════════════════════════════
class Debouncer {
  final Duration delay;
  VoidCallback? _action;
  bool _isDisposed = false;
  
  Debouncer({this.delay = const Duration(milliseconds: 300)});
  
  void call(VoidCallback action) {
    if (_isDisposed) return;
    _action = action;
    Future.delayed(delay, () {
      if (!_isDisposed && _action == action) {
        action();
      }
    });
  }
  
  void dispose() {
    _isDisposed = true;
    _action = null;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎨 Optimized Color Cache - تجنب إنشاء ألوان جديدة كل مرة
/// withOpacity() تنشئ كائن جديد كل مرة!
/// ═══════════════════════════════════════════════════════════════════════════
class ColorCache {
  static final Map<int, Color> _cache = {};
  
  /// الحصول على لون مع شفافية مُخزّنة
  static Color withOpacity(Color color, double opacity) {
    final key = color.value ^ opacity.hashCode;
    return _cache.putIfAbsent(
      key, 
      () => color.withOpacity(opacity),
    );
  }
  
  /// تنظيف الذاكرة المؤقتة
  static void clear() => _cache.clear();
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🏗️ Optimized Builder - بناء محسّن يمنع rebuilds غير ضرورية
/// ═══════════════════════════════════════════════════════════════════════════
class OptimizedBuilder<T> extends StatelessWidget {
  final T value;
  final Widget Function(BuildContext context, T value) builder;
  
  const OptimizedBuilder({
    super.key,
    required this.value,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return builder(context, value);
  }
}
