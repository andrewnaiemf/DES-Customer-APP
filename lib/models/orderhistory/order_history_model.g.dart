// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderHistory _$OrderHistoryFromJson(Map<String, dynamic> json) => OrderHistory(
      id: (json['id'] as num?)?.toInt(),
      event: json['event'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$OrderHistoryToJson(OrderHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event': instance.event,
      'created_at': instance.createdAt,
    };
