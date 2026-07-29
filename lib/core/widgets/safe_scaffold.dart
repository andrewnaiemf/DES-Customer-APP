import 'package:flutter/material.dart';

/// Scaffold محسّن يتعامل مع Safe Area تلقائياً
/// يحل مشكلة Navigation Bar في Samsung والهواتف بـ Gesture Navigation
class SafeScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool resizeToAvoidBottomInset;
  
  /// هل تريد SafeArea للـ body؟
  /// false إذا كان لديك ListView بـ padding مخصص
  final bool safeAreaBody;
  
  /// هل تريد SafeArea للـ bottom navigation bar؟
  /// true بشكل افتراضي لتجنب تداخل Navigation Bar
  final bool safeAreaBottom;

  const SafeScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = true, // true لجعل المحتوى يمتد خلف bottom nav
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset = true,
    this.safeAreaBody = false, // false لأن ListView ستستخدم padding مخصص
    this.safeAreaBottom = true, // true لحماية bottom nav
  });

  @override
  Widget build(BuildContext context) {
    Widget? bodyWidget = body;
    
    // إضافة SafeArea للـ body إذا كان مطلوباً
    if (bodyWidget != null && safeAreaBody) {
      bodyWidget = SafeArea(
        bottom: !safeAreaBottom, // إذا bottom nav عليه SafeArea، لا نضيف هنا
        child: bodyWidget,
      );
    }
    
    // إضافة SafeArea للـ bottom navigation bar
    Widget? bottomNavWidget = bottomNavigationBar;
    if (bottomNavWidget != null && safeAreaBottom) {
      bottomNavWidget = SafeArea(
        top: false, // فقط bottom padding
        child: bottomNavWidget,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: bodyWidget,
      bottomNavigationBar: bottomNavWidget,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
