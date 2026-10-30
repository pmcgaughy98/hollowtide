from pathlib import Path
import datetime, hashlib, json, os, re, shutil, subprocess, sys
sys.dont_write_bytecode=True
L=Path(__file__).resolve().parents[3]
R=L/'docs/art/slot-candidates'
sys.path.insert(0,str(L/'tools/art'))
import slot_registry as reg
BATCHES=json.loads((R/'work-manifest.json').read_text())['batches']
task=(L/'docs/team/CODEX_ART_TASKS_2026-10-26.md').read_text()
m=re.search(r'^## cx-09-road:.*?\n(.*?)(?=^## cx-|\Z)',task,re.M|re.S)
BATCHES['cx-09-road']=re.findall(r'^### [^:]+: ([^ ]+) \(',m[1],re.M)
BATCHES['cx-01-buildings']=[s for s in BATCHES['cx-01-buildings'] if s!='town.building.hall']
ENV=os.environ.copy();ENV['PYTHONDONTWRITEBYTECODE']='1'
def begin(batch):
 b=R/batch;b.mkdir(exist_ok=True)
 lock=b/'CODEX_IN_PROGRESS'
 if not lock.exists():lock.write_text('Codex 2026-10-27. Candidates only, no install.\n')
 for sid in BATCHES[batch]:
  d=b/sid;d.mkdir(exist_ok=True);(d/'spec-snapshot.json').write_text(json.dumps(reg.spec(sid),indent=2))
 return BATCHES[batch]
def ingest(batch,sid,source,prompt):
 assert sid in BATCHES[batch] and sid!='town.building.hall'
 d=R/batch/sid;d.mkdir(parents=True,exist_ok=True)
 if (d/'raw.png').exists():
  n=1
  while (d/('attempt-%02d'%n)).exists():n+=1
  a=d/('attempt-%02d'%n);a.mkdir()
  for p in d.iterdir():
   if p.is_file() and p.name not in ('spec-snapshot.json',):shutil.move(str(p),str(a/p.name))
 shutil.copy2(source,d/'raw.png');(d/'prompt.txt').write_text(prompt,encoding='utf-8')
 from PIL import Image
 spec=reg.spec(sid)
 ledger={'tool':'built-in image_gen','date':'2026-10-27','cost':'not exposed; no paid alternative called','raw_is_untouched':True,'raw_sha256':hashlib.sha256((d/'raw.png').read_bytes()).hexdigest(),'raw_dimensions':list(Image.open(d/'raw.png').size),'target_dimensions':spec['sheet_size'],'references':[str(reg.DOC/'refs'/(sid+s)) for s in ('.png','_grid.png','_card.png')],'source_file':source,'registry_sha256':reg.registry_hash()}
 (d/'ledger.json').write_text(json.dumps(ledger,indent=2))
 for tool,args in [('prepare_slot.py',[sid,str(d/'raw.png'),str(d/'prepared.png')]),('validate_slot.py',[sid,str(d/'prepared.png')])]:
  cmd=[sys.executable,'-B',str(L/'tools/art'/tool)]+args
  r=subprocess.run(cmd,cwd=L,env=ENV,capture_output=True,text=True)
  (d/(tool+'.log')).write_text(r.stdout+r.stderr)
  if r.returncode not in (0,1):raise RuntimeError(r.stdout+r.stderr)
 report=json.loads((d/'prepared.png.check.json').read_text())
 line=sid+': '+('PASS' if report['pass'] else 'FAIL')+'; '+', '.join(x['id']+' '+x['result'] for x in report['results'])
 print(line,flush=True);return report

def references(batch):
 from PIL import Image,ImageDraw
 ids=BATCHES[batch];im=Image.new('RGB',(1200,240*len(ids)),(35,38,40));draw=ImageDraw.Draw(im)
 for k,sid in enumerate(ids):
  spec=reg.spec(sid);print(json.dumps({a:spec.get(a) for a in ('id','brief','size','alpha','anchor','anchors','door_px','outline','tiling','palette','notes')}))
  for j,suffix in enumerate(('.png','_grid.png','_card.png')):
   src=Image.open(reg.DOC/'refs'/(sid+suffix)).convert('RGBA');src.thumbnail((380,200),Image.Resampling.NEAREST)
   im.paste(src,(j*400,k*240+30),src)
  draw.text((4,k*240+5),sid+' | target / grid / card',fill='white')
 out=R/('_references_'+batch+'.png');im.save(out);return out

def finish(batch):
 ids=BATCHES[batch];b=R/batch;lines=[];issues=[]
 for sid in ids:
  d=b/sid;report=json.loads((d/'prepared.png.check.json').read_text())
  assert report['pass'],sid+' is not ready; scripted checks still fail'
  lines.append(sid+': '+('PASS' if report['pass'] else 'FAIL')+'; '+', '.join(x['id']+' '+x['result'] for x in report['results']))
  for x in report['results']:
   if x['result']!='PASS':issues.append(sid+' '+x['id']+' '+x['result']+': '+x['detail'])
  ledger=json.loads((d/'ledger.json').read_text())
  if ledger['raw_dimensions']!=ledger['target_dimensions']:issues.append(sid+': image_gen returned '+str(ledger['raw_dimensions'])+' raw; requested native '+str(ledger['target_dimensions'])+'. Untouched raw preserved; provided prepare_slot produced exact-size candidate.')
 if (b/'extra_source_issues.json').exists():issues.extend(json.loads((b/'extra_source_issues.json').read_text()))
 import review_sheet
 original=review_sheet.batch_slots
 # Exclude the explicitly stopped Tower from this batch's review, without editing its registry or the review tool.
 if batch=='cx-01-buildings':review_sheet.batch_slots=lambda batch_id,folder:ids if batch_id==batch else original(batch_id,folder)
 review_sheet.sheet(batch,b,b/'review_sheet.png')
 review_sheet.batch_slots=original
 issues.append('In-game capture absent: no candidate installed or runtime wiring changed; R4 remains pending Preston/Claude review.')
 if batch=='cx-01-buildings':issues.append('CX-town-1 excluded by direct user request; held files are not delivered. Review membership filtered in memory because stock batch list still includes Tower.')
 text='# '+batch+' candidate delivery, 2026-10-27\n\n'+'\n'.join(lines)+'\n\nSource issues for Claude:\n'+'\n'.join('- '+s for s in issues)+'\n\nNo install. Answers pending Preston. Old Tower candidate excluded. New Tower batches await Claude\'s exported contracts. cx-10-road-far remains held pending its revised brief / approved crown.\n'
 (b/'DELIVERY.md').write_text(text);(b/'delivery.json').write_text(json.dumps({'batch':batch,'slots':ids,'check_lines':lines,'source_issues':issues,'installed':False},indent=2))
 lock=b/'CODEX_IN_PROGRESS'
 if lock.exists():lock.unlink()
 print(text,flush=True)
