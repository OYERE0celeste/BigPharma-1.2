from pathlib import Path
import re
root = Path('lib')
pattern = re.compile(r'color:\s*Color\(0xFF[0-9A-Fa-f]{6}\)')
for p in sorted(root.rglob('*.dart')):
    text = p.read_text(encoding='utf-8')
    for m in pattern.finditer(text):
        line = text[:m.start()].count('\n') + 1
        print(f'{p}:{line}:{m.group(0)}')
