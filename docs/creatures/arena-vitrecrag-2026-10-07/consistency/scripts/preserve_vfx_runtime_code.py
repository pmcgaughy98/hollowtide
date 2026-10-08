"""Preserve reviewed concurrent VFX code loaded before the completed native run.

Verify installed art before refreshing only external code guards. No game code,
art, settings or git state is written; original code hashes/snapshots are retained.
"""
from pathlib import Path
from datetime import datetime
import hashlib,json,shutil,subprocess
W=Path(__file__).resolve().parent;P=Path('C:/Users/pmcga/dev/hollowtide');A=P/'docs/creatures/arena-vitrecrag-2026-10-07/consistency'
mp=W/'source-audit/before-manifest.json';m=json.loads(mp.read_text(encoding='utf8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
details=json.loads((A/'installed-proof/original-files-and-protected-code-checks.json').read_text(encoding='utf8'))
for r in details['images']:assert sha(P/r['path'])==r['after_sha256'],'Concurrent installed art change: '+r['path']
for r in m['protected_assets']:assert sha(P/r['path'])==r['sha256'],'Old-form asset change: '+r['path']
runtime=json.loads((W/'runs/runtime_20261007_213008_f3d186a6/receipt.json').read_text(encoding='utf-8-sig'));start=datetime.fromisoformat(runtime['startedUtc']).timestamp()
updates=[]
for r in m['protected_code_and_tools']:
    h=sha(P/r['path'])
    if h==r['sha256']:continue
    if r['path']=='tools/arena/report_consistency.py':assert h==sha(W/'candidate-tools/report_consistency.py');continue
    assert r['path']=='scripts/arena/arena_prototype.gd' and h=='11ab5c4aa55a20854405cb2a836687de29fc1f7212c7bbb6dff9be974cd3a197',r['path']
    assert (P/r['path']).stat().st_mtime<start,'Code changed after runtime launch'
    updates.append((r,h))
assert len(updates)==1
for dest in (W/'source-audit',A/'source-audit'):
    snap=dest/'before-manifest.before-vfx-runtime-refresh.json';assert not snap.exists();shutil.copy2(dest/'before-manifest.json',snap)
    for r,h in updates:
        prior=dest/'externally-updated-code'/r['path'];old=dest/'externally-updated-code-before-vfx'/r['path'];old.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(prior,old);shutil.copy2(P/r['path'],prior)
for r,h in updates:
    m['concurrent_code_changes_before_install'].append({'path':r['path'],'initial_sha256':r['sha256'],'pre_install_sha256':h,'phase':'after art install; before native runtime','reason':'Reviewed Claude painted VFX wiring; code mtime predates owned runtime launch and remains identical after exit. No game code written by Codex.'})
    r.update(sha256=h,bytes=(P/r['path']).stat().st_size)
root_tools={'repair_fusern_brick.py','repair_vitrecrag_seams.py','repair_vitrecrag_core.py','fill_vitrecrag_core_voids.py','audit_fusern_shell.py'}
known={r['path'] for r in m['protected_code_and_tools']};new=[]
for folder,pattern in ((P/'tools/debug','*.gd'),(P/'tools/arena','*.py')):
    for q in folder.glob(pattern):
        rel=q.relative_to(P).as_posix()
        if rel not in known and q.name not in root_tools:
            row={'path':rel,'sha256':sha(q),'bytes':q.stat().st_size};m['protected_code_and_tools'].append(row);new.append(row)
            for dest in (W/'source-audit',A/'source-audit'):
                target=dest/'newer-code-guards'/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(q,target)
m['added_concurrent_code_guards']+=new;m['protected_code_and_tools'].sort(key=lambda r:r['path'])
head=subprocess.check_output(['git','log','-1','--format=%h %cI %s'],cwd=P,text=True).strip()
m['external_commit_during_pass']={'observed_head':head,'performed_by_codex':False,'source':'Claude shared guide and git log; Codex did not stage, commit or reset'}
for dest in (W/'source-audit',A/'source-audit'):(dest/'before-manifest.json').write_text(json.dumps(m,indent=2)+'\n',encoding='utf8')
print(json.dumps({'reviewed_vfx_updates':len(updates),'new_guards':new,'guard_count':len(m['protected_code_and_tools']),'external_head':head,'runtime_used_this_code':True},indent=2))
