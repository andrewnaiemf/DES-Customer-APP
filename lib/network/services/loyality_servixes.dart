import 'dart:convert';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/LoyaltyPointsModel.dart';
import 'package:app/models/Notifications/notifications_model.dart';
import 'package:app/models/Statistics/statistics_model.dart';
import 'package:app/network/dio_helper.dart';

class LoyalityServices{
  Future<LoyaltyPointsModel?> getLoyalityPoints() async {
    final response = await DioHelper.get(
      path: EndPoints.loyalityPoints,
      queryParameters: {'page': 1, 'per_page': 20},
    );
    if(response.statusCode! >= 200 &&response.statusCode! < 300){
      print("getLoyalityPoints statusCode 200");
      final payload = response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : jsonDecode(response.toString());
      return LoyaltyPointsModel.fromJson(payload);
    }else{
      print(response.toString());
      print("Failed to getLoyalityPoints.");
      return null;
    }
  }
}