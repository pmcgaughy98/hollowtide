from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text(encoding='utf-8'))
plan=json.loads((W/'pending.json').read_text(encoding='utf-8'))
owned={r['path'] for r in plan}
for row in plan:
    assert sha(L/row['path'])==row['after'],row['path']
    if row['before'] is not None:assert sha(Path(row['archive']))==row['before'],row['archive']
prior=(W/'latest-ai-before.md').read_bytes()
header=b'# Working Together on Hollowtide\r\n\r\n' if prior.startswith(b'# Working Together on Hollowtide\r\n\r\n') else b'# Working Together on Hollowtide\n\n'
assert (L/'docs/AI_COLLABORATION.md').read_bytes().endswith(prior[len(header):])
def inspect(item):
    r,h=item;p=L/r
    return r,p.exists() and sha(p)==h
with ThreadPoolExecutor(max_workers=8) as pool:results=dict(pool.map(inspect,[(r,h) for r,h in baseline.items() if r not in owned]))
changed=[r for r,ok in results.items() if not ok]
for r in changed:
    p=L/r
    if p.exists():
        q=W/'concurrent'/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
assets=[r for r in results if r.startswith('assets/')]
audit={'installed_files_exact':len(plan),'original_code_backups_exact':sum(r['before'] is not None for r in plan),'prior_ai_body_exact':True,'protected_files':len(results),'protected_files_exact':sum(results.values()),'asset_files':len(assets),'asset_files_exact':sum(results[r] for r in assets),'concurrent_changed_paths_retained':changed,'mutations_owned_by_this_task':sorted(owned)}
(W/'audit.json').write_text(json.dumps(audit,indent=2),encoding='utf-8')
print(json.dumps(audit,indent=2))
