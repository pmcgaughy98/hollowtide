from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,shutil,re,os
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
files=[p for folder in ['scripts','data','scenes','assets','tools','docs/creatures/arena-starters-2026-10-07/forms'] for p in (L/folder).rglob('*') if p.is_file() and p.suffix not in ['.import','.uid']]
files += [L/'project.godot',L/'docs/AI_COLLABORATION.md',L/'docs/team/CODEX_HANDOFF_2026-10-10.md']
def sync(p):
    raw=p.read_bytes();r=p.relative_to(L).as_posix();h=hashlib.sha256(raw).hexdigest()
    if r.startswith(('scripts/','data/','scenes/','assets/','tools/','docs/creatures/')) or r=='project.godot':
        q=C/r
        if not q.exists() or hashlib.sha256(q.read_bytes()).hexdigest()!=h:q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
    return r,h
with ThreadPoolExecutor(max_workers=12) as pool:baseline=dict(pool.map(sync,files))
(W/'baseline.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
for r in ['scripts/arena/creature_finish.gd','scripts/ui/crew_portrait_canvas.gd','scripts/ui/ui_style.gd','scripts/town/hub_town.gd','scripts/town/board_scene.gd','docs/AI_COLLABORATION.md']:
    q=W/'originals'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
def imports(p):
    r=p.relative_to(L);q=C/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
    for ref in re.findall(r'"res://(\.godot/imported/[^\"]+)"',p.read_text(encoding='utf-8')):
        src=L/ref;dst=C/ref
        if src.is_file():
            dst.parent.mkdir(parents=True,exist_ok=True)
            if not dst.exists() or hashlib.sha256(src.read_bytes()).hexdigest()!=hashlib.sha256(dst.read_bytes()).hexdigest():shutil.copy2(src,dst)
    src=L/str(r)[:-7];dst=C/str(r)[:-7]
    if src.exists() and dst.exists():os.utime(dst,ns=(src.stat().st_atime_ns,src.stat().st_mtime_ns))
with ThreadPoolExecutor(max_workers=12) as pool:list(pool.map(imports,(L/'assets').rglob('*.import')))
shutil.copy2(Path('D:/dev/hollowtide-launch-frames-20261010/run.py'),W/'run.py')
print('Synced source/current native import cache; guarded',len(baseline),'files. No live writes.')
