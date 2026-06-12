import 'package:flutter/material.dart';

import 'bp_theme.dart';

class SettingsTheme {
  // Dimensions
  static const double dialogMaxWidth = 850.0;
  static const double dialogMaxHeight = 700.0;
  static const double headerHeight = 72.0;
  static const double sidePadding = 24.0;

  // Colors (Curated for premium look)
  static Color get primary => BpColors.accent;
  static Color get accent => BpColors.surfaceMuted;
  static Color get background => BpColors.surfaceStrong;
  static Color get textPrimary => BpColors.textPrimary;
  static Color get textSecondary => BpColors.textSecondary;
  static Color get divider => BpColors.border;

  // Transitions
  static const Duration animationDuration = Duration(milliseconds: 400);
  static const Curve animationCurve = Curves.easeInOutCubic;

  // Text Styles
  static TextStyle get headerTitle => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get sectionTitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyText => TextStyle(
    fontSize: 14,
    color: textSecondary,
  );
}
