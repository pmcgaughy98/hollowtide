from pathlib import Path
import json,urllib.request,shutil
W=Path(__file__).parent
r=json.loads((W/'generation.json').read_text())
urllib.request.urlretrieve(r['result']['output_urls'][0],W/'town-source.png')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
p=C/'assets/sprites/menu/creature_village_2026_10_09.png'
p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'town-source.png',p)
print('Downloaded original Retro backdrop into review project')
