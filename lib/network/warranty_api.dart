import 'package:app/network/dio_helper.dart';
import 'package:dio/dio.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Warranty API Service - Uses DioHelperWarranty with Bearer Token
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyApi {
  // ─────────────────────────────────────────────────────────────────────────
  // 📋 Get PPF List (Paint Protection Film)
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Response> getPPFList() async {
    try {
      print('\n🌐 API Call: getPPFList');
      print('   Endpoint: /api/ext/list-ppf');
      print('   Method: GET');
      print('   🔑 Using Bearer Token Authentication');
      
      final response = await DioHelperWarranty.get(
        path: '/api/ext/list-ppf',
      );
      
      print('   Response Status: ${response.statusCode}');
      print('   Response Data: ${response.data}\n');
      
      return response;
    } catch (e) {
      print('   ❌ Error in getPPFList: $e\n');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🪟 Get Window Film List
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Response> getWindowList() async {
    try {
      print('\n🌐 API Call: getWindowList');
      print('   Endpoint: /api/ext/list-windows');
      print('   Method: GET');
      print('   🔑 Using Bearer Token Authentication');
      
      final response = await DioHelperWarranty.get(
        path: '/api/ext/list-windows',
      );
      
      print('   Response Status: ${response.statusCode}');
      print('   Response Data: ${response.data}\n');
      
      return response;
    } catch (e) {
      print('   ❌ Error in getWindowList: $e\n');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Register Warranty
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Response> registerWarranty({
    required String warrantyCode,
    required String serialCode,
    required String installDate,
    required String ownerFirstName,
    required String ownerLastName,
    required String ownerPhoneAreaCode,
    required String ownerPhone,
    required String ownerEmail,
    required String vehicleMake,
    required String vehicleModel,
    required String vehicleYear,
    required String vehicleColor,
    required String vehicleLicense,
    required double usedMeters,
    required List<String> protectedArea,
    String? remarks,
  }) async {
    try {
      print('\n🌐 API Call: registerWarranty');
      print('   Endpoint: /api/ext/warranty-registration');
      print('   Method: POST');
      print('   🔑 Using Bearer Token Authentication');
      print('   📝 Remarks value before processing: "${remarks}" (Type: ${remarks.runtimeType})');
      
      final requestData = {
        'warrantyCode': warrantyCode,
        'serialCode': serialCode,
        'installDate': installDate,
        'ownerFirstName': ownerFirstName,
        'ownerLastName': ownerLastName,
        'ownerPhoneAreaCode': ownerPhoneAreaCode,
        'ownerPhone': ownerPhone,
        'ownerEmail': ownerEmail,
        'vehicleMake': vehicleMake,
        'vehicleModel': vehicleModel,
        'vehicleYear': vehicleYear,
        'vehicleColor': vehicleColor,
        'vehicleLicense': vehicleLicense,
        'usedMeters': usedMeters,
        'protectedArea': protectedArea,
        'remarks': (remarks == null || remarks.isEmpty) ? 'No remarks' : remarks,
      };
      
      print('   📝 Remarks value after processing: "${requestData['remarks']}" (Type: ${requestData['remarks'].runtimeType})');
      print('   Request Data:');
      requestData.forEach((key, value) {
        print('      $key: $value');
      });
      
      final response = await DioHelperWarranty.post(
        path: '/api/ext/warranty-registration',
        data: requestData,
      );
      
      print('   Response Status: ${response.statusCode}');
      print('   Response Data: ${response.data}\n');
      
      return response;
    } catch (e, stackTrace) {
      print('   ❌ Error in registerWarranty: $e');
      print('   Stack Trace: $stackTrace\n');
      rethrow;
    }
  }
}
