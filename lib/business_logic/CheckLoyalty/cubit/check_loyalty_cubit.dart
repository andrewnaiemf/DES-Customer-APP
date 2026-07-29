import 'package:app/models/CheckLoyaltyModel.dart';
import 'package:app/network/services/orders_services.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'check_loyalty_state.dart';

class CheckLoyaltyCubit extends Cubit<CheckLoyaltyState> {
  CheckLoyaltyCubit() : super(CheckLoyaltyInitial());
  OrdersServices services =   OrdersServices();
  static CheckLoyaltyCubit get(BuildContext context) => BlocProvider.of(context);
  CheckLoyaltyModel? getCheckLoyaltyCubit() {
    try {
      emit(CheckLoyaltyLoading());
      services.checkLoyalty().then((value) {
        if (value != null) {
          emit(CheckLoyaltyLoaded(model: value));
        } else {
          emit(CheckLoyaltyError());
        }
      });
    } catch (e) {
      emit(CheckLoyaltyError());
    }
    return null;
  }
}
