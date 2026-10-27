from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json,sys,shutil,subprocess
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide')
sys.path.insert(0,str(L/'tools/arena'))
from downscale import shrink
out=[]
for name in ('sail_slash','mark_glyph'):
 p=L/f'docs/creatures/arena-starters-2026-10-07/vfx/{name}_sheet.png'
 im=Image.open(p).convert('RGBA');print(name,im.size)
 d=W/'originals'/p.relative_to(L);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
 sheet=Image.new('RGB',(4*180,4*180),(30,33,39));dr=ImageDraw.Draw(sheet)
 cw,ch=im.width//4,im.height//4
 for i in range(16):
  x,y=i%4*cw,i//4*ch;cut=im.crop((x,y,x+cw,y+ch));small=shrink(cut,2)
  oldpath=L/f'assets/sprites/arena/vfx/{name}/f{i:02d}.png';old=Image.open(oldpath).convert('RGBA')
  d=W/'originals'/oldpath.relative_to(L);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(oldpath,d)
  row={'name':name,'frame':i,'source_bbox':cut.getchannel('A').getbbox(),'source_alpha_pixels':sum(v>0 for v in cut.getchannel('A').getdata()),'recut_bbox':small.getchannel('A').getbbox(),'old_bbox':old.getchannel('A').getbbox(),'recut_matches':old.tobytes()==small.tobytes(),'old_sha':hashlib.sha256(oldpath.read_bytes()).hexdigest()}
  out.append(row)
  thumb=cut.resize((128,128),Image.Resampling.NEAREST);px=i%4*180+26;py=i//4*180+24;sheet.paste(thumb,(px,py),thumb);dr.text((px,py-19),f'f{i:02d} source {row["source_alpha_pixels"]}',fill='white');dr.text((px,py+132),f'old {row["old_bbox"]}',fill='white')
 sheet.save(W/f'{name}-source-grid.png')
(W/'audit.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out,indent=2))
