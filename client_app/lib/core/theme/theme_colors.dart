import 'package:flutter/material.dart';

/// Defines all available theme colors for BigPharma
class ThemeColorPalette {
  final String name;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Brightness brightness;

  const ThemeColorPalette({
    required this.name,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    this.brightness = Brightness.dark,
  });
}

class AppThemeColors {
  // WhatsApp-like light theme - Default
  static const ThemeColorPalette whatsappLight = ThemeColorPalette(
    name: 'WhatsApp clair',
    primary: Color(0xFF25D366),
    primaryLight: Color(0xFFE8F5E9),
    primaryDark: Color(0xFF075E54),
    accent: Color(0xFF25D366),
    brightness: Brightness.light,
  );

  // Pharmacy Green
  static const ThemeColorPalette pharmacyGreen = ThemeColorPalette(
    name: 'Vert pharmacie',
    primary: Color(0xFF2E7D32),
    primaryLight: Color(0xFF66BB6A),
    primaryDark: Color(0xFF1B5E20),
    accent: Color(0xFF66BB6A),
  );

  // Premium Purple
  static const ThemeColorPalette premiumPurple = ThemeColorPalette(
    name: 'Violet premium',
    primary: Color(0xFF7B1FA2),
    primaryLight: Color(0xFFBA68C8),
    primaryDark: Color(0xFF4A148C),
    accent: Color(0xFFBA68C8),
  );

  // Energy Orange
  static const ThemeColorPalette energyOrange = ThemeColorPalette(
    name: 'Orange énergie',
    primary: Color(0xFFF57C00),
    primaryLight: Color(0xFFFFB74D),
    primaryDark: Color(0xFFE65100),
    accent: Color(0xFFFFB74D),
  );

  // Emergency Red
  static const ThemeColorPalette emergencyRed = ThemeColorPalette(
    name: 'Rouge urgence',
    primary: Color(0xFFD32F2F),
    primaryLight: Color(0xFFEF5350),
    primaryDark: Color(0xFFB71C1C),
    accent: Color(0xFFEF5350),
  );

  // Indigo
  static const ThemeColorPalette indigo = ThemeColorPalette(
    name: 'Indigo',
    primary: Color(0xFF3949AB),
    primaryLight: Color(0xFF5E35B1),
    primaryDark: Color(0xFF283593),
    accent: Color(0xFF5E35B1),
  );

  // Turquoise
  static const ThemeColorPalette turquoise = ThemeColorPalette(
    name: 'Turquoise',
    primary: Color(0xFF00897B),
    primaryLight: Color(0xFF26A69A),
    primaryDark: Color(0xFF004D40),
    accent: Color(0xFF26A69A),
  );

  // Professional Gray
  static const ThemeColorPalette professionalGray = ThemeColorPalette(
    name: 'Gris professionnel',
    primary: Color(0xFF455A64),
    primaryLight: Color(0xFF78909C),
    primaryDark: Color(0xFF263238),
    accent: Color(0xFF78909C),
  );

  /// All available themes
  static const List<ThemeColorPalette> allThemes = [
    pharmacyGreen,
    professionalGray,
    indigo,
    turquoise,
    premiumPurple,
    energyOrange,
    emergencyRed,
    whatsappLight,
  ];

  /// Get theme by name
  static ThemeColorPalette getThemeByName(String name) {
    if (name == 'Bleu médical') {
      return whatsappLight;
    }

    try {
      return allThemes.firstWhere((theme) => theme.name == name);
    } catch (e) {
      return pharmacyGreen; // Default fallback
    }
  }

  /// Get icon for theme color
  static IconData getThemeIcon(String themeName) {
    if (themeName == whatsappLight.name) {
      return Icons.medical_services_rounded;
    }

    switch (themeName) {
      case 'Vert pharmacie':
        return Icons.local_pharmacy;
      case 'Violet premium':
        return Icons.diamond;
      case 'Orange énergie':
        return Icons.flash_on;
      case 'Rouge urgence':
        return Icons.emergency;
      case 'Indigo':
        return Icons.palette;
      case 'Turquoise':
        return Icons.water;
      case 'Gris professionnel':
        return Icons.business;
      default:
        return Icons.palette;
    }
  }
}

/// Extended BP Colors with dynamic theme support
class AppBpColors {
  // Current theme instance
  static ThemeColorPalette? _currentTheme;
  static bool _darkModeEnabled = false;

  /// Initialize with a theme
  static void setTheme(ThemeColorPalette theme) {
    _currentTheme = theme;
  }

  /// Update dark mode override.
  static void setDarkMode(bool enabled) {
    _darkModeEnabled = enabled;
  }

  /// Get current theme
  static ThemeColorPalette get currentTheme =>
      _currentTheme ?? AppThemeColors.pharmacyGreen;

  static bool get isLightTheme => !_darkModeEnabled;

  // Primary colors - dynamic
  static Color get primary => currentTheme.primary;
  static Color get primaryLight => currentTheme.primaryLight;
  static Color get primaryDark => currentTheme.primaryDark;
  static Color get accent => currentTheme.accent;

  // Auth colors
  static Color get authBg1 =>
      isLightTheme ? scaffold : Color.lerp(primaryDark, Colors.black, 0.02)!;
  static Color get authBg2 => isLightTheme ? surface : primary;
  static Color get authBg3 => isLightTheme ? surfaceMuted : primaryLight;

  // Scaffold colors
  static Color get scaffold => isLightTheme
      ? const Color(0xFFF5F8F6)
      : Color.lerp(primaryDark, Colors.black, 0.08)!;

  static Color get scaffoldSecondary =>
      isLightTheme ? const Color(0xFFEAF4ED) : primary;

  static Color get surface => isLightTheme
      ? Colors.white
      : Color.lerp(primaryDark, Colors.black, 0.02)!;

  static Color get surfaceStrong =>
      isLightTheme ? Colors.white : Color.lerp(primaryDark, primary, 0.16)!;

  static Color get surfaceMuted => isLightTheme
      ? Color.lerp(Colors.white, primary, 0.08)!
      : Color.lerp(primaryDark, primaryLight, 0.18)!;

  static Color get cardBg => surface;

  static Color get cardHighlight =>
      isLightTheme ? Color.lerp(Colors.white, primary, 0.10)! : primaryLight;

  static Color get glass =>
      isLightTheme ? Colors.white.withOpacity(0.85) : const Color(0x5C1E6E4C);

  // Text colors
  static Color get textPrimary =>
      isLightTheme ? const Color(0xFF10241E) : Colors.white;

  static Color get textSecondary =>
      isLightTheme ? const Color(0xFF4F635D) : Colors.white.withOpacity(0.9);

  static Color get textHint =>
      isLightTheme ? const Color(0xFF6C7E77) : const Color(0xB3FFFFFF);

  static Color get textOnDark => isLightTheme ? textPrimary : Colors.white;

  static Color get textOnDarkMuted =>
      isLightTheme ? textSecondary : Colors.white.withOpacity(0.72);

  // Status colors
  static const Color error = Color(0xFFE86B6B);
  static const Color success = Color(0xFF4CD286);
  static const Color warning = Color(0xFFF3B85B);

  // Border colors
  static Color get border => isLightTheme
      ? Color.lerp(Colors.grey.shade300, primary, 0.08)!.withOpacity(0.96)
      : const Color(0x335F8174);

  static Color get borderStrong => isLightTheme
      ? primary.withOpacity(0.25)
      : Color.fromARGB(
          102,
          currentTheme.primary.red,
          currentTheme.primary.green,
          currentTheme.primary.blue,
        );

  static Color get borderFocused => accent;
}
