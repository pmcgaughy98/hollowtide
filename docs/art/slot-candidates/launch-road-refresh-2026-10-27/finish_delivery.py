from pathlib import Path
import sys,json,shutil,hashlib
import numpy as np
from PIL import Image,ImageDraw
sys.dont_write_bytecode=True
R=Path(__file__).parent;C=R.parent;ROOT=R.parents[3];sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
live=reg.load();saved=json.loads((R/'slots.json').read_text());owned={'title.backdrop.launch':'cx-06-title','road.backdrop.mid':'cx-09-road'}
for sid in owned:assert live['slots'][sid]==saved['slots'][sid],'Shared target contract changed; re-read before submission'
reg.SLOTS_JSON=R/'slots.json';reg.SLOT_DIR=R/'contract-source/slots';reg.LOADER=R/'contract-source/art_slots.gd';reg.load()
import validate_slot,review_sheet
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,o):p.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8')
packet=R/'launch-road-review';packet.mkdir(exist_ok=True);(packet/'CODEX_IN_PROGRESS').write_text('Codex finalizing current revisions.\n')
sem={};lines=[]
for sid,b in owned.items():
 d=R/sid;main=C/b/sid;a=np.array(Image.open(d/'prepared.png').convert('RGBA'));assert validate_slot.run(sid,d/'prepared.png')['pass']
 if sid.endswith('mid'):
  forbidden=np.r_[0:59,228:384];assert not(a[:52,forbidden,3]>0).any();assert np.array_equal(a[:,0],a[:,-1]);assert not(a[:104,np.r_[0:60,226:384],3]>0).any()
  sem[sid]={'tower_corridor_opaque_pixels':int((a[:52,forbidden,3]>0).sum()),'corridor_columns':'228..383 and0..58','corridor_rows':'0..51','willow_group_x':[60,225],'outside_group_above_row104_opaque':0,'rgba_wrap_endpoints_exact':True,'tower_in_game_visibility':'Not tested; this measures the candidate against the source clearance envelope.'}
 else:
  exact=int(np.all(a[:,:,:3]==[24,23,44],axis=2).sum());assert exact>20000;assert(a[:,:,3]==255).all();sem[sid]={'updated_night_tint':'#18172c','exact_tint_pixel_count':exact,'colours':len(np.unique(a[:,:,:3].reshape(-1,3),axis=0)),'opaque':True}
 assert (C/b/'review.json').read_bytes()==(d/'review-before.json').read_bytes(),'Review changed externally'
 archive=main/'before-launch-road-refresh-2026-10-27';archive.mkdir(exist_ok=True)
 for p in main.iterdir():
  if p.is_file() and not(archive/p.name).exists():shutil.copy2(p,archive/p.name)
 if (main/'references').exists() and not(archive/'references').exists():shutil.copytree(main/'references',archive/'references')
 for name in ['raw.png','prompt.txt','ledger.json','native_input.png','prepared.png','prepared.png.check.json','prepare_slot.py.log','validate_slot.py.log','cleanup.json','spec-snapshot.json','preview-3x.png','prepared-from-raw.png','prepared-from-raw.png.check.json','prepare-raw.log','validate-raw.log']:
  shutil.copy2(d/name,main/name)
 shutil.copytree(d/'references',main/'references',dirs_exist_ok=True)
 write(main/'REVISION_OVERRIDE.json',{'revision':'launch-road-refresh-2026-10-27','builder':str(R/'build_candidates.py'),'review_packet':str(packet),'original_batch_builder_outdated':True})
 write(main/'semantic-checks.json',sem[sid]);report=validate_slot.run(sid,main/'prepared.png');assert report['pass'];write(main/'prepared.png.check.json',report)
 line=sid+': PASS; '+', '.join(x['id']+' '+x['result'] for x in report['results']);lines.append(line)
 dest=packet/sid;dest.mkdir(exist_ok=True)
 for name in ['raw.png','prompt.txt','ledger.json','prepared.png','prepared.png.check.json','native_input.png','cleanup.json','spec-snapshot.json','semantic-checks.json','REVISION_OVERRIDE.json']:shutil.copy2(main/name,dest/name)
 shutil.copytree(main/'references',dest/'references',dirs_exist_ok=True)
 assert sha(main/'raw.png')==json.loads((main/'ledger.json').read_text())['raw_sha256']
 assert sha(archive/'prepared.png')==sha(d/'input-before.png')
 assert sha(dest/'prepared.png')==sha(main/'prepared.png')
