from pathlib import Path
import sys,json,shutil,hashlib,re
import numpy as np
from PIL import Image,ImageDraw
sys.dont_write_bytecode=True
R=Path(__file__).parent;C=R.parent;ROOT=R.parents[3];sys.path.insert(0,str(ROOT/'tools/art'));import slot_registry as reg
owned={'town.building.hall.reach':'cx-14-tower-crown','town.prop.hall.rise_stair':'cx-12-tower-foot'};live=reg.load();snap=json.loads((R/'slots.json').read_text())
for sid in owned:assert live['slots'][sid]==snap['slots'][sid]
reg.SLOTS_JSON=R/'slots.json';reg.SLOT_DIR=R/'contract-source/slots';reg.LOADER=R/'contract-source/art_slots.gd';reg.load();import validate_slot,review_sheet
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,o):p.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8')
packet=R/'pass9-reach-stair-review';packet.mkdir(exist_ok=True);(packet/'CODEX_IN_PROGRESS').write_text('Codex finalizing two candidates.\n');lines=[];sem={}
for sid,b in owned.items():
 d=R/sid;main=C/b/sid;a=np.array(Image.open(d/'prepared.png').convert('RGBA'));old=np.array(Image.open(d/'input-before.png').convert('RGBA'));ref=np.array(Image.open(d/'references/target.png').convert('RGBA'));assert np.array_equal(a[:,:,3],ref[:,:,3]);assert validate_slot.run(sid,d/'prepared.png')['pass']
 if sid.endswith('reach'):
  assert np.array_equal(a[110:],old[110:]);assert np.array_equal(a[70:74,87:90],old[70:74,87:90]);features={}
  for name,(x0,y0,x1,y1) in [('222deg',(18,24,41,50)),('312deg',(62,22,91,49))]:
   part=ref[y0:y1,x0:x1];mask=np.all(part[:,:,:3]==[212,169,76],2)|np.all(part[:,:,:3]==[107,79,31],2)|np.all(part[:,:,:3]==[242,210,122],2);assert np.array_equal(a[y0:y1,x0:x1][mask],part[mask]);features[name]=int(mask.sum())
  for x,y in [(40,30),(84,47)]:assert np.array_equal(a[y-3:y+4,x-3:x+4],ref[y-3:y+4,x-3:x+4])
  sem[sid]={'current_reference_alpha_exact':True,'lower190_rows_byte_exact':True,'hook_local_88_72_exact':True,'lashings_reference_brass_pixels':features,'knots_local':[[40,30],[84,47]],'new_taper':'Exact current target alpha; source curl_w goes24px to13px.','optional_trailing_rootlets_added':False}
 else:
  assert np.all(a[:,[0,47],:3]==[11,14,17]);roots=np.zeros(a.shape[:2],bool)
  for color in [[176,107,61],[102,63,35],[63,39,22]]:roots|=np.all(ref[:,:,:3]==color,2)&(ref[:,:,3]>0)
  # The side ink is explicitly drawn over the reference's outermost root-shadow pixel.
  roots[:,[0,47]]=False;assert np.array_equal(a[roots],ref[roots]);assert np.all(a[44,0:6,:3]==[11,14,17]);assert np.all(a[68,41:47,:3]==[11,14,17])
  sem[sid]={'reference_alpha_exact':True,'tread_bands':[[i*12,i*12+11] for i in range(8)],'root_origins_local':[[3,46],[44,70]],'root_tips_local':[[14,53],[33,77]],'crack_lip_rows':[44,68],'reference_root_planes_exact_inside_drawn_side_ink':True,'one_px_side_ink_exact':True,'foot_row':95}
 assert (C/b/'review.json').read_bytes()==(d/'review-before.json').read_bytes()
 archive=main/'before-pass9-refresh-2026-10-28';archive.mkdir(exist_ok=True)
 for p in main.iterdir():
  if p.is_file() and not(archive/p.name).exists():shutil.copy2(p,archive/p.name)
 if (main/'references').exists() and not(archive/'references').exists():shutil.copytree(main/'references',archive/'references')
 for name in ['raw.png','prompt.txt','ledger.json','native_input.png','prepared.png','prepared.png.check.json','prepare_slot.py.log','validate_slot.py.log','cleanup.json','spec-snapshot.json','preview-4x.png','prepared-from-raw.png','prepared-from-raw.png.check.json','prepare-raw.log','validate-raw.log']:shutil.copy2(d/name,main/name)
 shutil.copytree(d/'references',main/'references',dirs_exist_ok=True);write(main/'semantic-checks.json',sem[sid]);write(main/'REVISION_OVERRIDE.json',{'revision':'pass9-reach-stair-2026-10-28','builder':str(R/'build_candidates.py'),'review_packet':str(packet),'original_builder_outdated':True})
 report=validate_slot.run(sid,main/'prepared.png');assert report['pass'];write(main/'prepared.png.check.json',report);line=sid+': PASS; '+', '.join(x['id']+' '+x['result'] for x in report['results']);lines.append(line)
 dest=packet/sid;dest.mkdir(exist_ok=True)
 for name in ['raw.png','prompt.txt','ledger.json','prepared.png','prepared.png.check.json','native_input.png','cleanup.json','spec-snapshot.json','semantic-checks.json','REVISION_OVERRIDE.json']:shutil.copy2(main/name,dest/name)
 shutil.copytree(main/'references',dest/'references',dirs_exist_ok=True);assert sha(main/'raw.png')==json.loads((main/'ledger.json').read_text())['raw_sha256'];assert sha(archive/'prepared.png')==sha(d/'input-before.png');assert sha(dest/'prepared.png')==sha(main/'prepared.png')
