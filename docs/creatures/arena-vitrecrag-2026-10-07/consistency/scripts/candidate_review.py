"""Review actual new-three arena candidates and tightly scoped crater-hole repairs.

Build only named small sprites first with an unchanged build_small.py/downscale.py.
Without --geometry-repairs, every source alpha/transparent byte must be exact.
The optional explicit fill_enclosed_crater JSON requires the complete coordinate
set of 0-to-255 additions and independently proves each original 8-connected
transparent component is wholly enclosed in its frame. No generic alpha waiver,
removal, exterior expansion, pose/canvas/foot move, or RGB palette exemption exists.
Game frames must byte-match the actual existing shrink/mirror pipeline; source and
game alpha changes are reported honestly, separately from permitted defect repair.
"""
from pathlib import Path
from collections import deque
import argparse,json,hashlib,sys
import numpy as np
from PIL import Image,ImageDraw,ImageOps
W=Path(__file__).resolve().parents[1];C=W/'candidate';O=W/'source-audit/originals';P=Path(r'C:/Users/pmcga/dev/hollowtide')
sys.path.insert(0,str(P/'tools/arena'));from normalize_arena_palette import metrics,lum,sat
sys.path.insert(0,str(C/'tools/arena'));from downscale import shrink
FACINGS='s se e ne n nw w sw'.split();NAMES=['fusern','slagglass','vitrecrag'];MIRRORS={'nw':'ne','w':'e','sw':'se'}
OUT=C/'contacts';OUT.mkdir(exist_ok=True)
ap=argparse.ArgumentParser();ap.add_argument('--geometry-repairs',type=Path);args=ap.parse_args()
repairs=json.loads(args.geometry_repairs.read_text(encoding='utf-8-sig')) if args.geometry_repairs else {'repairs':[]}
allowed={}
for r in repairs['repairs']:
 assert r['operation']=='fill_enclosed_crater' and r['path'].startswith('docs/creatures/arena-starters-2026-10-07/walk/vitrecrag_')
 assert r['path'] not in allowed
 coords=[tuple(map(int,xy)) for xy in r['sheet_pixels_xy']];assert len(coords)==len(set(coords));allowed[r['path']]=set(coords)
audit=json.loads((C/'candidate-audit.json').read_text());proof={'geometry':[],'forms':{},'game_frames':{},'geometry_repairs_path':str(args.geometry_repairs) if args.geometry_repairs else None,'permitted_alpha_operation':'fill_enclosed_crater' if allowed else None}

def small_path(root,n,f,i):return root/f'assets/sprites/arena/{n}/small/walk_{f}_f{i}.png'
def open_array(p):return np.array(Image.open(p).convert('RGBA'))
def bounding(mask):
 ys,xs=np.nonzero(mask);return [int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)] if len(xs) else None

def alpha_proof(old,new,rel):
 assert old.shape==new.shape
 changed={(int(x),int(y)) for y,x in zip(*np.nonzero(old[...,3]!=new[...,3]))};expected=allowed.get(rel,set())
 assert changed==expected,(rel,len(changed),len(expected))
 mask=np.zeros(old.shape[:2],bool)
 for x,y in expected:
  assert old[y,x,3]==0 and new[y,x,3]==255;mask[y,x]=True
 cell=old.shape[0]//2 if '/walk/' in rel else old.shape[0];remaining=set(expected);component_sizes=[]
 while remaining:
  start=next(iter(remaining));q=deque([start]);seen={start};component=set()
  while q:
   x,y=q.popleft();component.add((x,y));assert x%cell not in (0,cell-1) and y%cell not in (0,cell-1),(rel,x,y,'open exterior')
   for dy in (-1,0,1):
    for dx in (-1,0,1):
     if dx==dy==0:continue
     xx,yy=x+dx,y+dy
     if 0<=xx<old.shape[1] and 0<=yy<old.shape[0] and old[yy,xx,3]==0 and (xx,yy) not in seen:seen.add((xx,yy));q.append((xx,yy))
  assert component.issubset(expected),(rel,'partial transparent component')
  remaining-=component;component_sizes.append(len(component))
 assert bounding(old[...,3]>0)==bounding(new[...,3]>0)
 return mask,{'same_alpha':not changed,'alpha_valid':True,'enclosed_component_sizes':component_sizes,'alpha_added_pixels':len(expected),'same_bbox':True}

