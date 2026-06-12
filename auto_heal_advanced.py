import os
import re
import subprocess

def fix_repo(base_dir):
    print(f"Analyzing {base_dir}...")
    result = subprocess.run(
        ["flutter", "analyze", "--machine"],
        cwd=base_dir,
        capture_output=True,
        text=True,
        shell=True
    )
    # output of machine is entirely on stdout usually, but let's grab stderr too
    output = result.stdout + "\n" + result.stderr
    lines = output.split('\n')
    
    fixes = 0
    for line in lines:
        line = line.strip()
        if "invalid_constant" in line or "const_initialized_with_non_constant_value" in line:
            parts = line.split('|')
            if len(parts) >= 8:
                filepath = parts[3]
                line_num = int(parts[4])
                
                if not os.path.exists(filepath): continue
                with open(filepath, 'r', encoding='utf-8') as f:
                    content_lines = f.readlines()
                
                # Search backwards up to 5 lines to find the offending 'const'
                for i in range(line_num - 1, max(-1, line_num - 6), -1):
                    target_line = content_lines[i]
                    if re.search(r'\bconst\s+', target_line):
                        new_line = re.sub(r'\bconst\s+', '', target_line, count=1) # only remove the last const? Or all? Let's do all.
                        new_line = re.sub(r'\bconst\s+', '', target_line)
                        if new_line != target_line:
                            content_lines[i] = new_line
                            with open(filepath, 'w', encoding='utf-8') as f:
                                f.writelines(content_lines)
                            print(f"Fixed {filepath}:{i+1} (error reported at {line_num})")
                            fixes += 1
                            break
    return fixes

for d in [r"d:\Projets\BigPharma 1.2\epharma", r"d:\Projets\BigPharma 1.2\client_app"]:
    for i in range(3):
        print(f"Iteration {i+1} for {d}")
        f = fix_repo(d)
        if f == 0:
            print("No more fixes needed.")
            break
