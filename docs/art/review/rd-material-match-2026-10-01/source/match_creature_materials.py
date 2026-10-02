from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,colorsys
ROOT=Path('C:/Users/pmcga/dev/hollowtide')
OUT=Path(__file__).parent/'creatures'; OUT.mkdir(exist_ok=True)
NAMES=['kithflare','wayburn','coalcrest','fusern','slagglass','vitrecrag']

def group(c):
    h,s,v=colorsys.rgb_to_hsv(*(float(i)/255 for i in c))
    if v<0.22: return 'outline'
    if s<0.20: return 'stone'
    if v>0.77 and 0.035<h<0.18 and s>0.50: return 'heat'
    if 0.90<h or h<0.035: return 'red'
    if 0.55<h<0.90: return 'plum'
    return 'ochre'

def finish(im,ref):
    a=np.array(im.convert('RGBA'));original=a.copy();p=np.array(ref.convert('RGBA'))
    pal=np.unique(p[p[:,:,3]>0,:3],axis=0)
    bins={k:np.array([c for c in pal if group(c)==k]) for k in set(group(c) for c in pal)}
    rgb=a[:,:,:3].copy(); mask=a[:,:,3]>0
    for c in np.unique(rgb[mask],axis=0):
        k=group(c);choices=bins.get(k,pal)
        if len(choices)==0: choices=pal
        # Preserve material and lightness; front ramps, not a global colour lock.
        delta=choices.astype(float)-c
        weights=np.array([0.28,0.56,0.16]);dist=(delta**2*weights).sum(1)
        target=choices[dist.argmin()]
        cm=mask & (rgb==c).all(2); a[cm,:3]=target
        if k in ('outline','heat') or cm.sum()<90: continue
        # A narrow directional facet along existing colour-plane boundaries.
        # No new seams, noise, alpha, outlines or anatomy are drawn.
        lumi=choices@weights;now=target@weights
        hi=choices[(lumi>now+7)&(lumi<now+29)]
        lo=choices[(lumi<now-7)&(lumi>now-29)]
        inner=cm.copy()
        inner[0,:]=False;inner[:,0]=False;inner[-1,:]=False;inner[:,-1]=False
        upper=inner & (~np.roll(cm,2,axis=0)|~np.roll(cm,2,axis=1))
        lower=inner & (~np.roll(cm,-1,axis=0)|~np.roll(cm,-1,axis=1))
        # Keep silhouette/contact contours dark and exact.
        near_edge=~np.roll(mask,2,0)|~np.roll(mask,2,1)|~np.roll(mask,-2,0)|~np.roll(mask,-2,1)
        upper &= ~near_edge; lower &= ~near_edge & ~upper
        if len(hi): a[upper,:3]=hi[np.argmin(((hi.astype(float)-target)**2).sum(1))]
        if len(lo): a[lower,:3]=lo[np.argmin(((lo.astype(float)-target)**2).sum(1))]
    a[~mask]=original[~mask]
    assert np.array_equal(a[:,:,3],original[:,:,3])
    return Image.fromarray(a),int(np.any(a[:,:,:3]!=original[:,:,:3],axis=2).sum())

manifest={};card=Image.new('RGB',(960,900),(45,55,59));draw=ImageDraw.Draw(card)
for n,name in enumerate(NAMES):
    front_path=ROOT/f'assets/sprites/creatures/{name}_rd_front_2026_10_01.png';front=Image.open(front_path).convert('RGBA')
    manifest[name]={}
    for view in ['front','back','8dir']:
        p=ROOT/f'assets/sprites/creatures/{name}_rd_{view}_2026_10_01.png';im=Image.open(p).convert('RGBA')
        after,changes=(im,0) if view=='front' else finish(im,front)
        dst=OUT/f'{name}_{view}.png';after.save(dst)
        manifest[name][view]={'source':str(p),'source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'output':str(dst),'changed_rgb_pixels':changes,'alpha_changes':0,'size':im.size,'bbox':after.getbbox(),'sha256':hashlib.sha256(dst.read_bytes()).hexdigest()}
        if view in ['front','back']:
            x=(n%3)*320;y=(n//3)*450+(0 if view=='front' else 208)
            draw.text((x+12,y+6),f'{name} {view} matched',fill='white');cut=after.crop(after.getbbox());cut.thumbnail((300,200),Image.Resampling.NEAREST);card.paste(cut,(x+(320-cut.width)//2,y+28),cut)
    if name=='vitrecrag':
        manifest[name]['attacks']={}
        for p in sorted((ROOT/'assets/sprites/creatures/attacks/vitrecrag_rd_2026_10_01').glob('f??.png')):
            after,changes=finish(Image.open(p),front);dst=OUT/p.name;after.save(dst)
            manifest[name]['attacks'][p.name]={'source':str(p),'source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'output':str(dst),'changed_rgb_pixels':changes,'alpha_changes':0,'sha256':hashlib.sha256(dst.read_bytes()).hexdigest()}
card.save(OUT/'creature_materials_after.png');(OUT/'material_manifest.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps({n:{v:r.get('changed_rgb_pixels') for v,r in m.items() if v!='attacks'} for n,m in manifest.items()}))
