from pathlib import Path
import sys,json,os,subprocess,shutil,hashlib
import numpy as np
from PIL import Image
sys.dont_write_bytecode=True
R=Path(__file__).parent;C=R.parent;ROOT=R.parents[3];sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
reg.SLOTS_JSON=C/'final-contract-check/slots.json'
def tool(name,args,log):
 p=subprocess.run([sys.executable,'-B',str(C/'final-contract-check/with_current_contract.py'),name,*map(str,args)],env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),capture_output=True,text=True);log.write_text(p.stdout+p.stderr,encoding='utf-8')
 if p.returncode not in (0,1):raise RuntimeError(p.stdout+p.stderr)
 return p.returncode

def build(batch,sid):
 parent=C/batch/sid;D=parent/'revisions/great-tree-2026-10-27';spec=reg.spec(sid);raw=Image.open(D/'raw.png').convert('RGBA');old=np.array(Image.open(D/'input-before.png').convert('RGBA'));cw,ch=spec['size'];foot=sid.endswith('root_foot');receipt={'approved_note':'CODEX_ROOT_NOTE.md, Preston go','raw_untouched':True,'native_size':[cw,ch]}
 tool('prepare_slot.py',[sid,D/'raw.png',D/'prepared-from-raw.png'],D/'prepare-raw.log');tool('validate_slot.py',[sid,D/'prepared-from-raw.png'],D/'validate-raw.log')
 if foot:
  bb=raw.getchannel('A').point(lambda v:255 if v>=128 else 0).getbbox();assert bb
  small=raw.crop(bb).convert('RGBa').resize((cw,117),Image.Resampling.BOX).convert('RGBA');im=Image.new('RGBA',(cw,ch));im.alpha_composite(small,(0,3));a=np.array(im);a[:,:,3]=np.where(a[:,:,3]>=128,255,0);source=a.copy();warp=[]
  # Widen the actual generated arriving bark, tapering the correction into its elbow.
  for x in range(25):
   ys=np.flatnonzero(source[88:,x,3]>0)+88
   if not len(ys):continue
   lo,hi=int(ys.min()),int(ys.max())+1;top=round(72+1.0*x);bottom=120
   strip=Image.fromarray(source[lo:hi,x:x+1]).resize((1,bottom-top),Image.Resampling.NEAREST);v=np.array(strip)[:,0]
   if x<=10:a[70:,x]=0
   take=v[:,3]>0;a[top:bottom,x][take]=v[take];warp.append({'x':x,'source_rows':[lo,hi],'destination_rows':[top,bottom]})
  # The near side disappears under a ragged turf lip; the west woody cross-section is y72..110 (39px).
  turf=np.array([[107,111,29],[107,109,69],[68,66,26]],dtype=np.uint8)
  for x in range(25):
   top=111+x//6-(1 if (x//2)%3==1 else 0)
   for y in range(top,120):a[y,x,:3]=turf[(x//4+y//3)%3];a[y,x,3]=255
  yy,xx=np.indices((ch,cw));edit=(yy>=52)&(xx<56);a[~edit]=old[~edit];receipt['incoming_bark_registration_warp']=warp;receipt['west_root_cross_section']=[72,110];receipt['turf_occlusion']='Ragged near-side turf begins y111 at west edge, using three existing turf colours; baseline remains119.';receipt['second_image_edit']='Tool blocked output; no second image generated or used. Authorized pixel cleanup applied to first returned edit.'
  # Existing turf at the baseline is retained, without keeping the old brown flare or any stone.
  green=(old[:,:,1]>=old[:,:,0]*.9)&(old[:,:,1]>old[:,:,2]*1.3)&(old[:,:,3]>0)&(yy>=115);a[green]=old[green];receipt['upper_join_and_secondary_leg_protected']='all pixels outside x0..55,y52..119 exact';receipt['preserved_baseline_turf_pixels']=int(green.sum())
 else:
  bb=raw.getchannel('A').point(lambda v:255 if v>=128 else 0).getbbox();tb=Image.fromarray(old).getchannel('A').getbbox();assert bb and tb
  small=raw.crop(bb).convert('RGBa').resize((tb[2]-tb[0],tb[3]-tb[1]),Image.Resampling.BOX).convert('RGBA');im=Image.new('RGBA',(cw,ch));im.alpha_composite(small,(tb[0],tb[1]));a=np.array(im);m=old[:,:,3]>0;holes=m&(a[:,:,3]<128);a[holes]=old[holes];a[:,:,3]=old[:,:,3];receipt['source_crop']=list(bb);receipt['target_box']=list(tb);receipt['alpha_exact']=True;edit=m
 if not foot:
  m=old[:,:,3]>0;occupied=m.any(axis=1);starts=np.flatnonzero(occupied&~np.r_[False,occupied[:-1]]);ends=np.flatnonzero(occupied&~np.r_[occupied[1:],False]);caps=[]
  for start,end in zip(starts,ends):
   for y in range(int(end)-2,int(end)+1):
    xs=np.flatnonzero(m[y]);
    for x in xs:a[y,x,:3]=[156,140,104] if y<int(end) else [95,94,87]
   caps.append([int(end)-2,int(end)])
  receipt['masonry_overhang_row_bands']=caps;receipt['masonry_overhang']='Three-pixel stone lips cross the exposed bark at the existing breaks, within the unchanged mask.'
 a[a[:,:,3]==0,:3]=0;opaque=a[:,:,3]>0;palette=np.array(reg.palette(spec),dtype=np.int32);px=a[opaque,:3].astype(np.int32)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=palette[((chunk[:,None,:]-palette[None,:,:])**2).sum(2).argmin(1)]
 co,ct=np.unique(px,axis=0,return_counts=True);chosen=[v.tolist() for v in np.unique(old[old[:,:,3]>0,:3],axis=0)]
 for v in [co[i].tolist() for i in np.argsort(-ct)]:
  if v not in chosen:chosen.append(v)
  if len(chosen)>=32:break
 pal=np.array(chosen,dtype=np.int32)
 for i in range(0,len(px),16384):
  chunk=px[i:i+16384];px[i:i+16384]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
 a[opaque,:3]=px.astype(np.uint8);repaired=0
 # Sequential joining is monotone: an orphan joins an existing colour cluster without swapping orphan pairs.
 for y in range(ch):
  for x in range(cw):
   if not edit[y,x] or not a[y,x,3]:continue
   near=[(ny,nx) for ny,nx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=ny<ch and 0<=nx<cw and a[ny,nx,3]]
   if not near or any(np.array_equal(a[y,x,:3],a[ny,nx,:3]) for ny,nx in near):continue
   def score(pos):
    ny,nx=pos;colour=a[ny,nx,:3];count=sum(0<=ay<ch and 0<=ax<cw and a[ay,ax,3] and np.array_equal(a[ay,ax,:3],colour) for ay,ax in ((ny-1,nx),(ny,nx-1),(ny+1,nx),(ny,nx+1)))
    return(count,-int(((colour.astype(int)-a[y,x,:3].astype(int))**2).sum()))
   ny,nx=max(near,key=score);a[y,x,:3]=a[ny,nx,:3];repaired+=1
 if foot:assert np.array_equal(a[~edit],old[~edit]),'protected upper/leg changed'
 else:assert np.array_equal(a[:,:,3],old[:,:,3])
 Image.fromarray(a).save(D/'native_input.png');tool('prepare_slot.py',[sid,D/'native_input.png',D/'prepared.png'],D/'prepare_slot.py.log')
 actual=np.array(Image.open(D/'prepared.png').convert('RGBA'))
 if not np.array_equal(actual,a):
  shutil.copy2(D/'prepared.png',D/'prepared-before-registration-restore.png');Image.fromarray(a).save(D/'prepared.png');receipt['post_prepare_registration']='restored exact native registration after tool centering, then validated final bytes'
 tool('validate_slot.py',[sid,D/'prepared.png'],D/'validate_slot.py.log');Image.fromarray(a).resize((cw*3,ch*3),Image.Resampling.NEAREST).save(D/'preview-3x.png');receipt['sequential_colour_joins']=repaired;receipt['new_colours']=len(np.unique(a[a[:,:,3]>0,:3],axis=0));receipt['prepared_sha256']=hashlib.sha256((D/'prepared.png').read_bytes()).hexdigest();(D/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
 report=json.loads((D/'prepared.png.check.json').read_text(encoding='utf-8'));print(sid,report['pass'],[(r['id'],r['result'],r['detail']) for r in report['results'] if r['result']!='PASS'],flush=True)
 return report
if __name__=='__main__':build(sys.argv[1],sys.argv[2])
