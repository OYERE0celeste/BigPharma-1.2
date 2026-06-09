import re
from pathlib import Path
root = Path(r'd:\Projets\BigPharma 1.2\epharma\lib')
patterns = [
    r'color:\s*Colors\.white',
    r'backgroundColor:\s*Colors\.white',
    r'fillColor:\s*Colors\.white',
    r'color:\s*Colors\.black87',
    r'color:\s*Colors\.black',
    r'color:\s*Colors\.black54',
    r'color:\s*Colors\.grey',
    r'color:\s*Colors\.grey\[.*?\]',
    r'borderSide:\s*BorderSide\(color:\s*Colors\.grey.*?\)',
    r'backgroundColor:\s*const Color\(0xFFF[0-9A-Fa-f]{6}\)',
    r'color:\s*const Color\(0xFFF[0-9A-Fa-f]{6}\)'
]
results = []
for p in root.rglob('*.dart'):
    text = p.read_text(encoding='utf-8')
    for patt in patterns:
        for m in re.finditer(patt, text):
            results.append((p.relative_to(root), patt, m.group(0)))
print('total', len(results))
counts = {}
for _, patt, _ in results:
    counts[patt] = counts.get(patt, 0) + 1
for patt, c in counts.items():
    print(c, patt)
print('\nSample first 50:')
for item in results[:50]:
    print(item)
