from pathlib import Path
import re
root = Path('lib')
pattern = re.compile(r'color:\s*Colors\.white|backgroundColor:\s*Colors\.white|fillColor:\s*Colors\.white')
for p in sorted(root.rglob('*.dart')):
    lines = p.read_text(encoding='utf-8').splitlines()
    for i, line in enumerate(lines,1):
        if 'BoxDecoration' in line or 'backgroundColor:' in line or 'fillColor:' in line:
            if pattern.search(line):
                print(f'{p}:{i}: {line.strip()}')
            elif i+1 <= len(lines) and pattern.search(lines[i]):
                print(f'{p}:{i+1}: {lines[i].strip()}')
