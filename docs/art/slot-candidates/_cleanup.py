from pathlib import Path
import json,os,subprocess,sys,shutil
import numpy as np
from PIL import Image
sys.dont_write_bytecode=True
L=Path(__file__).resolve().parents[3];sys.path.insert(0,str(L/'tools/art'))
import slot_registry as reg

def clean(batch,sid):
 d=L/'docs/art/slot-candidates'/batch/sid
 assert sid!='town.building.hall'
 s=reg.spec(sid);before=d/'prepared-before-cleanup.png'
 if not before.exists():shutil.copy2(d/'prepared.png',before)
 a=np.array(Image.open(before).convert('RGBA'));original=a.copy();pal=np.array(reg.palette(s),dtype=np.int32)
 lum=pal[:,0]*.299+pal[:,1]*.587+pal[:,2]*.114
 budget=int(s['palette'].get('max',256))
 visible=a[:,:,3]>0
 if len(np.unique(a[visible,:3],axis=0))>budget:
  # Respect a slot's stricter budget even when its family palette strip has more entries.
  pixels=a[visible,:3];strip=Image.fromarray(pixels.reshape(-1,1,3));q=strip.quantize(colors=budget,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE)
  centers=np.array(q.getpalette()[:budget*3]).reshape(-1,3)
  chosen=pal[((centers[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
  for start in range(0,len(pixels),32768):
   chunk=pixels[start:start+32768].astype(int);pixels[start:start+32768]=chosen[((chunk[:,None,:]-chosen[None,:,:])**2).sum(2).argmin(1)]
  a[visible,:3]=pixels
 pal=np.unique(a[a[:,:,3]>0,:3],axis=0).astype(np.int32)
 lum=pal[:,0]*.299+pal[:,1]*.587+pal[:,2]*.114
 if 'door_px' in s:
  x,y,w,h=s['door_px'];dark=pal[lum.argmin()]
  a[y:y+h,x:x+w,:3]=dark;a[y:y+h,x:x+w,3]=255
 # Remove only isolated color specks using an adjacent opaque color. No blur or palette invention.
 removed=0
 for iteration in range(12):
  opaque=a[:,:,3]>0;key=(a[:,:,0].astype(int)<<16)|(a[:,:,1].astype(int)<<8)|a[:,:,2].astype(int);key=np.where(opaque,key,-1)
  p=np.pad(key,1,constant_values=-2);same=np.zeros(key.shape,bool)
  for dy,dx in ((0,1),(2,1),(1,0),(1,2)):same|=p[dy:dy+a.shape[0],dx:dx+a.shape[1]]==key
  ys,xs=np.nonzero(opaque&~same)
  if len(ys)/max(1,opaque.sum())<.006:break
  for y,x in zip(ys,xs):
   neighbors=[a[yy,xx,:3].copy() for yy,xx in ((y-1,x),(y+1,x),(y,x-1),(y,x+1)) if 0<=yy<a.shape[0] and 0<=xx<a.shape[1] and a[yy,xx,3]>0]
   if not neighbors:a[y,x]=0;removed+=1;continue
   colors,counts=np.unique(np.array(neighbors),axis=0,return_counts=True)
   dist=((colors.astype(int)-a[y,x,:3].astype(int))**2).sum(1)
   best=sorted(range(len(colors)),key=lambda k:(-counts[k],dist[k]))[0];a[y,x,:3]=colors[best]
 # Make the authored strip periodic in RGB and binary alpha, across a narrow 8px wrap band.
 if s.get('tiling') in ('h','hv'):
  src=a.copy();band=min(8,a.shape[1]//2)
  for i in range(band):
   f=(band-i)/band;left=src[:,i].astype(float);right=src[:,-1-i].astype(float);mid=(left+right)/2
   for x,side in ((i,left),(-1-i,right)):
    mix=side*(1-f)+mid*f
    a[:,x,:3]=pal[((mix[:,:3,None]-pal.T[None,:,:])**2).sum(1).argmin(1)]
    a[:,x,3]=np.where(mix[:,3]>=127.5,255,0)
 if s.get('tiling') in ('v','hv'):
  avg=(a[0,:,:3].astype(int)+a[-1,:,:3].astype(int))//2
  color=pal[((avg[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
  a[0,:,:3]=color;a[-1,:,:3]=color
  alpha=np.maximum(a[0,:,3],a[-1,:,3]);a[0,:,3]=alpha;a[-1,:,3]=alpha
 Image.fromarray(a).save(d/'native_input.png')
 ledger=json.loads((d/'ledger.json').read_text());ledger['pixel_cleanup']='Explicitly authorized by Preston, 2026-10-27. Raw untouched; native_input.png supplies repaired exact-size art to unchanged prepare_slot.';(d/'ledger.json').write_text(json.dumps(ledger,indent=2))
 receipt={'authorized':'Preston reply Yes, use Python pixel cleanup','changed_rgb_pixels':int(np.any(original[:,:,:3]!=a[:,:,:3],axis=2).sum()),'alpha_changed_pixels':int((original[:,:,3]!=a[:,:,3]).sum()),'isolated_alpha_specks_removed':removed,'size':list(Image.open(d/'native_input.png').size),'door_box':s.get('door_px'),'raw_unchanged':True}
 (d/'cleanup.json').write_text(json.dumps(receipt,indent=2))
 env=os.environ.copy();env['PYTHONDONTWRITEBYTECODE']='1'
 for tool,args in [('prepare_slot.py',[sid,str(d/'native_input.png'),str(d/'prepared.png')]),('validate_slot.py',[sid,str(d/'prepared.png')])]:
  r=subprocess.run([sys.executable,'-B',str(L/'tools/art'/tool)]+args,cwd=L,env=env,capture_output=True,text=True);(d/(tool+'.log')).write_text(r.stdout+r.stderr)
  if r.returncode not in (0,1):raise RuntimeError(r.stdout+r.stderr)
 report=json.loads((d/'prepared.png.check.json').read_text());print(sid+': '+('PASS' if report['pass'] else 'FAIL')+'; '+', '.join(x['id']+' '+x['result'] for x in report['results']),flush=True)
 return report
