# BigPharma Design System - Comprehensive Guide

## Overview

The BigPharma Design System provides a **centralized, theme-aware** system for managing all visual aspects of the application. This ensures consistency, accessibility, and maintainability across all platforms (Client, Pharmacy, Lab, Admin).

---

## ✅ Core Principles

### 1. **No Hardcoded Colors**
❌ **NEVER DO THIS:**
```dart
Container(color: Colors.white)
Text('Hello', style: TextStyle(color: Colors.black))
Icon(Icons.add, color: Colors.blue)
```

✅ **DO THIS INSTEAD:**
```dart
// Using theme
Container(color: context.surfaceColor)
Text('Hello', style: context.bodyMedium)
Icon(Icons.add, color: context.primaryColor)

// Or using tokens directly
Container(color: BpColorTokens.white)
Text('Hello', style: BpTypographyTokens.bodyMedium(context))
```

### 2. **Use Theme-Aware APIs**
- `Theme.of(context)` - Access material theme
- `context.colorScheme` - Quick access to color scheme
- `context.primaryColor` - Semantic color access
- `BpTypographyTokens` - Text styles
- `BpSpacingTokens` - Spacing and sizing

### 3. **Material 3 First**
All themes use `useMaterial3: true` and `ColorScheme.fromSeed()` for:
- Automatic color harmonization
- Semantic color roles (primary, secondary, tertiary, etc.)
- Accessibility compliance out of the box

---

## 📁 Design System Architecture

```
lib/core/theme/
├── color_tokens.dart           # Color definitions
├── typography_tokens.dart      # Text style definitions  
├── spacing_tokens.dart         # Spacing and sizing
├── app_theme.dart              # Material 3 theme builders
├── theme_controller.dart       # State management & persistence
├── theme_extensions.dart       # BuildContext extensions
├── theme_validator.dart        # WCAG AA contrast checking
└── index.dart                  # Barrel export
```

---

## 🎨 Color System

### Color Tokens (Foundation)
Defined in `color_tokens.dart`, these are the raw color values:

```dart
class BpColorTokens {
  // Semantic colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);
  
  // Surface colors  
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  
  // Greys
  static const Color grey50 through grey900
}
```

### Semantic Colors (Usage)
Use `BpColors` class for theme-aware access:

```dart
// ✅ CORRECT
Color textColor = BpColors.textPrimary(context.brightness);
Color surface = BpColors.surface(context.brightness);

// Or use extensions
Color textColor = context.textPrimaryColor;
Color success = context.successColor;
```

### Quick Reference
| Purpose | Light Mode | Dark Mode |
|---------|-----------|----------|
| **Background** | `surfaceLight` | `surfaceDark` |
| **Text** | `textPrimaryLight` | `textPrimaryDark` |
| **Success** | `Color(0xFF2E7D32)` | `Color(0xFF2E7D32)` |
| **Error** | `Color(0xFFC62828)` | `Color(0xFFC62828)` |
| **Warning** | `Color(0xFFF57C00)` | `Color(0xFFF57C00)` |

---

## 🔤 Typography System

### Text Style Hierarchy
Defined in `typography_tokens.dart`:

```dart
// Display styles (large headings)
context.displayLarge     // 57pt
context.displayMedium    // 45pt
context.displaySmall     // 36pt

// Headlines
context.headlineLarge    // 32pt (page titles)
context.headlineMedium   // 28pt
context.headlineSmall    // 24pt

// Titles  
context.titleLarge       // 22pt (card titles)
context.titleMedium      // 16pt (form labels)
context.titleSmall       // 14pt

// Body text
context.bodyLarge        // 16pt (main content)
context.bodyMedium       // 14pt (standard)
context.bodySmall        // 12pt

// Labels
context.labelLarge       // 14pt (buttons)
context.labelMedium      // 12pt
context.labelSmall       // 11pt
```

### Using Typography

✅ **CORRECT:**
```dart
Text('Title', style: context.headlineLarge)
Text('Body', style: context.bodyMedium)
Text('Button', style: context.labelLarge)
```

