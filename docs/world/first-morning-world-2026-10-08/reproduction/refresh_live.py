from pathlib import Path
import hashlib,json,shutil
root=Path(__file__).parent
live=Path('C:/Users/pmcga/dev/hollowtide')
stage=root/'project'
owned=['scripts/world_journey.gd','scripts/world_area.gd','scripts/area_landscape.gd','scripts/opening_flow.gd']
new=['scripts/courier_partner_story.gd','scripts/world_atlas.gd','scripts/hometown_commons.gd','tools/debug/first_morning_check.gd','tools/debug/world_refinement_check.gd']
baseline=json.loads((root/'baseline.json').read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for name in owned: assert sha(live/name)==baseline[name], 'Owned file changed: '+name
for folder in ['assets','data','scripts','scenes','tools']:
    for p in (live/folder).rglob('*'):
        if not p.is_file() or '__pycache__' in p.parts: continue
        relative=p.relative_to(live)
        if relative.as_posix() in owned+new: continue
        dest=stage/relative
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(p,dest)
protected={}
for folder in ['assets/sprites/arena','assets/audio/sfx/listener','assets/audio/sfx/canvaswing','data/creatures','scripts/arena']:
    if not (live/folder).exists(): continue
    for p in (live/folder).rglob('*'):
        if p.is_file(): protected[p.relative_to(live).as_posix()]=sha(p)
for name in ['project.godot','scripts/player_party.gd','scripts/first_route_prototype.gd','scripts/battle_screen.gd','scripts/main_menu.gd','scripts/main_menu_art_preview.gd','tools/arena/build_small.py','tools/arena/slice_rotations.py']:
    protected[name]=sha(live/name)
(root/'resumed-live-guards.json').write_text(json.dumps(protected,indent=2))
print('Refreshed current assets, creature data and other code; guarded',len(protected),'files')
