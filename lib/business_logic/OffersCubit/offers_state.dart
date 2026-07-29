part of 'offers_cubit.dart';

@immutable
sealed class OffersState {}

final class OffersInitial extends OffersState {}
final class OffersLoading extends OffersState {}
final class OffersLoaded extends OffersState {
  final OffersModel model ;
  OffersLoaded({required this.model});
}
final class OffersError extends OffersState {}
final class OffersActionSuccess extends OffersState {}
