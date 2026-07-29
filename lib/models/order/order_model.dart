import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/driver/driver_model.dart';
import 'package:app/models/order_item/order_item_model.dart';
import 'package:app/models/orderhistory/order_history_model.dart';
import 'package:app/models/user/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../offermodelinorder.dart';

part 'order_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderModel {
  late int id;
  late int? customerId;
  late int? driverId;
  late int? inventoryId;
  late String? reference;
  late String? status;

  late String? shippingStatus;
  late String? delivery_document_url;
 late String? loyaltyDiscount;
 late num? loyaltyPoints;
  late String? notes;
  late bool? is_offer;
  late String? location;
  // late String? confirmationImage;
  late List<dynamic>? confirmationImages;
  late dynamic termsConditions;
  late dynamic declineReason;
  late DateTime checkoutDate;
  late String? signature_image;
  late DateTime updatedAt;
  late double? totalTax;
  late double? total;
  late double? totalWithTax;
  late List<OrderItemModel>? orderItems;
  late List<OrderHistory>? orderHistory;
  OfferModelInOrder? offer;

  // late DriverModel? driver;
  late UserModel? customer;

  OrderModel({
    required this.id,
    required this.signature_image,
    required this.customerId,
     this.is_offer,
     this.offer,
    required this.driverId,
    required this.delivery_document_url,
    required this.inventoryId,
    required this.reference,
    required this.status,
    required this.shippingStatus,
    required this.loyaltyDiscount,
    required this.loyaltyPoints,
    required this.confirmationImages,
    required this.declineReason,
    // required this.confirmationImage,
    required this.termsConditions,
    required this.checkoutDate,
    required this.updatedAt,
    required this.totalTax,
    required this.total,
    required this.location,
    required this.totalWithTax,
    required this.orderItems,
    // required this.driver,
    required this.customer,
    required this.orderHistory,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
