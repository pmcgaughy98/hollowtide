from pathlib import Path
import hashlib,json,runpy
R=Path(__file__).parent;L=R.parents[2];w=runpy.run_path(str(R/'_workflow.py'));reg=w['reg']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
results=[]
for batch,ids in w['BATCHES'].items():
 for sid in ids:
  d=R/batch/sid
  if not (d/'prepared.png.check.json').exists():results.append({'batch':batch,'slot':sid,'status':'not yet prepared'});continue
  report=json.loads((d/'prepared.png.check.json').read_text());ledger=json.loads((d/'ledger.json').read_text())
  assert ledger['raw_sha256']==sha(d/'raw.png'),sid+' raw changed'
  results.append({'batch':batch,'slot':sid,'status':'PASS' if report['pass'] else 'FAIL','check_stamp_current':report['registry_sha256']==reg.registry_hash(),'prepared_sha256':sha(d/'prepared.png'),'raw_sha256':sha(d/'raw.png')})
base=json.loads((R/'protected-before.json').read_text());changes=[rel for rel,h in base.items() if not (L/rel).is_file() or sha(L/rel)!=h]
receipt={'slots':results,'passing_slots':sum(r['status']=='PASS' for r in results),'out_of_scope_files_changed_during_work':changes,'held':['superseded old300x576 Tower candidate','cx-10-road-far pending rebrief'],'pending_export':['new cx-11-cx-14 Tower parts'],'installed_by_codex':False,'registry_sha256':reg.registry_hash()}
(R/'audit.json').write_text(json.dumps(receipt,indent=2));print(json.dumps({'passing':receipt['passing_slots'],'total':len(results),'outside_changes':changes},indent=2))
