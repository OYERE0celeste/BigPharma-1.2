import os

def simple_replace(path):
    with open(path, 'r', encoding='utf-8') as f:
        c = f.read()
    
    # 1. Import
    c = c.replace("import 'brand_title.dart';", "import '../core/theme/theme_colors.dart';\nimport 'brand_title.dart';")
    
    # 2. colorScheme
    c = c.replace("const colorScheme = ColorScheme.dark(", "final colorScheme = ColorScheme.dark(")
    
    # 3. TextStyles to getters
    c = c.replace("static const TextStyle ", "static TextStyle get ")
    c = c.replace(" = TextStyle(", " => TextStyle(")
    c = c.replace(" = const TextStyle(", " => const TextStyle(")
    
    # Remove const where BpColors might be used
    c = c.replace("const TextStyle(", "TextStyle(")
    c = c.replace("const BorderSide(", "BorderSide(")
    c = c.replace("const WidgetStatePropertyAll(", "WidgetStatePropertyAll(")
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(c)

simple_replace(r"d:\Projets\BigPharma 1.2\client_app\lib\widgets\bp_theme.dart")
simple_replace(r"d:\Projets\BigPharma 1.2\epharma\lib\widgets\bp_theme.dart")
