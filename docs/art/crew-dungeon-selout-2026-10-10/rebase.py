from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
shutil.copytree(W/'review',W/'review-before-valley-update')
shutil.copytree(W/'originals',W/'initial-originals')
base=json.loads((W/'baseline.json').read_text());changed={}
for folder in ['scripts','data','scenes','tools']:
 for p in (L/folder).rglob('*'):
  if not p.is_file() or p.suffix in ['.uid','.import']:continue
  r=p.relative_to(L).as_posix();h=hashlib.sha256(p.read_bytes()).hexdigest()
  if base.get(r)!=h:changed[r]={'before':base.get(r),'current':h}
  if folder!='tools':
   q=C/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
for p in (W/'originals').rglob('*'):
 if p.is_file():
  r=p.relative_to(W/'originals');shutil.copy2(L/r,p);shutil.copy2(L/r,W/'candidate'/r)
(W/'concurrent-valley-update.json').write_text(json.dumps(changed,indent=2))
for r in changed:
 p=W/'concurrent-code'/r;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,p)
shutil.copy2(L/'tools/debug/dungeons_check.gd',W/'dungeons_check.gd')
print('Preserved current concurrent changes:',list(changed))
