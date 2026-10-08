"""Repaint seven arena forms from preserved sources without moving painted pixels.

Six forms use their approved base palette. Oxbowarchon replaces only desaturated
mint jade with exact darker jade RGBs from its original turn-based front, as Preston
requested, retaining the new A silhouette, charcoal body, gold and saturated rails.
An explicit corrected palette reference is saved alongside unchanged original bases.
The existing normalizer and named-form builder remain unchanged. No API is used.
"""
from pathlib import Path
import argparse, importlib.util, json, shutil, subprocess, sys
import numpy as np
from PIL import Image

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--workspace',type=Path,default=Path(__file__).resolve().parent,help='Review workspace with source-audit/originals and pipeline copies')
parser.add_argument('--forms',nargs='+',help='Only regenerate explicitly named forms from the preserved originals')
args=parser.parse_args()
W=args.workspace.resolve()
S=W/'source-audit/originals'; C=W/'source-audit/candidate-project'
DOC=Path('docs/creatures/arena-starters-2026-10-07')
FORMS=['slagglass','preostmar','oathfen','oxbowarchon','punchybun','sparkjab','starward']
if args.forms:
    assert set(args.forms).issubset(FORMS)
    FORMS=args.forms
FACING='s se e ne n nw w sw'.split()
spec=importlib.util.spec_from_file_location('norm',C/'tools/arena/normalize_arena_palette.py')
norm=importlib.util.module_from_spec(spec);spec.loader.exec_module(norm)
sys.path.insert(0,str(C/'tools/arena'))
from downscale import resample
reference=Image.open(W/'source-audit/references/assets/sprites/creatures/oxbowarchon.png').convert('RGBA')
ref=np.array(reference); orig_colors=np.unique(ref[ref[...,3]>0,:3],axis=0)
# Exact original muted jade ramp, excluding the bright rail-emission ramp.
RAMP=np.array([[28,60,52],[36,76,60],[52,84,68],[68,100,84],[76,116,92],[92,124,100],[108,148,124],[148,188,148]],dtype=np.uint8)
assert set(map(tuple,RAMP)).issubset(set(map(tuple,orig_colors)))

def jade(a):
    """Preserve geometry and non-mint pixels; replace only pale jade facet colors."""
    out=a.copy();rgb=a[...,:3].astype(float);l=norm.lum(rgb);s=norm.sat(rgb)
    mask=(a[...,3]>0)&(rgb[...,1]>rgb[...,0]+5)&(rgb[...,1]>rgb[...,2]+3)&(s<.43)&(l>65)
    colors,inv=np.unique(a[mask,:3],axis=0,return_inverse=True)
    if len(colors):
        mapped=norm.nearest(colors.astype(float)*np.array([.60,.64,.63]),RAMP)
        out[mask,:3]=mapped[inv]
    assert np.array_equal(out[...,3],a[...,3])
    return out,int(mask.sum())

def save(a,rel):
    p=C/rel;p.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(a).save(p)

def orange_seams(a,palette):
    """Restore bright mid-dome mortar to the approved orange, retaining the crater."""
    out=a.copy();rgb=a[...,:3].astype(float);yy=np.indices(a.shape[:2])[0]
    mask=(a[...,3]>0)&(yy>a.shape[0]*.30)&(yy<a.shape[0]*.78)&(norm.lum(rgb)>110)&(rgb[...,0]>1.25*rgb[...,1])&(rgb[...,1]>.45*rgb[...,0])&(rgb[...,2]<.30*rgb[...,0])
    ramp=palette[(palette[:,0]>180)&(palette[:,1]<110)&(palette[:,2]<35)]
    assert len(ramp)
    out[mask,:3]=norm.nearest(rgb[mask]*np.array([1,.70,1]),ramp)
    return out,int(mask.sum())

