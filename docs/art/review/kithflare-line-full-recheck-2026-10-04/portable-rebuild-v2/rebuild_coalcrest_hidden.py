from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,hashlib
from coalcrest_curve_helpers import shape_and_texture
from coalcrest_rear_helpers import geometry
W=Path(__file__).resolve().parent
D=W
a=np.array(Image.open(D/"sources/coalcrest-back-before.png").convert("RGBA"))
original=np.array(Image.open(D/"sources/coalcrest-back-authored-material.png").convert("RGBA"))
y,x=np.mgrid[:160,:160]
oldshape,*_=geometry([(64,121),(52,130),(40,132),(28,126),(18,113),(15,98),(18,84),(25,75),(31,72),(35,79)],[20,14,9,7.5,6,5,4.5,4,3.5,3.5])
lamp=(x>=18)&(x<51)&(y>=78)&(y<110)&(a[:,:,3]>0)&~oldshape
allowed=((x>=12)&(x<94)&(y>=104)&(y<141))|((x>=12)&(x<54)&(y>=67)&(y<104))
allowed&=~((x>=52)&(x<=61)&(y>=80)&(y<=101))
ly,lx=np.nonzero(lamp);allowed[ly,lx+8]=True
srcpoints=[(82,94),(74,106),(64,119),(50,130),(32,129)]
srcwidths=[21,22,20,14,9]
srcshape,*_=geometry(srcpoints,srcwidths)
# This original authored far foot is the only exposed part of the hidden far leg.
foot=(x>=74)&(x<94)&(y>=127)&(y<140)&(original[:,:,3]>0)&~srcshape
palette=np.unique(a[a[:,:,3]>0,:3],axis=0)
def native(c):return palette[((palette.astype(float)-np.array(c))**2).sum(1).argmin()]
def build(key):
 out=a.copy();out[allowed]=0
 points=[(86,102),(87,112),(81,124),(68,130),(53,131),(40,126),(30,116),(25,102),(27,86),(34,76),(39,73),(43,80)]
 widths=[13,12,12,9,8,7,6,5,4.5,4,3.5,3.5]
 if key=="f":
  points=[(86,102),(87,112),(83,123),(72,129),(55,131),(40,126),(30,116),(25,102),(27,86),(34,76),(39,73),(43,80)]
  widths=[13,12,11,10,8,7,6,5,4.5,4,3.5,3.5]
 shape,texture=shape_and_texture(original,points,widths,srcpoints,srcwidths,(30,94,89,135))
 _,path,arc,near,u,norm=geometry(points,widths)
 # Retain source rump-to-tail clusters through the attachment, with a short native-color blend.
 for yy,xx in np.argwhere(shape&allowed):
  v=a[yy,xx];distance=arc[near[yy,xx]]
  if distance<16 and v[3]>0 and v[0]>60 and v[0]>=v[1]>=v[2]:
   mix=np.clip((distance-5)/11,0,1)
   texture[yy,xx,:3]=native(v[:3].astype(float)*(1-mix)+texture[yy,xx,:3]*mix)
 rump=Image.new("L",(160,160));ImageDraw.Draw(rump).polygon([(61,96),(86,96),(90,104),(88,108),(84,111),(80,112),(76,112),(71,110),(66,108),(63,105),(62,102)],fill=255)
 rump=(np.array(rump)>0)&allowed&(a[:,:,3]>0)
 out[rump]=a[rump]
 opaque=out[:,:,3]>0;inner=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 out[rump&~inner,:3]=native((43,27,21))
 for yy,xx in np.argwhere(foot):
  out[yy,xx]=[*native(original[yy,xx,:3]),255]
 under=out.copy()
 paint=allowed&shape
 out[paint]=texture[paint]
 for yy,xx in np.argwhere(paint):out[yy,xx,:3]=native(out[yy,xx,:3])
 opaque=out[:,:,3]>0;inner=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 out[paint&~inner,:3]=native((43,27,21))
 out[ly,lx+8]=a[ly,lx]
 diff=np.any(out!=a,2);assert not np.any(diff&~allowed)
 Image.fromarray(out).save(D/"draft"/("coalcrest-back-hidden-leg-"+key+".png"))
 Image.fromarray(under).save(D/"draft"/("coalcrest-back-hidden-leg-under-"+key+".png"))
 for name,mask in [("allowed",allowed),("changed",diff),("lamp-source",lamp),("original-far-foot",foot),("foreground-tail",paint)]:
  Image.fromarray(mask.astype("uint8")*255).save(D/"masks"/("coalcrest-back-hidden-"+key+"-"+name+".png"))
 info={"tail_points":points,"tail_widths":widths,"far_leg_hidden":True,"original_far_foot_only":True,"lamp_shift_x":8,"changed_pixels":int(diff.sum()),"bounds":Image.fromarray(out).getbbox(),"sha256":hashlib.sha256((D/"draft"/("coalcrest-back-hidden-leg-"+key+".png")).read_bytes()).hexdigest()}
 (D/("hidden-leg-"+key+".json")).write_text(json.dumps(info,indent=2))
 return out,info
sheet=Image.new("RGB",(1280,660),(63,71,72));draw=ImageDraw.Draw(sheet);infos=[]
for i,key in enumerate(["e","f"]):
 out,info=build(key);infos.append(info)
 tile=Image.fromarray(out).resize((640,640),Image.Resampling.NEAREST);sheet.paste(tile,(i*640,20),tile)
 draw.text((i*640+8,3),"COALCREST REAR HIDDEN LEG "+key.upper(),fill="white")
sheet.save(D/"review/coalcrest-rear-hidden-leg-candidates.png")
print(json.dumps(infos))

import shutil
shutil.copy2(D/"draft/coalcrest-back-hidden-leg-e.png",D/"draft/coalcrest-back-draft.png")
shutil.copy2(D/"draft/coalcrest-back-hidden-leg-under-e.png",D/"draft/coalcrest-back-leg-before-occlusion.png")
for name in ["allowed","changed","lamp-source","original-far-foot","foreground-tail"]:
 shutil.copy2(D/"masks"/("coalcrest-back-hidden-e-"+name+".png"),D/"masks"/("coalcrest-back-"+name+".png"))
(D/"coalcrest-rear-geometry.json").write_text((D/"hidden-leg-e.json").read_text())
