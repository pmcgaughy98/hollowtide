"""Normalize arena still/walk colours to each approved take, without moving pixels.

Standalone candidate tool: --project PATH --output PATH [--forms FORM ...]. The output
contains project-relative fixed PNGs, metrics, parameters, and game-size contacts.
Inputs are read-only. The original palette's actual RGB colours are the only possible
painted output colours. Alpha support, canvases and feet are invariant; transparent
RGBA remains literal except partial painted alpha is made opaque. Existing dark
silhouette outlines are locked to an actual dark palette colour; bright rim lighting,
flames, eyes and pale fins are not reclassified as black outlines. Rotation mirror
pairs are copied as exact mirrors, never independently tuned. No generator or API.

Adapted from finish_back.py's redmean nearest-palette method, deliberately excluding
its recentering and blanket silhouette darkening. Brightness/saturation tuning is a
bounded deterministic colour transform; no geometry or dithering. Impossible magenta
material pixels are replaced by nearest valid painted-neighbour colours in-place.
Sparkwick NE/N has an explicit protected-lamp copper contrast ramp, because lamp
brightness hides faded rear body material in whole-sprite averages.
"""
from __future__ import annotations
import argparse, hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageOps

FORMS = ['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw']
FACINGS = 's se e ne n nw w sw'.split()
MIRRORS = {'kithflare': {'e':'w'}, 'sparkwick': {'e':'w'}, 'rimefin': {'e':'w'}, 'riftfin': {'nw':'ne'}, 'scourmaw': {'sw':'se'}}
ART = Path('assets/sprites/arena')
DOC = Path('docs/creatures/arena-starters-2026-10-07')


def lum(rgb):
    return np.asarray(rgb, float) @ np.array([.299,.587,.114])


def sat(rgb):
    rgb=np.asarray(rgb,float);v=rgb.max(axis=-1);m=rgb.min(axis=-1)
    return np.divide(v-m,v,out=np.zeros_like(v),where=v>0)


def edge_of(on):
    p=np.pad(on,1)
    return on & ~(p[:-2,1:-1]&p[2:,1:-1]&p[1:-1,:-2]&p[1:-1,2:])


def nearest(rgb,palette):
    c=np.asarray(rgb,float)[:,None,:];p=np.asarray(palette,float)[None,:,:]
    r=(c[...,0]+p[...,0])/2
    d=(2+r/256)*(c[...,0]-p[...,0])**2+4*(c[...,1]-p[...,1])**2+(2+(255-r)/256)*(c[...,2]-p[...,2])**2
    return palette[d.argmin(axis=1)]


def metrics(a):
    on=a[...,3]>0;c=a[...,:3][on];e=edge_of(on);l=lum(c);ys,xs=np.nonzero(on)
    low=e & (lum(a[...,:3])<40)
    colours,counts=np.unique(c,axis=0,return_counts=True)
    code=a[...,0].astype(int)*65536+a[...,1].astype(int)*256+a[...,2].astype(int);p=np.pad(code,1,constant_values=-1)
    lone=on&~e&(p[:-2,1:-1]!=code)&(p[2:,1:-1]!=code)&(p[1:-1,:-2]!=code)&(p[1:-1,2:]!=code)
    return {'brightness':round(float(l.mean()),4),'saturation_pct':round(float(sat(c).mean()*100),4),'colours':len(colours),'contrast_std':round(float(l.std()),4),'alpha_partial':int(((a[...,3]>0)&(a[...,3]<255)).sum()),'painted_pixels':int(on.sum()),'bbox':[int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)],'foot_row':int(ys.max()),'canvas':[a.shape[1],a.shape[0]],'dark_edge_pixels':int(low.sum()),'lone_interior_pct':round(float(lone.sum()/max(1,(on&~e).sum())*100),4)}


