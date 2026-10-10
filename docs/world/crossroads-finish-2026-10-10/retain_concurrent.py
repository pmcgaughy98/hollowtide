from pathlib import Path
import hashlib,json,shutil,subprocess
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text());owned={p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()}
changed=[]
for folder in ['scripts','scenes','assets','data','tools']:
 for p in (L/folder).rglob('*'):
  if not p.is_file() or p.suffix in ['.uid','.import','.pyc']:continue
  r=p.relative_to(L).as_posix()
  if r in owned:continue
  dest=C/r
  if dest.exists() and sha(dest)==sha(p):continue
  if dest.exists():
   prev=W/'concurrent/review-before'/r;prev.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(dest,prev)
   diff=subprocess.run(['git','diff','--no-index','--',str(dest),str(p)],capture_output=True,text=True)
   log=W/'concurrent/diffs'/(r.replace('/','_')+'.diff');log.parent.mkdir(parents=True,exist_ok=True);log.write_text(diff.stdout)
  snap=W/'concurrent/retained'/r;snap.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,snap)
  dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest);changed.append({'path':r,'sha256':sha(p),'new_since_baseline':r not in baseline})
(W/'retained-concurrent.json').write_text(json.dumps(changed,indent=2));print(json.dumps(changed,indent=2))
r='scripts/town/job_board_painter.gd'
assert sha(L/r)==baseline[r],'Board art changed concurrently; inspect before adapting.'
dest=W/'originals'/r;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,dest)
t=dest.read_text();needle='var target := 1.0 if town.panel.get("id", "") == "board" else 0.0';assert t.count(needle)==1
t=t.replace(needle,'# Claude\'s working Board panel identifies itself by service, without a place id.\n\tvar target := 1.0 if town.panel.get("id", "") == "board" or town.panel.get("service", "") == "board" else 0.0')
(W/'candidate'/r).write_text(t)
print('Retained current runtime; presentation-only Board signal adapter prepared.')
