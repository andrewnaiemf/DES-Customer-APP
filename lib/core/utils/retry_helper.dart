// ═══════════════════════════════════════════════════════════════════════════
// 🔄 Retry Helper
// ═══════════════════════════════════════════════════════════════════════════
// Helper للـ Retry مع Exponential Backoff
// يستخدم لإعادة المحاولة عند فشل العمليات
//
// Path: lib/core/utils/retry_helper.dart
// Created: February 9, 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Helper للـ Retry مع Exponential Backoff
class RetryHelper {
  RetryHelper._(); // Private constructor
  
  // ═══════════════════════════════════════════════════════════════════════
  // Retry with Exponential Backoff
  // ═══════════════════════════════════════════════════════════════════════
  
  /// تنفيذ عملية مع إعادة المحاولة
  /// 
  /// Example:
  /// ```dart
  /// final result = await RetryHelper.retry(
  ///   operation: () => sendNotification(),
  ///   maxRetries: 3,
  ///   initialDelay: Duration(seconds: 1),
  /// );
  /// ```
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    Duration? maxDelay,
    bool Function(Exception)? shouldRetry,
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (true) {
      try {
        attempt++;
        _log('🔄 Attempt $attempt of $maxRetries');
        
        return await operation();
        
      } catch (e) {
        // التحقق من نوع الخطأ
        if (e is! Exception) {
          _log('❌ Non-exception error, rethrowing: $e');
          rethrow;
        }
        
        // التحقق من إمكانية إعادة المحاولة
        final shouldRetryError = shouldRetry?.call(e) ?? true;
        
        // التحقق من الوصول للحد الأقصى
        if (attempt >= maxRetries || !shouldRetryError) {
          _log('❌ Max retries reached or should not retry');
          _log('   - Attempts: $attempt/$maxRetries');
          _log('   - Should retry: $shouldRetryError');
          rethrow;
        }
        
        // إخطار عن إعادة المحاولة
        onRetry?.call(attempt, e);
        
        _log('⚠️ Retry attempt $attempt failed: ${e.toString()}');
        _log('⏳ Retrying in ${delay.inSeconds}s...');
        
        // الانتظار
        await Future.delayed(delay);
        
        // زيادة التأخير (Exponential Backoff)
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).toInt(),
        );
        
