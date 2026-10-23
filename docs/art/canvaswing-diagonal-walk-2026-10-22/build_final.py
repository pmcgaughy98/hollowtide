from pathlib import Path
import subprocess,sys,json,shutil,hashlib
import numpy as np
from PIL import Image,ImageOps,ImageDraw
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'project';ART='assets/sprites/arena/canvaswing';commands=[]
for tool,args in [('build_dungeon_set.py',['canvaswing']),('build_dungeon_set.py',['canvaswing','--set=town','--scale=1.5']),('build_small.py',['canvaswing'])]:
    cmd=[sys.executable,str(P/'tools/arena'/tool),*args];p=subprocess.run(cmd,cwd=P,capture_output=True,text=True,encoding='utf-8',timeout=90);assert p.returncode==0,p.stderr
    commands.append({'command':cmd,'cwd':str(P),'stdout':p.stdout,'stderr':p.stderr,'exit':p.returncode});print(p.stdout,flush=True)
selected=[];facts=[]
for folder in ['dungeon','town','small']:
    colours=[]
    for i in range(3):
        a=np.array(Image.open(R/ART/folder/f'walk_se_f{i}.png').convert('RGBA'));colours.extend(map(tuple,a[a[...,3]>0][:,:3]))
    palette=np.array(sorted(set(colours))).astype(int)
    for facing in ['se','sw']:
        for i in range(3,8):
            rel=f'{ART}/{folder}/walk_{facing}_f{i}.png';p=P/rel;a=np.array(Image.open(p).convert('RGBA'));m=a[...,3]>0;rgb=a[m,:3].astype(int);dist=(rgb[:,None,:]-palette[None,:,:])**2;score=dist[:,:,0]*2+dist[:,:,1]*4+dist[:,:,2]*3
            raw=W/'raw-builder-output'/rel;raw.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,raw)
            a[m,:3]=palette[score.argmin(axis=1)];Image.fromarray(a).save(p);im=Image.open(p).convert('RGBA');b=im.getbbox();pixels=int(m.sum());colors=len(set(map(tuple,a[m,:3])));assert 0<b[0]<b[2]<im.width and 0<b[1]<b[3]<im.height,(rel,b);assert 15<=colors<=32,(rel,colors)
            good_areas=[]
            for k in range(3):good_areas.append(sum(1 for v in Image.open(R/ART/folder/f'walk_se_f{k}.png').convert('RGBA').getdata() if v[3]))
            assert min(good_areas)*.75<=pixels<=max(good_areas)*1.4,(rel,pixels,good_areas)
            selected.append(rel);facts.append({'path':rel,'bbox':b,'size':im.size,'pixels':pixels,'colors':colors,'palette_size':len(palette)})
    for i in range(3,8):
        se=np.array(Image.open(P/ART/folder/f'walk_se_f{i}.png').convert('RGBA'));sw=np.array(Image.open(P/ART/folder/f'walk_sw_f{i}.png').convert('RGBA'));assert np.array_equal(se[:,::-1],sw)
# Whole sets were regenerated with the current builders, but only the thirty repaired outputs are installed.
# Preserve all untouched stills, action frames, other directions, and f0-f2 byte-for-byte.
for folder in ['dungeon','town','small']:
    for p in (P/ART/folder).glob('*.png'):
        rel=p.relative_to(P).as_posix()
        if rel not in selected:shutil.copy2(R/rel,p)
qa=W/'review';qa.mkdir(exist_ok=True)
for folder in ['dungeon','town','small']:
    size=Image.open(P/ART/folder/'walk_se_f0.png').width;cell=size*4+10;sheet=Image.new('RGB',(cell*8,(size*4+32)*2),(37,43,38));d=ImageDraw.Draw(sheet)
    for row,facing in enumerate(['se','sw']):
        for i in range(8):
            im=Image.open(P/ART/folder/f'walk_{facing}_f{i}.png').convert('RGBA').resize((size*4,size*4),Image.Resampling.NEAREST);x=i*cell;y=row*(size*4+32);sheet.paste(im,(x,y),im);d.text((x+4,y+size*4+6),f'{facing} f{i}',fill='white')
    sheet.save(qa/(folder+'-contact-4x.png'))
    frames=[]
    for i in range(8):
        im=Image.open(P/ART/folder/f'walk_se_f{i}.png').convert('RGBA').resize((size*6,size*6),Image.Resampling.NEAREST);c=Image.new('RGB',im.size,(37,43,38));c.paste(im,(0,0),im);frames.append(c)
    frames[0].save(qa/(folder+'-walk.gif'),save_all=True,append_images=frames[1:],duration=100,loop=0)
source=Image.open(P/'docs/creatures/arena-starters-2026-10-07/walk/canvaswing_se_sheet.png').convert('RGBA');back=Image.new('RGB',source.size,(37,43,38));back.paste(source,(0,0),source);back.resize((2048,1024),Image.Resampling.NEAREST).save(qa/'source-contact-4x.png')
(W/'final-build.json').write_text(json.dumps({'commands':commands,'selected':selected,'facts':facts,'source_first_three_exact':True,'finish':'nearest existing installed f0-f2 per-set palette, same source/canvas/alpha; all unselected PNGs restored exact','native_validation':'pending'},indent=2),encoding='utf-8');print('Rebuilt and palette-preserved 30 selected frames.',flush=True)
