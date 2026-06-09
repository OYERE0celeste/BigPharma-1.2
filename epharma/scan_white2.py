from pathlib import Path
root = Path('lib')
print('decoration BoxDecoration color white:')
for p in sorted(root.rglob('*.dart')):
    lines = p.read_text(encoding='utf-8').splitlines()
    for i,line in enumerate(lines,1):
        if 'decoration:' in line and 'BoxDecoration' in line and 'Colors.white' in ''.join(lines[i:i+5]):
            print(p, i)
print('backgroundColor white:')
for p in sorted(root.rglob('*.dart')):
    lines = p.read_text(encoding='utf-8').splitlines()
    for i,line in enumerate(lines,1):
        if 'backgroundColor: Colors.white' in line:
            print(p, i)
print('fillColor white:')
for p in sorted(root.rglob('*.dart')):
    lines = p.read_text(encoding='utf-8').splitlines()
    for i,line in enumerate(lines,1):
        if 'fillColor: Colors.white' in line:
            print(p, i)
