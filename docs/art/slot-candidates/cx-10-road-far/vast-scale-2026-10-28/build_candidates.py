from pathlib import Path
import sys,json,subprocess,os,math
import numpy as np
from PIL import Image,ImageDraw
sys.dont_write_bytecode=True
R=Path(__file__).parent;B=R.parent;ROOT=R.parents[4];sys.path.insert(0,str(ROOT/'tools/art'));import slot_registry as reg
reg.SLOTS_JSON=R/'slots.json';reg.SLOT_DIR=R/'contract-source/slots';reg.LOADER=R/'contract-source/art_slots.gd';reg.load();import prepare_slot

def tool(name,args,log):
 p=subprocess.run([sys.executable,'-B',str(R/'with_contract.py'),name,*map(str,args)],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));log.write_text(p.stdout+p.stderr,encoding='utf-8');assert p.returncode in (0,1),p.stdout+p.stderr

def clean(a,protect=None):
 if protect is None:protect=np.zeros(a.shape[:2],bool)
 n=0;h,w=a.shape[:2]
 for y in range(h):
  for x in range(w):
   if protect[y,x] or not a[y,x,3]:continue
   near=[(ny,nx) for ny,nx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=ny<h and 0<=nx<w and a[ny,nx,3]]
   if not near or any(np.array_equal(a[y,x,:3],a[ny,nx,:3]) for ny,nx in near):continue
   def score(p):
    ny,nx=p;v=a[ny,nx,:3];ct=sum(0<=yy<h and 0<=xx<w and a[yy,xx,3] and np.array_equal(v,a[yy,xx,:3]) for yy,xx in ((ny-1,nx),(ny,nx-1),(ny+1,nx),(ny,nx+1)))
    return(ct,-int(((v.astype(int)-a[y,x,:3].astype(int))**2).sum()))
   ny,nx=max(near,key=score);a[y,x,:3]=a[ny,nx,:3];n+=1
 return n

