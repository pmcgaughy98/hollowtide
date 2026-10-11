from pathlib import Path
from PIL import Image
import shutil,hashlib,json
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
owned=['scripts/town/room_painter.gd','scripts/town/town_room.gd']
before={}
for rel in owned:
    dst=W/'latest-before-integration'/rel;dst.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(L/rel,dst);before[rel]=hashlib.sha256((L/rel).read_bytes()).hexdigest()
(W/'install-before-hashes.json').write_text(json.dumps(before,indent=2),encoding='utf-8')
for folder in ['scripts','scenes']:shutil.copytree(L/folder,C/folder,dirs_exist_ok=True)
for name in ['hall_floors_check.gd','town_room_check.gd','guild_scene_check.gd']:
    t=(L/'tools/debug'/name).read_text(encoding='utf-8')
    if 'const OUT :=' in t:
        a=t.index('const OUT :=');b=t.index('\n',a)
        t=t[:a]+'const OUT := "D:/dev/hollowtide-hall-floors-finish-20261011/"'+t[b:]
    t=t.replace('\tquit(', '\tfor child in root.get_children(): child.queue_free()\n\tload("res://scripts/audio/music.gd")._inst = null\n\tawait _frames(16)\n\tquit(')
    (W/name.replace('_check','')).write_text(t,encoding='utf-8')
g=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-7a0bcb96-4e72-403c-bc8b-95acf884d848.png')
shutil.copy2(g,W/'generation'/g.name)
im=Image.open(g).convert('RGBA');bounds=im.getchannel('A').point(lambda a:255 if a>127 else 0).getbbox()
im.crop(bounds).resize((16,48),Image.Resampling.NEAREST).save(C/'assets/sprites/world/hall_floors_2026_10_11/pegs.png')
manifest=json.loads((W/'native-preparation.json').read_text())
manifest['pegs']={'source':g.name,'alpha_bounds':bounds,'native':[16,48]}
(W/'native-preparation.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('Latest Claude four-room code staged, guarded originals saved; empty peg crop prepared.')
