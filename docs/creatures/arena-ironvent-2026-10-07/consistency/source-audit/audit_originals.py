"""Read-only original arena colour/alpha/geometry audit and W-only snapshots/contact sheets.
No project PNG, code, facing assignment, or paid service is altered.
"""
from pathlib import Path
import hashlib, json, csv, shutil, collections, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageOps
P=Path('C:/Users/pmcga/dev/hollowtide')
W=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-ironvent-consistency-2026-10-07/source-audit')
SRC=P/'docs/creatures/arena-starters-2026-10-07'
FORMS=['cinderhide','clinkerhide','ironvent']
OLD_FORMS=['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw']
FACINGS=['s','se','e','ne','n','nw','w','sw']
BASES={n:SRC/'forms'/f'{n}.png' for n in FORMS}

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def lum(rgb): return rgb[...,0]*.299+rgb[...,1]*.587+rgb[...,2]*.114

def hsv(rgb):
    a=rgb.astype(float)/255; mx=a.max(axis=-1); mn=a.min(axis=-1); dif=mx-mn
    s=np.divide(dif,mx,out=np.zeros_like(dif),where=mx>0)
    h=np.zeros_like(mx); has=dif>0
    r=has&(mx==a[...,0]); g=has&~r&(mx==a[...,1]); b=has&~r&~g
    h[r]=((a[...,1]-a[...,2])[r]/dif[r])%6; h[g]=(a[...,2]-a[...,0])[g]/dif[g]+2; h[b]=(a[...,0]-a[...,1])[b]/dif[b]+4
    return h/6,s,mx

def components(on):
    seen=np.zeros_like(on); result=[]; hh,ww=on.shape
    for y,x in zip(*np.nonzero(on)):
        if seen[y,x]: continue
        todo=[(int(y),int(x))]; seen[y,x]=True; pts=[]
        while todo:
            yy,xx=todo.pop(); pts.append((yy,xx))
            for dy,dx in ((-1,0),(1,0),(0,-1),(0,1),(-1,-1),(-1,1),(1,-1),(1,1)):
                ny,nx=yy+dy,xx+dx
                if 0<=ny<hh and 0<=nx<ww and on[ny,nx] and not seen[ny,nx]: seen[ny,nx]=True; todo.append((ny,nx))
        ys=[q[0] for q in pts]; xs=[q[1] for q in pts]
        result.append({'pixels':len(pts),'bbox':[min(xs),min(ys),max(xs)+1,max(ys)+1]})
    return sorted(result,key=lambda c:-c['pixels'])

def measure(im):
    a=np.array(im.convert('RGBA')); rgb=a[:,:,:3]; al=a[:,:,3]; on=al>0
    if not on.any(): return {'canvas':list(im.size),'empty':True}
    yy,xx=np.nonzero(on); pad=np.pad(on,1); edge=on&~(pad[:-2,1:-1]&pad[2:,1:-1]&pad[1:-1,:-2]&pad[1:-1,2:]); interior=on&~edge
    L=lum(rgb); H,S,V=hsv(rgb); count=collections.Counter(map(tuple,rgb[on])); edge_count=collections.Counter(map(tuple,rgb[edge])); dark=edge&(L<40)
    codes=rgb[:,:,0].astype(int)*65536+rgb[:,:,1].astype(int)*256+rgb[:,:,2]; cp=np.pad(codes,1,constant_values=-1)
    lone=interior&(cp[:-2,1:-1]!=codes)&(cp[2:,1:-1]!=codes)&(cp[1:-1,:-2]!=codes)&(cp[1:-1,2:]!=codes)
    hues={str(i*30)+'-'+str((i+1)*30):round(float(((H[on]*12).astype(int)%12==i)[S[on]>.1].mean()*100),3) if (S[on]>.1).any() else 0 for i in range(12)}
    cs=components(on)
    return {'canvas':list(im.size),'bbox':[int(xx.min()),int(yy.min()),int(xx.max()+1),int(yy.max()+1)],'foot_row':int(yy.max()),'painted_pixels':int(on.sum()),'opaque_pixels':int((al==255).sum()),'partial_alpha_pixels':int(((al>0)&(al<255)).sum()),'alpha_values':list(map(int,np.unique(al))),'mean_brightness':round(float(L[on].mean()),4),'mean_saturation':round(float(S[on].mean()*100),4),'colour_count':len(count),'brightness_p10':round(float(np.quantile(L[on],.1)),4),'brightness_p90':round(float(np.quantile(L[on],.9)),4),'contrast_p90_p10':round(float(np.quantile(L[on],.9)-np.quantile(L[on],.1)),4),'mean_interior_brightness':round(float(L[interior].mean()),4) if interior.any() else None,'edge_pixels':int(edge.sum()),'dark_edge_share_pct':round(float(dark.sum()/edge.sum()*100),3),'dark_edge_rgb_median':np.median(rgb[dark],axis=0).astype(int).tolist() if dark.any() else None,'top_edge_colours':[{'rgb':list(map(int,k)),'pixels':int(v)} for k,v in edge_count.most_common(6)],'top_colours':[{'rgb':list(map(int,k)),'pixels':int(v)} for k,v in count.most_common(10)],'interior_lone_colour_pct':round(float(lone.sum()/max(1,interior.sum())*100),4),'component_count_8':len(cs),'small_components_8':[c for c in cs if c['pixels']<=4],'components_8':cs,'chromatic_hue_distribution_pct':hues,'painted_touches_canvas':{'left':bool(on[:,0].any()),'right':bool(on[:,-1].any()),'top':bool(on[0].any()),'bottom':bool(on[-1].any())},'transparent_nonzero_rgb_pixels':int(((~on)&(rgb!=0).any(axis=2)).sum())}

