from pathlib import Path
import json,hashlib,shutil,sys,subprocess,ast
import numpy as np
from PIL import Image,ImageDraw,ImageFont
R=Path('C:/Users/pmcga/dev/hollowtide'); B=R/'docs/art/slot-candidates/cx-15-title-highbank'; P=B/'patch-repaint'
sys.path.insert(0,str(R/'tools/art')); import slot_registry as reg
raw=Path('C:/Users/pmcga/.codex/generated_images/01a12b4b-7982-7b32-b405-2a584762f412/exec-f8abc405-c510-46d9-b0a7-e1d41dbed455.png')
shutil.copy2(raw,P/'raw.png')
before=np.array(Image.open(P/'before.png').convert('RGBA'))
generated=np.array(Image.open(P/'raw.png').convert('RGBA').resize((384,216),Image.Resampling.BOX))
yy,xx=np.indices((216,384)); allowed=np.array(Image.open(P/'allowed-area.png'))>0
# Restore every landmark, including the tree's limbs and the Tower's brass reel, using the existing exact masks.
old=B/'layout-a-2026-10-28'
tree=np.array(Image.open(old/'tree-component.png').convert('RGBA'))[:,:,3]>0
tree &= yy<126
tower=np.array(Image.open(old/'tower-component.png').convert('RGBA'))[:,:,3]>0
mask=allowed & ~tree & ~tower
# The old cable rectangles include distant sky/hills. Preserve these and the existing forest skyline exactly.
mask &= (yy>=140) | ((yy>=120)&(xx>=170)&(xx<=305))
# Keep y179..188 repaint confined to the old house band, never the right Tower steps or river bluff face.
mask &= (yy<183)|((xx>=88)&(xx<=268))
# Pixel-aligned, palette-snapped joining across the permitted edge. This is compositing, not repeated/copied foliage.
distance=np.zeros(mask.shape,dtype=np.int16); interior=mask.copy()
for n in range(1,7):
 distance[interior]=n
 padded=np.pad(interior,1)
 interior=interior & padded[:-2,1:-1] & padded[2:,1:-1] & padded[1:-1,:-2] & padded[1:-1,2:]
weights=np.minimum(distance/5.0,1)[...,None]
rgb=np.rint(before[:,:,:3]*(1-weights)+generated[:,:,:3]*weights).astype('uint8')
palette=np.asarray(reg.palette(reg.spec('title.backdrop.highbank')),dtype=int)
pixels=rgb[mask].astype(int)
snapped=palette[((pixels[:,None]-palette[None])**2).sum(-1).argmin(-1)]
candidate=before.copy();candidate[mask,:3]=snapped
# Use the existing cleanup's pixel-neighbour rule. Restore protected pixels after every pass.
module=ast.parse((R/'tools/art/clean_slot.py').read_text(encoding='utf-8'))
names={'luma','snap_index','neighbours8','orphan_mask','_pair','clear_orphans'}
namespace={'np':np}
exec(compile(ast.Module(body=[n for n in module.body if isinstance(n,ast.FunctionDef) and n.name in names],type_ignores=[]),'clean_slot_helpers','exec'),namespace)
indices=namespace['snap_index'](candidate[:,:,:3],palette)
fixed_indices=indices.copy()
for _ in range(4):
 indices=namespace['clear_orphans'](indices,palette,keep=40)
 indices[~mask]=fixed_indices[~mask]
candidate[mask,:3]=palette[indices[mask]]
Image.fromarray(candidate).save(P/'native-input.png')
Image.fromarray(mask.astype('uint8')*255).save(P/'edit-mask.png')
python=sys.executable
def run(name,args,log):
 p=subprocess.run([python,'-B',str(R/'tools/art'/name),*map(str,args)],cwd=R,capture_output=True,text=True)
 (P/log).write_text(p.stdout+p.stderr,encoding='utf-8');print(p.stdout+p.stderr);assert p.returncode==0
