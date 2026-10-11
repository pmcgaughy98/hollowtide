from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project');r='scripts/town/hollow_approach.gd'
p=W/'initial-originals'/r;p.parent.mkdir(parents=True,exist_ok=True)
if not p.exists():shutil.copy2(W/'originals'/r,p)
shutil.copy2(L/r,W/'originals'/r)
s=(L/r).read_text()
s=s.replace('const ENTRANCE := "res://assets/backgrounds/hollow_entrance.png"','const ENTRANCE := "res://assets/sprites/world/waking_bank_2026_10_10/entrance_native.png"\nconst EntranceFinish := preload("res://scripts/ui/hollow_entrance_finish.gd")')
s=s.replace('entrance.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS','entrance.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST')
old='\tif ResourceLoader.exists(ENTRANCE):\n\t\treturn load(ENTRANCE)\n\treturn ImageTexture.create_from_image(_stand_in())'
new='\tvar img := preload("res://scripts/ui/waking_bank.gd").detailed_image(ENTRANCE)\n\tif img != null:\n\t\tEntranceFinish.apply(entrance, img)\n\t\treturn ImageTexture.create_from_image(EntranceFinish.finished_image(img))\n\treturn ImageTexture.create_from_image(_stand_in())'
assert old in s;s=s.replace(old,new);(C/r).write_text(s)
d=json.loads((W/'install-baseline.json').read_text());d[r]=hashlib.sha256((L/r).read_bytes()).hexdigest();(W/'install-baseline.json').write_text(json.dumps(d,indent=2))
print('Rebased visual loader onto Claude latest node spacing; every movement method retained.')
