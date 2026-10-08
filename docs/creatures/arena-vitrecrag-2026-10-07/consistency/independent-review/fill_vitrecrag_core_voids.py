"""Stage only fully enclosed Vitrecrag crater-alpha restoration for review.

Inspects 8-connected transparent components in source frames. A component must
never touch the frame exterior and every pixel must fit the audited finite pit
ellipse; all adjacent outside pixels must be painted. Only these existing
internal voids receive approved orange-edge to golden-center RGB/alpha255,
using inward Manhattan distance. No exterior alpha, original painted outlines,
poses, feet, canvas or pixel positions are changed. Exact alpha is honestly
false for affected frames and their precise additions are recorded for the
report's fill_enclosed_crater exception. No live or canonical asset writes.
"""
from __future__ import annotations
import argparse,hashlib,json,sys
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
import repair_vitrecrag_core as core
H=core.helpers;DOC=H.DOC;FACINGS=H.FACINGS
CENTERS={k:list(v) for k,v in core.CENTERS.items()}
CENTERS['e']=[(70,43),(70,47),(70,46),(70,48),(70,43),(70,43),(70,46),(70,48)]
RADII={k:v for k,v in core.RADII.items()};RADII['se']=(22,12);RADII['e']=(20,12)
PALETTE=[(239,127,32),(250,132,30),(254,153,43),(254,187,63)]
def components(mask):
 seen=np.zeros_like(mask);groups=[];hh,ww=mask.shape
 for y,x in zip(*np.nonzero(mask)):
  if seen[y,x]:continue
  seen[y,x]=True;todo=[(int(y),int(x))];g=[]
  while todo:
   yy,xx=todo.pop();g.append((yy,xx))
   for dy in [-1,0,1]:
    for dx in [-1,0,1]:
     ny,nx=yy+dy,xx+dx
     if 0<=ny<hh and 0<=nx<ww and mask[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;todo.append((ny,nx))
  groups.append(g)
 return groups

def enclosed_fill(a,f,i):
 h,w=a.shape[:2];yy,xx=np.mgrid[:h,:w];cx,cy=CENTERS[f][i];rx,ry=RADII[f];pit=(((xx-cx)/rx)**2+((yy-cy)/ry)**2<=1);mask=np.zeros((h,w),bool);out=a.copy();records=[]
 for group in components(a[:,:,3]==0):
  coords=np.array(group);y=coords[:,0];x=coords[:,1]
  if y.min()==0 or x.min()==0 or y.max()==h-1 or x.max()==w-1:continue
  if not pit[y,x].all():continue
  component=np.zeros((h,w),bool);component[y,x]=True
  border=[]
  for py,px in group:
   for dy in [-1,0,1]:
    for dx in [-1,0,1]:
     ny,nx=py+dy,px+dx
     if not component[ny,nx]:border.append((ny,nx))
  assert border and all(a[py,px,3]==255 for py,px in border),'Component must be fully surrounded by hard painted pixels'
  # Every component is closed; inward distances create a restrained source-style
  # hot center without borrowing background or inventing a random texture.
  distance=np.zeros((h,w),int);queue=[]
  for py,px in group:
   if any(not component[py+dy,px+dx] for dy,dx in [(0,1),(0,-1),(1,0),(-1,0)]):distance[py,px]=1;queue.append((py,px))
  j=0
  while j<len(queue):
   py,px=queue[j];j+=1
   for dy,dx in [(0,1),(0,-1),(1,0),(-1,0)]:
    ny,nx=py+dy,px+dx
    if component[ny,nx] and distance[ny,nx]==0:distance[ny,nx]=distance[py,px]+1;queue.append((ny,nx))
  for py,px in group:out[py,px]=(*PALETTE[min(int(distance[py,px])-1,3)],255)
  mask|=component
  records.append({'pixels':len(group),'bbox_half_open':[int(x.min()),int(y.min()),int(x.max()+1),int(y.max()+1)],'all_inside_reviewed_pit_ellipse':True,'closed_8_connected':True,'boundary_alpha255':True,'max_inward_distance':int(distance.max())})
 assert np.array_equal(out[~mask],a[~mask]);assert np.all(a[mask,3]==0) and np.all(out[mask,3]==255)
 # Filling internal components cannot affect the frame's externally connected
 # transparent component; original painted silhouette and hole-boundary RGB stay.
 for group in components(a[:,:,3]==0):
  if any(y in [0,h-1] or x in [0,w-1] for y,x in group):assert all(np.array_equal(out[y,x],a[y,x]) for y,x in group)
 return out,mask,records

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--source',type=Path,required=True);ap.add_argument('--baseline',type=Path,required=True);ap.add_argument('--input',type=Path,required=True);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--project',type=Path,required=True);args=ap.parse_args();assert args.output.resolve() not in [args.project.resolve(),args.baseline.resolve(),args.input.resolve()]
 args.output.mkdir(parents=True,exist_ok=True);sys.path.insert(0,str(args.project/'tools/arena'));from downscale import shrink
 base=np.array(Image.open(args.source/DOC/'forms/vitrecrag.png').convert('RGBA'));palette=set(map(tuple,base[base[:,:,3]>0,:3]));assert set(PALETTE).issubset(palette)
 report={'proposal_only':True,'operation':'fill_enclosed_crater','old_alpha':0,'new_alpha':255,'geometry_exception':True,'alpha_exact':False,'outside_all_added_masks_rgba_exact':True,'external_background_rgba_exact':True,'original_painted_outline_rgba_exact':True,'pit_centers':CENTERS,'pit_radii':RADII,'fill_palette':PALETTE,'records':[],'repairs':[],'remaining_limit':'RD crater outline/area, movement and seam layout vary between frames. These source geometries remain; only proved enclosed voids are filled.'}
 for f in FACINGS:
  rel=DOC/'walk'/f'vitrecrag_{f}_sheet.png';paths=[args.source/rel,args.baseline/rel,args.input/rel];raw,baseline,current=[np.array(Image.open(p).convert('RGBA')) for p in paths];filled=current.copy();sheetmask=np.zeros(current.shape[:2],bool);records=[];all_xy=[]
  game=Image.new('RGB',(8*170,3*190+170),(24,30,26));dg=ImageDraw.Draw(game);dg.text((5,5),f'{f}: base reference; ORIGINAL / SEAMS+CORE(alpha exact) / ENCLOSED HOTPIT RESTORATION; game3x',fill='white');game.paste(H.tile(base,1),(5,25));dg.text((145,42),'Adds only closed transparent source crater components. Exact alpha is false; outer silhouette is preserved.',fill='white')
  full=Image.new('RGB',(8*320,3*345+30),(24,30,26));df=ImageDraw.Draw(full);df.text((5,5),f'{f}: current / exact added alpha pixels RED / filled; full2x',fill='white')
  for i in range(8):
   a=H.frame(current,i);b,mask,comps=enclosed_fill(a,f,i);H.frame(filled,i)[:]=b;sheetmask[(i//4)*160:(i//4+1)*160,(i%4)*160:(i%4+1)*160]=mask
   assert set(map(tuple,b[b[:,:,3]>0,:3])).issubset(palette);ys,xs=np.nonzero(a[:,:,3]);yf,xf=np.nonzero(b[:,:,3]);assert a.shape==b.shape and ys.max()==yf.max() and [xs.min(),ys.min(),xs.max(),ys.max()]==[xf.min(),yf.min(),xf.max(),yf.max()]
   py,px=np.nonzero(mask);local=[[int(x),int(y)] for x,y in zip(px,py)];sheetxy=[[int(x+(i%4)*160),int(y+(i//4)*160)] for x,y in zip(px,py)];all_xy+=sheetxy
   mp=args.output/'masks'/f'vitrecrag_{f}_f{i}_added_core_alpha.png';mp.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(mask.astype('uint8')*255).save(mp)
   sm0=np.array(shrink(Image.fromarray(a),3));sm1=np.array(shrink(Image.fromarray(b),3));sm_added=(sm0[:,:,3]==0)&(sm1[:,:,3]>0)
   records.append({'frame':i,'added_pixels':int(mask.sum()),'components':comps,'local_added_pixels_xy':local,'sheet_added_pixels_xy':sheetxy,'game_added_alpha_pixels':int(sm_added.sum()),'full_alpha_exact':bool(np.array_equal(a[:,:,3],b[:,:,3])),'same_canvas_bbox_feet':True,'outside_added_rgba_exact':True,'baseline_game':H.metric(sm0),'filled_game':H.metric(sm1)})
   for j,img in enumerate([H.frame(raw,i),a,b]):
    sm=np.array(shrink(Image.fromarray(img),3));dg.text((i*170+5,170+j*190),f'f{i} L{H.metric(sm)["brightness"]:.1f} +{int(mask.sum())}px' if j==2 else f'f{i} L{H.metric(sm)["brightness"]:.1f}',fill='white');game.paste(H.tile(sm,3),(i*170+5,170+j*190+21))
   overlay=np.array(H.tile(a));overlay[mask]=(255,35,35)
   for j,img in enumerate([H.tile(a,2),Image.fromarray(overlay).resize((320,320),Image.Resampling.NEAREST),H.tile(b,2)]):
    df.text((i*320+5,30+j*345),f'f{i} +{int(mask.sum())}alpha' if j==1 else f'f{i}',fill='white');full.paste(img,(i*320,30+j*345+23))
  dest=args.output/rel;dest.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(filled).save(dest);Image.fromarray(sheetmask.astype('uint8')*255).save(args.output/'masks'/f'vitrecrag_{f}_sheet_added_core_alpha.png');game.save(args.output/f'vitrecrag_{f}_before_core_filled_game3x.png');full.save(args.output/f'vitrecrag_{f}_before_addedmask_filled_full2x.png')
  report['records'].append({'path':str(rel).replace('\\','/'),'input_sha256':[hashlib.sha256(p.read_bytes()).hexdigest() for p in paths],'output_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'added_pixels':len(all_xy),'frames':records})
  if all_xy:report['repairs'].append({'path':str(rel).replace('\\','/'),'operation':'fill_enclosed_crater','sheet_pixels_xy':all_xy})
 (args.output/'vitrecrag-enclosed-core-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');(args.output/'vitrecrag-crater-repairs.json').write_text(json.dumps({'repairs':report['repairs']},indent=2)+'\n',encoding='utf-8');print(json.dumps({'output':str(args.output),'added':[r['added_pixels'] for r in report['records']],'total_added':sum(r['added_pixels'] for r in report['records']),'alpha_exact':False,'external_silhouette':'exact','live_edits':0}))
if __name__=='__main__':main()
