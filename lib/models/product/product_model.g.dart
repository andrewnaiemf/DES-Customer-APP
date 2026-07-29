// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: (json['id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      taxId: (json['tax_id'] as num).toInt(),
      specialTaxReasonId: json['special_tax_reason_id'] as String?,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      picture: json['picture'] as String?,
      unitType: (json['unit_type'] as num).toInt(),
      unit: json['unit'] as String,
      buyingPrice: json['buying_price'] as String,
      sellingPrice: json['selling_price'] as String,
      isBuyingPriceInclusive:
          (json['is_buying_price_inclusive'] as num).toInt(),
      isSellingPriceInclusive:
          (json['is_selling_price_inclusive'] as num).toInt(),
      sku: json['sku'] as String,
      barcode: json['barcode'] as String,
      isSold: (json['is_sold'] as num).toInt(),
      isBought: (json['is_bought'] as num).toInt(),
      trackQuantity: (json['track_quantity'] as num).toInt(),
      posProduct: (json['pos_product'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      tax: json['tax'] == null
          ? null
          : ProductTaxModel.fromJson(json['tax'] as Map<String, dynamic>),
    )..customers = (json['customers'] as List<dynamic>?)
        ?.map((e) => ProductCustomerModel.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'tax_id': instance.taxId,
      'special_tax_reason_id': instance.specialTaxReasonId,
      'name_ar': instance.nameAr,
      'name_en': instance.nameEn,
      'description': instance.description,
      'type': instance.type,
      'picture': instance.picture,
      'unit_type': instance.unitType,
      'unit': instance.unit,
      'buying_price': instance.buyingPrice,
      'selling_price': instance.sellingPrice,
      'is_buying_price_inclusive': instance.isBuyingPriceInclusive,
      'is_selling_price_inclusive': instance.isSellingPriceInclusive,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'is_sold': instance.isSold,
      'is_bought': instance.isBought,
      'track_quantity': instance.trackQuantity,
      'pos_product': instance.posProduct,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'customers': instance.customers,
      'tax': instance.tax,
    };
