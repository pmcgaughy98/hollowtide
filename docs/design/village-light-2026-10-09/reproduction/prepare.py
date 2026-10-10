from pathlib import Path
import shutil,json,hashlib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project');P=Path('D:/dev/hollowtide-village-actors-20261009')
owned=['scripts/ui/village_menu_actor.gd','scripts/creature_opening.gd']
dependencies=['scripts/main_menu.gd','scripts/opening_flow.gd','scripts/main_menu_art_preview.gd','scripts/creature_prologue.gd','scripts/ui/hollowtide_wordmark.gd','scripts/arena/creature_finish.gd','scripts/arena/creature_finish.gdshader']
baseline={}
for r in owned+dependencies+['project.godot']:
    p=L/r;baseline[r]=hashlib.sha256(p.read_bytes()).hexdigest()
    if r in owned:
        out=W/'originals'/r;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,out)
    if r!='project.godot':shutil.copy2(p,C/r)
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
for name in ['run.py','input_check.gd','menu_animation_check.gd','encode_preview.py']:
    (W/name).write_text((P/name).read_text().replace('hollowtide-village-actors-20261009','hollowtide-village-light-20261009'))
print('Current menu sources inspected and backed up; cached art retained')
