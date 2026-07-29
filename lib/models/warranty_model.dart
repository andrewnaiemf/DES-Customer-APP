// ═══════════════════════════════════════════════════════════════════════════
// 📄 Warranty Models - نماذج بيانات نظام الضمان
// ═══════════════════════════════════════════════════════════════════════════

/// نموذج بيانات طلب إصدار شهادة الضمان
class WarrantyRequestModel {
  // بيانات صاحب السيارة
  final String ownerName;
  final String ownerMobile;

  // بيانات الرول / الحماية
  final String serialNumber;
  final String serviceType;
  final String? installationDate;

  // بيانات السيارة
  final String carPlateNumber;
  final String carType;
  final String carModel;
  final String? carYear;
  final String? notes;

  WarrantyRequestModel({
    required this.ownerName,
    required this.ownerMobile,
    required this.serialNumber,
    required this.serviceType,
    this.installationDate,
    required this.carPlateNumber,
    required this.carType,
    required this.carModel,
    this.carYear,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'owner_name': ownerName,
      'owner_mobile': ownerMobile,
      'serial_number': serialNumber,
      'service_type': serviceType,
      'installation_date': installationDate,
      'car_plate_number': carPlateNumber,
      'car_type': carType,
      'car_model': carModel,
      'car_year': carYear,
      'notes': notes,
    };
  }
}

/// نموذج شهادة الضمان المستلمة من الـ API
class WarrantyCertificateModel {
  final String certificateId;
  final String ownerName;
  final String ownerMobile;
  final String serialNumber;
  final String serviceType;
  final String installationDate;
  final String carPlateNumber;
  final String carType;
  final String carModel;
  final String? carYear;
  final String? notes;
  final String issueDate;
  final String expiryDate;
  final String? downloadUrl;
  final String? pdfBase64;

  WarrantyCertificateModel({
    required this.certificateId,
    required this.ownerName,
    required this.ownerMobile,
    required this.serialNumber,
    required this.serviceType,
    required this.installationDate,
    required this.carPlateNumber,
    required this.carType,
    required this.carModel,
    this.carYear,
    this.notes,
    required this.issueDate,
    required this.expiryDate,
    this.downloadUrl,
    this.pdfBase64,
  });

  factory WarrantyCertificateModel.fromJson(Map<String, dynamic> json) {
    return WarrantyCertificateModel(
      certificateId: json['certificate_id']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      ownerMobile: json['owner_mobile']?.toString() ?? '',
      serialNumber: json['serial_number']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? '',
      installationDate: json['installation_date']?.toString() ?? '',
      carPlateNumber: json['car_plate_number']?.toString() ?? '',
      carType: json['car_type']?.toString() ?? '',
      carModel: json['car_model']?.toString() ?? '',
      carYear: json['car_year']?.toString(),
      notes: json['notes']?.toString(),
      issueDate: json['issue_date']?.toString() ?? '',
      expiryDate: json['expiry_date']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString(),
      pdfBase64: json['pdf_base64']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificate_id': certificateId,
      'owner_name': ownerName,
      'owner_mobile': ownerMobile,
      'serial_number': serialNumber,
      'service_type': serviceType,
      'installation_date': installationDate,
      'car_plate_number': carPlateNumber,
      'car_type': carType,
      'car_model': carModel,
      'car_year': carYear,
      'notes': notes,
      'issue_date': issueDate,
      'expiry_date': expiryDate,
      'download_url': downloadUrl,
      'pdf_base64': pdfBase64,
    };
  }
}