assert review_sheet.sheet('pass9-reach-stair-review',packet,packet/'review_sheet.png')==0;review=json.loads((packet/'review.json').read_text())
for sid,b in owned.items():
 assert review['slots'][sid]['answer']=='pending';review['slots'][sid].update({'candidate_sha256':sha(C/b/sid/'prepared.png'),'source_batch':b,'revision':'pass9-reach-stair-2026-10-28'})
write(packet/'review.json',review)
for b in owned.values():assert review_sheet.sheet(b,C/b,C/b/'review_sheet.png')==0
before=json.loads((R/'prepared-before.json').read_text());other=0
for rel,h in before.items():
 p=ROOT/rel
 if p.parent.name not in owned:assert sha(p)==h;other+=1
assert other==52
# Small before/after plate, pixels enlarged4x, no game capture claim.
im=Image.new('RGB',(900,1755),(32,38,34));draw=ImageDraw.Draw(im);draw.text((12,12),'Before',fill='white');draw.text((460,12),'Pass9 update',fill='white');y=40
for sid in owned:
 draw.text((12,y),sid,fill='white');y+=22
 for col,name in enumerate(['input-before.png','prepared.png']):
  art=Image.open(R/sid/name).convert('RGBA');back=review_sheet.checker(*art.size);back.alpha_composite(art);im.paste(back.resize((art.width*4,art.height*4),Image.Resampling.NEAREST).convert('RGB'),(12+448*col,y))
 y+=1200+30 if sid.endswith('reach') else 384
im.save(R/'comparison.png')
# Assemble from individual parts in runtime order to avoid old opaque pixels surviving beneath removed art.
manifest=json.loads((C/'work-manifest.json').read_text());where={sid:C/b/sid/'prepared.png' for b,ids in manifest['batches'].items() for sid in ids};parts=(ROOT/'scripts/town/tower_parts.gd').read_text(encoding='utf-8').split('const PARTS := [')[1].split('\n]')[0];assembly=Image.new('RGBA',(432,720));refs=ROOT/'docs/design/placeholder-factory-2026-10-26/refs'
for sid,x,y,w,h,layer in re.findall(r'"id": "([^"]+)".*?Rect2i\((\d+), (\d+), (\d+), (\d+)\).*?"layer": "([^"]+)"',parts):
 if layer=='prop':continue
 p=where.get(sid,refs/(sid+'.png'));art=Image.open(p).convert('RGBA').crop((0,0,int(w),int(h)));assembly.alpha_composite(art,(int(x),int(y)))
