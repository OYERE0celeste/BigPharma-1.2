from pathlib import Path
import re
files = [
    'lib/widgets/bp_theme.dart',
    'lib/widgets/notification_panel.dart',
    'lib/widgets/app_notification.dart',
    'lib/widgets/receipt_ticket.dart',
    'lib/commandes/orders_page.dart',
    'lib/services/theme_service.dart',
    'lib/page_wrapper.dart'
]
pattern = re.compile(r'backgroundColor:\s*Colors\.white|fillColor:\s*Colors\.white|color:\s*const Color\(0xFFFEFDF8\)|color:\s*const Color\(0xFFE6DCC9\)|color:\s*Colors\.white|color:\s*Colors\.black\.withOpacity\(0\.\d+\)')
for f in files:
    p = Path(f)
    if p.exists():
        for i, line in enumerate(p.read_text(encoding='utf-8').splitlines(), 1):
            if pattern.search(line):
                print(f'{f}:{i}: {line.strip()}')
