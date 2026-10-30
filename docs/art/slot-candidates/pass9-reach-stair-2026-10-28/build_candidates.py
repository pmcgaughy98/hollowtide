from pathlib import Path
import sys,json,os,subprocess,runpy
import numpy as np
from PIL import Image,ImageDraw
sys.dont_write_bytecode=True
R=Path(__file__).parent;ROOT=R.parents[3];sys.path.insert(0,str(ROOT/'tools/art'));import slot_registry as reg
reg.SLOTS_JSON=R/'slots.json';reg.SLOT_DIR=R/'contract-source/slots';reg.LOADER=R/'contract-source/art_slots.gd';reg.load()
crown=runpy.run_path(str(R.parent/'cx-14-tower-crown/build_candidates.py'));fit=crown['fit'];cleanup=crown['cleanup']
def tool(name,args,log):
 p=subprocess.run([sys.executable,'-B',str(R/'with_contract.py'),name,*map(str,args)],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));log.write_text(p.stdout+p.stderr,encoding='utf-8');assert p.returncode in (0,1),p.stdout+p.stderr

def build(sid):
 d=R/sid;s=reg.spec(sid);old=np.array(Image.open(d/'input-before.png').convert('RGBA'));ref=np.array(Image.open(d/'references/target.png').convert('RGBA'));raw=Image.open(d/'raw.png').convert('RGBA');receipt={'authorization':'Preston explicit Python pixel cleanup','raw_untouched':True,'registry_sha256':reg.registry_hash(),'size':s['size']};tool('prepare_slot.py',[sid,d/'raw.png',d/'prepared-from-raw.png'],d/'prepare-raw.log');tool('validate_slot.py',[sid,d/'prepared-from-raw.png'],d/'validate-raw.log');protect=np.zeros(old.shape[:2],bool)
 if sid.endswith('reach'):
  a=fit(raw,ref);a[110:]=old[110:];protect[110:]=True;protected_detail=np.zeros_like(protect)
  for x0,y0,x1,y1 in [(18,24,41,50),(62,22,91,49)]:
   rgb=ref[y0:y1,x0:x1,:3];feature=(np.all(rgb==[212,169,76],2)|np.all(rgb==[107,79,31],2)|np.all(rgb==[242,210,122],2)|np.all(rgb==[11,14,17],2))&(ref[y0:y1,x0:x1,3]>0);patch=a[y0:y1,x0:x1];patch[feature]=ref[y0:y1,x0:x1][feature];protected_detail[y0:y1,x0:x1]|=feature
  for x,y in [(40,30),(84,47)]:
   box=(slice(y-3,y+4),slice(x-3,x+4));a[box]=ref[box];protected_detail[box]=ref[box][:,:,3]>0
  hook=(slice(70,74),slice(87,90));a[hook]=old[hook];protected_detail[hook]=True;protect|=protected_detail
  receipt.update({'scope':'crook rows0..109 only; lower190rows exact','alpha':'current reference silhouette exact','lashings_degrees':[222,312],'knots_degrees':[246,336],'knot_centres_local':[[40,30],[84,47]],'hook_local':[88,72],'precision':'Two brass/lip masks and two7x7 knot patches follow current reference; existing hook kept. No optional trailing rootlets.'})
 else:
  # Normalize the generated eight treads, whose first/last heights differed from the12px contract.
  bands=[0,274,506,738,970,1202,1434,1666,1774];im=Image.new('RGBA',(48,96))
  for i,(y0,y1) in enumerate(zip(bands,bands[1:])):im.paste(raw.crop((18,y0,870,y1)).resize((48,12),Image.Resampling.BOX),(0,i*12))
  a=np.array(im);a[:,:,3]=255
  # Remove the two generated roots one step too high; preserve stone cluster patterns by borrowing same-row stone.
  for x0,y0,x1,y1 in [(1,28,20,44),(28,52,47,68)]:
   src=a.copy()
   for y in range(y0,y1):
    for x in range(x0,x1):a[y,x]=src[y,20+(x%8)]
  receipt.update({'raw_stair_band_boundaries':bands,'raw_inner_x':[18,870],'generated_root_cleanup_boxes':[[1,28,20,44],[28,52,47,68]],'precision':'Eight12px treads; generated misplaced roots removed; exact source root planes and overhanging crack lips at the approved risers.'})
 # Snap to locked palette, keeping existing Reach colours for its protected lower shaft.
 m=a[:,:,3]>0;pal=np.array(reg.palette(s),int);px=a[m,:3].astype(int)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 colors,counts=np.unique(px,axis=0,return_counts=True);chosen=np.unique(old[old[:,:,3]>0,:3],axis=0).tolist() if sid.endswith('reach') else []
 for v in [[11,14,17],[212,169,76],[242,210,122],[107,79,31],[176,107,61],[102,63,35],[63,39,22]]+[colors[i].tolist() for i in np.argsort(-counts)]:
  if v not in chosen:chosen.append(v)
  if len(chosen)>=32:break
 pal=np.array(chosen,int)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 a[m,:3]=px.astype(np.uint8)
 if sid.endswith('rise_stair'):
  roots=np.zeros(a.shape[:2],bool)
  for color in [[176,107,61],[102,63,35],[63,39,22]]:roots|=np.all(ref[:,:,:3]==color,2)&(ref[:,:,3]>0)
  brown=(a[:,:,0]>a[:,:,1]*1.4)&(a[:,:,2]<a[:,:,0]*.65);src=a.copy()
  for y,x in zip(*np.nonzero(brown&~roots)):a[y,x]=src[y,20+(x%8)]
  a[roots]=ref[roots];protect|=roots
  for x0,x1,y in [(0,5,44),(41,46,68)]:a[y,x0:x1+1,:3]=[11,14,17];protect[y,x0:x1+1]=True
  im=Image.fromarray(a);dr=ImageDraw.Draw(im)
  for endpoint in [(19,4),(24,3),(29,4)]:dr.line([(24,9),endpoint],fill=(156,140,104,255),width=1)
  a=np.array(im);a[:,0,:3]=[11,14,17];a[:,-1,:3]=[11,14,17];protect[:,0]=True;protect[:,-1]=True
  receipt['root_origins_local']=[[3,46],[44,70]];receipt['root_tips_local']=[[14,53],[33,77]];receipt['root_source_mask_pixels']=int(roots.sum());receipt['outline']='drawn1px ink sides x0,47 retained'
 repaired=cleanup(a,set(zip(*np.nonzero(protect))));a[:,:,3]=ref[:,:,3];a[a[:,:,3]==0,:3]=0
 if sid.endswith('reach'):assert np.array_equal(a[110:],old[110:]),'lower shaft changed'
 Image.fromarray(a).save(d/'native_input.png');tool('prepare_slot.py',[sid,d/'native_input.png',d/'prepared.png'],d/'prepare_slot.py.log');actual=np.array(Image.open(d/'prepared.png').convert('RGBA'))
 if not np.array_equal(actual,a):Image.fromarray(actual).save(d/'prepared-before-registration-restore.png');Image.fromarray(a).save(d/'prepared.png');receipt['post_prepare_registration']='Restored authored reference registration after bounding-box recenter, final bytes validated.'
 tool('validate_slot.py',[sid,d/'prepared.png'],d/'validate_slot.py.log');receipt['colour_joins']=repaired;(d/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');Image.fromarray(a).resize((a.shape[1]*4,a.shape[0]*4),Image.Resampling.NEAREST).save(d/'preview-4x.png');report=json.loads((d/'prepared.png.check.json').read_text());print(sid,report['pass'],[(v['id'],v['result'],v['detail']) for v in report['results']],flush=True)
if __name__=='__main__':
 for sid in ['town.building.hall.reach','town.prop.hall.rise_stair']:build(sid)