assembly.save(R/'assembly.png');bg=Image.new('RGBA',assembly.size,(41,48,45,255));bg.alpha_composite(assembly);bg.convert('RGB').resize((864,1440),Image.Resampling.NEAREST).save(R/'assembly-2x.png')
write(R/'semantic-checks.json',sem)
issues=['Both built-in outputs were larger than native dimensions. Untouched raw, exact prompts, input snapshots and cleanup receipts retained.','Reach: only upper110rows repainted, with reference-registered bands/knot patches. Lower190rows, loft rootlets, three shaft bands and lamp hook remain exact. Alpha matches current reference. No optional trailing roots added.','Stair: generation had uneven tread heights and misplaced roots. Native recutting produces eight12px bands; misplaced roots removed, current reference root planes and crack lips applied at46/70 and44/68. Side ink stays drawn; source glyph is retained as a small branching inlay.','State_order is now exported for all185slots. Existing lamp layout remains lit/dark; no animation frames or other PNGs were changed in this slice.','No live captures, Finish-shader or gameplay seam approval. Static assembly only; new candidates await Preston.','cx-15 title houses/clouds wait for the great-tree answer under Pass9 H9-08/H9-09. Its existing candidate is retained. cx-10 remains held pending crown approval/current re-brief.','Earlier root redo records are preserved and root R2 remains pending separately. No installs or edits outside candidate folders.']
write(R/'audit.json',{'date':'2026-10-28','registry_sha256':reg.registry_hash(),'passing_slots':2,'check_lines':lines,'other52_images_exact':True,'original_review_answers_preserved':True,'new_answers':'pending','installed':False,'source_issues':issues})
md='# Pass9 Reach and stair refresh, 2026-10-28\n\nBoth candidates pass. Nothing installed. Other52 candidate images are byte-exact.\n\n[New pending review sheet](pass9-reach-stair-review/review_sheet.png) | [Before/after](comparison.png) | [Static Tower assembly](assembly-2x.png)\n\n'+''.join('- '+v+'\n' for v in lines)+'\nThe Reach now follows the new taper with two crosswise lashings and two crook knots. Its lower190rows and hook are unchanged. The stair has eight12px steps, with roots breaking out below the lips at(3,46) and(44,70).\n\nBuilt-in image_gen edits. Each slot folder contains prompt.txt, untouched raw.png, ledger.json, reference snapshots and precise cleanup receipts. New answers pending; earlier answers unchanged.\n\nSource issues for Claude:\n\n'+''.join('- '+v+'\n' for v in issues)+'\nNext safe step: Preston reviews the new Reach/stair and pending crown before cx-10.\n'
(R/'DELIVERY.md').write_text(md,encoding='utf-8');write(R/'STATUS.json',{'state':'submitted_for_review','packet':str(packet),'installed':False})
for sid,b in owned.items():
 p=C/b/'DELIVERY.json';doc=json.loads(p.read_text());doc['PASS9_REFRESH']={'slot':sid,'registry_sha256':reg.registry_hash(),'prepared_sha256':sha(C/b/sid/'prepared.png'),'review_packet':str(packet),'answer':'pending'};write(p,doc)
 p=C/b/'DELIVERY.md';p.write_text(p.read_text(encoding='utf-8')+'\n\n## Pass9 reference refresh,2026-10-28\n\n[Updated Reach/stair candidate, check lines and source issues](../pass9-reach-stair-2026-10-28/DELIVERY.md). This slot image supersedes its earlier delivery; new packet pending. Other batch images and answers unchanged. Nothing installed.\n',encoding='utf-8')
p=C/'candidate-check-inventory-2026-10-27.json';inv=json.loads(p.read_text());inv['last_updated']='2026-10-28';inv['note']='54 passing reports at their recorded versions. Pass9 Reach/stair at ee9c03563b1c pending, launch/road and root R2 pending separately; cx-15 held for great-tree answer. Original answer counts retained.'
for row in inv['slots']:
 if row['slot'] in owned:row.update({'registry_sha256':reg.registry_hash(),'prepared_sha256':sha(C/row['batch']/row['slot']/'prepared.png'),'latest_submission_answer':'pending','latest_review_packet':str(packet)})
write(p,inv)
manifest['pass9_refresh_submissions']={sid:{'sha256':sha(C/b/sid/'prepared.png'),'registry_sha256':reg.registry_hash(),'review_packet':str(packet),'answer':'pending'} for sid,b in owned.items()};manifest['next_work']='Pending Preston review: Pass9 Reach/stair, root R2, launch/road and crown. cx-10 awaits crown approval; cx-15 future repaint waits for great-tree answer. All writes still candidate-only; inspect fresh team notes before choosing more work.'
hold='cx-15 title houses/cloud repaint pending great-tree answer (Pass9 H9-08/H9-09); existing candidate retained'
if hold not in manifest['held']:manifest['held'].append(hold)
write(C/'work-manifest.json',manifest)
p=C/'README.md';t=p.read_text(encoding='utf-8');start=t.index('**');end=t.index('**',start+2);t=t[:start]+'**Latest: Pass9 Reach and stair revisions both PASS, pending review. Nothing installed. Earlier root and launch/road revisions also await review; cx-10 remains held.**'+t[end+2:];p.write_text(t+'\n\n[2026-10-28 Reach/stair update: before/after, exact prompts, checks and source issues](pass9-reach-stair-2026-10-28/DELIVERY.md). Other52 images exact. Future cx-15 repaint waits for the great-tree answer.\n',encoding='utf-8')
p=C/'CONTINUATION_2026-10-27.md';p.write_text(p.read_text(encoding='utf-8')+'\n\n## Pass9 Reach/stair refresh submitted,2026-10-28\n\n'+''.join('- '+v+'\n' for v in lines)+'\n[Review, before/after, prompts and source issues](pass9-reach-stair-2026-10-28/DELIVERY.md). Exact current reference masks, Reach lower190rows/hook protected; eight12px stairs, root/crack geometry verified. Other52 candidate PNGs exact. Prior candidates archived and answers preserved. Nothing installed. Crown/updated art awaits Preston; cx-10 held, future title repaint waits for great-tree answer. Candidate-only scope continues.\n',encoding='utf-8')
for p in [C/b/'CODEX_IN_PROGRESS' for b in owned.values()]+[packet/'CODEX_IN_PROGRESS']:p.unlink()
print('\n'.join(lines));print('52 other images exact. Prior answers preserved. New review pending. No installs.')
