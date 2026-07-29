import 'package:app/persentation/screens/home/home_screen.dart';
import 'package:app/persentation/screens/orders/orders_screen.dart';
import 'package:app/persentation/screens/profile/profile_screen.dart';
import 'package:app/persentation/screens/reports/repors_screen.dart';
import 'package:app/persentation/screens/warranty/warranty_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/constants/assets.dart';

part 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());
  static LayoutCubit get(BuildContext context) => BlocProvider.of(context);

  int bottomNavBarIndex = 0;

  void changeScreen(int index) {
    if (bottomNavBarIndex == index) return; // ✅ تجنب إعادة البناء إذا نفس الشاشة
    bottomNavBarIndex = index;
    emit(ChangeScreenState());
  }

  // ✅ استخدام const للشاشات لمنع إعادة إنشائها
  // final List<Widget> layoutBody = const [
  //   HomeScreen(),
  //   OrdersScreen(),
  //   ReportsScreen(),
  //   // WarrantyMainScreen(isActive: null,),
  //   WarrantyMainScreen(
  //     key: const ValueKey('warranty'),
  //     isActive: cubit.bottomNavBarIndex == 3,
  //   ),
  //   ProfileScreen(),
  // ];

  // List<BottomNavBarIcons> bottomNavBarIcons = [
  //   BottomNavBarIcons(
  //     index: 0,
  //     name: 'Home',
  //     svg: Assets.newHome,
  //   ),
  //   BottomNavBarIcons(
  //     index: 1,
  //     name: 'My bookings',
  //     svg: Assets.newCanleder,
  //   ),
  //   BottomNavBarIcons(
  //     index: 2,
  //     name: 'ASK',
  //     svg: Assets.chat,
  //   ),
  //   BottomNavBarIcons(
  //     index: 3,
  //     name: 'News',
  //     svg: Assets.newNews,
  //   ),
  // ];
}
