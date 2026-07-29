import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyColors {
  // Brand Colors
  static const Color yellow = Color.fromRGBO(217, 179, 29, 1.0);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color perpel = Color(0xFF6842E2);
  static const Color lightgreen = Color(0xFF28E6C5);
  static const Color darkgray = Color(0xFFC6CBE0);
  static const Color lightgray = Color(0xFFF9FAFB);

  // Extended Colors
  static const Color whiteColor = Colors.white;
  static const Color mainColor = perpel;
  static const Color gray = Color(0xFFE8E8E8);
  static const Color gray2 = Color(0xFF7B7B7B);
  static const Color green = Color(0xFF4CAF50);
  static const Color green2 = lightgreen; // Alias for lightgreen
  static const Color red2 = Color(0xFFFF4757);
  static const Color redColor = red2; // Alias for red2
  static const Color scaffoldColor = lightgray;

  // MaterialColor for primarySwatch
  static const MaterialColor mainColorSwatch = MaterialColor(
    0xFF6842E2,
    <int, Color>{
      50: Color(0xFFEDE7FC),
      100: Color(0xFFD1C3F7),
      200: Color(0xFFB39BF2),
      300: Color(0xFF9473ED),
      400: Color(0xFF7E55E9),
      500: Color(0xFF6842E2),
      600: Color(0xFF603CDF),
      700: Color(0xFF5533DA),
      800: Color(0xFF4B2BD6),
      900: Color(0xFF3A1DCF),
    },
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [perpel, Color(0xFF8B6EE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [lightgreen, Color(0xFF5BEAD9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [dark, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class MyFonts {
  static const String font = 'SF-Arabic';
}

// ==================== Theme Provider ====================
class AppThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // تحميل الثيم المحفوظ عند بدء التطبيق
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // حفظ الثيم عند التغيير
  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme(mode == ThemeMode.dark);
    notifyListeners();
  }

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: MyColors.perpel,
    scaffoldBackgroundColor: MyColors.lightgray,
    fontFamily: MyFonts.font,
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
      iconTheme: IconThemeData(color: MyColors.perpel),
      titleTextStyle: TextStyle(
        color: MyColors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: MyFonts.font,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: MyColors.perpel,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.perpel,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MyColors.lightgray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: MyColors.darkgray.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MyColors.perpel, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MyColors.red2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    fontFamily: MyFonts.font,
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
      iconTheme: IconThemeData(color: MyColors.lightgreen),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: MyFonts.font,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: MyColors.dark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: MyColors.lightgreen,
      foregroundColor: MyColors.dark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.perpel,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MyColors.perpel, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MyColors.red2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: MyColors.darkgray),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MyColors.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
  );
}
