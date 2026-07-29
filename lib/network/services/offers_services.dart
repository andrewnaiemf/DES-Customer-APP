import 'package:app/models/VersionModel.dart';
import 'package:dio/dio.dart';

import '../../data/constants/api_constants.dart';
import '../../helpers/ToastHelper.dart';
import '../../models/ActionModel.dart';
import '../../models/offers/OffersModel.dart';
import '../dio_helper.dart';

class OffersServices {
  Future<VersionModel?> getAppVersion() async {
    try {
      final response = await DioHelper.get(path: EndPoints.getAppVersion);
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        print('✅ getAppVersion successfully');
        return VersionModel.fromJson(response.data);
      } else {
        print('❌ Failed to getAppVersion');
        return null;
      }
    } catch (e) {
      print('❌ Error getAppVersion: $e');
      rethrow;
    }
  }
  Future<OffersModel?> getOffers() async {
    try {
      final response = await DioHelper.get(path: EndPoints.getOffers,options: Options(
        headers: {
          "per-page":1000
        }
      ));

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        print('✅ getOffers successfully');
        return OffersModel.fromJson(response.data);
      } else {
        print('❌ Failed to getOffers');
        return null;
      }
    } catch (e) {
      print('❌ Error getOffers: $e');
      rethrow;
    }
  }
  Future<ActionModel?> declineOffer(String offerId ) async {
    print("offerId= $offerId");
    try {
      final response = await DioHelper.post(path: EndPoints.declineOffer(offerId));

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        print('✅ declineOffer successfully');
        ToastHelper.success(message: ActionModel.fromJson(response.data).msg??'successfully',);
        return ActionModel.fromJson(response.data);
      } else {
        ToastHelper.error(message: ActionModel.fromJson(response.data).msg??'Something went wrong',);
        print("offerId= ${ActionModel.fromJson(response.data).msg}");
        print('❌ Failed to declineOffer');
        return null;
      }
    } catch (e) {
      ToastHelper.error(message: e.toString(),);
      print('❌ Error declineOffer: $e');
      rethrow;
    }
  }
  Future<ActionModel?> acceptOffer({required String offerId,required String location,required String notes} ) async {
    try {
      final response = await DioHelper.post(path: EndPoints.acceptOffer(offerId),
        data: {
          "location": location,
          "notes": notes
        }
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        print('✅ acceptOffer successfully');
        print('✅ data ${response.data}}');
        ToastHelper.success(message: ActionModel.fromJson(response.data).msg??'successfully',);
        return ActionModel.fromJson(response.data);
      } else {
        print('✅ data ${response.data}}');
        print('❌ Failed to acceptOffer');
        ToastHelper.error(message: ActionModel.fromJson(response.data).msg??'Something went wrong',);
        return null;
      }
    } catch (e) {
      ToastHelper.error(message: e.toString(),);
      print('❌ Error acceptOffer: $e');
      rethrow;
    }
  }
}