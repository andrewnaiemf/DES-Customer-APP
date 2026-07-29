part of 'warranty_cubit.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Warranty States - حالات نظام الضمان
// ═══════════════════════════════════════════════════════════════════════════
abstract class WarrantyState {
  const WarrantyState();
}

/// الحالة الأولية
class WarrantyInitial extends WarrantyState {}

/// حالة التحميل
class WarrantyLoading extends WarrantyState {}

/// حالة النجاح - تم إصدار الشهادة
class WarrantySuccess extends WarrantyState {
  final WarrantyCertificateModel certificate;

  const WarrantySuccess(this.certificate);
}

/// حالة الخطأ
class WarrantyError extends WarrantyState {
  final String message;

  const WarrantyError(this.message);
}
