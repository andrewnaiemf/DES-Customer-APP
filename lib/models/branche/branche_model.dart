import 'package:json_annotation/json_annotation.dart';

part 'branche_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BrancheModel {
  late int id;
  // late List<String?> deviceToken;
  late String locale;
  late String name;
  late String organization;
  late String? email;
  late String phoneNumber;
  late String taxNumber;
  late String status;
  late dynamic rememberToken;
  late DateTime createdAt;
  late DateTime updatedAt;

  BrancheModel({
    required this.id,
    // required this.deviceToken,
    required this.locale,
    required this.name,
    required this.organization,
    required this.email,
    required this.phoneNumber,
    required this.taxNumber,
    required this.status,
    required this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrancheModel.fromJson(Map<String, dynamic> json) => _$BrancheModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrancheModelToJson(this);
}
