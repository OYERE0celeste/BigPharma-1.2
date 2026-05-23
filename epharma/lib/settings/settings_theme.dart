import 'package:flutter/material.dart';
import '../widgets/bp_theme.dart';

class SettingsTheme {
  // Dimensions
  static const double dialogMaxWidth = 850.0;
  static const double dialogMaxHeight = 700.0;
  static const double headerHeight = 72.0;
  static const double sidePadding = 24.0;

  // Colors (Shared with app_colors.dart but curated for settings)
  static const Color primary = BpColors.accent;
  static const Color accent = BpColors.surfaceMuted;
  static const Color background = BpColors.surfaceStrong;
  static const Color textPrimary = BpColors.textPrimary;
  static const Color textSecondary = BpColors.textSecondary;
  static const Color divider = BpColors.border;

  // Transitions
  static const Duration animationDuration = Duration(milliseconds: 400);
  static const Curve animationCurve = Curves.easeInOutCubic;

  // Text Styles
  static const TextStyle headerTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  // Focus Decoration
  static BoxDecoration focusDecoration = BoxDecoration(
    border: Border.all(color: primary.withOpacity(0.5), width: 2),
    borderRadius: BorderRadius.circular(8),
  );
}
