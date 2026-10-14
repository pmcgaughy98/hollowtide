from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
W.mkdir(exist_ok=True)
refs={'hall-low.png':'docs/world/hall-fixtures-finish-2026-10-11/review/after/hall_low_room.png','hall-chamber.png':'docs/world/hall-floors-finish-2026-10-11/finished_chamber.png'}
for name,rel in refs.items():
    dest=W/'references'/name;dest.parent.mkdir(exist_ok=True);shutil.copy2(R/rel,dest)
protected={}
for folder in ['scripts','scenes','data','dialogue']:
    for p in (R/folder).rglob('*'):
        if p.is_file():protected[p.relative_to(R).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
for rel in ['project.godot','default_bus_layout.tres','assets/sprites/ui/item/parcel.png','assets/sprites/world/rising_water_2026_10_14/ripples.png','assets/sprites/world/rising_water_2026_10_14/shoreline.png']:
    protected[rel]=hashlib.sha256((R/rel).read_bytes()).hexdigest()
(W/'protected.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
for rel in ['scripts/town/storage.gd','scripts/town/hub_town.gd','scripts/town/town_room.gd','scripts/art/selout.gd','scripts/arena/sel_out.gdshaderinc','scripts/town/building_selout.gdshader']:
    p=R/rel
    if p.exists():
        dest=W/'reference-code'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
print('Saved Hall style references and',len(protected),'protected source/current-finish hashes.')
