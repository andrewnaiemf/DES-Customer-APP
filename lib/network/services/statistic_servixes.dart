import 'dart:convert';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/Statistics/statistics_model.dart';
import 'package:app/network/dio_helper.dart';

class StatisticServices{
  Future<StatisticModel?> getStatistic() async {
    try {
      final response = await DioHelper.get(
        path: EndPoints.statistic,
      ).timeout(
        const Duration(seconds: 15), // ⏱️ Timeout بعد 15 ثانية
        onTimeout: () {
          print('⏰ Statistics request timed out');
          throw Exception('Request timeout');
        },
      );
      
      if (response.statusCode != null && 
          response.statusCode! >= 200 && 
          response.statusCode! < 300) {
        var responseMap = jsonDecode(response.toString());
        print("✅ getStatistic statusCode: ${response.statusCode}");
        return StatisticModel.fromJson(responseMap);
      } else {
        print("❌ Failed to getStatistic. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in getStatistic: $e");
      // ✅ بدلاً من رمي الخطأ، نرجع null وده أفضل لتجربة المستخدم
      return null;
    }
  }

  Future<bool?> changeLocale({required String userId,required String locale}) async {
    final response = await DioHelper.put(path: EndPoints.changeLocale(userId),data: {"locale":"$locale"});
    // var responseMap = jsonDecode(response.data);
    if(response.statusCode! >= 200 &&response.statusCode! < 300){
      // print(response.data); 
      print("changeLocale statusCode 200");
      return true;
    }else{
      print(response.toString());
      print("Failed to changeLocale.");
      return false;
    }
  }
}