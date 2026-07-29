import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences preferences;
  static init() async {
    preferences = await SharedPreferences.getInstance();
  }

  static Future<void> setString({
    required String key,
    required String value,
  }) async {
    await preferences.setString(key, value).then((val) {
      log("SET => $key : $value");
    });
  }
  static Future<void> setBool({
    required String key,
    required bool value,
  }) async {
    await preferences.setBool(key, value).then((val) {
      log("SET => $key : $value");
    });
  }


  static Future<void> setList({
    required String key,
    required List<String> value,
  }) async {
    await preferences.setStringList(key, value).then((val) {
      log("SET => $key : $value");
    });
  }
  static bool? getBool({
    required String key,
  }) {
    return preferences.getBool(key);
  }


  static String? getString({
    required String key,
  }) {
    return preferences.getString(key);
  }

  static List<String>? getList({
    required String key,
  }) {
    return preferences.getStringList(key);
  }

  static removeKey({
    required String key,
  }) async {
    await preferences.remove(key);
    log("Removed : $key");
  }
}