def base_rules(a):
    on=a[...,3]>0;p=np.unique(a[...,:3][on],axis=0);e=edge_of(on)
    # Base's real outline ramp: use dark edge pixels only, not glows or pale bone.
    dark=e & (lum(a[...,:3])<min(40,float(lum(a[...,:3][on&~e]).mean())*.55))
    if not dark.any():
        colour=p[np.argmin(lum(p))]
    else:
        colour=nearest(np.median(a[...,:3][dark],axis=0)[None,:],p)[0]
    m=metrics(a)
    return p,colour,m


def transform(c,gain,s_gain):
    # HSV saturation scaling preserves each input hue; brightness gain preserves
    # shading order. Palette projection supplies the source form's material colours.
    c=np.asarray(c,float)*gain;v=c.max(axis=1,keepdims=True)
    c=v-(v-c)*s_gain
    return np.clip(c,0,255)


def normalize(a,palette,outline,target):
    on=a[...,3]>0;colours,idx,counts=np.unique(a[...,:3][on],axis=0,return_inverse=True,return_counts=True)
    # Only an existing dark outer line is normalised; pale/bright edge art is kept.
    threshold=min(40,float(lum(a[...,:3][on&~edge_of(on)]).mean())*.40)
    mask=edge_of(on)&(lum(a[...,:3])<threshold)
    fixed_counts=np.bincount(idx[mask[on]],minlength=len(colours))
    moving_counts=counts-fixed_counts
    n=int(on.sum());fixed_lum=float(lum(outline))*int(mask.sum());fixed_sat=float(sat(outline))*100*int(mask.sum())
    target_lum=target['brightness'];target_sat=target['saturation_pct']
    best=None;cache={}
    def evaluate(g,s):
        nonlocal best
        g=float(np.clip(g,.65,1.85));s=float(np.clip(s,.60,1.55));key=(round(g,7),round(s,7))
        if key in cache:return cache[key]
        mapped=nearest(transform(colours,g,s),palette)
        brightness=float((lum(mapped)@moving_counts+fixed_lum)/n)
        saturation=float((sat(mapped)*100@moving_counts+fixed_sat)/n)
        # Primary goal actual colour/material statistics, then small transform.
        error=((brightness-target_lum)/2)**2+((saturation-target_sat)/2)**2+.005*((g-1)**2+(s-1)**2)
        result=(error,g,s,mapped,brightness,saturation)
        cache[key]=result
        if best is None or result[0]<best[0]:best=result
        return result
    # Coarse global search avoids discontinuities from the exact small base palette.
    for g in np.linspace(.75,1.70,39):
        for s in np.linspace(.70,1.45,31):evaluate(g,s)
    for step in [.0125,.00625,.003125,.0015625]:
        bg,bs=best[1:3]
        for g in bg+np.arange(-2,3)*step:
            for s in bs+np.arange(-2,3)*step:evaluate(g,s)
    _,gain,s_gain,mapped,b,s=best
    out=a.copy();out[on,:3]=mapped[idx];out[on,3]=255;out[mask,:3]=outline
    assert np.array_equal(out[...,3]>0,on)
    assert set(map(tuple,out[on,:3])).issubset(set(map(tuple,palette)))
    params={'brightness_gain':gain,'saturation_gain':s_gain,'brightness_target':target_lum,'saturation_target_pct':target_sat,'actual_brightness':b,'actual_saturation_pct':s,'outline_rgb':list(map(int,outline)),'outline_px':int(mask.sum()),'outline_lum_threshold':threshold,'search_candidates':len(cache),'same_support':True,'same_canvas':True,'partial_alpha_made_opaque':int(((a[...,3]>0)&(a[...,3]<255)).sum())}
    return out,params


def contact(name,rows,small_rows,out):
    cellw=165;cellh=185;sheet=Image.new('RGB',(8*cellw,2*cellh+38),(22,28,34));draw=ImageDraw.Draw(sheet)
    draw.text((8,5),f'{name}: BEFORE top / AFTER bottom; game size x3',fill='white')
    for r in range(2):
        for i,f in enumerate(FACINGS):
            a=small_rows[r][f];im=Image.fromarray(a);im=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST)
            x=i*cellw+(cellw-im.width)//2;y=38+r*cellh+17
            sheet.paste(im,(x,y),im);m=metrics(a)
            draw.text((i*cellw+5,38+r*cellh),f'{f}: {m["brightness"]:.1f} / {m["saturation_pct"]:.1f}%',fill='white')
    out.parent.mkdir(parents=True,exist_ok=True);sheet.save(out)


