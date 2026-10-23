from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'project'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
B=json.loads((W/'protected-before.json').read_text());unexpected=[p for p,h in B.items() if not (R/p).exists() or sha(R/p)!=h]
log=(W/'native-candidate.log').read_text();assert 'CANVASWING WALK: 64/64' in log and not any(s in log for s in ['ERROR','WARNING','FAIL'])
build=json.loads((W/'final-build.json').read_text());selected=build['selected']+['docs/creatures/arena-starters-2026-10-07/walk/canvaswing_se_sheet.png'];assert len(selected)==31
assert not set(unexpected)&set(selected),'Concurrent edit of owned artwork'
assert all(p.startswith('scripts/') and (R/p).is_file() for p in unexpected),unexpected
concurrent={}
for rel in unexpected:
    dst=W/'concurrent-at-install'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dst);concurrent[rel]=sha(R/rel)
(W/'concurrent-at-install.json').write_text(json.dumps(concurrent,indent=2),encoding='utf-8')
for rel in selected:
    backup=W/'original-installed'/rel;backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,backup);shutil.copy2(P/rel,R/rel)
(W/'installed-files.json').write_text(json.dumps({rel:sha(R/rel) for rel in selected},indent=2),encoding='utf-8');print('Installed one repaired source sheet and30 selected frames; preserved',len(concurrent),'concurrently edited scripts, all other protected files exact.')
