import 'package:app/models/branche/branche_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  late int id;
  late List<String?> deviceToken;
  late String locale;
  late String name;
  late String organization;
  late String? email;
  late String phoneNumber;
  late String taxNumber;
  late String status;
  late String points;
  late dynamic rememberToken;
  late DateTime createdAt;
  late DateTime updatedAt;
  late double closingBalance;
  late double overdue;
  late int totalInvoicesCount;
  late double totalInvoicesAmount;
  late double totalOutStanding;
  late double totalPaid;
  late List<BrancheModel>? branches;

  UserModel({
    required this.id,
    required this.deviceToken,
    required this.locale,
    required this.name,
    required this.points,
    required this.organization,
    required this.email,
    required this.phoneNumber,
    required this.taxNumber,
    required this.status,
    required this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
    required this.closingBalance,
    required this.overdue,
    required this.totalInvoicesCount,
    required this.totalInvoicesAmount,
    required this.totalOutStanding,
    required this.totalPaid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    List<String?> tokens = <String?>[];
    final rawTokens = json['device_token'];
    if (rawTokens is List) {
      tokens = rawTokens.map((e) => e?.toString()).toList();
    } else if (rawTokens is String && rawTokens.isNotEmpty) {
      tokens = [rawTokens];
    }

    List<BrancheModel>? branches;
    if (json['branches'] is List) {
      branches = <BrancheModel>[];
      for (final item in json['branches'] as List) {
        if (item is! Map) continue;
        try {
          branches.add(
            BrancheModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {}
      }
    }

    return UserModel(
      id: parseInt(json['id']),
      deviceToken: tokens,
      locale: json['locale']?.toString() ?? 'ar',
      name: (json['name'] ?? json['organization'] ?? json['trade_name'] ?? '')
          .toString(),
      organization:
          (json['organization'] ?? json['trade_name'] ?? json['name'] ?? '')
              .toString(),
      email: json['email']?.toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      taxNumber: (json['tax_number'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      points: '${json['points'] ?? 0}',
      rememberToken: json['remember_token'],
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      closingBalance: parseDouble(json['closing_balance']),
      overdue: parseDouble(json['overdue']),
      totalInvoicesCount: parseInt(json['total_invoices_count']),
      totalInvoicesAmount: parseDouble(json['total_invoices_amount']),
      totalOutStanding: parseDouble(json['total_out_standing']),
      totalPaid: parseDouble(json['total_paid']),
    )..branches = branches;
  }

  String get displayName {
    for (final value in [name, organization]) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      final lower = trimmed.toLowerCase();
      if (lower == 'user' || lower == 'user name') continue;
      return trimmed;
    }
    return phoneNumber.trim();
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
