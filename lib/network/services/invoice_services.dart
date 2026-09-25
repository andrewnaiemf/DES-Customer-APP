import 'dart:developer';
import 'dart:typed_data';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/invoice/invoice_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:dio/dio.dart';

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
      
      var result = await DioHelper.get(
        path: endPoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

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
        final payload = result.data['data'];
        if (payload is Map) {
          return Map<String, dynamic>.from(payload);
        }
        if (payload is List) {
          return {
            'data': payload,
            'current_page': page,
            'last_page': 1,
            'total': payload.length,
            'next_page_url': null,
          };
        }
        return null;
      } else {
        log('❌ Unable To Get Paginated $endPoint');
        return null;
      }
    } catch (e) {
      log('❌ Error in getPaginatedInvoices: $e');
      return null;
    }
  }

  static Future<List<int>?> downloadPdfBytes(int id) async {
    try {
      final result = await DioHelper.get(
        path: '$endPoint/$id/pdf',
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 90),
        ),
      );
      if (result.statusCode != 200 || result.data == null) {
        return null;
      }
      final data = result.data;
      List<int>? bytes;
      if (data is Uint8List) {
        bytes = data;
      } else if (data is List<int>) {
        bytes = data;
      }
      if (bytes == null || bytes.length < 4) {
        return null;
      }
      if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) {
        return bytes;
      }
    } catch (e) {
      log('❌ Error in downloadPdfBytes: $e');
    }
    return null;
  }

  static Future<InVoiceModel?> getById(int id) async {
    try {
      final result = await DioHelper.get(path: '$endPoint/$id');
      if (result.statusCode == 200 && result.data['data'] is Map) {
        return InVoiceModel.fromJson(
          Map<String, dynamic>.from(result.data['data']),
        );
      }
    } catch (e) {
      log('❌ Error in getById: $e');
    }
    return null;
  }
}
