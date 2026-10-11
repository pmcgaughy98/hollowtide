from pathlib import Path
from PIL import Image
L=Path('C:/Users/pmcga/dev/hollowtide/assets/sprites/arena/skimlet')
for f in ['s.png','sw.png','town/s.png','dungeon/s.png','portrait.png']:
    im=Image.open(L/f).convert('RGBA');points=[]
    for y in range(im.height):
        for x in range(im.width):
            c=im.getpixel((x,y))
            if c[:3] not in [(255,255,255),(225,241,247)] or c[3]<128:continue
            around=[im.getpixel((x+dx,y+dy)) if 0<=x+dx<im.width and 0<=y+dy<im.height else (0,0,0,0) for dx,dy in [(0,1),(0,-1),(1,0),(-1,0),(1,1),(-1,1),(1,-1),(-1,-1)]]
            occupied=sum(a[3]>127 for a in around)
            if occupied<=6:points.append((x,y,occupied,around))
    print(f,points)
