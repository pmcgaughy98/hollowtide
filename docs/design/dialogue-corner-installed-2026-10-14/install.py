from pathlib import Path
import json,hashlib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
assert all(sha(R/r)==h for r,h in protected.items()),'Concurrent change; stop.'
p=R/'scripts/ui/ui_style.gd';raw=p.read_bytes();assert raw==(W/'original-ui_style.gd').read_bytes()
new=raw.replace(b'const PORTRAIT_INSET := 150.0',b'const PORTRAIT_INSET := 162.0').replace(b'box.position + Vector2(30, -34)',b'box.position + Vector2(42, -34)')
assert new!=raw and new.decode('utf-8').replace('\r\n','\n')==(W/'candidate-ui_style.gd').read_text(encoding='utf-8')
p.write_bytes(new)
print('Installed exactly two shared dialogue values; original line endings retained.')
