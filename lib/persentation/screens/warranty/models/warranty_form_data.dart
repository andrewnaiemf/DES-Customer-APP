import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📋 Warranty Form Data Model
// ═══════════════════════════════════════════════════════════════════════════
class WarrantyFormData {
  // Customer Info
  String ownerFirstName = '';
  String ownerLastName = '';
  String ownerPhoneAreaCode = '+1';
  String ownerPhone = '';
  String ownerEmail = '';

  // Warranty Info
  String warrantyCode = '';
  String serialCode = '';
  String installDate = '';
  double usedMeters = 0.0;

  // Vehicle Info
  String vehicleMake = '';
  String vehicleModel = '';
  String vehicleYear = '';
  String vehicleColor = '';
  String vehicleLicense = '';

  // Protected Areas
  List<String> selectedWindowAreas = [];
  List<String> selectedPPFAreas = [];

  // Validation
  bool isValid() {
    return ownerFirstName.isNotEmpty &&
        ownerLastName.isNotEmpty &&
        ownerPhone.isNotEmpty &&
        ownerEmail.isNotEmpty &&
        warrantyCode.isNotEmpty &&
        serialCode.isNotEmpty &&
        installDate.isNotEmpty &&
        vehicleMake.isNotEmpty &&
        vehicleModel.isNotEmpty &&
        vehicleYear.isNotEmpty &&
        (selectedWindowAreas.isNotEmpty || selectedPPFAreas.isNotEmpty);
  }

  List<String> getAllProtectedAreas() {
    return [...selectedWindowAreas, ...selectedPPFAreas];
  }

  void reset() {
    ownerFirstName = '';
    ownerLastName = '';
    ownerPhoneAreaCode = '+1';
    ownerPhone = '';
    ownerEmail = '';
    warrantyCode = '';
    serialCode = '';
    installDate = '';
    usedMeters = 0.0;
    vehicleMake = '';
    vehicleModel = '';
    vehicleYear = '';
    vehicleColor = '';
    vehicleLicense = '';
    selectedWindowAreas.clear();
    selectedPPFAreas.clear();
  }
}
