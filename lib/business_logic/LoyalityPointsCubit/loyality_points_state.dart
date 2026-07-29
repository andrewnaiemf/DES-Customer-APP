part of 'loyality_points_cubit.dart';

@immutable
sealed class LoyalityPointsState {}

final class LoyalityPointsInitial extends LoyalityPointsState {}
class LoyalityPointsLoading extends LoyalityPointsState {}
class LoyalityPointsLoaded extends LoyalityPointsState {
  final  LoyaltyPointsModel model;
  LoyalityPointsLoaded ({required this.model});
}
class LoyalityPointsError extends LoyalityPointsState {}