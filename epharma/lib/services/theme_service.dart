import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  Color _primaryColor = const Color(0xFF6366F1); // Default Indigo
  ThemeMode _themeMode = ThemeMode.light;

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _primaryColor,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _primaryColor,
    brightness: Brightness.dark,
  );
}
