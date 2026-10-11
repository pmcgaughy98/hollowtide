from pathlib import Path
from PIL import Image
import json,hashlib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project');F=C/'assets/sprites/world/hall_floors_2026_10_11'
manifest=json.loads((W/'native-preparation.json').read_text())
for part in ['floor','north','south']:
    entry=manifest['chamber_'+part]
    old=entry['native'];target=[old[0]+24,old[1]]
    im=Image.open(W/'generation'/entry['source']).convert('RGBA')
    im.crop(entry['region']).resize(target,Image.Resampling.NEAREST).save(F/('chamber_'+part+'.png'))
    entry['native']=target
(W/'native-preparation.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
# Preserve the latest revised painter, adding only our presentation branch.
rel='scripts/town/room_painter.gd';live=(L/rel).read_bytes()
dst=W/'concurrent-before-integration'/rel;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(live)
old=b'\treturn img\r\n\r\n\r\n# ---------------------------------------------------------------- helpers'
new=b'\tif id in ["hall", "hall_low", "chamber", "runners"]:\r\n\t\timg = preload("res://scripts/town/hall_floors_art.gd").paint(id, img)\r\n\treturn img\r\n\r\n\r\n# ---------------------------------------------------------------- helpers'
if b'\r\n' not in live:old=old.replace(b'\r\n',b'\n');new=new.replace(b'\r\n',b'\n')
assert live.count(old)==1
(C/rel).write_bytes(live.replace(old,new))
hashes=json.loads((W/'install-before-hashes.json').read_text());hashes[rel]=hashlib.sha256(live).hexdigest()
(W/'install-before-hashes.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
print('Chamber shell fitted to 17 tiles; current painter retained with one hook.')
