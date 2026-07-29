import 'dart:developer';

import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/receipt/receipt_model.dart';
import 'package:app/network/dio_helper.dart';

class ReceiptsServices {
  static String endPoint = EndPoints.receipts;

  static List<ReceiptModel> data = [];
  
  /// Get receipts with optional pagination, filtering, and search
  /// - [page]: The page number (default: null = all receipts)
  /// - [perPage]: Items per page (default: 20)
  /// - [status]: Filter by status
  /// - [search]: Search query
  static Future<List<ReceiptModel>> getData({
    int? page,
    int? perPage,
    String? status,
    String? search,
  }) async {
    data.clear();
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      
      if (page != null) {
        queryParams['page'] = page;
        queryParams['per_page'] = perPage ?? 20;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // If no pagination params, use old header method for backward compatibility
      if (page == null) {
        DioHelper.dio.options.headers.addAll({"per-page": 1000});
      }

      var result = await DioHelper.get(
        path: endPoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (page == null) {
        DioHelper.dio.options.headers.remove('per-page');
      }

      if (result.statusCode == 200) {
        log('Get $endPoint Success (Page: ${page ?? 'all'})');
        
        // Handle both nested and simple response formats
        dynamic receiptsData;
        if (result.data['data'] != null) {
          if (result.data['data']['data'] != null) {
            receiptsData = result.data['data']['data'];
          } else {
            receiptsData = result.data['data'];
          }
        } else {
          receiptsData = result.data;
        }

        for (var element in receiptsData) {
          data.add(ReceiptModel.fromJson(element));
        }
        log(result.data.toString());
        return data;
      } else {
        log('Unable To Get $endPoint');
        log(result.data.toString());

        return data;
      }
    } catch (e) {
      log('Error in ReceiptsServices.getData: $e');
      return data;
    }
  }

  /// Get receipts with full pagination metadata
  static Future<Map<String, dynamic>?> getPaginatedReceipts({
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
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      var result = await DioHelper.get(
        path: endPoint,
        queryParameters: queryParams,
      );

      if (result.statusCode == 200) {
        log('📊 Receipts pagination info: Page $page, Per Page: $perPage');
        
        // Handle nested response format (data.data)
        if (result.data['data'] != null && result.data['data']['data'] != null) {
          return {
            'data': result.data['data']['data'],
            'current_page': result.data['data']['current_page'] ?? page,
            'last_page': result.data['data']['last_page'] ?? 1,
            'total': result.data['data']['total'] ?? 0,
          };
        }
        
        // Handle simple response format
        return {
          'data': result.data['data'] ?? [],
          'current_page': result.data['current_page'] ?? page,
          'last_page': result.data['last_page'] ?? 1,
          'total': result.data['total'] ?? 0,
        };
      } else {
        log('❌ Unable to get paginated receipts');
        return null;
      }
    } catch (e) {
      log('❌ Error in getPaginatedReceipts: $e');
      return null;
    }
  }
}
