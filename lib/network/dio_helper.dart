import 'dart:developer';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Debug Logger - يطبع فقط في وضع Debug
// ═══════════════════════════════════════════════════════════════════════════
void _debugLog(String message) {
  if (kDebugMode) {
    log(message);
  }
}

class DioHelper {
  static Dio dio = Dio();

  static init() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseURL,
      connectTimeout: const Duration(seconds: 30), // ⏱️ انتظار الاتصال 30 ثانية
      receiveTimeout: const Duration(seconds: 30), // ⏱️ انتظار الاستقبال 30 ثانية
      sendTimeout: const Duration(minutes: 2),
      validateStatus: (statusCode) {
        // if (statusCode == 422) {
        //   return true;
        // }
        // if (statusCode == 200) {
        //   return true;
        // }
        // if (statusCode == 400) {
        //   return true;
        // }
        // if (statusCode == 428) {
        //   return true;
        // }
        return true;
      },
      headers: CacheHelper.getString(key: "access_token") == null
          ? null
          : {
            'Authorization': CacheHelper.getString(key: "access_token") == null ? null : 'Bearer ${CacheHelper.getString(key: "access_token")}',
            "locale": CacheHelper.getString(key: "lang")?? "ar"
            },
    );
  }

  static Future<Response> post({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    _debugLog('🔷 DioHelper POST: ${dio.options.baseUrl}$path');
    _debugLog('🔷 DioHelper Token: ${CacheHelper.getString(key: "access_token")}');

    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      // Keep caller options (needed for multipart FormData on web).
      options: options ?? Options(),
    ).then((response) {
      _debugLog('✅ POST $path: ${response.statusCode}');
      return response;
    }).catchError((error) {
      _debugLog('❌ POST $path Error: $error');
      throw error;
    });
  }

  static Future<Response> put({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(),
    );
  }

  static Future<Response> delete({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(),
    );
  }

  static Future<Response> get({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
  Options? options
  }) async {
    _debugLog('🔷 DioHelper GET: ${dio.options.baseUrl}$path');
    _debugLog('🔷 DioHelper Token: ${CacheHelper.getString(key: "access_token")}');

    try {
      final response = await dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      _debugLog('✅ GET $path: ${response.statusCode}');
      return response;
      
    } on DioException catch (e) {
      _debugLog('❌ GET $path DioException: ${e.type} - ${e.message}');
      rethrow;
    } catch (e) {
      _debugLog('❌ GET $path Error: $e');
      rethrow;
    }
  }
}


class DioHelperV2 {
  static Dio dio = Dio();

  static init() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseURL2,
      connectTimeout: const Duration(seconds: 30), // ⏱️ إضافة timeout للاتصال
      receiveTimeout: const Duration(seconds: 30), // ⏱️ إضافة timeout للاستقبال
      sendTimeout: const Duration(minutes: 2),
      validateStatus: (statusCode) => true,
      headers: CacheHelper.getString(key: "access_token") == null
          ? null
          : {
        'Authorization': 'Bearer ${CacheHelper.getString(key: "access_token")}',
        "locale": CacheHelper.getString(key: "lang") ?? "ar",
      },
    );
  }

  static Future<Response> post({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(),
    );
  }

  static Future<Response> put({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(),
    );
  }

  static Future<Response> delete({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(),
    );
  }

  static Future<Response> get({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌍 DioHelperPublic - For public/external API calls without authentication
// ═══════════════════════════════════════════════════════════════════════════
class DioHelperPublic {
  static Dio dio = Dio();

  static init() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseURL,
      sendTimeout: const Duration(minutes: 2),
      validateStatus: (statusCode) => true,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'locale': CacheHelper.getString(key: "lang") ?? "ar",
      },
    );
  }

  static Future<Response> post({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    _debugLog('🌍 DioHelperPublic POST: ${dio.options.baseUrl}$path');
    
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(),
    ).then((response) {
      _debugLog('✅ Public POST $path: ${response.statusCode}');
      return response;
    }).catchError((error) {
      _debugLog('❌ Public POST $path Error: $error');
      throw error;
    });
  }

  static Future<Response> get({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    _debugLog('🌍 DioHelperPublic GET: ${dio.options.baseUrl}$path');
    
    return dio.get(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(),
    ).then((response) {
      _debugLog('✅ Public GET $path: ${response.statusCode}');
      return response;
    }).catchError((error) {
      _debugLog('❌ Public GET $path Error: $error');
      throw error;
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🛡️ DioHelperWarranty - For Warranty API calls WITH Bearer Token
// ═══════════════════════════════════════════════════════════════════════════
class DioHelperWarranty {
  static Dio dio = Dio();

  static init() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.warrantyBaseURL,
      sendTimeout: const Duration(minutes: 2),
      validateStatus: (statusCode) => true,
      headers: CacheHelper.getString(key: "access_token") == null
          ? {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'locale': CacheHelper.getString(key: "lang") ?? "ar",
            }
          : {
              'Authorization': 'Bearer ${CacheHelper.getString(key: "access_token")}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'locale': CacheHelper.getString(key: "lang") ?? "ar",
            },
    );
  }

  static Future<Response> post({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    _debugLog('🛡️ DioHelperWarranty POST: ${dio.options.baseUrl}$path');
    
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(),
    ).then((response) {
      _debugLog('✅ Warranty POST $path: ${response.statusCode}');
      return response;
    }).catchError((error) {
      _debugLog('❌ Warranty POST $path Error: $error');
      throw error;
    });
  }

  static Future<Response> get({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    _debugLog('🛡️ DioHelperWarranty GET: ${dio.options.baseUrl}$path');
    
    return dio.get(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(),
    ).then((response) {
      _debugLog('✅ Warranty GET $path: ${response.statusCode}');
      return response;
    }).catchError((error) {
      _debugLog('❌ Warranty GET $path Error: $error');
      throw error;
    });
  }
}
