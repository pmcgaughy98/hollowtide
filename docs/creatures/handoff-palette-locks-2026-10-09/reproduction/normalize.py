from pathlib import Path
import importlib.util,json,sys,time,subprocess
import numpy as np
from PIL import Image
W=Path(__file__).parent;O=W/'originals';P=W/'candidate';DOC=Path('docs/creatures/arena-starters-2026-10-07');FORMS=['dustkite','waywhistle','highsignal','riftfin','scourmaw'];FACINGS='s se e ne n nw w sw'.split()
spec=importlib.util.spec_from_file_location('norm',P/'tools/arena/normalize_arena_palette.py');norm=importlib.util.module_from_spec(spec);spec.loader.exec_module(norm)
audit={'method':'existing exact own-reference redmean palette normalizer, unmodified; named-only unchanged arena and dungeon builders','forms':{}}
for name in FORMS:
    base=np.array(Image.open(O/DOC/'forms'/f'{name}_arena_front_take1.png').convert('RGBA'))
    palette,outline,target=norm.base_rules(base);row={'reference':(DOC/'forms'/f'{name}_arena_front_take1.png').as_posix(),'reference_metrics':target,'palette':palette.tolist(),'records':[]}
    files=[Path(f'assets/sprites/arena/{name}/{f}.png') for f in FACINGS]+[DOC/'walk'/f'{name}_{f}_sheet.png' for f in 's se e ne n'.split()]
    for rel in files:
        a=np.array(Image.open(O/rel).convert('RGBA'));b=a.copy();walk=rel.name.endswith('_sheet.png');cell=a.shape[0]//2 if walk else a.shape[0]
        for i in range(8 if walk else 1):
            y=i//4*cell if walk else 0;x=i%4*cell if walk else 0;fr=a[y:y+cell,x:x+cell]
            assert ((fr[...,3]==0)|(fr[...,3]==255)).all(),'Partial alpha requires review: '+str(rel)
            fixed,params=norm.normalize(fr,palette,outline,target)
            assert np.array_equal(fixed[...,3],fr[...,3]),str(rel)
            assert np.array_equal(fixed[fr[...,3]==0],fr[fr[...,3]==0]),'Transparent RGBA changed'
            b[y:y+cell,x:x+cell]=fixed
            row['records'].append({'path':rel.as_posix(),'frame':i,'before':norm.metrics(fr),'after':norm.metrics(fixed),'parameters':params})
        dst=P/rel;dst.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(b).save(dst)
        print(name,rel.name,'done',flush=True)
    audit['forms'][name]=row;(W/'candidate-audit.json').write_text(json.dumps(audit,indent=2))
for builder in ['build_small.py','build_dungeon_set.py']:
    subprocess.run([sys.executable,str(P/'tools/arena'/builder),*FORMS],cwd=P,check=True)
print('Both sprite sets rebuilt; sources remain exact in originals',flush=True)
