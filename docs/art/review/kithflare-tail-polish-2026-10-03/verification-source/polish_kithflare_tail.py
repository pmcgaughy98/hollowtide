from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,hashlib,shutil
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"kithflare-tail-review";N=W/"kithflare-tail-polish";P=Path(r"C:/Users/pmcga/dev/hollowtide")
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
if not (N/"baseline.json").exists():
 baseline={}
 for folder in ["assets","data","scripts","scenes"]:
  for p in (P/folder).rglob("*"):
   if p.is_file():baseline[p.relative_to(P).as_posix()]=sha(p)
 baseline["project.godot"]=sha(P/"project.godot")
 (N/"baseline.json").write_text(json.dumps(baseline,indent=2))
 for name in ["kithflare","wayburn","coalcrest"]:
  for view in ["front","back"]:
   p=P/"assets/sprites/creatures/kithflare_tail_attached_2026_10_03"/(name+"_"+view+".png")
   shutil.copy2(p,N/(name+"-"+view+"-previous.png"))
 for rel in ["103_kithflare.tres","104_wayburn.tres","105_coalcrest.tres"]:shutil.copy2(P/"data/creatures"/rel,N/(rel+"-before.txt"))
namespace={}
source=(W/"assemble_kithflare_tail_material.py").read_text().split("records=[]")[0]
exec(source,namespace);smooth=namespace["smooth"]
# Native texture repeats follow the authored tail's band spacing instead of stretching it.
def curve(original,prepared,allowed,points,widths,srcpoints,srcwidths,roi):
 out=prepared.copy();path=smooth(points,widths);src=smooth(srcpoints,srcwidths)
 ta=np.cumsum(np.r_[0,np.linalg.norm(np.diff(path[:,:2],axis=0),axis=1)])
 sa=np.cumsum(np.r_[0,np.linalg.norm(np.diff(src[:,:2],axis=0),axis=1)])
 arc=ta%(2*sa[-1]);arc=np.where(arc>sa[-1],2*sa[-1]-arc,arc)
 ids=np.searchsorted(sa,arc).clip(0,len(src)-1)
 tangent=np.gradient(path[:,:2],axis=0);tangent/=np.maximum(np.linalg.norm(tangent,axis=1)[:,None],.001)
 normal=np.column_stack([-tangent[:,1],tangent[:,0]])
 st=np.gradient(src[:,:2],axis=0);st/=np.maximum(np.linalg.norm(st,axis=1)[:,None],.001)
 sn=np.column_stack([-st[:,1],st[:,0]])
 h,w=out.shape[:2];ys,xs=np.mgrid[:h,:w];diff=np.stack([xs,ys],axis=-1)[:,:,None,:]-path[None,None,:,:2]
 dist=(diff*diff).sum(axis=3);near=dist.argmin(axis=2);shape=(dist.min(axis=2)<=(path[near,2]/2)**2)&allowed
 opaque=original[:,:,3]>0;interior=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 sample=np.zeros(opaque.shape,bool);sample[roi[1]:roi[3],roi[0]:roi[2]]=True
 sample &= interior & (original[:,:,0]>60)&(original[:,:,0]>=original[:,:,1])&(original[:,:,1]>=original[:,:,2])
 sy,sx=np.nonzero(sample)
 dark=original[opaque&(~interior),:3];dark=dark[(dark[:,0]>8)&(dark[:,0]<70)&(dark[:,0]>=dark[:,1])&(dark[:,1]>=dark[:,2])]
 c,n=np.unique(dark,axis=0,return_counts=True);outline=c[n.argmax()]
 out[allowed]=0
 for y,x in np.argwhere(shape):
  i=near[y,x];j=ids[i]
  u=np.dot(np.array([x,y])-path[i,:2],normal[i])/max(path[i,2]/2,.001)
  desired=src[j,:2]+sn[j]*u*max(src[j,2]/2-1,.5)
  rx,ry=np.rint(desired).astype(int)
  if not (0<=rx<w and 0<=ry<h and sample[ry,rx]):
   k=((sx-desired[0])**2+(sy-desired[1])**2).argmin();rx,ry=sx[k],sy[k]
  out[y,x]=original[ry,rx];out[y,x,3]=255
 inner=np.array(Image.fromarray(shape.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 for y,x in np.argwhere(shape&~inner):
  touches=False
  for dy,dx in [(0,-1),(0,1),(-1,0),(1,0)]:
   yy,xx=y+dy,x+dx
   if 0<=yy<h and 0<=xx<w and not allowed[yy,xx] and out[yy,xx,3]>0:touches=True
  if not touches:out[y,x,:3]=outline
 return out
audit=[]
for name in ["kithflare","wayburn","coalcrest"]:
 for view in ["front","back"]:
  original=np.array(Image.open(D/(name+"-"+view+"-before.png")).convert("RGBA"))
  previous=np.array(Image.open(N/(name+"-"+view+"-previous.png")).convert("RGBA"))
  allowed=np.array(Image.open(D/(name+"-"+view+"-final-mask.png")).convert("L"))>0
  out=previous.copy()
  if name=="coalcrest":
   prepared=original.copy();bulb=np.array(Image.open(D/"original-coalcrest-lantern.png").convert("RGBA"))
   protect=np.zeros(allowed.shape,bool);protect[78:109,19:50]=bulb[:,:,3]>0
   prepared[78:109,19:50][bulb[:,:,3]>0]=bulb[bulb[:,:,3]>0]
   if view=="front":prepared[96:134,118:154]=0
   region=allowed.copy();region[96:134,118:154]=False;region &= ~protect
   if view=="front":
    points=[(65,112),(56,125),(40,132),(26,128),(15,115),(13,99),(17,85),(24,75),(31,72),(35,79)]
    widths=[16,14,12,10,8,7,6,5,4,4]
    source=[(62,122),(54,125),(44,125),(35,124),(27,122)]
   else:
    points=[(61,131),(46,135),(28,128),(16,114),(13,98),(16,84),(24,75),(31,72),(35,79)]
    widths=[16,14,12,10,8,7,6,5,4]
    source=[(65,131),(55,133),(44,133),(32,130),(25,128)]
   material=original
   if view=="front":
    material=np.array(Image.open(D/"coalcrest-back-before.png").convert("RGBA"))
    source=[(65,131),(55,133),(44,133),(32,130),(25,128)]
   out=curve(material,prepared,region,points,widths,source,[14,14,13,12,10],(18,115,67,139))
   if view=="front":
    # Shared native plate spacing, quantized back to the front's authored browns.
    palette=original[115:134,20:64].reshape(-1,4)
    palette=np.unique(palette[(palette[:,3]>0)&(palette[:,0]>35)&(palette[:,0]>=palette[:,1])&(palette[:,1]>=palette[:,2]),:3],axis=0)
    for y,x in np.argwhere(region&(out[:,:,3]>0)&(out[:,:,0]>45)):
     weighted=(palette.astype(float)-out[y,x,:3].astype(float))*np.array([1,1.25,1.25])
     out[y,x,:3]=palette[np.argmin((weighted*weighted).sum(axis=1))]
   out[protect]=prepared[protect]
   if view=="front":
    # Explicit anatomy guard: the previous allowed rectangle had clipped native toes.
    out[129:153,60:118]=original[129:153,60:118]
    assert np.array_equal(out[129:153,60:118],original[129:153,60:118])
  elif name=="wayburn" and view=="front":
   # Its source and rounded curve have comparable lengths; keep authored zigzag scale.
   # Existing curve is retained; only clear the old internal outline at its attachment.
   pass
  else:
   # Widening left an old dark contour buried inside three necks. Replace only that
   # internal contour with the nearest original skin material; outer outlines stay.
   opaque=out[:,:,3]>0
   inner=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
   dark=(out[:,:,0]<65)&(out[:,:,1]<40)&(out[:,:,2]<30)
   edit=allowed&inner&dark
   skin=allowed&(original[:,:,3]>0)&(original[:,:,0]>85)&(original[:,:,1]>45)&(original[:,:,1]<140)&(original[:,:,2]<100)
   sy,sx=np.nonzero(skin)
   for y,x in np.argwhere(edit):
    k=((sx-x)**2+(sy-y)**2).argmin();out[y,x]=original[sy[k],sx[k]]
  assert np.array_equal(out[~allowed],original[~allowed]),(name,view,"outside original tail mask")
  # RGBA alpha format and all existing authored fin/head/torso/foot pixels outside
  # tail regions are exact. The original lamp remains unchanged and four-connected.
  target=N/(name+"-"+view+"-polished.png");Image.fromarray(out).save(target)
  Image.fromarray(allowed.astype("uint8")*255).save(N/(name+"-"+view+"-mask.png"))
  audit.append({"name":name,"view":view,"previous_bbox":Image.fromarray(previous).getbbox(),"polished_bbox":Image.fromarray(out).getbbox(),"changed_from_previous":int(np.any(out!=previous,axis=2).sum()),"original_tail_mask_only":True,"sha256":sha(target)})
sheet=Image.new("RGB",(600,356),(60,68,69))
for col,name in enumerate(["kithflare","wayburn","coalcrest"]):
 for row,view in enumerate(["front","back"]):
  im=Image.open(N/(name+"-"+view+"-polished.png"))
  sheet.paste(im,(col*200+4,row*178+16),im);ImageDraw.Draw(sheet).text((col*200+4,row*178+2),name.upper()+" "+view.upper(),fill="white")
sheet.resize((1200,712),Image.Resampling.NEAREST).save(N/"line-review.png")
(N/"draft-audit.json").write_text(json.dumps(audit,indent=2))
print(json.dumps(audit))
