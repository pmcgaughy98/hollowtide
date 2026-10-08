"""Review-only Fusern shell classifier diagnostics. Never writes sprite assets.

The original bright source color also describes broad shell faces. Separate
thin network pixels from broad areas with binary opening, and isolate the
roof using its largest warm-color component so face/eye glow stays protected.
Outputs are advisory masks and labeled nearest-neighbor contact sheets only.
"""
from pathlib import Path
from PIL import Image, ImageFilter, ImageDraw
import numpy as np,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'source-audit/originals/assets/sprites/arena/fusern'
OUT=Path(__file__).resolve().parent
C=np.array([(231,113,39),(252,161,82),(218,116,60)])
def components(m):
 seen=np.zeros_like(m);groups=[];h,w=m.shape
 for y,x in zip(*np.nonzero(m)):
  if seen[y,x]:continue
  seen[y,x]=True;todo=[(int(y),int(x))];group=[]
  while todo:
   yy,xx=todo.pop();group.append((yy,xx))
   for dy in [-1,0,1]:
    for dx in [-1,0,1]:
     ny,nx=yy+dy,xx+dx
     if 0<=ny<h and 0<=nx<w and m[ny,nx] and not seen[ny,nx]:
      seen[ny,nx]=True;todo.append((ny,nx))
  groups.append(group)
 return sorted(groups,key=len,reverse=True)
def flat(a):
 bg=np.full(a.shape,255,dtype='uint8');bg[:,:,:3]=(45,53,57)
 solid=a[:,:,3]>0;bg[solid]=a[solid]
 return Image.fromarray(bg,'RGBA')
rows=[];records=[]
for f in ['e','ne','n','nw']:
 path=SOURCE/(f+'.png');a=np.asarray(Image.open(path).convert('RGBA'))
 m=(a[:,:,3]>0)&np.any(np.all(a[:,:,:3,None]==C.T[None,None,:,:],axis=2),axis=2)
 groups=components(m);shell=np.zeros_like(m)
 for y,x in groups[0]:shell[y,x]=True
 b=shell&np.all(a[:,:,:3]==C[1],axis=2)
 panels=[flat(a)];rec={'facing':f,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'shell':int(shell.sum()),'bright':int(b.sum()),'opening':{}}
 for k in [3,5,7]:
  wide=np.array(Image.fromarray(b.astype('uint8')*255).filter(ImageFilter.MinFilter(k)).filter(ImageFilter.MaxFilter(k)))>0
  thin=b&~wide
  overlay=np.array(flat(a));overlay[thin]=(255,42,42,255);overlay[b&wide]=(36,240,238,255)
  panels.append(Image.fromarray(overlay,'RGBA'))
  Image.fromarray(thin.astype('uint8')*255).save(OUT/f'fusern_{f}_thin_mortar_open{k}_advisory_mask.png')
  Image.fromarray((b&wide).astype('uint8')*255).save(OUT/f'fusern_{f}_broad_fill_open{k}_advisory_mask.png')
  rec['opening'][k]={'thin_count':int(thin.sum()),'broad_count':int((b&wide).sum())}
 Image.fromarray(shell.astype('uint8')*255).save(OUT/f'fusern_{f}_warm_roof_advisory_mask.png')
 records.append(rec);rows.append((f,panels))
sheet=Image.new('RGB',(4*512,4*544),(24,28,32));draw=ImageDraw.Draw(sheet)
for i,(f,panels) in enumerate(rows):
 for j,im in enumerate(panels):
  draw.text((j*512+8,i*544+6),f'{f.upper()} '+(['original','opening3','opening5','opening7'][j]),fill='white')
  sheet.paste(im.resize((512,512),Image.Resampling.NEAREST).convert('RGB'),(j*512,i*544+30))
sheet.save(OUT/'fusern_shell_thin_vs_broad_advisory4x.png')
(OUT/'fusern_shell_classifier_diagnostics.json').write_text(json.dumps({'review_only':True,'rule':'largest 8-connected component of exact three warm RGB classes; bright252 binary opening separates thin/red from broad/cyan','records':records},indent=2),encoding='utf-8')
print(json.dumps({'contact':str(OUT/'fusern_shell_thin_vs_broad_advisory4x.png'),'rows':len(rows),'masks':'advisory only'}))
