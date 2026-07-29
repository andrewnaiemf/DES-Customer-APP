import 'dart:developer';

import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:app/network/dio_helper.dart';
import 'package:app/network/services/statistic_servixes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'translation_state.dart';

class TranslationCubit extends Cubit<TranslationState> {
  TranslationCubit() : super(TranslationInitial());

  static TranslationCubit get(BuildContext context) => BlocProvider.of(context);
  StatisticServices statisticServices =   StatisticServices();
  List<String> langs = ['ar', 'en'];
  String currentSelectedLang = CacheHelper.getString(key: "lang") ?? "en";

  bool isLoading = false;

  void changAppLang(BuildContext context, String lang) async {
    isLoading = true;
    emit(ChangAppLang());
    changeLocale(userId: "${ProfileCubit.get(context).userModel?.id}", locale: lang);
    try {
      currentSelectedLang = lang;
      await CacheHelper.setString(key: "lang", value: lang).then((value) async {
        context.setLocale(Locale(lang));
        DioHelper.init();
        emit(ChangAppLang());
      });

      isLoading = false;

      emit(ChangAppLang());
    } catch (e) {
      isLoading = false;

      emit(ChangAppLang());
      log(e.toString());
    }
  }
  bool? changeLocale({required String userId,required String locale}) {
    try {
      statisticServices.changeLocale(userId: userId, locale: locale).then((value) {});
    } catch (e) {
      print("changeLocale Error $e");
    }
    return null;
  }
}
