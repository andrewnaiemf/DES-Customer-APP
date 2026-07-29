part of 'app_version_cubit.dart';

abstract class AppVersionState {}

class AppVersionInitial extends AppVersionState {}

class AppVersionLoading extends AppVersionState {}

class AppVersionError extends AppVersionState {}

class AppVersionLoaded extends AppVersionState {
  final VersionModel model;
  final String localVersion;

  AppVersionLoaded({
    required this.model,
    required this.localVersion,
  });
}