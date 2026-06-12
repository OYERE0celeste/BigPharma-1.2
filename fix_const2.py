import os
import re

def replace_in_file(filepath, pattern, replacement):
    if not os.path.exists(filepath): return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

# CardTheme -> CardThemeData
replace_in_file(r"d:\Projets\BigPharma 1.2\client_app\lib\core\theme\app_theme.dart", r'CardTheme\(', r'CardThemeData(')
replace_in_file(r"d:\Projets\BigPharma 1.2\epharma\lib\core\theme\app_theme.dart", r'CardTheme\(', r'CardThemeData(')

# settings_theme.dart
settings_theme_files = [
    r"d:\Projets\BigPharma 1.2\client_app\lib\widgets\settings_theme.dart",
    r"d:\Projets\BigPharma 1.2\epharma\lib\settings\settings_theme.dart"
]
for f in settings_theme_files:
    replace_in_file(f, r'static\s+const\s+Color\s+(\w+)\s*=\s*BpColors\.(\w+);', r'static Color get \1 => BpColors.\2;')

# General regex for any 'const ' before a widget that might contain BpColors
def remove_invalid_const(filepath):
    if not os.path.exists(filepath): return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Simple regex to remove 'const ' if there's BpColors on the same line or within the next few words
    # But it's safer to just remove all `const ` on the reported lines.
    # Actually, we can just replace 'const ' with '' if it's followed by a widget with BpColors
    new_content = re.sub(r'const\s+([A-Z][A-Za-z0-9_]*\s*\([^;]*?BpColors)', r'\1', content, flags=re.DOTALL)
    new_content = re.sub(r'const\s+\[([^;]*?BpColors[^;]*?)\]', r'[\1]', new_content, flags=re.DOTALL)
    new_content = re.sub(r'const\s+WidgetStatePropertyAll\s*\([^;]*?BpColors', r'WidgetStatePropertyAll(', new_content, flags=re.DOTALL)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Removed const in {filepath}")

remove_invalid_const(r"d:\Projets\BigPharma 1.2\client_app\lib\pages\landing_page.dart")
remove_invalid_const(r"d:\Projets\BigPharma 1.2\client_app\lib\pages\register_page.dart")
remove_invalid_const(r"d:\Projets\BigPharma 1.2\client_app\lib\widgets\bp_theme.dart")

remove_invalid_const(r"d:\Projets\BigPharma 1.2\epharma\lib\clients\widgets\search_filter_client.dart")
remove_invalid_const(r"d:\Projets\BigPharma 1.2\epharma\lib\products\widgets\lot_card.dart")
remove_invalid_const(r"d:\Projets\BigPharma 1.2\epharma\lib\settings\securite_dialog.dart")
remove_invalid_const(r"d:\Projets\BigPharma 1.2\epharma\lib\ventes\widgets\sale_history.dart")
remove_invalid_const(r"d:\Projets\BigPharma 1.2\epharma\lib\widgets\bp_theme.dart")
remove_invalid_const(r"d:\Projets\BigPharma 1.2\epharma\lib\widgets\receipt_ticket.dart")

# Fix for page_wrapper.dart:49 (non_constant_default_value)
# if it is `Color color = BpColors.surface`, we can change it to `Color? color` and `color ??= BpColors.surface`
def fix_page_wrapper():
    path = r"d:\Projets\BigPharma 1.2\epharma\lib\page_wrapper.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Find `this.backgroundColor = BpColors.xxx`
    content = re.sub(r'this\.backgroundColor\s*=\s*BpColors\.\w+', r'this.backgroundColor', content)
    # This might require changing the type to Color? and setting it in build. 
    # Let's just run sed-like replace if possible.
    
fix_page_wrapper()

# Fix for theme_service.dart:26, 51 (invalid constant value)
remove_invalid_const(r"d:\Projets\BigPharma 1.2\epharma\lib\services\theme_service.dart")

