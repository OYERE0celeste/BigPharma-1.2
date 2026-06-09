import re
from pathlib import Path
root = Path('lib')
patterns = [
    r'color: Colors\.black87',
    r'color: Colors\.black',
    r'color: Colors\.black54',
    r'color: Colors\.grey',
    r'backgroundColor: Colors\.white',
    r'fillColor: Colors\.white',
    r'backgroundColor: const Color\(0xFFF8FAFC\)',
    r'backgroundColor: const Color\(0xFFFEFDF8\)',
    r'borderSide: BorderSide\(color: Colors\.grey\[200\]!\)'
]
for p in sorted(root.rglob('*.dart')):
    lines = p.read_text(encoding='utf-8').splitlines()
    for i, line in enumerate(lines, 1):
        for patt in patterns:
            if re.search(patt, line):
                print(p, i, line.strip())
