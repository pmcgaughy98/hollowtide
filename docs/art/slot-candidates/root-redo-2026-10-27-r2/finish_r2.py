from pathlib import Path
import sys,json,hashlib,shutil,re
import numpy as np
from PIL import Image,ImageDraw
sys.dont_write_bytecode=True
R=Path(__file__).parent;C=R.parent;ROOT=R.parents[3];sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
meta=json.loads((R/'contract-source.json').read_text());source=R/meta['folder'];reg.SLOTS_JSON=R/'slots.json';reg.SLOT_DIR=source/'slots';reg.LOADER=source/'art_slots.gd';reg.load()
import validate_slot,review_sheet
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,obj):p.write_text(json.dumps(obj,indent=2)+'\n',encoding='utf-8')
owned={'town.building.hall.root_foot':'cx-12-tower-foot','town.building.hall.root_vein':'cx-13-tower-body'}
packet=R/'root-redo-r2-review';packet.mkdir(exist_ok=True)
semantic={};lines=[]
for sid,batch in owned.items():
 d=R/sid;main=C/batch/sid;old=np.array(Image.open(d/'input-before.png').convert('RGBA'));a=np.array(Image.open(d/'prepared.png').convert('RGBA'))
 assert a.shape==old.shape
 if sid.endswith('foot'):
  yy,xx=np.indices(a.shape[:2]);edit=(xx>=5)&(xx<54)&(yy>=65)&(yy<=113)&~((xx>=44)&(yy>=104))
  assert np.array_equal(a[~edit],old[~edit]);semantic[sid]={'protected_outside_elbow_exact':True,'west_bark_rows':[72,110],'join_frame':[90,610],'size':[96,120]}
 else:
  m=old[:,:,3]>0;n=a[:,:,3]>0;allowed=m.copy()
  for dx in range(1,7):allowed[:,dx:]|=m[:,:-dx];allowed[:,:-dx]|=m[:,dx:]
  assert not(n&~allowed).any();assert np.array_equal(n.any(1),m.any(1))
  semantic[sid]={'same_occupied_rows_and_run_breaks':True,'shoulders_max_horizontal_expansion_px':6,'slot_frame_x':[80,139],'nearest_window_x':144,'size':[60,296],'restored_rows':[208,209]}
 archive=main/'before-root-redo-r2-2026-10-27';archive.mkdir(exist_ok=True)
 for p in main.iterdir():
  if p.is_file() and not (archive/p.name).exists():shutil.copy2(p,archive/p.name)
 if (main/'references').is_dir() and not(archive/'references').exists():shutil.copytree(main/'references',archive/'references')
 for p in d.iterdir():
  if p.is_file() and p.name not in ['input-before.png','review-before.json']:shutil.copy2(p,main/p.name)
 shutil.copytree(d/'references',main/'references',dirs_exist_ok=True)
 write(main/'REVISION_OVERRIDE.json',{'revision':'root-redo-2026-10-27-r2','builder':str(R/'build_r2.py'),'pending_review_packet':str(packet),'do_not_rebuild_using_original_batch_builder':True})
 assert (C/batch/'review.json').read_bytes()==(d/'review-before.json').read_bytes(),'original answer changed externally'
 report=validate_slot.run(sid,main/'prepared.png');assert report['pass'];write(main/'prepared.png.check.json',report)
 line=sid+': PASS; '+', '.join(x['id']+' '+x['result'] for x in report['results']);lines.append(line)
 (main/'validate_slot.py.log').write_text(line+'\n',encoding='utf-8')
 dest=packet/sid;dest.mkdir(exist_ok=True)
 for name in ['prepared.png','prepared.png.check.json','raw.png','prompt.txt','ledger.json','cleanup.json','native_input.png','spec-snapshot.json','REVISION_OVERRIDE.json']:
  shutil.copy2(main/name,dest/name)
 shutil.copytree(main/'references',dest/'references',dirs_exist_ok=True)
 write(main/'semantic-checks.json',semantic[sid])
# Authoritative previous decisions remain intact. New packet has independent pending answers.
assert review_sheet.sheet('root-redo-r2-review',packet,packet/'review_sheet.png')==0
review=json.loads((packet/'review.json').read_text())
for sid,batch in owned.items():
 row=review['slots'][sid];assert row['answer']=='pending';row.update({'candidate_sha256':sha(packet/sid/'prepared.png'),'source_batch':batch,'responds_to':json.loads((R/sid/'review-before.json').read_text())['slots'][sid]})
write(packet/'review.json',review)
for batch in owned.values():assert review_sheet.sheet(batch,C/batch,C/batch/'review_sheet.png')==0
before=json.loads((R/'prepared-before.json').read_text());others=[]
for rel,h in before.items():
 p=ROOT/rel
 if p.parent.name not in owned:assert sha(p)==h,rel;others.append(rel)
assert len(others)==52
# Static transparent assembly in the runtime's PARTS order, first frame of moving parts.
manifest=json.loads((C/'work-manifest.json').read_text());where={sid:C/b/sid/'prepared.png' for b,ids in manifest['batches'].items() for sid in ids}
parts=(ROOT/'scripts/town/tower_parts.gd').read_text(encoding='utf-8').split('const PARTS := [')[1].split('\n]')[0]
assembly=Image.new('RGBA',(432,720));refs=ROOT/'docs/design/placeholder-factory-2026-10-26/refs'
for sid,x,y,w,h,layer in re.findall(r'"id": "([^"]+)".*?Rect2i\((\d+), (\d+), (\d+), (\d+)\).*?"layer": "([^"]+)"',parts):
 if layer=='prop':continue
 p=where.get(sid,refs/(sid+'.png'));im=Image.open(p).convert('RGBA').crop((0,0,int(w),int(h)));assembly.alpha_composite(im,(int(x),int(y)))
