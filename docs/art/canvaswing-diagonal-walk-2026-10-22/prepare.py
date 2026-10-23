from pathlib import Path
import json,hashlib,shutil,sys,subprocess
import numpy as np
from PIL import Image,ImageOps,ImageDraw
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'project';P.mkdir(exist_ok=True)
G=Path('C:/Users/pmcga/.codex/generated_images/01a12b4b-7982-7b32-b405-2a584762f412/exec-6c4be28b-3113-4810-b959-631f96a01b24.png')
source='docs/creatures/arena-starters-2026-10-07/walk';art='assets/sprites/arena/canvaswing'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
protected={}
for folder in ['scripts','scenes','data','dialogue','tools/arena','assets/sprites/arena/canvaswing',source]:
    for p in (R/folder).rglob('*'):
        if p.is_file() and p.suffix!='.pyc':protected[p.relative_to(R).as_posix()]=sha(p)
(W/'protected-before.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
(W/'originals'/art).mkdir(parents=True)
shutil.copytree(R/art,P/art);shutil.copytree(R/art,W/'originals'/art,dirs_exist_ok=True)
for path in [source,'tools/arena']:
    shutil.copytree(R/path,P/path)
for rel in ['scripts/arena/arena_prototype.gd']:
    dest=P/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dest)
shutil.copy2(G,W/'generated-raw.png')
original=Image.open(R/source/'canvaswing_se_sheet.png').convert('RGBA');generated=Image.open(G).convert('RGBA');assert generated.width==2*generated.height
size=128;cw=generated.width//4;ch=generated.height//2
palette=np.unique(np.array(original.crop((0,0,384,128)))[np.array(original.crop((0,0,384,128)))[...,3]>0][:,:3],axis=0).astype(int)
after=np.array(original).copy();stats=[]
for i in range(3,8):
    cell=generated.crop((i%4*cw,i//4*ch,(i%4+1)*cw,(i//4+1)*ch))
    a=np.array(cell.resize((size,size),Image.Resampling.LANCZOS)).astype(int);opaque=a[...,3]>=128;rgb=a[opaque,:3];distance=(rgb[:,None,:]-palette[None,:,:])**2
    score=distance[:,:,0]*2+distance[:,:,1]*4+distance[:,:,2]*3;out=np.zeros((size,size,4),np.uint8);out[opaque,:3]=palette[score.argmin(axis=1)];out[opaque,3]=255
    after[i//4*size:(i//4+1)*size,i%4*size:(i%4+1)*size]=out
    im=Image.fromarray(out);box=im.getbbox();stats.append({'frame':i,'generated_cell':[i%4*cw,i//4*ch,cw,ch],'bbox':box,'pixels':int(opaque.sum()),'colors':len(np.unique(out[opaque,:3],axis=0))})
Image.fromarray(after).save(P/source/'canvaswing_se_sheet.png')
for i in range(3):assert np.array_equal(after[:128,i*128:(i+1)*128],np.array(original)[:128,i*128:(i+1)*128])
(W/'preparation.json').write_text(json.dumps({'generated_size':generated.size,'source_cell':128,'existing_palette_colors':len(palette),'new_frames':stats,'first_three_exact':True,'method':'crop generated 4x2 cells, Lanczos native-grid reduction, alpha>=128, existing 26-colour redmean palette; first three original cells copied exactly'},indent=2),encoding='utf-8')
print(json.dumps(stats),flush=True)
