import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'spacing_tokens.dart';
import 'theme_extensions.dart';
import 'typography_tokens.dart';

class AppTheme {
  AppTheme._();

  static const Duration themeAnimationDuration = Duration(milliseconds: 420);
  static const Curve themeAnimationCurve = Curves.easeInOutCubic;

  static ThemeData buildLightTheme(ThemeColorPalette palette) {
    return buildTheme(seedColor: palette.seedColor, brightness: Brightness.light);
  }

  static ThemeData buildDarkTheme(ThemeColorPalette palette) {
    return buildTheme(seedColor: palette.seedColor, brightness: Brightness.dark);
  }

  static ThemeData buildTheme({
    required Color seedColor,
    required Brightness brightness,
  }) {
    final colorScheme = buildAppColorScheme(
      seedColor: seedColor,
      brightness: brightness,
    );
    final themeExtension = AppThemeExtension.fromScheme(colorScheme);
    final textTheme = AppTypography.buildTextTheme(colorScheme);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[themeExtension],
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      primaryColor: colorScheme.primary,
      cardColor: themeExtension.card,
      dividerColor: themeExtension.divider,
      shadowColor: themeExtension.shadow,
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: _buildAppBarTheme(colorScheme, themeExtension),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(
        colorScheme,
        themeExtension,
      ),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, themeExtension),
      navigationRailTheme: _buildNavigationRailTheme(colorScheme, themeExtension),
      drawerTheme: _buildDrawerTheme(colorScheme, themeExtension),
      cardTheme: _buildCardTheme(colorScheme, themeExtension),
      dialogTheme: _buildDialogTheme(colorScheme, themeExtension),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme, themeExtension),
      popupMenuTheme: _buildPopupMenuTheme(colorScheme, themeExtension),
      menuTheme: _buildMenuTheme(colorScheme, themeExtension),
      snackBarTheme: _buildSnackBarTheme(colorScheme, themeExtension),
      tooltipTheme: _buildTooltipTheme(colorScheme),
      badgeTheme: _buildBadgeTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme, themeExtension),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme, themeExtension),
      filledButtonTheme: _buildFilledButtonTheme(colorScheme, themeExtension),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme, themeExtension),
      textButtonTheme: _buildTextButtonTheme(colorScheme, themeExtension),
      floatingActionButtonTheme: _buildFabTheme(colorScheme, themeExtension),
      iconTheme: IconThemeData(color: colorScheme.primary, size: 22),
      iconButtonTheme: _buildIconButtonTheme(colorScheme),
      checkboxTheme: _buildCheckboxTheme(colorScheme, themeExtension),
      radioTheme: _buildRadioTheme(colorScheme, themeExtension),
      switchTheme: _buildSwitchTheme(colorScheme, themeExtension),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: themeExtension.border.withOpacity(isDark ? 0.30 : 0.18),
      ),
      dataTableTheme: _buildDataTableTheme(colorScheme, themeExtension),
      chipTheme: _buildChipTheme(colorScheme, themeExtension),
      listTileTheme: _buildListTileTheme(colorScheme),
      dividerTheme: DividerThemeData(
        color: themeExtension.divider,
        thickness: 1,
        space: 1,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primaryContainer.withOpacity(isDark ? 0.36 : 0.28),
        selectionHandleColor: colorScheme.primary,
      ),
      tabBarTheme: _buildTabBarTheme(colorScheme, themeExtension),
    );
  }

  static AppBarTheme _buildAppBarTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 70,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        );
      }),
    );
  }

  static NavigationRailThemeData _buildNavigationRailTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return NavigationRailThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      useIndicator: true,
      elevation: 0,
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static DrawerThemeData _buildDrawerTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return DrawerThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: themeExtension.shadow,
    );
  }

  static CardThemeData _buildCardTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return CardThemeData(
      color: themeExtension.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: themeExtension.border),
      ),
    );
  }

  static DialogThemeData _buildDialogTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return DialogThemeData(
      backgroundColor: themeExtension.surfaceStrong,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: themeExtension.border),
      ),
    );
  }

  static BottomSheetThemeData _buildBottomSheetTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return BottomSheetThemeData(
      backgroundColor: themeExtension.surfaceStrong,
      modalBackgroundColor: themeExtension.surfaceStrong,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    );
  }

  static PopupMenuThemeData _buildPopupMenuTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return PopupMenuThemeData(
      color: themeExtension.surfaceStrong,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: themeExtension.border),
      ),
      textStyle: TextStyle(color: colorScheme.onSurface),
    );
  }

  static MenuThemeData _buildMenuTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(themeExtension.surfaceStrong),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(themeExtension.shadow),
        elevation: const WidgetStatePropertyAll(10),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: themeExtension.border),
          ),
        ),
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      actionTextColor: colorScheme.primaryContainer,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: themeExtension.border),
      ),
    );
  }

  static TooltipThemeData _buildTooltipTheme(ColorScheme colorScheme) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      textStyle: TextStyle(
        color: colorScheme.onInverseSurface,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: const Duration(milliseconds: 300),
      showDuration: const Duration(seconds: 2),
    );
  }

  static BadgeThemeData _buildBadgeTheme(ColorScheme colorScheme) {
    return BadgeThemeData(
      backgroundColor: colorScheme.primary,
      textColor: colorScheme.onPrimary,
      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: themeExtension.surfaceMuted,
      contentPadding: AppSpacing.field,
      labelStyle: TextStyle(
        fontSize: 14,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: themeExtension.textHint,
      ),
      floatingLabelStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: BorderSide(color: themeExtension.border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: BorderSide(color: themeExtension.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: BorderSide(color: colorScheme.error, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: BorderSide(color: colorScheme.error, width: 1.8),
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.38),
        disabledForegroundColor: colorScheme.onPrimary.withOpacity(0.54),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        minimumSize: const Size(0, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.38),
        disabledForegroundColor: colorScheme.onPrimary.withOpacity(0.54),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        minimumSize: const Size(0, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: themeExtension.borderStrong, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  static FloatingActionButtonThemeData _buildFabTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );
  }

  static IconButtonThemeData _buildIconButtonTheme(ColorScheme colorScheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        disabledForegroundColor: colorScheme.onSurfaceVariant.withOpacity(0.40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  static CheckboxThemeData _buildCheckboxTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return themeExtension.surfaceMuted;
      }),
      checkColor: WidgetStatePropertyAll(colorScheme.onPrimary),
      side: BorderSide(color: themeExtension.borderStrong, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  static RadioThemeData _buildRadioTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return themeExtension.borderStrong;
      }),
    );
  }

  static SwitchThemeData _buildSwitchTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return themeExtension.border.withOpacity(0.45);
      }),
    );
  }

  static DataTableThemeData _buildDataTableTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(themeExtension.surfaceMuted),
      dataRowColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return themeExtension.selected;
        }
        if (states.contains(WidgetState.hovered)) {
          return themeExtension.hover;
        }
        return themeExtension.card;
      }),
      dividerThickness: 1,
      columnSpacing: 22,
      horizontalMargin: 18,
      dataRowMinHeight: 52,
      dataRowMaxHeight: 64,
      headingRowHeight: 56,
      dataTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 13,
        height: 1.35,
      ),
      headingTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
      ),
    );
  }

  static ChipThemeData _buildChipTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return ChipThemeData(
      backgroundColor: themeExtension.surfaceMuted,
      selectedColor: colorScheme.primaryContainer,
      secondarySelectedColor: colorScheme.primaryContainer,
      disabledColor: themeExtension.surfaceMuted.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      secondaryLabelStyle: TextStyle(color: colorScheme.onSurface),
      side: BorderSide(color: themeExtension.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  static ListTileThemeData _buildListTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(
      iconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  static TabBarThemeData _buildTabBarTheme(
    ColorScheme colorScheme,
    AppThemeExtension themeExtension,
  ) {
    return TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      dividerColor: themeExtension.divider,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }
}
