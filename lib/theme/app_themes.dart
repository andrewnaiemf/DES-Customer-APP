import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/theme/colors.dart';

class AppThemes {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: MyColors.perpel,
    scaffoldBackgroundColor: MyColors.lightgray,
    fontFamily: 'SF-Arabic',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'SF-Arabic'),
      displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'SF-Arabic'),
      displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'SF-Arabic'),
      headlineLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'SF-Arabic'),
      headlineMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'SF-Arabic'),
      headlineSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'SF-Arabic'),
      titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic'),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic'),
      titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic'),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontFamily: 'SF-Arabic'),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, fontFamily: 'SF-Arabic'),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'SF-Arabic'),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic'),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic'),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic'),
    ),
    colorScheme: const ColorScheme.light(
      primary: MyColors.perpel,
      secondary: MyColors.lightgreen,
      surface: Colors.white,
      background: MyColors.lightgray,
      onPrimary: Colors.white,
      onSecondary: MyColors.black,
      onSurface: MyColors.black,
      onBackground: MyColors.black,
      error: MyColors.red2,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: MyColors.perpel, size: 20),
      titleTextStyle: TextStyle(
        color: MyColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF-Arabic',
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: MyColors.perpel,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.perpel,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MyColors.lightgray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: MyColors.darkgray.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MyColors.perpel, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MyColors.red2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    dividerTheme: DividerThemeData(
      color: MyColors.darkgray.withOpacity(0.3),
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: MyColors.perpel,
    scaffoldBackgroundColor: MyColors.background,
    fontFamily: 'SF-Arabic',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'SF-Arabic', color: Colors.white),
      displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'SF-Arabic', color: Colors.white),
      displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'SF-Arabic', color: Colors.white),
      headlineLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'SF-Arabic', color: Colors.white),
      headlineMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'SF-Arabic', color: Colors.white),
      headlineSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'SF-Arabic', color: Colors.white),
      titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic', color: Colors.white),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic', color: Colors.white),
      titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic', color: Colors.white),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontFamily: 'SF-Arabic', color: Colors.white),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, fontFamily: 'SF-Arabic', color: Colors.white),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'SF-Arabic', color: Colors.white),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic', color: Colors.white),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic', color: Colors.white),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'SF-Arabic', color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: MyColors.perpel,
      secondary: MyColors.lightgreen,
      surface: MyColors.dark,
      background: MyColors.background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      error: MyColors.red2,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: MyColors.lightgreen, size: 20),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF-Arabic',
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: MyColors.dark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: MyColors.lightgreen,
      foregroundColor: MyColors.dark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.perpel,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MyColors.perpel, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MyColors.red2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: MyColors.darkgray),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MyColors.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
