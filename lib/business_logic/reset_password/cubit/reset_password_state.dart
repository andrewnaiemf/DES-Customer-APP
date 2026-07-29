part of 'reset_password_cubit.dart';

@immutable
class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {}

class ResetPasswordError extends ResetPasswordState {}

class ShowPasswordState extends ResetPasswordState {}
