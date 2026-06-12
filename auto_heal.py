import subprocess
import os
import re

def fix_repo(base_dir):
    print(f"Analyzing {base_dir}...")
    result = subprocess.run(
        ["flutter", "analyze"],
        cwd=base_dir,
        capture_output=True,
        text=True,
        shell=True
    )
    output = result.stdout + "\n" + result.stderr
    
    lines = output.split('\n')
    fixes = 0
    for line in lines:
        line = line.strip()
        if "error -" in line and ("invalid_constant" in line or "const_initialized_with_non_constant_value" in line or "missing_default_value_for_parameter" in line):
            parts = line.split('-')
            # The format is typically: error - Invalid constant value - lib\widgets\bp_theme.dart:182:27 - invalid_constant
            # parts: ['error ', ' Invalid constant value ', ' lib\\widgets\\bp_theme.dart:182:27 ', ' invalid_constant']
            if len(parts) >= 4:
                file_info = parts[-2].strip() 
                if ':' in file_info:
                    file_parts = file_info.split(':')
                    rel_path = file_parts[0].strip()
                    line_num = int(file_parts[1])
                    
                    filepath = os.path.join(base_dir, rel_path)
                    
                    if not os.path.exists(filepath): continue
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content_lines = f.readlines()
                    
                    if line_num <= len(content_lines):
                        target_line = content_lines[line_num - 1]
                        
                        if "settings_theme.dart" in filepath and "Color" in target_line:
                            new_line = re.sub(r'static\s+const\s+Color\s+(\w+)\s*=\s*BpColors\.(\w+);', r'static Color get \1 => BpColors.\2;', target_line)
                        elif "page_wrapper.dart" in filepath and "missing_default_value_for_parameter" in line:
                            new_line = target_line.replace('final Color backgroundColor;', 'final Color? backgroundColor;')
                        else:
                            new_line = re.sub(r'\bconst\s+', '', target_line)
                        
                        if new_line != target_line:
                            content_lines[line_num - 1] = new_line
                            with open(filepath, 'w', encoding='utf-8') as f:
                                f.writelines(content_lines)
                            print(f"Fixed {filepath}:{line_num}")
                            fixes += 1
    return fixes

# Run it in a loop until no more fixes
for d in [r"d:\Projets\BigPharma 1.2\client_app", r"d:\Projets\BigPharma 1.2\epharma"]:
    for i in range(5):
        print(f"Iteration {i+1} for {d}")
        f = fix_repo(d)
        if f == 0:
            print("No more fixes needed.")
            break
