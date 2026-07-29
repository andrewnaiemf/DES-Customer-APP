import 'service_entry_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Warranty Model - Multi-Entry Support
// ═══════════════════════════════════════════════════════════════════════════
// Enhanced model supporting multiple service entries per warranty
// Replaces single service record with scalable multi-service log
// ═══════════════════════════════════════════════════════════════════════════

class WarrantyModelMultiEntry {
  // Customer Information
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  // Warranty Core Information
  final String installationDate;

  // Vehicle Information
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final String vehicleColor;
  final String licensePlate;

  // 🔥 MULTI-ENTRY SERVICES - The Core Change
  final List<ServiceEntryModel> serviceEntries;

  // Images
  final List<String> images;

  // Optional remarks
  final String? remarks;

  WarrantyModelMultiEntry({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.installationDate,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleColor,
    required this.licensePlate,
    required this.serviceEntries,
    required this.images,
    this.remarks,
  });

  // Convert to API format matching backend requirements
  Map<String, dynamic> toApiJson() {
    // Convert service entries to products array format
    List<Map<String, dynamic>> products = [];
    
    for (var entry in serviceEntries) {
      products.add({
        'usedMeters': entry.usedMeters.toString(),
        'warrantyCode': entry.warrantyCode,
        'serialCode': entry.serialCode,
        'protectedArea': entry.protectedAreas,
      });
    }

    return {
      'installDate': installationDate,
      'ownerFirstName': firstName,
      'ownerLastName': lastName,
      'ownerPhoneAreaCode': '+966', // Default, should be dynamic
      'ownerPhone': phone,
      'ownerEmail': email,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleColor': vehicleColor,
      'vehicleLicense': licensePlate,
      'remarks': remarks ?? 'Multi-service warranty registration',
      'products': products,
      // Note: vehiclePhotos will be handled separately as FormData
    };
  }

  // Get service summary
  ServiceSummary get summary => ServiceSummary.fromEntries(serviceEntries);

  // Validation
  bool get isValid {
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || phone.isEmpty) {
      return false;
    }

    if (vehicleMake.isEmpty || vehicleModel.isEmpty) {
      return false;
    }
    if (serviceEntries.isEmpty) {
      return false;
    }
    // Ensure all service entries are valid
    return serviceEntries.every((entry) => entry.isValid);
  }

  // Get entries by service type
  List<ServiceEntryModel> getEntriesByType(String type) {
    return serviceEntries.where((e) => e.serviceType == type).toList();
  }

  List<ServiceEntryModel> get windowsEntries => getEntriesByType('windows');
  List<ServiceEntryModel> get ppfEntries => getEntriesByType('ppf');
}
