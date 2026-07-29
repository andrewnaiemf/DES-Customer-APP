import 'package:app/models/branche/branche_model.dart';
import 'package:app/models/driver/driver_model.dart';
import 'package:app/models/order_item/order_item_model.dart';
import 'package:app/models/user/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_history_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderHistory {
 late int? id;
 late String? event;
 late String? createdAt;

 OrderHistory({
    required this.id,
    required this.event,
    required this.createdAt,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) => _$OrderHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryToJson(this);
}
