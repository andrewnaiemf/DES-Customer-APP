// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingAddressModel _$ShippingAddressModelFromJson(
        Map<String, dynamic> json) =>
    ShippingAddressModel(
      id: (json['id'] as num).toInt(),
      contactId: (json['contact_id'] as num?)?.toInt(),
      isDefault: json['is_default'] as bool?,
      shippingAddress: json['shipping_address'] as String,
      shippingCity: json['shipping_city'] as String,
      shippingState: json['shipping_state'] as String,
      shippingZip: json['shipping_zip'] as String,
      shippingCountry: json['shipping_country'] as String,
      shippingBuildingNumber: json['shipping_building_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ShippingAddressModelToJson(
        ShippingAddressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contact_id': instance.contactId,
      'is_default': instance.isDefault,
      'shipping_address': instance.shippingAddress,
      'shipping_city': instance.shippingCity,
      'shipping_state': instance.shippingState,
      'shipping_zip': instance.shippingZip,
      'shipping_country': instance.shippingCountry,
      'shipping_building_number': instance.shippingBuildingNumber,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
