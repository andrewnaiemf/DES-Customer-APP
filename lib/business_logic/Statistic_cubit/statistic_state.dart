part of 'statistic_cubit.dart';

@immutable
abstract class StatisticState {}

class StatisticInitial extends StatisticState {}
class StatisticLoading extends StatisticState {}
class StatisticLoaded extends StatisticState {
  final  StatisticModel model;
  StatisticLoaded ({required this.model});
}
class StatisticError extends StatisticState {}
