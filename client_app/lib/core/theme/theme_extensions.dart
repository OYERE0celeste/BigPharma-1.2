import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'typography_tokens.dart';

/// Theme Extensions for convenient access
///
/// Provides context-based getters for colors, text styles, and spacing

extension BpThemeExtension on BuildContext {
  // ============ COLOR ACCESS ============

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Brightness get brightness => Theme.of(this).brightness;

  // Primary colors
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get secondaryColor => colorScheme.secondary;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get tertiaryColor => colorScheme.tertiary;
  Color get onTertiaryColor => colorScheme.onTertiary;

  // Surface colors
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get surfaceContainerColor => colorScheme.surfaceContainer;
  Color get surfaceContainerHighColor => colorScheme.surfaceContainerHigh;
  Color get onSurfaceVariantColor => colorScheme.onSurfaceVariant;

  // Error colors
  Color get errorColor => colorScheme.error;
  Color get onErrorColor => colorScheme.onError;
  Color get errorContainerColor => colorScheme.errorContainer;
  Color get onErrorContainerColor => colorScheme.onErrorContainer;

  // Outline colors
  Color get outlineColor => colorScheme.outline;
  Color get outlineVariantColor => colorScheme.outlineVariant;

  // Background
  Color get backgroundColor => colorScheme.background;
  Color get onBackgroundColor => colorScheme.onBackground;

  // ============ SEMANTIC COLORS ============

  Color get successColor => BpColorTokens.success;
  Color get warningColor => BpColorTokens.warning;
  Color get infoColor => BpColorTokens.info;
  Color get pendingColor => BpColorTokens.pending;

  // Order statuses
  Color get orderConfirmedColor => BpColorTokens.orderConfirmed;
  Color get orderPendingColor => BpColorTokens.orderPending;
  Color get orderCancelledColor => BpColorTokens.orderCancelled;
  Color get orderShippedColor => BpColorTokens.orderShipped;
  Color get orderDeliveredColor => BpColorTokens.orderDelivered;

  // Text colors
  Color get textPrimaryColor => BpColors.textPrimary(brightness);
  Color get textSecondaryColor => BpColors.textSecondary(brightness);
  Color get textTertiaryColor => BpColors.textTertiary(brightness);
  Color get textDisabledColor => BpColors.textDisabled(brightness);

  // Utility colors
  Color get dividerColor => BpColors.divider(brightness);
  Color get disabledColor => BpColorTokens.disabledElement;

  // ============ TEXT STYLES ============

  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get displayLarge => BpTypographyTokens.displayLarge(this);
  TextStyle get displayMedium => BpTypographyTokens.displayMedium(this);
  TextStyle get displaySmall => BpTypographyTokens.displaySmall(this);

  TextStyle get headlineLarge => BpTypographyTokens.headlineLarge(this);
  TextStyle get headlineMedium => BpTypographyTokens.headlineMedium(this);
  TextStyle get headlineSmall => BpTypographyTokens.headlineSmall(this);

  TextStyle get titleLarge => BpTypographyTokens.titleLarge(this);
  TextStyle get titleMedium => BpTypographyTokens.titleMedium(this);
  TextStyle get titleSmall => BpTypographyTokens.titleSmall(this);

  TextStyle get bodyLarge => BpTypographyTokens.bodyLarge(this);
  TextStyle get bodyMedium => BpTypographyTokens.bodyMedium(this);
  TextStyle get bodySmall => BpTypographyTokens.bodySmall(this);

  TextStyle get labelLarge => BpTypographyTokens.labelLarge(this);
  TextStyle get labelMedium => BpTypographyTokens.labelMedium(this);
  TextStyle get labelSmall => BpTypographyTokens.labelSmall(this);

  // ============ SHAPE AND SIZE ============

  BorderRadius get borderRadiusXs => const BorderRadius.all(Radius.circular(4));
  BorderRadius get borderRadiusSm => const BorderRadius.all(Radius.circular(8));
  BorderRadius get borderRadiusMd =>
      const BorderRadius.all(Radius.circular(12));
  BorderRadius get borderRadiusLg =>
      const BorderRadius.all(Radius.circular(16));
  BorderRadius get borderRadiusXl =>
      const BorderRadius.all(Radius.circular(24));
  BorderRadius get borderRadiusCircle =>
      const BorderRadius.all(Radius.circular(9999));

  // ============ CONVENIENCE METHODS ============

  /// Get text style with error color
  TextStyle getErrorStyle(TextStyle baseStyle) =>
      BpTypographyTokens.getErrorTextStyle(baseStyle);

  /// Get text style with success color
  TextStyle getSuccessStyle(TextStyle baseStyle) =>
      BpTypographyTokens.getSuccessTextStyle(baseStyle);

  /// Get text style with warning color
  TextStyle getWarningStyle(TextStyle baseStyle) =>
      BpTypographyTokens.getWarningTextStyle(baseStyle);

  /// Get secondary text style
  TextStyle getSecondaryStyle(TextStyle baseStyle) =>
      BpTypographyTokens.getSecondaryTextStyle(baseStyle, this);

  /// Get disabled text style
  TextStyle getDisabledStyle(TextStyle baseStyle) =>
      BpTypographyTokens.getDisabledTextStyle(baseStyle, this);

  /// Check if dark mode
  bool get isDarkMode => brightness == Brightness.dark;

  /// Check if light mode
  bool get isLightMode => brightness == Brightness.light;
}

/// Widget-level theme helper
extension BpThemeHelper on ThemeData {
  /// Get whether this is a dark theme
  bool get isDark => brightness == Brightness.dark;

  /// Get whether this is a light theme
  bool get isLight => brightness == Brightness.light;
}

/// Color convenience extension
extension BpColorHelper on Color {
  /// Get slightly darker version
  Color darken({double amount = 0.1}) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  /// Get slightly lighter version
  Color lighten({double amount = 0.1}) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightened.toColor();
  }

  /// Get semi-transparent version
  Color withSemiTransparency({double opacity = 0.5}) {
    return withOpacity(opacity);
  }

  /// Get inverted version
  Color invert() {
    return Color.fromARGB(alpha, 255 - red, 255 - green, 255 - blue);
  }
}
