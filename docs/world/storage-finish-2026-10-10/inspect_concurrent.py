from pathlib import Path
import difflib,json,hashlib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
changes=json.loads((W/'concurrent-before-install.json').read_text())
for r in changes:
    p=C/r
    if p.exists():
        diff=list(difflib.unified_diff(p.read_text().splitlines(True),(L/r).read_text().splitlines(True)))
        print(r);print(''.join(diff[:18]))
archive=L/'docs/world/storage-finish-2026-10-10'
missing=[]
for p in (W/'archive').rglob('*'):
    if p.is_file():
        target=archive/p.relative_to(W/'archive')
        if not target.exists() or hashlib.sha256(p.read_bytes()).digest()!=hashlib.sha256(target.read_bytes()).digest():missing.append(p.relative_to(W/'archive').as_posix())
print('Archive differences:',missing)
(W/'archive-verification.json').write_text(json.dumps({'missing_or_different':missing},indent=2))
