// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_statement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountStatementModel _$AccountStatementModelFromJson(
        Map<String, dynamic> json) =>
    AccountStatementModel(
      id: (json['id'] as num?)?.toInt(),
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      date: json['date'] as String?,
      type: json['type'] as String,
      contact: UserModel.fromJson(json['contact'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AccountStatementModelToJson(
        AccountStatementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'description': instance.description,
      'date': instance.date,
      'type': instance.type,
      'contact': instance.contact,
    };
