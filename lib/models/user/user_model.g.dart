// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      deviceToken: (json['device_token'] as List<dynamic>)
          .map((e) => e as String?)
          .toList(),
      locale: json['locale'] as String,
      name: json['name'] as String,
      points: json['points'] as String,
      organization: json['organization'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String,
      taxNumber: json['tax_number'] as String,
      status: json['status'] as String,
      rememberToken: json['remember_token'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      closingBalance: (json['closing_balance'] as num).toDouble(),
      overdue: (json['overdue'] as num).toDouble(),
      totalInvoicesCount: (json['total_invoices_count'] as num).toInt(),
      totalInvoicesAmount: (json['total_invoices_amount'] as num).toDouble(),
      totalOutStanding: (json['total_out_standing'] as num).toDouble(),
      totalPaid: (json['total_paid'] as num).toDouble(),
    )..branches = (json['branches'] as List<dynamic>?)
        ?.map((e) => BrancheModel.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'device_token': instance.deviceToken,
      'locale': instance.locale,
      'name': instance.name,
      'organization': instance.organization,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'tax_number': instance.taxNumber,
      'status': instance.status,
      'points': instance.points,
      'remember_token': instance.rememberToken,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'closing_balance': instance.closingBalance,
      'overdue': instance.overdue,
      'total_invoices_count': instance.totalInvoicesCount,
      'total_invoices_amount': instance.totalInvoicesAmount,
      'total_out_standing': instance.totalOutStanding,
      'total_paid': instance.totalPaid,
      'branches': instance.branches,
    };
