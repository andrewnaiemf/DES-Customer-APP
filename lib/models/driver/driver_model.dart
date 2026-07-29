import 'package:app/models/branche/branche_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DriverModel {
  late int id;
  late List<String?> deviceToken;
  late String locale;
  late String name;
  late String phoneNumber;
  late String status;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String password;

  DriverModel({
    required this.id,
    required this.deviceToken,
    required this.locale,
    required this.name,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.password,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverModelToJson(this);
}
