import 'package:flutter/material.dart';

/// Design System Color Tokens for BigPharma
///
/// All colors are defined here and must be used through the theme system.
/// No hardcoded Color(...) or Colors.* should appear in widgets.
class BpColorTokens {
  // Private constructor - static class only
  BpColorTokens._();

  // ============ SEMANTIC COLOR DEFINITIONS ============
  // These define what each color means conceptually

  static const Color success = Color(0xFF2E7D32); // Green
  static const Color warning = Color(0xFFF57C00); // Orange
  static const Color error = Color(0xFFC62828); // Red
  static const Color info = Color(0xFF1565C0); // Blue
  static const Color pending = Color(0xFF6F42C1); // Purple

  // ============ PALETTE - LIGHT MODE ============
  static const Color brandPrimary = Color(0xFF4A90E2); // Brand Blue
  static const Color brandSecondary = Color(0xFF50C878); // Brand Green
  static const Color brandTertiary = Color(0xFFFFB81C); // Brand Yellow

  static const Color surfaceLight = Color(0xFFFAFAFA); // Almost white
  static const Color surfaceContainerLight = Color(0xFFF5F5F5);
  static const Color onSurfaceLight = Color(0xFF1F1F1F); // Almost black
  static const Color onSurfaceVariantLight = Color(0xFF49454F);
  static const Color outlineLight = Color(0xFF79747E);
  static const Color outlineVariantLight = Color(0xFFCAC7D0);

  // ============ PALETTE - DARK MODE ============
  static const Color surfaceDark = Color(0xFF121212); // True black
  static const Color surfaceContainerDark = Color(0xFF1F1F1F);
  static const Color onSurfaceDark = Color(0xFFFFFFFF); // True white
  static const Color onSurfaceVariantDark = Color(0xFFCAC7D0);
  static const Color outlineDark = Color(0xFF938F96);
  static const Color outlineVariantDark = Color(0xFF49454F);

  // ============ STATUS COLORS ============
  static const Color orderConfirmed = Color(0xFF2E7D32); // Green
  static const Color orderPending = Color(0xFFFFA500); // Orange
  static const Color orderCancelled = Color(0xFFC62828); // Red
  static const Color orderShipped = Color(0xFF1976D2); // Blue
  static const Color orderDelivered = Color(0xFF388E3C); // Dark Green

  // ============ INTERACTIVE ELEMENTS ============
  static const Color linkColor = Color(0xFF0066CC); // Web blue
  static const Color linkVisited = Color(0xFF7C3AED); // Purple
  static const Color focusIndicator = Color(0xFF4A90E2); // Same as primary
  static const Color disabledElement = Color(0xFFBDBDBD); // Light grey

  // ============ FUNCTIONAL COLORS ============
  // These are used for specific UI patterns
  static const Color divider = Color(0xFFE0E0E0); // Light grey
  static const Color shadow = Color(0xFF000000); // Black (for opacity)
  static const Color backdrop = Color(0xFF000000); // Black (modal backdrop)

  // ============ TEXT COLORS ============
  static const Color textPrimaryLight = Color(0xFF1F1F1F); // Almost black
  static const Color textSecondaryLight = Color(0xFF49454F); // Medium grey
  static const Color textTertiaryLight = Color(0xFF79747E); // Light grey
  static const Color textDisabledLight = Color(0xFFCACAC9); // Very light grey

  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White
  static const Color textSecondaryDark = Color(0xFFCAC7D0); // Light grey
  static const Color textTertiaryDark = Color(0xFF938F96); // Medium grey
  static const Color textDisabledDark = Color(0xFF49454F); // Dark grey

  // ============ BADGE & CHIP COLORS ============
  static const Color badgeSuccess = Color(0xFFE8F5E9); // Light green
  static const Color badgeWarning = Color(0xFFFFF3E0); // Light orange
  static const Color badgeError = Color(0xFFFFEBEE); // Light red
  static const Color badgeInfo = Color(0xFFE3F2FD); // Light blue

  // ============ HELPER COLORS ============
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ============ OPACITY MODIFIERS ============
  // Use like: BpColorTokens.textPrimaryLight.withOpacity(0.38)
  // Or use the constants below for common opacity levels

  static const double opacityHover = 0.08;
  static const double opacityFocus = 0.12;
  static const double opacityPressed = 0.12;
  static const double opacityDragged = 0.16;
  static const double opacityDisabled = 0.38;
  static const double opacitySubtle = 0.54;
}

/// Convenience class for accessing color tokens with semantic names
class BpColors {
  BpColors._();

  // Primary colors
  static Color primary(Brightness brightness) => brightness == Brightness.dark
      ? BpColorTokens.brandPrimary.withAlpha(230)
      : BpColorTokens.brandPrimary;

  static Color secondary(Brightness brightness) => BpColorTokens.brandSecondary;

  static Color tertiary(Brightness brightness) => BpColorTokens.brandTertiary;

  // Surface colors
  static Color surface(Brightness brightness) => brightness == Brightness.dark
      ? BpColorTokens.surfaceDark
      : BpColorTokens.surfaceLight;

  static Color onSurface(Brightness brightness) => brightness == Brightness.dark
      ? BpColorTokens.onSurfaceDark
      : BpColorTokens.onSurfaceLight;

  // Status colors (non-theme dependent)
  static Color success = BpColorTokens.success;
  static Color warning = BpColorTokens.warning;
  static Color error = BpColorTokens.error;
  static Color info = BpColorTokens.info;
  static Color pending = BpColorTokens.pending;

  // Order statuses
  static Color orderConfirmed = BpColorTokens.orderConfirmed;
  static Color orderPending = BpColorTokens.orderPending;
  static Color orderCancelled = BpColorTokens.orderCancelled;
  static Color orderShipped = BpColorTokens.orderShipped;
  static Color orderDelivered = BpColorTokens.orderDelivered;

  // Text
  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.dark
      ? BpColorTokens.textPrimaryDark
      : BpColorTokens.textPrimaryLight;

  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.dark
      ? BpColorTokens.textSecondaryDark
      : BpColorTokens.textSecondaryLight;

  static Color textTertiary(Brightness brightness) =>
      brightness == Brightness.dark
      ? BpColorTokens.textTertiaryDark
      : BpColorTokens.textTertiaryLight;

  static Color textDisabled(Brightness brightness) =>
      brightness == Brightness.dark
      ? BpColorTokens.textDisabledDark
      : BpColorTokens.textDisabledLight;

  // Dividers & Borders
  static Color divider(Brightness brightness) => brightness == Brightness.dark
      ? BpColorTokens.outlineVariantDark.withAlpha(77)
      : BpColorTokens.outlineLight;

  // Neutral greys (not theme dependent)
  static Color grey(int shade) {
    switch (shade) {
      case 50:
        return BpColorTokens.grey50;
      case 100:
        return BpColorTokens.grey100;
      case 200:
        return BpColorTokens.grey200;
      case 300:
        return BpColorTokens.grey300;
      case 400:
        return BpColorTokens.grey400;
      case 500:
        return BpColorTokens.grey500;
      case 600:
        return BpColorTokens.grey600;
      case 700:
        return BpColorTokens.grey700;
      case 800:
        return BpColorTokens.grey800;
      case 900:
        return BpColorTokens.grey900;
      default:
        return BpColorTokens.grey500;
    }
  }
}
