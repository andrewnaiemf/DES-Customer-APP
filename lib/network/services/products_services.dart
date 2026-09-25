import 'dart:developer';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/order/order_model.dart';
import 'package:app/models/product/product_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:dio/dio.dart';

class ProductsServices {
  static String endPoint = EndPoints.products;

  static List<ProductModel> data = [];
  static Future<List<ProductModel>> getData({int page = 1, int perPage = 20}) async {
    data.clear();
    try {
      var result = await DioHelper.get(
        path: endPoint,
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (result.statusCode == 200) {
        log('Get $endPoint Success');
        for (var element in result.data['data']['data']) {
          data.add(ProductModel.fromJson(element));
        }
        return data;
      } else {
        log('Unable To Get $endPoint');
        return data;
      }
    } catch (e) {
      log('$e');
      return data;
    }
  }
  static Future<List<ProductModel>> getAllData({int page = 1, int perPage = 20}) async {
    data.clear();
    try {
      var result = await DioHelper.get(
        path: endPoint,
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (result.statusCode == 200) {
        log('Get $endPoint Success');
        for (var element in result.data['data']['data']) {
          data.add(ProductModel.fromJson(element));
        }
        return data;
      } else {
        log('Unable To Get $endPoint');
        return data;
      }
    } catch (e) {
      log('$e');
      return data;
    }
  }
}
