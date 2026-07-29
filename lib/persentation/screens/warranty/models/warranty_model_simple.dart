// ═══════════════════════════════════════════════════════════════════════════
// 📦 Warranty Model - Simple Data Class
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String warrantyCode;
  final String serialNumber;
  final String installationDate;
  final int currentMileage;
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final String vehicleColor;
  final String licensePlate;
  final List<String> windowsProtection;
  final List<String> ppfProtection;
  final List<String> images;

  WarrantyModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.warrantyCode,
    required this.serialNumber,
    required this.installationDate,
    required this.currentMileage,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleColor,
    required this.licensePlate,
    required this.windowsProtection,
    required this.ppfProtection,
    required this.images,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'warrantyCode': warrantyCode,
    'serialNumber': serialNumber,
    'installationDate': installationDate,
    'currentMileage': currentMileage,
    'vehicleMake': vehicleMake,
    'vehicleModel': vehicleModel,
    'vehicleYear': vehicleYear,
    'vehicleColor': vehicleColor,
    'licensePlate': licensePlate,
    'windowsProtection': windowsProtection,
    'ppfProtection': ppfProtection,
    'images': images,
  };
}
