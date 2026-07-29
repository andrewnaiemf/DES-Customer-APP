import 'dart:convert';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/Notifications/notifications_model.dart';
import 'package:app/models/Statistics/statistics_model.dart';
import 'package:app/network/dio_helper.dart';

class NotificationsServices{
  Future<NotificationsModel?> getNotifications() async {
    final response = await DioHelper.get(path: EndPoints.notifications,data: {"per-page": 1000});
    var responseMap = jsonDecode(response.toString());
    if(response.statusCode! >= 200 &&response.statusCode! < 300){
      print(response.toString());
      print("getNotifications statusCode 200");
      return NotificationsModel.fromJson(responseMap);
    }else{
      print(response.toString());
      print("Failed to getNotifications.");
      return null;
    }
  }
  Future<bool?> readNotifications(String notificationId) async {
    final response = await DioHelper.get(path: EndPoints.readNotification+"/$notificationId");
    var responseMap = jsonDecode(response.toString());
    if(response.statusCode! >= 200 &&response.statusCode! < 300){
      print(response.toString());
      print("getNotifications statusCode 200");
      return true;
    }else{
      print(response.toString());
      print("Failed to getNotifications.");
      return false;
    }
  }

  Future<bool?> readAllNotifications() async {
    final response = await DioHelper.get(path: EndPoints.readAllNotifications);
    var responseMap = jsonDecode(response.toString());
    if(response.statusCode! >= 200 &&response.statusCode! < 300){
      print(response.toString());
      print("readAllNotifications statusCode 200");
      return true;
    }else{
      print(response.toString());
      print("Failed to readAllNotifications.");
      return false;
    }
  }
}