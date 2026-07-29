import 'dart:convert';
import 'dart:developer';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:app/functions/functions.dart';
import 'package:app/functions/my_navigation.dart';
import 'package:app/models/user/CheckPhoneModel.dart';
import 'package:app/network/dio_helper.dart';
import 'package:app/persentation/screens/layout/layout_screen.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Minimal file shape so we can support web bytes + mobile paths.
class PlatformFileLike {
  final String name;
  final String? path;
  final List<int>? bytes;

  PlatformFileLike({
    required this.name,
    this.path,
    this.bytes,
  });
}

class AuthServices {
  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'status': false, 'msg': 'Invalid response'};
  }

  bool _isSuccess(Map<String, dynamic> data, int? statusCode) {
    final status = data['status'];
    final success = data['success'];
    final codeOk = statusCode != null && statusCode >= 200 && statusCode < 300;
    return codeOk && (status == true || success == true || status == 1);
  }

  Future<MultipartFile> _toMultipart(PlatformFileLike file) async {
    final name = file.name;
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      return MultipartFile.fromBytes(file.bytes!, filename: name);
    }
    if (!kIsWeb && file.path != null && file.path!.isNotEmpty) {
      return MultipartFile.fromFile(file.path!, filename: name);
    }
    throw Exception('File "$name" has no data. Please re-attach the document.');
  }

  /// Send register OTP via Laravel → Taqnyat SMS
  Future<Map<String, dynamic>?> sendRegisterOtp({required String phone}) async {
    try {
      DioHelper.init();
      final response = await DioHelper.post(
        path: EndPoints.registerSendOtp,
        data: {'phone_number': phone},
      );
      final data = _asMap(response.data);
      if (!_isSuccess(data, response.statusCode)) {
        return {
          'status': false,
          'msg': data['msg'] ?? data['message'] ?? 'Failed to send OTP',
        };
      }
      return data;
    } catch (e) {
      log('sendRegisterOtp error: $e');
      return {'status': false, 'msg': e.toString()};
    }
  }

  /// Verify register OTP via Laravel
  Future<Map<String, dynamic>?> verifyRegisterOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      DioHelper.init();
      final response = await DioHelper.post(
        path: EndPoints.registerVerifyOtp,
        data: {
          'phone_number': phone,
          'otp': otp,
        },
      );
      final data = _asMap(response.data);
      if (!_isSuccess(data, response.statusCode)) {
        return {
          'status': false,
          'msg': data['msg'] ?? data['message'] ?? 'OTP invalid or expired',
        };
      }
      return data;
    } catch (e) {
      log('verifyRegisterOtp error: $e');
      return {'status': false, 'msg': e.toString()};
    }
  }

  /// Fast register (no files) → local Laravel `/api/user/register`
  Future<Map<String, dynamic>?> registerCustomer({
    required String companyName,
    String? tradeName,
    required String managerName,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required bool isVatRegistered,
    String? taxNumber,
    required String otp,
    String? email,
  }) async {
    try {
      DioHelper.init();
      final response = await DioHelper.post(
        path: EndPoints.register,
        data: {
          'company_name': companyName,
          if (tradeName != null && tradeName.trim().isNotEmpty)
            'trade_name': tradeName.trim(),
          'manager_name': managerName,
          'phone_number': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'is_vat_registered': isVatRegistered ? '1' : '0',
          'otp': otp,
          if (taxNumber != null && taxNumber.trim().isNotEmpty)
            'tax_number': taxNumber.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          'locale': CacheHelper.getString(key: 'lang') ?? 'ar',
        },
      );
      final data = _asMap(response.data);
      if (_isSuccess(data, response.statusCode)) return data;
      return {
        'status': false,
        'msg': data['msg'] ?? data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      log('registerCustomer error: $e');
      return {'status': false, 'msg': e.toString()};
    }
  }

  /// Upload docs in background after fast register.
  Future<Map<String, dynamic>?> uploadRegisterDocuments({
    required String phone,
    required String otp,
    required bool isVatRegistered,
    required PlatformFileLike commercialRegistration,
    PlatformFileLike? taxDocument,
    required PlatformFileLike nationalAddress,
  }) async {
    try {
      DioHelper.init();
      final formData = FormData.fromMap({
        'phone_number': phone,
        'otp': otp,
        'is_vat_registered': isVatRegistered ? '1' : '0',
        'commercial_registration': await _toMultipart(commercialRegistration),
        'national_address': await _toMultipart(nationalAddress),
        if (taxDocument != null) 'tax_document': await _toMultipart(taxDocument),
      });

      final response = await DioHelper.post(
        path: EndPoints.registerDocuments,
        data: formData,
      );
      final data = _asMap(response.data);
      if (_isSuccess(data, response.statusCode)) return data;
      return {
        'status': false,
        'msg': data['msg'] ?? data['message'] ?? 'Documents upload failed',
      };
    } catch (e) {
      log('uploadRegisterDocuments error: $e');
      return {'status': false, 'msg': e.toString()};
    }
  }

  Future<CheckPhoneModel?> checkPhone(String phone) async {
    final response = await DioHelper.post(
      path: EndPoints.checkPhone,
      data: {"phone_number": phone},
    );
    var responseMap = jsonDecode(response.toString());
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      print(response.toString());
      print("checkPhone statusCode 200");
      return CheckPhoneModel.fromJson(responseMap);
    } else {
      print(response.toString());
      print("Failed to checkPhone.");
      return null;
    }
  }

  Future<bool?> login({
    required BuildContext context,
    required String phone,
    required String password,
  }) async {
    String? token;
    if (!kIsWeb) {
      try {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        token = await messaging.getToken();
      } catch (e) {
        print('Failed to get FCM token: $e');
        token = null;
      }
    }
    final bool isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final response = await DioHelper.post(
      path: EndPoints.login,
      data: {
        "phone_number": phone,
        "password": password,
        "device_token": token ?? "",
        "locale": "${CacheHelper.getString(key: "lang") ?? "ar"}",
        "is_android": isAndroid ? 1 : 0
      },
    );
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return _persistSessionAndNavigate(
        context: context,
        responseData: response.data,
      );
    } else {
      print(response.toString());
      showMessage(
        context: context,
        message: response.data["msg"]?.toString() ?? 'Failed to login',
        color: Colors.red,
      );
      print("Failed to login.");
      return false;
    }
  }

  /// Send login OTP (first login or after 3 months inactivity).
  Future<Map<String, dynamic>?> sendLoginOtp({required String phone}) async {
    try {
      DioHelper.init();
      final response = await DioHelper.post(
        path: EndPoints.loginOtpSend,
        data: {'phone_number': phone},
      );
      final data = _asMap(response.data);
      if (!_isSuccess(data, response.statusCode)) {
        return {
          'status': false,
          'msg': data['msg'] ?? data['message'] ?? 'Failed to send OTP',
          'code': response.statusCode,
        };
      }
      return data;
    } catch (e) {
      log('sendLoginOtp error: $e');
      return {'status': false, 'msg': e.toString()};
    }
  }

  /// Verify login OTP and create session (JWT).
  Future<bool?> loginWithOtp({
    required BuildContext context,
    required String phone,
    required String otp,
  }) async {
    try {
      String? token;
      if (!kIsWeb) {
        try {
          token = await FirebaseMessaging.instance.getToken();
        } catch (_) {
          token = null;
        }
      }
      final bool isAndroid =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

      DioHelper.init();
      final response = await DioHelper.post(
        path: EndPoints.loginOtpVerify,
        data: {
          'phone_number': phone,
          'otp': otp,
          'device_token': token ?? '',
          'locale': CacheHelper.getString(key: 'lang') ?? 'ar',
          'is_android': isAndroid ? 1 : 0,
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return _persistSessionAndNavigate(
          context: context,
          responseData: response.data,
        );
      }

      showMessage(
        context: context,
        message: response.data['msg']?.toString() ?? 'OTP invalid',
        color: Colors.red,
      );
      return false;
    } catch (e) {
      log('loginWithOtp error: $e');
      showMessage(context: context, message: e.toString(), color: Colors.red);
      return false;
    }
  }

  Future<bool> _persistSessionAndNavigate({
    required BuildContext context,
    required dynamic responseData,
  }) async {
    final data = _asMap(responseData);
    final payload = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : <String, dynamic>{};

    await CacheHelper.setString(
      key: 'access_token',
      value: '${payload['token'] ?? ''}',
    );
    await CacheHelper.setBool(key: 'is_logged_in', value: true);
    await CacheHelper.setBool(key: 'biometric_app_lock_enabled', value: true);
    await CacheHelper.setString(
      key: 'last_app_activity_at',
      value: DateTime.now().toUtc().toIso8601String(),
    );

    DioHelper.init();
    // ignore: use_build_context_synchronously
    MyNavigator.navigateOff(context, const LayoutScreen());
    // ignore: use_build_context_synchronously
    showMessage(
      context: context,
      message: data['msg']?.toString() ?? 'Logged in successfully',
      color: Colors.green,
    );
    return true;
  }
}
