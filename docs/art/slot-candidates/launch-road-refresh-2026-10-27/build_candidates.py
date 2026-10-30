from pathlib import Path
import sys,json,subprocess,os
import numpy as np
from PIL import Image
sys.dont_write_bytecode=True
R=Path(__file__).parent;ROOT=R.parents[3];sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
reg.SLOTS_JSON=R/'slots.json';reg.SLOT_DIR=R/'contract-source/slots';reg.LOADER=R/'contract-source/art_slots.gd';reg.load()
import prepare_slot,validate_slot

def command(name,args,log):
 p=subprocess.run([sys.executable,'-B',str(R/'with_contract.py'),name,*map(str,args)],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));log.write_text(p.stdout+p.stderr,encoding='utf-8');assert p.returncode in (0,1),p.stdout+p.stderr

def clean(a):
 count=0
 # Join isolated colour pixels to an adjacent opaque cluster without blurring edges.
 for y in range(a.shape[0]):
  for x in range(a.shape[1]):
   if not a[y,x,3]:continue
   near=[(ny,nx) for ny,nx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=ny<a.shape[0] and 0<=nx<a.shape[1] and a[ny,nx,3]]
   if any(np.array_equal(a[y,x,:3],a[ny,nx,:3]) for ny,nx in near):continue
   if not near:a[y,x]=0;count+=1;continue
   def score(p):
    ny,nx=p;v=a[ny,nx,:3];n=sum(0<=yy<a.shape[0] and 0<=xx<a.shape[1] and a[yy,xx,3] and np.array_equal(v,a[yy,xx,:3]) for yy,xx in ((ny-1,nx),(ny+1,nx),(ny,nx-1),(ny,nx+1)))
    return (n,-int(((v.astype(int)-a[y,x,:3].astype(int))**2).sum()))
   ny,nx=max(near,key=score);a[y,x,:3]=a[ny,nx,:3];count+=1
 return count

def build(sid):
 d=R/sid;s=reg.spec(sid);raw=Image.open(d/'raw.png').convert('RGBA');command('prepare_slot.py',[sid,d/'raw.png',d/'prepared-from-raw.png'],d/'prepare-raw.log');command('validate_slot.py',[sid,d/'prepared-from-raw.png'],d/'validate-raw.log')
 receipt={'raw_untouched':True,'authorized':'Preston Python pixel cleanup approval','contract':reg.registry_hash(),'native_size':s['size']}
 if sid.endswith('launch'):
  native=raw.resize((384,216),Image.Resampling.BOX);a=np.array(prepare_slot.snap(native,s));a[:,:,3]=255;receipt['strategy']='Full composition resized to native canvas, snapped to updated nine-colour night palette; adjacent colour cluster cleanup.'
 else:
  a0=np.array(raw);mask=a0[:,:,3]>=128;rows=np.flatnonzero(mask.mean(1)>.7);assert len(rows);ground=int(rows[0]);cut=ground-70;ys,xs=np.nonzero(mask[:cut]);bb=[int(xs.min()),int(ys.min()),int(xs.max())+1,ground+3]
  trees=raw.crop(bb).convert('RGBa').resize((166,104),Image.Resampling.BOX).convert('RGBA');groundart=raw.crop((0,ground-14,raw.width,raw.height)).convert('RGBa').resize((384,8),Image.Resampling.BOX).convert('RGBA');im=Image.new('RGBA',(384,112));im.alpha_composite(trees,(60,4));im.alpha_composite(groundart,(0,104));a=np.array(im);a[:,:,3]=np.where(a[:,:,3]>=128,255,0);a[a[:,:,3]==0,:3]=0
  a=np.array(prepare_slot.snap(Image.fromarray(a),s));receipt.update({'strategy':'Two generated willows fit x60..225,y4..107; generated low ground fringe y104..111. Upper viewing corridor kept transparent.','raw_tree_crop':bb,'raw_ground_crop':[0,ground-14,raw.width,raw.height],'tree_native_box':[60,4,166,104]})
  # Budget32 from the supplied dawn family, retaining the most used cluster colours.
  m=a[:,:,3]>0;colors,counts=np.unique(a[m,:3],axis=0,return_counts=True);pal=colors[np.argsort(-counts)[:32]].astype(int);px=a[m,:3].astype(int);a[m,:3]=pal[((px[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 receipt['colour_joins']=clean(a)
 if sid.endswith('mid'):
  # Only low grass reaches the tile edge. Mirror the first four grass columns at the right edge for exact edge equality.
  a[:,-4:]=a[:,:4][:,::-1];a[a[:,:,3]==0,:3]=0
 Image.fromarray(a).save(d/'native_input.png');command('prepare_slot.py',[sid,d/'native_input.png',d/'prepared.png'],d/'prepare_slot.py.log')
 actual=np.array(Image.open(d/'prepared.png').convert('RGBA'))
 if not np.array_equal(actual,a):
  Image.fromarray(actual).save(d/'prepared-before-registration-restore.png');Image.fromarray(a).save(d/'prepared.png');receipt['post_prepare_registration']='Native authored registration restored after tool bounding-box fit, final exact bytes validated.'
 command('validate_slot.py',[sid,d/'prepared.png'],d/'validate_slot.py.log');report=json.loads((d/'prepared.png.check.json').read_text());(d/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');Image.fromarray(a).resize((384*3,a.shape[0]*3),Image.Resampling.NEAREST).save(d/'preview-3x.png');print(sid,report['pass'],[(x['id'],x['result'],x['detail']) for x in report['results']],flush=True)
if __name__=='__main__':
 for sid in ['title.backdrop.launch','road.backdrop.mid']:build(sid)
