import 'dart:math' as math;

import 'package:flutter/material.dart';

double _linearizeChannel(int value) {
  final normalized = value / 255.0;
  return normalized <= 0.03928
      ? normalized / 12.92
      : math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
}

/// Represents a curated palette seed exposed to the user.
@immutable
class ThemeColorPalette {
  final String name;
  final Color seedColor;
  final IconData icon;
  final Brightness brightness;

  const ThemeColorPalette({
    required this.name,
    required this.seedColor,
    required this.icon,
    this.brightness = Brightness.light,
  });

  Color get primary => seedColor;

  Color get primaryLight => Color.lerp(seedColor, Colors.white, 0.34)!;

  Color get primaryDark => Color.lerp(seedColor, const Color(0xFF101010), 0.30)!;

  Color get accent => Color.lerp(seedColor, Colors.white, 0.18)!;

  ColorScheme schemeFor(Brightness brightness, {double contrastLevel = 0.18}) {
    return buildAppColorScheme(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeColorPalette &&
        other.name == name &&
        other.seedColor.value == seedColor.value &&
        other.icon == icon &&
        other.brightness == brightness;
  }

  @override
  int get hashCode => Object.hash(name, seedColor.value, icon, brightness);
}

class AppThemeColors {
  AppThemeColors._();

  static const ThemeColorPalette pharmacyGreen = ThemeColorPalette(
    name: 'Vert pharmacie',
    seedColor: Color(0xFF2E7D32),
    icon: Icons.local_pharmacy_rounded,
  );

  static const ThemeColorPalette medicalBlue = ThemeColorPalette(
    name: 'Bleu médical',
    seedColor: Color(0xFF1E88E5),
    icon: Icons.medical_services_rounded,
  );

  static const ThemeColorPalette premiumPurple = ThemeColorPalette(
    name: 'Violet premium',
    seedColor: Color(0xFF7B1FA2),
    icon: Icons.diamond_rounded,
  );

  static const ThemeColorPalette indigo = ThemeColorPalette(
    name: 'Indigo',
    seedColor: Color(0xFF3949AB),
    icon: Icons.auto_awesome_rounded,
  );

  static const ThemeColorPalette turquoise = ThemeColorPalette(
    name: 'Turquoise',
    seedColor: Color(0xFF00897B),
    icon: Icons.water_rounded,
  );

  static const ThemeColorPalette professionalGray = ThemeColorPalette(
    name: 'Gris professionnel',
    seedColor: Color(0xFF455A64),
    icon: Icons.business_rounded,
  );

  static const ThemeColorPalette warmAmber = ThemeColorPalette(
    name: 'Ambre doux',
    seedColor: Color(0xFFF57C00),
    icon: Icons.wb_sunny_rounded,
  );

  static const ThemeColorPalette emergencyRed = ThemeColorPalette(
    name: 'Rouge urgence',
    seedColor: Color(0xFFD32F2F),
    icon: Icons.emergency_rounded,
  );

  static const List<ThemeColorPalette> allThemes = [
    pharmacyGreen,
    medicalBlue,
    premiumPurple,
    indigo,
    turquoise,
    professionalGray,
    warmAmber,
    emergencyRed,
  ];

  static ThemeColorPalette getThemeByName(String name) {
    final normalized = _normalize(name);

    for (final theme in allThemes) {
      if (_normalize(theme.name) == normalized) {
        return theme;
      }
    }

    switch (normalized) {
      case 'whatsapp clair':
      case 'bleu medical':
      case 'bleu médical':
      case 'medical blue':
      case 'blue medical':
        return medicalBlue;
      case 'vert pharmacie':
      case 'pharmacy green':
        return pharmacyGreen;
      case 'violet premium':
        return premiumPurple;
      case 'indigo':
        return indigo;
      case 'turquoise':
        return turquoise;
      case 'gris professionnel':
      case 'professional gray':
      case 'professional grey':
        return professionalGray;
      case 'ambre doux':
      case 'orange énergie':
      case 'orange energie':
        return warmAmber;
      case 'rouge urgence':
        return emergencyRed;
      default:
        return pharmacyGreen;
    }
  }

  static ThemeColorPalette? presetFromSeed(Color seedColor) {
    for (final theme in allThemes) {
      if (theme.seedColor.value == seedColor.value) {
        return theme;
      }
    }
    return null;
  }

  static IconData getThemeIcon(String themeName) {
    return getThemeByName(themeName).icon;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}

class ThemeAccessibility {
  ThemeAccessibility._();

