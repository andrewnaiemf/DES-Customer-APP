import 'dart:developer';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:dio/dio.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔐 نتيجة جلب البروفايل عند بدء التطبيق
// بنفرّق بين:
//   - success: التوكن شغّال والبيانات اترجعت
//   - unauthorized: السيرفر رفض التوكن فعلاً (401) -> لازم logout
//   - transientError: خطأ شبكة/timeout/سيرفر مؤقت -> نحافظ على الجلسة
// ═══════════════════════════════════════════════════════════════════════════
enum ProfileFetchOutcome { success, unauthorized, transientError }

class ProfileFetchResult {
  final UserModel? user;
  final ProfileFetchOutcome outcome;

  const ProfileFetchResult(this.user, this.outcome);
}

class ProfileServices {
  static Future<UserModel?> getProfile() async {
    try {
      var result = await DioHelper.get(path: EndPoints.profile);

      if (result.statusCode == 200) {
        log('Get Profile Success');
        return UserModel.fromJson(result.data['data']['user']);
      } else {
        log('Unable To Get Profile');
      }
    } catch (e) {
      log('$e');
    }
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 🔐 نسخة بحالة واضحة تُستخدم عند بدء التطبيق لتحديد الوجهة (Login/Layout)
  // ───────────────────────────────────────────────────────────────────────────
  static Future<ProfileFetchResult> getProfileWithStatus() async {
    try {
      // ⚠️ DioHelper.validateStatus راجع true لأي status code،
      // فالـ 401 بييجي كـ Response مش كـ exception.
      var result = await DioHelper.get(path: EndPoints.profile);

      if (result.statusCode == 200) {
        log('Get Profile Success');
        return ProfileFetchResult(
          UserModel.fromJson(result.data['data']['user']),
          ProfileFetchOutcome.success,
        );
      } else if (result.statusCode == 401 || result.statusCode == 403) {
        // التوكن مرفوض فعلاً من السيرفر -> الجلسة انتهت
        log('Profile Unauthorized (${result.statusCode}) -> session expired');
        return const ProfileFetchResult(null, ProfileFetchOutcome.unauthorized);
      } else {
        // 500 / 4xx أخرى -> نعتبرها مؤقتة ومانطردش المستخدم
        log('Unable To Get Profile (status: ${result.statusCode}) -> transient');
        return const ProfileFetchResult(null, ProfileFetchOutcome.transientError);
      }
    } catch (e) {
      // timeout / مفيش نت / DioException -> مؤقت
      log('getProfileWithStatus error -> transient: $e');
      return const ProfileFetchResult(null, ProfileFetchOutcome.transientError);
    }
  }

  static Future<Response?> updatePassword({
    required String phone,
    required String password,
  }) async {
    try {
      print("phone updatePassword $phone");
      var result = await DioHelper.post(
        path: EndPoints.forgetPassword,
        data: {
          "phone_number": phone,
          "password": password,
          "password_confirmation": password,
        },
      );
      if (result.statusCode == 200) {
        log('Update Profile Success');
      } else {
        log('${result.data['data']}');
        log('Unable To Update Profile');
      }
      return result;
    } catch (e) {
      log('$e');
    }
    return null;
  }
}
