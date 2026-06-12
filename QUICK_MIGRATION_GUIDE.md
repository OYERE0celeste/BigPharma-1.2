# Quick Migration Guide - BigPharma Design System

## 🚀 30-Second Migration

### Step 1: Add Import
```dart
import 'package:client_app/core/theme/index.dart';
```

### Step 2: Replace Colors

| Old ❌ | New ✅ | Use When |
|--------|--------|----------|
| `Colors.white` | `BpColorTokens.white` | Need constant white |
| `Colors.black` | `BpColorTokens.black` | Need constant black |
| `Colors.grey` | `BpColorTokens.grey500` | Need grey (various shades) |
| `Color(0xFFABCDEF)` | `BpColorTokens.xxxxx` | Any hardcoded color |
| (in TextStyle) `color: Colors.xxx` | `style: context.styleXxx` | Text styling |

### Step 3: Replace Spacing

| Old ❌ | New ✅ |
|--------|--------|
| `EdgeInsets.all(16)` | `BpSpacingTokens.paddingLg` |
| `SizedBox(height: 12)` | `BpSpacingTokens.gapVerticalMd` |
| `BorderRadius.circular(12)` | `BpSpacingTokens.borderRadiusMd` |
| `const SizedBox(width: 8)` | `BpSpacingTokens.gapHorizontalSm` |

### Step 4: Replace Typography

| Old ❌ | New ✅ |
|--------|--------|
| `TextStyle(fontSize: 16, fontWeight: FontWeight.w400)` | `context.bodyLarge` |
| `TextStyle(fontSize: 14, fontWeight: FontWeight.w500)` | `context.titleMedium` |
| `TextStyle(fontSize: 12)` | `context.bodySmall` |
| `TextStyle(fontSize: 22, fontWeight: FontWeight.w500)` | `context.titleLarge` |

---

## 🎯 By Widget Type

### Text Widget
```dart
// ❌ BEFORE
Text(
  'Hello',
  style: TextStyle(
    fontSize: 14,
    color: Colors.black,
  ),
)

// ✅ AFTER
Text(
  'Hello',
  style: context.bodyMedium,
)
```

### Container
```dart
// ❌ BEFORE
Container(
  color: Colors.white,
  padding: const EdgeInsets.all(16),
  child: Text('Content'),
)

// ✅ AFTER
Container(
  color: context.surfaceColor,
  padding: BpSpacingTokens.paddingLg,
  child: Text('Content', style: context.bodyMedium),
)
```

### Card
```dart
// ❌ BEFORE
Card(
  color: Colors.white,
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Text('Card content'),
  ),
)

// ✅ AFTER
Card(
  child: Padding(
    padding: BpSpacingTokens.paddingMd,
    child: Text('Card content', style: context.bodyMedium),
  ),
)
```

### Button
```dart
// ❌ BEFORE
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
  ),
  onPressed: () {},
  child: Text('Click'),
)

// ✅ AFTER
ElevatedButton(
  onPressed: () {},
  child: Text('Click', style: context.labelLarge),
)
```

### TextField
```dart
// ❌ BEFORE
TextField(
  decoration: InputDecoration(
    hintText: 'Enter text',
    hintStyle: TextStyle(color: Colors.grey),
  ),
)

// ✅ AFTER
TextField(
  decoration: InputDecoration(
    hintText: 'Enter text',
    hintStyle: context.bodyMedium.copyWith(
      color: context.textSecondaryColor,
    ),
  ),
)
```

### Column/Row Spacing
```dart
// ❌ BEFORE
Column(
  children: [
    Text('Item 1'),
    const SizedBox(height: 16),
    Text('Item 2'),
    const SizedBox(height: 16),
    Text('Item 3'),
  ],
)

// ✅ AFTER
Column(
  children: [
    Text('Item 1', style: context.bodyMedium),
    BpSpacingTokens.gapVerticalLg,
    Text('Item 2', style: context.bodyMedium),
    BpSpacingTokens.gapVerticalLg,
    Text('Item 3', style: context.bodyMedium),
  ],
)
```

