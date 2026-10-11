from pathlib import Path
import hashlib,shutil,json,difflib
W=Path(__file__).parent
R=Path('C:/Users/pmcga/dev/hollowtide')
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
old=W/'originals/riverbank_painter.gd';live=R/'scripts/dungeon/riverbank_painter.gd'
assert digest(old)==digest(live), 'Claude changed the owned painter; rebase before installing.'
new=R/'scripts/dungeon/rootbank_detail.gd'
assert not new.exists(), 'Rootbank helper already exists; inspect before overwriting.'
snapshot=json.loads((W/'protected.json').read_text())
changed=[rel for rel,sha in snapshot.items() if not (R/rel).exists() or digest(R/rel)!=sha]
(W/'concurrent-before-install.json').write_text(json.dumps(changed,indent=2))
diff=''.join(difflib.unified_diff(old.read_text().splitlines(True),(W/'riverbank_painter.gd').read_text().splitlines(True),fromfile='original/riverbank_painter.gd',tofile='installed/riverbank_painter.gd'))
diff+=''.join(difflib.unified_diff([], (W/'rootbank_detail.gd').read_text().splitlines(True),fromfile='/dev/null',tofile='installed/rootbank_detail.gd'))
(W/'rootbank.diff').write_text(diff)
for name in ['riverbank_painter.gd','rootbank_detail.gd']:
    shutil.copy2(W/name,R/'scripts/dungeon'/name)
    assert digest(W/name)==digest(R/'scripts/dungeon'/name)
print('Installed two presentation files. Concurrent source edits preserved:',changed)
