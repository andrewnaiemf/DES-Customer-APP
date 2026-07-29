import 'package:app/models/owner/owner_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'allocatee_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Allocatee {
  final int id;
  final int contactId;
  final String? reference;
  final String? description;
  final String issueDate;
  final String dueDate;
  final String status;
  final String dueAmount;
  final String paidAmount;
  final String total;
  final String? notes;
  final dynamic termsConditions;
  final String? qrcodeString;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Pivot? pivot;
  final String? type;
  final OwnerModel? owner;

  Allocatee({
    required this.id,
    required this.contactId,
    required this.reference,
    required this.description,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.dueAmount,
    required this.paidAmount,
    required this.total,
    required this.notes,
    required this.termsConditions,
    required this.qrcodeString,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
    required this.type,
    required this.owner,
  });

  factory Allocatee.fromJson(Map<String, dynamic> json) => _$AllocateeFromJson(json);

  Map<String, dynamic> toJson() => _$AllocateeToJson(this);
}

class Pivot {
  final int? id;
  final int? allocateeId;

  Pivot({
    required this.id,
    required this.allocateeId,
  });

  Pivot.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        allocateeId = json['allocatee_id'] as int?;

  Map<String, dynamic> toJson() => {'id': id, 'allocatee_id': allocateeId};
}