assert review_sheet.sheet('launch-road-review',packet,packet/'review_sheet.png')==0
rv=json.loads((packet/'review.json').read_text())
for sid,b in owned.items():
 assert rv['slots'][sid]['answer']=='pending';rv['slots'][sid].update({'candidate_sha256':sha(C/b/sid/'prepared.png'),'source_batch':b,'revision':'launch-road-refresh-2026-10-27'})
write(packet/'review.json',rv)
for b in owned.values():assert review_sheet.sheet(b,C/b,C/b/'review_sheet.png')==0
before=json.loads((R/'prepared-before.json').read_text());others=[]
for rel,h in before.items():
 p=ROOT/rel
 if p.parent.name not in owned:assert sha(p)==h;others.append(rel)
assert len(others)==52
# Before/after comparison, native pixels enlarged exactly2x.
comparison=Image.new('RGB',(1572,794),(32,38,34));dr=ImageDraw.Draw(comparison);dr.text((12,12),'Before',fill='white');dr.text((798,12),'Updated candidate',fill='white');y=36
for sid in owned:
 dr.text((12,y),sid,fill='white');y+=20
 for col,name in enumerate(['input-before.png','prepared.png']):
  im=Image.open(R/sid/name).convert('RGBA');back=review_sheet.checker(*im.size);back.alpha_composite(im);comparison.paste(back.resize((im.width*2,im.height*2),Image.Resampling.NEAREST).convert('RGB'),(12+col*786,y))
 y+=432+22 if sid.endswith('launch') else 224
comparison.save(R/'comparison.png')
road=Image.open(R/'road.backdrop.mid/prepared.png').convert('RGBA');two=review_sheet.checker(768,112);two.alpha_composite(road,(0,0));two.alpha_composite(road,(384,0));two.resize((1536,224),Image.Resampling.NEAREST).convert('RGB').save(R/'road-two-tile-preview.png')
gap=review_sheet.checker(384,112);dd=ImageDraw.Draw(gap);dd.rectangle((228,0,383,51),fill=(31,62,74,255));dd.rectangle((0,0,58,51),fill=(31,62,74,255));gap.alpha_composite(road);gap.resize((1152,336),Image.Resampling.NEAREST).save(R/'road-clearance-preview.png')
write(R/'semantic-checks.json',sem)
issues=['Generated outputs were larger than requested native dimensions. Raw files are untouched; native recutting, palette snapping, colour joins and grass wrap cleanup were explicitly authorized.','prepare_slot bounding-box fit can move asymmetrically arranged transparent strips. Native road registration was restored after preparation and final bytes validated.','The source corridor is empty in the candidate and the wrap endpoints match exactly. No live candidate injection or runtime four-talk visibility check was run; review sheet captures remain absent.','Launch source brief still says dark greens and river blues while the updated tint/reference is #18172c. Candidate uses the updated nine-colour night palette and retains green banks and blue water.','Only these two reports were refreshed at ee9c03563b1c. Other52 PNGs and their earlier checks were preserved; no blanket claim that all54 meet every latest brief.','No install. cx-10-road-far still waits for explicit crown approval/current re-brief. Previous root redo decisions remain intact; root R2 is pending in its own review packet.']
audit={'date':'2026-10-27','registry_sha256':reg.registry_hash(),'shared_contract_match_at_submission':True,'passing_slots':2,'check_lines':lines,'other52_candidate_images_exact':True,'original_review_answers_preserved':True,'new_packet_answers':'pending','installed':False,'source_issues':issues};write(R/'audit.json',audit)
md='# Launch tint and road Tower-clearance refresh, 2026-10-27\n\nBoth candidates pass. Nothing installed. Other52 candidate images are byte-exact, including both root R2 images.\n\n[Review sheet](launch-road-review/review_sheet.png) | [Before/after](comparison.png) | [Two road tiles](road-two-tile-preview.png) | [Clearance envelope](road-clearance-preview.png)\n\n'+''.join('- '+line+'\n' for line in lines)+'\nLaunch:384x216,9colours,24,755pixels at #18172c. Road:384x112,14colours,two willows in x60..225. Zero opaque pixels in x228..383 and0..58 above row52; RGBA wrap seam exact.\n\nBuilt-in image_gen edits; exact prompts and input snapshots are in each slot folder. Raw outputs retained. New review answers pending; original answers unchanged.\n\nSource issues for Claude:\n\n'+''.join('- '+v+'\n' for v in issues)+'\nNext safe step: Preston reviews this packet and the pending root/crown art. cx-10 stays held.\n'
(R/'DELIVERY.md').write_text(md,encoding='utf-8');write(R/'STATUS.json',{'state':'submitted_for_review','installed':False,'packet':str(packet)})
for sid,b in owned.items():
 p=C/b/'DELIVERY.json';data=json.loads(p.read_text());data['LATEST_REVISION']={'slot':sid,'revision':'launch-road-refresh-2026-10-27','registry_sha256':reg.registry_hash(),'check_line':next(x for x in lines if x.startswith(sid+':')),'prepared_sha256':sha(C/b/sid/'prepared.png'),'review_packet':str(packet),'answer':'pending'};write(p,data)
 p=C/b/'DELIVERY.md';p.write_text(p.read_text(encoding='utf-8')+'\n\n## Latest candidate revision, 2026-10-27\n\n[Launch tint / road Tower clearance delivery](../launch-road-refresh-2026-10-27/DELIVERY.md) supersedes this slot image and its older art notes. Old candidate archived; review pending; no install.\n',encoding='utf-8')
