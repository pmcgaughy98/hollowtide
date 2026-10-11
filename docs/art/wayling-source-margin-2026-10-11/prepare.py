from pathlib import Path
import json,shutil,hashlib
R=Path('C:/Users/pmcga/dev/hollowtide');W=Path(__file__).parent
SOURCE=Path('docs/creatures/arena-starters-2026-10-07/forms/wayling_arena_front_chosen.png')
W.mkdir(exist_ok=True)
shutil.copy2(R/SOURCE,W/'original.png')
files=list((R/'assets/sprites/arena/wayling').rglob('*'))
files += list((R/'assets/sprites/ui/dialogue').glob('wayling*'))
files += [R/'tools/ui/build_dialogue_portraits.py',R/'scripts/town/scene_kit.gd',R/'scripts/town/guild_crew.gd']
manifest={p.relative_to(R).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in files if p.is_file()}
(W/'protected.json').write_text(json.dumps(manifest,indent=2))
print('Saved chosen-front original and',len(manifest),'protected runtime/tool files.')
