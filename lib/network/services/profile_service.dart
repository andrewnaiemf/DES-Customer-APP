import 'dart:convert';
import 'dart:developer';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/helpers/cache_helper.dart';
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
  static const cachedUserKey = 'cached_user_json';

  static UserModel? parseUser(dynamic raw) {
    try {
      if (raw is! Map) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      log('parseUser failed: $e');
      return null;
    }
  }

  static Future<void> cacheUser(UserModel user) async {
    try {
      await CacheHelper.setString(
        key: cachedUserKey,
        value: jsonEncode(user.toJson()),
      );
    } catch (e) {
      log('cacheUser failed: $e');
    }
  }

  static UserModel? loadCachedUser() {
    try {
      final raw = CacheHelper.getString(key: cachedUserKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return parseUser(decoded);
    } catch (e) {
      log('loadCachedUser failed: $e');
      return null;
    }
  }

  static Future<void> clearCachedUser() async {
    try {
      await CacheHelper.removeKey(key: cachedUserKey);
    } catch (_) {}
  }

  static Future<UserModel?> getProfile() async {
    try {
      var result = await DioHelper.get(path: EndPoints.profile);

      if (result.statusCode == 200) {
        log('Get Profile Success');
        final user = parseUser(result.data['data']?['user']);
        if (user != null) {
          await cacheUser(user);
        }
        return user;
      } else {
        log('Unable To Get Profile');
      }
    } catch (e) {
      log('$e');
    }
    return loadCachedUser();
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
        final user = parseUser(result.data['data']?['user']);
        if (user != null) {
          await cacheUser(user);
          return ProfileFetchResult(user, ProfileFetchOutcome.success);
        }
        return ProfileFetchResult(
          loadCachedUser(),
          ProfileFetchOutcome.transientError,
        );
      } else if (result.statusCode == 401 || result.statusCode == 403) {
        // التوكن مرفوض فعلاً من السيرفر -> الجلسة انتهت
        log('Profile Unauthorized (${result.statusCode}) -> session expired');
        return const ProfileFetchResult(null, ProfileFetchOutcome.unauthorized);
      } else {
        // 500 / 4xx أخرى -> نعتبرها مؤقتة ومانطردش المستخدم
        log('Unable To Get Profile (status: ${result.statusCode}) -> transient');
        return ProfileFetchResult(
          loadCachedUser(),
          ProfileFetchOutcome.transientError,
        );
      }
    } catch (e) {
      // timeout / مفيش نت / DioException -> مؤقت
      log('getProfileWithStatus error -> transient: $e');
      return ProfileFetchResult(
        loadCachedUser(),
        ProfileFetchOutcome.transientError,
      );
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
