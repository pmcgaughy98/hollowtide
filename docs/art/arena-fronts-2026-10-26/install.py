from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());manifest=json.loads((W/'manifest.json').read_text());files={p.relative_to(W/'prepared').as_posix():p for p in (W/'prepared').rglob('*') if p.is_file()}
for rel in ('scripts/town/board_scene.gd','export_presets.cfg'):assert sha(L/rel)==base[rel],rel+' changed, rebase first'
for item in manifest:assert sha(L/item['source'])==item['sha256'] and not (L/item['destination']).exists()
for rel,p in files.items():
 dest=L/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
(W/'installed-files.json').write_text(json.dumps({rel:sha(L/rel) for rel in files},indent=2));print('Installed16 fronts and two guarded integration files; original docs untouched.')
