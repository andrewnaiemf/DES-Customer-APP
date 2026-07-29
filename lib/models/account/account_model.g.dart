// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      typeOfAccount: json['type_of_account'] as String,
      parentType: json['parent_type'] as String,
      balance: json['balance'] as String,
      type: json['type'] as String,
      groupType: json['group_type'] as String,
      receivePayments: (json['receive_payments'] as num).toInt(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name_en': instance.nameEn,
      'name_ar': instance.nameAr,
      'type_of_account': instance.typeOfAccount,
      'parent_type': instance.parentType,
      'balance': instance.balance,
      'type': instance.type,
      'group_type': instance.groupType,
      'receive_payments': instance.receivePayments,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
