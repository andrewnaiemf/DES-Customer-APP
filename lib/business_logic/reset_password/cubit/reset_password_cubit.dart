import 'dart:developer';

import 'package:app/network/services/profile_service.dart';
import 'package:app/persentation/screens/auth/login_screen.dart';
import 'package:app/persentation/screens/auth/pin_code_screen.dart';
import 'package:app/persentation/screens/auth/reset_change_password_screen.dart';
import 'package:app/persentation/screens/profile/change_password_screen.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/constants/api_constants.dart';
import '../../../data/constants/constants.dart';
import '../../../functions/functions.dart';
import '../../../functions/my_navigation.dart';
import '../../../functions/otp_helpers/generate_otp.dart';
import '../../../functions/otp_helpers/unimtx_sms_helpers.dart';
import '../../../models/user/user_model.dart';
import '../../../network/dio_helper.dart';
import '../../../theme/colors.dart';
import '../../../functions/otp_helpers/twilio_sms_helper.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordInitial());

  static ResetPasswordCubit get(BuildContext context) => BlocProvider.of(context);

  bool isCodeSent = false;
  bool isLoading = false;
  String myVerificationId =  "NULL";

  bool isPasswordVisible = true;
  bool isConfirmPasswordVisible = true;
  void showPassword1() {
    isPasswordVisible = !isPasswordVisible;
    emit(ShowPasswordState());
  }

  void showPassword2() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    emit(ShowPasswordState());
  }
  Future<void> sendOTPMessage({
    required BuildContext context,
    required String phone,
  }) async {
    print("Sending OTP to: $phone");
    isLoading = true;
    emit(ResetPasswordLoading());

    try {
      final response = await DioHelperV2.post(
        path: EndPoints.sendOtp,
        data: {
          "role": "customer",
          "phone": phone,
        },
      );

      print("phone  ${phone}");
      print("response.data  ${response.data}");
      if (response.statusCode == 200) {
        isLoading = false;
        isCodeSent = true;
        emit(ResetPasswordSuccess());

        // Navigate
        MyNavigator.navigateOff(context, PinCodeScreen(phone: phone));

        // Show message
        showMessage(
          context: context,
          message: response.data["message"],
          color: Colors.green,
        );

      } else {
        isLoading = false;
        emit(ResetPasswordError());
        showMessage(
          context: context,
          message: response.data["message"].toString(),
          color: MyColors.redColor,
        );
      }
    } catch (e) {
      isLoading = false;
      emit(ResetPasswordError());
      print("SendOTP Error: $e");
      showMessage(
        context: context,
        message: e.toString(),
        color: Colors.red,
      );
    }
  }


  Future<void> confirmPhoneNumberAndResetPassword({
    required BuildContext context,
    required String code,
    required String phone,
  }) async {
    print("Confirming OTP for phone: $phone | code: $code");
    isLoading = true;
    emit(ResetPasswordLoading());

    try {
      final response = await DioHelperV2.post(
        path: EndPoints.verifyOtp,
        data: {
          "role": "customer",
          "phone": phone,
          "otp": code,
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        isCodeSent = false;
        emit(ResetPasswordSuccess());
        MyNavigator.navigateTo(context, ResetChangePasswordScreen(phone: phone));

        showMessage(
          context: context,
          message: response.data["message"],
          color: Colors.green,
        );
      } else {
        isLoading = false;
        emit(ResetPasswordError());

        showMessage(
          context: context,
          message: response.data["message"].toString(),
          color: MyColors.redColor,
        );
      }
    } catch (e) {
      isLoading = false;
      emit(ResetPasswordError());
      print("Confirm OTP Error: $e");

      showMessage(
        context: context,
        message: "حدث خطأ أثناء التحقق من الكود",
        color: Colors.red,
      );
    }
  }
  // Future<void> sendOTPMessage({
  //   required BuildContext context,
  //   required String phone,
  // }) async {
  //   print("phonephonephonephone$phone");
  //   isLoading = true;
  //   emit(ResetPasswordLoading());
  //   // try{
  //     String code=generateOtp();
  //     print("phone $phone");  ///541138239
  //     print("Code $code");
  //
  //     // var result=await TwilioSmsHelper.sendOtpWithTemplate(toNumber: phone, code: code);
  //     Response response = await DioHelperV2.post(
  //       path: EndPoints.sendOtp,
  //       data: {
  //         "role": "customer",
  //         "phone": phone,
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //      // ignore: use_build_context_synchronously
  //       MyNavigator.navigateOff(context, PinCodeScreen(phone: phone));
  //       isCodeSent = true;
  //       // ignore: use_build_context_synchronously
  //       showMessage(
  //         context: context,
  //         message: response.data["msg"],
  //         color: Colors.green,
  //       );
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       showMessage(
  //         context: context,
  //         message: response.data["msg"].toString(),
  //         color: MyColors.redColor,
  //       );
  //     }
  //     // if(result?.statusCode==201 || result?.statusCode==200){
  //     //   myVerificationId = code;
  //     //   isLoading = false;
  //     //
  //     //   emit(ResetPasswordSuccess());
  //     //   MyNavigator.navigateOff(context, PinCodeScreen(phone: phone));
  //     //   isCodeSent = true;
  //     //   log("Code Sent");
  //     // }
  //     // else
  //     // {
  //     //   showMessage(
  //     //     context: context,
  //     //     message: "Code Not Sent",
  //     //     color: MyColors.redColor,
  //     //   );
  //     //   isLoading = false;
  //     //   emit(ResetPasswordSuccess());
  //     // }
  //   // }
  //   // catch(e){
  //   //   log(e.toString());
  //   //   showMessage(
  //   //     context: context,
  //   //     message: e.toString(),
  //   //     color: Colors.red,
  //   //   );
  //   //   isLoading = false;
  //   //   emit(ResetPasswordSuccess());
  //   // }
  //
  //   /*await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     // phoneNumber: '+201033561845',
  //     phoneNumber: phone,
  //     verificationCompleted: verificationCompleted,
  //     verificationFailed: (FirebaseAuthException e) {
  //       showMessage(context: context, message: e.code);
  //       if (e.code == 'invalid-phone-number') {
  //         showMessage(
  //           context: context,
  //           message: "Phone number is incorrect".tr(),
  //           color: MyColors.redColor,
  //         );
  //       } else if (e.code == 'invalid-verification-code') {
  //         showMessage(
  //           context: context,
  //           message: "The confirmation code is incorrect".tr(),
  //           color: MyColors.redColor,
  //         );
  //       } else if (e.code == 'missing-client-identifier') {
  //         showMessage(
  //           context: context,
  //           message: "Unkown error".tr(),
  //           color: MyColors.redColor,
  //         );
  //       } else {
  //         log(e.toString());
  //         showMessage(
  //           context: context,
  //           message: e.toString(),
  //           color: Colors.red,
  //         );
  //       }
  //       isLoading = false;
  //       emit(ResetPasswordSuccess());
  //     },
  //     timeout: const Duration(seconds: 60),
  //     codeSent: (String verificationId, int? resendToken) {
  //       myVerificationId = verificationId;
  //       isLoading = false;
  //
  //       emit(ResetPasswordSuccess());
  //       MyNavigator.navigateOff(context, PinCodeScreen(phone: phone));
  //       isCodeSent = true;
  //       log("Code Sent");
  //     },
  //     codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
  //   );*/
  // }

  void codeAutoRetrievalTimeout(String verificationId) async {
    log("CodeAutoRetrievalTimeout");
  }

  // void verificationCompleted(PhoneAuthCredential credential) async {
  //   log("verificationCompleted");
  // }

//   Future<void> confirmPhoneNumberAndResetPassword({
//     required BuildContext context,
//     required String code,
//     required String phone,
//   }) async {
//     print("phonephonephonephone $phone");
//     isLoading = true;
//     emit(ResetPasswordLoading());
//     // try {
// /*      PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: myVerificationId,
//         smsCode: code,
//       );
//
//       await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
//         MyNavigator.navigateTo(context, ResetChangePasswordScreen(phone: phone));
//         isCodeSent = false;
//       });
//       isLoading = false;
//       emit(ResetPasswordSuccess());*/
//
//       print("EnteredCodeIs: $code");
//       print("verificationId: $myVerificationId");
//       Response response = await DioHelperV2.post(
//         path: EndPoints.verifyOtp,
//         data: {
//           "role": "customer",
//           "phone": phone,
//           "otp": code,
//         },
//       );
//       if (response.statusCode == 200) {
//         // ignore: use_build_context_synchronously
//         MyNavigator.navigateTo(context, ResetChangePasswordScreen(phone: phone));
//         isCodeSent = true;
//         // ignore: use_build_context_synchronously
//         showMessage(
//           context: context,
//           message: response.data["msg"],
//           color: Colors.green,
//         );
//       } else {
//         // ignore: use_build_context_synchronously
//         showMessage(
//           context: context,
//           message: response.data["msg"].toString(),
//           color: MyColors.redColor,
//         );
//       }
//     //   if(code==myVerificationId){
//     //     isCodeSent = false;          // To solve problem when back
//     //     MyNavigator.navigateTo(context, ResetChangePasswordScreen(phone: phone));
//     //     isLoading = false;
//     //     emit(ResetPasswordSuccess());
//     //   }else{
//     //     showMessage(
//     //       context: context,
//     //       message: "Code Not Correct",
//     //       color: MyColors.redColor,
//     //     );
//     //     isLoading = false;
//     //     emit(ResetPasswordError());
//     //   }
//     //
//     // } catch (e) {
//     //   if (e.toString().startsWith("[firebase_auth/invalid-phone-number]")) {
//     //     // ignore: use_build_context_synchronously
//     //     showMessage(
//     //       context: context,
//     //       message: "Phone number is incorrect".tr(),
//     //       color: MyColors.redColor,
//     //     );
//     //   } else if (e.toString().startsWith("[firebase_auth/invalid-verification-code]")) {
//     //     // ignore: use_build_context_synchronously
//     //     showMessage(
//     //       context: context,
//     //       message: "The confirmation code is incorrect".tr(),
//     //       color: MyColors.redColor,
//     //     );
//     //   } else {
//     //     log(e.toString());
//     //     // ignore: use_build_context_synchronously
//     //     showMessage(context: context, message: e.toString(), color: Colors.red);
//     //   }
//     //   isLoading = false;
//     //   emit(ResetPasswordError());
//     // }
//   }

  Future<void> changePassword({
    required String phone,
    required String password1,
    required String password2,
    required BuildContext context,
  }) async {
    isLoading = true;
    emit(ResetPasswordLoading());
    try {
      await ProfileServices.updatePassword(
        phone: phone,
        password: password2,
      ).then((response) {
        if (response?.statusCode == 200) {
          isCodeSent = false;
          isPasswordVisible = false;
          MyNavigator.navigateOffAll(context, LoginScreen());
          showMessage(
            context: context,
            message: response!.data["msg"],
            color: Colors.green,
          );
        } else {
          showMessage(
            context: context,
            message: response!.data["msg"],
            color: Colors.red,
          );
        }
      });
      isLoading = false;
      emit(ResetPasswordSuccess());
    } catch (e) {
      isLoading = false;
      emit(ResetPasswordError());
    }
  }
}
