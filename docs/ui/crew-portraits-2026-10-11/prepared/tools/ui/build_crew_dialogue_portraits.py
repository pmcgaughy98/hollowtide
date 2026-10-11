"""Six crew normal portraits from Preston's current chosen fronts (2026-10-11).

Same square head crops, 40px palette-locked resample and outline_portrait rule as
build_dialogue_portraits.py. Chosen fronts are excluded from recolor_creature.files;
apply each existing crew scheme to a copy before cutting, as for the town idles.
No generated/redrawn faces. Original source files are never written.

python tools/ui/build_crew_dialogue_portraits.py --output-dir <dir> --evidence-dir <dir>
"""
from pathlib import Path
import argparse,hashlib,json,sys,shutil
import numpy as np
from PIL import Image,ImageDraw

SIZE=40
CROPS={
    'grubbit':(22,4,76,58),
    'stillwade':(44,9,102,67),
    'wickglow':(20,32,78,90),
    'muskin':(32,6,80,54),
    'slipjaw':(28,8,76,56),
    'rinsepaw':(30,6,84,60),
}

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def build(project: Path,output: Path,evidence: Path):
    sys.path.insert(0,str(project/'tools/arena'))
    sys.path.insert(0,str(project/'tools/ui'))
    from downscale import resample
    from recolor_creature import recolor,SCHEMES
    import outline_portrait as edges
    output.mkdir(parents=True,exist_ok=True)
    evidence.mkdir(parents=True,exist_ok=True)
    edges.BACK=str(evidence/'before_outline')+'/'
    manifest=[]
    sheet=Image.new('RGB',(6*190,224),'#242923');draw=ImageDraw.Draw(sheet)
    for k,(form,box) in enumerate(CROPS.items()):
        rel=f'docs/creatures/arena-starters-2026-10-07/forms/{form}_arena_front_chosen.png'
        src=project/rel;source_hash=sha(src)
        dst=output/(form+'.png')
        if dst.exists():raise FileExistsError(f'Inspect and snapshot the existing portrait before rebuilding: {dst}')
        source=Image.open(src).convert('RGBA')
        scheme=SCHEMES[form]
        colour=recolor(source,scheme['rule'],scheme.get('accent'))
        assert np.array_equal(np.array(source)[...,3],np.array(colour)[...,3])
        assert box[2]-box[0]==box[3]-box[1]
        cut=colour.crop(box)
        portrait=resample(cut,cut.width/SIZE).resize((SIZE,SIZE),Image.Resampling.NEAREST)
        assert portrait.size==(SIZE,SIZE)
        portrait.save(dst)
        # Reuse the exact existing outline algorithm; choose its line colour from
        # an absolute current south-facing sprite so invocation cwd is irrelevant.
        sprite=np.array(Image.open(project/f'assets/sprites/arena/{form}/s.png').convert('RGBA')).astype(int)
        px=sprite[sprite[...,3]>0][:,:3]
        line=tuple(int(v) for v in px[np.argmin(edges.luma(px))])
        outlined=edges.outline(str(dst),line)
        final=Image.open(dst).convert('RGBA');a=np.array(final);before=np.array(portrait)
        assert np.array_equal(a[...,3],before[...,3])
        assert set(np.unique(a[...,3])).issubset({0,255})
        padding=np.pad(before[...,3]>0,1,constant_values=True)
        edge=(before[...,3]>0)&~(padding[:-2,1:-1]&padding[2:,1:-1]&padding[1:-1,:-2]&padding[1:-1,2:])
        assert np.array_equal(a[~edge],before[~edge]),'Only the transparency boundary may change.'
        assert sha(src)==source_hash
        for name,img in [('recoloured_source',colour),('crop',cut)]:
            p=evidence/name/(form+'.png');p.parent.mkdir(parents=True,exist_ok=True);img.save(p)
        x=k*190+15
        bg=Image.new('RGBA',(40,40),'#94cfc6');bg.alpha_composite(final)
        sheet.paste(bg.resize((160,160),Image.Resampling.NEAREST),(x,12))
        draw.text((x,182),form,fill='#fff4e8')
        draw.text((x,198),str(box),fill='#b9c2b3')
        manifest.append({'form':form,'source':rel,'source_sha256':source_hash,'source_size':list(source.size),'crop':list(box),'output':f'assets/sprites/ui/dialogue/{form}.png','output_sha256':sha(dst),'size':[40,40],'bbox':list(final.getbbox()),'line_colour':list(line),'outline_pixels':outlined,'source_recolour_scheme':form,'alpha_exact_after_outline':True,'outside_transparency_edge_exact':True})
    sheet.save(evidence/'review_sheet.png')
    (evidence/'manifest.json').write_text(json.dumps(manifest,indent=2))
    return manifest

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project-root',type=Path,default=Path(__file__).resolve().parents[2])
    parser.add_argument('--output-dir',type=Path,required=True)
    parser.add_argument('--evidence-dir',type=Path,required=True)
    args=parser.parse_args()
    rows=build(args.project_root,args.output_dir,args.evidence_dir)
    print(json.dumps(rows,indent=2));print('Six 40px normal crew portraits prepared.')
