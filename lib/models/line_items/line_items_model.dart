import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/product/product_model.dart';
import 'package:app/models/product/product_price/product_pivot_model.dart';
import 'package:app/models/shipping_address/shipping_address_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line_items_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LineItemsModel {
  late int id;
  late int? invoiceId;
  late int productId;
  late String description;
  late String quantity;
  late String unitPrice;
  late String discount;
  late String discountType;
  late String taxPercent;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String name;
  // late ProductModel product;

  LineItemsModel({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.discountType,
    required this.taxPercent,
    required this.name,
    // required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LineItemsModel.fromJson(Map<String, dynamic> json) => _$LineItemsModelFromJson(json);

  Map<String, dynamic> toJson() => _$LineItemsModelToJson(this);
}
