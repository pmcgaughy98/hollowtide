from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
copied=[]
for p in (L/'assets/audio').rglob('*'):
    if p.is_file() and p.suffix!='.import':
        dst=C/p.relative_to(L)
        if not dst.exists() or p.read_bytes()!=dst.read_bytes():
            dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst);copied.append(p.relative_to(L).as_posix())
(W/'audio-dependency-sync.json').write_text(json.dumps(copied,indent=2))
p=W/'menu_check.gd'
t=p.read_text().replace('var menu: Node = load("res://scenes/creature_opening.tscn").instantiate()', 'verify("F5 main scene is the creature opening",ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/creature_opening.tscn")\n\tvar menu: Node = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()')
p.write_text(t)
# External baseline scripts make the identical pixel check reproducible on live.
p=W/'hall_ground_before.gd'
p.write_text((W/'originals/scripts/town/highbank_ground_painter.gd').read_text().replace('res://scripts/town/wayline_hall_painter.gd',W.as_posix()+'/hall_original_art.gd'))
p=W/'live_entrance_check.gd'
p.write_text((W/'entrance_check.gd').read_text().replace('res://tools/debug/hall_ground_before.gd',W.as_posix()+'/hall_ground_before.gd'))
print('Synced',len(copied),'audio dependencies; prepared 51 launch/menu checks and live pixel baseline')
