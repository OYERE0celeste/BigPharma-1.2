import 'package:flutter/material.dart';

import 'color_tokens.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color card;
  final Color elevatedSurface;
  final Color surfaceMuted;
  final Color surfaceStrong;
  final Color border;
  final Color borderStrong;
  final Color hover;
  final Color selected;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color glass;
  final Color shadow;
  final Color gradientStart;
  final Color gradientMiddle;
  final Color gradientEnd;
  final Color textMuted;
  final Color textHint;
  final Color divider;

  const AppThemeExtension({
    required this.card,
    required this.elevatedSurface,
    required this.surfaceMuted,
    required this.surfaceStrong,
    required this.border,
    required this.borderStrong,
    required this.hover,
    required this.selected,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.glass,
    required this.shadow,
    required this.gradientStart,
    required this.gradientMiddle,
    required this.gradientEnd,
    required this.textMuted,
    required this.textHint,
    required this.divider,
  });

  factory AppThemeExtension.fromScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final hoverOpacity = isDark ? 0.14 : 0.08;
    final selectedOpacity = isDark ? 0.20 : 0.12;
    final successColor = const Color(0xFF1F8A5B);
    final warningColor = const Color(0xFFB66A1F);
    final infoColor = scheme.tertiary;

    return AppThemeExtension(
      card: scheme.surfaceContainerLow,
      elevatedSurface: scheme.surfaceContainer,
      surfaceMuted: scheme.surfaceContainerHighest,
      surfaceStrong: scheme.surfaceContainerHigh,
      border: scheme.outlineVariant,
      borderStrong: scheme.outline,
      hover: scheme.primary.withOpacity(hoverOpacity),
      selected: scheme.primaryContainer.withOpacity(selectedOpacity),
      success: successColor,
      onSuccess: ThemeAccessibility.readableOn(successColor),
      warning: warningColor,
      onWarning: ThemeAccessibility.readableOn(warningColor),
      info: infoColor,
      onInfo: ThemeAccessibility.readableOn(infoColor),
      glass: scheme.surface.withOpacity(isDark ? 0.84 : 0.92),
      shadow: scheme.shadow.withOpacity(isDark ? 0.28 : 0.18),
      gradientStart: Color.lerp(scheme.surface, scheme.primary, isDark ? 0.18 : 0.06)!,
      gradientMiddle: scheme.surfaceContainerLow,
      gradientEnd: Color.lerp(scheme.surface, scheme.primaryContainer, isDark ? 0.14 : 0.08)!,
      textMuted: scheme.onSurfaceVariant,
      textHint: scheme.onSurfaceVariant.withOpacity(isDark ? 0.82 : 0.72),
      divider: scheme.outlineVariant,
    );
  }

  @override
  AppThemeExtension copyWith({
    Color? card,
    Color? elevatedSurface,
    Color? surfaceMuted,
    Color? surfaceStrong,
    Color? border,
    Color? borderStrong,
    Color? hover,
    Color? selected,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? glass,
    Color? shadow,
    Color? gradientStart,
    Color? gradientMiddle,
    Color? gradientEnd,
    Color? textMuted,
    Color? textHint,
    Color? divider,
  }) {
    return AppThemeExtension(
      card: card ?? this.card,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      hover: hover ?? this.hover,
      selected: selected ?? this.selected,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      glass: glass ?? this.glass,
      shadow: shadow ?? this.shadow,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMiddle: gradientMiddle ?? this.gradientMiddle,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      textMuted: textMuted ?? this.textMuted,
      textHint: textHint ?? this.textHint,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      card: Color.lerp(card, other.card, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientMiddle: Color.lerp(gradientMiddle, other.gradientMiddle, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.fromScheme(colorScheme);

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
