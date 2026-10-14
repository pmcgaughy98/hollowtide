from pathlib import Path
import shutil,json,hashlib
W=Path(__file__).parent;P=W/'package'
P.mkdir(exist_ok=True)
for folder in ['references','reference-code','generation','review']:
    shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
shutil.copytree(W/'staging',P/'staging',dirs_exist_ok=True,ignore=shutil.ignore_patterns('.godot'))
cache=P/'staging/.godot';cache.mkdir(exist_ok=True)
shutil.copytree(W/'staging/.godot/imported',cache/'imported',dirs_exist_ok=True)
for name in ['uid_cache.bin','global_script_class_cache.cfg']:
    src=W/'staging/.godot'/name
    if src.exists():shutil.copy2(src,cache/name)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.gd','.json','.md','.txt','.log','.png']:shutil.copy2(p,P/p.name)
(P/'.gdignore').write_text('',encoding='utf-8')
print('Packaged standalone art project, native cache, sources and evidence. No live repo writes.')
