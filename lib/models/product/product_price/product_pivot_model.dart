import 'package:app/models/branche/branche_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_pivot_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductPivotModel {
  late String price;

  ProductPivotModel({
    required this.price,
  });

  factory ProductPivotModel.fromJson(Map<String, dynamic> json) => _$ProductPivotModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductPivotModelToJson(this);
}
