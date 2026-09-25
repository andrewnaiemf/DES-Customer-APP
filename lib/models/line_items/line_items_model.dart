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

  factory LineItemsModel.fromJson(Map<String, dynamic> json) {
    String asString(dynamic value) => value?.toString() ?? '';
    int asInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime asDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();

    return LineItemsModel(
      id: asInt(json['id']),
      invoiceId: json['invoice_id'] == null ? null : asInt(json['invoice_id']),
      productId: asInt(json['product_id']),
      description: asString(json['description']),
      quantity: asString(json['quantity'] ?? '0'),
      unitPrice: asString(json['unit_price'] ?? json['unitPrice'] ?? '0'),
      discount: asString(json['discount'] ?? '0'),
      discountType: asString(json['discount_type'] ?? json['discountType'] ?? ''),
      taxPercent: asString(json['tax_percent'] ?? json['taxPercent'] ?? '0'),
      name: asString(json['name'] ?? json['product_name'] ?? ''),
      createdAt: asDate(json['created_at']),
      updatedAt: asDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => _$LineItemsModelToJson(this);
}
