import 'package:flutter/material.dart';
import '../core/theme/theme_colors.dart';
import 'brand_title.dart';

class BpColors {
  BpColors._();

  static Color get primary => AppBpColors.primary;
  static Color get primaryLight => AppBpColors.primaryLight;
  static Color get primaryDark => AppBpColors.primaryDark;
  static Color get accent => AppBpColors.accent;

  static Color get authBg1 => AppBpColors.authBg1;
  static Color get authBg2 => AppBpColors.authBg2;
  static Color get authBg3 => AppBpColors.authBg3;

  static Color get scaffold => AppBpColors.scaffold;
  static Color get scaffoldSecondary => AppBpColors.scaffoldSecondary;
  static Color get surface => AppBpColors.surface;
  static Color get surfaceStrong => AppBpColors.surfaceStrong;
  static Color get surfaceMuted => AppBpColors.surfaceMuted;
  static Color get cardBg => AppBpColors.cardBg;
  static Color get cardHighlight => AppBpColors.cardHighlight;
  static Color get glass => AppBpColors.glass;

  static Color get textPrimary => AppBpColors.textPrimary;
  static Color get textSecondary => AppBpColors.textSecondary;
  static Color get textHint => AppBpColors.textHint;
  static Color get textOnDark => AppBpColors.textOnDark;
  static Color get textOnDarkMuted => AppBpColors.textOnDarkMuted;

  static Color get error => AppBpColors.error;
  static Color get success => AppBpColors.success;
  static Color get warning => AppBpColors.warning;

  static Color get border => AppBpColors.border;
  static Color get borderStrong => AppBpColors.borderStrong;
  static Color get borderFocused => AppBpColors.borderFocused;
}

class BpSpacing {
  BpSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 32;
}

class BpTextStyles {
  BpTextStyles._();

  static TextStyle get heading1 => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: BpColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get heading2 => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: BpColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get heading3 => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: BpColors.textPrimary,
  );

  static TextStyle get body => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: BpColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodyBold => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BpColors.textPrimary,
  );

  static TextStyle get label => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BpColors.textSecondary,
    letterSpacing: 0.1,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: BpColors.textHint,
  );

  static TextStyle get buttonText =>
      TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2);

  static TextStyle get headingOnDark => TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: BpColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get authTitle => TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: BpColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get authSubtitle =>
      TextStyle(fontSize: 14, color: BpColors.textSecondary, height: 1.5);

  static TextStyle get authBadge => TextStyle(
    fontSize: 12,
    color: BpColors.accent,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get bodyOnDark =>
      TextStyle(fontSize: 13, color: BpColors.textSecondary, height: 1.5);

  static TextStyle get labelOnDark => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: BpColors.textSecondary,
  );
}

class BpTheme {
  BpTheme._();