p=C/'candidate-check-inventory-2026-10-27.json';inv=json.loads(p.read_text());inv['note']='54 passing reports at their per-slot recorded registry versions. Latest launch/road revisions at ee9c03563b1c and root R2 at f4423acc8832 await review. No all-current-contract claim. Original answer counts retained.'
for row in inv['slots']:
 if row['slot'] in owned:row.update({'registry_sha256':reg.registry_hash(),'prepared_sha256':sha(C/row['batch']/row['slot']/'prepared.png'),'latest_submission_answer':'pending','latest_review_packet':str(packet)})
write(p,inv)
p=C/'work-manifest.json';manifest=json.loads(p.read_text());manifest['contract_refresh_submissions']={sid:{'sha256':sha(C/b/sid/'prepared.png'),'registry_sha256':reg.registry_hash(),'review_packet':str(packet),'answer':'pending'} for sid,b in owned.items()};manifest['next_work']='Pending Preston visual review of launch/road revisions, root R2 and crown. cx-10 stays held until crown approval/current re-brief. Check latest collaboration notes for new assigned work.';write(p,manifest)
p=C/'README.md';t=p.read_text(encoding='utf-8');t=t.replace('**Root R2: two PASS candidates submitted for review. Nothing installed. Other52 candidate images unchanged. Earlier reports use their recorded contracts; launch tint and road mid brief need follow-up.**','**Latest: launch tint and road Tower-clearance revisions both PASS, submitted for review. Nothing installed. Root R2 and crown also await review. Earlier candidates retain their recorded contract versions.**');p.write_text(t+'\n\n[Latest launch/road revisions: checks and source issues](launch-road-refresh-2026-10-27/DELIVERY.md). Both pending. Other52 images exact.\n',encoding='utf-8')
p=C/'CONTINUATION_2026-10-27.md';p.write_text(p.read_text(encoding='utf-8')+'\n\n## Launch tint and road Tower clearance submitted\n\n'+''.join('- '+line+'\n' for line in lines)+'\n[Review, exact prompts, before/after and source issues](launch-road-refresh-2026-10-27/DELIVERY.md). Updated night palette; two willows grouped within60..225; forbidden corridor alpha0, wrap RGBA exact. Other52 candidate PNGs exact. Previous candidates and answers retained. No installs or runtime candidate captures. Next: pending visual reviews; cx-10 remains gated.\n',encoding='utf-8')
for p in [C/b/'CODEX_IN_PROGRESS' for b in owned.values()]+[packet/'CODEX_IN_PROGRESS']:p.unlink()
print('\n'.join(lines));print('Other52 PNGs exact. Review answers preserved. Pending new packet. Nothing installed.')
