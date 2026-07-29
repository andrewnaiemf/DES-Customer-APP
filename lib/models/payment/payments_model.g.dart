// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentsModel _$PaymentsModelFromJson(Map<String, dynamic> json) =>
    PaymentsModel(
      id: (json['id'] as num).toInt(),
      sourceId: (json['source_id'] as num).toInt(),
      allocateeId: (json['allocatee_id'] as num).toInt(),
      amount: json['amount'] as String,
      date: json['date'] as String,
      sourceType: json['source_type'] as String,
      allocateeType: json['allocatee_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PaymentsModelToJson(PaymentsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_id': instance.sourceId,
      'allocatee_id': instance.allocateeId,
      'amount': instance.amount,
      'date': instance.date,
      'source_type': instance.sourceType,
      'allocatee_type': instance.allocateeType,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
