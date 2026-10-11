from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import re,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
forms=['wayling','swaphoard','pouchbill','inkhoot','cairnshell','crawdukes']
for form in forms:
    for p in (L/'assets/sprites/arena'/form).rglob('*'):
        if not p.is_file():continue
        r=p.relative_to(L);q=C/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
        if p.suffix=='.import':
            for ref in re.findall(r'"res://(\.godot/imported/[^\"]+)"',p.read_text()):
                src=L/ref;dst=C/ref
                if src.is_file():dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
for r in ['scripts/arena/sel_out.gdshaderinc']:
    q=W/'originals'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
print('Synced six new townsfolk; archived original shared shader include.')
