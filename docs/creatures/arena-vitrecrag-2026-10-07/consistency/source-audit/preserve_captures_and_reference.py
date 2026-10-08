"""Preserve original native Vitrecrag captures and make labelled source/facing previews.
Pure evidence writes, no project edits. Display-only enlargement uses nearest pixels.
"""
from pathlib import Path
import json,shutil,hashlib,importlib.util
from PIL import Image,ImageDraw
P=Path('C:/Users/pmcga/dev/hollowtide');W=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-vitrecrag-consistency-2026-10-07/source-audit');SRC=W/'originals/docs/creatures/arena-starters-2026-10-07';FORMS=['fusern','slagglass','vitrecrag'];FS=['s','se','e','ne','n','nw','w','sw']
def tile(im,label,scale,size):
    im=im.convert('RGBA');w,h=size;bg=Image.new('RGBA',size,(45,55,58,255));d=ImageDraw.Draw(bg)
    for y in range(20,h,12):
        for x in range(0,w,12):
            if (x//12+y//12)%2==0:d.rectangle((x,y,x+11,y+11),fill=(55,66,69,255))
    d.text((5,4),label,fill='white');shown=im.resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST);bg.alpha_composite(shown,((w-shown.width)//2,20+(h-20-shown.height)//2));return bg
m_path=W/'before-manifest.json';m=json.loads(m_path.read_text());caps=[]
for p in sorted((P/'docs/creatures/arena-vitrecrag-2026-10-07').glob('*.png')):
    rel=p.relative_to(P).as_posix();q=W/'originals'/rel;q.parent.mkdir(parents=True,exist_ok=True)
    if q.exists():assert q.read_bytes()==p.read_bytes(),rel
    else:shutil.copy2(p,q)
    caps.append({'path':rel,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size})
m['capture_originals']=caps;m_path.write_text(json.dumps(m,indent=2))
spec=importlib.util.spec_from_file_location('readonly_downscale',P/'tools/arena/downscale.py');ds=importlib.util.module_from_spec(spec);spec.loader.exec_module(ds)
for n in FORMS:
    base=Image.open(SRC/'forms'/f'{n}.png').convert('RGBA');faces=[Image.open(W/'originals/assets/sprites/arena'/n/f'{f}.png').convert('RGBA') for f in FS]
    ims=[base]+faces;size=(max(im.width for im in ims)*2+12,max(im.height for im in ims)*2+28);sheet=Image.new('RGBA',(size[0]*3,size[1]*3))
    for j,(label,im) in enumerate(zip(['BASE']+FS,ims)):sheet.alpha_composite(tile(im,label,2,size),((j%3)*size[0],(j//3)*size[1]))
    sheet.convert('RGB').save(W/'contacts'/f'{n}-base-and-facings-before-full2x.png')
    smallbase=ds.shrink(base,3);row=Image.open(W/'contacts'/f'{n}-facings-before-game3x.png').convert('RGBA');cw=row.width//8;out=Image.new('RGBA',(row.width+cw,row.height),(45,55,58,255));out.alpha_composite(tile(smallbase,'BASE',3,(cw,row.height)),(0,0));out.alpha_composite(row,(cw,0));out.convert('RGB').save(W/'contacts'/f'{n}-base-and-facings-before-game3x.png')
for f in ('s','se','e','ne','n'):
    sheet=Image.open(SRC/'walk'/f'fusern_{f}_sheet.png').convert('RGBA');cw=sheet.height//2;ims=[sheet.crop(((j%4)*cw,(j//4)*cw,(j%4+1)*cw,(j//4+1)*cw)) for j in range(8)];size=(cw*2+12,cw*2+28);out=Image.new('RGBA',(size[0]*4,size[1]*2))
    for j,im in enumerate(ims):out.alpha_composite(tile(im,f'{f} f{j}',2,size),((j%4)*size[0],(j//4)*size[1]))
    out.convert('RGB').save(W/'contacts'/f'fusern-walk-{f}-before-full2x.png')
print(json.dumps({'native_captures_preserved':len(caps),'full2x_and_base_contacts':11},indent=2))
