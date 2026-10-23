from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');rel='docs/creatures/arena-starters-2026-10-07/walk/canvaswing_se_sheet.png'
im=Image.open(R/rel).convert('RGBA');size=im.height//2;assert im.width==size*4
(W/'references').mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,W/'references/original-se-sheet.png')
sheet=Image.new('RGB',(4*256,2*282),(37,43,38));draw=ImageDraw.Draw(sheet);facts=[]
for i in range(8):
    cx=i%4*size;cy=i//4*size;f=im.crop((cx,cy,cx+size,cy+size));f.save(W/'references'/f'f{i}.png');box=f.getbbox();colors=f.getcolors(size*size);facts.append({'frame':i,'bbox':box,'pixels':sum(c for c,rgba in colors if rgba[3]),'colors':len([1 for c,rgba in colors if rgba[3]])})
    f=f.resize((256,256),Image.Resampling.NEAREST);x=i%4*256;y=i//4*282;sheet.paste(f,(x,y),f);draw.text((x+8,y+261),f'f{i}',fill='white')
sheet.save(W/'references/original-contact-2x.png')
good=Image.new('RGBA',(size*3,size),(0,0,0,0));good.alpha_composite(im.crop((0,0,size*3,size)),(0,0));good.save(W/'references/good-frames-native.png');good.resize((size*3*4,size*4),Image.Resampling.NEAREST).save(W/'references/good-frames-4x.png')
print('source',im.size,json.dumps(facts))
for folder in ['dungeon','town','small']:
    p=R/'assets/sprites/arena/canvaswing'/folder/'walk_se_f0.png';print(folder,Image.open(p).size)
