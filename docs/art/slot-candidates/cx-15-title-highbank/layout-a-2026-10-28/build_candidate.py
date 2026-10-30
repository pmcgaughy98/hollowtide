from pathlib import Path
import sys,json,subprocess,os,shutil
import numpy as np
from PIL import Image
sys.dont_write_bytecode=True
R=Path(__file__).parent;B=R.parent;ROOT=R.parents[4];sys.path.insert(0,str(ROOT/'tools/art'));import slot_registry as reg
reg.SLOTS_JSON=R/'slots.json';reg.SLOT_DIR=R/'contract-source/slots';reg.LOADER=R/'contract-source/art_slots.gd';reg.load();import prepare_slot
SID='title.backdrop.highbank';s=reg.spec(SID);old=np.array(Image.open(R/'input-before.png').convert('RGBA'));raw=Image.open(R/'raw.png').convert('RGBA').resize((384,216),Image.Resampling.BOX);a0=np.array(raw);ref=np.array(Image.open(R/'references/target.png').convert('RGBA'));tree=np.array(Image.open(R/'tree-component.png').convert('RGBA'));tower=np.array(Image.open(R/'tower-component.png').convert('RGBA'));yy,xx=np.indices(old.shape[:2]);protected=(xx<80)|(yy>=182)|((xx>=21)&(xx<129)&(yy>=108)&(yy<200))|((xx>=86)&(xx<280)&(yy>=144)&(yy<182));a=old.copy();tm=(tree[:,:,3]>0)&(yy<126);region=(xx>=284)&(yy<182)
# Register the new tree to its exact coded silhouette; the painted source's crown was several pixels left of centre.
treecrop=raw.crop((118,6,285,120)).resize((158,120),Image.Resampling.BOX);painttree=Image.new('RGBA',(384,216));painttree.alpha_composite(treecrop,(130,6));painttree=np.array(painttree);a[tm]=painttree[tm]
# Remove the old small Tower completely; keep the new source's background outside the huge plinth/Stack.
a[region]=ref[region];tower_mask=tower[:,:,3]>0
for y in range(168):
 dst=np.flatnonzero(tower_mask[y]);
 if not len(dst):continue
 xmin=int(dst.min());search=300 if y<124 else 268;rgb=a0[y,:,:3].astype(float);warm=(rgb[:,0]>rgb[:,1]*1.08)&(rgb[:,0]>rgb[:,2]*1.2);xs=np.flatnonzero(warm&(np.arange(384)>=search));srcmin=int(xs.min()) if len(xs) else xmin
 # Keep the arched door axis fixed while recutting the two wider plinth faces.
 if y>=124:
  left=raw.crop((srcmin,y,333,y+1)).resize((333-xmin,1),Image.Resampling.BOX);row=np.array(left)[0];a[y,xmin:333]=row;a[y,333:]=a0[y,333:]
 else:
  row=np.array(raw.crop((srcmin,y,384,y+1)).resize((384-xmin,1),Image.Resampling.BOX))[0];a[y,xmin:]=row
 # Restore source background in tiny cutouts and between rootlets.
 a[y,~tower_mask[y]&region[y]]=ref[y,~tower_mask[y]&region[y]]
