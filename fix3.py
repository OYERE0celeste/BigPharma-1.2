import re
import os

def fix_bp(path):
    with open(path, 'r', encoding='utf-8') as f:
        c = f.read()

    # 1. Imports
    if "import '../core/theme/theme_colors.dart';" not in c:
        c = c.replace("import 'brand_title.dart';", "import '../core/theme/theme_colors.dart';\nimport 'brand_title.dart';")
    
    # 2. colorScheme
    c = c.replace("const colorScheme = ColorScheme.dark(", "final colorScheme = ColorScheme.dark(")

    # 3. BpTextStyles (const -> get)
    c = re.sub(r'static const TextStyle (\w+)\s*=\s*const TextStyle\(', r'static TextStyle get \1 => TextStyle(', c)
    c = re.sub(r'static const TextStyle (\w+)\s*=\s*TextStyle\(', r'static TextStyle get \1 => TextStyle(', c)
    
    # 4. BpColors Block replacement
    c = re.sub(r'static const Color (\w+) = Color\([^)]+\);', r'static Color get \1 => AppBpColors.\1;', c)
    c = re.sub(r'static const Color (\w+) = accent;', r'static Color get \1 => AppBpColors.accent;', c)
    c = re.sub(r'static const Color (\w+) = primaryDark;', r'static Color get \1 => AppBpColors.primaryDark;', c)
    c = re.sub(r'static const Color (\w+) = primaryLight;', r'static Color get \1 => AppBpColors.primaryLight;', c)
    c = re.sub(r'static const Color (\w+) = primary;', r'static Color get \1 => AppBpColors.primary;', c)
    c = re.sub(r'static const Color (\w+) = Colors\.white;', r'static Color get \1 => AppBpColors.textPrimary;', c)
    c = re.sub(r'static const Color textSecondary = Color\([^)]+\);', r'static Color get textSecondary => AppBpColors.textSecondary;', c)
    c = re.sub(r'static const Color textHint = Color\([^)]+\);', r'static Color get textHint => AppBpColors.textHint;', c)
    c = re.sub(r'static const Color textOnDarkMuted = Color\([^)]+\);', r'static Color get textOnDarkMuted => AppBpColors.textOnDarkMuted;', c)

    # 5. Remove internal const where BpColors is used
    c = c.replace("const BorderSide(color: BpColors", "BorderSide(color: BpColors")
    c = c.replace("const WidgetStatePropertyAll(BpColors", "WidgetStatePropertyAll(BpColors")
    c = c.replace("const Icon(Icons.error_outline, color: BpColors", "Icon(Icons.error_outline, color: BpColors")
    c = c.replace("const Divider(color: BpColors", "Divider(color: BpColors")
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(c)

fix_bp(r"d:\Projets\BigPharma 1.2\client_app\lib\widgets\bp_theme.dart")
fix_bp(r"d:\Projets\BigPharma 1.2\epharma\lib\widgets\bp_theme.dart")

# Also fix receipt_ticket.dart
def fix_receipt(path):
    with open(path, 'r', encoding='utf-8') as f:
        c = f.read()
    c = re.sub(r'static const TextStyle (\w+) = const TextStyle\(', r'static TextStyle get \1 => TextStyle(', c)
    c = re.sub(r'static const TextStyle (\w+) = TextStyle\(', r'static TextStyle get \1 => TextStyle(', c)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(c)

fix_receipt(r"d:\Projets\BigPharma 1.2\epharma\lib\widgets\receipt_ticket.dart")

# Fix page_wrapper.dart
def fix_page(path):
    with open(path, 'r', encoding='utf-8') as f:
        c = f.read()
    c = c.replace("this.backgroundColor = BpColors.scaffold,", "this.backgroundColor,")
    c = c.replace("return Material(color: backgroundColor,", "return Material(color: backgroundColor ?? BpColors.scaffold,")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(c)

fix_page(r"d:\Projets\BigPharma 1.2\epharma\lib\page_wrapper.dart")