❌ **INCORRECT:**
```dart
Text('Title', style: TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w400,
  color: Colors.black,  // ❌ Hardcoded color
))
```

### Custom Colors in Text
```dart
// Get style with specific color
Text(
  'Success',
  style: context.bodyMedium.copyWith(color: context.successColor),
)

// Use helper methods
Text(
  'Error',
  style: BpTypographyTokens.getErrorTextStyle(context.bodyMedium),
)
```

---

## 📏 Spacing System

### Spacing Tokens
Base unit: 4pt (Material Design standard)

```dart
// Basic units
BpSpacingTokens.xs  = 4pt
BpSpacingTokens.sm  = 8pt
BpSpacingTokens.md  = 12pt
BpSpacingTokens.lg  = 16pt
BpSpacingTokens.xl  = 24pt
BpSpacingTokens.xxl = 32pt
BpSpacingTokens.xxxl = 48pt

// Pre-built padding
BpSpacingTokens.paddingMd      // EdgeInsets.all(12)
BpSpacingTokens.paddingLg      // EdgeInsets.all(16)
BpSpacingTokens.paddingXl      // EdgeInsets.all(24)

// Pre-built gaps (for Row/Column)
BpSpacingTokens.gapMd          // SizedBox(width/height: 12)
BpSpacingTokens.gapLg          // SizedBox(width/height: 16)

// Component sizes
BpSpacingTokens.buttonHeight        // 48
BpSpacingTokens.buttonHeightSmall   // 36
BpSpacingTokens.avatarSize          // 48
BpSpacingTokens.toolbarHeight       // 56
```

### Using Spacing

✅ **CORRECT:**
```dart
Container(
  padding: BpSpacingTokens.paddingLg,
  child: Column(
    children: [
      Text('Item 1'),
      BpSpacingTokens.gapVerticalMd,
      Text('Item 2'),
    ],
  ),
)
```

❌ **INCORRECT:**
```dart
Container(
  padding: const EdgeInsets.all(16),  // ❌ Magic number
  child: Column(
    children: [
      Text('Item 1'),
      const SizedBox(height: 12),     // ❌ Magic number
      Text('Item 2'),
    ],
  ),
)
```

### Border Radius
```dart
BpSpacingTokens.borderRadiusXs   // 4pt radius
BpSpacingTokens.borderRadiusSm   // 8pt radius
BpSpacingTokens.borderRadiusMd   // 12pt radius
BpSpacingTokens.borderRadiusLg   // 16pt radius
BpSpacingTokens.borderRadiusXl   // 24pt radius
BpSpacingTokens.borderRadiusCircle // 9999 (full circle)

// Usage
Container(
  decoration: BoxDecoration(
    borderRadius: BpSpacingTokens.borderRadiusMd,
  ),
)
```

---

## 🌓 Theme Switching

### Theme Controller
Manages theme state and persistence:

```dart
final controller = BpThemeController();

// Set theme mode
await controller.setThemeMode(BpThemeMode.dark);

// Set custom seed color
await controller.setSeedColor(Color(0xFF4A90E2));

// Get current theme
ThemeData lightTheme = controller.getLightTheme();
ThemeData darkTheme = controller.getDarkTheme();

// Reset to defaults
await controller.resetToDefaults();
```

### In MaterialApp
```dart
MaterialApp(
  theme: bpThemeController.getLightTheme(),
  darkTheme: bpThemeController.getDarkTheme(),
  themeMode: ThemeMode.system, // or ThemeMode.light/dark
)
```

---

## ♿ Accessibility (WCAG AA)

### Contrast Validation
All text/background combinations must meet WCAG AA standards:

```dart
// Check if colors meet WCAG AA
bool passes = BpContrastValidator.meetsWcagAANormalText(
  foreground: Colors.black,
  background: Colors.white,
);

// Get diagnostic info
String report = BpContrastValidator.getDiagnostics(
  foreground: Colors.black,
  background: Colors.white,
);
print(report);

// Get accessible text color for background
Color textColor = BpContrastValidator.getAccessibleTextColor(
  backgroundColor,
);
```

