import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/product/product_price/product_customer_model.dart';
import 'package:app/models/product/product_price/product_pivot_model.dart';
import 'package:app/models/product/product_tax/product_tax_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductModel {
  late int id;
  late int categoryId;
  late int taxId;
  late String? specialTaxReasonId;
  late String nameAr;
  late String nameEn;
  late String description;
  late String type;
  late String? picture;
  late int unitType;
  late String unit;
  late String buyingPrice;
  late String sellingPrice;
  late int isBuyingPriceInclusive;
  late int isSellingPriceInclusive;
  late String sku;
  late String barcode;
  late int isSold;
  late int isBought;
  late int trackQuantity;
  late int posProduct;
  late DateTime createdAt;
  late DateTime updatedAt;
  @JsonKey(name: 'customers')
  late List<ProductCustomerModel>? customers;
  late ProductTaxModel? tax;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.taxId,
    required this.specialTaxReasonId,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    required this.type,
    required this.picture,
    required this.unitType,
    required this.unit,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.isBuyingPriceInclusive,
    required this.isSellingPriceInclusive,
    required this.sku,
    required this.barcode,
    required this.isSold,
    required this.isBought,
    required this.trackQuantity,
    required this.posProduct,
    required this.createdAt,
    required this.updatedAt,
    required this.tax,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
