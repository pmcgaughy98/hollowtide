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
 if 'door_px' in s:
  x,y,w,h=s['door_px'];a[y:y+h,x:x+w,:3]=[11,14,17];a[y:y+h,x:x+w,3]=255;precision.append('Exact open dark doorway '+str(s['door_px']))
 if sid.endswith('.gable'):
  im=Image.fromarray(a);draw=ImageDraw.Draw(im);draw.rectangle((26,20,77,45),fill=(107,79,31,255));draw.rectangle((27,21,76,44),fill=(212,169,76,255));draw.line((27,21,76,21),fill=(242,210,122,255),width=1)
  knot=np.array([51.,40.]);arms=[np.array([32.,26.]),np.array([51.,24.]),np.array([72.,27.])];pegs=[]
  for arm,ks in zip(arms,[[.45,.8],[.4,.72,.98],[.45,.8]]):
   draw.line([tuple(knot),tuple(arm)],fill=(107,79,31,255),width=2)
   for k in ks:pegs.append((knot+(arm-knot)*k).round().astype(int).tolist())
  pegs.append([51,40])
  for x,y in pegs:draw.rectangle((x-1,y-1,x+1,y+1),fill=(11,14,17,255))
  a=np.array(im);precision.append({'exact_dark_peg_centres':pegs,'matches':'TowerParts.route_pegs, local frame (164,560)'})
 if sid.endswith('.gable'):
  for y in range(ch-3,ch):
   m=a[y,:,3]>0;rgb=a[y,m,:3].astype(float)*.55;a[y,m,:3]=pal[((rgb[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
  precision.append('Owns three-pixel under-lip contact shadow at the bottom seam.')
 if sid.endswith('.yard'):
  # Keep the dock completely still. Only the handle region changes, at the coded winch coordinates.
  first=a[:,:cw].copy();second=first.copy();rm0=np.array(ref)[:,:cw,3]>0;rm1=np.array(ref)[:,cw:,3]>0;added=rm1&~rm0;second[added,:3]=[107,79,31];second[:,:,3]=np.where(rm1,255,0);second[~rm1,:3]=0;a[:,cw:]=second;precision.append('Frame 1 derived from painted frame 0; only coded handle alpha/paint region changes. All other pixels exact.')
 if sid.endswith('rise_stair'):
  a[:,0,:3]=[11,14,17];a[:,-1,:3]=[11,14,17];precision.append('Drawn 1px side outline per prop contract, unlike building parts.')
 if sid.endswith('rise_stair'):
  src=Image.fromarray(a);eight=Image.new('RGBA',(48,96));bands=[0,1,2,3,3,4,5,6]
  for i,k in enumerate(bands):
   strip=src.crop((0,round(k*96/7),48,round((k+1)*96/7))).resize((48,12),Image.Resampling.NEAREST);eight.paste(strip,(0,i*12))
  a=np.array(eight);precision.append({'generated_treads':7,'delivered_treads':8,'band_map':bands,'method':'Recut painted tread bands to eight 12px risers, repeating one quiet middle tread. No new raw paint claimed.'})
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
