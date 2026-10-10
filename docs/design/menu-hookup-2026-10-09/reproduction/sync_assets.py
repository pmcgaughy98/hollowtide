from pathlib import Path
import hashlib, shutil, json
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide'); C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
changed=[]
for source in (L/'assets').rglob('*'):
    if not source.is_file() or source.suffix in ['.import','.uid','.pyc']: continue
    relative=source.relative_to(L)
    target=C/relative
    if target.exists() and hashlib.sha256(source.read_bytes()).digest()==hashlib.sha256(target.read_bytes()).digest(): continue
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(source,target)
    changed.append(relative.as_posix())
(W/'review-dependency-sync.json').write_text(json.dumps(changed,indent=2))
print('Updated isolated review dependencies:',len(changed),'including',sum('/audio/' in r for r in changed),'audio sources; live files untouched.')
