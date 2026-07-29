import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/product/product_price/product_pivot_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payments_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PaymentsModel {
  late int id;
  late int sourceId;
  late int allocateeId;
  late String amount;
  late String date;
  late String sourceType;
  late String allocateeType;
  late DateTime createdAt;
  late DateTime updatedAt;

  PaymentsModel({
    required this.id,
    required this.sourceId,
    required this.allocateeId,
    required this.amount,
    required this.date,
    required this.sourceType,
    required this.allocateeType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentsModel.fromJson(Map<String, dynamic> json) => _$PaymentsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentsModelToJson(this);
}