### Icon
```dart
// ❌ BEFORE
Icon(
  Icons.add,
  color: Colors.blue,
  size: 24,
)

// ✅ AFTER
Icon(
  Icons.add,
  color: context.primaryColor,
  size: 24,
)
```

### BorderRadius
```dart
// ❌ BEFORE
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
  ),
)

// ✅ AFTER
Container(
  decoration: BoxDecoration(
    borderRadius: BpSpacingTokens.borderRadiusMd,
  ),
)
```

### Status Indicator
```dart
// ❌ BEFORE
Container(
  color: status == 'success' ? Colors.green : Colors.red,
  child: Text(status),
)

// ✅ AFTER
Container(
  color: status == 'success' 
    ? context.successColor 
    : context.errorColor,
  child: Text(status, style: context.labelSmall),
)
```

---

## 🔍 Find & Replace Patterns

### VSCode Find/Replace Regex

#### Replace Colors.white
- Find: `Colors\.white`
- Replace: `BpColorTokens.white` or `context.surfaceColor`

#### Replace Colors.black
- Find: `Colors\.black`  
- Replace: `BpColorTokens.black` or `context.onSurfaceColor`

#### Replace Colors.grey
- Find: `Colors\.grey(?![0-9])`
- Replace: `BpColorTokens.grey500` or `context.textSecondaryColor`

#### Replace Color(0xFF...)
- Find: `Color\(0x[A-F0-9]{8}\)`
- Replace: (manually check each and use appropriate BpColorTokens constant)

#### Replace SizedBox(height:
- Find: `const SizedBox\(height: (\d+)\)`
- Replace: (map to appropriate BpSpacingTokens.gap)

#### Replace const EdgeInsets
- Find: `const EdgeInsets\.all\((\d+)\)`
- Replace: (map to appropriate BpSpacingTokens.padding)

---

## ✅ Validation Checklist

Before committing changes:

- [ ] No `Colors.` in file (except imports)
- [ ] No `Color(0x` in file (except design tokens)
- [ ] No hardcoded numbers in padding/margin (should use BpSpacingTokens)
- [ ] All Text widgets use `context.styleXxx` or explicit theme style
- [ ] All Containers with color use theme-aware colors
- [ ] `flutter analyze` passes
- [ ] Tested in both light and dark modes
- [ ] Visual check - no invisible text

---

## 🎓 Example: Complete Widget Refactor

### Before
```dart
class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.items.length.toString() + ' items',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '\$${order.total}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
```

### After
```dart
class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: BpSpacingTokens.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: context.titleMedium,
                ),
                Container(
                  padding: BpSpacingTokens.paddingCompact,
                  decoration: BoxDecoration(
                    color: _getStatusColor(context),
                    borderRadius: BpSpacingTokens.borderRadiusXs,
                  ),
                  child: Text(
                    order.status,
                    style: context.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            BpSpacingTokens.gapVerticalMd,
            Text(
              '${order.items.length} items',
              style: context.bodySmall,
            ),
            BpSpacingTokens.gapVerticalMd,
            Text(
              '\$${order.total}',
              style: context.titleLarge.copyWith(
                color: context.successColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (order.status) {
      case 'confirmed':
        return context.orderConfirmedColor;
      case 'pending':
        return context.orderPendingColor;
      case 'cancelled':
        return context.orderCancelledColor;
      default:
        return context.outlineColor;
    }
  }
}
```

---

## 🆘 Need Help?

### Where to Find...
- **Color Definitions**: `lib/core/theme/color_tokens.dart`
- **Text Styles**: `lib/core/theme/typography_tokens.dart`
- **Spacing/Sizing**: `lib/core/theme/spacing_tokens.dart`
- **Extensions**: `lib/core/theme/theme_extensions.dart`
- **Full Guide**: `DESIGN_SYSTEM_COMPLETE_GUIDE.md`

### Quick Questions
1. **"What color should I use?"** → Check `BpColorTokens` or `BpColors` in design system guide
2. **"What spacing should I use?"** → Check `BpSpacingTokens` for the appropriate unit
3. **"What text style?"** → Use `context.styleXxx` matching the semantic purpose
4. **"Something not in design system?"** → Add it to the appropriate token file

---

**Happy Migrating! 🚀**
