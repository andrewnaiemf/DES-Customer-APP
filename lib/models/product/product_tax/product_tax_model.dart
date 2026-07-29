import 'package:app/models/branche/branche_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_tax_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductTaxModel {
  late int id;
  late String name;
  late String rate;

  ProductTaxModel({
    required this.id,
    required this.name,
    required this.rate,
  });

  factory ProductTaxModel.fromJson(Map<String, dynamic> json) => _$ProductTaxModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductTaxModelToJson(this);
}