def checker(width,height):
 a=np.zeros((height,width,3),np.uint8);yy,xx=np.mgrid[:height,:width];m=((xx//12+yy//12)%2)==0;a[m]=[92,119,89];a[~m]=[97,125,95];return Image.fromarray(a)

def contact(n,i):
 w,h=180,190;sheet=checker(w*8,h*2+40);d=ImageDraw.Draw(sheet);d.text((8,6),f'{n} WALK frame {i}: BEFORE top / AFTER bottom; game sprites at x3',fill='white')
 for row,root in enumerate([O,C]):
  for col,f in enumerate(FACINGS):
   a=open_array(small_path(root,n,f,i));im=Image.fromarray(a).resize((a.shape[1]*3,a.shape[0]*3),Image.Resampling.NEAREST);x=col*w+(w-im.width)//2;y=40+row*h+20;sheet.paste(im,(x,y),im);m=metrics(a);d.text((col*w+5,40+row*h),f'{f} L{m["brightness"]:.1f} S{m["saturation_pct"]:.1f}%',fill='white')
 return sheet

def expected_game(n,f,i):
 rel=f'docs/creatures/arena-starters-2026-10-07/walk/{n}_{f}_sheet.png';flip=not(C/rel).exists()
 if flip:rel=f'docs/creatures/arena-starters-2026-10-07/walk/{n}_{MIRRORS[f]}_sheet.png'
 sheet=Image.open(C/rel).convert('RGBA');cw=sheet.height//2;fr=sheet.crop(((i%4)*cw,(i//4)*cw,(i%4+1)*cw,(i//4+1)*cw));size=Image.open(C/f'assets/sprites/arena/{n}/{f}.png').size
 if fr.size!=size:fr=fr.resize(size,Image.Resampling.NEAREST)
 fr=shrink(fr,3)
 return np.array(ImageOps.mirror(fr) if flip else fr),rel

def full_cycle_metrics(path):
 a=open_array(path);c=a.shape[0]//2;return [metrics(a[(i//4)*c:(i//4+1)*c,(i%4)*c:(i%4+1)*c]) for i in range(8)]

for n in NAMES:
 base=open_array(O/f'docs/creatures/arena-starters-2026-10-07/forms/{n}.png');palette=set(map(tuple,base[base[...,3]>0,:3]));info=audit['forms'][n]
 rels=[f'assets/sprites/arena/{n}/{f}.png' for f in FACINGS]+[f'docs/creatures/arena-starters-2026-10-07/walk/{p}' for p in info['walk']]
 for rel in rels:
  b=open_array(O/rel);a=open_array(C/rel);on=b[...,3]>0;exception,alpha=alpha_proof(b,a,rel)
  r={'path':rel,'same_canvas':b.shape==a.shape,**alpha,'same_support':bool(np.array_equal(on,a[...,3]>0)),'same_transparent_rgba':bool(np.array_equal(b[~on],a[~on])),'transparent_rgba_valid':bool(np.array_equal(b[~on&~exception],a[~on&~exception])),'exact_base_palette':set(map(tuple,a[a[...,3]>0,:3])).issubset(palette),'original_hash':hashlib.sha256((O/rel).read_bytes()).hexdigest(),'candidate_hash':hashlib.sha256((C/rel).read_bytes()).hexdigest(),'same_foot':True}
  if '/walk/' in rel:
   cw=b.shape[0]//2
   for i in range(8):
    y=(i//4)*cw;x=(i%4)*cw;r['same_foot'] &= metrics(b[y:y+cw,x:x+cw])['foot_row']==metrics(a[y:y+cw,x:x+cw])['foot_row'];assert bounding(b[y:y+cw,x:x+cw,3]>0)==bounding(a[y:y+cw,x:x+cw,3]>0)
  else:r['same_foot']=metrics(b)['foot_row']==metrics(a)['foot_row']
  assert all(r[x] for x in ['same_canvas','alpha_valid','transparent_rgba_valid','exact_base_palette','same_foot','same_bbox']),r
  assert r['original_hash']==audit['inputs'][rel],rel
  proof['geometry'].append(r)
 for f in FACINGS:
  frames=[]
  for i in range(8):
   b=open_array(small_path(O,n,f,i));a=open_array(small_path(C,n,f,i));expected,rel=expected_game(n,f,i)
   assert b.shape==a.shape and np.array_equal(a,expected),(n,f,i,'pipeline mismatch')
   samealpha=np.array_equal(b[...,3],a[...,3]);assert samealpha or rel in allowed
   changed={(int(x),int(y)) for y,x in zip(*np.nonzero(b[...,3]!=a[...,3]))};assert all(b[y,x,3]==0 and a[y,x,3]==255 for x,y in changed)
   assert bounding(b[...,3]>0)==bounding(a[...,3]>0) and metrics(b)['foot_row']==metrics(a)['foot_row']
   assert set(map(tuple,a[a[...,3]>0,:3])).issubset(palette)
   frames.append({'frame':i,'before':metrics(b),'after':metrics(a),'same_alpha':bool(samealpha),'same_canvas':True,'same_bbox_foot':True,'pipeline_rgba_exact':True,'source_path':rel,'alpha_added_pixels_xy':sorted(changed),'alpha_added_pixels':len(changed)})
  proof['game_frames'][f'{n}/{f}']=frames
 frames=[contact(n,i) for i in range(8)];frames[0].save(OUT/f'{n}_walk_before_after_game3x.png');frames[0].save(OUT/f'{n}_walk_before_after_game3x.gif',save_all=True,append_images=frames[1:],duration=140,loop=0,disposal=2)
 fullwalk=[full_cycle_metrics(C/f'docs/creatures/arena-starters-2026-10-07/walk/{path}') for path in info['walk']];fw=[x['brightness'] for cycle in fullwalk for x in cycle];gw=[x['after']['brightness'] for f in FACINGS for x in proof['game_frames'][f'{n}/{f}']]
 proof['forms'][n]={'full_still_spread_before':info['before_brightness_spread'],'full_still_spread_after':max(metrics(open_array(C/f'assets/sprites/arena/{n}/{f}.png'))['brightness'] for f in FACINGS)-min(metrics(open_array(C/f'assets/sprites/arena/{n}/{f}.png'))['brightness'] for f in FACINGS),'small_still_spread_before':info['small_before_brightness_spread'],'small_still_spread_after':max(metrics(open_array(C/f'assets/sprites/arena/{n}/small/{f}.png'))['brightness'] for f in FACINGS)-min(metrics(open_array(C/f'assets/sprites/arena/{n}/small/{f}.png'))['brightness'] for f in FACINGS),'walk_full_cycle_spread_max':max(max(x['brightness'] for x in cycle)-min(x['brightness'] for x in cycle) for cycle in fullwalk),'walk_small_cycle_spread_max':max(max(x['after']['brightness'] for x in proof['game_frames'][f'{n}/{f}'])-min(x['after']['brightness'] for x in proof['game_frames'][f'{n}/{f}']) for f in FACINGS),'walk_full_all_frames_spread':max(fw)-min(fw),'walk_small_all_frames_spread':max(gw)-min(gw)}
 print(n,proof['forms'][n],flush=True)
proof['source_alpha_exact']=all(r['same_alpha'] for r in proof['geometry']);proof['source_alpha_added_total']=sum(r['alpha_added_pixels'] for r in proof['geometry']);proof['source_alpha_valid']=all(r['alpha_valid'] for r in proof['geometry']);proof['game_alpha_added_total']=sum(r['alpha_added_pixels'] for frames in proof['game_frames'].values() for r in frames)
(C/'candidate-invariants-and-walk-review.json').write_text(json.dumps(proof,indent=2)+'\n')
print(f'39 full sources and 192 game walk frames validated; source alpha additions {proof["source_alpha_added_total"]}, actual game additions {proof["game_alpha_added_total"]}.',flush=True)
