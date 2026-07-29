import 'package:app/models/Notifications/notifications_model.dart';
import 'package:app/network/services/notifications_servixes.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitial());
  NotificationsServices notificationsServices =   NotificationsServices();
  static NotificationsCubit get(BuildContext context) => BlocProvider.of(context);
  NotificationsModel? getNotifications() {
    try {
      emit(NotificationsLoading());
      notificationsServices.getNotifications().then((value) {
        if (value != null) {
          emit(NotificationsLoaded(model: value));
        } else {
          emit(NotificationsError());
        }
      });
    } catch (e) {
      emit(NotificationsError());
    }
    return null;
  }
  bool? readNotifications(String notificationId) {
    try {
      notificationsServices.readNotifications(notificationId).then((value) {
        if (value != null) {
         if(value==true){
           try {
             notificationsServices.getNotifications().then((value) {
               if (value != null) {
                 emit(NotificationsLoaded(model: value));
               } else {
                 emit(NotificationsError());
               }
             });
           } catch (e) {
             emit(NotificationsError());
           }
         }
        } else {
          emit(NotificationsError());
        }
      });
    } catch (e) {
      emit(NotificationsError());
    }
    return null;
  }

  Future<bool?> readAllNotifications() async {
    try {
      // نحصل على الحالة الحالية للإشعارات
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final unreadNotifications = currentState.model.data!.data!
            .where((notification) => notification.read == 0)
            .toList();
        
        // نقرأ كل إشعار غير مقروء على حدة
        for (var notification in unreadNotifications) {
          await notificationsServices.readNotifications(notification.id.toString());
        }
        
        // بعد قراءة الكل، نحدث القائمة
        try {
          final updatedNotifications = await notificationsServices.getNotifications();
          if (updatedNotifications != null) {
            emit(NotificationsLoaded(model: updatedNotifications));
            return true;
          } else {
            emit(NotificationsError());
            return false;
          }
        } catch (e) {
          emit(NotificationsError());
          return false;
        }
      }
      return false;
    } catch (e) {
      emit(NotificationsError());
      return false;
    }
  }
}
