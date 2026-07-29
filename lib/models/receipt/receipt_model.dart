import 'package:app/models/account/account_model.dart';
import 'package:app/models/allocates/allocates_model.dart';
import 'package:app/models/from_location/from_location_mode.dart';
import 'package:app/models/user/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'receipt_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ReceiptModel {
  final int? id;
  final String? reference;
  final String? description;
  final String? date;
  final String amount;
  final String kind;
  final int contactId;
  final int accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel contact;
  final Account? account;
  final List<Allocates>? allocates;
  final int? unAllocateAmount;
  final FromLocation? fromLocation;

  ReceiptModel({
    required this.id,
    required this.reference,
    required this.description,
    required this.date,
    required this.amount,
    required this.kind,
    required this.contactId,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    required this.contact,
    required this.account,
    required this.allocates,
    required this.unAllocateAmount,
    required this.fromLocation,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) => _$ReceiptModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptModelToJson(this);
}