        // تحديد الحد الأقصى للتأخير
        if (maxDelay != null && delay > maxDelay) {
          delay = maxDelay;
        }
      }
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Retry with Timeout
  // ═══════════════════════════════════════════════════════════════════════
  
  /// تنفيذ عملية مع timeout
  /// 
  /// Example:
  /// ```dart
  /// final result = await RetryHelper.withTimeout(
  ///   operation: () => fetchData(),
  ///   timeout: Duration(seconds: 30),
  /// );
  /// ```
  static Future<T> withTimeout<T>({
    required Future<T> Function() operation,
    Duration timeout = const Duration(seconds: 30),
    T Function()? onTimeout,
  }) async {
    try {
      _log('⏱️ Starting operation with ${timeout.inSeconds}s timeout');
      return await operation().timeout(timeout);
      
    } on TimeoutException {
      _log('⏱️ Operation timed out after ${timeout.inSeconds}s');
      
      if (onTimeout != null) {
        return onTimeout();
      }
      rethrow;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Retry with Timeout (Combined)
  // ═══════════════════════════════════════════════════════════════════════
  
  /// تنفيذ عملية مع retry و timeout
  /// 
  /// Example:
  /// ```dart
  /// final result = await RetryHelper.retryWithTimeout(
  ///   operation: () => apiCall(),
  ///   maxRetries: 3,
  ///   timeout: Duration(seconds: 10),
  /// );
  /// ```
  static Future<T> retryWithTimeout<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 10),
    Duration initialDelay = const Duration(seconds: 1),
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    _log('🔄 Starting retry with timeout');
    _log('   - Max retries: $maxRetries');
    _log('   - Timeout: ${timeout.inSeconds}s');
    
    return retry(
      operation: () => withTimeout(
        operation: operation,
        timeout: timeout,
      ),
      maxRetries: maxRetries,
      initialDelay: initialDelay,
      onRetry: onRetry,
    );
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Retry with Jitter (لتجنب Thundering Herd)
  // ═══════════════════════════════════════════════════════════════════════
  
  /// تنفيذ عملية مع retry و jitter
  /// Jitter يضيف عشوائية للتأخير لتجنب تزامن عدة محاولات
  /// 
  /// Example:
  /// ```dart
  /// final result = await RetryHelper.retryWithJitter(
  ///   operation: () => sendRequest(),
  ///   maxRetries: 3,
  /// );
  /// ```
  static Future<T> retryWithJitter<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    double jitterFactor = 0.3, // 30% jitter
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    int attempt = 0;
    Duration baseDelay = initialDelay;
    
    while (true) {
      try {
        attempt++;
        return await operation();
        
      } catch (e) {
        if (e is! Exception || attempt >= maxRetries) rethrow;
        
        onRetry?.call(attempt, e);
        
        // حساب التأخير مع Jitter
        final jitterMs = (baseDelay.inMilliseconds * jitterFactor).toInt();
        final randomJitter = (DateTime.now().microsecond % jitterMs).toInt();
        final delayWithJitter = Duration(
          milliseconds: baseDelay.inMilliseconds + randomJitter,
        );
        
        _log('⚠️ Retry $attempt failed, waiting ${delayWithJitter.inMilliseconds}ms (with jitter)');
        
        await Future.delayed(delayWithJitter);
        
        baseDelay = Duration(
          milliseconds: (baseDelay.inMilliseconds * backoffMultiplier).toInt(),
        );
      }
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Circuit Breaker Pattern
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Circuit Breaker state
  static final Map<String, _CircuitBreakerState> _circuitBreakers = {};
  
  /// تنفيذ عملية مع Circuit Breaker
  /// يمنع المحاولات المتكررة إذا كان النظام يفشل باستمرار
  /// 
  /// Example:
  /// ```dart
  /// final result = await RetryHelper.withCircuitBreaker(
  ///   key: 'api_endpoint',
  ///   operation: () => callApi(),
  ///   failureThreshold: 5,
  ///   resetTimeout: Duration(minutes: 1),
  /// );
  /// ```
  static Future<T> withCircuitBreaker<T>({
    required String key,
    required Future<T> Function() operation,
    int failureThreshold = 5,
    Duration resetTimeout = const Duration(minutes: 1),
  }) async {
    // الحصول على أو إنشاء Circuit Breaker
    final breaker = _circuitBreakers.putIfAbsent(
      key,
      () => _CircuitBreakerState(failureThreshold, resetTimeout),
    );
    
    // التحقق من حالة الـ Circuit
    if (breaker.isOpen) {
      if (breaker.shouldAttemptReset) {
        _log('🔄 Circuit breaker half-open, attempting reset');
        breaker.halfOpen();
      } else {
        _log('⛔ Circuit breaker is OPEN, rejecting operation');
        throw Exception('Circuit breaker is open for: $key');
      }
    }
    
    try {
      final result = await operation();
      breaker.recordSuccess();
      return result;
      
    } catch (e) {
      breaker.recordFailure();
      _log('❌ Circuit breaker recorded failure ($key)');
      _log('   - Failures: ${breaker.failureCount}/${breaker.threshold}');
      rethrow;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // Utility
  // ═══════════════════════════════════════════════════════════════════════
  
  static void _log(String message) {
    final formattedMessage = '[RetryHelper] $message';
    dev.log(formattedMessage);
    if (kDebugMode) {
      debugPrint(formattedMessage);
    }
  }
  
  /// إعادة تعيين Circuit Breaker
  static void resetCircuitBreaker(String key) {
    _circuitBreakers.remove(key);
    _log('🔄 Circuit breaker reset: $key');
  }
  
  /// إعادة تعيين جميع Circuit Breakers
  static void resetAllCircuitBreakers() {
    _circuitBreakers.clear();
    _log('🔄 All circuit breakers reset');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Circuit Breaker State
// ═══════════════════════════════════════════════════════════════════════════

class _CircuitBreakerState {
  final int threshold;
  final Duration resetTimeout;
  
  int failureCount = 0;
  DateTime? lastFailureTime;
  bool _isOpen = false;
  
  _CircuitBreakerState(this.threshold, this.resetTimeout);
  
  bool get isOpen => _isOpen;
  
  bool get shouldAttemptReset {
    if (!_isOpen || lastFailureTime == null) return false;
    return DateTime.now().difference(lastFailureTime!) > resetTimeout;
  }
  
  void recordSuccess() {
    failureCount = 0;
    _isOpen = false;
    lastFailureTime = null;
  }
  
  void recordFailure() {
    failureCount++;
    lastFailureTime = DateTime.now();
    
    if (failureCount >= threshold) {
      _isOpen = true;
    }
  }
  
  void halfOpen() {
    _isOpen = false;
  }
}
