import 'package:json_annotation/json_annotation.dart';

part 'account_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Account {
  final int id;
  final String code;
  final String nameEn;
  final String nameAr;
  final String typeOfAccount;
  final String parentType;
  final String balance;
  final String type;
  final String groupType;
  final int receivePayments;
  final String status;
  final String createdAt;
  final String updatedAt;

  Account({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.typeOfAccount,
    required this.parentType,
    required this.balance,
    required this.type,
    required this.groupType,
    required this.receivePayments,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
