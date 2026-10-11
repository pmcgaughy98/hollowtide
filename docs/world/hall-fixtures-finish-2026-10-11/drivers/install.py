from pathlib import Path
import shutil,difflib,hashlib,json
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
owned=['scripts/town/room_painter.gd','scripts/town/hall_floors_art.gd']
for rel in owned:
    assert (C/rel).read_bytes()==(W/'originals'/rel).read_bytes(),f'Concurrent edit detected: {rel}; rebase before installation.'
new='scripts/town/hall_fixtures_art.gd'
assert not (C/new).exists(),'New helper unexpectedly exists; inspect first.'
for rel in owned+[new]:
    shutil.copy2(W/'prepared'/rel,C/rel)
    assert (C/rel).read_bytes()==(W/'prepared'/rel).read_bytes()
diff=''
for rel in owned:
    diff+=''.join(difflib.unified_diff((W/'originals'/rel).read_text().splitlines(True),(C/rel).read_text().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
(W/'hooks.patch').write_text(diff)
shutil.copytree(W/'review/after',W/'review/staging-after',dirs_exist_ok=True)
print('Installed native helper and three guarded presentation hooks; current shared sources matched snapshots.')
