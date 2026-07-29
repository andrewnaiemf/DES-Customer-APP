// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_tax_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductTaxModel _$ProductTaxModelFromJson(Map<String, dynamic> json) =>
    ProductTaxModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      rate: json['rate'] as String,
    );

Map<String, dynamic> _$ProductTaxModelToJson(ProductTaxModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'rate': instance.rate,
    };
