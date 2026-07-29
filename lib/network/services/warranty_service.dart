import 'package:app/models/warranty_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:app/data/constants/api_constants.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🌐 Warranty Service - خدمة API نظام الضمان
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyService {
  /// إصدار شهادة ضمان جديدة
  Future<WarrantyCertificateModel?> issueCertificate(
    WarrantyRequestModel request,
  ) async {
    try {
      final response = await DioHelper.post(
        path: EndPoints.warrantyIssue, // يجب إضافة endpoint في ملف end_point.dart
        data: request.toJson(),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        print('✅ Warranty certificate issued successfully');
        return WarrantyCertificateModel.fromJson(response.data['data']);
      } else {
        print('❌ Failed to issue warranty certificate');
        return null;
      }
    } catch (e) {
      print('❌ Error issuing warranty certificate: $e');
      rethrow;
    }
  }

  /// الحصول على شهادة ضمان بواسطة ID
  Future<WarrantyCertificateModel?> getCertificate(String certificateId) async {
    try {
      final response = await DioHelper.get(
        path: '${EndPoints.warrantyGet}/$certificateId',
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return WarrantyCertificateModel.fromJson(response.data['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error getting warranty certificate: $e');
      rethrow;
    }
  }
}
