import 'dart:convert';
import 'dart:developer';

import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:app/functions/functions.dart';
import 'package:app/functions/my_navigation.dart';
import 'package:app/models/user/CheckPhoneModel.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:app/network/services/profile_service.dart';
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

  String _apiMessage(Map<String, dynamic> data, String fallback) {
    final msg = data['msg'] ?? data['message'];
    if (msg is List) return msg.map((e) => e.toString()).join(', ');
    if (msg != null && msg.toString().trim().isNotEmpty) return msg.toString();
    return fallback;
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
    required String commercialRegistrationNumber,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required bool isVatRegistered,
    String? taxNumber,
    required String otp,
    String? email,
    required String buildingNumber,
    required String street,
    required String district,
    required String city,
    required String postalCode,
    String? additionalNumber,
    required String signerName,
    required String signerTitle,
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
          'commercial_registration_number': commercialRegistrationNumber,
          'phone_number': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'is_vat_registered': isVatRegistered ? '1' : '0',
          'otp': otp,
          if (taxNumber != null && taxNumber.trim().isNotEmpty)
            'tax_number': taxNumber.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          'building_number': buildingNumber,
          'street': street,
          'district': district,
          'city': city,
          'postal_code': postalCode,
          if (additionalNumber != null && additionalNumber.trim().isNotEmpty)
            'additional_number': additionalNumber.trim(),
          'signer_name': signerName,
          'signer_title': signerTitle,
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
    required PlatformFileLike signature,
    required PlatformFileLike stamp,
  }) async {
    try {
      DioHelper.init();
      final formData = FormData.fromMap({
        'phone_number': phone,
        'otp': otp,
        'is_vat_registered': isVatRegistered ? '1' : '0',
        'commercial_registration': await _toMultipart(commercialRegistration),
        'national_address': await _toMultipart(nationalAddress),
        'signature': await _toMultipart(signature),
        'stamp': await _toMultipart(stamp),
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

  Future<List<int>?> previewAgreementPdf({
    required Map<String, String> fields,
    required PlatformFileLike signature,
    required PlatformFileLike stamp,
  }) async {
    try {
      DioHelper.init();
      final formData = FormData.fromMap({
        ...fields,
        'signature': await _toMultipart(signature),
        'stamp': await _toMultipart(stamp),
      });
      final response = await DioHelper.post(
        path: EndPoints.registerAgreementPreview,
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      final raw = response.data;
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (raw is Uint8List) return raw;
        if (raw is List<int>) return List<int>.from(raw);
      }
      return null;
    } catch (e) {
      log('previewAgreementPdf error: $e');
      return null;
    }
  }

  Future<CheckPhoneModel?> checkPhone(String phone) async {
    DioHelper.init();
    final response = await DioHelper.post(
      path: EndPoints.checkPhone,
      data: {"phone_number": phone},
    );
    final responseMap = _asMap(response.data);
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return CheckPhoneModel.fromJson(responseMap);
    }
    log('checkPhone failed: ${response.statusCode} $responseMap');
    return null;
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
          'msg': _apiMessage(data, 'Failed to send OTP'),
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
        final body = _asMap(response.data);
        if (body['status'] == true || body['success'] == true) {
          return _persistSessionAndNavigate(
            context: context,
            responseData: body,
          );
        }
        if (context.mounted) {
          showMessage(
            context: context,
            message: _apiMessage(body, 'OTP invalid'),
            color: Colors.red,
          );
        }
        return false;
      }

      final body = _asMap(response.data);
      if (context.mounted) {
        showMessage(
          context: context,
          message: _apiMessage(body, 'OTP invalid'),
          color: Colors.red,
        );
      }
      return false;
    } catch (e) {
      log('loginWithOtp error: $e');
      if (context.mounted) {
        showMessage(context: context, message: e.toString(), color: Colors.red);
      }
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

    final token = '${payload['token'] ?? ''}';
    if (token.isEmpty) {
      if (context.mounted) {
        showMessage(
          context: context,
          message: _apiMessage(data, 'OTP invalid'),
          color: Colors.red,
        );
      }
      return false;
    }

    await CacheHelper.setString(
      key: 'access_token',
      value: token,
    );
    await CacheHelper.setBool(key: 'is_logged_in', value: true);
    await CacheHelper.setBool(key: 'biometric_app_lock_enabled', value: true);
    await CacheHelper.setString(
      key: 'last_app_activity_at',
      value: DateTime.now().toUtc().toIso8601String(),
    );

    ProfileCubit? profileCubit;
    if (context.mounted) {
      profileCubit = ProfileCubit.get(context);
    }

    DioHelper.init();
    try {
      final user = ProfileServices.parseUser(payload['user']);
      if (user != null && profileCubit != null) {
        profileCubit.setUser(user);
      }
    } catch (e) {
      log('hydrate profile from login: $e');
    }
    try {
      await profileCubit?.getProfile(forceRefresh: true);
    } catch (e) {
      log('getProfile after login: $e');
    }

    if (!context.mounted) return true;

    showMessage(
      context: context,
      message: data['msg']?.toString() ?? 'Logged in successfully',
      color: Colors.green,
    );
    MyNavigator.navigateOff(context, const LayoutScreen());
    return true;
  }
}
