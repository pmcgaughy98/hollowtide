"""Render current Fusern material candidates, keeping early reviews clearly marked."""
from pathlib import Path
import sys,hashlib,numpy as np
from PIL import Image,ImageDraw
W=Path(__file__).resolve().parents[1];C=W/'candidate';O=W/'source-audit/originals';B=W/'palette-baseline';A=Path('assets/sprites/arena/fusern');OUT=C/'contacts';sys.path.insert(0,str(C/'tools/arena'));from downscale import shrink
sys.path.insert(0,str(W/'candidate-tools'));from repair_fusern_brick import repair,read
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(C/A/'nw.png')==sha(C/'fusern_nw_donor_pattern_proposal.png')==sha(C/'fusern_nw_donor_proposal.png')
stale=OUT/'fusern_brick_roles_before_after_game3x.png';earlier=OUT/'fusern_earlier_role_only_preview_game3x.png'
if stale.exists() and not earlier.exists():earlier.write_bytes(stale.read_bytes())
fs='s se e ne n nw w sw'.split();sheet=Image.new('RGB',(180*8,570),(92,119,89));d=ImageDraw.Draw(sheet)
for row,label in enumerate(['ORIGINAL','PALETTE BASELINE (material drift remains)','FINAL selected brick texture']):
 d.text((8,row*190+6),label+'; actual game pixels x3',fill='white')
 for col,f in enumerate(fs):
  if row==0:im=Image.open(O/A/'small'/f'{f}.png').convert('RGBA')
  elif row==1:im=shrink(Image.open((B if (B/A/f'{f}.png').exists() else C)/A/f'{f}.png'),3)
  else:im=Image.open(C/A/'small'/f'{f}.png').convert('RGBA')
  im=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST);d.text((col*180+5,row*190+28),f,fill='white');sheet.paste(im,(col*180+(180-im.width)//2,row*190+45),im)
sheet.save(stale)
base=read(O/'docs/creatures/arena-starters-2026-10-07/forms/fusern.png');pal=set(map(tuple,base[base[...,3]>0,:3]));original=read(O/A/'nw.png');role,_,masks=repair(original,read(B/A/'nw.png'),pal)
overlay=read(C/A/'nw.png');allowed=masks['broad_highlight'];changed=np.any(overlay!=role,axis=2);overlay[allowed,:3]=[60,160,220];overlay[changed,:3]=[245,220,20]
panels=[('Original NW',Image.fromarray(original)),('Role-only (not selected)',Image.fromarray(role)),('FINAL actual canonical NW',Image.open(C/A/'nw.png').convert('RGBA')),('Accepted W donor',Image.open(C/A/'w.png').convert('RGBA')),('Blue allowed / yellow changed',Image.fromarray(overlay))]
full=Image.new('RGB',(670*5,690),(92,119,89));d=ImageDraw.Draw(full)
for i,(label,im) in enumerate(panels):
 d.text((i*670+8,8),label,fill='white');im=im.resize((im.width*5,im.height*5),Image.Resampling.NEAREST);full.paste(im,(i*670+15,38),im)
full.save(OUT/'fusern_nw_final_texture_restoration_full5x.png')
print('Canonical NW hash matches reviewed option3 and regenerated proposal:',sha(C/A/'nw.png'));print('Allowed island',int(allowed.sum()),'; changed texture pixels',int(changed.sum()))
