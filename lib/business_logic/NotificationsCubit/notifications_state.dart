part of 'notifications_cubit.dart';

@immutable
abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}
class NotificationsLoading extends NotificationsState {}
class NotificationsLoaded extends NotificationsState {
  final  NotificationsModel model;
  NotificationsLoaded ({required this.model});
}
class NotificationsError extends NotificationsState {}
