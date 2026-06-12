export 'color_tokens.dart';

import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'theme_controller.dart';
import 'theme_extensions.dart';

/// Compatibility wrapper used by the existing codebase.
class AppBpColors {
  AppBpColors._();

  static ThemeController? get _controller => ThemeController.instance;

  static ColorScheme get _colorScheme =>
      _controller?.colorScheme ??
      buildAppColorScheme(
        seedColor: AppThemeColors.pharmacyGreen.seedColor,
        brightness: Brightness.light,
      );

  static AppThemeExtension get _tokens =>
      _controller?.themeExtension ?? AppThemeExtension.fromScheme(_colorScheme);

  static bool get isLightTheme => _controller?.themeMode != ThemeMode.dark;

  static ThemeColorPalette get currentTheme =>
      _controller?.currentTheme ?? AppThemeColors.pharmacyGreen;

  static Color get primary => _colorScheme.primary;
  static Color get primaryLight => _colorScheme.primaryContainer;
  static Color get primaryDark => ThemeAccessibility.readableOn(_colorScheme.primary);
  static Color get accent => _colorScheme.primary;

  static Color get onPrimary => _colorScheme.onPrimary;
  static Color get onSurface => _colorScheme.onSurface;

  static Color get authBg1 => _tokens.gradientStart;
  static Color get authBg2 => _tokens.gradientMiddle;
  static Color get authBg3 => _tokens.gradientEnd;

  static Color get scaffold => _colorScheme.surface;
  static Color get scaffoldSecondary => _colorScheme.surfaceContainerLow;
  static Color get surface => _colorScheme.surface;
  static Color get surfaceStrong => _tokens.surfaceStrong;
  static Color get surfaceMuted => _tokens.surfaceMuted;
  static Color get cardBg => _tokens.card;
  static Color get cardHighlight => _tokens.selected;
  static Color get glass => _tokens.glass;

  static Color get textPrimary => _colorScheme.onSurface;
  static Color get textSecondary => _tokens.textMuted;
  static Color get textHint => _tokens.textHint;
  static Color get textOnDark => _colorScheme.onPrimary;
  static Color get textOnDarkMuted => _colorScheme.onPrimary.withOpacity(0.72);

  static Color get error => _colorScheme.error;
  static Color get success => _tokens.success;
  static Color get warning => _tokens.warning;
  static Color get info => _tokens.info;

  static Color get border => _tokens.border;
  static Color get borderStrong => _tokens.borderStrong;
  static Color get borderFocused => _colorScheme.primary;

  static Color get hover => _tokens.hover;
  static Color get selected => _tokens.selected;

  static void setTheme(ThemeColorPalette theme) {
    _controller?.setTheme(theme);
  }

  static void setDarkMode(bool enabled) {
    _controller?.setDarkMode(enabled);
  }
}
