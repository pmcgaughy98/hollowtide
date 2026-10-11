from pathlib import Path
import difflib,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
baseline=json.loads((W/'baseline.json').read_text())
for r in ['scripts/arena/creature_finish.gd','scripts/town/board_scene.gd','scripts/town/hub_town.gd','scripts/ui/ui_style.gd','scripts/ui/crew_portrait_canvas.gd']:
    if hashlib.sha256((L/r).read_bytes()).hexdigest()!=baseline[r]:
        print(''.join(difflib.unified_diff((W/'originals'/r).read_text().splitlines(True),(L/r).read_text().splitlines(True),fromfile='snapshot/'+r,tofile='live/'+r)))
