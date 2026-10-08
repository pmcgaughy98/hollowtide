"""Install only reviewed Vitrecrag-line source PNGs after fresh hash guards.

All original PNGs and audit data are archived first. The existing named-form small
builder runs separately. No game code, approved base, rotation or previous-twelve art is
written. Rerunnable candidate generation is separate from this guarded install.
"""
from pathlib import Path
import hashlib,json,shutil
W=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-vitrecrag-consistency-2026-10-07')
P=Path('C:/Users/pmcga/dev/hollowtide')
A=P/'docs/creatures/arena-vitrecrag-2026-10-07/consistency'
m=json.loads((W/'source-audit/before-manifest.json').read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for group in ['files','protected_code_and_tools','protected_assets']:
    for r in m[group]:
        assert sha(P/r['path'])==r['sha256'],f'Concurrent change detected before install: {r["path"]}'
assert sha(W/'source-audit/original-tools/tools/arena/report_consistency.py')==sha(P/'tools/arena/report_consistency.py'),'Live report unexpectedly changed; inspect instead of replacing a concurrent edit'
assert (W/'candidate-tools/repair_fusern_brick.py').exists(),'Missing reviewed material tool'
assert (W/'candidate/vitrecrag-crater-repairs.json').exists(),'Missing bounded enclosed-crater repair declaration'
tool_names=['repair_fusern_brick.py','repair_vitrecrag_seams.py','repair_vitrecrag_core.py','fill_vitrecrag_core_voids.py','audit_fusern_shell.py','report_consistency.py']
audit_names=['vitrecrag-crater-repairs.json','vitrecrag-core-audit.json','vitrecrag-enclosed-core-report.json']
for name in tool_names:assert (W/'candidate-tools'/name).exists(),f'Missing accepted repair/report tool: {name}'
for name in audit_names:assert (W/'candidate'/name).exists(),f'Missing final Vitrecrag material evidence: {name}'
for r in m['files']:
    rel=r['path']
    if (rel.startswith('assets/sprites/arena/') and '/small/' not in rel) or '/walk/' in rel:
        assert (W/'candidate'/rel).exists(),f'Missing reviewed candidate: {rel}'
frozen=json.loads((W/'candidate/candidate-manifest.json').read_text(encoding='utf8'))
for rel,h in frozen['candidate_png_sha256'].items():
    assert sha(W/'candidate'/rel)==h,f'Candidate changed after visual review: {rel}'
assert sha(W/'candidate-tools/finalize_vitrecrag_evidence.py')=='8ca0944cfea9076fe749a3e3e442aeed4e7412dcb71bdf26fd1633969e6e4ff9','Finalizer changed after review'
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
for tool_name in tool_names:
    shutil.copy2(W/'candidate-tools'/tool_name,P/'tools/arena'/tool_name)
if (W/'candidate/fusern-brick-audit.json').exists():
    shutil.copy2(W/'candidate/fusern-brick-audit.json',A/'fusern-brick-audit.json')
if (W/'candidate/vitrecrag-seam-audit.json').exists():
    shutil.copy2(W/'candidate/vitrecrag-seam-audit.json',A/'vitrecrag-seam-audit.json')
for name in audit_names:
    shutil.copy2(W/'candidate'/name,A/name)
(A/'installed-source-files.json').write_text(json.dumps(changes,indent=2)+'\n',encoding='utf8')
print(f'Installed {len(changes)} full facings / source walk sheets; originals archived in {A}')