# Register the grounded root's brown planes and small roots directly to the updated source geometry.
root=(tower[:,:,3]>0)&(tower[:,:,0]>tower[:,:,1]*1.30)&(tower[:,:,1]>tower[:,:,2]*1.2);a[root]=tower[root];a[145:168,327:340]=ref[145:168,327:340]
# The upper wordmark crown is just its body and rim; the right strip has the exact current pre-shade.
calm=(xx>=90)&(xx<296)&(yy<52);a[tm&calm]=ref[tm&calm];a[:50,312:]=ref[:50,312:]
# These sky columns are not part of either giant. Keep their seam a quiet continuation of the existing bands.
for y in range(50):a[y,296:312,:3]=[30,48,46] if y<26 else[38,61,58]
# Thin source-registered waylines; never paint over retained house interiors or menu pixels.
lines=np.array(Image.open(R/'lines-component.png').convert('RGBA'));wire=(lines[:,:,3]>0)&~protected;a[wire]=lines[wire]
a[protected]=old[protected];a[:,:,3]=255
# Snap edited regions to the actual source PALETTE47. Shared34-strip comparison remains separate and authoritative.
source_doc=R/'source-palette-contract';reg.DOC=source_doc;snapped=np.array(prepare_slot.snap(Image.fromarray(a),s));snapped[protected]=old[protected];a=snapped;assert len(np.unique(a[:,:,:3].reshape(-1,3),axis=0))<=48
protect=protected|wire|root;protect[145:168,327:340]=True;protect[:52]=True;repaired=0
for y in range(216):
 for x in range(384):
  if protect[y,x]:continue
  near=[(ny,nx) for ny,nx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=ny<216 and 0<=nx<384]
  if any(np.array_equal(a[y,x,:3],a[ny,nx,:3]) for ny,nx in near):continue
  def score(p):
   ny,nx=p;v=a[ny,nx,:3];ct=sum(0<=ay<216 and 0<=ax<384 and np.array_equal(v,a[ay,ax,:3]) for ay,ax in ((ny-1,nx),(ny+1,nx),(ny,nx-1),(ny,nx+1)))
   return(ct,-int(((v.astype(int)-a[y,x,:3].astype(int))**2).sum()))
  ny,nx=max(near,key=score);a[y,x,:3]=a[ny,nx,:3];repaired+=1
assert np.array_equal(a[protected],old[protected]);Image.fromarray(a).save(R/'native_input.png');np.save(R/'protected-mask.npy',protected)
# Both real tool paths run unchanged: shared-palette output and source-palette-preserving output.
wrapper=(R/'with_contract.py').read_text(encoding='utf-8');wrapper=wrapper.replace("name=sys.argv.pop(1)","reg.DOC=R/'source-palette-contract'\nname=sys.argv.pop(1)");(R/'with_source_palette.py').write_text(wrapper,encoding='utf-8')
def tool(wrapper,name,args,log):
 p=subprocess.run([sys.executable,'-B',str(R/wrapper),name,*map(str,args)],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));(R/log).write_text(p.stdout+p.stderr,encoding='utf-8');assert p.returncode in (0,1),p.stdout+p.stderr;return p.returncode
for name,args,log in [('prepare_slot.py',[SID,R/'raw.png',R/'prepared-from-raw.png'],'prepare-raw.log'),('validate_slot.py',[SID,R/'prepared-from-raw.png'],'validate-raw.log'),('prepare_slot.py',[SID,R/'native_input.png',R/'prepared-published-palette.png'],'prepare-published-palette.log')]:tool('with_contract.py',name,args,log)
tool('with_source_palette.py','prepare_slot.py',[SID,R/'native_input.png',R/'prepared-source-palette.png'],'prepare-source-palette.log');assert np.array_equal(np.array(Image.open(R/'prepared-source-palette.png').convert('RGBA')),a);shutil.copy2(R/'prepared-source-palette.png',R/'prepared.png')
tool('with_contract.py','validate_slot.py',[SID,R/'prepared.png'],'validate-shared-palette.log');tool('with_source_palette.py','validate_slot.py',[SID,R/'prepared-source-palette.png'],'validate-source-palette.log')
report=json.loads((R/'prepared-source-palette.png.check.json').read_text());report['palette_source_note']='Exact47colours from current title_highbank.gd PALETTE; published strip has34and omits protected colours. This diagnostic is not the main shared-palette report.';(R/'prepared-source-palette.png.check.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
receipt={'raw_untouched':True,'authorized_cleanup':True,'protected_old_pixels_exact':int(protected.sum()),'protected_regions':'left tree x<80; menu21,108..129,200; houses86..279,y144..181; river/road from182down','tree_mask':'current source silhouette clipped behind far forest at126','old_small_tower_removed':'whole right region x284..383,y0..181 rebuilt','root_geometry':'current grounded source planes and two short ground grips','door_anchor':[333,160],'old_lamp_anchor_removed':True,'source_palette':'real PALETTE47 copied without source edits','shared_palette':'34exported colours conflict with preserved art','colour_joins':repaired};(R/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');Image.fromarray(a).resize((1152,648),Image.Resampling.NEAREST).save(R/'preview-3x.png');print('Source palette:',report['pass']);shared=json.loads((R/'prepared.png.check.json').read_text());print('Published strip:',shared['pass'],[(v['id'],v['result'],v['detail']) for v in shared['results']]);print('Protected pixels exact',int(protected.sum()))
