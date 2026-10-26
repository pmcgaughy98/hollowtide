from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text())
owned=['scripts/main_menu.gd','scripts/creature_opening.gd','scripts/soul_prologue.gd']
for p in owned:assert sha(L/p)==base[p],f'Owned file changed: {p}'
changes=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
(W/'concurrent-at-install.json').write_text(json.dumps(changes,indent=2))
for p in changes:
    if (L/p).is_file():
        d=W/'concurrent-at-install'/p;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,d)
installed={}
for p in owned:shutil.copy2(W/'prepared'/p,L/p);installed[p]=sha(L/p)
(W/'installed-files.json').write_text(json.dumps(installed,indent=2))
print('Installed three owned scripts only; concurrent files preserved:',changes)
