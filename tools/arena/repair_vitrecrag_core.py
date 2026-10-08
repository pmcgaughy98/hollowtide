"""Stage color-only Vitrecrag crater-interior material consistency for review.

Uses the approved base crater's exact warm palette and weighted luminance shade
ranks. Source shade order and every pixel/alpha location stay fixed. Explicit
reviewed ellipse envelopes are bounded inside each walk frame's existing pit;
existing dark warm rims, head, legs, silhouette and all outside RGBA
stay literal. The gray/pale generated pit interiors are mapped to the source's
rust-rim/orange/gold heat ramp. This does not claim restored crater shape or
added detail. Writes separate proposals/masks/reports only; never live assets.
"""
from __future__ import annotations
import argparse,json,hashlib,sys
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
import repair_vitrecrag_seams as helpers
DOC=helpers.DOC;F=helpers.FACINGS
CENTERS={
 's':[(83,43),(82,42),(83,42),(82,39),(82,42),(82,42),(82,42),(82,42)],
 'se':[(78,39),(78,38),(78,38),(78,36),(75,37),(75,38),(75,38),(77,38)],
 'e':[(70,43),(70,41),(70,41),(70,41),(70,43),(70,43),(70,41),(70,41)],
 'ne':[(67,46),(67,46),(67,47),(67,49),(67,49),(67,49),(67,49),(67,50)],
 'n':[(75,55),(74,54),(74,53),(74,54),(74,53),(74,53),(74,54),(74,55)]}
