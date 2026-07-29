import 'package:app/models/line_items/line_items_model.dart';
import 'package:app/models/owner/owner_model.dart';
import 'package:app/models/payment/payments_model.dart';
import 'package:app/models/user/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InVoiceModel {
  late int? id;
  late int? contactId;
  late String? reference;
  late String? description;
  late String? issueDate;
  late String? dueDate;
  late String? status;
  late String? dueAmount;
  late String? paidAmount;
  late String? total;
  late String? notes;
  late String? pdf;
  late dynamic termsConditions;
  late String? qrcodeString;
  late String? paymentMethod;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late dynamic inventory;
  late String? type;
  late List<PaymentsModel>? payments;
  late List<LineItemsModel>? lineItems;
  late UserModel? contact;
  late OwnerModel? owner;

  InVoiceModel({
    this.id,
    this.contactId,
    this.reference,
    this.description,
    this.issueDate,
    this.dueDate,
    this.status,
    this.dueAmount,
    this.paidAmount,
    this.total,
    this.notes,
    this.pdf,
    this.termsConditions,
    this.qrcodeString,
    this.paymentMethod,
    this.createdAt,
    this.inventory,
    this.type,
    this.payments,
    this.lineItems,
    this.contact,
    this.owner,
  });

  factory InVoiceModel.fromJson(Map<String, dynamic> json) => _$InVoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InVoiceModelToJson(this);
}
