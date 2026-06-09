import 'package:flutter/material.dart';
import '../widgets/bp_theme.dart';

class ThemeService extends ChangeNotifier {
  Color _primaryColor = BpColors.accent;
  ThemeMode _themeMode = ThemeMode.dark;

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: BpColors.accent,
      onPrimary: Colors.white,
      secondary: BpColors.primaryLight,
      onSecondary: Colors.white,
      background: BpColors.scaffold,
      onBackground: BpColors.textPrimary,
      surface: BpColors.surface,
      onSurface: BpColors.textPrimary,
      error: BpColors.error,
      onError: Colors.white,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: BpColors.scaffold,
    canvasColor: BpColors.scaffold,
    cardColor: BpColors.surfaceStrong,
    appBarTheme: const AppBarTheme(
      backgroundColor: BpColors.surfaceStrong,
      foregroundColor: BpColors.textPrimary,
      elevation: 0,
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: BpColors.accent,
      onPrimary: Colors.white,
      secondary: BpColors.primaryLight,
      onSecondary: Colors.white,
      background: BpColors.scaffold,
      onBackground: BpColors.textPrimary,
      surface: BpColors.surface,
      onSurface: BpColors.textPrimary,
      error: BpColors.error,
      onError: Colors.white,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: BpColors.scaffold,
    canvasColor: BpColors.scaffold,
    cardColor: BpColors.surfaceStrong,
  );
}
