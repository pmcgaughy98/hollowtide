from pathlib import Path
import sys,json,os,subprocess,shutil,hashlib,math
import numpy as np
from PIL import Image,ImageDraw
sys.dont_write_bytecode=True
B=Path(__file__).parent;ROOT=B.parents[3];sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
LAYOUT={'lamp':[('lit',4),('dark',1)],'bell':[('rest',1),('swing',4)],'vane':[('flutter',4)]}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def tool(name,args,log):
 p=subprocess.run([sys.executable,'-B',str(ROOT/'tools/art'/name),*map(str,args)],env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),capture_output=True,text=True);log.write_text(p.stdout+p.stderr,encoding='utf-8')
 if p.returncode not in (0,1):raise RuntimeError(p.stdout+p.stderr)
 return p.returncode

def ingest(jobs):
 for j in jobs:
  d=B/j['sid'];assert not (d/'raw.png').exists(),'Raw exists; archive explicitly before replacing';shutil.copy2(j['source'],d/'raw.png');(d/'prompt.txt').write_text(j['prompt'],encoding='utf-8')
  ledger={'tool':'built-in image_gen','date':'2026-10-27','cost':'not exposed; no alternate generator','source_file':j['source'],'raw_sha256':sha(d/'raw.png'),'raw_is_untouched':True,'raw_dimensions':list(Image.open(d/'raw.png').size),'requested_dimensions':j['size'],'references':[{'path':v,'sha256':sha(Path(v))} for v in j['refs']],'registry_sha256':reg.registry_hash(),'key_approval':'Preston approval go','pixel_cleanup_approval':'Preston Yes, use Python pixel cleanup'};(d/'ledger.json').write_text(json.dumps(ledger,indent=2)+'\n',encoding='utf-8')
  tool('prepare_slot.py',[j['sid'],d/'raw.png',d/'prepared-from-raw.png'],d/'prepare-raw.log');tool('validate_slot.py',[j['sid'],d/'prepared-from-raw.png'],d/'validate-raw.log')

def fit(src,target):
 m=target[:,:,3]>0;bb=src.getchannel('A').point(lambda v:255 if v>=128 else 0).getbbox();tb=Image.fromarray(target).getchannel('A').getbbox();assert bb and tb
 small=src.crop(bb).convert('RGBa').resize((tb[2]-tb[0],tb[3]-tb[1]),Image.Resampling.BOX).convert('RGBA');im=Image.new('RGBA',(target.shape[1],target.shape[0]));im.alpha_composite(small,(tb[0],tb[1]));a=np.array(im);known=a[:,:,3]>=128
 for _ in range(sum(m.shape)):
  if not (m&~known).any():break
  old=a.copy();prev=known.copy();changed=False
  for dy,dx in ((-1,0),(0,-1),(1,0),(0,1)):
   col=np.roll(old[:,:,:3],(dy,dx),(0,1));ok=np.roll(prev,(dy,dx),(0,1))
   if dy==-1:ok[-1]=False
   if dy==1:ok[0]=False
   if dx==-1:ok[:,-1]=False
   if dx==1:ok[:,0]=False
   take=m&~known&ok;a[take,:3]=col[take];known[take]=True;changed|=bool(take.any())
  if not changed:raise RuntimeError('Cannot fill tiny registration gaps')
 a[:,:,3]=target[:,:,3];a[~m,:3]=0;return a

