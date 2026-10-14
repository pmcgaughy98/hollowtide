from pathlib import Path
import json,hashlib,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
receipt=json.loads((W/'stage-audit.json').read_text(encoding='utf-8'))
assert receipt['native_total']>=40
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
assert all(sha(R/r)==h for r,h in protected.items()),'Concurrent source edit; stop.'
for rel,h in receipt['installed_file_hashes'].items():assert sha(W/'prepared'/rel)==h
new=[r for r in receipt['installed_file_hashes'] if r not in receipt['expected_changed_files']]
assert all(not (R/r).exists() for r in new),'A proposed new file already exists.'
for rel,h in receipt['installed_file_hashes'].items():
    dst=R/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'prepared'/rel,dst);assert sha(dst)==h
for rel in json.loads((W/'imported-files.json').read_text(encoding='utf-8')):
    dst=R/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(S/rel,dst)
print('Installed14 scoped art/script files plus native import metadata/cache. Storage rules/state/saves untouched; one pause save call extended to the new room.')
