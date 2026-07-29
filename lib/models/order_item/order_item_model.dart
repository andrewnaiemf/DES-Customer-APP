import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/orderhistory/order_history_model.dart';
import 'package:app/models/product/product_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_item_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderItemModel {
  late int id;
  late int orderId;
  late int productId;
  late String quantity;
  late String unitPrice;
  late String taxPercent;
  late ProductModel product;
  late DateTime createdAt;
  late DateTime updatedAt;
  late double total;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.taxPercent,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}