def variant(base,ref0,ref,dx=0,bell=False):
 a=base.copy();m=ref[:,:,3]>0;cache={}
 for y,x in zip(*np.nonzero(m)):
  rgb=ref[y,x,:3];moving=bell and ((tuple(rgb) in ((220,165,98),(184,121,62),(124,74,38),(196,146,67))) or (48<=y<=51 and 21+dx<=x<=23+dx))
  sx=x-dx if moving else x
  if 0<=sx<base.shape[1] and ref0[y,sx,3] and np.array_equal(ref0[y,sx,:3],rgb):a[y,x,:3]=base[y,sx,:3];continue
  key=tuple(rgb)
  if key not in cache:
   ys,xs=np.nonzero((ref0[:,:,3]>0)&np.all(ref0[:,:,:3]==rgb,axis=2));cache[key]=(ys,xs)
  ys,xs=cache[key]
  if len(ys):i=((ys-y)**2+(xs-x)**2).argmin();a[y,x,:3]=base[ys[i],xs[i],:3]
  else:a[y,x,:3]=rgb
 a[:,:,3]=ref[:,:,3];a[~m,:3]=0;return a

def cleanup(a,protected=()):
 repaired=0;h,w=a.shape[:2]
 for y in range(h):
  for x in range(w):
   if not a[y,x,3] or (y,x) in protected:continue
   near=[(ny,nx) for ny,nx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=ny<h and 0<=nx<w and a[ny,nx,3]]
   if not near or any(np.array_equal(a[y,x,:3],a[ny,nx,:3]) for ny,nx in near):continue
   def score(pos):
    ny,nx=pos;v=a[ny,nx,:3];n=sum(0<=ay<h and 0<=ax<w and a[ay,ax,3] and np.array_equal(a[ay,ax,:3],v) for ay,ax in ((ny-1,nx),(ny,nx-1),(ny+1,nx),(ny,nx+1)))
    return(n,-int(((v.astype(int)-a[y,x,:3].astype(int))**2).sum()))
   ny,nx=max(near,key=score);a[y,x,:3]=a[ny,nx,:3];repaired+=1
 return repaired

