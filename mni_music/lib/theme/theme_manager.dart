// theme_manager.dart
import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  static const String LIGHT_THEME = 'light';
  static const String DARK_THEME = 'dark';
  static const String SYSTEM_THEME = 'system';

  String _currentTheme = SYSTEM_THEME;

  String get currentTheme => _currentTheme;

  void setTheme(String theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    switch (_currentTheme) {
      case LIGHT_THEME:
        return ThemeMode.light;
      case DARK_THEME:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}