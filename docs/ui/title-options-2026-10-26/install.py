from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());owned=['scripts/main_menu.gd','scripts/creature_opening.gd']
for p in owned:assert sha(L/p)==base[p],p
assert not (L/'scripts/ui/title_settings.gd').exists()
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
(W/'concurrent-at-install.json').write_text(json.dumps(changed,indent=2))
for p in changed:
    if (L/p).is_file():
        dest=W/'concurrent-at-install'/p;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,dest)
out={}
for p in owned+['scripts/ui/title_settings.gd']:
    shutil.copy2(W/'prepared'/p,L/p);out[p]=sha(L/p)
(W/'installed-files.json').write_text(json.dumps(out,indent=2))
print('Installed only title-owned files; preserved concurrent changes:',changed)
