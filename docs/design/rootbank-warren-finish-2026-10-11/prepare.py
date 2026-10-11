from pathlib import Path
import shutil, hashlib, json
W=Path(__file__).parent
R=Path('C:/Users/pmcga/dev/hollowtide')
S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
records={}
for folder in ['scripts','scenes','data','dialogue','tools/debug']:
    for p in (R/folder).rglob('*'):
        if not p.is_file(): continue
        rel=p.relative_to(R)
        records[rel.as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
        dest=S/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
for name in ['riverbank_painter.gd','dungeon.gd','crew_scene.gd','dungeon_finish.gd','ruin_painter.gd','valley_painter.gd','dungeon_tile_art.gd']:
    dest=W/'originals'/name;dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(R/'scripts/dungeon'/name,dest)
(W/'protected.json').write_text(json.dumps(records,indent=2))
old=W/'before'
if old.exists():old.rename(W/'before-stale-atlas')
print('Refreshed current source; archived superseded atlas captures separately.')
