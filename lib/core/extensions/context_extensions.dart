import 'package:flutter/material.dart';

/// Extension للحصول على Safe Padding بسهولة
/// يحل مشكلة Navigation Bar في Samsung والهواتف بـ Gesture Navigation
extension SafePaddingExtension on BuildContext {
  /// Padding للـ Navigation Bar (الأسفل)
  double get bottomSafePadding => MediaQuery.of(this).viewPadding.bottom;
  
  /// Padding للـ Status Bar (الأعلى)
  double get topSafePadding => MediaQuery.of(this).viewPadding.top;
  
  /// Padding لكل الجوانب
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).viewPadding;
  
  /// Padding جاهز للـ ListView
  /// يضيف padding أسفل القائمة لتجنب تداخل Navigation Bar
  EdgeInsets get listViewSafePadding => EdgeInsets.only(
    bottom: MediaQuery.of(this).viewPadding.bottom + 16,
  );
  
  /// Padding جاهز للـ ListView مع BottomNavigationBar
  /// navHeight: ارتفاع الـ BottomNavigationBar (default: kBottomNavigationBarHeight)
  EdgeInsets listViewPaddingWithBottomNav({
    double navHeight = kBottomNavigationBarHeight,
  }) {
    return EdgeInsets.only(
      bottom: MediaQuery.of(this).viewPadding.bottom + navHeight + 16,
    );
  }
  
  /// Padding للـ GridView
  EdgeInsets get gridViewSafePadding => EdgeInsets.only(
    bottom: MediaQuery.of(this).viewPadding.bottom + 16,
  );
  
  /// Padding للـ GridView مع BottomNavigationBar
  EdgeInsets gridViewPaddingWithBottomNav({
    double navHeight = kBottomNavigationBarHeight,
  }) {
    return EdgeInsets.only(
      bottom: MediaQuery.of(this).viewPadding.bottom + navHeight + 16,
    );
  }
  
  /// Padding للـ ScrollView العامة
  EdgeInsets get scrollViewSafePadding => EdgeInsets.only(
    top: 16,
    bottom: MediaQuery.of(this).viewPadding.bottom + 16,
    left: 16,
    right: 16,
  );
  
  /// Padding للـ ScrollView مع BottomNavigationBar
  EdgeInsets scrollViewPaddingWithBottomNav({
    double navHeight = kBottomNavigationBarHeight,
  }) {
    return EdgeInsets.only(
      top: 16,
      bottom: MediaQuery.of(this).viewPadding.bottom + navHeight + 16,
      left: 16,
      right: 16,
    );
  }
}
