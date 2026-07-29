import 'dart:developer';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/invoice/invoice_model.dart';
import 'package:app/network/dio_helper.dart';

class InVoiceServices {
  static String endPoint = EndPoints.invoices;
  static List<InVoiceModel> data = [];
  
  /// ✅ Get Invoices with Pagination Support
  static Future<List<InVoiceModel>> getData({
    int? page,
    int? perPage,
    String? status,
    String? search,
  }) async {
    data.clear();
    try {
      Map<String, dynamic> queryParams = {};
      
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      if (queryParams.isEmpty) {
        DioHelper.dio.options.headers.addAll({"per-page": 1000});
      }
      
      var result = await DioHelper.get(
        path: endPoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      DioHelper.dio.options.headers.remove('per-page');

      if (result.statusCode == 200) {
        log('Get $endPoint Success');
        
        var responseData = result.data['data'];
        List<dynamic> invoicesJson;
        
        if (responseData is Map && responseData.containsKey('data')) {
          invoicesJson = responseData['data'];
          log('📊 Invoice Pagination Info: Page ${responseData['current_page']}/${responseData['last_page']}, Total: ${responseData['total']}');
          // log('📊 Token ${responseData['current_page']}/${responseData['last_page']}, Total: ${responseData['total']}');
        } else if (responseData is List) {
          invoicesJson = responseData;
        } else {
          log('⚠️ Unknown response format');
          return data;
        }
        
        for (var element in invoicesJson) {
          data.add(InVoiceModel.fromJson(element));
        }
        
        log('✅ Loaded ${data.length} invoices');
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
  
  /// ✅ Get Paginated Invoices (returns full pagination metadata)
  static Future<Map<String, dynamic>?> getPaginatedInvoices({
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
      log('❌ Error in getPaginatedInvoices: $e');
      return null;
    }
  }
}
