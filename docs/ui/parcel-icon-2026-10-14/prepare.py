from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
W.mkdir(exist_ok=True)
protected={}
for folder in ['scripts','scenes','data','dialogue','assets/sprites/ui','tools/ui']:
    for p in (R/folder).rglob('*'):
        if p.is_file():protected[p.relative_to(R).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
(W/'protected.json').write_text(json.dumps(protected,indent=2))
for rel in ['tools/ui/build_icons.py','scripts/town/hub_town.gd','scripts/ui/ui_style.gd','scripts/ui/bag_page.gd','scripts/town/jobs.gd','tools/debug/job_board_check.gd']:
    dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dest)
copied=0
for folder in ['scripts','scenes','data','dialogue','assets','addons','.godot/imported','tools/debug']:
    for p in (R/folder).rglob('*'):
        if not p.is_file():continue
        dest=S/p.relative_to(R)
        if dest.exists() and dest.stat().st_size==p.stat().st_size and abs(dest.stat().st_mtime-p.stat().st_mtime)<0.1:continue
        dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest);copied+=1
for rel in ['project.godot','default_bus_layout.tres','.godot/uid_cache.bin','.godot/global_script_class_cache.cfg']:
    if (R/rel).exists():shutil.copy2(R/rel,S/rel)
print('Protected',len(protected),'source/UI files; refreshed',copied,'staging dependencies. No live files written.')
