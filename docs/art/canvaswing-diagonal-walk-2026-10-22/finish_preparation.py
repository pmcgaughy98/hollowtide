from pathlib import Path
import json
import numpy as np
from PIL import Image
W=Path(__file__).parent;P=W/'project';R=Path('C:/Users/pmcga/dev/hollowtide');source='docs/creatures/arena-starters-2026-10-07/walk/canvaswing_se_sheet.png'
original=Image.open(R/source).convert('RGBA');generated=Image.open(W/'generated-raw.png').convert('RGBA');cw=generated.width//4;ch=generated.height//2
o=np.array(original);good=o[:128,:384];palette=np.unique(good[good[...,3]>0][:,:3],axis=0).astype(int);after=o.copy();stats=[]
for i in range(3,8):
    cell=generated.crop((i%4*cw,i//4*ch,(i%4+1)*cw,(i//4+1)*ch));a=np.array(cell.resize((128,128),Image.Resampling.LANCZOS)).astype(int);opaque=a[...,3]>=128;rgb=a[opaque,:3];distance=(rgb[:,None,:]-palette[None,:,:])**2
    score=distance[:,:,0]*2+distance[:,:,1]*4+distance[:,:,2]*3;out=np.zeros((128,128,4),np.uint8);out[opaque,:3]=palette[score.argmin(axis=1)];out[opaque,3]=255
    after[i//4*128:(i//4+1)*128,i%4*128:(i%4+1)*128]=out;im=Image.fromarray(out);box=im.getbbox();assert 0<box[0]<box[2]<128 and 0<box[1]<box[3]<128
    stats.append({'frame':i,'generated_cell':[i%4*cw,i//4*ch,cw,ch],'bbox':box,'pixels':int(opaque.sum()),'colors':len(np.unique(out[opaque,:3],axis=0))})
assert np.array_equal(after[:128,:384],o[:128,:384]);Image.fromarray(after).save(P/source)
(W/'preparation.json').write_text(json.dumps({'generated_size':generated.size,'source_cell':128,'existing_palette_colors':len(palette),'new_frames':stats,'first_three_exact':True,'method':'crop generated 4x2 cells, Lanczos native-grid reduction, alpha>=128, existing palette redmean lock; original f0-f2 copied exactly'},indent=2),encoding='utf-8');print(json.dumps(stats),flush=True)
