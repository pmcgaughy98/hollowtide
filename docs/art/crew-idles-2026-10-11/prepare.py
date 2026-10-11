from pathlib import Path
import hashlib,json,shutil,sys
import numpy as np
from PIL import Image,ImageDraw
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
NAMES=['grubbit','muskin','slipjaw','stillwade','wickglow','rinsepaw']
sys.path.insert(0,str(C/'tools/arena'))
from downscale import resample
from recolor_creature import recolor,SCHEMES
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def outline(im):
    a=np.array(im);m=a[...,3]>0;p=np.pad(m,1)
    edge=m&~(p[:-2,1:-1]&p[2:,1:-1]&p[1:-1,:-2]&p[1:-1,2:])
    lum=a[...,0]*.3+a[...,1]*.59+a[...,2]*.11
    a[edge&(lum>=12),:3]=0
    return Image.fromarray(a)
assert not (W/'manifest.json').exists(),'Preserve the previous snapshots.'
manifest=[];protected={}
for name in NAMES:
    root=C/f'assets/sprites/arena/{name}'
    assert not (root/'town/idle_s.png').exists(),'Existing idle must be inspected: '+name
    chosen_rel=f'docs/creatures/arena-starters-2026-10-07/forms/{name}_arena_front_chosen.png'
    for p in [C/chosen_rel,*sorted(root.rglob('*.png'))]:
        rel=p.relative_to(C).as_posix();protected[rel]=sha(p)
        dst=W/'originals'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
        assert sha(dst)==protected[rel]
    source=Image.open(C/chosen_rel).convert('RGBA')
    scheme=SCHEMES[name];coloured=recolor(source,scheme['rule'],scheme.get('accent'))
    assert np.array_equal(np.array(source)[...,3],np.array(coloured)[...,3])
    full=Image.open(root/'s.png').convert('RGBA');town=Image.open(root/'town/s.png').convert('RGBA')
    # Existing set scale, measured from its canvas; job objects do not shrink the creature.
    factor=full.width/town.width
    small=outline(resample(coloured,factor))
    sb=small.getbbox();tb=town.getbbox()
    # Put the source whole canvas into the exact existing town canvas, feet on its south baseline.
    dx=round(town.width/2-(sb[0]+sb[2])/2)
    dy=tb[3]-sb[3]
    assert sb[0]+dx>=1 and sb[2]+dx<town.width and sb[1]+dy>=1 and sb[3]+dy<town.height,(name,sb,dx,dy,town.size)
    idle=Image.new('RGBA',town.size);idle.paste(small,(dx,dy))
    assert np.count_nonzero(np.array(idle)[...,3])==np.count_nonzero(np.array(small)[...,3])
    assert set(np.unique(np.array(idle)[...,3])).issubset({0,255})
    path=f'assets/sprites/arena/{name}/town/idle_s.png';dst=W/'prepared'/path;dst.parent.mkdir(parents=True,exist_ok=True);idle.save(dst)
    (W/'recoloured').mkdir(exist_ok=True);coloured.save(W/'recoloured'/f'{name}.png')
    manifest.append({'form':name,'source':chosen_rel,'source_sha':sha(C/chosen_rel),'output':path,'output_sha':sha(dst),'size':list(town.size),'scale_factor':factor,'translation':[dx,dy],'idle_bbox':list(idle.getbbox()),'town_s_bbox':list(tb),'baseline':tb[3]-1,'object_rule':{'grubbit':'parcel; no tag','stillwade':'bell; no gauge stick or rocks','wickglow':'lamplighter pole','rinsepaw':'ladle, greens, pot','muskin':'worn satchel','slipjaw':'worn bandana'}[name]})
for rel in ['tools/arena/downscale.py','tools/arena/recolor_creature.py','scripts/town/guild_crew.gd','scripts/town/scene_kit.gd','scripts/town/town_room.gd','scripts/arena/creature_finish.gd','scripts/arena/creature_finish.gdshader','scripts/arena/sel_out.gdshaderinc','project.godot']:
    protected[rel]=sha(C/rel)
(W/'manifest.json').write_text(json.dumps(manifest,indent=2));(W/'protected.json').write_text(json.dumps(protected,indent=2))
out=Image.new('RGB',(1050,660),'#3f5140');draw=ImageDraw.Draw(out)
for k,r in enumerate(manifest):
    x=(k%3)*350;y=(k//3)*330
    draw.text((x+8,y+8),r['form']+' / WALK SOUTH     IDLE',fill='#fff4e8')
    for j,p in enumerate([C/f'assets/sprites/arena/{r["form"]}/town/s.png',W/'prepared'/r['output']]):
        im=Image.open(p).convert('RGBA');im=im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST)
        yy=y+260-r['baseline']*2
        out.paste(im,(x+j*175+(175-im.width)//2,yy),im)
    draw.line((x+5,y+262,x+340,y+262),fill='#98a786')
    draw.text((x+8,y+286),r['object_rule'],fill='#fff4e8')
out.save(W/'prepared-review.png')
print(json.dumps(manifest,indent=2));print('Six new idle assets prepared. Existing source files remain exact.')
