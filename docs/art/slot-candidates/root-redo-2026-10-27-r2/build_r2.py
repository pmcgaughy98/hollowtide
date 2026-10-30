from pathlib import Path
import sys,json,subprocess,os,shutil
import numpy as np
from PIL import Image
sys.dont_write_bytecode=True
R=Path(__file__).parent;ROOT=R.parents[3];C=R.parent;sys.path.insert(0,str(ROOT/'tools/art'));import slot_registry as reg
reg.SLOTS_JSON=R/'slots.json';meta=json.loads((R/'contract-source.json').read_text(encoding='utf-8'));source=R/meta['folder'];reg.SLOT_DIR=source/'slots';reg.LOADER=source/'art_slots.gd';reg.load()
def tool(name,args,log):
 p=subprocess.run([sys.executable,'-B',str(R/'with_contract.py'),name,*map(str,args)],env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),capture_output=True,text=True);log.write_text(p.stdout+p.stderr,encoding='utf-8')
 if p.returncode not in (0,1):raise RuntimeError(p.stdout+p.stderr)
 return p.returncode

def build(sid):
 d=R/sid;s=reg.spec(sid);w,h=s['size'];old=np.array(Image.open(d/'input-before.png').convert('RGBA'));raw=Image.open(d/'raw.png').convert('RGBA');bb=raw.getchannel('A').point(lambda v:255 if v>=128 else 0).getbbox();assert bb;tb=Image.fromarray(old).getchannel('A').getbbox();receipt={'authorization':'Preston go; native Python pixel cleanup already explicitly authorized','raw_untouched':True,'geometry_contract':s['size']}
 tool('prepare_slot.py',[sid,d/'raw.png',d/'prepared-from-raw.png'],d/'prepare-raw.log');tool('validate_slot.py',[sid,d/'prepared-from-raw.png'],d/'validate-raw.log')
 if sid.endswith('root_foot'):
  small=raw.crop(bb).convert('RGBa').resize((w,117),Image.Resampling.BOX).convert('RGBA');im=Image.new('RGBA',(w,h));im.alpha_composite(small,(0,3));a=np.array(im);a[:,:,3]=np.where(a[:,:,3]>=128,255,0);yy,xx=np.indices((h,w));edit=(xx>=5)&(xx<54)&(yy>=65)&(yy<=113)&~((xx>=44)&(yy>=104));a[~edit]=old[~edit];protect=~edit
  distance=np.minimum.reduce([xx-5,53-xx,yy-65,113-yy]);blend=edit&(distance<=1)&(a[:,:,3]>0)&(old[:,:,3]>0)
  a[blend,:3]=((a[blend,:3].astype(int)+old[blend,:3].astype(int)*2)//3).astype(np.uint8);receipt['protected']='west5columns, upper diagonal/join, secondary leg and baseline byte exact';receipt['west_woody_rows']=[72,110]
 else:
  small=raw.crop(bb).convert('RGBa').resize((w,tb[3]-tb[1]),Image.Resampling.BOX).convert('RGBA');im=Image.new('RGBA',(w,h));im.alpha_composite(small,(0,tb[1]));a=np.array(im);m=old[:,:,3]>0;allowed=np.zeros_like(m)
  for dx in range(-6,7):
   moved=np.roll(m,dx,axis=1)
   if dx<0:moved[:,dx:]=False
   if dx>0:moved[:,:dx]=False
   allowed|=moved
  mnew=(a[:,:,3]>=128)&allowed;a[:,:,3]=np.where(mnew,255,0);wall=np.array(Image.open(R/'masonry-without-vein.png').convert('RGBA'));protect=np.zeros_like(m);barkold=(old[:,:,0]>old[:,:,1]*1.23)&(old[:,:,3]>0);corridor=np.zeros_like(m);centres=[]
  for y in range(h):
   xs=np.flatnonzero(barkold[y]);
   if not len(xs):continue
   centre=int(np.median(xs));half=4+round(4*y/(h-1));left=max(0,centre-half);right=min(w,centre+half+1);corridor[y,left:right]=True;core=np.zeros(w,bool);core[max(0,centre-3):min(w,centre+4)]=True;core&=m[y];a[y,core]=old[y,core];protect[y,core]=True;centres.append([y,centre])
  brown=(a[:,:,0]>a[:,:,1]*1.23)&(a[:,:,3]>0)&~corridor;stone_palette=np.array([[245,217,168],[230,198,151],[204,178,144],[156,140,104],[95,94,87]],dtype=np.uint8)
  for y,x in zip(*np.nonzero(brown)):
   samples=[]
   for sx in range(max(0,x+24-5),min(wall.shape[1],x+24+22)):
    v=wall[y+24,sx];
    if v[3] and v[0]<=v[1]*1.23 and v[:3].mean()>75:samples.append((abs(sx-(x+24)),v[:3]))
   a[y,x,:3]=min(samples,key=lambda z:z[0])[1] if samples else stone_palette[1 if x<30 else 3]
  # Keep the horizontal run interruptions; any added shoulder stays within the existing 60px slot.
  a[:,:,3]=np.where((a[:,:,3]>0)&allowed,255,0);missing=m.any(1)&~(a[:,:,3]>0).any(1);a[missing]=old[missing];protect[missing]=m[missing];receipt['restored_run_rows']=np.flatnonzero(missing).tolist();receipt['stone_shoulder_expansion_limit_px']=6;receipt['woody_centerline_seeds']=centres;receipt['protected_core']='existing central7pixels where present, preserving path and treads';receipt['window_clearance']='frame x80..139; nearest drum window begins x144'
 a[a[:,:,3]==0,:3]=0;m=a[:,:,3]>0;pal=np.array(reg.palette(s),dtype=np.int32);px=a[m,:3].astype(int)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 co,ct=np.unique(px,axis=0,return_counts=True);chosen=[v.tolist() for v in np.unique(old[old[:,:,3]>0,:3],axis=0)]
 for v in [co[i].tolist() for i in np.argsort(-ct)]:
  if v not in chosen:chosen.append(v)
  if len(chosen)>=32:break
 pal=np.array(chosen,dtype=np.int32)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 a[m,:3]=px.astype(np.uint8);repaired=0
 for y in range(h):
  for x in range(w):
   if not a[y,x,3] or protect[y,x]:continue
   near=[(ny,nx) for ny,nx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=ny<h and 0<=nx<w and a[ny,nx,3]]
   if not near or any(np.array_equal(a[y,x,:3],a[ny,nx,:3]) for ny,nx in near):continue
   def score(pos):
    ny,nx=pos;v=a[ny,nx,:3];count=sum(0<=ay<h and 0<=ax<w and a[ay,ax,3] and np.array_equal(a[ay,ax,:3],v) for ay,ax in ((ny-1,nx),(ny,nx-1),(ny+1,nx),(ny,nx+1)))
    return(count,-int(((v.astype(int)-a[y,x,:3].astype(int))**2).sum()))
   ny,nx=max(near,key=score);a[y,x,:3]=a[ny,nx,:3];repaired+=1
 assert np.array_equal(a[protect],old[protect]),'protected source pixels changed';Image.fromarray(a).save(d/'native_input.png');tool('prepare_slot.py',[sid,d/'native_input.png',d/'prepared.png'],d/'prepare_slot.py.log')
 actual=np.array(Image.open(d/'prepared.png').convert('RGBA'))
 if not np.array_equal(actual,a):shutil.copy2(d/'prepared.png',d/'prepared-before-registration-restore.png');Image.fromarray(a).save(d/'prepared.png');receipt['post_prepare_registration']='restored authored native registration after bounding-box recenter; final bytes validated'
 tool('validate_slot.py',[sid,d/'prepared.png'],d/'validate_slot.py.log');receipt['colour_joins']=repaired;receipt['protected_rgba_exact']=True;(d/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');Image.fromarray(a).resize((w*4,h*4),Image.Resampling.NEAREST).save(d/'preview-4x.png');report=json.loads((d/'prepared.png.check.json').read_text(encoding='utf-8'));print(sid,report['pass'],[(v['id'],v['result'],v['detail']) for v in report['results'] if v['result']!='PASS'],flush=True)
if __name__=='__main__':
 for sid in ['town.building.hall.root_foot','town.building.hall.root_vein']:build(sid)