files=set()
for b in BASES.values(): files.add(b)
for n in FORMS:
    files.update((P/'assets/sprites/arena'/n).glob('*.png'))
    files.update((P/'assets/sprites/arena'/n/'small').glob('*.png'))
for n in FORMS:
    files.update((SRC/'forms').glob(n+'*.png')); files.update((SRC/'walk').glob(n+'*_sheet.png'))
manifest=[]
for p in sorted(files):
    rel=p.relative_to(P).as_posix(); out=W/'originals'/rel; out.parent.mkdir(parents=True,exist_ok=True)
    if out.exists():
        if sha(out)!=sha(p): raise RuntimeError('Original already snapshotted but project changed: '+rel)
    else: shutil.copy2(p,out)
    manifest.append({'path':rel,'sha256':sha(p),'bytes':p.stat().st_size})
protected=[]
for pattern in ('*.gd','*.tscn'):
    for p in P.rglob(pattern):
        if '.godot' in p.parts or '.git' in p.parts: continue
        protected.append({'path':p.relative_to(P).as_posix(),'sha256':sha(p),'bytes':p.stat().st_size})
for p in (P/'tools').rglob('*.py'):
    protected.append({'path':p.relative_to(P).as_posix(),'sha256':sha(p),'bytes':p.stat().st_size})
protected_assets=[]
for n in OLD_FORMS:
    oldfiles=list((P/'assets/sprites/arena'/n).glob('*.png'))+list((P/'assets/sprites/arena'/n/'small').glob('*.png'))+list((SRC/'walk').glob(n+'*_sheet.png'))
    for p in sorted(oldfiles): protected_assets.append({'path':p.relative_to(P).as_posix(),'sha256':sha(p),'bytes':p.stat().st_size})