### Minimum Contrast Ratios
- **Normal Text**: 4.5:1 (WCAG AA)
- **Large Text**: 3:1 (WCAG AA)

---

## 🔧 Extension Methods

### Context Extensions
Quick access via `BuildContext`:

```dart
// Colors
context.primaryColor
context.successColor
context.errorColor
context.textPrimaryColor

// Text Styles
context.headlineLarge
context.bodyMedium
context.labelSmall

// Shapes
context.borderRadiusMd
context.borderRadiusLg

// Utilities
context.isDarkMode      // bool
context.isLightMode     // bool
context.colorScheme     // ColorScheme
context.brightness      // Brightness
```

### Color Extensions
```dart
Color c = Color(0xFF000000);

c.darken(amount: 0.2)          // 20% darker
c.lighten(amount: 0.2)         // 20% lighter
c.withSemiTransparency()       // 50% opacity
c.invert()                     // Inverted colors
```

---

## ❌ Common Mistakes (DO NOT DO)

### 1. Hardcoded Colors
```dart
// ❌ WRONG
Container(color: Colors.white)
Text('Hello', style: TextStyle(color: Colors.black))
Icon(Icons.add, color: const Color(0xFF2196F3))

// ✅ RIGHT
Container(color: context.surfaceColor)
Text('Hello', style: context.bodyMedium)
Icon(Icons.add, color: context.primaryColor)
```

### 2. Magic Numbers
```dart
// ❌ WRONG
Padding(padding: const EdgeInsets.all(16))
SizedBox(height: 24)
BorderRadius.circular(12)

// ✅ RIGHT
Padding(padding: BpSpacingTokens.paddingLg)
BpSpacingTokens.gapVerticalXl
BorderRadius.circular(BpSpacingTokens.radiusMd)
```

### 3. Colors.xyz
```dart
// ❌ WRONG
Colors.white, Colors.black, Colors.grey, Colors.blue
Colors.red.shade200
Colors.grey[500]

// ✅ RIGHT
BpColorTokens.white
BpColorTokens.grey500
context.successColor
```

### 4. Shade Modifiers
```dart
// ❌ WRONG
Colors.grey.shade300
Colors.red.shade50

// ✅ RIGHT
BpColorTokens.grey300
BpColorTokens.badgeError  // Pre-defined shade
```

### 5. Fixed TextStyle Colors
```dart
// ❌ WRONG
TextStyle(fontSize: 16, color: Colors.black87)

// ✅ RIGHT
context.bodyLarge
BpTypographyTokens.bodyLarge(context)
```

---

## 📊 Component Guidelines

### Cards
```dart
Card(
  color: context.surfaceColor,
  child: Padding(
    padding: BpSpacingTokens.paddingLg,
    child: Text('Content', style: context.bodyMedium),
  ),
)
```

### Buttons
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Click me', style: context.labelLarge),
)

OutlinedButton(
  onPressed: () {},
  child: Text('Cancel', style: context.labelLarge),
)
```

### Forms
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    labelStyle: context.titleMedium,
    hintText: 'Enter your email',
    hintStyle: context.bodyMedium.copyWith(
      color: context.textSecondaryColor,
    ),
  ),
)
```

### Lists
```dart
ListTile(
  title: Text('Item', style: context.titleMedium),
  subtitle: Text('Description', style: context.bodySmall),
  leading: Container(
    width: BpSpacingTokens.avatarSize,
    height: BpSpacingTokens.avatarSize,
    decoration: BoxDecoration(
      color: context.primaryColor,
      borderRadius: BpSpacingTokens.borderRadiusCircle,
    ),
  ),
)
```

---

## 🚀 Migration Checklist

To migrate existing code to the new design system:

