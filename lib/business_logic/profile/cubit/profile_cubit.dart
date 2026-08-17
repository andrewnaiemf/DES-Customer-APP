import 'dart:developer';
import 'dart:io';

import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/user/user_model.dart';
import 'package:app/network/services/profile_service.dart';
import 'package:dio/dio.dart';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({UserModel? initialUserModel}) : super(ProfileInitial()) {
    userModel = initialUserModel ?? ProfileServices.loadCachedUser();
    if (userModel != null) {
      _lastFetchTime = DateTime.now();
      // Wait a microtask to emit success so listeners can catch it
      Future.microtask(() => emit(GetProfileSuccess()));
    }
  }

  static ProfileCubit get(BuildContext context) => BlocProvider.of(context);

  bool isLoadingProfile = false;
  bool isLoading = false;
  bool isLoadingUpdate = false;
  bool isLoadingChangeNotifications = false;
  bool isLoadingChangePassword = false;

  UserModel? userModel;
  DateTime? _lastFetchTime; // ✅ Cache timer
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  void setUser(UserModel user) {
    userModel = user;
    _lastFetchTime = DateTime.now();
    ProfileServices.cacheUser(user);
    emit(GetProfileSuccess());
  }

  Future<void> getProfile({bool forceRefresh = false}) async {
    // ✅ تجنب إعادة تحميل البيانات إذا الكاش صالح
    if (!forceRefresh && userModel != null && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return;
    }
    isLoadingProfile = true;
    emit(GetProfileLoading());
    try {
      final fetched = await ProfileServices.getProfile();
      if (fetched != null) {
        userModel = fetched;
        _lastFetchTime = DateTime.now();
      } else if (userModel == null) {
        userModel = ProfileServices.loadCachedUser();
      }

      isLoadingProfile = false;
      emit(GetProfileSuccess());
    } catch (e) {
      isLoadingProfile = false;
      emit(GetProfileError());
      log('$e');
    }
  }

  Future<void> changePassword(String password, BuildContext context) async {
    isLoadingChangePassword = true;
    emit(ChangePasswordLoading());
    try {
      Response? response = await ProfileServices.updatePassword(
        phone: userModel!.phoneNumber,
        password: password,
      );

      if (response?.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showMessage(context: context, message: '${response?.data['msg']}', color: Colors.green);

        // ignore: use_build_context_synchronously
        await getProfile();

        // ignore: use_build_context_synchronously
        MyNavigator.back(context);
      }

      isLoadingChangePassword = false;
      emit(ChangePasswordSuccess());
    } catch (e) {
      isLoadingChangePassword = false;
      log(e.toString());
      emit(ChangePasswordError());
    }
  }
}
