"""Stage Vitrecrag walk seam-color proposals without moving or adding any pixel.

Reads preserved raw sheets and independently normalized baseline sheets. Only
existing bright warm shell networks inside explicitly reviewed shell envelopes
receive the approved source's copper RGB (173,90,51). The unchanged existing
shade ramp stays below the threshold. Direction-specific crater/core
rectangles, the head/eyes, legs, band and silhouette edges remain literal baseline
RGBA. This is a material proposal, not a geometry or animation-topology repair.

All output is written under --output; do not point it at the live project or the
canonical candidate without separately reviewing these contact sheets first.
"""
from __future__ import annotations
import argparse,hashlib,json,sys
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFilter
DOC=Path('docs/creatures/arena-starters-2026-10-07')
FACINGS=['s','se','e','ne','n']
# Half-open bounds, source-frame coordinates. Generous core guards include rim.
CAP={'s':(25,20,130,76),'se':(23,20,119,77),'e':(20,21,103,87),'ne':(20,25,104,89),'n':(25,28,120,92)}
CORE={'s':(61,24,106,60),'se':(54,24,100,54),'e':(48,27,94,58),'ne':(47,32,90,64),'n':(51,36,99,73)}
HEAD={'s':(51,77,105,110),'se':(96,56,126,98),'e':(101,39,143,102),'ne':(105,25,142,89),'n':(105,18,133,49)}
COPPER=(173,90,51)
def rect(shape,b):
 x0,y0,x1,y1=b;m=np.zeros(shape,dtype=bool);m[y0:y1,x0:x1]=True;return m
def edge(on):
 p=np.pad(on,1);return on&~(p[:-2,1:-1]&p[2:,1:-1]&p[1:-1,:-2]&p[1:-1,2:])
def mask_for(a,f):
 on=a[:,:,3]>0;rgb=a[:,:,:3].astype(float);l=rgb@[.299,.587,.114]
 warm=on&(l>115)&(rgb[:,:,0]>rgb[:,:,1]*1.15)&(rgb[:,:,1]>rgb[:,:,2]*1.2)
 broad=np.array(Image.fromarray(warm.astype('uint8')*255).filter(ImageFilter.MinFilter(3)).filter(ImageFilter.MaxFilter(3)))>0
 protected=rect(on.shape,CORE[f])|rect(on.shape,HEAD[f])|edge(on)
 return warm&rect(on.shape,CAP[f])&~protected,protected

def frame(sheet,i):
 c=sheet.shape[0]//2;return sheet[(i//4)*c:(i//4+1)*c,(i%4)*c:(i%4+1)*c]
def metric(a):
 on=a[:,:,3]>0;c=a[:,:,:3][on].astype(float);v=c.max(1);mn=c.min(1)
 return {'brightness':round(float((c@[.299,.587,.114]).mean()),4),'saturation_pct':round(float(np.divide(v-mn,v,out=np.zeros_like(v),where=v>0).mean()*100),4),'colors':int(len(np.unique(c,axis=0)))}
