// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCustomerModel _$ProductCustomerModelFromJson(
        Map<String, dynamic> json) =>
    ProductCustomerModel(
      pivot: ProductPivotModel.fromJson(json['pivot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductCustomerModelToJson(
        ProductCustomerModel instance) =>
    <String, dynamic>{
      'pivot': instance.pivot,
    };
