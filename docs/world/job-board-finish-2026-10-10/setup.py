from pathlib import Path
import hashlib,json,shutil
from PIL import Image
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline={}
for folder in ['scripts','scenes','assets','data','tools']:
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:baseline[p.relative_to(L).as_posix()]=sha(p)
for r in ['project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TOWN_FINISH_BRIEF_2026-10-10.md','docs/art/art-direction.md']:baseline[r]=sha(L/r)
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
for r in ['scripts/town/building_exteriors.gd','scripts/town/highbank_ground_painter.gd','scripts/town/hub_town.gd','scripts/town/town_layout.gd','scripts/town/growth_shrine_painter.gd','scripts/town/training_yard_painter.gd','docs/AI_COLLABORATION.md']:
 dest=W/'originals'/r;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,dest)
copied=0
for r,h in baseline.items():
 if r.startswith(('scripts/','scenes/','assets/','data/','tools/')) or r=='project.godot':
  dest=C/r
  if not dest.exists() or sha(dest)!=h:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,dest);copied+=1
for r in ['candidate/scripts/town','candidate/assets/sprites/world/job_board_2026_10_10','review','sources','prompts']:(W/r).mkdir(parents=True,exist_ok=True)
shutil.copy2('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-60275dd8-b17a-4a3e-941a-a6856ffee5f5.png',W/'sources/board_original.png')
im=Image.open(W/'sources/board_original.png').convert('RGBA');box=im.getbbox();im=im.crop(box)
scale=min(46/im.width,24/im.height);size=tuple(round(n*scale) for n in im.size);offset=((48-size[0])//2,24-size[1])
native=Image.new('RGBA',(48,24));native.paste(im.resize(size,Image.Resampling.NEAREST),offset);native.save(W/'candidate/assets/sprites/world/job_board_2026_10_10/board_native.png')
(W/'preparation.json').write_text(json.dumps({'crop':box,'scaled_size':size,'offset':offset,'canvas':[48,24],'method':'transparent padding crop, uniform nearest resize only'},indent=2))
for r in ['scripts/town/building_exteriors.gd','scripts/town/highbank_ground_painter.gd']:shutil.copy2(W/'originals'/r,W/'candidate'/r)
print('Baseline',len(baseline),'files; review sync',copied,'files; native prep',size,offset)
