import 'dart:developer';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:app/persentation/screens/auth/login_screen.dart';
import 'package:app/persentation/screens/layout/layout_screen.dart';
import 'package:app/persentation/screens/splash/splash_screen.dart';
import 'package:app/theme/colors.dart';
import 'package:app/core/services/biometric_service.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/services/fcm_subscription_helper.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  bool isLoadingLogin = false;
  bool isLoadingSignOut = false;

  Future<void> login({
    required BuildContext context,
    required String phone,
    required String password,
  }) async {
    isLoadingLogin = true;
    emit(LoginLoading());
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      Response response = await DioHelper.post(
        path: EndPoints.login,
        data: {
          "phone_number": phone,
          "password": password,
          "device_token": token,
          "locale":"${CacheHelper.getString(key: "lang")?? "ar"}"
        },
      );
      if (response.statusCode == 200) {
        UserModel userModel = UserModel.fromJson(response.data["data"]["user"]);
        log("${userModel}");
        await CacheHelper.setString(
          key: "access_token",
          value: response.data["data"]["token"],
        );
        await CacheHelper.setBool(
          key: "is_logged_in",
          value: true,
        );

        // ✅ تفعيل البصمة تلقائياً بعد تسجيل الدخول الناجح للسماح بالدخول السريع
        await CacheHelper.setBool(
          key: 'biometric_app_lock_enabled',
          value: true,
        );

        // ✅ ضمان اشتراك المستخدم في إشعارات FCM وحفظ Token
        FCMSubscriptionHelper().ensureSubscribed(
          userId: userModel.id.toString(),
        );

        DioHelper.init();
        if (context.mounted) {
          showMessage(
            context: context,
            message: response.data["msg"],
            color: Colors.green,
          );
          MyNavigator.navigateOff(context, const LayoutScreen());
        }
      } else {
        if (context.mounted) {
          showMessage(
            context: context,
            message: response.data["msg"].toString(),
            color: MyColors.redColor,
          );
        }
      }

      isLoadingLogin = false;
      emit(LoginSuccess());
    } catch (e) {
      log("$e");
      isLoadingLogin = false;
      if (context.mounted) {
        showMessage(
          context: context,
          message: "Error when Login",
          color: MyColors.redColor,
        );
      }
      emit(LoginError());
    }
  }
  void signOut(BuildContext context) async {
    isLoadingSignOut = true;
    emit(SignoutState());

    // 🔐 احتفظ بإعدادات البصمة بعد Logout
    // فقط ننظف الجلسة الحالية ووقت الخلفية، لكن لا نحذف حالة التفعيل
    BiometricService.instance.resetSessionAuthentication();
    await BiometricService.instance.clearBackgroundTime();

    // امسح التوكن بس من الكاش
    await CacheHelper.removeKey(key: "access_token");

    // ممكن هنا تضيف لو عندك حاجة تحدد إذا كان المستخدم مسجل دخول:
    await CacheHelper.setBool(key: "is_logged_in", value: false);
    await CacheHelper.removeKey(key: 'cached_user_json');

    // إعادة تعيين حالة الـ Splash لعرضه في المرة القادمة
    await SplashScreen.resetSplashState();

    // إعادة تهيئة Dio
    DioHelper.init();

    isLoadingSignOut = false;
    emit(SignoutState());

    // ارجع لصفحة تسجيل الدخول
    MyNavigator.navigateOffAll(context, LoginScreen());
  }
}
