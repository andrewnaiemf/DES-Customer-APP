import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// نظام معالجة الأخطاء للـ Live Tracking مع Exponential Backoff
/// Handles all tracking errors with retry logic and user-friendly messages
class TrackingErrorHandler {
  final Connectivity _connectivity = Connectivity();
  
  // Exponential Backoff Configuration
  static const int maxRetries = 5;
  static const Duration initialDelay = Duration(seconds: 2);
  static const Duration maxDelay = Duration(minutes: 2);
  static const double backoffMultiplier = 2.0;

  /// تنفيذ عملية مع إعادة المحاولة التلقائية
  /// Execute an operation with automatic retry and exponential backoff
  Future<T?> executeWithRetry<T>({
    required Future<T> Function() operation,
    required String operationName,
    int maxAttempts = maxRetries,
    Function(TrackingError)? onError,
    bool requiresConnectivity = true,
  }) async {
    int attempt = 0;
    Duration currentDelay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        attempt++;
        
        // Check connectivity before attempting if required
        if (requiresConnectivity) {
          final hasConnection = await _checkConnectivity();
          if (!hasConnection) {
            if (attempt == maxAttempts) {
              final error = TrackingError.noInternet();
              onError?.call(error);
              throw error;
            }
            
            // Wait for connection before retrying
            debugPrint('⚠️ No internet connection. Waiting before retry $attempt/$maxAttempts');
            await _waitForConnection(timeout: currentDelay);
            currentDelay = _calculateNextDelay(currentDelay);
            continue;
          }
        }

        // Execute the operation
        debugPrint('🔄 Executing $operationName (attempt $attempt/$maxAttempts)');
        final result = await operation();
        
        if (attempt > 1) {
          debugPrint('✅ $operationName succeeded after $attempt attempts');
        }
        
        return result;
        
      } catch (e, stackTrace) {
        final error = _classifyError(e, stackTrace, operationName);
        
        debugPrint('❌ Error in $operationName (attempt $attempt/$maxAttempts): ${error.message}');
        
        // If this was the last attempt or error is not retryable, fail
        if (attempt >= maxAttempts || !error.isRetryable) {
          debugPrint('🛑 Giving up on $operationName after $attempt attempts');
          onError?.call(error);
          
          if (error.isCritical) {
            throw error;
          }
          return null;
        }
        
        // Wait before retrying with exponential backoff
        debugPrint('⏳ Waiting ${currentDelay.inSeconds}s before retry...');
        await Future.delayed(currentDelay);
        currentDelay = _calculateNextDelay(currentDelay);
      }
    }
    
    return null;
  }

  /// حساب التأخير التالي باستخدام Exponential Backoff
  /// Calculate next delay using exponential backoff
  Duration _calculateNextDelay(Duration currentDelay) {
    final nextDelay = Duration(
      milliseconds: (currentDelay.inMilliseconds * backoffMultiplier).round(),
    );
    
    // Cap at max delay
    return nextDelay > maxDelay ? maxDelay : nextDelay;
  }

  /// فحص الاتصال بالإنترنت
  /// Check internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }
      
      // Double-check with actual internet access
      return await _hasInternetAccess();
    } catch (e) {
      debugPrint('⚠️ Connectivity check failed: $e');
      return false;
    }
  }

  /// التحقق من الوصول الفعلي للإنترنت
  /// Verify actual internet access
  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      debugPrint('⚠️ Internet access check failed: $e');
      return false;
    }
  }

  /// الانتظار حتى يعود الاتصال
  /// Wait for connection to be restored
  Future<void> _waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<void>();
    StreamSubscription? subscription;
    Timer? timeoutTimer;

    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription?.cancel();
        completer.complete();
      }
    });

    subscription = _connectivity.onConnectivityChanged.listen((results) async {
      if (!results.contains(ConnectivityResult.none)) {
        // Verify actual internet access
        final hasInternet = await _hasInternetAccess();
        if (hasInternet && !completer.isCompleted) {
          timeoutTimer?.cancel();
          subscription?.cancel();
          completer.complete();
        }
      }
    });

    await completer.future;
  }

  /// تصنيف الخطأ وتحويله إلى TrackingError
  /// Classify error and convert to TrackingError
  TrackingError _classifyError(dynamic error, StackTrace stackTrace, String operation) {
    // Network errors
    if (error is SocketException) {
      return TrackingError.network(
        message: 'فشل الاتصال بالخادم',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    if (error is TimeoutException) {
      return TrackingError.timeout(
        message: 'انتهت مهلة الاتصال',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Permission errors
    if (error.toString().contains('permission') || 
        error.toString().contains('authorized')) {
      return TrackingError.permission(
        message: 'لا توجد صلاحيات كافية',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Firebase errors
    if (error.toString().contains('firebase') || 
        error.toString().contains('firestore')) {
      return TrackingError.firebase(
        message: 'خطأ في قاعدة البيانات',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Platform errors (iOS/Android)
    if (error.toString().contains('PlatformException') ||
        error.toString().contains('MissingPluginException')) {
      return TrackingError.platform(
        message: 'خطأ في النظام',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Unknown errors
    return TrackingError.unknown(
      message: 'حدث خطأ غير متوقع',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// الحصول على رسالة خطأ واضحة للمستخدم
  /// Get user-friendly error message
  String getUserFriendlyMessage(TrackingError error) {
    switch (error.type) {
      case TrackingErrorType.noInternet:
        return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
      
      case TrackingErrorType.network:
        return 'فشل الاتصال بالخادم. يرجى المحاولة مرة أخرى.';
      
      case TrackingErrorType.timeout:
        return 'انتهت مهلة الاتصال. يرجى التحقق من سرعة الإنترنت.';
      
      case TrackingErrorType.permission:
        return 'لا توجد صلاحيات كافية. يرجى تفعيل الصلاحيات المطلوبة.';
      
      case TrackingErrorType.firebase:
        return 'حدث خطأ في قاعدة البيانات. يرجى المحاولة مرة أخرى.';
      
      case TrackingErrorType.platform:
        return 'حدث خطأ في النظام. يرجى إعادة تشغيل التطبيق.';
      
      case TrackingErrorType.orderNotFound:
        return 'الطلب غير موجود أو تم حذفه.';
      
      case TrackingErrorType.alreadyTracking:
        return 'يتم تتبع طلب آخر حالياً. يرجى إيقافه أولاً.';
      
      case TrackingErrorType.notTrackable:
        return 'لا يمكن تتبع هذا الطلب في الوقت الحالي.';
      
      case TrackingErrorType.unknown:
      default:
        return error.message ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    }
  }

  /// عرض رسالة الخطأ للمستخدم
  /// Show error message to user
  void showErrorToUser(BuildContext context, TrackingError error) {
    final message = getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: error.isCritical ? Colors.red : Colors.orange,
        duration: const Duration(seconds: 4),
        action: error.isRetryable
            ? SnackBarAction(
                label: 'إعادة المحاولة',
                textColor: Colors.white,
                onPressed: () {
                  // Retry will be handled by the calling code
                },
              )
            : null,
      ),
    );
  }
}

/// أنواع أخطاء التتبع
/// Tracking error types
enum TrackingErrorType {
  noInternet,
  network,
  timeout,
  permission,
  firebase,
  platform,
  orderNotFound,
  alreadyTracking,
  notTrackable,
  unknown,
}

/// خطأ التتبع مع معلومات كاملة
/// Tracking error with full details
class TrackingError implements Exception {
  final TrackingErrorType type;
  final String? message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final bool isRetryable;
  final bool isCritical;

  TrackingError({
    required this.type,
    this.message,
    this.originalError,
    this.stackTrace,
    this.isRetryable = true,
    this.isCritical = false,
  });

  // Factory constructors for common errors
  factory TrackingError.noInternet() => TrackingError(
        type: TrackingErrorType.noInternet,
        message: 'No internet connection',
        isRetryable: true,
        isCritical: false,
      );

  factory TrackingError.network({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      TrackingError(
        type: TrackingErrorType.network,
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
        isRetryable: true,
        isCritical: false,
      );

  factory TrackingError.timeout({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      TrackingError(
        type: TrackingErrorType.timeout,
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
        isRetryable: true,
        isCritical: false,
      );

  factory TrackingError.permission({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      TrackingError(
        type: TrackingErrorType.permission,
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
        isRetryable: false,
        isCritical: true,
      );

  factory TrackingError.firebase({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      TrackingError(
        type: TrackingErrorType.firebase,
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
        isRetryable: true,
        isCritical: false,
      );

  factory TrackingError.platform({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      TrackingError(
        type: TrackingErrorType.platform,
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
        isRetryable: false,
        isCritical: true,
      );

  factory TrackingError.orderNotFound() => TrackingError(
        type: TrackingErrorType.orderNotFound,
        message: 'Order not found',
        isRetryable: false,
        isCritical: false,
      );

  factory TrackingError.alreadyTracking() => TrackingError(
        type: TrackingErrorType.alreadyTracking,
        message: 'Already tracking another order',
        isRetryable: false,
        isCritical: false,
      );

  factory TrackingError.notTrackable() => TrackingError(
        type: TrackingErrorType.notTrackable,
        message: 'Order is not trackable',
        isRetryable: false,
        isCritical: false,
      );

  factory TrackingError.unknown({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      TrackingError(
        type: TrackingErrorType.unknown,
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
        isRetryable: true,
        isCritical: false,
      );

  @override
  String toString() {
    return 'TrackingError{type: $type, message: $message, isRetryable: $isRetryable, isCritical: $isCritical}';
  }
}
