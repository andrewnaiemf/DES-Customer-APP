part of 'exports_cubit.dart';

@immutable
sealed class ExportsState {}

final class ExportsInitial extends ExportsState {}

final class ExportLoading extends ExportsState {}

final class ExportSuccess extends ExportsState {}

final class ExportError extends ExportsState {}
