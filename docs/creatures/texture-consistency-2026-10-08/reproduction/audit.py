from pathlib import Path
from PIL import Image,ImageDraw
import re,json,hashlib
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide')
lines=re.findall(r'"forms": \[\["(\w+)".*?\["(\w+)".*?\["(\w+)"', (L/'scripts/arena/arena_prototype.gd').read_text())
out=Image.new('RGB',(1200,len(lines)*190),(34,40,46)); d=ImageDraw.Draw(out)
for row,line in enumerate(lines):
 for col,name in enumerate(line):
  x=col*400;y=row*190
  d.text((x+8,y+5),name,fill='white')
  for j,f in enumerate(['s','se','walk_se_f3']):
   p=L/f'assets/sprites/arena/{name}/small/{f}.png'
   if p.exists():
    im=Image.open(p).convert('RGBA');box=im.getbbox(); im=im.crop(box).resize(((box[2]-box[0])*3,(box[3]-box[1])*3),Image.Resampling.NEAREST)
    out.paste(im,(x+j*132+(132-im.width)//2,y+34+140-im.height),im)
  d.text((x+5,y+178),'south / southeast / walk',fill=(170,180,185))
out.save(W/'roster-before.png')
guards={p.relative_to(L).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in (L/'assets/sprites/arena').rglob('*.png')}
(W/'arena-png-baseline.json').write_text(json.dumps(guards,indent=2))
(W/'roster.json').write_text(json.dumps(lines,indent=2))
print(len(lines),'lines',len(guards),'arena PNGs')