RADII={'s':(19,11),'se':(20,10),'e':(19,9),'ne':(19,12),'n':(20,15)}
def lum(c):return np.asarray(c,float)@[.299,.587,.114]
def core_mask(a,f,i):
 yy,xx=np.mgrid[:a.shape[0],:a.shape[1]];cx,cy=CENTERS[f][i];rx,ry=RADII[f]
 inside=(((xx-cx)/rx)**2+((yy-cy)/ry)**2<=1)&(a[:,:,3]>0)&~helpers.edge(a[:,:,3]>0)
 rgb=a[:,:,:3].astype(float);l=lum(rgb);mask=inside&(l>=65)
 # Some generated pits have a cold gray center. Restore only its 4-connected
 # neutral fill seeded at the actual pit center; dark warm rim colors never pass.
 neutral=inside&(l>=45)&(l<=95)&(rgb[:,:,1]>=rgb[:,:,2])&(rgb[:,:,0]<=rgb[:,:,1]*1.6)&(rgb[:,:,1]<=rgb[:,:,2]*1.6)
 if neutral[cy,cx]:
  todo=[(cy,cx)];seen=np.zeros_like(neutral);seen[cy,cx]=True
  while todo:
   y,x=todo.pop();mask[y,x]=True
   for dy,dx in [(0,1),(0,-1),(1,0),(-1,0)]:
    ny,nx=y+dy,x+dx
    if 0<=ny<a.shape[0] and 0<=nx<a.shape[1] and neutral[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;todo.append((ny,nx))
 return mask
def stats(a,m):
 c=a[m,:3];return {'pixels':int(m.sum()),'brightness':round(float(lum(c).mean()),4),'colors':len(np.unique(c,axis=0))}
def shade_transfer(a,m,target_colors,target_counts):
 c,idx,n=np.unique(a[m,:3],axis=0,return_inverse=True,return_counts=True);order=np.argsort(lum(c));quant=(np.cumsum(n[order])-n[order]/2)/n.sum();tcdf=np.cumsum(target_counts)/target_counts.sum();chosen=np.minimum(np.searchsorted(tcdf,quant),len(target_colors)-1);mapping=np.zeros_like(c);mapping[order]=target_colors[chosen];b=a.copy();b[m,:3]=mapping[idx]
 return b,[{'from_rgb':list(map(int,k)),'to_rgb':list(map(int,v)),'pixels':int(q)} for k,v,q in zip(c,mapping,n)]
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--source',type=Path,required=True);ap.add_argument('--baseline',type=Path,required=True);ap.add_argument('--seams',type=Path,required=True);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--project',type=Path,required=True);args=ap.parse_args();assert args.output.resolve() not in [args.project.resolve(),args.baseline.resolve(),args.seams.resolve()]
 args.output.mkdir(parents=True,exist_ok=True);sys.path.insert(0,str(args.project/'tools/arena'));from downscale import shrink
 basepath=args.source/DOC/'forms/vitrecrag.png';base=np.array(Image.open(basepath).convert('RGBA'));yy,xx=np.mgrid[:128,:128];rgb=base[:,:,:3].astype(float)
 bm=(((xx-61)/19)**2+((yy-26)/11)**2<=1)&(base[:,:,3]>0)&(lum(rgb)>=65)&(rgb[:,:,0]>rgb[:,:,1]*1.15)&(rgb[:,:,1]>rgb[:,:,2]*1.2)
 tc,tn=np.unique(base[bm,:3],axis=0,return_counts=True);order=np.argsort(lum(tc));tc=tc[order];tn=tn[order];palette=set(map(tuple,base[base[:,:,3]>0,:3]))
 report={'proposal_only':True,'operation':'approved-base crater warm-ramp monotonic shade-rank transfer inside existing pit; no new geometry/detail','approved_reference':stats(base,bm),'base_sha256':hashlib.sha256(basepath.read_bytes()).hexdigest(),'target_colors_and_weights':[{'rgb':list(map(int,c)),'pixels':int(n)} for c,n in zip(tc,tn)],'centers':CENTERS,'radii':RADII,'records':[],'remaining_limit':'Original crater outline/area and seam topology/width still differ; this is only color material consistency.'}
 Image.fromarray(bm.astype('uint8')*255).save(args.output/'approved_base_core_reference_mask.png')
 for f in F:
  rel=DOC/'walk'/f'vitrecrag_{f}_sheet.png';paths=[args.source/rel,args.baseline/rel,args.seams/rel];raw,current,seams=[np.array(Image.open(p).convert('RGBA')) for p in paths];combined=seams.copy();sheetmask=np.zeros(seams.shape[:2],dtype='uint8');records=[]
  game=Image.new('RGB',(8*170,4*190+190),(24,30,26));dg=ImageDraw.Draw(game);dg.text((5,5),f'Vitrecrag {f}: approved base reference above; RAW / PALETTE BASELINE / SEAMS / SEAMS+CORE; game3x',fill='white');game.paste(helpers.tile(base,1),(5,25));dg.text((145,40),f'Base warm pit L{stats(base,bm)["brightness"]:.2f}; all proposed colors from this exact source.',fill='white')
  full=Image.new('RGB',(8*320,3*345+30),(24,30,26));df=ImageDraw.Draw(full);df.text((5,5),f'{f}: seam-only / exact core-mask RED / combined; full2x',fill='white')
  for i in range(8):
   a=helpers.frame(seams,i);mask=core_mask(a,f,i);b,mapping=shade_transfer(a,mask,tc,tn);helpers.frame(combined,i)[:]=b
   assert np.array_equal(a[:,:,3],b[:,:,3]);assert np.array_equal(a[~mask],b[~mask]);assert set(map(tuple,b[b[:,:,3]>0,:3])).issubset(palette)
   yy,xx=np.nonzero(mask);change=np.any(a[:,:,:3]!=b[:,:,:3],axis=2)&mask;cy,cx=np.nonzero(change);outmask=args.output/'masks'/f'vitrecrag_{f}_f{i}_core_mask.png';outmask.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(mask.astype('uint8')*255).save(outmask);sheetmask[(i//4)*160:(i//4+1)*160,(i%4)*160:(i%4+1)*160]=mask.astype('uint8')*255
   variants=[helpers.frame(raw,i),helpers.frame(current,i),a,b]
   for j,img in enumerate(variants):
    sm=np.array(shrink(Image.fromarray(img),3));dg.text((i*170+5,190+j*190),f'f{i} L{helpers.metric(sm)["brightness"]:.1f}',fill='white');game.paste(helpers.tile(sm,3),(i*170+5,190+j*190+21))
   overlay=np.array(helpers.tile(a));overlay[mask]=(255,35,35)
   for j,img in enumerate([helpers.tile(a,2),Image.fromarray(overlay).resize((320,320),Image.Resampling.NEAREST),helpers.tile(b,2)]):
    df.text((i*320+5,30+j*345),f'f{i} core {int(mask.sum())}px' if j==1 else f'f{i}',fill='white');full.paste(img,(i*320,30+j*345+23))
   records.append({'frame':i,'core_before':stats(a,mask),'core_after':stats(b,mask),'changed_pixels':int(change.sum()),'core_mask_pixels_xy':[[int(x),int(y)] for x,y in zip(xx,yy)],'changed_pixels_xy':[[int(x),int(y)] for x,y in zip(cx,cy)],'alpha_exact':True,'outside_core_rgba_exact':True,'dark_rim_and_outline_exact':True,'mapping':mapping,'combined':helpers.metric(b),'game_combined':helpers.metric(np.array(shrink(Image.fromarray(b),3)))})
  dest=args.output/rel;dest.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(combined).save(dest);Image.fromarray(sheetmask).save(args.output/'masks'/f'vitrecrag_{f}_sheet_core_mask.png');game.save(args.output/f'vitrecrag_{f}_original_baseline_seams_core_game3x.png');full.save(args.output/f'vitrecrag_{f}_seams_coremask_combined_full2x.png')
  report['records'].append({'path':str(rel).replace('\\','/'),'input_sha256':[hashlib.sha256(p.read_bytes()).hexdigest() for p in paths],'output_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'changed_pixels':sum(r['changed_pixels'] for r in records),'frames':records})
 (args.output/'vitrecrag-core-proposal-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({'output':str(args.output),'changed':[r['changed_pixels'] for r in report['records']],'alpha':'exact','live_edits':0}))
if __name__=='__main__':main()
