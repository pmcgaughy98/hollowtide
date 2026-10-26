from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
data=json.loads((W/'installed-files.json').read_text());rel='scripts/creature_opening.gd'
assert sha(L/rel)==data[rel]
raw=(L/rel).read_bytes();old=b'var active := topic==["journey","controls"][i]';new=b'var active: bool = topic==["journey","controls"][i]';assert raw.count(old)==1
(W/'installed-before-type-repair.gd').write_bytes(raw)
(L/rel).write_bytes(raw.replace(old,new));data[rel]=sha(L/rel);(W/'installed-files.json').write_text(json.dumps(data,indent=2))
print('Corrected explicit boolean type in the owned tab-state code; hash-guarded repair.')
