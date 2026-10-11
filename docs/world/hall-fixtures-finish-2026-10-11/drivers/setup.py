from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'baseline.json').exists()
protected={}
for folder in ['scripts','scenes','assets/sprites/world','assets/sprites/arena','dialogue','resources','data']:
    root=C/folder
    if root.exists():
        for p in root.rglob('*'):
            if p.is_file():protected[p.relative_to(C).as_posix()]=sha(p)
protected['project.godot']=sha(C/'project.godot')
for rel in ['scripts/town/room_painter.gd','scripts/town/hall_floors_art.gd','scripts/town/town_room.gd']:
    dst=W/'originals'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/rel,dst)
    dst=W/'prepared'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/rel,dst)
(W/'baseline.json').write_text(json.dumps(protected,indent=2))
shutil.copy2(Path('D:/dev/hollowtide-crew-idles-20261011/run.py'),W/'run.py')
print('Fresh source snapshots and',len(protected),'protected hashes saved.')
