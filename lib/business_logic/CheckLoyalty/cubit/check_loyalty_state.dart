part of 'check_loyalty_cubit.dart';

@immutable
sealed class CheckLoyaltyState {}

final class CheckLoyaltyInitial extends CheckLoyaltyState {}
class  CheckLoyaltyLoading extends CheckLoyaltyState {}
class  CheckLoyaltyLoaded extends CheckLoyaltyState {
  final  CheckLoyaltyModel model;
  CheckLoyaltyLoaded ({required this.model});
}
class  CheckLoyaltyError extends CheckLoyaltyState {}