import os
import re

dirs = [
    r"d:\Projets\BigPharma 1.2\client_app\lib",
    r"d:\Projets\BigPharma 1.2\epharma\lib"
]

patterns = [
    # Match `const WidgetName( ... BpColors ...)`
    (re.compile(r'const\s+([A-Z][A-Za-z0-9_]*\s*\([^{};]*?BpColors)', re.DOTALL), r'\1'),
    # Match `const [ ... BpColors ... ]`
    (re.compile(r'const\s+(\[[^{};]*?BpColors)', re.DOTALL), r'\1'),
    # Match `const WidgetStatePropertyAll(BpColors...`
    (re.compile(r'const\s+(WidgetStatePropertyAll\s*\([^{};]*?BpColors)', re.DOTALL), r'\1'),
]

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # We might need to run it multiple times if there are nested consts, but usually one is enough.
    for i in range(3):
        for pattern, replacement in patterns:
            content = pattern.sub(replacement, content)
            
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for d in dirs:
    for root, _, files in os.walk(d):
        for file in files:
            if file.endswith(".dart"):
                process_file(os.path.join(root, file))
