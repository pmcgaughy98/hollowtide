from pathlib import Path
import hashlib,json,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
NAMES=['grubbit','stillwade','wickglow','muskin','slipjaw','rinsepaw']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected.json').exists(),'Preserve fresh originals.'
protected={}
for folder in ['scripts','scenes','assets/sprites/ui','assets/sprites/world','tools/ui','tools/arena']:
    for p in (C/folder).rglob('*'):
        if p.is_file():protected[p.relative_to(C).as_posix()]=sha(p)
for name in NAMES:
    for p in (C/f'assets/sprites/arena/{name}').rglob('*'):
        if p.is_file():protected[p.relative_to(C).as_posix()]=sha(p)
for rel in ['project.godot',*[f'docs/creatures/arena-starters-2026-10-07/forms/{n}_arena_front_chosen.png' for n in NAMES]]:
    protected[rel]=sha(C/rel)
for rel in [*[f'docs/creatures/arena-starters-2026-10-07/forms/{n}_arena_front_chosen.png' for n in NAMES],*[f'assets/sprites/arena/{n}/s.png' for n in NAMES],*[f'assets/sprites/ui/dialogue/{n}.png' for n in ['wayling','swaphoard','pouchbill','inkhoot','starward','gruntle']], 'tools/ui/build_dialogue_portraits.py','tools/ui/outline_portrait.py','tools/arena/recolor_creature.py','tools/arena/downscale.py','scripts/ui/ui_style.gd']:
    dst=W/'originals'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/rel,dst)
(W/'protected.json').write_text(json.dumps(protected,indent=2))
sheet=Image.new('RGB',(3*480,2*490),'#36392e');d=ImageDraw.Draw(sheet)
meta=[]
for k,n in enumerate(NAMES):
    p=C/f'docs/creatures/arena-starters-2026-10-07/forms/{n}_arena_front_chosen.png'
    im=Image.open(p).convert('RGBA');x=(k%3)*480;y=(k//3)*490
    d.text((x+12,y+8),f'{n} {im.size} bbox={im.getbbox()}',fill='#fff4e8')
    big=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST)
    sheet.paste(big,(x+25,y+40),big)
    for px in range(0,im.width+1,10):
        d.line((x+25+px*3,y+40,x+25+px*3,y+40+im.height*3),fill='#6d6560',width=1)
        d.text((x+25+px*3,y+24),str(px),fill='#fff4e8')
    for py in range(0,im.height+1,10):
        d.line((x+25,y+40+py*3,x+25+im.width*3,y+40+py*3),fill='#6d6560',width=1)
        d.text((x+2,y+40+py*3),str(py),fill='#fff4e8')
    meta.append({'form':n,'size':im.size,'bbox':im.getbbox(),'source_sha256':sha(p)})
sheet.save(W/'source_grid.png')
ref=Image.new('RGB',(6*150,170),'#242923');d=ImageDraw.Draw(ref)
for k,n in enumerate(['wayling','swaphoard','pouchbill','inkhoot','starward','gruntle']):
    im=Image.open(C/f'assets/sprites/ui/dialogue/{n}.png').convert('RGBA');bg=Image.new('RGBA',im.size,'#8fd0e4');bg.alpha_composite(im)
    ref.paste(bg.resize((120,120),Image.Resampling.NEAREST),(k*150+10,10));d.text((k*150+10,140),n,fill='#fff4e8')
ref.save(W/'reference_portraits.png')
(W/'source_meta.json').write_text(json.dumps(meta,indent=2))
shutil.copy2(Path('D:/dev/hollowtide-hall-fixtures-20261011/run.py'),W/'run.py')
print(json.dumps(meta,indent=2));print('Protected',len(protected),'existing files; current sources and reference frames saved.')
