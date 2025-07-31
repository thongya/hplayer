import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeService extends ChangeNotifier {
  final SharedPreferences prefs;
  ThemeData _themeData = ThemeData.dark();
  Color _primaryColor = Colors.deepPurple;
  Color _accentColor = Colors.tealAccent;
  bool _isDarkMode = true;

  ThemeService(this.prefs) {
    _loadTheme();
  }

  ThemeData getTheme() => _themeData;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;
  bool get isDarkMode => _isDarkMode;

  void _loadTheme() {
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    _primaryColor = Color(prefs.getInt('primary_color') ?? Colors.deepPurple.value);
    _accentColor = Color(prefs.getInt('accent_color') ?? Colors.tealAccent.value);
    _updateTheme();
  }

  void _updateTheme() {
    _themeData = _isDarkMode
        ? ThemeData.dark().copyWith(
      primaryColor: _primaryColor,
      hintColor: _accentColor,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _accentColor,
      ),
    )
        : ThemeData.light().copyWith(
      primaryColor: _primaryColor,
      hintColor: _accentColor,
      colorScheme: ColorScheme.light(
        primary: _primaryColor,
        secondary: _accentColor,
      ),
    );
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    prefs.setBool('is_dark_mode', _isDarkMode);
    _updateTheme();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    prefs.setInt('primary_color', color.value);
    _updateTheme();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    prefs.setInt('accent_color', color.value);
    _updateTheme();
  }
}