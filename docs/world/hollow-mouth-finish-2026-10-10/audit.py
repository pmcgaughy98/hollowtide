from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'baseline.json').read_text());protected=json.loads((W/'preinstall-protected.json').read_text());pending=json.loads((W/'pending-install.json').read_text())
problems=[];exact=0;retained={}
accepted=json.loads((W/'accepted-post-preinstall.json').read_text()) if (W/'accepted-post-preinstall.json').exists() else {}
for r,h in protected.items():
 if not (L/r).exists() or sha(L/r)!=h:
  if r in accepted and (L/r).exists() and sha(L/r)==accepted[r]['sha256']:retained[r]=accepted[r]
  else:problems.append(r)
 else:exact+=1
for item in pending:
 if not (L/item['path']).exists() or sha(L/item['path'])!=item['after']:
  r=item['path']
  if r=='docs/AI_COLLABORATION.md' and r in accepted and (L/r).exists() and sha(L/r)==accepted[r]['sha256']:retained[r]=accepted[r]
  else:problems.append(r)
art={r:h for r,h in base.items() if r.startswith('assets/')}
asset_exceptions={'assets/audio/music/monster_house.mp3':'cddf8fe0aa188c90cbebfdc81e7281b5b15e0dd9ee371831a32bbb252f858cb8','assets/audio/_440hz_originals/retuned.txt':'dcc507d7756953a0016a94a40427cc1001447e212de504c21d6ab73ae9304621'} # Inspected Claude's appended pond-garden retuning record; no art bytes.
art_exact=all((L/r).exists() and sha(L/r)==asset_exceptions.get(r,h) for r,h in art.items())
if not art_exact:problems.append('Original asset hash mismatch')
target=L/'docs/world/hollow-mouth-finish-2026-10-10'
mismatch=[p.relative_to(W/'archive').as_posix() for p in (W/'archive').rglob('*') if p.is_file() and (not (target/p.relative_to(W/'archive')).exists() or sha(p)!=sha(target/p.relative_to(W/'archive')))]
result={'protected_exact_since_preinstall':exact,'original_art_and_creatures_unchanged':art_exact,'concurrent_before_install_retained':json.loads((W/'concurrent-before-install.json').read_text()),'concurrent_after_preinstall_retained':retained,'owned_runtime_exact':not any(item['path'] in problems for item in pending),'problems':problems,'archive_mismatch':mismatch}
(W/'installation.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2));raise SystemExit(1 if problems or mismatch else 0)
