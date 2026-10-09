from pathlib import Path
import hashlib, json, shutil, importlib.util, subprocess, sys
import numpy as np
from PIL import Image
L=Path('C:/Users/pmcga/dev/hollowtide');W=Path(__file__).parent
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
DOC=Path('docs/creatures/arena-starters-2026-10-07')
NAMES=['listener','caller','warden'];FACING='s se e ne n nw w sw'.split()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
# Refresh concurrent code and dependencies into the isolated review project only.
for folder in ['assets','data','scripts','scenes','tools']:
    for p in (L/folder).rglob('*'):
        if not p.is_file() or '__pycache__' in p.parts:continue
        dst=C/p.relative_to(L);dst.parent.mkdir(parents=True,exist_ok=True)
        if not dst.exists() or sha(p)!=sha(dst):shutil.copy2(p,dst)
for rel,digest in json.loads((W/'original-manifest.json').read_text()).items():
    assert sha(L/rel)==digest,'Concurrent source edit '+rel
    dst=C/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dst)
spec=importlib.util.spec_from_file_location('norm',C/'tools/arena/normalize_arena_palette.py');norm=importlib.util.module_from_spec(spec);spec.loader.exec_module(norm)
audit={'method':'Existing bounded own-base palette normalization; original geometry and alpha retained','forms':{},'files':[]}
for name in NAMES:
    base=np.array(Image.open(W/'originals'/DOC/'forms'/f'{name}_arena_front_take1.png').convert('RGBA'))
    palette,outline,target=norm.base_rules(base)
    row={'base_target':target,'palette':palette.tolist(),'images':[]}
    inputs=[Path(f'assets/sprites/arena/{name}/{f}.png') for f in FACING]
    inputs+=sorted(p.relative_to(W/'originals') for p in (W/'originals'/DOC/'walk').glob(name+'_*_sheet.png'))
    for rel in inputs:
        a=np.array(Image.open(W/'originals'/rel).convert('RGBA'));out=a.copy()
        walk=rel.name.endswith('_sheet.png');size=a.shape[0]//2 if walk else a.shape[0];records=[]
        for i in range(8 if walk else 1):
            y=i//4*size if walk else 0;x=i%4*size if walk else 0
            fr=a[y:y+size,x:x+size]
            fixed,params=norm.normalize(fr,palette,outline,target)
            assert np.array_equal(fixed[...,3],fr[...,3])
            out[y:y+size,x:x+size]=fixed
            records.append({'frame':i,'before':norm.metrics(fr),'after':norm.metrics(fixed),'parameters':params})
        Image.fromarray(out).save(C/rel)
        row['images'].append({'path':rel.as_posix(),'frames':records})
        audit['files'].append(rel.as_posix())
    audit['forms'][name]=row
    print(name,'normalized',flush=True)
subprocess.run([sys.executable,str(C/'tools/arena/build_small.py'),*NAMES],cwd=C,check=True)
for name in NAMES:audit['files']+=sorted(p.relative_to(C).as_posix() for p in (C/f'assets/sprites/arena/{name}/small').glob('*.png'))
audit['candidate_hashes']={rel:sha(C/rel) for rel in audit['files']}
(W/'candidate-audit.json').write_text(json.dumps(audit,indent=2))
print(len(audit['files']),'candidate paths')