def repair_magenta(a,palette):
    """Replace impossible magenta material RGB with nearest valid painted neighbours.

    The approved palettes contain no magenta. RGB is sampled from nearest valid
    painted pixels, with modal colour breaking equal-distance ties; no support pixel
    is deleted and no geometry is changed. Each replacement is explicitly audited.
    """
    a=a.copy();rgb=a[...,:3];on=a[...,3]>0
    bad=on&(rgb[...,0]>170)&(rgb[...,2]>150)&(rgb[...,1]<100)
    good=on&~bad;ys,xs=np.nonzero(good);coords=np.column_stack([ys,xs]);changes=[]
    for y,x in zip(*np.nonzero(bad)):
        d=((coords-[y,x])**2).sum(1);near=coords[d==d.min()];samples=rgb[near[:,0],near[:,1]]
        c,count=np.unique(samples,axis=0,return_counts=True);top=c[count==count.max()]
        chosen=nearest(np.median(top,axis=0)[None,:],palette)[0]
        changes.append({'xy':[int(x),int(y)],'before_rgb':list(map(int,rgb[y,x])),'neighbor_base_rgb':list(map(int,chosen)),'nearest_distance_sq':int(d.min())})
        a[y,x,:3]=chosen
    assert np.array_equal(a[...,3],on.astype(np.uint8)*255)
    return a,changes


def refine_sparkwick_body(a,facing,palette):
    """Repair dark mauve rear copper while preserving exact lantern/outline RGB.

    Requested visual revision: whole-sprite averages hide the lantern bias. The
    NE/N rear head/torso brown material must use the approved copper ramp. Lamp
    protection rectangles are source-canvas coordinates and contain the whole lamp
    plus its neck. Cream rims, deep outlines, high-saturation gold stripes and bright
    effects are excluded. Only existing body RGB is remapped, no pattern is added.
    """
    out=a.copy();h,w=a.shape[:2];yy,xx=np.mgrid[:h,:w];rgb=a[...,:3].astype(float);l=lum(rgb);ss=sat(rgb)
    # Protected visible lamp envelopes, read from the source pixels; intentionally
    # broad so all glass, metal cage, flames and tail-to-lamp connector are literal.
    lamp=(xx<70)&(yy<94) if facing=='ne' else (xx<68)&(yy<104)
    mask=(a[...,3]>0)&~lamp&(l>=80)&(l<180)&(ss>=.30)&(ss<=.74)&(rgb[...,0]>rgb[...,1])&(rgb[...,1]>rgb[...,2])
    centre,contrast=(139.0,1.50) if facing=='ne' else (138.0,1.55)
    old_mean=float(l[mask].mean());colours,idx,counts=np.unique(a[mask,:3],axis=0,return_inverse=True,return_counts=True)
    old_lum=lum(colours);new_lum=np.clip((old_lum-old_mean)*contrast+centre,0,255)
    scaled=colours.astype(float)*np.divide(new_lum,old_lum,out=np.zeros_like(new_lum),where=old_lum>0)[:,None]
    mapped=nearest(transform(scaled,1,1.20),palette);out[mask,:3]=mapped[idx]
    return out,{'body_lum_centre':centre,'body_contrast_factor':contrast,'body_saturation_gain':1.20,'body_pixels':int(mask.sum()),'changed_body_pixels':int(np.any(out[...,:3]!=a[...,:3],axis=-1).sum()),'lamp_envelope':[0,0,70,94] if facing=='ne' else [0,0,68,104],'lamp_exact':bool(np.array_equal(out[lamp],a[lamp])),'outline_and_cream_exact':bool(np.array_equal(out[~mask],a[~mask])),'body_before_brightness':old_mean,'body_after_brightness':float(lum(out[mask,:3]).mean()),'body_before_contrast_std':float(l[mask].std()),'body_after_contrast_std':float(lum(out[mask,:3]).std()),'body_before_saturation_pct':float(ss[mask].mean()*100),'body_after_saturation_pct':float(sat(out[mask,:3]).mean()*100),'same_alpha':bool(np.array_equal(out[...,3],a[...,3])),'shade_mapping':[{'from_rgb':list(map(int,c)),'to_rgb':list(map(int,n)),'pixels':int(count),'from_lum':float(lum(c)),'to_lum':float(lum(n))} for c,n,count in zip(colours,mapped,counts)]}



