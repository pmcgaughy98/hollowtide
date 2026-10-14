from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
W.mkdir(exist_ok=True);protected={}
for folder in ['scripts','scenes','data','dialogue','tools/debug']:
    for p in (R/folder).rglob('*'):
        if not p.is_file():continue
        rel=p.relative_to(R);protected[rel.as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
        dest=S/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
for rel in ['project.godot','default_bus_layout.tres']:
    protected[rel]=hashlib.sha256((R/rel).read_bytes()).hexdigest();shutil.copy2(R/rel,S/rel)
for rel in ['scripts/dungeon/dungeon.gd','scripts/dungeon/valley_painter.gd','scripts/town/team_state.gd','tools/debug/water_check.gd','tools/debug/save_check.gd']:
    dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dest)
(W/'protected.json').write_text(json.dumps(protected,indent=2));print('Saved current originals and',len(protected),'protected source files; refreshed staging source only.')
