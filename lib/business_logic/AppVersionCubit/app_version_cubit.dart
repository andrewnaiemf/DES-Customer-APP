import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/VersionModel.dart';
import '../../network/services/offers_services.dart';

part 'app_version_state.dart';

class AppVersionCubit extends Cubit<AppVersionState> {
  AppVersionCubit() : super(AppVersionInitial());

  OffersServices services = OffersServices();

  static AppVersionCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> getAppVersion() async {
    emit(AppVersionLoading());

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version;

      final value = await services.getAppVersion();

      if (value != null) {
        emit(AppVersionLoaded(
          model: value,
          localVersion: localVersion,
        ));
      } else {
        emit(AppVersionError());
      }
    } catch (e) {
      emit(AppVersionError());
    }
  }
}