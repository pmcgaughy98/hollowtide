from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,math,hashlib
D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/kithflare-tail-review")
def smooth(points,widths):
 p=np.array(points,float);w=np.array(widths,float);result=[]
 for i in range(len(p)-1):
  a=p[max(i-1,0)];b=p[i];c=p[i+1];d=p[min(i+2,len(p)-1)]
  for t in np.linspace(0,1,16,endpoint=False):
   q=.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)
   result.append([q[0],q[1],w[i]*(1-t)+w[i+1]*t])
 result.append([*p[-1],w[-1]])
 return np.array(result)
def render_curve(original,prepared,allowed,target,widths,source,source_widths,roi):
 out=prepared.copy()
 path=smooth(target,widths);src=smooth(source,source_widths)
 src_arc=np.cumsum(np.r_[0,np.linalg.norm(np.diff(src[:,:2],axis=0),axis=1)])
 target_arc=np.cumsum(np.r_[0,np.linalg.norm(np.diff(path[:,:2],axis=0),axis=1)])
 indices=np.searchsorted(src_arc,target_arc/max(target_arc[-1],.001)*src_arc[-1]).clip(0,len(src)-1)
 tangents=np.gradient(path[:,:2],axis=0);tangents/=np.maximum(np.linalg.norm(tangents,axis=1)[:,None],.001)
 normals=np.column_stack([-tangents[:,1],tangents[:,0]])
 src_t=np.gradient(src[:,:2],axis=0);src_t/=np.maximum(np.linalg.norm(src_t,axis=1)[:,None],.001)
 src_n=np.column_stack([-src_t[:,1],src_t[:,0]])
 h,w=out.shape[:2];ys,xs=np.mgrid[:h,:w]
 diff=np.stack([xs,ys],axis=-1)[:,:,None,:]-path[None,None,:,:2]
 distances=(diff*diff).sum(axis=3);nearest=distances.argmin(axis=2)
 shape=(distances.min(axis=2)<=(path[nearest,2]/2)**2)&allowed
 old_opaque=original[:,:,3]>0
 interior=np.array(Image.fromarray(old_opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 selected=np.zeros(old_opaque.shape,bool);selected[roi[1]:roi[3],roi[0]:roi[2]]=True
 selected &= interior & (original[:,:,0]>60)&(original[:,:,0]>=original[:,:,1])&(original[:,:,1]>=original[:,:,2])
 sy,sx=np.nonzero(selected);assert len(sx)>0
 outline_candidates=original[np.array(Image.fromarray(old_opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))==0,:3]
 dark=outline_candidates[(outline_candidates[:,0]>8)&(outline_candidates[:,0]<70)&(outline_candidates[:,0]>=outline_candidates[:,1])&(outline_candidates[:,1]>=outline_candidates[:,2])]
 colors,counts=np.unique(dark,axis=0,return_counts=True);outline=colors[counts.argmax()]
 # Rebuild only the allowed tail surface, retaining the original light organ separately.
 out[allowed]=[0,0,0,0]
 for y,x in np.argwhere(shape):
  n=nearest[y,x];j=indices[n]
  transverse=np.dot(np.array([x,y])-path[n,:2],normals[n])/max(path[n,2]/2,.001)
  desired=src[j,:2]+src_n[j]*transverse*max(src[j,2]/2-1,.5)
  rx,ry=np.rint(desired).astype(int)
  if not (0<=rx<w and 0<=ry<h and selected[ry,rx]):
   k=((sx-desired[0])**2+(sy-desired[1])**2).argmin();rx,ry=sx[k],sy[k]
  out[y,x]=original[ry,rx];out[y,x,3]=255
 inner=np.array(Image.fromarray(shape.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 border=shape&~inner
 # Do not draw a transverse black seam where the tail rejoins preserved skin.
 for y,x in np.argwhere(border):
  near_body=False
  for dy,dx in [(0,-1),(0,1),(-1,0),(1,0)]:
   yy,xx=y+dy,x+dx
   if 0<=yy<h and 0<=xx<w and not allowed[yy,xx] and out[yy,xx,3]>0:near_body=True
  if not near_body:out[y,x,:3]=outline
 return out
records=[]
for name in ["kithflare","wayburn","coalcrest"]:
 for view in ["front","back"]:
  original=np.array(Image.open(D/(name+"-"+view+"-before.png")).convert("RGBA"))
  prepared=np.array(Image.open(D/(name+"-"+view+"-prepared.png")).convert("RGBA"))
  allowed=np.array(Image.open(D/(name+"-"+view+"-allowed-mask.png")).convert("L"))>0
  if name=="coalcrest":
   # Raise the mature tail curl so its light organ also reads in the rear battle view.
   bulb=np.array(Image.open(D/"original-coalcrest-lantern.png").convert("RGBA"))
   prepared=original.copy()
   if view=="front":prepared[96:134,118:154]=[0,0,0,0]
   protect=np.zeros(allowed.shape,bool);protect[78:109,19:50]=bulb[:,:,3]>0
   prepared[78:109,19:50][bulb[:,:,3]>0]=bulb[bulb[:,:,3]>0]
   allowed=np.zeros(allowed.shape,bool);allowed[66:145,7:62]=True
   protected_body=(original[:,:,3]>0);protected_body[113:]=False
   if view=="front":protected_body[103:]=False
   allowed &= ~protected_body
   if view=="front":allowed[103:145,50:66]=True
   if view=="front":allowed[96:134,118:154]=True
   assert not np.any(protect&protected_body)
   region=allowed.copy();region[96:134,118:154]=False;region &= ~protect
   if view=="front":
    points=[(65,112),(56,125),(40,132),(26,128),(15,115),(13,99),(17,85),(24,75),(31,72),(35,79)]
    widths=[16,14,12,10,8,7,6,5,4,4]
    source=[(62,122),(54,125),(44,125),(35,124),(27,122)]
   else:
    points=[(61,133),(46,138),(28,132),(16,118),(13,101),(16,85),(24,75),(31,72),(35,79)]
    widths=[16,14,12,10,8,7,6,5,4]
    source=[(65,131),(55,133),(44,133),(32,130),(25,128)]
   out=render_curve(original,prepared,region,points,widths,source,[14,14,13,12,10],(18,115,67,139))
   out[protect]=prepared[protect]
  elif name=="wayburn" and view=="front":
   # The full-tail correction extends upward into clear space without touching the hips.
   allowed[23:93,13:94]=True;allowed[73:95,76:95]=False;allowed[90:95,65:95]=False
   allowed[11:27,92:114]=False
   points=[(77,81),(62,85),(43,81),(29,70),(25,54),(31,39),(43,31),(57,32),(70,37),(83,34),(93,28)]
   widths=[13,13,11,10,8,7,6,5,5,4,3]
   source=[(78,80),(61,80),(44,77),(32,68),(29,53),(37,46),(52,48),(68,48),(82,41),(90,33),(95,28)]
   out=render_curve(original,prepared,allowed,points,widths,source,[13,13,11,9,6,5,4,3,3,2,2],(22,29,93,88))
  else:
   # Existing curled tails already connect; reinforce their short organic collars.
   if name=="kithflare" and view=="front":
    points=[(52,33),(57,36),(59,40)];widths=[6,5,4];roi=(47,28,64,43)
    allowed[40:]=False
   elif name=="kithflare":
    points=[(53,43),(57,46),(58,50)];widths=[6,5,4];roi=(47,39,64,53)
    allowed[50:]=False
   else:
    points=[(44,52),(40,47),(35,43)];widths=[4,4,3];roi=(32,41,49,57)
    allowed[:43,:38]=False
   # Retain all existing neck pixels; add/retexture only the smooth local join.
   repaired=render_curve(original,prepared,allowed,points,widths,points,widths,roi)
   out=prepared.copy();new=repaired[:,:,3]>0
   out[allowed&new]=repaired[allowed&new]
  Image.fromarray(allowed.astype("uint8")*255).save(D/(name+"-"+view+"-final-mask.png"))
  final=D/(name+"-"+view+"-tail-connected.png");Image.fromarray(out).save(final)
  diff=np.any(out!=original,axis=2)
  # The original light organ is retained separately, not globally repainted.
  assert int(diff[~allowed].sum())==0,(name,view,int(diff[~allowed].sum()))
  records.append({"name":name,"view":view,"changed_pixels":int(diff.sum()),"outside_final_tail_mask_changed":int(diff[~allowed].sum()),"canvas_size":[out.shape[1],out.shape[0]],"sha256":hashlib.sha256(final.read_bytes()).hexdigest()})
canvas=Image.new("RGB",(1152,1020),(60,68,69))
for i,name in enumerate(["kithflare","wayburn","coalcrest"]):
 for j,view in enumerate(["front","back"]):
  im=Image.open(D/(name+"-"+view+"-tail-connected.png")).convert("RGBA")
  im=im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST)
  at=(j*576+50,i*340+18);canvas.paste(im,at,im)
  ImageDraw.Draw(canvas).text((j*576+4,i*340+2),name.upper()+" "+view.upper(),fill="white")
canvas.save(D/"connected-line-review.png")
(D/"native-assembly-audit.json").write_text(json.dumps(records,indent=2));print(json.dumps(records))
