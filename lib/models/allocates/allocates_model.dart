import 'package:app/models/allocatee/allocatee_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'allocates_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Allocates {
  final int id;
  final int sourceId;
  final int allocateeId;
  final String amount;
  final String date;
  final String sourceType;
  final String allocateeType;
  final String createdAt;
  final String updatedAt;
  final List<Allocatee>? allocatee;

  Allocates({
    required this.id,
    required this.sourceId,
    required this.allocateeId,
    required this.amount,
    required this.date,
    required this.sourceType,
    required this.allocateeType,
    required this.createdAt,
    required this.updatedAt,
    required this.allocatee,
  });

  factory Allocates.fromJson(Map<String, dynamic> json) => _$AllocatesFromJson(json);

  Map<String, dynamic> toJson() => _$AllocatesToJson(this);
}
