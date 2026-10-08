"""Show the bounded Fusern NW mortar proposal against original and actual W donor."""
from pathlib import Path
import sys,numpy as np
from PIL import Image,ImageDraw
W=Path(__file__).resolve().parents[1];C=W/'candidate';O=W/'source-audit/originals';A=Path('assets/sprites/arena/fusern');OUT=C/'contacts';OUT.mkdir(exist_ok=True)
sys.path.insert(0,str(C/'tools/arena'));from downscale import shrink
original=Image.open(O/A/'nw.png').convert('RGBA');current=Image.open(C/A/'nw.png').convert('RGBA');proposal=Image.open(C/'fusern_nw_donor_proposal.png').convert('RGBA');donor=Image.open(O/A/'w.png').convert('RGBA')
mask=np.array(Image.open(C/'fusern-brick-masks/nw_donor_seam_proposal.png'))>0
allowed=np.array(Image.open(C/'fusern-brick-masks/nw_broad_highlight.png'))>0
rgba=np.array(current);overlay=rgba.copy();overlay[allowed,:3]=[60,160,220];overlay[mask,:3]=[245,220,20]
panels=[('NW original',original),('Role repair',current),('W seam proposal',proposal),('Approved dark W donor',donor),('Blue broad / yellow changed',Image.fromarray(overlay))]
for small,scale,title in [(False,5,'full5x'),(True,3,'game3x')]:
 images=[shrink(im,3) if small else im for _,im in panels];pw=images[0].width*scale+30;ph=images[0].height*scale+50
 sheet=Image.new('RGB',(pw*5,ph),(92,119,89));d=ImageDraw.Draw(sheet)
 for i,((label,_),im) in enumerate(zip(panels,images)):
  d.text((i*pw+8,8),label,fill='white');im=im.resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST);sheet.paste(im,(i*pw+15,38),im)
 sheet.save(OUT/f'fusern_nw_donor_proposal_{title}.png')
print('NW proposal transfers',int(mask.sum()),'actual W seam pixels within',int(allowed.sum()),'existing broad island pixels. Full/game review images saved.')