  static double contrastRatio(Color foreground, Color background) {
    final luminance1 = _relativeLuminance(foreground);
    final luminance2 = _relativeLuminance(background);
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool isAccessible(
    Color foreground,
    Color background, {
    double minimum = 4.5,
  }) {
    return contrastRatio(foreground, background) >= minimum;
  }

  static Color readableOn(
    Color background, {
    Color light = Colors.white,
    Color dark = const Color(0xFF1F1F1F),
    double minimum = 4.5,
  }) {
    final lightContrast = contrastRatio(light, background);
    final darkContrast = contrastRatio(dark, background);

    if (lightContrast >= minimum && lightContrast >= darkContrast) {
      return light;
    }
    if (darkContrast >= minimum && darkContrast >= lightContrast) {
      return dark;
    }
    return lightContrast >= darkContrast ? light : dark;
  }

  static Color ensureReadableOn(
    Color background, {
    Color? preferred,
    double minimum = 4.5,
  }) {
    if (preferred != null && isAccessible(preferred, background, minimum: minimum)) {
      return preferred;
    }
    return readableOn(background, minimum: minimum);
  }

  static double _relativeLuminance(Color color) {
    final red = _linearizeChannel(color.red);
    final green = _linearizeChannel(color.green);
    final blue = _linearizeChannel(color.blue);
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
  }
}

ColorScheme buildAppColorScheme({
  required Color seedColor,
  required Brightness brightness,
  double contrastLevel = 0.18,
}) {
  final attempts = <double>[
    contrastLevel,
    0.28,
    0.40,
    0.55,
  ];

  for (final level in attempts) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
      contrastLevel: level,
    );
    final accessibleScheme = _enforceReadablePairs(baseScheme);
    if (_passesAccessibility(accessibleScheme)) {
      return accessibleScheme;
    }
  }

  final fallbackScheme = ColorScheme.fromSeed(
    seedColor: AppThemeColors.pharmacyGreen.seedColor,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    contrastLevel: 0.40,
  );
  return _enforceReadablePairs(fallbackScheme);
}

ColorScheme _enforceReadablePairs(ColorScheme scheme) {
  final onPrimary = ThemeAccessibility.ensureReadableOn(
    scheme.primary,
    preferred: scheme.onPrimary,
  );
  final onPrimaryContainer = ThemeAccessibility.ensureReadableOn(
    scheme.primaryContainer,
    preferred: scheme.onPrimaryContainer,
  );
  final onSecondary = ThemeAccessibility.ensureReadableOn(
    scheme.secondary,
    preferred: scheme.onSecondary,
  );
  final onSecondaryContainer = ThemeAccessibility.ensureReadableOn(
    scheme.secondaryContainer,
    preferred: scheme.onSecondaryContainer,
  );
  final onTertiary = ThemeAccessibility.ensureReadableOn(
    scheme.tertiary,
    preferred: scheme.onTertiary,
  );
  final onTertiaryContainer = ThemeAccessibility.ensureReadableOn(
    scheme.tertiaryContainer,
    preferred: scheme.onTertiaryContainer,
  );
  final onError = ThemeAccessibility.ensureReadableOn(
    scheme.error,
    preferred: scheme.onError,
  );
  final onErrorContainer = ThemeAccessibility.ensureReadableOn(
    scheme.errorContainer,
    preferred: scheme.onErrorContainer,
  );
  final onSurface = ThemeAccessibility.ensureReadableOn(
    scheme.surface,
    preferred: scheme.onSurface,
  );
  final onSurfaceVariant = ThemeAccessibility.ensureReadableOn(
    scheme.surfaceContainerHighest,
    preferred: scheme.onSurfaceVariant,
  );

  return scheme.copyWith(
    onPrimary: onPrimary,
    onPrimaryContainer: onPrimaryContainer,
    onSecondary: onSecondary,
    onSecondaryContainer: onSecondaryContainer,
    onTertiary: onTertiary,
    onTertiaryContainer: onTertiaryContainer,
    onError: onError,
    onErrorContainer: onErrorContainer,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    background: scheme.surface,
    onBackground: onSurface,
    surfaceVariant: scheme.surfaceContainerHighest,
  );
}

bool _passesAccessibility(ColorScheme scheme) {
  return ThemeAccessibility.isAccessible(scheme.onPrimary, scheme.primary) &&
      ThemeAccessibility.isAccessible(scheme.onSecondary, scheme.secondary) &&
      ThemeAccessibility.isAccessible(scheme.onSurface, scheme.surface) &&
      ThemeAccessibility.isAccessible(scheme.onError, scheme.error);
}
