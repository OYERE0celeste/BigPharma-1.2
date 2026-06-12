import 'package:flutter/material.dart';

/// Spacing Tokens for BigPharma Design System
///
/// Provides consistent spacing values throughout the application.
/// Use these instead of hardcoded EdgeInsets or SizedBox values.
class BpSpacingTokens {
  BpSpacingTokens._();

  // ============ BASIC SPACING UNITS ============
  // Using 4pt base unit (Material Design standard)

  static const double xs = 4; // 1 unit
  static const double sm = 8; // 2 units
  static const double md = 12; // 3 units
  static const double lg = 16; // 4 units
  static const double xl = 24; // 6 units
  static const double xxl = 32; // 8 units
  static const double xxxl = 48; // 12 units

  // ============ PADDING SHORTCUTS ============

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXxxl = EdgeInsets.all(xxxl);

  // ============ HORIZONTAL PADDING ============

  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(
    horizontal: xl,
  );
  static const EdgeInsets paddingHorizontalXxl = EdgeInsets.symmetric(
    horizontal: xxl,
  );

  // ============ VERTICAL PADDING ============

  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(
    vertical: lg,
  );
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(
    vertical: xl,
  );
  static const EdgeInsets paddingVerticalXxl = EdgeInsets.symmetric(
    vertical: xxl,
  );

  // ============ MARGIN SHORTCUTS ============

  static const EdgeInsets marginXs = EdgeInsets.all(xs);
  static const EdgeInsets marginSm = EdgeInsets.all(sm);
  static const EdgeInsets marginMd = EdgeInsets.all(md);
  static const EdgeInsets marginLg = EdgeInsets.all(lg);
  static const EdgeInsets marginXl = EdgeInsets.all(xl);
  static const EdgeInsets marginXxl = EdgeInsets.all(xxl);

  // ============ CUSTOM PADDING COMBINATIONS ============

  /// Padding for compact UI elements (buttons, chips)
  static const EdgeInsets paddingCompact = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Padding for standard form fields
  static const EdgeInsets paddingFormField = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Padding for card content
  static const EdgeInsets paddingCard = EdgeInsets.all(lg);

  /// Padding for page content
  static const EdgeInsets paddingPage = EdgeInsets.all(lg);

  /// Padding for modal content
  static const EdgeInsets paddingModal = EdgeInsets.all(xl);

  /// Padding for list items
  static const EdgeInsets paddingListItem = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // ============ GAP SIZES (for Row/Column) ============

  /// Small gap between elements
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);

  /// Horizontal gaps (for Row)
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);
  static const SizedBox gapHorizontalSm = SizedBox(width: sm);
  static const SizedBox gapHorizontalMd = SizedBox(width: md);
  static const SizedBox gapHorizontalLg = SizedBox(width: lg);
  static const SizedBox gapHorizontalXl = SizedBox(width: xl);
  static const SizedBox gapHorizontalXxl = SizedBox(width: xxl);

  /// Vertical gaps (for Column)
  static const SizedBox gapVerticalXs = SizedBox(height: xs);
  static const SizedBox gapVerticalSm = SizedBox(height: sm);
  static const SizedBox gapVerticalMd = SizedBox(height: md);
  static const SizedBox gapVerticalLg = SizedBox(height: lg);
  static const SizedBox gapVerticalXl = SizedBox(height: xl);
  static const SizedBox gapVerticalXxl = SizedBox(height: xxl);

  // ============ BORDER RADIUS ============

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static const BorderRadius borderRadiusXs = BorderRadius.all(
    Radius.circular(radiusXs),
  );
  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(radiusSm),
  );
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(radiusMd),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(radiusXl),
  );

  static const BorderRadius borderRadiusCircle = BorderRadius.all(
    Radius.circular(9999),
  );

  // ============ COMPONENT-SPECIFIC SIZES ============

  static const double buttonHeight = 48;
  static const double buttonHeightSmall = 36;
  static const double buttonHeightLarge = 56;

  static const double chipHeight = 32;
  static const double tagHeight = 24;

  static const double iconButtonSize = 48;
  static const double iconButtonSizeSmall = 40;
  static const double iconButtonSizeLarge = 56;

  static const double avatarSizeSmall = 32;
  static const double avatarSize = 48;
  static const double avatarSizeLarge = 64;

  static const double toolbarHeight = 56;
  static const double appBarHeight = 64;
}

/// Convenience extension for quick access to spacing
extension BpSpacing on BuildContext {
  double get spacingXs => BpSpacingTokens.xs;
  double get spacingSm => BpSpacingTokens.sm;
  double get spacingMd => BpSpacingTokens.md;
  double get spacingLg => BpSpacingTokens.lg;
  double get spacingXl => BpSpacingTokens.xl;
  double get spacingXxl => BpSpacingTokens.xxl;

  EdgeInsets get paddingXs => BpSpacingTokens.paddingXs;
  EdgeInsets get paddingSm => BpSpacingTokens.paddingSm;
  EdgeInsets get paddingMd => BpSpacingTokens.paddingMd;
  EdgeInsets get paddingLg => BpSpacingTokens.paddingLg;
  EdgeInsets get paddingXl => BpSpacingTokens.paddingXl;
  EdgeInsets get paddingXxl => BpSpacingTokens.paddingXxl;
}
