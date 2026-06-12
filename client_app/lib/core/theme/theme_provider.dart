import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'theme_colors.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme_name';
  static const String _darkModeKey = 'dark_mode_enabled';

  late SharedPreferences _prefs;
  ThemeColorPalette _currentTheme = AppThemeColors.pharmacyGreen;
  bool _isDarkMode = false;

  ThemeColorPalette get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  ThemeData get lightTheme => AppTheme.buildLightTheme(seedColor: _currentTheme.primary);
  ThemeData get darkTheme => AppTheme.buildDarkTheme(seedColor: _currentTheme.primary);

  /// Initialize the ThemeProvider with saved preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final savedThemeName =
        _prefs.getString(_themeKey) ?? AppThemeColors.pharmacyGreen.name;
    _currentTheme = AppThemeColors.getThemeByName(savedThemeName);
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;

    AppBpColors.setTheme(_currentTheme);
    AppBpColors.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Change the current theme
  Future<void> setTheme(ThemeColorPalette theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    AppBpColors.setTheme(theme);

    notifyListeners();

    try {
      await _prefs.setString(_themeKey, theme.name);
    } catch (error) {
      debugPrint('Failed to persist theme preference: $error');
    }
  }

  /// Toggle dark mode
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;

    _isDarkMode = isDark;
    AppBpColors.setDarkMode(isDark);

    notifyListeners();

    try {
      await _prefs.setBool(_darkModeKey, isDark);
    } catch (error) {
      debugPrint('Failed to persist theme mode: $error');
    }
  }

  /// Reset to default theme and light mode
  Future<void> resetAppearance() async {
    _currentTheme = AppThemeColors.pharmacyGreen;
    _isDarkMode = false;

    AppBpColors.setTheme(_currentTheme);
    AppBpColors.setDarkMode(false);

    notifyListeners();

    try {
      await _prefs.setString(_themeKey, AppThemeColors.pharmacyGreen.name);
      await _prefs.setBool(_darkModeKey, false);
    } catch (error) {
      debugPrint('Failed to persist appearance reset: $error');
    }
  }

  /// Optional helper to reset to defaults on app start based on a flag
  Future<void> resetToDefaultIfNeeded({required bool forceReset}) async {
    if (forceReset) {
      await resetAppearance();
    }
  }

  /// Get all available themes
  List<ThemeColorPalette> get availableThemes => AppThemeColors.allThemes;
}
