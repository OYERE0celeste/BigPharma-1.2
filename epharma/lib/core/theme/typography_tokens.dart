import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    final baseTheme = colorScheme.brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return baseTheme
        .copyWith(
          displayLarge: baseTheme.displayLarge?.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.8,
          ),
          displayMedium: baseTheme.displayMedium?.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -0.5,
          ),
          headlineLarge: baseTheme.headlineLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -0.3,
          ),
          headlineMedium: baseTheme.headlineMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.18,
            letterSpacing: -0.2,
          ),
          titleLarge: baseTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.22,
            letterSpacing: -0.1,
          ),
          titleMedium: baseTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          bodyLarge: baseTheme.bodyLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
          bodyMedium: baseTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
          labelLarge: baseTheme.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.1,
            letterSpacing: 0.15,
          ),
          labelMedium: baseTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.1,
            letterSpacing: 0.2,
          ),
        )
        .apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface);
  }
}
