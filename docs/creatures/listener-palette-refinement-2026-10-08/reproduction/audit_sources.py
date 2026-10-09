from pathlib import Path
import hashlib, json, shutil, importlib.util
import numpy as np
from PIL import Image
L=Path('C:/Users/pmcga/dev/hollowtide')
W=Path(__file__).parent
DOC=Path('docs/creatures/arena-starters-2026-10-07')
NAMES=['listener','caller','warden']
spec=importlib.util.spec_from_file_location('norm',L/'tools/arena/normalize_arena_palette.py'); norm=importlib.util.module_from_spec(spec);spec.loader.exec_module(norm)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
records={}; manifest={}
for name in NAMES:
    base=DOC/'forms'/f'{name}_arena_front_take1.png'
    files=[base,DOC/'forms'/f'{name}_arena_rotation_3x3.png',*sorted(p.relative_to(L) for p in (L/'assets/sprites/arena'/name).rglob('*.png')),*sorted(p.relative_to(L) for p in (L/DOC/'walk').glob(f'{name}_*_sheet.png'))]
    for rel in files:
        dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True)
        if not dest.exists():shutil.copy2(L/rel,dest)
        assert sha(dest)==sha(L/rel)
        manifest[rel.as_posix()]=sha(L/rel)
    a=np.array(Image.open(L/base).convert('RGBA'));p,o,t=norm.base_rules(a)
    row={'base':t,'palette':p.tolist(),'stills':{},'walks':{}}
    for f in 's se e ne n nw w sw'.split():row['stills'][f]=norm.metrics(np.array(Image.open(L/f'assets/sprites/arena/{name}/{f}.png').convert('RGBA')))
    for f in 's se e ne n'.split():
        a=np.array(Image.open(L/DOC/'walk'/f'{name}_{f}_sheet.png').convert('RGBA'));z=a.shape[0]//2
        row['walks'][f]=[norm.metrics(a[i//4*z:(i//4+1)*z,i%4*z:(i%4+1)*z]) for i in range(8)]
    records[name]=row
    print(name,'base',t)
    print('still brightness',[(f,m['brightness']) for f,m in row['stills'].items()])
    print('walk brightness',[(f,round(min(m['brightness'] for m in ms),1),round(max(m['brightness'] for m in ms),1)) for f,ms in row['walks'].items()])
    print('palette',p.tolist())
(W/'original-manifest.json').write_text(json.dumps(manifest,indent=2))
(W/'inspection.json').write_text(json.dumps(records,indent=2))
print('Backed up',len(manifest),'files')
