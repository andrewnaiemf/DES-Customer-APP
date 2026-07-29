import 'dart:convert';
import 'dart:developer';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/CheckLoyaltyModel.dart';
import 'package:app/models/order/order_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:dio/dio.dart';

class OrdersServices {
  static String endPoint = EndPoints.orders;

  static List<OrderModel> data = [];
  
  /// ✅ Get Orders with Pagination Support
  static Future<List<OrderModel>> getData({
    int? page,
    int? perPage,
    String? status,
    String? search,
  }) async {
    data.clear();
    try {
      // ✅ Build query parameters
      Map<String, dynamic> queryParams = {};
      
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      // ✅ فقط استخدم per-page header إذا مافي query parameters
      // وإلا استخدم query parameter per_page
      final useHeader = queryParams.isEmpty;
      if (useHeader) {
        DioHelper.dio.options.headers.addAll({"per-page": 100}); // ✅ تقليل من 1000 إلى 100 لتحسين الأداء
      }
      
      var result = await DioHelper.get(
        path: endPoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      // ✅ تنظيف الـ header بعد الـ request
      if (useHeader) {
        DioHelper.dio.options.headers.remove('per-page');
      }

      if (result.statusCode == 200) {
        log('Get $endPoint Success');
        
        // ✅ Handle both response formats:
        // Format 1: { data: { data: [...], current_page, ... } } (Laravel nested)
        // Format 2: { data: [...] } (Simple)
        
        var responseData = result.data['data'];
        List<dynamic> ordersJson;
        
        if (responseData is Map && responseData.containsKey('data')) {
          // Laravel nested format
          ordersJson = responseData['data'];
          log('📊 Pagination Info: Page ${responseData['current_page']}/${responseData['last_page']}, Total: ${responseData['total']}');
        } else if (responseData is List) {
          // Simple list format
          ordersJson = responseData;
        } else {
          log('⚠️ Unknown response format');
          return data;
        }
        
        for (var element in ordersJson) {
          data.add(OrderModel.fromJson(element));
        }
        
        log('✅ Loaded ${data.length} orders');
        return data;
      } else {
        log('Unable To Get $endPoint');
        return data;
      }
    } catch (e) {
      log('❌ Error in getData: $e');
      return data;
    }
  }
  
  /// ✅ Get Paginated Response (returns full pagination metadata)
  static Future<Map<String, dynamic>?> getPaginatedOrders({
    int page = 1,
    int perPage = 20,
    String? status,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };
      
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      var result = await DioHelper.get(
        path: endPoint,
        queryParameters: queryParams,
      );

      if (result.statusCode == 200) {
        log('✅ Get Paginated $endPoint Success');
        return result.data['data'];
      } else {
        log('❌ Unable To Get Paginated $endPoint');
        return null;
      }
    } catch (e) {
      log('❌ Error in getPaginatedOrders: $e');
      return null;
    }
  }

  /// ✅ OLD METHOD - Kept for backward compatibility
  static Future<List<OrderModel>> getData_OLD() async {
    data.clear();
    try {
      // ✅ تقليل عدد الطلبات لـ 100 بدل 1000 (أسرع 10x)
      DioHelper.dio.options.headers.addAll({"per-page": 100});
      var result = await DioHelper.get(path: endPoint);
      DioHelper.dio.options.headers.remove('per-page');

      if (result.statusCode == 200) {
        log('Get $endPoint Success');
        for (var element in result.data['data']['data']) {
          data.add(OrderModel.fromJson(element));
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

  static Future<Response?> addData(Map<String, dynamic> payload) async {
    try {
      var result = await DioHelper.post(path: endPoint, data: payload);

      if (result.statusCode == 200) {
        log('Add $endPoint  Success');
        return result;
      } else {
        log('Unable To Add $endPoint');
      }

      return result;
    } catch (e) {
      log('$e');
    }
    return null;
  }

  Future<CheckLoyaltyModel?> checkLoyalty() async {
    final response = await DioHelper.get(path: EndPoints.checkLoyalty);
    var responseMap = jsonDecode(response.toString());
    if(response.statusCode! >= 200 &&response.statusCode! < 300){
      log("checkLoyalty statusCode 200");
      return CheckLoyaltyModel.fromJson(responseMap);
    }else{
      log("Failed to checkLoyalty.");
      return null;
    }
  }
  static Future<Response?> editOrder(Map<String, dynamic> payload, String orderId,
      ) async {
    try {
      var result = await DioHelper.put(path: endPoint+"/${orderId}", data: payload);

      if (result.statusCode == 200) {
        log('Edit $endPoint  Success');
        return result;
      } else {
        log('Unable To Edit $endPoint');
      }

      return result;
    } catch (e) {
      log('$e');
    }
    return null;
  }
  static Future<Response?> cancelOrder(String orderId,
      ) async {
    try {
      var result = await DioHelper.put(path: endPoint+"/${orderId}",data: {
        "status": "Canceled"
      });

      if (result.statusCode == 200) {
        log('Edit $endPoint  Success');
        return result;
      } else {
        log('Unable To Edit $endPoint');
      }

      return result;
    } catch (e) {
      log('$e');
    }
    return null;
  }
  
  /// Get single order tracking update - NOT SUPPORTED BY API
  /// API returns 404: "The GET method is not supported for this route"
  /// Use getData() and filter locally instead
  static Future<OrderModel?> getOrderTracking(String orderId) async {
    // API doesn't support GET for single order
    // Return null to force fallback to local search
    log('⚠️ getOrderTracking: API does not support GET for single order');
    return null;
  }
}
