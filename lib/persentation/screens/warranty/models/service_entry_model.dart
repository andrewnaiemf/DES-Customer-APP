// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Service Entry Model - Multi-Entry Support
// ═══════════════════════════════════════════════════════════════════════════
// Supports multiple service entries per Warranty + Serial combination
// Each entry is independent with its own:
// - Service Type (Windows/PPF)
// - Used Meters
// - Protected Areas
// - Timestamp
// ═══════════════════════════════════════════════════════════════════════════

class ServiceEntryModel {
  final String id; // Unique ID for UI management
  final String warrantyCode;
  final String serialCode;
  final String serviceType; // "windows" or "ppf"
  final int usedMeters;
  final List<String> protectedAreas;
  final DateTime timestamp;

  ServiceEntryModel({
    required this.id,
    this.warrantyCode = '',
    this.serialCode = '',
    required this.serviceType,
    required this.usedMeters,
    required this.protectedAreas,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Create empty entry for adding new service
  factory ServiceEntryModel.empty(String id) {
    return ServiceEntryModel(
      id: id,
      warrantyCode: '',
      serialCode: '',
      serviceType: 'windows',
      usedMeters: 0,
      protectedAreas: [],
    );
  }

  // Copy with method for updates
  ServiceEntryModel copyWith({
    String? id,
    String? warrantyCode,
    String? serialCode,
    String? serviceType,
    int? usedMeters,
    List<String>? protectedAreas,
    DateTime? timestamp,
  }) {
    return ServiceEntryModel(
      id: id ?? this.id,
      warrantyCode: warrantyCode ?? this.warrantyCode,
      serialCode: serialCode ?? this.serialCode,
      serviceType: serviceType ?? this.serviceType,
      usedMeters: usedMeters ?? this.usedMeters,
      protectedAreas: protectedAreas ?? this.protectedAreas,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() => {
        'warrantyCode': warrantyCode,
        'serialCode': serialCode,
        'serviceType': serviceType,
        'usedMeters': usedMeters,
        'protectedAreas': protectedAreas,
        'timestamp': timestamp.toIso8601String(),
      };

  // Validation
  bool get isValid {
    return warrantyCode.isNotEmpty && 
           serialCode.isNotEmpty && 
           usedMeters > 0 && 
           protectedAreas.isNotEmpty;
  }

  String get serviceDisplayName {
    return serviceType == 'windows' 
        ? 'Window Protection' 
        : 'PPF Protection';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Service Summary - For displaying totals
// ═══════════════════════════════════════════════════════════════════════════
class ServiceSummary {
  final int totalWindowsMeters;
  final int totalPPFMeters;
  final int totalEntries;

  ServiceSummary({
    required this.totalWindowsMeters,
    required this.totalPPFMeters,
    required this.totalEntries,
  });

  factory ServiceSummary.fromEntries(List<ServiceEntryModel> entries) {
    int windowsTotal = 0;
    int ppfTotal = 0;

    for (var entry in entries) {
      if (entry.serviceType == 'windows') {
        windowsTotal += entry.usedMeters;
      } else if (entry.serviceType == 'ppf') {
        ppfTotal += entry.usedMeters;
      }
    }

    return ServiceSummary(
      totalWindowsMeters: windowsTotal,
      totalPPFMeters: ppfTotal,
      totalEntries: entries.length,
    );
  }

  int get totalMeters => totalWindowsMeters + totalPPFMeters;
}