def snap(im,s):return np.array(prepare_slot.snap(im.convert('RGBA'),s))
def build(sid):
 d=B/sid;s=reg.spec(sid);ref=np.array(Image.open(d/'references/target.png').convert('RGBA'));a=np.array(Image.open(d/'prepared-from-raw.png').convert('RGBA'));receipt={'authorization':'Preston explicit Python pixel cleanup','raw_untouched':True,'registry_sha256':reg.registry_hash(),'size':s['size']};protect=np.zeros(a.shape[:2],bool)
 if sid.endswith('highbank_far'):
  original=a.copy()
  # Remove the generation's offset pole, then register its painted stone to the source's narrow pole.
  for y in range(60,76):a[y,111:120]=original[y,121:130]
  crop=Image.fromarray(original).crop((111,3,119,75)).resize((11,71),Image.Resampling.NEAREST);pole=np.array(crop);mask=ref[5:76,99:110,3]>0;patch=a[5:76,99:110];patch[mask]=pole[mask];patch[mask,3]=255
  yy,xx=np.indices(a.shape[:2]);cloud=(yy<55)&(ref[:,:,3]>0)&(ref[:,:,0]>=131)&~((xx>=99)&(xx<110));a[cloud]=ref[cloud]
  # Below the high forest band the source requires valley mist, rather than a second forest on a floating island.
  mist=np.array([[131,142,135],[160,173,176],[171,194,211]],int);m=(yy>=76)&(ref[:,:,3]>0);lum=original[:,:,:3].mean(2);idx=np.clip(((lum-50)/60).astype(int),0,2);a[m,:3]=mist[idx[m]];a[:,:,3]=ref[:,:,3];a[a[:,:,3]==0,:3]=0
  # Exact micro hook and beacon; native source precision is essential at this scale.
  a[5:10,102:109]=ref[5:10,102:109];protect[5:10,102:109]=True
  im=Image.fromarray(a);dr=ImageDraw.Draw(im);pts=[]
  for i in range(18):
   t=i/17;x=round(101+(84-101)*t);y=round(70+3*t+3*4*t*(1-t));pts.append((x,y))
  dr.line(pts,fill=(107,79,31,255),width=1);a=np.array(im);a[:,:,3]=ref[:,:,3];a[a[:,:,3]==0,:3]=0
  for x,y in pts:protect[y,x]=True
  a[5:76,100:108]=ref[5:76,100:108];protect[5:76,100:108]=True;a[7,105]=[236,179,107,255];protect[7,105]=True;receipt['micro_core']='Reference8px Tower core retained to preserve slender neck, tiny rings and continuous readable profile; generated offset core archived.'
  receipt.update({'native_pole_source_box':[111,3,119,75],'native_pole_target_box':[99,5,110,76],'reference_alpha_exact':True,'beacon':[105,7],'wayline_points':pts,'mist':'native lower20rows rebuilt in three source mist colours; terrain remains within reference alpha; old offset pole removed'})
 elif sid.endswith('vista'):
  # Keep the source centre; the user's correction changes only the two framing trees.
  baseline=a.copy();anchors=s['anchors'];protect[7:201,278:297]=True;yy,xx=np.indices(a.shape[:2]);cable=(xx>=286)&(yy>=95)&(yy<=151)&(a[:,:,0]>a[:,:,1]*1.1)&(a[:,:,:3].mean(2)<120);protect|=cable
  for k,v in anchors.items():
   if k.startswith('lamp_'):x,y=v;baseline[y:y+2,x,:3]=[45,55,42];protect[y:y+2,x]=True
  baseline[11,286,:3]=[236,181,108];protect[10:13,285:288]=True;baseline=snap(Image.fromarray(baseline),s);clean(baseline,protect);Image.fromarray(baseline).save(d/'native-centre-baseline.png')
  raw=Image.open(d/'side-trees-edit.png').convert('RGBA');edited=snap(raw.resize((384,216),Image.Resampling.BOX),s);a=baseline.copy();a[:,:104]=edited[:,:104];a[:,301:]=edited[:,301:];edgeprotect=np.ones(a.shape[:2],bool);edgeprotect[:,:104]=False;edgeprotect[:,301:]=False;receipt['side_colour_joins']=clean(a,edgeprotect);assert np.array_equal(a[:,104:301],baseline[:,104:301]);protect[:,:]=True
  receipt.update({'user_side_tree_revision':True,'framing_bands_native':[[0,103],[301,383]],'native_centre_columns104_300_exact_to_common_baseline':True,'source_centre_columns450_1309_exact':True,'lamp_windows':'five declared house anchors dark/unlit; runtime owns lighting','beacon':[286,11],'wayline':'Original central cable preserved per user side-only request; east/west source contradiction left for Claude.'})
 else:
  green=(a[:,:,1]>a[:,:,0]*1.08)&(a[:,:,1]>a[:,:,2]*1.03)&(np.indices(a.shape[:2])[0]>135);ys,xs=np.nonzero(green);assert len(ys);bb=(int(xs.min()),int(ys.min()),int(xs.max())+1,int(ys.max())+1);mref=(ref[:,:,1]>ref[:,:,0]*1.08)&(ref[:,:,1]>ref[:,:,2]*1.03)&(np.indices(ref.shape[:2])[0]>=146);ty,tx=np.nonzero(mref);tb=(int(tx.min()),int(ty.min()),int(tx.max())+1,int(ty.max())+1)
  # Remove the generation's earlier/higher crown before placing it at the approved cap's shape.
  for y,x in zip(*np.nonzero(green)):a[y,x]=a[y,250+(x%100)]
  small=np.array(Image.fromarray(np.array(Image.open(d/'prepared-from-raw.png').convert('RGBA'))).crop(bb).resize((tb[2]-tb[0],tb[3]-tb[1]),Image.Resampling.NEAREST));patch=a[tb[1]:tb[3],tb[0]:tb[2]];mm=mref[tb[1]:tb[3],tb[0]:tb[2]];patch[mm]=small[mm]
  a[:146]=ref[:146];a[119:136,:, :3]=ref[127,192,:3];protect[:146]=True
  # Guarantee every leaf is a green palette member rather than a sampled surrounding cloud.
  pal=np.array(reg.palette(s),int);greens=pal[(pal[:,1]>pal[:,0]*1.08)&(pal[:,1]>pal[:,2]*1.03)];px=a[mref,:3].astype(int);a[mref,:3]=greens[((px[:,None,:]-greens[None,:,:])**2).sum(2).argmin(1)]
  protect|=mref
  for dy,dx in [(-1,0),(1,0),(0,-1),(0,1)]:protect|=np.roll(mref,(dy,dx),(0,1))
  receipt.update({'sky_bands':'reference flat bands retained above horizon146; generated cloud sea below','generated_cap_box':list(bb),'reference_cap_box':list(tb),'reference_cap_mask_exact':True,'lamp_calm_box':[184,119,17,17],'no_tower_lamp_or_town_painted':True})
 receipt['colour_joins']=clean(a,protect);a=snap(Image.fromarray(a),s)
 if sid.endswith('highbank_far'):a[:,:,3]=ref[:,:,3];a[a[:,:,3]==0,:3]=0
 Image.fromarray(a).save(d/'native_input.png');tool('prepare_slot.py',[sid,d/'native_input.png',d/'prepared.png'],d/'prepare_slot.py.log');actual=np.array(Image.open(d/'prepared.png').convert('RGBA'));assert np.array_equal(actual,a),'Exact-size preparation moved or changed source pixels unexpectedly'
 tool('validate_slot.py',[sid,d/'prepared.png'],d/'validate_slot.py.log');(d/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');Image.fromarray(a).resize((a.shape[1]*3,a.shape[0]*3),Image.Resampling.NEAREST).save(d/'preview-3x.png');report=json.loads((d/'prepared.png.check.json').read_text());print(sid,report['pass'],[(v['id'],v['result'],v['detail']) for v in report['results']],flush=True)
if __name__=='__main__':
 for sid in ['road.backdrop.highbank_far','road.backdrop.vista','story.backdrop.tower_sky']:build(sid)