def refine_small_outlier(original,current,params,palette,outline,target,small_target,shrink):
    """Choose a nearby transform that reduces majority-shrink brightness loss.

    Only colour parameters change. Full-size brightness stays within2.5 of the
    approved base; saturation within3 percentage points. Actual pipeline shrink
    is evaluated, so no game-size postprocessing or geometry changes are used.
    """
    on=original[...,3]>0;mask=edge_of(on)&(lum(original[...,:3])<params['outline_lum_threshold']);colours,idx=np.unique(original[...,:3][on],axis=0,return_inverse=True)
    best=current;best_params=dict(params);start=metrics(current);small_start=metrics(np.array(shrink(Image.fromarray(current),3)));score_best=max(0,abs(small_start['brightness']-small_target)-3.5)**2+.05*(start['brightness']-target['brightness'])**2
    for gain in params['brightness_gain']+np.linspace(-.04,.06,21):
        for saturation in params['saturation_gain']+np.array([-.02,0,.02]):
            out=original.copy();out[on,:3]=nearest(transform(colours,gain,saturation),palette)[idx];out[mask,:3]=outline
            m=metrics(out)
            if abs(m['brightness']-target['brightness'])>2.5 or abs(m['saturation_pct']-target['saturation_pct'])>3:continue
            sm=metrics(np.array(shrink(Image.fromarray(out),3)));score=max(0,abs(sm['brightness']-small_target)-3.5)**2+.05*(m['brightness']-target['brightness'])**2
            if score<score_best:
                best=out;score_best=score;best_params.update({'brightness_gain':float(gain),'saturation_gain':float(saturation),'actual_brightness':m['brightness'],'actual_saturation_pct':m['saturation_pct'],'game_size_refinement':{'small_target':small_target,'small_before_brightness':small_start['brightness'],'small_after_brightness':sm['brightness'],'full_mean_limit':2.5}})
    return best,best_params


