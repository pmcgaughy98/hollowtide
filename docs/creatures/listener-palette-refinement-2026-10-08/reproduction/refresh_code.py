from pathlib import Path
import hashlib,shutil,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
record={};changes=[]
for folder in ['scripts','data','scenes']:
    for p in (L/folder).rglob('*'):
        if not p.is_file():continue
        rel=p.relative_to(L);dst=C/rel
        if not dst.exists() or sha(p)!=sha(dst):
            if dst.exists():
                backup=W/'previous-tested-code'/rel;backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(dst,backup)
            dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst);changes.append(rel.as_posix())
        record[rel.as_posix()]=sha(dst)
shutil.copy2(W/'listener_palette_check.gd',C/'tools/debug/listener_palette_check.gd')
if (W/'native').exists():
    old=W/'prior-native';old.mkdir(exist_ok=True)
    for p in (W/'native').glob('*'):shutil.copy2(p,old/p.name)
(W/'tested-code.json').write_text(json.dumps(record,indent=2))
print('Refreshed',changes)
