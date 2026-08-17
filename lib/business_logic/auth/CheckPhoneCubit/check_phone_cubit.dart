import 'dart:developer';

import 'package:app/helpers/cache_helper.dart';
import 'package:app/functions/functions.dart';
import 'package:app/functions/my_navigation.dart';
import 'package:app/models/user/CheckPhoneModel.dart';
import 'package:app/network/dio_helper.dart';
import 'package:app/network/services/auth_services.dart';
import 'package:app/persentation/screens/auth/reset_change_password_screen.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../data/constants/api_constants.dart';
import '../../../models/country_code.dart';

part 'check_phone_state.dart';

class CheckPhoneCubit extends Cubit<CheckPhoneState> {
  final _secureStorage = const FlutterSecureStorage();

  CheckPhoneCubit() : super(CheckPhoneInitial());
  AuthServices authServices = AuthServices();
  bool showOTP = false;
  bool showPassword = false;
  /// true = login OTP (issue JWT). false = password-reset OTP (set password).
  bool isLoginOtpFlow = false;
  bool canUseBiometric = false;
  String myVerificationId = "NULL";
  CountryCode selectedCounty = countryCodesList.firstWhere(
    (country) => country.code == "+966",
    orElse: () => countryCodesList.first,
  );

  void changeCountryCode(CountryCode code) {
    selectedCounty = code;
    emit(CountryCodeChanged());
  }

  static CheckPhoneCubit get(BuildContext context) => BlocProvider.of(context);

  CheckPhoneModel? checkPhone({
    required BuildContext context,
    required String phone,
  }) {
    try {
      emit(CheckPhoneLoading());
      authServices.checkPhone(phone).then((value) async {
        if (value == null || value.data == null) {
          showMessage(
            context: context,
            message: value?.msg ?? "The selected phone number is invalid".tr(),
            color: MyColors.redColor,
          );
          emit(CheckPhoneError());
          return;
        }

        final data = value.data!;
        canUseBiometric = data.canUseBiometric == true;
        final requiresOtp = data.requiresOtp == true;
        final hasPassword = data.isVerified == true;

        // First login OR inactive 3+ months → OTP login (no password).
        if (requiresOtp) {
          showPassword = false;
          await _sendLoginOtp(context: context, phone: phone);
          showMessage(
            context: context,
            message: value.msg ??
                (data.isFirstLogin == true
                    ? 'Please verify OTP to complete first login'
                    : 'Please verify OTP after 3 months of inactivity'),
            color: MyColors.green,
          );
          return;
        }

        // Active user with password → password / biometric path.
        if (hasPassword) {
          showPassword = true;
          showOTP = false;
          isLoginOtpFlow = false;
          emit(CheckPhoneLoaded());
          showMessage(
            context: context,
            message: value.msg ?? '',
            color: MyColors.green,
          );
          return;
        }

        // No password yet → legacy password-reset OTP to set password.
        isLoginOtpFlow = false;
        await _sendPasswordResetOtp(context: context, phone: phone);
        showMessage(
          context: context,
          message: value.msg ?? '',
          color: MyColors.green,
        );
      }).catchError((e) {
        log('checkPhone error: $e');
        showMessage(
          context: context,
          message: e.toString(),
          color: MyColors.redColor,
        );
        emit(CheckPhoneError());
      });
    } catch (e) {
      emit(CheckPhoneError());
    }
    return null;
  }

  Future<void> _sendLoginOtp({
    required BuildContext context,
    required String phone,
  }) async {
    try {
      final result = await authServices.sendLoginOtp(phone: phone);
      final ok = result != null && result['status'] == true;
      if (ok) {
        showPassword = false;
        showOTP = true;
        isLoginOtpFlow = true;
        myVerificationId = 'login';
        emit(CheckPhoneLoaded());
        final debugOtp = result['data'] is Map
            ? (result['data'] as Map)['debug_otp']?.toString()
            : null;
        if (debugOtp != null && debugOtp.isNotEmpty) {
          showMessage(
            context: context,
            message: 'OTP (test): $debugOtp',
            color: MyColors.green,
          );
        }
        log('Login OTP sent');
      } else {
        // Test mode: still show OTP so the code from DB can be entered.
        showPassword = false;
        showOTP = true;
        isLoginOtpFlow = true;
        myVerificationId = 'login';
        emit(CheckPhoneLoaded());
        log('Login OTP send failed, OTP screen shown for DB code');
      }
    } catch (e) {
      log(e.toString());
      showMessage(context: context, message: e.toString(), color: Colors.red);
      emit(CheckPhoneError());
    }
  }

