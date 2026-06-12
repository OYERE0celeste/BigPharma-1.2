import 'package:flutter/material.dart';
import '../widgets/bp_theme.dart';

class SettingsTheme {
  // Dimensions
  static const double dialogMaxWidth = 850.0;
  static const double dialogMaxHeight = 700.0;
  static const double headerHeight = 72.0;
  static const double sidePadding = 24.0;

  // Colors (Shared with app_colors.dart but curated for settings)
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

  // Focus Decoration
  static BoxDecoration focusDecoration = BoxDecoration(
    border: Border.all(color: primary.withOpacity(0.5), width: 2),
    borderRadius: BorderRadius.circular(8),
  );
}
