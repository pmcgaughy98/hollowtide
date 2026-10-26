from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text(encoding='utf-8'))
rel='scripts/main_menu.gd';assert sha(L/rel)==base[rel], 'Owned menu changed concurrently; rebase before installing'
changes=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
(W/'concurrent-at-install.json').write_text(json.dumps(changes,indent=2),encoding='utf-8')
for p in changes:
    if (L/p).is_file():
        d=W/'concurrent-at-install'/p;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,d)
prepared=W/'prepared'/rel
old=(L/rel).read_bytes();new=prepared.read_bytes().replace(b'\r\n',b'\n')
if b'\r\n' in old:new=new.replace(b'\n',b'\r\n')
prepared.write_bytes(new)
shutil.copy2(prepared,L/rel)
(W/'installed-files.json').write_text(json.dumps({rel:sha(L/rel)},indent=2),encoding='utf-8')
print('Installed only main_menu.gd; preserved concurrent files:',changes)
