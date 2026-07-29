import 'dart:async';
import 'package:app/models/Statistics/statistics_model.dart';
import 'package:app/network/services/statistic_servixes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/realtime/home_realtime_service.dart';

part 'statistic_state.dart';

class StatisticCubit extends Cubit<StatisticState> {
  StatisticCubit() : super(StatisticInitial()) {
    _setupRealtimeListener();
  }
  
  StatisticServices statisticServices = StatisticServices();
  final HomeRealtimeService _realtimeService = HomeRealtimeService();
  StreamSubscription? _refreshSubscription;
  
  static StatisticCubit get(BuildContext context) => BlocProvider.of(context);
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Real-time Listener Setup
  // ═══════════════════════════════════════════════════════════════════════
  
  void _setupRealtimeListener() {
    _refreshSubscription = _realtimeService.refreshStream.listen((event) {
      // عند استقبال حدث تحديث، نقوم بجلب البيانات مجدداً
      getStatistic(silent: true);
    });
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Get Statistics
  // ═══════════════════════════════════════════════════════════════════════
  
  Future<StatisticModel?> getStatistic({bool silent = false}) async {
    try {
      if (!silent) {
        emit(StatisticLoading());
      }
      
      final value = await statisticServices.getStatistic();
      
      if (value != null) {
        emit(StatisticLoaded(model: value));
        return value;
      } else {
        print('⚠️ Statistics returned null');
        if (!silent) {
          emit(StatisticError());
        }
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Error in getStatistic cubit: $e');
      print('Stack trace: $stackTrace');
      if (!silent) {
        emit(StatisticError());
      }
      return null;
    }
  }

  @override
  Future<void> close() {
    _refreshSubscription?.cancel();
    return super.close();
  }
}
