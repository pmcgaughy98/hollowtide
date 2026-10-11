from pathlib import Path
from PIL import Image,ImageDraw
import json
W=Path(__file__).parent
names=list(json.loads((W/'stats.json').read_text()))
# Crop only the review layout's transparent margins, never the sprite sources.
for chosen in [False,True]:
    cell=400;out=Image.new('RGB',(cell*4,cell*4),'#242b25');draw=ImageDraw.Draw(out)
    for k,name in enumerate(names):
        rel=f'docs/creatures/arena-starters-2026-10-07/forms/{name}_arena_front_chosen.png' if chosen else f'assets/sprites/arena/{name}/s.png'
        for n,source in enumerate(['originals','prepared']):
            im=Image.open(W/source/rel).convert('RGBA');im=im.crop(im.getbbox())
            factor=min(2,360//im.width,350//im.height)
            assert factor>=1
            im=im.resize((im.width*factor,im.height*factor),Image.Resampling.NEAREST)
            x=(k%2)*cell*2+n*cell;y=(k//2)*cell
            draw.text((x+8,y+8),name+' '+('BEFORE' if n==0 else 'AFTER'),fill='#e4ca8e')
            out.paste(im,(x+(cell-im.width)//2,y+28+(cell-28-im.height)//2),im)
    out.save(W/'review'/('idle_fronts_before_after.png' if chosen else 'facings_before_after.png'))
print('Review overviews corrected to show entire silhouettes.')
