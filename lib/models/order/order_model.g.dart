// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: (json['id'] as num).toInt(),
  is_offer: json['is_offer'] as bool?,
      signature_image: json['signature_image'] as String?,
      customerId: (json['customer_id'] as num?)?.toInt(),
      driverId: (json['driver_id'] as num?)?.toInt(),
      delivery_document_url: json['delivery_document_url'] as String?,
      inventoryId: (json['inventory_id'] as num?)?.toInt(),
      reference: json['reference'] as String?,
      status: json['status'] as String?,
      shippingStatus: json['shipping_status'] as String?,
      loyaltyDiscount: json['loyalty_discount'] as String?,
      loyaltyPoints: json['loyalty_points'] as num?,
      confirmationImages: json['confirmation_images'] as List<dynamic>?,
      declineReason: json['decline_reason'],
      termsConditions: json['terms_conditions'],
      checkoutDate: DateTime.parse(json['checkout_date'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalTax: (json['total_tax'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      location: json['location'] as String?,
      totalWithTax: (json['total_with_tax'] as num?)?.toDouble(),
      orderItems: (json['order_items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      customer: json['customer'] == null
          ? null
          : UserModel.fromJson(json['customer'] as Map<String, dynamic>),
  offer: json['offer'] == null
          ? null
          : OfferModelInOrder.fromJson(json['offer'] as Map<String, dynamic>),
      orderHistory: (json['order_history'] as List<dynamic>?)
          ?.map((e) => OrderHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..notes = json['notes'] as String?;

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'driver_id': instance.driverId,
      'inventory_id': instance.inventoryId,
      'reference': instance.reference,
      'status': instance.status,
      'shipping_status': instance.shippingStatus,
      'delivery_document_url': instance.delivery_document_url,
      'loyalty_discount': instance.loyaltyDiscount,
      'loyalty_points': instance.loyaltyPoints,
      'notes': instance.notes,
      'location': instance.location,
      'confirmation_images': instance.confirmationImages,
      'terms_conditions': instance.termsConditions,
      'decline_reason': instance.declineReason,
      'checkout_date': instance.checkoutDate.toIso8601String(),
      'signature_image': instance.signature_image,
      'is_offer': instance.is_offer,
      'updated_at': instance.updatedAt.toIso8601String(),
      'total_tax': instance.totalTax,
      'total': instance.total,
      'total_with_tax': instance.totalWithTax,
      'order_items': instance.orderItems,
      'order_history': instance.orderHistory,
      'customer': instance.customer,
      'offer': instance.offer,
    };
