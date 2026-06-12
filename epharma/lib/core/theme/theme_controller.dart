import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'color_tokens.dart';
import 'theme_extensions.dart';

class ThemeController extends ChangeNotifier {
  static const String _seedColorKey = 'theme_seed_color';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _legacyThemeNameKey = 'selected_theme_name';

  static ThemeController? _instance;

  static ThemeController? get instance => _instance;

  late SharedPreferences _prefs;
  bool _initialized = false;

  Color _seedColor = AppThemeColors.pharmacyGreen.seedColor;
  bool _isDarkMode = false;

  Color? _previewSeedColor;
  bool? _previewDarkMode;
  bool _previewActive = false;

  ThemeController() {
    _instance = this;
  }

  bool get isInitialized => _initialized;

  bool get isDarkMode => _isDarkMode;

  Color get seedColor => _seedColor;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeColorPalette get currentTheme =>
      AppThemeColors.presetFromSeed(_seedColor) ??
      ThemeColorPalette(
        name: 'Couleur personnalisée',
        seedColor: _seedColor,
        icon: Icons.palette_rounded,
      );

  ThemeColorPalette get previewTheme =>
      _previewActive
          ? (AppThemeColors.presetFromSeed(_previewSeedColor ?? _seedColor) ??
                ThemeColorPalette(
                  name: 'Couleur personnalisée',
                  seedColor: _previewSeedColor ?? _seedColor,
                  icon: Icons.palette_rounded,
                ))
          : currentTheme;

  bool get isPreviewing => _previewActive;

  Color get previewSeedColor => _previewSeedColor ?? _seedColor;

  bool get previewDarkMode => _previewDarkMode ?? _isDarkMode;

  ThemeData get lightTheme => AppTheme.buildTheme(
        seedColor: _seedColor,
        brightness: Brightness.light,
      );

  ThemeData get darkTheme => AppTheme.buildTheme(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      );

  ThemeData previewThemeData({Brightness? brightness}) {
    return AppTheme.buildTheme(
      seedColor: previewSeedColor,
      brightness: brightness ??
          (previewDarkMode ? Brightness.dark : Brightness.light),
    );
  }

  ColorScheme get colorScheme => buildAppColorScheme(
        seedColor: _seedColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      );

  ColorScheme get previewColorScheme => buildAppColorScheme(
        seedColor: previewSeedColor,
        brightness: previewDarkMode ? Brightness.dark : Brightness.light,
      );

  AppThemeExtension get themeExtension => AppThemeExtension.fromScheme(colorScheme);

  AppThemeExtension get previewThemeExtension =>
      AppThemeExtension.fromScheme(previewColorScheme);

  List<ThemeColorPalette> get availableThemes => AppThemeColors.allThemes;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _seedColor = _restoreSeedColor();
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setTheme(ThemeColorPalette theme) async {
    await setSeedColor(theme.seedColor, persistName: theme.name);
  }

  Future<void> setSeedColor(
    Color seedColor, {
    String? persistName,
  }) async {
    if (_seedColor.value == seedColor.value) {
      return;
    }

    _seedColor = seedColor;
    _clearPreview();
    notifyListeners();

    await _persistAppearance(persistName: persistName);
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) {
      return;
    }

    _isDarkMode = isDark;
    _clearPreview();
    notifyListeners();

    try {
      await _prefs.setBool(_darkModeKey, isDark);
    } catch (error) {
      debugPrint('Failed to persist theme mode: $error');
    }
  }

  void startPreview({
    Color? seedColor,
    bool? darkMode,
  }) {
    _previewActive = true;
    _previewSeedColor = seedColor ?? _seedColor;
    _previewDarkMode = darkMode ?? _isDarkMode;
    notifyListeners();
  }

  void updatePreview({
    Color? seedColor,
    bool? darkMode,
  }) {
    if (!_previewActive) {
      startPreview(seedColor: seedColor, darkMode: darkMode);
      return;
    }

    if (seedColor != null) {
      _previewSeedColor = seedColor;
    }
    if (darkMode != null) {
      _previewDarkMode = darkMode;
    }
    notifyListeners();
  }

  Future<void> commitPreview({String? persistName}) async {
    if (!_previewActive) {
      return;
    }

    _seedColor = _previewSeedColor ?? _seedColor;
    _isDarkMode = _previewDarkMode ?? _isDarkMode;
    _clearPreview();
    notifyListeners();

    await _persistAppearance(persistName: persistName);
    try {
      await _prefs.setBool(_darkModeKey, _isDarkMode);
    } catch (error) {
      debugPrint('Failed to persist theme mode: $error');
    }
  }

  void cancelPreview() {
    if (!_previewActive) {
      return;
    }

    _clearPreview();
    notifyListeners();
  }

  Future<void> resetAppearance() async {
    _seedColor = AppThemeColors.pharmacyGreen.seedColor;
    _isDarkMode = false;
    _clearPreview();
    notifyListeners();

    try {
      await _prefs.setInt(_seedColorKey, _seedColor.value);
      await _prefs.setString(_legacyThemeNameKey, AppThemeColors.pharmacyGreen.name);
      await _prefs.setBool(_darkModeKey, false);
    } catch (error) {
      debugPrint('Failed to persist appearance reset: $error');
    }
  }

  Future<void> resetToDefaultIfNeeded({required bool forceReset}) async {
    if (forceReset) {
      await resetAppearance();
    }
  }

  Color _restoreSeedColor() {
    final storedSeedValue = _prefs.getInt(_seedColorKey);
    if (storedSeedValue != null) {
      return Color(storedSeedValue);
    }

    final savedThemeName = _prefs.getString(_legacyThemeNameKey);
    if (savedThemeName != null && savedThemeName.isNotEmpty) {
      return AppThemeColors.getThemeByName(savedThemeName).seedColor;
    }

    return AppThemeColors.pharmacyGreen.seedColor;
  }

  void _clearPreview() {
    _previewActive = false;
    _previewSeedColor = null;
    _previewDarkMode = null;
  }

  Future<void> _persistAppearance({String? persistName}) async {
    try {
      await _prefs.setInt(_seedColorKey, _seedColor.value);
      await _prefs.setString(
        _legacyThemeNameKey,
        persistName ?? currentTheme.name,
      );
    } catch (error) {
      debugPrint('Failed to persist theme preference: $error');
    }
  }
}
