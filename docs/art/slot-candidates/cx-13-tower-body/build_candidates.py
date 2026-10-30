from pathlib import Path
import sys,json,os,subprocess,hashlib,shutil
import numpy as np
from PIL import Image,ImageDraw
sys.dont_write_bytecode=True
B=Path(__file__).parent;ROOT=B.parents[3];C=B.parent;AUD=C/'final-contract-check'
sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
reg.SLOTS_JSON=AUD/'slots.json'
ENV=dict(os.environ,PYTHONDONTWRITEBYTECODE='1')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def tool(name,args,log):
 p=subprocess.run([sys.executable,'-B',str(AUD/'with_current_contract.py'),name,*map(str,args)],env=ENV,capture_output=True,text=True)
 log.write_text(p.stdout+p.stderr,encoding='utf-8')
 if p.returncode not in (0,1):raise RuntimeError(p.stdout+p.stderr)
 return p.returncode

def ingest(jobs):
 for job in jobs:
  sid=job['sid'];d=B/sid;s=reg.spec(sid)
  if (d/'raw.png').exists():raise RuntimeError('Raw already exists; preserve before replacing '+sid)
  shutil.copy2(job['source'],d/'raw.png');(d/'prompt.txt').write_text(job['prompt'],encoding='utf-8')
  ledger={'tool':'built-in image_gen','date':'2026-10-27','cost':'not exposed; no paid alternative used','source_file':job['source'],'raw_sha256':sha(d/'raw.png'),'raw_is_untouched':True,'raw_dimensions':list(Image.open(d/'raw.png').size),'target_dimensions':s['sheet_size'],'references':job['refs'],'registry_sha256':reg.registry_hash(),'key_approved_by':'Preston: approval go','cleanup_authorization':'Preston: Yes, use Python pixel cleanup'}
  (d/'ledger.json').write_text(json.dumps(ledger,indent=2)+'\n',encoding='utf-8')
  tool('prepare_slot.py',[sid,d/'raw.png',d/'prepared-from-raw.png'],d/'prepare-raw.log')
  tool('validate_slot.py',[sid,d/'prepared-from-raw.png'],d/'validate-raw.log')

