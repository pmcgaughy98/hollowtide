from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import shutil,re,os
L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sync(p):
 r=p.relative_to(L);q=C/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
 count=0
 for ref in re.findall(r'"res://(\.godot/imported/[^\"]+)"',p.read_text()):
  src=L/ref;dst=C/ref
  if src.exists():
   dst.parent.mkdir(parents=True,exist_ok=True)
   if not dst.exists() or src.stat().st_size!=dst.stat().st_size:shutil.copy2(src,dst);count+=1
 source=L/str(r)[:-7]; target=C/str(r)[:-7]
 if source.exists() and target.exists():os.utime(target,ns=(source.stat().st_atime_ns,source.stat().st_mtime_ns))
 return count
paths=list((L/'assets').rglob('*.import'))
with ThreadPoolExecutor(max_workers=12) as pool:count=sum(pool.map(sync,paths))
print('Read-only live cache sync to review:',len(paths),'metadata files,',count,'missing imported payloads.',flush=True)
