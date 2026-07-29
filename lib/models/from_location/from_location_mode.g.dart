// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'from_location_mode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FromLocation _$FromLocationFromJson(Map<String, dynamic> json) => FromLocation(
      id: (json['id'] as num).toInt(),
      arName: json['ar_name'] as String,
      name: json['name'] as String,
      accountId: (json['account_id'] as num).toInt(),
      shippingAddressId: json['shipping_address_id'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FromLocationToJson(FromLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ar_name': instance.arName,
      'name': instance.name,
      'account_id': instance.accountId,
      'shipping_address_id': instance.shippingAddressId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
