from pathlib import Path
import re
root = Path('lib')
for p in sorted(root.rglob('*.dart')):
    text = p.read_text(encoding='utf-8')
    for m in re.finditer(r'(^.*color: Colors\.white.*$)|(^.*backgroundColor: Colors\.white.*$)|(^.*fillColor: Colors\.white.*$)', text, re.MULTILINE):
        print(f'{p}:{text[:m.start()].count("\n") + 1}:{m.group(0).strip()}')
