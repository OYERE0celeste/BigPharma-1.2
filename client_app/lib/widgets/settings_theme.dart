import 'package:flutter/material.dart';

class SettingsTheme {
  // Dimensions
  static const double dialogMaxWidth = 850.0;
  static const double dialogMaxHeight = 700.0;
  static const double headerHeight = 72.0;
  static const double sidePadding = 24.0;
  
  // Colors (Curated for premium look)
  static const Color primary = Color(0xFF2E7D62);
  static const Color accent = Color(0xFFE3F2FD);
  static const Color background = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);
  
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
}