def refine_spark_game(frame,fixed,params,palette,outline,target):
    """Reduce sparse cream-palette jumps in the current 0.85-scale game pipeline."""
    on=frame[...,3]>0;mask=norm.edge_of(on)&(norm.lum(frame[...,:3])<params['outline_lum_threshold'])
    colors,inv=np.unique(frame[on,:3],axis=0,return_inverse=True)
    def score(a):
        small=norm.metrics(np.array(resample(Image.fromarray(a),3/.85)))
        full=norm.metrics(a)
        return (small['brightness']-201.0)**2+.05*(full['brightness']-target['brightness'])**2
    best=fixed;bs=score(best)
    for g in params['brightness_gain']+np.linspace(-.045,.045,19):
        for s in params['saturation_gain']+np.array([-.015,0,.015]):
            a=frame.copy();a[on,:3]=norm.nearest(norm.transform(colors,g,s),palette)[inv];a[mask,:3]=outline
            m=norm.metrics(a)
            if abs(m['brightness']-target['brightness'])>4:continue
            sc=score(a)
            if sc<bs:best=a;bs=sc
    return best

audit=json.loads((W/'candidate-audit.json').read_text()) if (W/'candidate-audit.json').exists() else {'algorithm':'existing bounded gain and own-base palette; explicit original-jade override for Oxbowarchon','forms':{}}
for name in FORMS:
    base=np.array(Image.open(S/DOC/'forms'/f'{name}.png').convert('RGBA'))
    if name=='oxbowarchon':
        base,count=jade(base);dest=W/'palette-reference/oxbowarchon-dark-jade.png';dest.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(base).save(dest)
    palette,outline,target=norm.base_rules(base)
    row={'target':target,'palette':palette.tolist(),'outline':outline.tolist(),'images':[]}
    inputs=[Path(f'assets/sprites/arena/{name}/{f}.png') for f in FACING]
    inputs+=sorted(p.relative_to(S) for p in (S/DOC/'walk').glob(name+'_*_sheet.png'))
    for rel in inputs:
        a=np.array(Image.open(S/rel).convert('RGBA'));out=a.copy()
        iswalk=rel.name.endswith('_sheet.png');size=a.shape[0]//2 if iswalk else a.shape[0]
        records=[]
        for i in range(8 if iswalk else 1):
            y=i//4*size if iswalk else 0;x=i%4*size if iswalk else 0
            frame=a[y:y+size,x:x+size];premapped,count=jade(frame) if name=='oxbowarchon' else (frame,0)
            fixed,params=norm.normalize(premapped,palette,outline,target)
            if name=='slagglass' and iswalk:
                fixed,seams=orange_seams(fixed,palette);params['mid_dome_orange_seam_pixels']=seams
            if name=='sparkjab' and iswalk:
                fixed=refine_spark_game(premapped,fixed,params,palette,outline,target);params['current_085_scale_refinement']=True
            if name in ['preostmar','oathfen'] and iswalk:
                rgb=frame[...,:3].astype(float)
                mask=(frame[...,3]>0)&(norm.lum(rgb)>125)&(rgb[...,1]>=rgb[...,0]*.98)&(rgb[...,1]>=rgb[...,2]*.98)
                ramp=palette[(palette[:,1]>palette[:,0].astype(int)+8)&(palette[:,1]>palette[:,2].astype(int)+4)&(norm.lum(palette)<130)&(norm.lum(palette)>40)]
                fixed[mask,:3]=norm.nearest(rgb[mask]*.60,ramp)
                params['walk_pale_jade_pixels']=int(mask.sum())
            assert np.array_equal(fixed[...,3],frame[...,3]),str(rel)
            out[y:y+size,x:x+size]=fixed
            records.append({'frame':i,'jade_pixels':count,'before':norm.metrics(frame),'after':norm.metrics(fixed),'parameters':params})
        save(out,rel);row['images'].append({'path':rel.as_posix(),'frames':records})
    audit['forms'][name]=row
    (W/'candidate-audit.json').write_text(json.dumps(audit,indent=2),encoding='utf8')
    print(name,'completed',flush=True)
subprocess.run([sys.executable,str(C/'tools/arena/build_small.py'),*FORMS],cwd=C,check=True)