- [ ] Replace all `Colors.white` → `BpColorTokens.white`
- [ ] Replace all `Colors.black` → `BpColorTokens.black`
- [ ] Replace all `Colors.xxx.shadeYYY` → `BpColorTokens.greyXXX`
- [ ] Replace all `Color(0xFFHEXVALUE)` → appropriate `BpColorTokens` constant
- [ ] Replace all hardcoded `TextStyle(color: Colors.xxx)` → use `context.styleXxx` or add color to existing style
- [ ] Replace all hardcoded `EdgeInsets.all(N)` → `BpSpacingTokens.paddingXxx`
- [ ] Replace all hardcoded `SizedBox(width/height: N)` → `BpSpacingTokens.gapXxx`
- [ ] Replace all hardcoded `BorderRadius.circular(N)` → `BpSpacingTokens.borderRadiusXxx`
- [ ] Add `import 'package:client_app/core/theme/index.dart';` to files needing theme access

---

## 📝 Examples

### Example 1: Product Card
```dart
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: context.surfaceContainerColor,
              borderRadius: BpSpacingTokens.borderRadiusMd,
            ),
            // Image goes here
          ),
          Padding(
            padding: BpSpacingTokens.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: context.titleMedium,
                ),
                BpSpacingTokens.gapVerticalSm,
                Text(
                  product.description,
                  style: context.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                BpSpacingTokens.gapVerticalMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price}',
                      style: context.titleLarge.copyWith(
                        color: context.successColor,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Add', style: context.labelMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Status Badge
```dart
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({required this.status});

  Color _getStatusColor(BuildContext context) {
    switch (status) {
      case 'confirmed':
        return context.orderConfirmedColor;
      case 'pending':
        return context.orderPendingColor;
      case 'cancelled':
        return context.orderCancelledColor;
      case 'shipped':
        return context.orderShippedColor;
      default:
        return context.outlineColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: BpSpacingTokens.paddingCompact,
      decoration: BoxDecoration(
        color: _getStatusColor(context).withOpacity(0.1),
        borderRadius: BpSpacingTokens.borderRadiusSm,
        border: Border.all(color: _getStatusColor(context)),
      ),
      child: Text(
        status,
        style: context.labelSmall.copyWith(
          color: _getStatusColor(context),
        ),
      ),
    );
  }
}
```

---

## 🔍 Validation

### Pre-commit Checks
Before committing code:

1. ✅ Search for `Colors.` in files - should find NONE
2. ✅ Search for `Color(0x` in files - should find NONE in widgets
3. ✅ Search for hardcoded numbers in padding/margin - should find NONE
4. ✅ All text uses context style methods
5. ✅ Run `flutter analyze` - should pass

### Git Hooks
Add this to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Prevent commits with hardcoded colors
if git diff --cached | grep -E 'Colors\.|Color\(0x' | grep -v 'color_tokens.dart' | grep -v 'app_theme.dart'; then
  echo "❌ Hardcoded colors detected. Use BpColorTokens or theme system."
  exit 1
fi
```

---

## 📚 Further Reading

- [Material 3 Specification](https://m3.material.io/)
- [WCAG 2.1 Contrast Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
- [Flutter Theme Documentation](https://flutter.dev/docs/cookbook/design/themes)

---

## ❓ FAQ

**Q: Can I use Colors.white or Colors.black directly?**  
A: Only in `color_tokens.dart`. Never in widget files.

**Q: What if the token doesn't exist?**  
A: Add it to `color_tokens.dart` or `spacing_tokens.dart`. Never hardcode values.

**Q: How do I support dark mode?**  
A: Use `context.brightness` or `context.isDarkMode` to check, then use appropriate colors.

**Q: Can I override theme values per-widget?**  
A: Use `.copyWith()` on styles or pass optional color parameters.

**Q: What about animations/transitions?**  
A: Use `AnimatedBuilder` or `AnimatedContainer` with theme values.

---

**Last Updated:** June 12, 2026  
**Version:** 1.0 - Material 3 Complete Redesign
