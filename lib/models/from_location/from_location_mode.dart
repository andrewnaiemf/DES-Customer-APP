import 'package:json_annotation/json_annotation.dart';

part 'from_location_mode.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FromLocation {
  final int id;
  final String arName;
  final String name;
  final int accountId;
  final dynamic shippingAddressId;
  final DateTime createdAt;
  final DateTime updatedAt;

  FromLocation({
    required this.id,
    required this.arName,
    required this.name,
    required this.accountId,
    required this.shippingAddressId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FromLocation.fromJson(Map<String, dynamic> json) => _$FromLocationFromJson(json);

  Map<String, dynamic> toJson() => _$FromLocationToJson(this);
}