assembly.save(R/'assembly.png');back=Image.new('RGBA',assembly.size,(41,48,45,255));back.alpha_composite(assembly);back.convert('RGB').resize((864,1440),Image.Resampling.NEAREST).save(R/'assembly-2x.png')
comparison=Image.new('RGB',(860,1320),(32,38,34));draw=ImageDraw.Draw(comparison);draw.text((20,12),'Prior submitted root                 Revised root R2',fill='white')
y=45
for sid in owned:
 draw.text((20,y),sid,fill='white');y+=25
 for col,name in enumerate(['input-before.png','prepared.png']):
  im=Image.open(R/sid/name).convert('RGBA');im=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST);comparison.paste(im,(20+col*430,y),im)
 y+=360 if sid.endswith('foot') else 888
comparison.save(R/'comparison.png')
write(R/'semantic-checks.json',semantic)
sourceissues=['Shared registry/export changed concurrently; checks use the genuine f4423acc8832 export and matching copied registry sources with the normal hash guard. No shared source was edited.','Root note overrides old protruding-root/footing-stone art wording; Claude should reconcile references/brief text.','Launch backdrop tint changed to #18172c and road.backdrop.mid now requires the Tower gap. Their existing candidates need a separate follow-up. Other 52 PNGs are byte-exact; their older reports are not promoted to this contract version.','No in-game captures, Finish shader or runtime seam approval. This is a static art submission.','cx-10 remains held pending crown approval/current re-brief; no installs.']
write(R/'audit.json',{'revision':'R2','registry_sha256':reg.registry_hash(),'checks':lines,'other_candidate_images_unchanged':len(others),'original_redo_answers_preserved':True,'new_packet_answers':'pending','installed':False,'source_issues':sourceissues})
text='# Root redo R2, 2026-10-27\n\nTwo revised roots pass. Nothing installed. Prior candidates archived; the other52 candidate images are byte-exact.\n\n[New pending review sheet](root-redo-r2-review/review_sheet.png) | [Before/after](comparison.png) | [Static Tower assembly](assembly-2x.png)\n\n'+''.join('- '+l+'\n' for l in lines)+'\nFoot: smooth elbow,39px west bark entry; fixed join and right leg retained. Vein: irregular masonry shoulders up to6px beyond the old mask, with the woody centre and all three run breaks preserved. Two resampling omissions restored at rows208 and209.\n\nEarlier redo answers are preserved verbatim. New R2 images await Preston in the versioned packet. Approval to revise is not approval of the result.\n\nSource issues for Claude:\n\n'+''.join('- '+v+'\n' for v in sourceissues)
(R/'DELIVERY.md').write_text(text,encoding='utf-8');(R/'STATUS.json').write_text(json.dumps({'state':'submitted_for_review','installed':False,'packet':str(packet)},indent=2)+'\n',encoding='utf-8')
for sid,batch in owned.items():
 p=C/batch/'DELIVERY.json';data=json.loads(p.read_text());data['ROOT_R2_SUBMISSION']={'slot':sid,'candidate_sha256':sha(C/batch/sid/'prepared.png'),'review_packet':str(packet),'answer':'pending; previous redo preserved'};write(p,data)
 p=C/batch/'DELIVERY.md';t=p.read_text(encoding='utf-8');note='\n\nRoot R2 supersedes the prior root image only. [New pending packet](../root-redo-2026-10-27-r2/DELIVERY.md). Previous redo answer is preserved.\n';p.write_text(t+note,encoding='utf-8')
manifest['redo_responses_submitted']={sid:{'sha256':sha(C/batch/sid/'prepared.png'),'review_packet':str(packet),'answer':'pending'} for sid,batch in owned.items()};manifest['next_work']='Review root R2; follow up launch tint and road mid Tower clearance changed by Claude. cx-10 waits for crown approval.';manifest['all_unheld_work_complete']=False;write(C/'work-manifest.json',manifest)
p=C/'candidate-check-inventory-2026-10-27.json';inventory=json.loads(p.read_text());inventory['note']='54 reports passed their recorded contracts; two roots refreshed at f4423acc8832. Launch tint and road mid brief changed and need follow-up. Original answer counts retained; new root R2 packet pending.'
for row in inventory['slots']:
 sid=row['slot'];reportpath=C/row['batch']/sid/'prepared.png.check.json';report=json.loads(reportpath.read_text());row['registry_sha256']=report['registry_sha256']
 if sid in owned:row['prepared_sha256']=sha(C/row['batch']/sid/'prepared.png');row['r2_submission_answer']='pending';row['r2_review_packet']=str(packet)
write(p,inventory)
p=C/'CONTINUATION_2026-10-27.md';p.write_text(p.read_text(encoding='utf-8')+'\n## Root redo R2 submitted\n\n'+text.split('\n',2)[2],encoding='utf-8')
p=C/'README.md';t=p.read_text(encoding='utf-8');t=t.replace('**54 candidates pass current scripted checks. Nothing installed. Review records: 51 pending, 2 redo, 1 approved reference key.**','**Root R2: two PASS candidates submitted for review. Nothing installed. Other52 candidate images unchanged. Earlier reports use their recorded contracts; launch tint and road mid brief need follow-up.**');p.write_text(t+'\n\n[Latest: root R2 review and source issues](root-redo-2026-10-27-r2/DELIVERY.md). Original2 redo records preserved; new versioned packet pending.\n',encoding='utf-8')
for p in [C/b/'CODEX_IN_PROGRESS' for b in owned.values()]+[packet/'CODEX_IN_PROGRESS']:
 if p.exists():p.unlink()
print('\n'.join(lines));print('52 other PNGs exact. Review pending. No installs.')
