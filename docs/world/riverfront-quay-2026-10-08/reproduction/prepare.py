from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
owned=['scripts/area_landscape.gd','scripts/world_area.gd']
baseline={}
for folder in ['assets','scripts','scenes','data','tools']:
    for p in (L/folder).rglob('*'):
        if not p.is_file() or '__pycache__' in p.parts:continue
        rel=p.relative_to(L);dst=C/rel
        if not dst.exists() or sha(p)!=sha(dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
        if p.suffix not in ['.import','.uid','.pyc']:baseline[rel.as_posix()]=sha(p)
baseline['project.godot']=sha(L/'project.godot')
for rel in owned:
    dst=W/'originals'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dst)
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
print('Refreshed isolated project; guarded',len(baseline),'existing files')
