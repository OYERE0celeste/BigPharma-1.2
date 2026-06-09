from pathlib import Path
root = Path('lib')
for p in sorted(root.rglob('*.dart')):
    lines = p.read_text(encoding='utf-8').splitlines()
    for i, line in enumerate(lines, 1):
        if any(token in line for token in [
            'color: Colors.white',
            'backgroundColor: Colors.white',
            'fillColor: Colors.white',
            'color: Colors.white70',
            'color: Colors.white54',
            'color: Colors.white24',
            'Border.all(color: Colors.white'
        ]):
            print(f'{p}:{i}:{line.strip()}')
