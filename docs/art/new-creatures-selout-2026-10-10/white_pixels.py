from pathlib import Path
from PIL import Image
from collections import Counter
L=Path('C:/Users/pmcga/dev/hollowtide')
for file in ['s.png','sw.png','se.png','town/s.png','town/sw.png','dungeon/walk_s_f0.png']:
    p=L/'assets/sprites/arena/skimlet'/file
    if not p.exists():continue
    im=Image.open(p).convert('RGBA')
    points=[(x,y,im.getpixel((x,y))) for y in range(im.height) for x in range(im.width) if min(im.getpixel((x,y))[:3])>=180 and im.getpixel((x,y))[3]>127]
    print(file,im.size,points[:90],len(points))
