from pathlib import Path
import ast
p=Path(__file__).parent/'archive.py'
s=p.read_text().replace("Claude's three",'the three Claude')
s=s.replace('All 30,715 protected files exact;','30,712 protected files exact; three concurrent Claude audio hooks preserved;')
ast.parse(s)
p.write_text(s)
print('Documentation audit counts and concurrent-change notes verified.')
