import 'package:flutter/material.dart';
import 'color_tokens.dart';

/// Typography Tokens for BigPharma Design System
///
/// Provides all text styles for the application.
/// Always use these instead of TextStyle(color: Colors.xxx).
class BpTypographyTokens {
  BpTypographyTokens._();

  // ============ HEADING STYLES ============

  /// Display Large - 57pt, for major headings
  static TextStyle displayLarge(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.12,
      letterSpacing: -0.25,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  /// Display Medium - 45pt
  static TextStyle displayMedium(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
      letterSpacing: 0,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  /// Display Small - 36pt
  static TextStyle displaySmall(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.22,
      letterSpacing: 0,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  // ============ HEADLINE STYLES ============

  /// Headline Large - 32pt, for page titles
  static TextStyle headlineLarge(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 1.25,
      letterSpacing: 0,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  /// Headline Medium - 28pt
  static TextStyle headlineMedium(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      height: 1.29,
      letterSpacing: 0,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  /// Headline Small - 24pt
  static TextStyle headlineSmall(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  // ============ TITLE STYLES ============

  /// Title Large - 22pt, for card titles
  static TextStyle titleLarge(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 1.27,
      letterSpacing: 0,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  /// Title Medium - 16pt, for form labels
  static TextStyle titleMedium(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0.15,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  /// Title Small - 14pt
  static TextStyle titleSmall(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  // ============ BODY STYLES ============

  /// Body Large - 16pt, for main content
  static TextStyle bodyLarge(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5,
      color: color ?? BpColors.textPrimary(brightness),
    );
  }

  /// Body Medium - 14pt, standard body text
  static TextStyle bodyMedium(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
      color: color ?? BpColors.textPrimary(brightness),
    );
  }

  /// Body Small - 12pt
  static TextStyle bodySmall(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
      color: color ?? BpColors.textSecondary(brightness),
    );
  }

  // ============ LABEL STYLES ============

  /// Label Large - 14pt, for button text
  static TextStyle labelLarge(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  /// Label Medium - 12pt
  static TextStyle labelMedium(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0.5,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  /// Label Small - 11pt
  static TextStyle labelSmall(BuildContext context, {Color? color}) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.5,
      color: color ?? BpColors.onSurface(brightness),
    );
  }

  // ============ HELPER METHODS ============

  /// Get disabled text style (reduced opacity)
  static TextStyle getDisabledTextStyle(TextStyle style, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return style.copyWith(color: BpColors.textDisabled(brightness));
  }

  /// Get error text style
  static TextStyle getErrorTextStyle(TextStyle style) {
    return style.copyWith(color: BpColorTokens.error);
  }

  /// Get success text style
  static TextStyle getSuccessTextStyle(TextStyle style) {
    return style.copyWith(color: BpColorTokens.success);
  }

  /// Get warning text style
  static TextStyle getWarningTextStyle(TextStyle style) {
    return style.copyWith(color: BpColorTokens.warning);
  }

  /// Get secondary text style (lighter color)
  static TextStyle getSecondaryTextStyle(
    TextStyle style,
    BuildContext context,
  ) {
    final brightness = Theme.of(context).brightness;
    return style.copyWith(color: BpColors.textSecondary(brightness));
  }
}

/// Convenience extension for quick access to typography
extension BpTypography on BuildContext {
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
}
