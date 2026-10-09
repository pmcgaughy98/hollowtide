from pathlib import Path
import sys,json,hashlib,importlib.util
import numpy as np
from PIL import Image,ImageOps
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project');O=W/'originals'
DOC=Path('docs/creatures/arena-starters-2026-10-07')
sys.path.insert(0,str(C/'tools/arena'))
from downscale import resample,shrink
spec=importlib.util.spec_from_file_location('norm',C/'tools/arena/normalize_arena_palette.py');norm=importlib.util.module_from_spec(spec);spec.loader.exec_module(norm)
audit=json.loads((W/'candidate-audit.json').read_text());report={'images':[],'forms':{},'pipeline_comparisons':0}
for rel in audit['files']:
    before=np.array(Image.open(O/rel).convert('RGBA'));after=np.array(Image.open(C/rel).convert('RGBA'))
    assert before.shape==after.shape and np.array_equal(before[...,3],after[...,3]),rel
    name=next(n for n in audit['forms'] if n in Path(rel).parts or Path(rel).name.startswith(n+'_'))
    palette=set(map(tuple,audit['forms'][name]['palette']))
    on=after[...,3]>0
    assert set(map(tuple,after[on,:3])).issubset(palette),rel
    report['images'].append({'path':rel,'same_alpha_canvas':True,'own_palette_only':True,'changed_rgb_pixels':int(np.any(before[...,:3]!=after[...,:3],axis=-1).sum())})
for name,scale in [('listener',.95),('caller',1.),('warden',1.1)]:
    small=lambda im:shrink(im,3) if scale==1 else resample(im,3/scale)
    dest=C/f'assets/sprites/arena/{name}/small'
    for f in 's se e ne n nw w sw'.split():
        src=Image.open(C/f'assets/sprites/arena/{name}/{f}.png').convert('RGBA')
        assert small(src).tobytes()==Image.open(dest/f'{f}.png').convert('RGBA').tobytes()
        report['pipeline_comparisons']+=1
    cycles={};brightness={'before':[],'after':[]}
    for f in 's se e ne n'.split():
        sheet=Image.open(C/DOC/'walk'/f'{name}_{f}_sheet.png').convert('RGBA');cw=sheet.height//2;distinct=set()
        cell=Image.open(C/f'assets/sprites/arena/{name}/{f}.png').size
        for i in range(8):
            fr=sheet.crop((i%4*cw,i//4*cw,(i%4+1)*cw,(i//4+1)*cw))
            if fr.size!=cell:fr=fr.resize(cell,Image.Resampling.NEAREST)
            assert small(fr).tobytes()==Image.open(dest/f'walk_{f}_f{i}.png').convert('RGBA').tobytes()
            report['pipeline_comparisons']+=1
            distinct.add(Image.open(dest/f'walk_{f}_f{i}.png').tobytes())
            for state,root in [('before',O),('after',C)]:
                brightness[state].append(norm.metrics(np.array(Image.open(root/f'assets/sprites/arena/{name}/small/walk_{f}_f{i}.png').convert('RGBA')))['brightness'])
        cycles[f]=len(distinct)
    for src,dst in [('e','w'),('se','sw'),('ne','nw')]:
        for i in range(8):
            assert ImageOps.mirror(Image.open(dest/f'walk_{src}_f{i}.png')).tobytes()==Image.open(dest/f'walk_{dst}_f{i}.png').tobytes()
            report['pipeline_comparisons']+=1
    report['forms'][name]={'distinct_walk_frames':cycles,'game_walk_brightness':{k:{'min':min(v),'max':max(v),'std':float(np.std(v))} for k,v in brightness.items()},'palette_colors':len(audit['forms'][name]['palette'])}
(W/'asset-audit.json').write_text(json.dumps(report,indent=2))
print('Exact alpha/palette checks:',len(report['images']),'pipeline comparisons:',report['pipeline_comparisons'])
print(json.dumps(report['forms'],indent=2))
