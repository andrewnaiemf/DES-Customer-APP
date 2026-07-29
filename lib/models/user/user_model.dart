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

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