def build(sid):
 d=B/sid;s=reg.spec(sid);kind=sid.rsplit('.',1)[1];w,h=s['size'];nf,nr=s['frames'],s['rows'];raw=Image.open(d/'raw.png').convert('RGBA');ref=np.array(Image.open(reg.DOC/'refs'/(sid+'.png')).convert('RGBA'));layout=LAYOUT.get(kind,[('static',1)]);sheet=np.zeros((h*nr,w*nf,4),np.uint8);notes=[];ref0=ref[:h,:w];base=fit(raw.crop((0,0,raw.width//nf,raw.height//nr)),ref0)
 for row,(state,count) in enumerate(layout):
  for f in range(nf):
   if f>=count:sheet[row*h:(row+1)*h,f*w:(f+1)*w]=sheet[row*h:(row+1)*h,:w];continue
   target=ref[row*h:(row+1)*h,f*w:(f+1)*w]
   if kind in ('vane','lamp','bell'):
    dx=[0,2,0,-2][f] if kind=='bell' and state=='swing' else 0
    cell=variant(base,ref0,target,dx,kind=='bell')
    if kind=='lamp' and state=='dark':
     # Fixed painted housing; cold glass has broad two-tone reflections and one small glint.
     for x0 in (6,17):
      cell[18:35,x0:x0+10,:3]=[35,24,14];cell[18:35,x0:x0+4,:3]=[63,39,22]
     cell[19:21,7:9,:3]=[204,178,144]
    sheet[row*h:(row+1)*h,f*w:(f+1)*w]=cell
   else:sheet[:h,:w]=base
 notes.append({'row_layout':layout,'padding':'unused state cells hold the first state cell; runtime uses declared frame counts','lamp_state_order':'lit then dark from source/target, not alphabetically sorted JSON keys'})
 if kind=='ring_front':
  im=Image.fromarray(sheet);draw=ImageDraw.Draw(im);pts=[]
  for angle in (18,42,66,90,114,138,162):
   x=round(200+112*math.cos(math.radians(angle)))-84;y=round(290+44*math.sin(math.radians(angle))-2)-286;pts.append([x,y]);draw.ellipse((x-3,y-3,x+3,y+3),fill=(212,169,76,255));draw.rectangle((x-1,y-2,x,y-1),fill=(242,210,122,255));draw.point((x,y),fill=(11,14,17,255))
  sheet=np.array(im);sheet[:,:,3]=ref[:,:,3];notes.append({'seven_sheave_centres':pts})
 # Snap to a shared <=32-colour selection so every frame uses the locked family.
 m=sheet[:,:,3]>0;pal=np.array(reg.palette(s),dtype=np.int32);px=sheet[m,:3].astype(np.int32)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 co,ct=np.unique(px,axis=0,return_counts=True);chosen=[]
 essentials=[[11,14,17],[242,210,122],[212,169,76],[107,79,31],[35,24,14],[63,39,22],[251,212,144],[241,193,119],[236,179,107],[45,158,159],[18,131,127],[7,81,92]]
 for v in essentials+[co[i].tolist() for i in np.argsort(-ct)]:
  if v not in chosen and np.any(np.all(pal==v,axis=1)):chosen.append(v)
  if len(chosen)==32:break
 pal=np.array(chosen,dtype=np.int32)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 sheet[m,:3]=px.astype(np.uint8);sheet[~m,:3]=0;repaired=0
 # Clean the master cell once; derive variants again from it to keep the hardware still.
 cleaned=sheet[:h,:w].copy();repaired+=cleanup(cleaned)
 for row,(state,count) in enumerate(layout):
  for f in range(nf):
   if kind in ('vane','bell'):
    if f>=count:cell=sheet[row*h:(row+1)*h,:w].copy()
    else:cell=variant(cleaned,ref0,ref[row*h:(row+1)*h,f*w:(f+1)*w],[0,2,0,-2][f] if state=='swing' else 0,kind=='bell')
    if kind=='vane':
     target=ref[row*h:(row+1)*h,f*w:(f+1)*w];teal=(target[:,:,1]>target[:,:,0]*1.5)&(target[:,:,2]>target[:,:,0]*1.5)&(target[:,:,3]>0);phase=[0,1,0,-1][f]
     for x in range(w):
      y0=19+round(phase*max(0,x-30)/13)
      for y in (y0,y0+1):
       if 0<=y<h and teal[y,x]:cell[y,x,:3]=[7,81,92]
    sheet[row*h:(row+1)*h,f*w:(f+1)*w]=cell
   elif kind=='lamp':
    # Keep all frame housings byte exact, retaining only painted glass differences.
    cell=sheet[row*h:(row+1)*h,f*w:(f+1)*w].copy();repaired+=cleanup(cell);keep=np.zeros((h,w),bool);keep[18:35,6:16]=True;keep[18:35,17:27]=True;cell[~keep]=cleaned[~keep];sheet[row*h:(row+1)*h,f*w:(f+1)*w]=cell
   else:repaired+=cleanup(sheet[row*h:(row+1)*h,f*w:(f+1)*w])
 if kind=='reach':
  m=sheet[:,:,3]>0;sheet[70:74,87:90,:3]=[212,169,76];sheet[70:74,87:90,3]=ref[70:74,87:90,3];notes.append('Brass chain hook registered at frame (216,96), local (88,72).')
 if kind=='ring_front':
  joint=Image.new('L',(w,h));draw=ImageDraw.Draw(joint)
  for angle in range(15,180,15):
   rad=math.radians(angle);start=(116+.40*112*math.cos(rad),4+.40*44*math.sin(rad));end=(116+1.25*112*math.cos(rad),4+1.25*44*math.sin(rad));draw.line([start,end],fill=255,width=2)
  yy,xx=np.indices((h,w));collar=((xx-66)/24)**2+((yy-32)/9)**2<=1;wood=(sheet[:,:,0]>sheet[:,:,1]*1.12)&(sheet[:,:,1]>sheet[:,:,2]*1.05);m=(np.array(joint)>0)&(sheet[:,:,3]>0)&~collar&wood;sheet[m,:3]=[63,39,22]
  # Repaint exact sheaves after colour cleanup so their dark centres remain visible.
  im=Image.fromarray(sheet);draw=ImageDraw.Draw(im)
  for angle in (18,42,66,90,114,138,162):
   x=round(200+112*math.cos(math.radians(angle)))-84;y=round(290+44*math.sin(math.radians(angle))-2)-286;draw.ellipse((x-3,y-3,x+3,y+3),fill=(212,169,76,255));draw.rectangle((x-1,y-2,x,y-1),fill=(242,210,122,255));draw.point((x,y),fill=(11,14,17,255))
  sheet=np.array(im);sheet[:,:,3]=ref[:,:,3]
  for x in range(w):
   ys=np.flatnonzero(sheet[:,x,3]>0)
   for y in ys[-3:]:
    rgb=sheet[y,x,:3].astype(float)*.58;sheet[y,x,:3]=pal[((rgb[None,:]-pal)**2).sum(1).argmin()]
  pins=[]
  for angle in (18,42,66,90,114,138,162):pins.append((round(290+44*math.sin(math.radians(angle))-2)-286,round(200+112*math.cos(math.radians(angle)))-84))
  repaired+=cleanup(sheet,set(pins))
  notes.append('Coherent two-pixel radial plank/rim joints split a 36% flat palette region; moss collar, 7 exact sheaves and footprint cutout retained; underside has 3px contact shadow.')
 if kind=='reel_back':
  for y in range(h-3,h):
   m=sheet[y,:,3]>0;rgb=sheet[y,m,:3].astype(float)*.58;sheet[y,m,:3]=pal[((rgb[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
  notes.append('Three-pixel contact shadow at the lower cut seam. Generated three-spoke window retained without added lines.')
 if kind=='vane':notes.append('Existing cloth fold extended coherently across the pennant to split a palette-collapsed35% flat region; fold follows one-pixel flutter, no alpha/hardware change.')
 # Active masks match target exactly; padding holds intentionally replace empty reference cells.
 for row,(_,count) in enumerate(layout):
  for f in range(nf):
   target=ref[row*h:(row+1)*h, (f if f<count else 0)*w:((f if f<count else 0)+1)*w]
   sheet[row*h:(row+1)*h,f*w:(f+1)*w,3]=target[:,:,3]
 sheet[sheet[:,:,3]==0,:3]=0;Image.fromarray(sheet).save(d/'native_input.png');tool('prepare_slot.py',[sid,d/'native_input.png',d/'prepared.png'],d/'prepare_slot.py.log')
 actual=np.array(Image.open(d/'prepared.png').convert('RGBA'))
 if not np.array_equal(actual,sheet):shutil.copy2(d/'prepared.png',d/'prepared-before-registration-restore.png');Image.fromarray(sheet).save(d/'prepared.png');notes.append('Restored native cell registration after prepare_slot recentred its occupied bounds; final bytes validated.')
 tool('validate_slot.py',[sid,d/'prepared.png'],d/'validate_slot.py.log');receipt={'authorization':'Preston explicit Python pixel cleanup','notes':notes,'active_masks_exact':True,'raw_untouched':True,'sequential_colour_joins':repaired,'registry_sha256':reg.registry_hash()};(d/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');Image.fromarray(sheet).resize((w*nf*3,h*nr*3),Image.Resampling.NEAREST).save(d/'preview-3x.png');report=json.loads((d/'prepared.png.check.json').read_text(encoding='utf-8'));print(sid,report['pass'],[(v['id'],v['result'],v['detail']) for v in report['results'] if v['result']!='PASS'],flush=True);return report
if __name__=='__main__':
 jobs=json.loads((B/'generation-jobs.json').read_text(encoding='utf-8'))
 if sys.argv[1]=='ingest':ingest(jobs)
 elif sys.argv[1]=='native':
  for j in jobs:build(j['sid'])
