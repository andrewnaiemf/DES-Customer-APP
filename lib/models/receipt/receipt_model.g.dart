// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptModel _$ReceiptModelFromJson(Map<String, dynamic> json) => ReceiptModel(
      id: (json['id'] as num?)?.toInt(),
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      date: json['date'] as String?,
      amount: json['amount'] as String,
      kind: json['kind'] as String,
      contactId: (json['contact_id'] as num).toInt(),
      accountId: (json['account_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      contact: UserModel.fromJson(json['contact'] as Map<String, dynamic>),
      account: json['account'] == null
          ? null
          : Account.fromJson(json['account'] as Map<String, dynamic>),
      allocates: (json['allocates'] as List<dynamic>?)
          ?.map((e) => Allocates.fromJson(e as Map<String, dynamic>))
          .toList(),
      unAllocateAmount: (json['un_allocate_amount'] as num?)?.toInt(),
      fromLocation: json['from_location'] == null
          ? null
          : FromLocation.fromJson(
              json['from_location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReceiptModelToJson(ReceiptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'description': instance.description,
      'date': instance.date,
      'amount': instance.amount,
      'kind': instance.kind,
      'contact_id': instance.contactId,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'contact': instance.contact,
      'account': instance.account,
      'allocates': instance.allocates,
      'un_allocate_amount': instance.unAllocateAmount,
      'from_location': instance.fromLocation,
    };
