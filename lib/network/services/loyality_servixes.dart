import 'dart:convert';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/LoyaltyPointsModel.dart';
import 'package:app/models/Notifications/notifications_model.dart';
import 'package:app/models/Statistics/statistics_model.dart';
import 'package:app/network/dio_helper.dart';

class LoyalityServices{
  Future<LoyaltyPointsModel?> getLoyalityPoints() async {
    final response = await DioHelper.get(path: EndPoints.loyalityPoints,
        data: {"per-page": 1000});
    var responseMap = jsonDecode(response.toString());
    if(response.statusCode! >= 200 &&response.statusCode! < 300){
      print(response.toString());
      print("getLoyalityPoints statusCode 200");
      return LoyaltyPointsModel.fromJson(responseMap);
    }else{
      print(response.toString());
      print("Failed to getLoyalityPoints.");
      return null;
    }
  }
}