from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
baseline=json.loads((W/'baseline.json').read_text(encoding='utf-8'))
pending=json.loads((W/'pending-install.json').read_text(encoding='utf-8'))
owned={d['path'] for d in pending}
def inspect(pair):
 r,h=pair
 if r in owned:return None
 now=sha(L/r)
 if now==h:return None
 q=W/'concurrent-final'/r
 if (L/r).is_file():q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
 return {'path':r,'before':h,'current':now,'preserved':'No task write targets this path; current concurrent version retained.'}
with ThreadPoolExecutor(max_workers=12) as pool:changes=[c for c in pool.map(inspect,baseline.items()) if c]
installed=[d['path'] for d in pending if sha(L/d['path'])==d['after']]
assert len(installed)==len(pending),'Installed candidate changed concurrently; review required.'
initial_note=(W/'originals-current/docs/AI_COLLABORATION.md').read_bytes()
current_note=(L/'docs/AI_COLLABORATION.md').read_bytes()
assert current_note.endswith(initial_note.split(b'\n',2)[2]),'Prior collaboration body must be retained verbatim.'
audit={'installed_exact':installed,'guarded_baseline_files':len(baseline),'protected_exact':len(baseline)-len(owned.intersection(baseline))-len(changes),'concurrent_changes_preserved':changes,'original_asset_files_exact':sum(r.startswith('assets/') and r not in {c['path'] for c in changes} for r in baseline),'prior_collaboration_body_exact':True}
(W/'audit.json').write_text(json.dumps(audit,indent=2),encoding='utf-8')
print(json.dumps(audit,indent=2))
