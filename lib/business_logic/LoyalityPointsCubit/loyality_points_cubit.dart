import 'package:app/models/LoyaltyPointsModel.dart';
import 'package:app/network/services/loyality_servixes.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'loyality_points_state.dart';

class LoyalityPointsCubit extends Cubit<LoyalityPointsState> {
  LoyalityPointsCubit() : super(LoyalityPointsInitial());
  LoyalityServices services =   LoyalityServices();
  static LoyalityPointsCubit get(BuildContext context) => BlocProvider.of(context);
  LoyaltyPointsModel? getLoyalityPoints() {
    try {
      emit(LoyalityPointsLoading());
      services.getLoyalityPoints().then((value) {
        if (value != null) {
          emit(LoyalityPointsLoaded(model: value));
        } else {
          emit(LoyalityPointsError());
        }
      });
    } catch (e) {
      emit(LoyalityPointsError());
    }
    return null;
  }
}
