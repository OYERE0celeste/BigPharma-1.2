import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class BpColors {
  BpColors._();

  static const Color primary = Color(0xFF1E6E4C);
  static const Color primaryLight = Color(0xFF2F996C);
  static const Color primaryDark = Color(0xFF082117);
  static const Color accent = Color(0xFF39C17E);

  static const Color authBg1 = Color(0xFF04140E);
  static const Color authBg2 = Color(0xFF0A241A);
  static const Color authBg3 = Color(0xFF103126);

  static const Color scaffold = Color(0xFF071912);
  static const Color scaffoldSecondary = Color(0xFF0B2118);
  static const Color surface = Color(0xFF193126);
  static const Color surfaceStrong = Color(0xFF213A2F);
  static const Color surfaceMuted = Color(0xFF2A4338);
  static const Color cardBg = Color(0xFF233B30);
  static const Color cardHighlight = Color(0xFF2C473B);
  static const Color glass = Color(0x5C355046);

  static const Color textPrimary = Color(0xFFF2FBF6);
  static const Color textSecondary = Color(0xFFB5C8BD);
  static const Color textHint = Color(0xFF8EA699);
  static const Color textOnDark = Colors.white;
  static const Color textOnDarkMuted = Color(0xFFB9CCC0);

  static const Color error = Color(0xFFE86B6B);
  static const Color success = Color(0xFF4CD286);
  static const Color warning = Color(0xFFF3B85B);

  static const Color border = Color(0x335F8174);
  static const Color borderStrong = Color(0x667BA392);
  static const Color borderFocused = accent;
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

  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: BpColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: BpColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: BpColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: BpColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BpColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BpColors.textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: BpColors.textHint,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle headingOnDark = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.3,
  );

  static const TextStyle authTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  static const TextStyle authSubtitle = TextStyle(
    fontSize: 14,
    color: BpColors.textOnDarkMuted,
    height: 1.5,
  );

  static const TextStyle authBadge = TextStyle(
    fontSize: 12,
    color: BpColors.accent,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyOnDark = TextStyle(
    fontSize: 13,
    color: BpColors.textOnDarkMuted,
    height: 1.5,
  );

  static const TextStyle labelOnDark = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: BpColors.textOnDarkMuted,
  );
}

class BpTheme {
  BpTheme._();

  static ThemeData materialTheme() {
    const colorScheme = ColorScheme.dark(
      primary: BpColors.accent,
      onPrimary: BpColors.primaryDark,
      secondary: BpColors.primaryLight,
      onSecondary: BpColors.primaryDark,
      error: BpColors.error,
      onError: Colors.white,
      surface: BpColors.surface,
      onSurface: BpColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: 'sans-serif',
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: BpColors.surface,
      shadowColor: Colors.black,
      dividerColor: BpColors.border,
      splashFactory: InkSparkle.splashFactory,
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
          const TextTheme(
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: BpColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BpColors.surfaceStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusXl),
          side: const BorderSide(color: BpColors.border),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: BpColors.cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          side: const BorderSide(color: BpColors.border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: BpColors.surfaceStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
          side: const BorderSide(color: BpColors.border),
        ),
        textStyle: const TextStyle(color: BpColors.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BpColors.surfaceStrong,
        contentTextStyle: const TextStyle(color: BpColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BpSpacing.radiusMd),
          side: const BorderSide(color: BpColors.border),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BpColors.accent,
          foregroundColor: BpColors.primaryDark,
          disabledBackgroundColor: BpColors.accent.withOpacity(0.4),
          disabledForegroundColor: BpColors.primaryDark.withOpacity(0.6),
          minimumSize: const Size(0, 54),
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
          side: const BorderSide(color: BpColors.borderStrong),
          minimumSize: const Size(0, 52),
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BpColors.accent,
        foregroundColor: BpColors.primaryDark,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BpColors.surfaceStrong,
        disabledColor: BpColors.surfaceMuted,
        selectedColor: BpColors.accent.withOpacity(0.18),
        secondarySelectedColor: BpColors.accent.withOpacity(0.18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: const TextStyle(color: BpColors.textSecondary),
        secondaryLabelStyle: const TextStyle(color: BpColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: BpColors.border),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: BpColors.textSecondary,
        textColor: BpColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
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
        todayForegroundColor: const WidgetStatePropertyAll(BpColors.accent),
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

  static const InputDecorationTheme _inputDecorationTheme =
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
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [BpColors.authBg1, BpColors.authBg2, BpColors.authBg3],
            ),
          ),
        ),
        Positioned(
          top: -140,
          right: -100,
          child: _buildBlob(380, BpColors.primary.withOpacity(0.16)),
        ),
        Positioned(
          bottom: -120,
          left: -80,
          child: _buildBlob(300, BpColors.accent.withOpacity(0.11)),
        ),
        Positioned(
          top: 180,
          left: -120,
          child: _buildBlob(240, Colors.white.withOpacity(0.03)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.02),
                  Colors.transparent,
                  Colors.black.withOpacity(0.10),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  static Widget _buildBlob(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
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
    this.blurSigma = 10,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color:
            color ??
            (kIsWeb ? BpColors.glass.withOpacity(0.85) : BpColors.glass),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: BpColors.borderStrong, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );

    if (kIsWeb) {
      return Container(margin: margin, child: cardContent);
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: cardContent,
        ),
      ),
    );
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
      color: const Color(0xE6223A30),
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
      labelStyle: const TextStyle(fontSize: 14, color: BpColors.textSecondary),
      hintStyle: const TextStyle(fontSize: 13, color: BpColors.textHint),
      prefixIconColor: BpColors.textSecondary,
      suffixIcon: suffixIconWidget,
      filled: true,
      fillColor: BpColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: const BorderSide(color: BpColors.border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: const BorderSide(color: BpColors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: const BorderSide(color: BpColors.accent, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: const BorderSide(color: BpColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: const BorderSide(color: BpColors.error, width: 1.8),
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
  }) {
    return InputDecoration(
      hintText: hint ?? label,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.34), fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 20, color: Colors.white.withOpacity(0.58))
          : null,
      suffixIcon: suffixIconWidget,
      filled: true,
      fillColor: Colors.white.withOpacity(0.09),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BpSpacing.radiusLg),
        borderSide: const BorderSide(color: BpColors.accent, width: 1.8),
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
    final foreground = isDark ? BpColors.primaryDark : Colors.white;

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
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [BpColors.primary, BpColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('BigPharma', style: BpTextStyles.authTitle),
                  const SizedBox(height: 10),
                  const Text(
                    'Chargement en cours...',
                    style: BpTextStyles.authSubtitle,
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
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
