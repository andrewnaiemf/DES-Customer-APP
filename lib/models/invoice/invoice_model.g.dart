// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InVoiceModel _$InVoiceModelFromJson(Map<String, dynamic> json) => InVoiceModel(
      id: (json['id'] as num?)?.toInt(),
      contactId: (json['contact_id'] as num?)?.toInt(),
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      issueDate: json['issue_date'] as String?,
      dueDate: json['due_date'] as String?,
      status: json['status'] as String?,
      dueAmount: json['due_amount'] as String?,
      paidAmount: json['paid_amount'] as String?,
      total: json['total'] as String?,
      notes: json['notes'] as String?,
      pdf: json['pdf'] as String?,
      termsConditions: json['terms_conditions'],
      qrcodeString: json['qrcode_string'] as String?,
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      inventory: json['inventory'],
      type: json['type'] as String?,
      payments: (json['payments'] as List<dynamic>?)
          ?.map((e) => PaymentsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lineItems: (json['line_items'] as List<dynamic>?)
          ?.map((e) => LineItemsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      contact: json['contact'] == null
          ? null
          : UserModel.fromJson(json['contact'] as Map<String, dynamic>),
      owner: json['owner'] == null
          ? null
          : OwnerModel.fromJson(json['owner'] as Map<String, dynamic>),
    )..updatedAt = json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at'] as String);

Map<String, dynamic> _$InVoiceModelToJson(InVoiceModel instance) =>
    <String, dynamic>{
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
      'pdf': instance.pdf,
      'terms_conditions': instance.termsConditions,
      'qrcode_string': instance.qrcodeString,
      'payment_method': instance.paymentMethod,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'inventory': instance.inventory,
      'type': instance.type,
      'payments': instance.payments,
      'line_items': instance.lineItems,
      'contact': instance.contact,
      'owner': instance.owner,
    };
