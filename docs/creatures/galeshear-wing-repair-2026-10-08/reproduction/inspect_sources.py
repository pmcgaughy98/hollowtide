from pathlib import Path
from collections import deque
import json,hashlib,shutil
import numpy as np
from PIL import Image
ROOT=Path(__file__).parent
LIVE=Path('C:/Users/pmcga/dev/hollowtide')
GEN=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188')
sources={'rotation':'14fee1c9-b56f-4fb3-b401-24ff0819054a','se':'19d887b7-e5b5-438a-aaac-99f4b41a3108','n':'ea7ec7ff-1ee1-4f7e-a484-1cd52eccc182','s':'1417a4da-8fe4-4cc7-997f-e192266ddc3f','e':'215add46-875a-4d08-a57a-ae5af1c6481a','ne':'f465b0fd-a3ff-4734-b0d7-0ca37f5ae918'}
originals=list((LIVE/'assets/sprites/arena/galeshear').rglob('*.png'))
originals+=list((LIVE/'docs/creatures/arena-starters-2026-10-07/walk').glob('galeshear_*_sheet.png'))
originals+=[LIVE/'docs/creatures/arena-starters-2026-10-07/forms/galeshear_arena_rotation_3x3.png']
manifest=[]
for p in originals:
    relative=p.relative_to(LIVE)
    dest=ROOT/'originals'/relative
    dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(p,dest)
    manifest.append({'path':relative.as_posix(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(ROOT/'originals.json').write_text(json.dumps(manifest,indent=2))
records={}
for name,uid in sources.items():
    p=GEN/('exec-'+uid+'.png')
    dest=ROOT/'generated'/f'{name}.png'
    dest.parent.mkdir(exist_ok=True)
    shutil.copy2(p,dest)
    a=np.asarray(Image.open(p).convert('RGBA'))
    mask=(a[:,:,3]>=128).copy()
    h,w=mask.shape
    parts=[]
    for y,x in zip(*np.where(mask)):
        if not mask[y,x]: continue
        mask[y,x]=False
        q=deque([(int(x),int(y))]); xmin=xmax=int(x);ymin=ymax=int(y);n=0
        while q:
            xx,yy=q.popleft();n+=1
            xmin=min(xmin,xx);xmax=max(xmax,xx);ymin=min(ymin,yy);ymax=max(ymax,yy)
            for nx,ny in [(xx-1,yy),(xx+1,yy),(xx,yy-1),(xx,yy+1)]:
                if 0<=nx<w and 0<=ny<h and mask[ny,nx]:mask[ny,nx]=False;q.append((nx,ny))
        if n>500: parts.append({'bounds':[xmin,ymin,xmax-xmin+1,ymax-ymin+1],'pixels':n,'touches_edge':xmin==0 or ymin==0 or xmax==w-1 or ymax==h-1})
    rows=3 if name=='rotation' else 2
    cols=3 if name=='rotation' else 4
    parts.sort(key=lambda c:(round((c['bounds'][1]+c['bounds'][3]*.5)/h*rows-.5),c['bounds'][0]+c['bounds'][2]*.5))
    records[name]={'path':str(dest).replace('\\','/'),'dimensions':[w,h],'components':parts}
    print(name,len(parts),[(c['bounds'],c['touches_edge']) for c in parts])
(ROOT/'components.json').write_text(json.dumps(records,indent=2))