run('prepare_slot.py',['title.backdrop.highbank',P/'native-input.png',P/'candidate.png'],'prepare.log')
run('validate_slot.py',['title.backdrop.highbank',P/'candidate.png'],'validate.log')
final=np.array(Image.open(P/'candidate.png').convert('RGBA'))
assert np.array_equal(final[~mask],before[~mask]),'Protected pixels changed'
assert np.array_equal(final,candidate),'Preparation unexpectedly changed registered pixels'
Image.fromarray(final).resize((1152,648),Image.Resampling.NEAREST).save(P/'candidate-3x.png')
before_band=Image.fromarray(before).crop((0,60,311,196)).resize((933,408),Image.Resampling.NEAREST)
after_band=Image.fromarray(final).crop((0,60,311,196)).resize((933,408),Image.Resampling.NEAREST)
before_band.save(P/'before-band-3x.png');after_band.save(P/'after-band-3x.png')
sheet=Image.new('RGB',(933,864),(24,31,32));d=ImageDraw.Draw(sheet)
d.text((10,8),'BEFORE - installed patch, 3x native pixels',fill=(239,224,192));sheet.paste(before_band,(0,24))
d.text((10,440),'AFTER - repaint candidate, 3x native pixels - NOT INSTALLED',fill=(239,224,192));sheet.paste(after_band,(0,456))
sheet.save(P/'before-after-3x.png')
hashes=json.loads((P/'source-before.json').read_text());changed={p:{'before':h,'after':hashlib.sha256((R/p).read_bytes()).hexdigest() if (R/p).is_file() else None} for p,h in hashes.items() if not (R/p).is_file() or hashlib.sha256((R/p).read_bytes()).hexdigest()!=h}
expected='docs/design/placeholder-factory-2026-10-26/slots.json'
assert set(changed)<= {expected},changed
report=json.loads((P/'candidate.png.check.json').read_text())
audit={'before_sha256':hashlib.sha256((P/'before.png').read_bytes()).hexdigest(),'candidate_sha256':hashlib.sha256((P/'candidate.png').read_bytes()).hexdigest(),'raw_sha256':hashlib.sha256((P/'raw.png').read_bytes()).hexdigest(),'raw_size':Image.open(P/'raw.png').size,'candidate_size':[384,216],'changed_pixels':int(np.any(final!=before,axis=-1).sum()),'editable_pixels':int(mask.sum()),'protected_pixels_exact':int((~mask).sum()),'outside_task_rectangles_exact':bool(np.array_equal(final[~allowed],before[~allowed])),'great_tree_exact':bool(np.array_equal(final[tree],before[tree])),'tower_root_reel_steps_exact':bool(np.array_equal(final[tower],before[tower])),'watched_source_files':len(hashes),'watched_differences':changed,'installed_asset_unchanged':hashlib.sha256((R/'assets/slots/title/backdrop/highbank.png').read_bytes()).hexdigest()==hashlib.sha256((P/'before.png').read_bytes()).hexdigest(),'checks_pass':report['pass'],'registry_sha256':report['registry_sha256'],'review':'pending; prior approvals apply to installed no-wires version, not this repaint','installed':False}
(P/'audit.json').write_text(json.dumps(audit,indent=2)+'\n')
ledger={'date':'2026-10-29 America/Chicago','tool':'built-in image_gen edit','generation_count':1,'credit_authorization':'Preston approved one image edit in this chat','cost':'not exposed by tool','edit_target':str(R/'assets/slots/title/backdrop/highbank.png'),'raw_source':str(raw),'raw_untouched':True,'native_preparation':'One whole-frame BOX reduction, mask composite, five-native-pixel palette-snapped join inside edit mask; source landmarks restored exactly. No foliage clones or mirroring.','palette':'47-colour shared highbank_title; source unchanged','visual_approval':'pending','installed':False}
(P/'ledger.json').write_text(json.dumps(ledger,indent=2)+'\n')
print(json.dumps(audit,indent=2))
