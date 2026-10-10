from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text())
protected=json.loads((W/'preinstall-protected.json').read_text())
pending=json.loads((W/'pending-install.json').read_text())
problems=[];exact=0
for r,h in protected.items():
    if not (L/r).exists() or sha(L/r)!=h:problems.append(r)
    else:exact+=1
for item in pending:
    if sha(L/item['path'])!=item['after']:problems.append(item['path'])
old_art={r:h for r,h in baseline.items() if r.startswith('assets/')}
art_exact=all((L/r).exists() and sha(L/r)==h for r,h in old_art.items())
if not art_exact:problems.append('Original asset hash mismatch')
archive=L/'docs/world/growth-shrine-finish-2026-10-10'
archive_mismatch=[p.relative_to(W/'archive').as_posix() for p in (W/'archive').rglob('*') if p.is_file() and (not (archive/p.relative_to(W/'archive')).exists() or sha(p)!=sha(archive/p.relative_to(W/'archive')))]
result={'protected_exact_since_preinstall':exact,'original_art_and_creatures_unchanged':art_exact,'concurrent_before_install_retained':json.loads((W/'concurrent-before-install.json').read_text()),'problems':problems,'archive_mismatch':archive_mismatch,'owned_runtime_exact':not any(item['path'] in problems for item in pending)}
(W/'installation.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
raise SystemExit(1 if problems or archive_mismatch else 0)