  Future<void> _sendPasswordResetOtp({
    required BuildContext context,
    required String phone,
  }) async {
    try {
      DioHelperV2.init();
      final response = await DioHelperV2.post(
        path: EndPoints.sendOtp,
        data: {
          'role': 'customer',
          'phone': phone,
        },
      );
      final ok = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          (response.data['success'] == true ||
              response.data['status'] == true);
      if (ok) {
        showPassword = false;
        showOTP = true;
        isLoginOtpFlow = false;
        myVerificationId = 'backend';
        emit(CheckPhoneLoaded());
        log('Password-reset OTP sent');
      } else {
        showMessage(
          context: context,
          message: (response.data['message'] ??
                  response.data['msg'] ??
                  'Code Not Sent')
              .toString(),
          color: MyColors.redColor,
        );
        emit(CheckPhoneError());
      }
    } catch (e) {
      log(e.toString());
      showMessage(context: context, message: e.toString(), color: Colors.red);
      emit(CheckPhoneError());
    }
  }

  bool? login({
    required BuildContext context,
    required String phone,
    required String password,
  }) {
    try {
      CacheHelper.init();
      emit(CheckPhoneLoading());
      authServices
          .login(context: context, phone: phone, password: password)
          .then((value) async {
        if (value == true) {
          showOTP = false;
          showPassword = false;
          await _secureStorage.write(key: 'phone', value: phone);
          await _secureStorage.write(key: 'password', value: password);
          await CacheHelper.setBool(key: 'can_use_biometric', value: true);
          log('Saved phone/password for biometric');
          emit(CheckPhoneLoaded());
        } else {
          emit(CheckPhoneError());
        }
      }).catchError((e) {
        log('login error: $e');
        showMessage(
          context: context,
          message: e.toString(),
          color: MyColors.redColor,
        );
        emit(CheckPhoneError());
      });
    } catch (e) {
      emit(CheckPhoneError());
    }
    return null;
  }

  void verifyOtp({
    required BuildContext context,
    required String code,
    required String phone,
  }) async {
    try {
      emit(CheckPhoneLoading());

      // Login OTP → issue JWT and enter app.
      if (isLoginOtpFlow) {
        final ok = await authServices.loginWithOtp(
          context: context,
          phone: phone,
          otp: code,
        );
        if (ok == true) {
          showOTP = false;
          showPassword = false;
          isLoginOtpFlow = false;
          await _secureStorage.write(key: 'phone', value: phone);
          // Keep existing password in secure storage if any (for later biometric).
          await CacheHelper.setBool(key: 'can_use_biometric', value: true);
          emit(CheckPhoneLoaded());
        } else {
          emit(CheckPhoneError());
        }
        return;
      }

      // Password-reset OTP → set password screen.
      DioHelperV2.init();
      final response = await DioHelperV2.post(
        path: EndPoints.verifyOtp,
        data: {
          'role': 'customer',
          'phone': phone,
          'otp': code,
        },
      );
      final ok = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          (response.data['success'] == true ||
              response.data['status'] == true);
      if (ok) {
        showOTP = false;
        MyNavigator.navigateTo(
          context,
          ResetChangePasswordScreen(phone: phone),
        );
        emit(CheckPhoneLoaded());
      } else {
        showMessage(
          context: context,
          message: (response.data['message'] ??
                  response.data['msg'] ??
                  'Code Not Correct')
              .toString(),
          color: MyColors.redColor,
        );
        emit(CheckPhoneError());
      }
    } catch (e) {
      log(e.toString());
      showMessage(
        context: context,
        message: e.toString(),
        color: Colors.red,
      );
      emit(CheckPhoneError());
    }
  }

  void iniAuthScreen() {
    emit(CheckPhoneLoading());
    showOTP = false;
    showPassword = false;
    isLoginOtpFlow = false;
    canUseBiometric = false;
    emit(CheckPhoneLoaded());
  }
}
