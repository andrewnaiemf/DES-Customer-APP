part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class GetProfileLoading extends ProfileState {}

final class GetProfileSuccess extends ProfileState {}

final class GetProfileError extends ProfileState {}

final class UpdateProfileLoading extends ProfileState {}

final class UpdateProfileSuccess extends ProfileState {}

final class UpdateProfileError extends ProfileState {}

final class ChangePasswordLoading extends ProfileState {}

final class ChangePasswordSuccess extends ProfileState {}

final class ChangePasswordError extends ProfileState {}

class ChangeImageLoading extends ProfileState {}

class ChangeImageSuccess extends ProfileState {}

class ChangeImageError extends ProfileState {}
