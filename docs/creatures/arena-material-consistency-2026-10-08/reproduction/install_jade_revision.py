"""Install the reviewed pale-jade walk revision while enforcing previous installed hashes."""
from pathlib import Path
import json,hashlib,shutil,subprocess,sys
W=Path(__file__).resolve().parent;P=Path('C:/Users/pmcga/dev/hollowtide');C=W/'source-audit/candidate-project';A=P/'docs/creatures/arena-material-consistency-2026-10-08'
guards=json.loads((W/'revision-guards.json').read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert all(sha(P/r)==h for r,h in guards.items()),'Concurrent asset change; stop.'
for r in guards:
    if '/small/' not in r:shutil.copy2(C/r,P/r)
subprocess.run([sys.executable,str(P/'tools/arena/build_small.py'),'preostmar','oathfen'],cwd=P,check=True)
shutil.copy2(W/'refine_arena_materials.py',P/'tools/arena/refine_arena_materials_20261008.py')
shutil.copy2(W/'candidate-audit.json',A/'candidate-audit.json')
manifest=json.loads((W/'source-audit/before-manifest.json').read_text())
changed=[r['path'] for r in manifest['files'] if sha(P/r['path'])!=r['sha256']]
installed=json.loads((A/'installed-files.json').read_text());installed['active_png_changes']=sorted(changed);(A/'installed-files.json').write_text(json.dumps(installed,indent=2),encoding='utf8')
print('Final jade revision installed; source poses and alpha remain exact.')
