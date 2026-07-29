import 'package:bloc/bloc.dart';
import 'package:app/models/warranty_model.dart';
import 'package:app/network/services/warranty_service.dart';

part 'warranty_state.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Warranty Cubit - إدارة حالات نظام الضمان
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyCubit extends Cubit<WarrantyState> {
  final WarrantyService _warrantyService;

  WarrantyCubit(this._warrantyService) : super(WarrantyInitial());

  /// إصدار شهادة ضمان جديدة
  Future<void> issueCertificate(WarrantyRequestModel request) async {
    try {
      emit(WarrantyLoading());

      // محاكاة وقت الطلب (2 ثانية)
      await Future.delayed(const Duration(seconds: 2));

      // إنشاء شهادة تجريبية مع البيانات المدخلة
      final mockCertificate = WarrantyCertificateModel(
        certificateId: 'WRT-${DateTime.now().millisecondsSinceEpoch}',
        ownerName: request.ownerName,
        ownerMobile: request.ownerMobile,
        serialNumber: request.serialNumber,
        serviceType: request.serviceType,
        installationDate: request.installationDate ?? '',
        carPlateNumber: request.carPlateNumber,
        carType: request.carType,
        carModel: request.carModel,
        carYear: request.carYear,
        notes: request.notes,
        issueDate: DateTime.now().toIso8601String(),
        expiryDate: DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        downloadUrl: 'https://example.com/warranty-certificate.pdf',
        pdfBase64: 'mock_pdf_data',
      );

      emit(WarrantySuccess(mockCertificate));

      // الكود الأصلي للـ API (معطل مؤقتاً)
      // final certificate = await _warrantyService.issueCertificate(request);
      // if (certificate != null) {
      //   emit(WarrantySuccess(certificate));
      // } else {
      //   emit(const WarrantyError('فشل إصدار شهادة الضمان'));
      // }
    } catch (e) {
      emit(WarrantyError(e.toString()));
    }
  }

  /// إعادة تعيين الحالة
  void reset() {
    emit(WarrantyInitial());
  }
}
