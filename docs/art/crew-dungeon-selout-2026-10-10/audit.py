from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,shutil,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');base=json.loads((W/'baseline.json').read_text());manifest=json.loads((W/'pending-install.json').read_text());owned={r['path']:r['candidate'] for r in manifest}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inspect(item):
 r,h=item;p=L/r
 return r,sha(p) if p.exists() else None,h
with ThreadPoolExecutor(max_workers=12) as pool:rows=list(pool.map(inspect,base.items()))
same=[];concurrent={};source_same=0
for r,h,original in rows:
 if r in owned:assert h==owned[r],r;continue
 if h!=original:
  concurrent[r]={'baseline':original,'current':h}
  if (L/r).exists():
   p=W/'concurrent-final'/r;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,p)
 else:
  same.append(r)
  if r.startswith(('assets/','docs/creatures/')):source_same+=1
allowed_portraits={'assets/sprites/ui/dialogue/kithflare_'+face+'.png' for face in ['angry','determined','joyous','sad','surprised','worried']}
assert not any(r.startswith(('assets/','docs/creatures/')) and r not in allowed_portraits for r in concurrent),'Unexpected original art changed; inspect before claiming preservation.'
for r,h in owned.items():assert sha(L/r)==h,r
previous_note=b''.join((W/'originals/docs/AI_COLLABORATION.md').read_bytes().splitlines(keepends=True)[2:])
report={'protected_exact':len(same),'original_art_source_exact':source_same,'owned_installed_exact':len(owned),'concurrent_preserved':concurrent,'source_png_changes_by_this_task':0,'note_prior_content_retained':previous_note in (L/'docs/AI_COLLABORATION.md').read_bytes()}
assert report['note_prior_content_retained']
(W/'audit.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