def tile(a,scale=1):
 im=Image.fromarray(a,'RGBA');bg=Image.new('RGBA',im.size,(41,53,43,255));bg.alpha_composite(im)
 return bg.resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST).convert('RGB')
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--source',type=Path,required=True);ap.add_argument('--baseline',type=Path,required=True);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--project',type=Path,required=True);args=ap.parse_args()
 assert args.output.resolve()!=args.project.resolve(),'Review-only: refuse live project output'
 assert args.output.resolve()!=args.baseline.resolve(),'Review-only: refuse canonical baseline output'
 args.output.mkdir(parents=True,exist_ok=True);sys.path.insert(0,str(args.project/'tools/arena'));from downscale import shrink
 base=np.array(Image.open(args.source/DOC/'forms/vitrecrag.png').convert('RGBA'));palette=set(map(tuple,base[base[:,:,3]>0,:3]));assert COPPER in palette
 report={'proposal_only':True,'operation':'existing bright warm shell networks outside crater/core to own-base copper173,90,51; no added seams','target_rgb':COPPER,'cap_half_open':CAP,'core_half_open':CORE,'head_half_open':HEAD,'records':[],'remaining_limit':'Original crater brightness/area and generated seam topology are preserved, not repaired.'}
 for f in FACINGS:
  rel=DOC/'walk'/f'vitrecrag_{f}_sheet.png';rawpath=args.source/rel;currentpath=args.baseline/rel
  raw=np.array(Image.open(rawpath).convert('RGBA'));current=np.array(Image.open(currentpath).convert('RGBA'));proposed=current.copy();assert raw.shape==current.shape and current.shape==(320,640,4)
  masks=np.zeros(current.shape[:2],dtype='uint8');records=[];c=160
  game=Image.new('RGB',(8*170,3*190+34),(24,30,26));dg=ImageDraw.Draw(game);dg.text((5,5),f'Vitrecrag {f}: ORIGINAL / NORMALIZED BASELINE / SEAM PROPOSAL; game3x',fill='white')
  full=Image.new('RGB',(8*320,3*345+30),(24,30,26));df=ImageDraw.Draw(full);df.text((5,5),f'{f}: baseline / protected-core BLUE & repaint RED / proposed; full2x',fill='white')
  for i in range(8):
   before=frame(raw,i);a=frame(current,i);mask,protected=mask_for(a,f);b=a.copy();b[mask,:3]=COPPER;frame(proposed,i)[:]=b
   assert np.array_equal(b[:,:,3],a[:,:,3]);assert np.array_equal(b[~mask],a[~mask]);assert np.array_equal(b[protected],a[protected]);assert set(map(tuple,b[b[:,:,3]>0,:3])).issubset(palette)
   maskpath=args.output/'masks'/f'vitrecrag_{f}_f{i}_seam_mask.png';maskpath.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(mask.astype('uint8')*255).save(maskpath);masks[(i//4)*c:(i//4+1)*c,(i%4)*c:(i%4+1)*c]=mask.astype('uint8')*255
   yy,xx=np.nonzero(mask);sa=np.array(shrink(Image.fromarray(a),3));sb=np.array(shrink(Image.fromarray(b),3));sraw=np.array(shrink(Image.fromarray(before),3));assert np.array_equal(sa[:,:,3],sb[:,:,3])
   records.append({'frame':i,'changed_pixels':int(mask.sum()),'local_pixels_xy':[[int(x),int(y)] for x,y in zip(xx,yy)],'alpha_exact':True,'outside_mask_rgba_exact':True,'core_rgba_exact':True,'outline_rgba_exact':True,'baseline':metric(a),'proposed':metric(b),'game_baseline':metric(sa),'game_proposed':metric(sb)})
   for j,img in enumerate([sraw,sa,sb]):
    dg.text((i*170+5,34+j*190),f'f{i} L{metric(img)["brightness"]:.1f}',fill='white');game.paste(tile(img,3),(i*170+5,34+j*190+21))
   overlay=np.array(tile(a));overlay[protected&(a[:,:,3]>0)]=(35,96,244);overlay[mask]=(255,35,35)
   for j,img in enumerate([tile(a,2),Image.fromarray(overlay).resize((320,320),Image.Resampling.NEAREST),tile(b,2)]):
    df.text((i*320+5,30+j*345),f'f{i} {int(mask.sum())} seam pixels' if j==1 else f'f{i}',fill='white');full.paste(img,(i*320,30+j*345+23))
  outpath=args.output/rel;outpath.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(proposed).save(outpath)
  Image.fromarray(masks).save(args.output/'masks'/f'vitrecrag_{f}_sheet_seam_mask.png');game.save(args.output/f'vitrecrag_{f}_original_baseline_proposed_game3x.png');full.save(args.output/f'vitrecrag_{f}_baseline_mask_proposed_full2x.png')
  report['records'].append({'path':str(rel).replace('\\','/'),'raw_sha256':hashlib.sha256(rawpath.read_bytes()).hexdigest(),'baseline_sha256':hashlib.sha256(currentpath.read_bytes()).hexdigest(),'proposal_sha256':hashlib.sha256(outpath.read_bytes()).hexdigest(),'changed_pixels':sum(r['changed_pixels'] for r in records),'frames':records})
 (args.output/'vitrecrag-seam-proposal-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({'proposal':str(args.output),'changed':[r['changed_pixels'] for r in report['records']],'alpha':'exact','live_edits':0}))
if __name__=='__main__':main()
