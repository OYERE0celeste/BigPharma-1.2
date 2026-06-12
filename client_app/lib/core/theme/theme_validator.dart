import 'dart:math';
import 'package:flutter/material.dart';

/// WCAG Contrast Validator
///
/// Validates that text/background color combinations meet WCAG AA standards.
/// WCAG AA requires minimum contrast ratio of 4.5:1 for normal text,
/// 3:1 for large text.
class BpContrastValidator {
  BpContrastValidator._();

  // WCAG AA minimum contrast ratios
  static const double minContrastRatioNormalText = 4.5;
  static const double minContrastRatioLargeText = 3.0;

  /// Calculate relative luminance of a color
  /// Reference: https://www.w3.org/TR/WCAG20/#relativeluminancedef
  static double _getRelativeLuminance(Color color) {
    final r = _linearizeColorComponent(color.red / 255);
    final g = _linearizeColorComponent(color.green / 255);
    final b = _linearizeColorComponent(color.blue / 255);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearize a color component for luminance calculation
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return pow((component + 0.055) / 1.055, 2).toDouble();
    }
  }

  /// Calculate contrast ratio between two colors
  /// Reference: https://www.w3.org/TR/WCAG20/#contrast-ratiodef
  static double calculateContrastRatio(Color foreground, Color background) {
    final l1 = _getRelativeLuminance(foreground);
    final l2 = _getRelativeLuminance(background);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if colors meet WCAG AA for normal text (4.5:1)
  static bool meetsWcagAANormalText(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >=
        minContrastRatioNormalText;
  }

  /// Check if colors meet WCAG AA for large text (3:1)
  static bool meetsWcagAALargeText(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >=
        minContrastRatioLargeText;
  }

  /// Get diagnostic information about color contrast
  static String getDiagnostics(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    final minRequired = isLargeText
        ? minContrastRatioLargeText
        : minContrastRatioNormalText;
    final passes = ratio >= minRequired;

    return '''
WCAG Contrast Validation
========================
Foreground: ${foreground.toString()}
Background: ${background.toString()}
Contrast Ratio: ${ratio.toStringAsFixed(2)}:1
Required: $minRequired:1 (${isLargeText ? 'large text' : 'normal text'})
Status: ${passes ? '✓ PASS' : '✗ FAIL'}
''';
  }

  /// Automatically adjust text color for sufficient contrast
  /// Returns a text color that meets WCAG AA requirements
  static Color getAccessibleTextColor(Color background) {
    // Try black first
    if (meetsWcagAANormalText(Colors.black87, background)) {
      return Colors.black87;
    }

    // Try dark grey
    if (meetsWcagAANormalText(const Color(0xFF212121), background)) {
      return const Color(0xFF212121);
    }

    // Fall back to white
    return Colors.white;
  }

  /// Validate that an entire theme meets accessibility standards
  static List<String> validateThemeAccessibility(ThemeData theme) {
    final issues = <String>[];

    // Validate primary text on surface
    if (!meetsWcagAANormalText(
      theme.textTheme.bodyMedium?.color ?? Colors.black,
      theme.scaffoldBackgroundColor,
    )) {
      issues.add(
        'Body text on scaffold background does not meet WCAG AA (${calculateContrastRatio(theme.textTheme.bodyMedium?.color ?? Colors.black, theme.scaffoldBackgroundColor).toStringAsFixed(2)}:1)',
      );
    }

    return issues;
  }
}

// Helper function for pow()
double pow(double base, double exponent) {
  return base == 0 ? 0 : exp(exponent * log(base));
}
