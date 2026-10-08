"""Add source-palette drift and visually reviewed anomaly annotations to original audit."""
from pathlib import Path
import json, collections, sys
import numpy as np
from PIL import Image, ImageOps
W=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-vitrecrag-consistency-2026-10-07/source-audit')
P=W/'originals'; records=json.loads((W/'before-metrics.json').read_text())
basepal={}
for r in records:
 if r['kind']=='base':
  a=np.array(Image.open(P/r['path']).convert('RGBA')); basepal[r['form']]={tuple(c) for c in a[:,:,:3][a[:,:,3]>0]}
results=[]
for r in records:
 p=P/r['path']; im=Image.open(p).convert('RGBA')
 if r['kind']=='walk_full':
  cw=im.height//2; i=r['frame']; im=im.crop(((i%4)*cw,(i//4)*cw,(i%4+1)*cw,(i//4+1)*cw))
 a=np.array(im); on=a[:,:,3]>0; cols=collections.Counter(map(tuple,a[:,:,:3][on])); pal=basepal[r['form']]
 unsupported=sum(n for c,n in cols.items() if c not in pal)
 rgb=a[:,:,:3].astype(int); magenta=on&(rgb[:,:,0]>160)&(rgb[:,:,2]>120)&(rgb[:,:,1]<100)
 results.append({'form':r['form'],'kind':r['kind'],'facing':r['facing'],'frame':r['frame'],'path':r['path'],'out_of_base_palette_pixels':unsupported,'out_of_base_palette_pct':round(100*unsupported/max(1,on.sum()),3),'magenta_pixels':int(magenta.sum()),'magenta_coords_xy':[[int(x),int(y)] for y,x in zip(*np.nonzero(magenta))]})
(W/'palette-drift-and-magenta.json').write_text(json.dumps(results,indent=2))
print(json.dumps({'magenta_cases':[r for r in results if r['magenta_pixels']],'full_out_of_palette_by_form':{n:[r['out_of_base_palette_pct'] for r in results if r['form']==n and r['kind']=='full'] for n in basepal},'small_components':[{'form':r['form'],'kind':r['kind'],'facing':r['facing'],'frame':r['frame'],'small_components':r['small_components_8']} for r in records if r['small_components_8']]},indent=2))
