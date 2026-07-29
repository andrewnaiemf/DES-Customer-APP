// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branche_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrancheModel _$BrancheModelFromJson(Map<String, dynamic> json) => BrancheModel(
      id: (json['id'] as num).toInt(),
      locale: json['locale'] as String,
      name: json['name'] as String,
      organization: json['organization'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String,
      taxNumber: json['tax_number'] as String,
      status: json['status'] as String,
      rememberToken: json['remember_token'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BrancheModelToJson(BrancheModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locale': instance.locale,
      'name': instance.name,
      'organization': instance.organization,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'tax_number': instance.taxNumber,
      'status': instance.status,
      'remember_token': instance.rememberToken,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
