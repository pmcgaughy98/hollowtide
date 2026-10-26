from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
data=json.loads((W/'installed-files.json').read_text())
for rel in ('scripts/main_menu.gd','scripts/ui/title_settings.gd'):
    assert sha(L/rel)==data[rel],rel
    p=W/'prepared'/rel;raw=p.read_bytes().replace(b'\r\n',b'\n')
    if b'\r\n' in (L/rel).read_bytes():raw=raw.replace(b'\n',b'\r\n')
    p.write_bytes(raw);shutil.copy2(p,L/rel);data[rel]=sha(L/rel)
(W/'installed-files.json').write_text(json.dumps(data,indent=2))
print('Retained the C1 safe writer for all title-owned keys; existing shared game-preference path remains unchanged.')
