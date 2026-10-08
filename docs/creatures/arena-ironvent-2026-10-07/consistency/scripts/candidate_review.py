"""Review three new arena candidates at game size without changing any source.

Build named small sprites first with an unmodified copy of build_small.py/downscale.py.
This tool compares saved original small PNGs against candidate game PNGs, creates an
8-facing before/after walk contact and animation per form, and validates all full
source alpha/support/foot/canvas/palette/transparent bytes. Inputs remain literal.
"""
from pathlib import Path
import json,hashlib,sys
import numpy as np
from PIL import Image,ImageDraw
W=Path(__file__).resolve().parents[1];C=W/'candidate';O=W/'source-audit/originals'
P=Path(r'C:/Users/pmcga/dev/hollowtide');sys.path.insert(0,str(P/'tools/arena'));from normalize_arena_palette import metrics,lum,sat
FACINGS='s se e ne n nw w sw'.split();NAMES=['cinderhide','clinkerhide','ironvent']
OUT=C/'contacts';OUT.mkdir(exist_ok=True)
audit=json.loads((C/'candidate-audit.json').read_text());proof={'geometry':[],'forms':{},'game_frames':{}}

def small_path(root,n,f,i):return root/f'assets/sprites/arena/{n}/small/walk_{f}_f{i}.png'
def open_array(p):return np.array(Image.open(p).convert('RGBA'))
def checker(width,height):
 a=np.zeros((height,width,3),np.uint8);yy,xx=np.mgrid[:height,:width];m=((xx//12+yy//12)%2)==0;a[m]=[92,119,89];a[~m]=[97,125,95];return Image.fromarray(a)

def contact(n,i):
 w,h=180,190;sheet=checker(w*8,h*2+40);d=ImageDraw.Draw(sheet);d.text((8,6),f'{n} WALK frame {i}: BEFORE top / AFTER bottom; game sprites at x3',fill='white')
 for row,root in enumerate([O,C]):
  for col,f in enumerate(FACINGS):
   a=open_array(small_path(root,n,f,i));im=Image.fromarray(a).resize((a.shape[1]*3,a.shape[0]*3),Image.Resampling.NEAREST);x=col*w+(w-im.width)//2;y=40+row*h+20;sheet.paste(im,(x,y),im);m=metrics(a);d.text((col*w+5,40+row*h),f'{f} L{m["brightness"]:.1f} S{m["saturation_pct"]:.1f}%',fill='white')
 return sheet

for n in NAMES:
 base=open_array(O/f'docs/creatures/arena-starters-2026-10-07/forms/{n}.png');palette=set(map(tuple,base[base[...,3]>0,:3]));info=audit['forms'][n];rows=[]
 rels=[f'assets/sprites/arena/{n}/{f}.png' for f in FACINGS]+[f'docs/creatures/arena-starters-2026-10-07/walk/{p}' for p in info['walk']]
 for rel in rels:
  b=open_array(O/rel);a=open_array(C/rel);on=b[...,3]>0;r={'path':rel,'same_canvas':b.shape==a.shape,'same_alpha':bool(np.array_equal(b[...,3],a[...,3])),'same_support':bool(np.array_equal(on,a[...,3]>0)),'same_transparent_rgba':bool(np.array_equal(b[~on],a[~on])),'exact_base_palette':set(map(tuple,a[on,:3])).issubset(palette),'original_hash':hashlib.sha256((O/rel).read_bytes()).hexdigest(),'candidate_hash':hashlib.sha256((C/rel).read_bytes()).hexdigest(),'same_foot':True}
  if '/walk/' in rel:
   cw=b.shape[0]//2
   for i in range(8):
    y=(i//4)*cw;x=(i%4)*cw
    r['same_foot'] &= metrics(b[y:y+cw,x:x+cw])['foot_row']==metrics(a[y:y+cw,x:x+cw])['foot_row']
  else:r['same_foot']=metrics(b)['foot_row']==metrics(a)['foot_row']
  assert all(r[x] for x in ['same_canvas','same_alpha','same_support','same_transparent_rgba','exact_base_palette','same_foot']),r
  assert r['original_hash']==audit['inputs'][rel],rel
  proof['geometry'].append(r)
 for f in FACINGS:
  frames=[]
  for i in range(8):
   b=open_array(small_path(O,n,f,i));a=open_array(small_path(C,n,f,i));assert b.shape==a.shape;assert np.array_equal(b[...,3],a[...,3]);assert set(map(tuple,a[a[...,3]>0,:3])).issubset(palette)
   frames.append({'frame':i,'before':metrics(b),'after':metrics(a),'same_alpha':True,'same_canvas':True})
  proof['game_frames'][f'{n}/{f}']=frames
 frames=[contact(n,i) for i in range(8)];frames[0].save(OUT/f'{n}_walk_before_after_game3x.png');frames[0].save(OUT/f'{n}_walk_before_after_game3x.gif',save_all=True,append_images=frames[1:],duration=140,loop=0,disposal=2)
 proof['forms'][n]={'full_still_spread_before':info['before_brightness_spread'],'full_still_spread_after':info['after_brightness_spread'],'small_still_spread_before':info['small_before_brightness_spread'],'small_still_spread_after':info['small_after_brightness_spread'],'walk_full_spread_max':max(max(x['after']['brightness'] for x in frames)-min(x['after']['brightness'] for x in frames) for frames in info['walk'].values()),'walk_small_cycle_spread_max':max(max(x['after']['brightness'] for x in proof['game_frames'][f'{n}/{f}'])-min(x['after']['brightness'] for x in proof['game_frames'][f'{n}/{f}']) for f in FACINGS)}
 print(n,proof['forms'][n],flush=True)
(C/'candidate-invariants-and-walk-review.json').write_text(json.dumps(proof,indent=2)+'\n')
print('39 full sources and192 game walk frames validated; contacts/GIFs saved.',flush=True)
