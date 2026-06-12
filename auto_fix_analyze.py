import os
import re

def fix_errors(machine_file):
    if not os.path.exists(machine_file): return
    # Try utf-16 first, then utf-8
    try:
        with open(machine_file, 'r', encoding='utf-16') as f:
            lines = f.readlines()
    except UnicodeDecodeError:
        with open(machine_file, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
        
    for line in lines:
        parts = line.strip().split('|')
        if len(parts) >= 8:
            err_code = parts[2]
            filepath = parts[3]
            line_num = int(parts[4])
            
            if err_code in ["invalid_constant", "const_initialized_with_non_constant_value", "invalid_annotation", "const_with_non_constant_argument", "list_element_type_not_assignable"]:
                if not os.path.exists(filepath): continue
                with open(filepath, 'r', encoding='utf-8') as f:
                    content_lines = f.readlines()
                
                if line_num <= len(content_lines):
                    target_line = content_lines[line_num - 1]
                    
                    if "settings_theme.dart" in filepath and "Color" in target_line:
                        new_line = re.sub(r'static\s+const\s+Color\s+(\w+)\s*=\s*BpColors\.(\w+);', r'static Color get \1 => BpColors.\2;', target_line)
                    else:
                        new_line = re.sub(r'\bconst\s+', '', target_line)
                    
                    if new_line != target_line:
                        content_lines[line_num - 1] = new_line
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.writelines(content_lines)
                        print(f"Fixed {filepath}:{line_num}")

fix_errors(r"d:\Projets\BigPharma 1.2\client_app\errors_client.txt")
fix_errors(r"d:\Projets\BigPharma 1.2\epharma\errors_epharma.txt")
