"""Candidate-only native preparation; generated raw and all production art remain untouched."""
import json,hashlib
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[4]
B=Path(__file__).resolve().parent
raw=Image.open(B/'raw.png').convert('RGBA')
a=np.array(raw);mask=a[:,:,3]>=128
bbox=Image.fromarray(mask).getbbox()
cut=raw.crop(bbox)
k=min(184/cut.width,166/cut.height)
nw,nh=round(cut.width*k),round(cut.height*k)
small=cut.convert('RGBa').resize((nw,nh),Image.Resampling.BOX).convert('RGBA')
a=np.array(small);a[:,:,3]=np.where(a[:,:,3]>=128,255,0)
a[a[:,:,3]==0,:3]=0
src=ROOT/'assets/sprites/arena/riftfin/sw.png'
s=np.array(Image.open(src).convert('RGBA'))
pal=np.unique(s[s[:,:,3]>0,:3],axis=0)
m=a[:,:,3]>0
rgb=a[m,:3].astype(int)
a[m,:3]=pal[((rgb[:,None,:]-pal[None,:,:].astype(int))**2).sum(-1).argmin(1)]
x=(224-nw)//2;y=195-nh+1
out=Image.new('RGBA',(224,224));out.alpha_composite(Image.fromarray(a),(x,y))
out.save(B/'prepared.png')
arr=np.array(out);ob=out.getchannel('A').getbbox()
boxes=[Image.open(f).convert('RGBA').getchannel('A').getbbox() for f in (ROOT/'assets/sprites/creatures/idle_2026_10_05/001_rimefin').glob('f[0-7].png')]
old=[min(b[0] for b in boxes),min(b[1] for b in boxes),max(b[2] for b in boxes),max(b[3] for b in boxes)]
old_h=old[3]-old[1];new_h=ob[3]-ob[1]
cols=np.unique(arr[arr[:,:,3]>0,:3],axis=0)
used=set(map(tuple,cols.tolist()));allowed=set(map(tuple,pal.tolist()))
checks={'size_224x224':out.size==(224,224),'alpha_binary':set(np.unique(arr[:,:,3]))<={0,255},'uses_current_riftfin_palette':used<=allowed,'all_sides_clear':ob[0]>0 and ob[1]>0 and ob[2]<224 and ob[3]<224,'taller_than_rimefin_idle_union':new_h>=old_h,'same_two_x_scale':min(3,max(1,int(380/max(old_h,new_h))))==2,'raw_preserved':hashlib.sha256((B/'raw.png').read_bytes()).hexdigest()==hashlib.sha256(Path(r'C:/Users/pmcga/.codex/generated_images/01a12b4b-7982-7b32-b405-2a584762f412/exec-00356d3a-62e4-4035-90fe-85b24ff15166.png').read_bytes()).hexdigest()}
report={'pass':all(checks.values()),'checks':{a:bool(v) for a,v in checks.items()},'raw_size':list(raw.size),'raw_solid_box':list(bbox),'native_size':[224,224],'native_opaque_box':list(ob),'source_palette':str(src.relative_to(ROOT)).replace('\\','/'),'palette_colours':len(pal),'candidate_colours':len(cols),'rimefin_idle_union':old,'old_height':old_h,'new_height':new_h,'candidate_scale':2,'on_screen_heights':[old_h*2,new_h*2],'frames':1,'animation':False,'approval':'pending','installed':False}
assert report['pass'],report
(B/'checks.json').write_text(json.dumps(report,indent=2)+'\n')
background=Image.new('RGBA',out.size,(35,43,40,255));background.alpha_composite(out)
background.resize((672,672),Image.Resampling.NEAREST).convert('RGB').save(B/'preview-3x.png')
print(json.dumps(report))