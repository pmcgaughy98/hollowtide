from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
data=json.loads((W/'installed-files.json').read_text());rel='scripts/main_menu.gd';assert sha(L/rel)==data[rel]
raw=(L/rel).read_bytes()
pairs=[(b'Your current save is replaced when the new team reaches Highbank.',b'Saving the new journey will replace your current save.'),(b'# New Game stays as it was and only overwrites the save when the new team first reaches Highbank.',b'# New Game keeps the existing file until the new journey next saves.')]
for a,b in pairs:assert raw.count(a)==1;raw=raw.replace(a,b)
(L/rel).write_bytes(raw);(W/'prepared'/rel).write_bytes(raw);data[rel]=sha(L/rel);(W/'installed-files.json').write_text(json.dumps(data,indent=2))
print('Corrected gated proposal and stale comment: a dungeon suspend can save before Highbank. Flag remains off.')
