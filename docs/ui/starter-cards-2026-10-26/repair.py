from pathlib import Path
import json,hashlib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/soul_prologue.gd'
hashes=json.loads((W/'installed-files.json').read_text())
assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==hashes[rel]
s=(L/rel).read_text()
s=s.replace('\t\tif stage in ["choose", "confirm"]:\n\t\t\tadvance()', '\t\tif stage in ["choose", "confirm"]:\n\t\t\tadvance()\n\t\t\t_accept_released = false   # even a press inside the opening guard needs releasing',1)
s=s.replace('\t\tif not _choice_ready(): return\n\t\tfor k in', '\t\tif not _choice_ready():\n\t\t\t_accept_released = false\n\t\t\treturn\n\t\tfor k in')
assert 'even a press inside' in s
(W/'prepared'/rel).write_text(s,encoding='utf-8');(L/rel).write_text(s,encoding='utf-8')
hashes[rel]=hashlib.sha256((L/rel).read_bytes()).hexdigest();(W/'installed-files.json').write_text(json.dumps(hashes,indent=2))
print('Consumed early guard presses until release, for keyboard/pad/mouse.')