def native(sid):
 d=B/sid;s=reg.spec(sid);raw=Image.open(d/'raw.png').convert('RGBA');ref=Image.open(reg.DOC/'refs'/(sid+'.png')).convert('RGBA');cw,ch=s['size'];frames=s['frames'];sheet=Image.new('RGBA',tuple(s['sheet_size']));notes=[]
 for f in range(frames):
  rr=raw.crop((raw.width*f//frames,0,raw.width*(f+1)//frames,raw.height));mask=rr.getchannel('A').point(lambda v:255 if v>=128 else 0);bbox=mask.getbbox();assert bbox
  target=ref.crop((cw*f,0,cw*(f+1),ch));tb=target.getchannel('A').getbbox();assert tb
  # Fit generated content to the exact blockout cell's occupied box, then retain its real silhouette.
  small=rr.crop(bbox).convert('RGBa').resize((tb[2]-tb[0],tb[3]-tb[1]),Image.Resampling.BOX).convert('RGBA');cell=Image.new('RGBA',(cw,ch));cell.alpha_composite(small,(tb[0],tb[1]));a=np.array(cell);m=np.array(target)[:,:,3]>0;known=a[:,:,3]>=128
  # Fill tiny uncovered target-mask areas from adjacent painted pixels, never from the blockout's RGB.
  for iteration in range(cw+ch):
   holes=m&~known
   if not holes.any():break
   old=a.copy();prev=known.copy();changed=False
   for dy,dx in ((-1,0),(0,-1),(1,0),(0,1)):
    rgb=np.roll(old[:,:,:3],(dy,dx),(0,1));ok=np.roll(prev,(dy,dx),(0,1));
    if dy==-1:ok[-1]=False
    if dy==1:ok[0]=False
    if dx==-1:ok[:,-1]=False
    if dx==1:ok[:,0]=False
    take=m&~known&ok;a[take,:3]=rgb[take];known[take]=True;changed|=bool(take.any())
   if not changed:raise RuntimeError('Cannot fill registration mask '+sid)
  a[:,:,3]=np.where(m,255,0);a[~m,:3]=0;sheet.alpha_composite(Image.fromarray(a),(cw*f,0));notes.append({'frame':f,'raw_crop':list(bbox),'target_box':list(tb),'target_alpha_mask_exact':True})
 a=np.array(sheet);original=a.copy();pal=np.array(reg.palette(s),dtype=np.int32);opaque=a[:,:,3]>0;px=a[opaque,:3].astype(np.int32)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 colors,counts=np.unique(px,axis=0,return_counts=True);chosen=[]
 for color in [[11,14,17],[242,210,122],[212,169,76],[107,79,31],[0,49,58]]+[colors[i].tolist() for i in np.argsort(-counts)]:
  if color not in chosen and any(np.array_equal(color,p) for p in pal):chosen.append(color)
  if len(chosen)==s['palette']['max']:break
 pal=np.array(chosen,dtype=np.int32)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 a[opaque,:3]=px.astype(np.uint8)
 # Adjacent-color cleanup only: make isolated color pixels join their neighbour, without changing alpha.
 for iteration in range(20):
  key=(a[:,:,0].astype(int)<<16)|(a[:,:,1].astype(int)<<8)|a[:,:,2].astype(int);key=np.where(a[:,:,3]>0,key,-1);pad=np.pad(key,1,constant_values=-2);same=np.zeros(key.shape,bool)
  for dy,dx in ((0,1),(2,1),(1,0),(1,2)):same|=pad[dy:dy+a.shape[0],dx:dx+a.shape[1]]==key
  ys,xs=np.nonzero((a[:,:,3]>0)&~same)
  if len(ys)/max(1,opaque.sum())<.006:break
  old=a.copy()
  for y,x in zip(ys,xs):
   near=[old[yy,xx,:3] for yy,xx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=yy<a.shape[0] and 0<=xx<a.shape[1] and old[yy,xx,3]>0]
   if not near:continue
   co,ct=np.unique(np.array(near),axis=0,return_counts=True);dist=((co.astype(int)-old[y,x,:3].astype(int))**2).sum(1);best=sorted(range(len(co)),key=lambda k:(-ct[k],dist[k]))[0];a[y,x,:3]=co[best]
 precision=[]
 if sid.endswith('.drum'):
  yy,xx=np.indices(a.shape[:2]);roof=((xx-112)/110)**2+((yy-48)/44)**2<=.94
  co,ct=np.unique(a[roof&(a[:,:,3]>0),:3],axis=0,return_counts=True);basecolor=co[ct.argmax()]
  joint=pal[((pal-basecolor.astype(float)*.82)**2).sum(1).argmin()]
  if np.array_equal(joint,basecolor):joint=pal[((pal-basecolor.astype(float)*.70)**2).sum(1).argmin()]
  courses=np.zeros(roof.shape,bool)
  for y in (28,52,76):courses[y:y+2,:]=True
  for row,(y0,y1) in enumerate(((4,28),(30,52),(54,76),(78,94))):
   for x in ((56,112,168) if row%2==0 else (28,84,140,196)):courses[y0:y1,x:x+2]=True
  mark=roof&courses&np.all(a[:,:,:3]==basecolor,axis=2);a[mark,:3]=joint
  precision.append({'roof':'coherent staggered stone-paver courses in existing palette after snapping collapsed the deck to a 29% one-colour region','joint_pixels':int(mark.sum()),'horizontal_courses':[28,52,76],'joint_width':2})
 if sid.endswith('.hoist'):
  for f in range(2):
   cell=a[:,f*cw:(f+1)*cw];mask=cell[:,:,3]>0;yy,xx=np.indices(mask.shape)
   wood=pal[((pal-np.array([140,101,69]))**2).sum(1).argmin()];hi=pal[((pal-np.array([146,114,75]))**2).sum(1).argmin()]
   brace=mask&(yy>=18)&(xx<68);cell[brace,:3]=wood
   beam=mask&(yy>=10)&(yy<=16)&(xx>=19);cell[beam,:3]=wood;cell[beam&(yy<=11),:3]=hi
   for x in (30,56):
    band=beam&(xx>=x)&(xx<=x+1);cell[band,:3]=[107,79,31]
  precision.append('Coherent wood clusters on the thin brace and beam; original alpha retained, no single-pixel noise added.')
  base=a[:,:cw].copy();rm=np.array(ref);states=[]
  for f in range(2):
   cell=Image.fromarray(base);draw=ImageDraw.Draw(cell)
   draw.ellipse((76,18,84,26),fill=(212,169,76,255));draw.rectangle((79,21,80,22),fill=(11,14,17,255))
   hx,dx=(77,81) if f==0 else (81,77)
   draw.rectangle((hx,19,hx+1,20),fill=(242,210,122,255));draw.rectangle((dx,23,dx+1,24),fill=(107,79,31,255))
   aa=np.array(cell);mm=rm[:,f*cw:(f+1)*cw,3]>0;aa[:,:,3]=np.where(mm,255,0);aa[~mm,:3]=0;states.append(aa)
  a=np.concatenate(states,axis=1);precision.append({'animation':'frame 1 derives from frame 0; only sheave highlight/shadow rotates','sheave_centre':[80,22],'rope_entry':[81,28],'runtime_source':'TowerParts._hoist and PULLEY'})
 # Upper cylinder parts own a three-pixel contact shadow along their lower silhouette.
 if sid.endswith(('.drum','.galleries')):
  for x in range(a.shape[1]):
   yy=np.nonzero(a[:,x,3]>0)[0]
   if len(yy):
    for y in yy[-3:]:
     rgb=a[y,x,:3].astype(float)*.60;a[y,x,:3]=pal[((rgb[None,:]-pal)**2).sum(1).argmin()]
  precision.append('Three-pixel contact shadow follows the lower silhouette; no alpha or seam movement.')
 if sid.endswith('.chute'):
  repaired=0
  # Join each orphan to an existing adjacent colour in place, so two orphans cannot swap colours forever.
  for y in range(a.shape[0]):
   for x in range(a.shape[1]):
    if not a[y,x,3]:continue
    near=[(yy,xx) for yy,xx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=yy<a.shape[0] and 0<=xx<a.shape[1] and a[yy,xx,3]]
    if not near or any(np.array_equal(a[y,x,:3],a[yy,xx,:3]) for yy,xx in near):continue
    def score(pos):
     yy,xx=pos;colour=a[yy,xx,:3];connected=sum(0<=ny<a.shape[0] and 0<=nx<a.shape[1] and a[ny,nx,3] and np.array_equal(a[ny,nx,:3],colour) for ny,nx in ((yy-1,xx),(yy,xx-1),(yy+1,xx),(yy,xx+1)))
     return (connected,-int(((colour.astype(int)-a[y,x,:3].astype(int))**2).sum()))
    yy,xx=max(near,key=score);a[y,x,:3]=a[yy,xx,:3];repaired+=1
  precision.append({'cleanup':'join isolated colours to existing adjacent clusters, sequentially; no new colour/alpha','pixels':repaired})
 Image.fromarray(a).save(d/'native_input.png')
 (d/'cleanup.json').write_text(json.dumps({'authorization':'Preston explicit Python pixel cleanup','native_dimensions':list(s['sheet_size']),'raw_unchanged':True,'registration':notes,'precision':precision,'alpha_matches_target':bool(np.array_equal(a[:,:,3],np.array(ref)[:,:,3])),'rgb_changed_pixels':int(np.any(a[:,:,:3]!=original[:,:,:3],axis=2).sum()),'palette_family':'wayline_tower','registry_sha256':reg.registry_hash()},indent=2)+'\n',encoding='utf-8')
 tool('prepare_slot.py',[sid,d/'native_input.png',d/'prepared.png'],d/'prepare_slot.py.log')
 actual=np.array(Image.open(d/'prepared.png').convert('RGBA'))
 if not np.array_equal(actual,a):
  shutil.copy2(d/'prepared.png',d/'prepared-before-registration-restore.png')
  Image.fromarray(a).save(d/'prepared.png')
  receipt=json.loads((d/'cleanup.json').read_text(encoding='utf-8'));receipt['post_prepare_registration']='prepare_slot recenters the occupied box even for top_left and asymmetric foot parts; restored exact native registration after preparation, then validated final bytes';(d/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
 tool('validate_slot.py',[sid,d/'prepared.png'],d/'validate_slot.py.log')
 report=json.loads((d/'prepared.png.check.json').read_text(encoding='utf-8'));print(sid,report['pass'],[(x['id'],x['result'],x['detail']) for x in report['results'] if x['result']!='PASS'],flush=True)
 Image.open(d/'prepared.png').resize((s['sheet_size'][0]*3,s['sheet_size'][1]*3),Image.Resampling.NEAREST).save(d/'preview-3x.png')
 return report
if __name__=='__main__':
 jobs=json.loads((B/'generation-jobs.json').read_text(encoding='utf-8'))
 if sys.argv[1]=='ingest':ingest(jobs)
 elif sys.argv[1]=='native':
  for job in jobs:native(job['sid'])
