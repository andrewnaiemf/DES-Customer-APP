import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/product/product_price/product_pivot_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shipping_address_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ShippingAddressModel {
  late int id;
  late int? contactId;
  late bool? isDefault;
  late String shippingAddress;
  late String shippingCity;
  late String shippingState;
  late String shippingZip;
  late String shippingCountry;
  late String shippingBuildingNumber;
  late DateTime createdAt;
  late DateTime updatedAt;

  ShippingAddressModel({
    required this.id,
    required this.contactId,
    required this.isDefault,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingZip,
    required this.shippingCountry,
    required this.shippingBuildingNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) => _$ShippingAddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingAddressModelToJson(this);
}
