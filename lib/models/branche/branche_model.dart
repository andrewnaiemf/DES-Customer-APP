import 'package:json_annotation/json_annotation.dart';

part 'branche_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BrancheModel {
  late int id;
  // late List<String?> deviceToken;
  late String locale;
  late String name;
  late String organization;
  late String? email;
  late String phoneNumber;
  late String taxNumber;
  late String status;
  late dynamic rememberToken;
  late DateTime createdAt;
  late DateTime updatedAt;

  BrancheModel({
    required this.id,
    // required this.deviceToken,
    required this.locale,
    required this.name,
    required this.organization,
    required this.email,
    required this.phoneNumber,
    required this.taxNumber,
    required this.status,
    required this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrancheModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return BrancheModel(
      id: parseInt(json['id']),
      locale: json['locale']?.toString() ?? 'ar',
      name: (json['name'] ?? json['organization'] ?? '').toString(),
      organization:
          (json['organization'] ?? json['trade_name'] ?? json['name'] ?? '')
              .toString(),
      email: json['email']?.toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      taxNumber: (json['tax_number'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      rememberToken: json['remember_token'],
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => _$BrancheModelToJson(this);
}
