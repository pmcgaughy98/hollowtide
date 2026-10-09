from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
p=Path('scripts/arena/arena_prototype.gd');old=(L/p).read_bytes();text=old.decode().replace('\r\n','\n')
needle='\tvar art := _load_art(form[0])\n'
assert text.count(needle)==1
(W/'arena-original.gd').write_bytes(old)
(W/'arena-original-sha256.txt').write_text(hashlib.sha256(old).hexdigest())
(C/p).write_text(text.replace(needle,'\tpreload("res://scripts/arena/creature_finish.gd").apply(sprite)\n'+needle))
# Keep latest Hollow and picker scripts for the integration test. Never write them live.
for folder in ['scripts/hollow','scenes']:
 for s in (L/folder).glob('*'):
  if s.is_file():shutil.copy2(s,C/s.relative_to(L))
shutil.copy2(L/'scripts/move_preview.gd',C/'scripts/move_preview.gd')
print('Applied one-line finish hook to latest arena snapshot')
