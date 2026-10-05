from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,hashlib
from coalcrest_curve_helpers import smooth,shape_and_texture
from coalcrest_rear_helpers import geometry
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"kithflare-line-full-recheck-2026-10-04"
a=np.array(Image.open(D/"sources/coalcrest-back-before.png").convert("RGBA"))
original=np.array(Image.open(D/"sources/coalcrest-back-authored-material.png").convert("RGBA"))
y,x=np.mgrid[:160,:160]
oldshape,*_=geometry([(64,121),(52,130),(40,132),(28,126),(18,113),(15,98),(18,84),(25,75),(31,72),(35,79)],[20,14,9,7.5,6,5,4.5,4,3.5,3.5])
lamp=(x>=18)&(x<51)&(y>=78)&(y<110)&(a[:,:,3]>0)&~oldshape
allowed=((x>=12)&(x<94)&(y>=104)&(y<141))|((x>=12)&(x<54)&(y>=67)&(y<104))
# Explicitly preserve the original forearm and near/right leg.
allowed&=~((x>=52)&(x<=61)&(y>=80)&(y<=108))
ly,lx=np.nonzero(lamp);allowed[ly,lx+8]=True
srcpoints=[(82,94),(74,106),(64,119),(50,130),(32,129)]
srcwidths=[21,22,20,14,9]
palette=np.unique(a[a[:,:,3]>0,:3],axis=0)
def native(c):
 return palette[((palette.astype(float)-np.array(c))**2).sum(1).argmin()]
def outline(out,region,c):
 opaque=out[:,:,3]>0
 inner=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 out[region&~inner,:3]=native(c)
def build(key,root,legpoints,legwidths):
 out=a.copy();out[allowed]=0
 points=[root,(81,110),(71,121),(56,127),(42,125),(31,116),(25,102),(27,86),(34,76),(39,73),(43,80)]
 widths=[15,13,11,9,7,6,5,4.5,4,3.5,3.5]
 if key=="d":
  points=[(86,102),(87,112),(81,122),(68,128),(53,131),(40,126),(30,116),(25,102),(27,86),(34,76),(39,73),(43,80)]
  widths=[13,12,10,9,8,7,6,5,4.5,4,3.5,3.5]
 shape,texture=shape_and_texture(original,points,widths,srcpoints,srcwidths,(30,94,89,135))
 # Reuse authored near-leg scale clusters, shaded with native palette.
 leg,path,arc,near,u,norm=geometry(legpoints,legwidths);leg&=allowed
 source_shape,spath,sarc,snear,su,snorm=geometry([(94,98),(102,109),(94,119),(94,124),(102,133)],[14,11,9,7,5])
 sample=(original[:,:,3]>0)&source_shape&(original[:,:,0]>80)
 sy,sx=np.nonzero(sample)
 for yy,xx in np.argwhere(leg):
  i=near[yy,xx];fraction=arc[i]/arc[-1]
  j=min(len(spath)-1,int(np.searchsorted(sarc,fraction*sarc[-1])))
  desired=spath[j,:2]+snorm[j]*u[yy,xx]*(spath[j,2]/2-1)
  rx,ry=np.rint(desired).astype(int)
  if not (0<=rx<160 and 0<=ry<160 and sample[ry,rx]):
   k=((sx-desired[0])**2+(sy-desired[1])**2).argmin();rx,ry=sx[k],sy[k]
  out[yy,xx]=[*native(original[ry,rx,:3].astype(float)*.96),255]
 outline(out,leg,(37,27,25))
 # Keep an actual clawed far foot at its full authored vertical detail.
 foot=np.array(Image.fromarray(original).crop((98,131,125,140)).resize((19,7),Image.Resampling.NEAREST))
 fx0=int(legpoints[-1][0])-5;fy0=int(legpoints[-1][1])-2
 for fy,fx in np.argwhere(foot[:,:,3]>0):
  yy=fy0+fy;xx=fx0+fx
  if allowed[yy,xx]:out[yy,xx]=[*native(foot[fy,fx,:3].astype(float)*.9),255]
 under=out.copy()
 paint=allowed&shape
 out[paint]=texture[paint]
 for yy,xx in np.argwhere(paint):out[yy,xx,:3]=native(out[yy,xx,:3])
 # Existing warm brown outline; no black rectangular patches.
 outline(out,paint,(43,27,21))
 ly,lx=np.nonzero(lamp);out[ly,lx+8]=a[ly,lx]
 diff=np.any(out!=a,2);assert not np.any(diff&~allowed),np.argwhere(diff&~allowed).tolist()
 im=Image.fromarray(out);im.save(D/"draft"/("coalcrest-back-anatomy-"+key+".png"))
 Image.fromarray(under).save(D/"draft"/("coalcrest-back-underleg-"+key+".png"))
 info={"tail_points":points,"tail_widths":widths,"leg_points":legpoints,"leg_widths":legwidths,"foot_origin":[fx0,fy0],"lamp_shift_x":8,"changed_pixels":int(diff.sum()),"bounds":im.getbbox(),"sha256":hashlib.sha256((D/"draft"/("coalcrest-back-anatomy-"+key+".png")).read_bytes()).hexdigest()}
 (D/("anatomy-"+key+".json")).write_text(json.dumps(info,indent=2))
 return out,info,leg,paint
variants=[
 ("a",(85,99),[(68,103),(61,114),(59,125),(64,133),(70,134)],[13,11,7,6,4]),
 ("b",(86,99),[(67,103),(60,114),(57,123),(57,132),(65,134)],[13,10,7,6,4]),
 ("c",(85,99),[(67,103),(61,115),(63,124),(67,131),(73,133)],[13,10,7,6,4]),
 ("d",(86,102),[(71,103),(65,113),(61,121),(62,132),(64,135),(70,136)],[13,11,7,5,4,4])
]
sheet=Image.new("RGB",(1280,1320),(63,71,72));draw=ImageDraw.Draw(sheet)
rows=[]
for i,params in enumerate(variants):
 out,info,leg,paint=build(*params)
 tile=Image.fromarray(out).resize((640,640),Image.Resampling.NEAREST);sheet.paste(tile,((i%2)*640,20+(i//2)*660),tile)
 draw.text(((i%2)*640+8,3+(i//2)*660),"COALCREST REAR ANATOMY "+params[0].upper(),fill="white")
 rows.append(info)
sheet.save(D/"review/coalcrest-rear-anatomy-candidates.png")
print(json.dumps(rows))
