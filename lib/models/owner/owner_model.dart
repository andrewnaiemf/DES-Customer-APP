import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/product/product_price/product_pivot_model.dart';
import 'package:app/models/shipping_address/shipping_address_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'owner_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OwnerModel {
  // late int id;
  // late List<String?> deviceToken;
  // late String locale;
  late String? name;
  // late dynamic organization;
  // late String email;
  // late String phoneNumber;
  // late String? taxNumber;
  // late DateTime createdAt;
  // late DateTime updatedAt;
  // late String commercialRegistrationNumber;
  // late ShippingAddressModel shippingAddress;

  OwnerModel({
    // required this.id,
    // required this.deviceToken,
    // required this.locale,
    required this.name,
    // required this.organization,
    // required this.email,
    // required this.phoneNumber,
    // required this.taxNumber,
    // required this.createdAt,
    // required this.updatedAt,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) => _$OwnerModelFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerModelToJson(this);
}
