"""Create read-only enlarged pixel guides for the documented Clinkerhide south curl."""
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFont
W=Path(__file__).resolve().parent.parent
P=W/'source-audit/originals/docs/creatures/arena-starters-2026-10-07/walk/clinkerhide_s_sheet.png'
im=Image.open(P).convert('RGBA');a=np.array(im);cw=im.height//2
assert im.size==(576,288) and cw==144
O=W/'clinker-curl-review';O.mkdir(exist_ok=True)
for i in range(8):
 fr=im.crop(((i%4)*cw,(i//4)*cw,(i%4+1)*cw,(i//4+1)*cw))
 crop=fr.crop((48,16,96,56));large=crop.resize((480,400),Image.Resampling.NEAREST)
 bg=Image.new('RGB',(520,440),(245,245,245));bg.paste(large,(32,25),large);dr=ImageDraw.Draw(bg)
 for x in range(48,97):
  px=32+(x-48)*10
  if x%5==0:dr.text((px,4),str(x),fill='black')
  dr.line([(px,25),(px,425)],fill=(210,210,210),width=1)
 for y in range(16,57):
  py=25+(y-16)*10
  if y%5==0:dr.text((2,py),str(y),fill='black')
  dr.line([(32,py),(512,py)],fill=(210,210,210),width=1)
 dr.text((35,428),f'frame{i}; x48..95 y16..55; coordinates within144x144cell',fill='black')
 bg.save(O/f'south_f{i}_crest_grid10x.png')
 print('f',i,'opaque bounds',fr.getbbox())
