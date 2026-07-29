import 'package:flutter/material.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:app/theme/app_themes.dart';

class AppThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  AppThemeProvider() {
    _loadThemeFromCache();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  bool get isInitialized => _isInitialized;

  // Load theme from cache
  Future<void> _loadThemeFromCache() async {
    final isDark = CacheHelper.getBool(key: 'isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _isInitialized = true;
    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await CacheHelper.setBool(key: 'isDarkMode', value: isDarkMode);
    notifyListeners();
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await CacheHelper.setBool(key: 'isDarkMode', value: isDarkMode);
    notifyListeners();
  }

  // Get themes from AppThemes class
  static ThemeData get lightTheme => AppThemes.lightTheme;
  static ThemeData get darkTheme => AppThemes.darkTheme;
}
