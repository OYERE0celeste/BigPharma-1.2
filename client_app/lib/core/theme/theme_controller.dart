import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'color_tokens.dart';

/// Theme Mode
enum BpThemeMode { light, dark, system }

/// Theme Controller - Manages theme state and persistence
///
/// Handles:
/// - Theme mode changes (light, dark, system)
/// - Custom seed colors
/// - Persistence to SharedPreferences
/// - Smooth transitions between themes
class BpThemeController extends ChangeNotifier {
  static final BpThemeController _instance = BpThemeController._internal();

  factory BpThemeController() {
    return _instance;
  }

  BpThemeController._internal() {
    _initialize();
  }

  // Private variables
  late SharedPreferences _prefs;
  BpThemeMode _themeMode = BpThemeMode.system;
  Color _seedColor = BpColorTokens.brandPrimary;
  bool _isInitialized = false;

  // Getters
  BpThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  bool get isInitialized => _isInitialized;

  // Keys for SharedPreferences
  static const String _themeModeKey = 'bp_theme_mode';
  static const String _seedColorKey = 'bp_seed_color';

  /// Initialize theme controller
  /// Must be called before app starts to load persisted theme
  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load saved theme mode
      final savedMode = _prefs.getString(_themeModeKey);
      if (savedMode != null) {
        _themeMode = BpThemeMode.values.byName(savedMode);
      }

      // Load saved seed color
      final savedColorInt = _prefs.getInt(_seedColorKey);
      if (savedColorInt != null) {
        _seedColor = Color(savedColorInt);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing theme controller: $e');
      _isInitialized = false;
    }
  }

  /// Ensure initialization is complete before using
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    await _initialize();
  }

  /// Set theme mode
  Future<void> setThemeMode(BpThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  /// Set seed color (for dynamic theme generation)
  Future<void> setSeedColor(Color color) async {
    if (_seedColor.value == color.value) return;

    _seedColor = color;
    await _prefs.setInt(_seedColorKey, color.value);
    notifyListeners();
  }

  /// Reset theme to defaults
  Future<void> resetToDefaults() async {
    _themeMode = BpThemeMode.system;
    _seedColor = BpColorTokens.brandPrimary;

    await _prefs.remove(_themeModeKey);
    await _prefs.remove(_seedColorKey);

    notifyListeners();
  }

  /// Get current theme data based on system brightness
  ThemeData getLightTheme() {
    return BpAppTheme.buildLightTheme(seedColor: _seedColor);
  }

  ThemeData getDarkTheme() {
    return BpAppTheme.buildDarkTheme(seedColor: _seedColor);
  }

  /// Get theme data for specific brightness
  ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? getDarkTheme() : getLightTheme();
  }

  /// Get high contrast variant of theme
  ThemeData getHighContrastLightTheme() {
    // This could be enhanced with accessibility color adjustments
    return getLightTheme();
  }

  ThemeData getHighContrastDarkTheme() {
    // This could be enhanced with accessibility color adjustments
    return getDarkTheme();
  }
}

/// Global theme controller instance
final bpThemeController = BpThemeController();
