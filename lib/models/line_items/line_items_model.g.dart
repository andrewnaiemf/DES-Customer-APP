// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_items_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineItemsModel _$LineItemsModelFromJson(Map<String, dynamic> json) =>
    LineItemsModel(
      id: (json['id'] as num).toInt(),
      invoiceId: (json['invoice_id'] as num?)?.toInt(),
      productId: (json['product_id'] as num).toInt(),
      description: json['description'] as String,
      quantity: json['quantity'] as String,
      unitPrice: json['unit_price'] as String,
      discount: json['discount'] as String,
      discountType: json['discount_type'] as String,
      taxPercent: json['tax_percent'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$LineItemsModelToJson(LineItemsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_id': instance.invoiceId,
      'product_id': instance.productId,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'discount': instance.discount,
      'discount_type': instance.discountType,
      'tax_percent': instance.taxPercent,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'name': instance.name,
    };
