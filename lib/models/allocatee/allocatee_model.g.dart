// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocatee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Allocatee _$AllocateeFromJson(Map<String, dynamic> json) => Allocatee(
      id: (json['id'] as num).toInt(),
      contactId: (json['contact_id'] as num).toInt(),
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      issueDate: json['issue_date'] as String,
      dueDate: json['due_date'] as String,
      status: json['status'] as String,
      dueAmount: json['due_amount'] as String,
      paidAmount: json['paid_amount'] as String,
      total: json['total'] as String,
      notes: json['notes'] as String?,
      termsConditions: json['terms_conditions'],
      qrcodeString: json['qrcode_string'] as String?,
      paymentMethod: json['payment_method'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pivot: json['pivot'] == null
          ? null
          : Pivot.fromJson(json['pivot'] as Map<String, dynamic>),
      type: json['type'] as String?,
      owner: json['owner'] == null
          ? null
          : OwnerModel.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AllocateeToJson(Allocatee instance) => <String, dynamic>{
      'id': instance.id,
      'contact_id': instance.contactId,
      'reference': instance.reference,
      'description': instance.description,
      'issue_date': instance.issueDate,
      'due_date': instance.dueDate,
      'status': instance.status,
      'due_amount': instance.dueAmount,
      'paid_amount': instance.paidAmount,
      'total': instance.total,
      'notes': instance.notes,
      'terms_conditions': instance.termsConditions,
      'qrcode_string': instance.qrcodeString,
      'payment_method': instance.paymentMethod,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'pivot': instance.pivot,
      'type': instance.type,
      'owner': instance.owner,
    };
