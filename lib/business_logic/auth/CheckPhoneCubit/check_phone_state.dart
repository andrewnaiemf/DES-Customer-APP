part of 'check_phone_cubit.dart';

@immutable
abstract class CheckPhoneState {}

class CheckPhoneInitial extends CheckPhoneState {}
class CheckPhoneLoading extends CheckPhoneState {}
class CheckPhoneLoaded extends CheckPhoneState {}
class CheckPhoneError extends CheckPhoneState {}
class CountryCodeChanged extends CheckPhoneState {}
