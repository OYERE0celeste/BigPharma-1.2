import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'spacing_tokens.dart';

/// Material 3 Theme Definitions for BigPharma
///
/// Provides light and dark themes using ColorScheme.fromSeed()
/// to automatically generate a complete color palette with Material 3 semantics.
/// Alias for backward compatibility
typedef AppTheme = BpAppTheme;

class BpAppTheme {
  BpAppTheme._();

  // ============ ANIMATION CONSTANTS ============
  static const Duration themeAnimationDuration = Duration(milliseconds: 420);
  static const Curve themeAnimationCurve = Curves.easeInOutCubic;

  // ============ LIGHT THEME ============

  static ThemeData buildLightTheme({Color? seedColor}) {
    final effectiveSeedColor = seedColor ?? BpColorTokens.brandPrimary;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: effectiveSeedColor,
      brightness: Brightness.light,
      surface: BpColorTokens.surfaceLight,
      onSurface: BpColorTokens.onSurfaceLight,
      outline: BpColorTokens.outlineLight,
      outlineVariant: BpColorTokens.outlineVariantLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BpColorTokens.surfaceLight,

      // ============ TEXT THEMES ============
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 1.12,
          letterSpacing: -0.25,
          color: BpColorTokens.onSurfaceLight,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 1.16,
          color: BpColorTokens.onSurfaceLight,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 1.22,
          color: BpColorTokens.onSurfaceLight,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: BpColorTokens.onSurfaceLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          height: 1.29,
          color: BpColorTokens.onSurfaceLight,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 1.33,
          color: BpColorTokens.onSurfaceLight,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.27,
          color: BpColorTokens.onSurfaceLight,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.15,
          color: BpColorTokens.onSurfaceLight,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
          color: BpColorTokens.onSurfaceLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.5,
          color: BpColorTokens.textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.25,
          color: BpColorTokens.textPrimaryLight,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0.4,
          color: BpColorTokens.textSecondaryLight,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
          color: BpColorTokens.onSurfaceLight,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.5,
          color: BpColorTokens.onSurfaceLight,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.45,
          letterSpacing: 0.5,
          color: BpColorTokens.onSurfaceLight,
        ),
      ),

      // ============ COMPONENT THEMES ============
      appBarTheme: AppBarTheme(
        backgroundColor: BpColorTokens.surfaceLight,
        foregroundColor: BpColorTokens.onSurfaceLight,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: BpSpacingTokens.appBarHeight,
      ),

      cardTheme: CardThemeData(
        color: BpColorTokens.white,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusMd,
          side: BorderSide(color: BpColorTokens.outlineLight),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: BpSpacingTokens.lg,
            vertical: BpSpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BpSpacingTokens.borderRadiusSm,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: BpSpacingTokens.lg,
            vertical: BpSpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BpSpacingTokens.borderRadiusSm,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: BpSpacingTokens.lg,
            vertical: BpSpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BpSpacingTokens.borderRadiusSm,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: BpSpacingTokens.md,
            vertical: BpSpacingTokens.sm,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusLg,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BpSpacingTokens.lg,
          vertical: BpSpacingTokens.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BpSpacingTokens.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BpSpacingTokens.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BpSpacingTokens.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusXl,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: BpColorTokens.outlineLight,
        thickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusMd,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: BpColorTokens.white,
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusLg,
        ),
        elevation: 6,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BpColorTokens.white,
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(fontSize: 12, color: colorScheme.onSurface),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BpColorTokens.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
      ),

      iconTheme: IconThemeData(color: colorScheme.onSurface),
      primaryIconTheme: IconThemeData(color: colorScheme.primary),
    );
  }

  // ============ DARK THEME ============

  static ThemeData buildDarkTheme({Color? seedColor}) {
    final effectiveSeedColor = seedColor ?? BpColorTokens.brandPrimary;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: effectiveSeedColor,
      brightness: Brightness.dark,
      surface: BpColorTokens.surfaceDark,
      onSurface: BpColorTokens.onSurfaceDark,
      outline: BpColorTokens.outlineDark,
      outlineVariant: BpColorTokens.outlineVariantDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BpColorTokens.surfaceDark,

      // ============ TEXT THEMES ============
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 1.12,
          letterSpacing: -0.25,
          color: BpColorTokens.onSurfaceDark,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 1.16,
          color: BpColorTokens.onSurfaceDark,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 1.22,
          color: BpColorTokens.onSurfaceDark,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: BpColorTokens.onSurfaceDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          height: 1.29,
          color: BpColorTokens.onSurfaceDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 1.33,
          color: BpColorTokens.onSurfaceDark,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.27,
          color: BpColorTokens.onSurfaceDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.15,
          color: BpColorTokens.onSurfaceDark,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
          color: BpColorTokens.onSurfaceDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.5,
          color: BpColorTokens.textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.25,
          color: BpColorTokens.textPrimaryDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0.4,
          color: BpColorTokens.textSecondaryDark,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
          color: BpColorTokens.onSurfaceDark,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.5,
          color: BpColorTokens.onSurfaceDark,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.45,
          letterSpacing: 0.5,
          color: BpColorTokens.onSurfaceDark,
        ),
      ),

      // ============ COMPONENT THEMES ============
      appBarTheme: AppBarTheme(
        backgroundColor: BpColorTokens.surfaceDark,
        foregroundColor: BpColorTokens.onSurfaceDark,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: BpSpacingTokens.appBarHeight,
      ),

      cardTheme: CardThemeData(
        color: BpColorTokens.surfaceDark,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusMd,
          side: BorderSide(color: BpColorTokens.outlineDark),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: BpSpacingTokens.lg,
            vertical: BpSpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BpSpacingTokens.borderRadiusSm,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: BpSpacingTokens.lg,
            vertical: BpSpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BpSpacingTokens.borderRadiusSm,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: BpSpacingTokens.lg,
            vertical: BpSpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BpSpacingTokens.borderRadiusSm,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: BpSpacingTokens.md,
            vertical: BpSpacingTokens.sm,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusLg,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BpSpacingTokens.lg,
          vertical: BpSpacingTokens.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BpSpacingTokens.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BpSpacingTokens.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BpSpacingTokens.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusXl,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: BpColorTokens.outlineVariantDark,
        thickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusMd,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: BpColorTokens.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BpSpacingTokens.borderRadiusLg,
        ),
        elevation: 6,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BpColorTokens.surfaceContainerDark,
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(fontSize: 12, color: colorScheme.onSurface),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BpColorTokens.surfaceContainerDark,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
      ),

      iconTheme: IconThemeData(color: colorScheme.onSurface),
      primaryIconTheme: IconThemeData(color: colorScheme.primary),
    );
  }
}