def main():
    ap=argparse.ArgumentParser();ap.add_argument('--project',type=Path,required=True);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--forms',nargs='+',default=FORMS);ap.add_argument('--source',type=Path,help='Optional preserved-original project-relative root')
    args=ap.parse_args();p=args.project;source=args.source or p;out=args.output
    sys.path.insert(0,str(p/'tools/arena'));from downscale import shrink
    out.mkdir(parents=True,exist_ok=True);records={'algorithm':'bounded HSV gain -> exact own-base redmean nearest palette; existing dark outer outline only','forms':{},'inputs':{}}
    def read(rel):
        path=source/rel;records['inputs'][str(rel).replace('\\','/')]=hashlib.sha256(path.read_bytes()).hexdigest();return np.array(Image.open(path).convert('RGBA'))
    def save(a,rel):
        dest=out/rel;dest.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(a).save(dest)
    for name in args.forms:
        rel=DOC/(f'{name}_arena_front_take2_clear.png' if name in ['kithflare','tallowroot','rimefin'] else f'forms/{name}.png')
        base=read(rel);palette,outline,target=base_rules(base);row={'base':str(rel),'base_metrics':target,'palette_size':len(palette),'outline_rgb':list(map(int,outline)),'facings':{},'walk':{}}
        before={f:read(ART/name/f'{f}.png') for f in FACINGS};after={};mirrors=MIRRORS.get(name,{})
        for f in FACINGS:
            if f in mirrors:continue
            after[f],params=normalize(before[f],palette,outline,target)
            row['facings'][f]={'before':metrics(before[f]),'after':metrics(after[f]),'parameters':params}
        for f,source_f in mirrors.items():
            assert np.array_equal(before[f],before[source_f][:,::-1]),f'Original {name}/{f} is not exact mirror of {source_f}'
            after[f]=after[source_f][:,::-1].copy()
            row['facings'][f]={'before':metrics(before[f]),'after':metrics(after[f]),'mirror_of':source_f,'exact_mirror':True}
        if name=='rimefin':
            target_small=float(np.median([metrics(np.array(shrink(Image.fromarray(after[f]),3)))['brightness'] for f in FACINGS]))
            f='s';after[f],params=refine_small_outlier(before[f],after[f],row['facings'][f]['parameters'],palette,outline,target,target_small,shrink)
            row['facings'][f]['after']=metrics(after[f]);row['facings'][f]['parameters']=params
        if name=='sparkwick':
            for f in ['ne','n']:
                after[f],body_params=refine_sparkwick_body(after[f],f,palette)
                row['facings'][f]['before_body_revision']=row['facings'][f]['after']
                row['facings'][f]['after']=metrics(after[f]);row['facings'][f]['body_revision']=body_params
        for f in FACINGS:save(after[f],ART/name/f'{f}.png')
        for kind in ['before','after']:
            row[f'{kind}_brightness_spread']=max(row['facings'][f][kind]['brightness'] for f in FACINGS)-min(row['facings'][f][kind]['brightness'] for f in FACINGS)
            row[f'{kind}_saturation_spread_pct']=max(row['facings'][f][kind]['saturation_pct'] for f in FACINGS)-min(row['facings'][f][kind]['saturation_pct'] for f in FACINGS)
        small_before={f:np.array(shrink(Image.fromarray(before[f]),3)) for f in FACINGS}
        small_after={f:np.array(shrink(Image.fromarray(after[f]),3)) for f in FACINGS}
        for f,source_f in mirrors.items():small_after[f]=small_after[source_f][:,::-1].copy()
        for f in FACINGS:
            row['facings'][f]['small_before']=metrics(small_before[f]);row['facings'][f]['small_after']=metrics(small_after[f])
            save(small_after[f],ART/name/'small'/f'{f}.png')
        for kind in ['small_before','small_after']:
            row[f'{kind}_brightness_spread']=max(row['facings'][f][kind]['brightness'] for f in FACINGS)-min(row['facings'][f][kind]['brightness'] for f in FACINGS)
            row[f'{kind}_saturation_spread_pct']=max(row['facings'][f][kind]['saturation_pct'] for f in FACINGS)-min(row['facings'][f][kind]['saturation_pct'] for f in FACINGS)
        contact(name,[before,after],[small_before,small_after],out/'contacts'/f'{name}_before_after_game3x.png')
        for file in sorted((source/DOC/'walk').glob(f'{name}_*_sheet.png')):
            rel=file.relative_to(source);sheet=read(rel);h,w=sheet.shape[:2];cell=h//2
            assert w==4*cell and h==2*cell,'Unexpected walk sheet grid'
            fixed=sheet.copy();frames=[]
            for i in range(8):
                y=(i//4)*cell;x=(i%4)*cell;a=sheet[y:y+cell,x:x+cell];clean,repairs=repair_magenta(a,palette);b,params=normalize(clean,palette,outline,target);params['magenta_neighbor_repairs']=repairs;fixed[y:y+cell,x:x+cell]=b
                frames.append({'frame':i,'before':metrics(a),'after':metrics(b),'parameters':params})
            row['walk'][file.name]=frames;save(fixed,rel)
        records['forms'][name]=row
        print(name,'brightness',round(row['before_brightness_spread'],2),'->',round(row['after_brightness_spread'],2),'saturation',round(row['before_saturation_spread_pct'],2),'->',round(row['after_saturation_spread_pct'],2),flush=True)
        (out/'candidate-audit.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
    print('Candidate saved:',out,flush=True)

if __name__=='__main__':main()
