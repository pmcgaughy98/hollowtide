from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project');P=L/'docs/world/world-selout-2026-10-11'
owned=['scripts/town/highbank_painter.gd','scripts/town/hub_town.gd']
before=json.loads((W/'before-hashes.json').read_text())
for rel in owned:assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==before[rel],'Concurrent edit; rebase '+rel
assert not (L/'scripts/town/world_finish.gd').exists(),'Inspect existing helper first'
P.mkdir(parents=True,exist_ok=True);shutil.copytree(W/'originals',P/'originals',dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.gd','.py','.png','.json','.diff','.log']:shutil.copy2(p,P/p.name)
manifest={}
for rel in owned+['scripts/town/world_finish.gd']:
    shutil.copy2(C/rel,L/rel);manifest[rel]=hashlib.sha256((L/rel).read_bytes()).hexdigest()
(P/'installed-hashes.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('Installed two guarded presentation hooks and new world_finish helper. Original PNGs untouched. Archive:',P)
