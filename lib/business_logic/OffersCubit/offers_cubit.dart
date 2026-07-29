import 'package:app/business_logic/orders/cubit/orders_cubit.dart';
import 'package:app/models/offers/OffersModel.dart';
import 'package:app/network/services/offers_services.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../models/ActionModel.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit() : super(OffersInitial());
  OffersServices services =   OffersServices();
  List<OfferData> offersList=[];
  int totalOffers=0;
  static OffersCubit get(BuildContext context) => BlocProvider.of(context);
  OffersModel? getOffers() {
    try {
      emit(OffersLoading());
      services.getOffers().then((value) {
        if (value != null) {
          totalOffers=value.data?.total??0;
          offersList=value.data?.data??[];
          emit(OffersLoaded(model: value));
        } else {
          emit(OffersError());
        }
      });
    } catch (e) {
      emit(OffersError());
    }
    return null;
  }
  ActionModel? declineOffer(String offerId,BuildContext context) {
    try {
      emit(OffersLoading());
      services.declineOffer(offerId).then((value) {
        if (value != null) {
          Navigator.pop(context);
          getOffers();
          // emit(OffersLoaded(model: value));
        } else {
          getOffers();
          emit(OffersError());
        }
      });
    } catch (e) {
      getOffers();
      emit(OffersError());
    }
    return null;
  }
  // ActionModel? acceptOffer({required String offerId,required String location,required String notes,required BuildContext context}) {
  //   try {
  //     emit(OffersLoading());
  //     services.acceptOffer(offerId:offerId,location: location,notes: notes).then((value) {
  //       if (value != null) {
  //         context.read<OrdersCubit>().getOrders();
  //         // Navigator.pop(context);
  //         getOffers();
  //         // emit(OffersLoaded(model: value));
  //       } else {
  //         getOffers();
  //         emit(OffersError());
  //       }
  //     });
  //   } catch (e) {
  //     getOffers();
  //     emit(OffersError());
  //   }
  //   return null;
  // }
  ActionModel? acceptOffer({
    required String offerId,
    required String location,
    required String notes,
  }) {
    emit(OffersLoading());

    services.acceptOffer(
      offerId: offerId,
      location: location,
      notes: notes,
    ).then((value) {
      if (value != null) {
        emit(OffersActionSuccess());
        getOffers();
      } else {
        emit(OffersError());
      }
    });
  }
}

