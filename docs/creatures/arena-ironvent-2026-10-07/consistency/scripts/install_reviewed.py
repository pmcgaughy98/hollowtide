"""Install only reviewed Cinderhide-line source PNGs after fresh hash guards.

All original PNGs and audit data are archived first. The existing named-form small
builder runs separately. No game code, approved base, rotation or old-nine art is
written. Rerunnable candidate generation is separate from this guarded install.
"""
from pathlib import Path
import hashlib,json,shutil
W=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-ironvent-consistency-2026-10-07')
P=Path('C:/Users/pmcga/dev/hollowtide')
A=P/'docs/creatures/arena-ironvent-2026-10-07/consistency'
m=json.loads((W/'source-audit/before-manifest.json').read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for group in ['files','protected_code_and_tools','protected_assets']:
    for r in m[group]:
        assert sha(P/r['path'])==r['sha256'],f'Concurrent change detected before install: {r["path"]}'
assert not A.exists(),'Review archive already exists; inspect instead of overwriting prior evidence'
shutil.copytree(W/'source-audit',A/'source-audit')
shutil.copytree(W/'candidate-tools',A/'scripts')
shutil.copy2(W/'candidate/candidate-audit.json',A/'candidate-audit.json')
changes=[]
for r in m['files']:
    rel=r['path']
    source=(rel.startswith('assets/sprites/arena/') and '/small/' not in rel) or '/walk/' in rel
    if not source:continue
    q=W/'candidate'/rel
    assert q.exists(),f'Missing reviewed candidate: {rel}'
    if sha(q)!=r['sha256']:
        shutil.copy2(q,P/rel);changes.append(rel)
shutil.copy2(W/'candidate-tools/report_consistency.py',P/'tools/arena/report_consistency.py')
if (W/'candidate-tools/repair_clinker_curl.py').exists():
    shutil.copy2(W/'candidate-tools/repair_clinker_curl.py',P/'tools/arena/repair_clinker_curl.py')
if (W/'candidate/geometry-repairs.json').exists():
    shutil.copy2(W/'candidate/geometry-repairs.json',A/'geometry-repairs.json')
(A/'installed-source-files.json').write_text(json.dumps(changes,indent=2)+'\n',encoding='utf8')
print(f'Installed {len(changes)} full facings / source walk sheets; originals archived in {A}')