  static ThemeData materialTheme() {
    final isLight = BpColors.scaffold.computeLuminance() > 0.5;

    final colorScheme = isLight
        ? ColorScheme.light(
            primary: BpColors.accent,
            onPrimary: BpColors.textPrimary,
            secondary: BpColors.primaryLight,
            onSecondary: BpColors.textPrimary,
            surface: BpColors.surface,
            onSurface: BpColors.textPrimary,
            background: BpColors.scaffold,
            onBackground: BpColors.textPrimary,
            error: BpColors.error,
            onError: BpColors.textPrimary,
            surfaceVariant: BpColors.surfaceMuted,
          )
        : ColorScheme.dark(
            primary: BpColors.accent,
            onPrimary: Colors.white,
            secondary: BpColors.primaryLight,
            onSecondary: Colors.white,
            surface: BpColors.surface,
            onSurface: BpColors.textPrimary,
            background: BpColors.scaffold,
            onBackground: BpColors.textPrimary,
            error: BpColors.error,
            onError: Colors.white,
            surfaceVariant: BpColors.surfaceMuted,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: 'sans-serif',
      scaffoldBackgroundColor: BpColors.scaffold,
      canvasColor: BpColors.scaffold,
      cardColor: BpColors.surfaceStrong,
      shadowColor: BpColors.primaryDark.withOpacity(0.4),
      dividerColor: BpColors.border,
      splashFactory: InkSparkle.splashFactory,
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: BpColors.textPrimary,
          disabledForegroundColor: BpColors.textSecondary.withOpacity(0.4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BpColors.surfaceMuted.withOpacity(0.5);
          }
          if (states.contains(WidgetState.selected)) {
            return BpColors.accent;
          }
          return BpColors.surfaceMuted;
        }),
        checkColor: WidgetStateProperty.all(BpColors.primaryDark),
        side: BorderSide(color: BpColors.borderStrong, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(BpColors.surfaceMuted),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BpColors.accent.withOpacity(0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return BpColors.surfaceStrong.withOpacity(0.94);
          }
          return BpColors.surfaceStrong.withOpacity(0.78);
        }),
        dataTextStyle: TextStyle(
          color: BpColors.textSecondary,
          fontSize: 13,
          height: 1.35,
        ),
        headingTextStyle: TextStyle(
          color: BpColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
        ),
        columnSpacing: 22,
        horizontalMargin: 18,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 64,
        headingRowHeight: 56,
        dividerThickness: 1,
      ),
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
      textTheme:
          TextTheme(
            displayLarge: BpTextStyles.heading1,
            displayMedium: BpTextStyles.heading2,
            titleLarge: BpTextStyles.heading2,
            titleMedium: BpTextStyles.heading3,
            bodyLarge: BpTextStyles.body,
            bodyMedium: BpTextStyles.body,
            labelLarge: BpTextStyles.buttonText,
          ).apply(
            bodyColor: BpColors.textPrimary,
            displayColor: BpColors.textPrimary,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: BpColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BpColors.surfaceStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
          side: BorderSide(color: BpColors.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: BpColors.surfaceStrong,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: BpColors.surfaceStrong,
      ),
      cardTheme: CardThemeData(
        color: BpColors.cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          side: BorderSide(color: BpColors.border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: BpColors.surfaceStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          side: BorderSide(color: BpColors.border),
        ),
        textStyle: TextStyle(color: BpColors.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BpColors.surfaceStrong,
        contentTextStyle: TextStyle(color: BpColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
          side: BorderSide(color: BpColors.border),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BpColors.accent,
          foregroundColor: BpColors.primaryDark,
          disabledBackgroundColor: BpColors.accent.withOpacity(0.4),
          disabledForegroundColor: BpColors.primaryDark.withOpacity(0.6),
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          ),
          textStyle: BpTextStyles.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BpColors.textPrimary,
          side: BorderSide(color: BpColors.borderStrong),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BpColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: BpColors.accent,
        foregroundColor: BpColors.primaryDark,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BpColors.surfaceStrong,
        disabledColor: BpColors.surfaceMuted,
        selectedColor: BpColors.accent.withOpacity(0.18),
        secondarySelectedColor: BpColors.accent.withOpacity(0.18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: TextStyle(color: BpColors.textSecondary),
        secondaryLabelStyle: TextStyle(color: BpColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: BpColors.border),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: BpColors.textSecondary,
        textColor: BpColors.textPrimary,
      ),
      dividerTheme: DividerThemeData(
        color: BpColors.border,
        thickness: 1,
        space: 1,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: BpColors.surfaceStrong,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: BpColors.surface,
        headerForegroundColor: BpColors.textPrimary,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BpColors.primaryDark;
          }
          return BpColors.textPrimary;
        }),
        todayForegroundColor: WidgetStatePropertyAll(BpColors.accent),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BpColors.accent;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
        ),
      ),
    );
  }

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: BpColors.surfaceMuted,
        labelStyle: TextStyle(fontSize: 14, color: BpColors.textSecondary),
        hintStyle: TextStyle(fontSize: 14, color: BpColors.textHint),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(BpSpacing.radiusLg)),
          borderSide: BorderSide(color: BpColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(BpSpacing.radiusLg)),
          borderSide: BorderSide(color: BpColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(BpSpacing.radiusLg)),
          borderSide: BorderSide(color: BpColors.accent, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(BpSpacing.radiusLg)),
          borderSide: BorderSide(color: BpColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(BpSpacing.radiusLg)),
          borderSide: BorderSide(color: BpColors.error, width: 1.8),
        ),
      );
}

class BpDecoratedBackground extends StatelessWidget {
  const BpDecoratedBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BpColors.authBg1, BpColors.authBg2, BpColors.authBg3],
        ),
      ),
      child: child,
    );
  }
}

class BpSurfaceCard extends StatelessWidget {
  const BpSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.radius = BpSpacing.radiusXl,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? BpColors.surfaceStrong.withOpacity(0.92),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: BpColors.borderStrong, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    return Container(margin: margin, child: cardContent);
  }
}

class BpBottomSheetContainer extends StatelessWidget {
  const BpBottomSheetContainer({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return BpSurfaceCard(
      radius: BpSpacing.radiusXl,
      padding:
          padding ??
          EdgeInsets.only(
            left: 28,
            right: 28,
            top: 28,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
      color: BpColors.surfaceStrong,
      child: child,
    );
  }
}

class BpInputTheme {
  BpInputTheme._();

  static InputDecoration light({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIconWidget,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(fontSize: 14, color: BpColors.textSecondary),
      hintStyle: TextStyle(fontSize: 13, color: BpColors.textHint),
      prefixIconColor: BpColors.textSecondary,
      suffixIcon: suffixIconWidget,
      filled: true,
      fillColor: BpColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(color: BpColors.border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(color: BpColors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(color: BpColors.accent, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(color: BpColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(color: BpColors.error, width: 1.8),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 20, color: BpColors.textSecondary)
          : null,
    );
  }

  static InputDecoration dark({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIconWidget,
    bool showLabel = true,
  }) {
    return InputDecoration(
      labelText: showLabel ? label : null,
      hintText: hint ?? label,
      hintStyle: TextStyle(
        color: BpColors.textPrimary.withOpacity(0.34),
        fontSize: 14,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              size: 20,
              color: BpColors.textPrimary.withOpacity(0.58),
            )
          : null,
      suffixIcon: suffixIconWidget,
      filled: true,
      fillColor: BpColors.cardBg.withOpacity(0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(color: BpColors.border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(color: BpColors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(color: BpColors.accent, width: 1.8),
      ),
    );
  }
}

class BpButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDark;
  final double height;

  const BpButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDark = false,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final background = isDark ? BpColors.accent : BpColors.primaryLight;
    final foreground = BpColors.primaryDark;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(foreground),
                ),
              )
            : Text(label, style: BpTextStyles.buttonText),
      ),
    );
  }
}

class BpAuthLoadingScreen extends StatelessWidget {
  const BpAuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BpDecoratedBackground(
        child: SafeArea(
          child: Center(
            child: BpSurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandTitle(style: BpTextStyles.authTitle),
                  const SizedBox(height: 10),
                  Text(
                    'Chargement en cours...',
                    style: BpTextStyles.authSubtitle,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: BpColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
