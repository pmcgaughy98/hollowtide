"""Read-only Fusern upper-shell diagnostic, separated from whole-body averages.
The mask is the upper52% of the original painted bbox, excluding the external
4-neighbour silhouette edge. This is a comparable upper-dome ROI, not a semantic
segmentation of every brick. It excludes eyes/legs and most lower gray armor.
No pixel is moved, recoloured or removed from the original assets.
"""
from pathlib import Path
import json,csv,collections,argparse
import numpy as np
from PIL import Image
W=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-vitrecrag-consistency-2026-10-07/source-audit');O=W/'originals';rs=json.loads((W/'before-metrics.json').read_text());parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--image-root',type=Path);parser.add_argument('--output-stem',default='fusern-shell-before-metrics');args=parser.parse_args()
if args.image_root:O=args.image_root.resolve()
maskdir=W/'shell-diagnostic-masks';maskdir.mkdir(exist_ok=True)
def lum(rgb):return rgb[...,0]*.299+rgb[...,1]*.587+rgb[...,2]*.114
def bbox(a):
 on=a[:,:,3]>0;y,x=np.nonzero(on);return int(x.min()),int(y.min()),int(x.max()+1),int(y.max()+1)
rows=[]
for r in rs:
 if r['form']!='fusern':continue
 im=Image.open(O/r['path']).convert('RGBA')
 if r['kind']=='walk_full':
  cw=im.height//2;i=r['frame'];im=im.crop(((i%4)*cw,(i//4)*cw,(i%4+1)*cw,(i//4+1)*cw))
 a=np.array(im);on=a[:,:,3]>0;x0,y0,x1,y1=bbox(a);cut=y0+int(round((y1-y0)*.52));yy,xx=np.indices(on.shape);pad=np.pad(on,1);edge=on&~(pad[:-2,1:-1]&pad[2:,1:-1]&pad[1:-1,:-2]&pad[1:-1,2:]);roi=on&(yy<cut)&~edge;rgb=a[:,:,:3].astype(float);L=lum(rgb);mx=rgb.max(2);mn=rgb.min(2);sat=np.divide(mx-mn,mx,out=np.zeros_like(mx),where=mx>0);warm=(rgb[:,:,0]>rgb[:,:,1]*1.3)&(rgb[:,:,1]>rgb[:,:,2]*1.15)&(sat>.35);brick=roi&warm;br=roi&warm&(L>=130);pale=roi&warm&(L>=165);dark=roi&(L<=60);cols=collections.Counter(map(tuple,a[:,:,:3][roi]));dominant=cols.most_common(1)[0]
 difs=[]
 for dy,dx in ((0,1),(1,0)):
  pa=roi[:roi.shape[0]-dy or None,:roi.shape[1]-dx or None];pb=roi[dy:,dx:];la=L[:L.shape[0]-dy or None,:L.shape[1]-dx or None];lb=L[dy:,dx:];m=pa&pb;difs.extend(abs(la[m]-lb[m]).tolist())
 row={k:r[k] for k in ('form','kind','facing','frame','path')};row.update({'whole_mean_brightness':round(float(L[on].mean()),4),'dome_bbox':[x0,y0,x1,cut],'dome_roi_pixels':int(roi.sum()),'dome_mean_brightness':round(float(L[roi].mean()),4),'warm_brick_pixels':int(brick.sum()),'warm_brick_mean_brightness':round(float(L[brick].mean()),4),'warm_brick_saturation_pct':round(float(sat[brick].mean()*100),4),'bright_orange_L130_roi_pct':round(float(br.sum()/roi.sum()*100),4),'pale_orange_L165_roi_pct':round(float(pale.sum()/roi.sum()*100),4),'dark_joint_or_shadow_L60_roi_pct':round(float(dark.sum()/roi.sum()*100),4),'dominant_rgb':list(map(int,dominant[0])),'dominant_rgb_roi_pct':round(float(dominant[1]/roi.sum()*100),4),'local_adjacent_luminance_difference':round(float(np.mean(difs)),4),'roi_colour_count':len(cols)})
 rows.append(row)
 if r['kind'] in ('base','full','walk_full'):
  frame='' if r['frame'] is None else f"-f{r['frame']}";Image.fromarray((roi*255).astype('uint8')).save(maskdir/f"{r['kind']}-{r['facing']}{frame}.png")
(W/(args.output_stem+'.json')).write_text(json.dumps({'mask_method':__doc__,'records':rows},indent=2),encoding='utf8')
with (W/(args.output_stem+'.csv')).open('w',encoding='utf8',newline='') as fp:
 wr=csv.DictWriter(fp,fieldnames=list(rows[0]));wr.writeheader();wr.writerows(rows)
print(json.dumps([r for r in rows if r['kind'] in ('base','full')],indent=2))
