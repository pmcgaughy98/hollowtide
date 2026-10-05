from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,hashlib
from coalcrest_curve_helpers import smooth
W=Path(__file__).resolve().parent
D=W
(D/"draft").mkdir(exist_ok=True);(D/"masks").mkdir(exist_ok=True)
def geometry(h,w,points,widths):
 path=smooth(points,widths);arc=np.cumsum(np.r_[0,np.linalg.norm(np.diff(path[:,:2],axis=0),axis=1)])
 tan=np.gradient(path[:,:2],axis=0);tan/=np.maximum(np.linalg.norm(tan,axis=1)[:,None],.001)
 normal=np.column_stack([-tan[:,1],tan[:,0]])
 yy,xx=np.mgrid[:h,:w];diff=np.stack([xx,yy],-1)[:,:,None,:]-path[None,None,:,:2]
 d=(diff*diff).sum(3);near=d.argmin(2);shape=d.min(2)<=(path[near,2]/2)**2
 u=(diff*normal[None,None]).sum(3)[yy,xx,near]/np.maximum(path[near,2]/2,.001)
 return shape,path,arc,near,u,normal
def nearest(color,palette):return palette[((palette.astype(float)-np.array(color))**2).sum(1).argmin()]
records=[]
for spec in json.loads((D/"current-specs.json").read_text()):
 name=spec["species"];view=spec["view"];key=name+"-"+view
 im=Image.open(D/"sources"/spec["snapshot"]).convert("RGBA");a=np.array(im);out=a.copy()
 h,w=a.shape[:2];yy,xx=np.mgrid[:h,:w];allowed=np.zeros((h,w),bool)
 palette=np.unique(a[a[:,:,3]>0,:3],axis=0)
 if key=="wayburn-front":
  points=[(77,81),(62,85),(43,81),(29,70),(25,54),(31,39),(43,31),(57,32),(70,37),(83,34),(93,28)]
  widths=[13,13,11,10,8,8,8,7,6,5,3]
  shape,path,arc,near,u,norm=geometry(h,w,points,widths)
  # Restrict the actual edit to the exposed upper curl. Original hip/stripe/light organ are exact.
  allowed=(yy>=26)&(yy<=70)&(xx>=18)&(xx<=92)
  # Top-left lighting and native dorsal bands continue up the previously flat, narrow surface.
  ramp=np.array([[118,71,40],[141,93,53],[171,124,68],[192,143,75]])
  bands=np.array([[87,57,36],[118,71,40],[141,93,53],[171,124,68]])
  cream=[183,156,113]
  out[allowed]=0
  for y,x in np.argwhere(shape&allowed):
   i=near[y,x];v=float(u[y,x]);s=float(arc[i])
   light=float(np.dot(norm[i],[-.6,-.8])*v)
   level=0 if light<-.62 else 1 if light<-.15 else 2 if light<.55 else 3
   phase=(s+1.2*v*v+.6*v-1.3)%9.5
   c=bands[level] if phase<1.7 else ramp[level]
   # The cream ventral edge is narrow, following the underside rather than coating the shaft.
   if v>.52 and level>=1 and s<83:c=cream if phase>=1.7 else [141,112,73]
   # A four-pixel material transition meets the existing lower tail without a horizontal seam.
   if y>=67 and a[y,x,3]>0 and a[y,x,0]>45:
    blend=(y-67)/4;c=np.array(c)*(1-blend)+a[y,x,:3]*blend
   out[y,x]=[*nearest(c,palette),255]
  opaque=out[:,:,3]>0;inner=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
  edge=allowed&shape&~inner;out[edge,:3]=[11,2,0]
  # Existing small orange collar is an authored emitter transition, not a skin band.
  collar=(xx>=85)&(yy<=32)&(a[:,:,3]>0)&(a[:,:,0]>160)&(a[:,:,1]<100)
  out[collar]=a[collar];allowed&=~collar
  # Tone down the three pure-white inner toe/claw highlights using this sprite\'s ivory ramp.
  for y in [130,131,132]:
   allowed[y,43]=True;out[y,43,:3]=nearest([236,209,159],palette)
 elif key=="wayburn-back":
  # Preserve the original silhouette, cream anatomy and light direction.
  # Break the continuous pale strip with authored warm material bands, and shade its inner edge.
  allowed=(xx>=16)&(xx<=31)&(yy>=65)&(yy<=96)&(a[:,:,3]>0)&(a[:,:,0]>65)
  points=[(42,100),(28,98),(21,91),(20,81),(22,73),(29,66),(39,62)]
  widths=[13,10,9,8,7,5,4]
  shape,path,arc,near,u,norm=geometry(h,w,points,widths)
  for y,x in np.argwhere(allowed):
   i=near[y,x];s=float(arc[i]);v=float(u[y,x]);native=a[y,x,:3]
   phase=(s+1.3*v*v+.4*v+1.0)%9.5
   # Brightest one-pixel rim remains cream. Broad interior fades into the body tan.
   edge_dist=min(x-16,31-x)
   if native[0]>199:
    weight=.45 if x<=19 else .68
    target=np.array([192,166,119])
    c=native.astype(float)*(1-weight)+target*weight
    if phase<1.7:c=np.array([171,141,98])
   elif phase<1.7 and native[0]>155:c=native.astype(float)*.7+np.array([141,112,73])*.3
   else:continue
   out[y,x,:3]=nearest(c,palette)
 diff=np.any(a!=out,2)
 assert not np.any(diff&~allowed),key
 Image.fromarray(out).save(D/"draft"/(key+"-draft.png"))
 Image.fromarray(allowed.astype("uint8")*255).save(D/"masks"/(key+"-allowed.png"))
 Image.fromarray(diff.astype("uint8")*255).save(D/"masks"/(key+"-changed.png"))
 records.append({"key":key,"changed_pixels":int(diff.sum()),"allowed_pixels":int(allowed.sum()),"alpha_changed":int(np.sum((a[:,:,3]!=out[:,:,3]))),"retained_exact":not np.any(diff)})
 if name=="wayburn":
  sheet=Image.new("RGB",(w*8,h*4+32),(63,71,72));draw=ImageDraw.Draw(sheet)
  for j,src in enumerate([a,out]):
   tile=Image.fromarray(src).resize((w*4,h*4),Image.Resampling.NEAREST)
   sheet.paste(tile,(j*w*4,32),tile);draw.text((j*w*4+8,8),key+(" BEFORE" if j==0 else " DRAFT"),fill="white")
  sheet.save(D/"review"/(key+"-draft-comparison.png"))
(D/"draft-audit.json").write_text(json.dumps(records,indent=2));print(json.dumps(records))
