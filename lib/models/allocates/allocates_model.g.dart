// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocates_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Allocates _$AllocatesFromJson(Map<String, dynamic> json) => Allocates(
      id: (json['id'] as num).toInt(),
      sourceId: (json['source_id'] as num).toInt(),
      allocateeId: (json['allocatee_id'] as num).toInt(),
      amount: json['amount'] as String,
      date: json['date'] as String,
      sourceType: json['source_type'] as String,
      allocateeType: json['allocatee_type'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      allocatee: (json['allocatee'] as List<dynamic>?)
          ?.map((e) => Allocatee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AllocatesToJson(Allocates instance) => <String, dynamic>{
      'id': instance.id,
      'source_id': instance.sourceId,
      'allocatee_id': instance.allocateeId,
      'amount': instance.amount,
      'date': instance.date,
      'source_type': instance.sourceType,
      'allocatee_type': instance.allocateeType,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'allocatee': instance.allocatee,
    };
