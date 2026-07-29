import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/product/product_price/product_pivot_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_customer_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductCustomerModel {
  late ProductPivotModel pivot;

  ProductCustomerModel({
    required this.pivot,
  });

  factory ProductCustomerModel.fromJson(Map<String, dynamic> json) => _$ProductCustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductCustomerModelToJson(this);
}