(W/'before-manifest.json').write_text(json.dumps({'project':str(P),'files':manifest,'protected_code_and_tools':sorted(protected,key=lambda x:x['path']),'protected_assets':sorted(protected_assets,key=lambda x:x['path']),'authorized_report_tool_exception':'tools/arena/report_consistency.py'},indent=2),encoding='utf8')
metrics=[]
for n in FORMS:
    p=BASES[n]; rec={'form':n,'kind':'base','facing':'base','frame':None,'path':p.relative_to(P).as_posix(),**measure(Image.open(p))}; metrics.append(rec)
    for f in FACINGS:
        for k,pre in (('full',''),('small','small/')):
            p=P/'assets/sprites/arena'/n/pre/f'{f}.png'; metrics.append({'form':n,'kind':k,'facing':f,'frame':None,'path':p.relative_to(P).as_posix(),**measure(Image.open(p))})
    for p in (SRC/'walk').glob(f'{n}_*_sheet.png'):
        f=p.stem.removeprefix(n+'_').removesuffix('_sheet'); im=Image.open(p).convert('RGBA'); cw=im.height//2
        for i in range(8):
            fr=im.crop(((i%4)*cw,(i//4)*cw,(i%4+1)*cw,(i//4+1)*cw))
            metrics.append({'form':n,'kind':'walk_full','facing':f,'frame':i,'path':p.relative_to(P).as_posix(),**measure(fr)})
    for p in (P/'assets/sprites/arena'/n/'small').glob('walk_*_f*.png'):
        bits=p.stem.split('_'); metrics.append({'form':n,'kind':'walk_small','facing':bits[1],'frame':int(bits[2][1:]),'path':p.relative_to(P).as_posix(),**measure(Image.open(p))})
(W/'before-metrics.json').write_text(json.dumps(metrics,indent=2),encoding='utf8')
columns=['form','kind','facing','frame','mean_brightness','mean_saturation','colour_count','contrast_p90_p10','partial_alpha_pixels','foot_row','painted_pixels','edge_pixels','dark_edge_share_pct','interior_lone_colour_pct','component_count_8','path']
with (W/'before-metrics.csv').open('w',encoding='utf8',newline='') as fp:
    writer=csv.DictWriter(fp,fieldnames=columns,extrasaction='ignore'); writer.writeheader(); writer.writerows(metrics)
summary={}
for n in FORMS:
    by={k:[m for m in metrics if m['form']==n and m['kind']==k] for k in ('base','full','small','walk_full','walk_small')}
    summary[n]={}
    for k,rs in by.items():
        if not rs: continue
        summary[n][k]={'count':len(rs),'brightness':{'min':min(m['mean_brightness'] for m in rs),'max':max(m['mean_brightness'] for m in rs),'spread':round(max(m['mean_brightness'] for m in rs)-min(m['mean_brightness'] for m in rs),4)},'saturation':{'min':min(m['mean_saturation'] for m in rs),'max':max(m['mean_saturation'] for m in rs),'spread':round(max(m['mean_saturation'] for m in rs)-min(m['mean_saturation'] for m in rs),4)},'colours':{'min':min(m['colour_count'] for m in rs),'max':max(m['colour_count'] for m in rs)},'partial_alpha_total':sum(m['partial_alpha_pixels'] for m in rs),'small_components_total':sum(len(m['small_components_8']) for m in rs)}
(W/'before-summary.json').write_text(json.dumps(summary,indent=2),encoding='utf8')

CONTACT=W/'contacts'; CONTACT.mkdir(exist_ok=True)
def tile(im,label,scale=3,size=None):
    im=im.convert('RGBA'); sz=(im.width*scale,im.height*scale); cellw,cellh=size or (sz[0]+12,sz[1]+28)
    bg=Image.new('RGBA',(cellw,cellh),(45,55,58,255)); d=ImageDraw.Draw(bg)
    for yy in range(20,cellh,12):
        for xx in range(0,cellw,12):
            if (xx//12+yy//12)%2==0:d.rectangle((xx,yy,xx+11,yy+11),fill=(55,66,69,255))
    d.text((5,4),label,fill='white'); bg.alpha_composite(im.resize(sz,Image.Resampling.NEAREST),((cellw-sz[0])//2,20+(cellh-20-sz[1])//2)); return bg
for n in FORMS:
    ps=[P/'assets/sprites/arena'/n/'small'/f'{f}.png' for f in FACINGS]; ims=[Image.open(p).convert('RGBA') for p in ps]; size=(max(i.width for i in ims)*3+12,max(i.height for i in ims)*3+28)
    row=Image.new('RGBA',(size[0]*8,size[1]));
    for j,(f,im) in enumerate(zip(FACINGS,ims)):row.alpha_composite(tile(im,f,3,size),(j*size[0],0))
    row.convert('RGB').save(CONTACT/f'{n}-facings-before-game3x.png')
    # Approved source alongside full facings for source-identity audit.
    base=Image.open(BASES[n]).convert('RGBA'); full=[Image.open(P/'assets/sprites/arena'/n/f'{f}.png').convert('RGBA') for f in FACINGS]; size=(max(i.width for i in [base]+full)+12,max(i.height for i in [base]+full)+28)
    row=Image.new('RGBA',(size[0]*9,size[1]));
    for j,(f,im) in enumerate(zip(['base']+FACINGS,[base]+full)): row.alpha_composite(tile(im,f,1,size),(j*size[0],0))
    row.convert('RGB').save(CONTACT/f'{n}-source-and-facings-original1x.png')
    walk_paths=list((P/'assets/sprites/arena'/n/'small').glob('walk_*_f*.png'))
    if walk_paths:
        example=Image.open(walk_paths[0]); size=(example.width*3+12,example.height*3+28); allwalk=Image.new('RGBA',(size[0]*8,size[1]*8))
        for r,f in enumerate(FACINGS):
            for c in range(8):
                p=P/'assets/sprites/arena'/n/'small'/f'walk_{f}_f{c}.png'; allwalk.alpha_composite(tile(Image.open(p),f'{f} f{c}',3,size),(c*size[0],r*size[1]))
        allwalk.convert('RGB').save(CONTACT/f'{n}-walks-before-game3x.png')
mirror={}
mirrorchecks=[]
for n,pairs in mirror.items():
    for dst,src in pairs.items():
        a=np.array(Image.open(P/'assets/sprites/arena'/n/f'{dst}.png').convert('RGBA')); b=np.array(ImageOps.mirror(Image.open(P/'assets/sprites/arena'/n/f'{src}.png').convert('RGBA'))); mirrorchecks.append({'form':n,'facing':dst,'mirrors':src,'full_rgba_exact':bool(np.array_equal(a,b))})
(W/'mirror-checks-original.json').write_text(json.dumps(mirrorchecks,indent=2),encoding='utf8')
print(json.dumps({'snapshots':len(manifest),'protected_code':len(protected),'protected_old_nine_assets':len(protected_assets),'metrics_rows':len(metrics),'summary':summary,'mirror_checks':mirrorchecks},indent=2))
