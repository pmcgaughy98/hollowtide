from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,math
from coalcrest_curve_helpers import smooth
R=Path(__file__).resolve().parents[1]
S=R/"sources"
D=R/"rebuild";D.mkdir(exist_ok=True)
def rgba(p):return np.array(Image.open(p).convert("RGBA"))
def poly(points):
 im=Image.new("L",(160,160));ImageDraw.Draw(im).polygon(points,fill=255);return np.array(im)>0
def nearest_color(c,palette):
 return palette[((palette.astype(float)-np.array(c))**2).sum(1).argmin()]
def stroke(a,points,color,width=1):
 im=Image.fromarray(a);ImageDraw.Draw(im).line(points,fill=(*color,255),width=width);a[:]=np.array(im)
def pfill(a,points,color):a[poly(points)]=[*color,255]
def geometry(points,widths):
 path=smooth(points,widths)
 arc=np.cumsum(np.r_[0,np.linalg.norm(np.diff(path[:,:2],axis=0),axis=1)])
 tangent=np.gradient(path[:,:2],axis=0);tangent/=np.maximum(np.linalg.norm(tangent,axis=1)[:,None],.001)
 normal=np.column_stack([-tangent[:,1],tangent[:,0]])
 y,x=np.mgrid[:160,:160];diff=np.stack([x,y],-1)[:,:,None,:]-path[None,None,:,:2]
 dist=(diff*diff).sum(3);near=dist.argmin(2)
 shape=dist.min(2)<=(path[near,2]/2)**2
 u=(diff*np.array(normal)[None,None]).sum(3)[y,x,near]/np.maximum(path[near,2]/2,.001)
 return shape,path,arc,near,u,normal
def skin_tail(original,points,widths,view):
 shape,path,arc,near,u,norm=geometry(points,widths)
 palette=np.unique(original[original[:,:,3]>0,:3],axis=0)
 # Native ramps and material bands, with screen-space top-left lighting.
 if view=="front":
  ramp=np.array([[49,30,29],[75,48,40],[106,70,50],[120,84,64]])
  bands=np.array([[65,41,36],[106,70,50],[156,88,48],[170,99,53]])
 else:
  ramp=np.array([[75,48,40],[106,70,50],[120,84,64],[177,122,76]])
  bands=np.array([[88,56,43],[120,84,64],[156,88,48],[177,122,76]])
 out=np.zeros_like(original)
 for y,x in np.argwhere(shape):
  i=near[y,x];s=arc[i];v=float(u[y,x])
  light=float(np.dot(norm[i],np.array([-.6,-.8]))*v)
  level=0 if light<-.62 else 1 if light<-.12 else 2 if light<.62 else 3
  # Root material fixes the band phase; upper faces carry the wider highlights.
  phase=(s+1.7*v*v+.8*v+2.5)%10.5
  ring=phase<2.0
  color=bands[level] if ring else ramp[level]
  # Small scale breaks follow the material/axis, avoiding random detached spark pixels.
  if not ring and level==2 and 4.1<phase<5.3 and -.12<v<.36:color=ramp[1]
  # Through the root and first band retain the actual authored surface at its position.
  native=original[y,x]
  valid=native[3]>0 and native[0]>60 and native[0]>=native[1]>=native[2]
  if valid and s<18:
   mix=np.clip((s-8)/10,0,1)
   color=nearest_color(native[:3].astype(float)*(1-mix)+color*mix,palette)
  else:color=nearest_color(color,palette)
  out[y,x]=[*color,255]
 return shape,out,path,arc,near
def repaint_rear_leg(a,before):
 # Texture the visible leg using the authored hind shin, retaining a shaded depth ramp.
 region=poly([(55,102),(65,100),(66,112),(65,125),(55,126),(55,116)])
 bounds=[61,61,60,60,60,60,59,59,59,59,58,58,58,57,57,57,56,56,56]
 original=rgba(S/"original-back.png")
 shadow_ramp=np.array([[37,27,25],[49,30,29],[75,48,40],[88,56,43],[106,70,50],[120,84,64]])
 for y,left in enumerate(bounds,104):
  for x in range(55,65):
   if not region[y,x]:continue
   if x<left:a[y,x]=0
   elif before[y,x,3]>0:
    if x==left:a[y,x]=[37,27,25,255];continue
    # Reuse actual shin clusters, without borrowing an emitter color.
    sample=original[113+(y-104)//2,96+min(x-left,5),:3].astype(float)
    brightness=float(sample.mean())
    k=2 if brightness<48 else 3 if brightness<68 else 4
    if y in [108,109,114,115,119] and x>=left+2:k=min(5,k+1)
    if x==left+1:k=max(1,k-1)
    a[y,x]=[*shadow_ramp[k],255]
 return region
def feet_detail(a,view):
 # Refine toe surfaces at pixel scale, all colors from this creature's skin.
 M=(75,48,40);B=(106,70,50);H=(120,84,64);S=(49,30,29);O=(10,2,0)
 if view=="front":
  # Smooth the ankle-to-foot saddle; three scuted toes, no rectangular bright blocks.
  stroke(a,[(61,129),(62,130),(62,132)],B)
  stroke(a,[(61,131),(64,133)],H)
  stroke(a,[(61,134),(63,135),(64,137)],B)
  stroke(a,[(63,136),(65,136),(66,138)],M)
  stroke(a,[(65,138),(66,139)],H)
  stroke(a,[(60,137),(60,139)],B)
  stroke(a,[(69,136),(71,136),(73,138)],B)
  stroke(a,[(67,133),(67,135)],S)
  a[137,74]=[*O,255];a[138,74]=[*O,255]
  # Right ankle texture continues into the upper toe plane.
  stroke(a,[(95,128),(96,129),(96,130)],B)
  stroke(a,[(97,131),(99,132),(101,133)],H)
  stroke(a,[(103,133),(106,133)],B)
  stroke(a,[(108,134),(110,134)],H)
  stroke(a,[(112,135),(114,136)],B)
  a[137,117]=[*O,255];a[138,116]=[*O,255]
 else:
  # Far foot has fine scales at the ankle and restrained separate claw tips.
  stroke(a,[(74,127),(74,129),(76,131)],B)
  stroke(a,[(74,130),(75,131),(77,132)],H)
  stroke(a,[(78,132),(80,132),(81,133)],B)
  stroke(a,[(82,133),(83,134)],B)
  stroke(a,[(85,133),(87,134)],H)
  stroke(a,[(75,129),(76,130)],S)
  # Keep the authored near hind foot, cleaning one protruding underside pixel only.
def lamp_detail(a):
 # Tiny continuous aged-metal/skin clusters within the existing cage, preserving silhouette.
 stroke(a,[(34,86),(35,88),(35,91)],(120,84,64))
 stroke(a,[(35,93),(35,96)],(106,70,50))
 stroke(a,[(35,100),(34,103)],(75,48,40))
 stroke(a,[(26,92),(26,95)],(106,70,50))
 stroke(a,[(42,94),(42,96)],(106,70,50))
 a[83,33]=[177,122,76,255]
ys,xs=np.mgrid[:160,:160]
records=[]
for view in ["front","back"]:
 before=rgba(S/(view+"-before.png"));original=rgba(S/("original-"+view+".png"));a=before.copy()
 # Fixed masks come from the prior authored repair regions, enlarged only for the allowed leg surfaces.
 allowed=np.array(Image.open(S/(view+"-authorized-regions.png")))>0
 if view=="front":
  points=[(64,106),(55,116),(45,124),(34,128),(24,123),(17,113),(15,99),(18,85),(25,75),(31,72),(35,79)]
  widths=[22,17,12,9,7,6,5,4.5,4,3.5,3.5]
  region=poly([(5,66),(41,66),(46,85),(45,101),(60,109),(61,125),(48,139),(29,144),(14,138),(5,120)])
  signed=(xs-55)*-.67+(ys-116)*.74
  paint=region&((signed>0)|((xs<44)&(ys<116)))
 else:
  points=[(64,121),(52,130),(40,132),(28,126),(18,113),(15,98),(18,84),(25,75),(31,72),(35,79)]
  widths=[20,14,9,7.5,6,5,4.5,4,3.5,3.5]
  region=poly([(5,66),(41,66),(46,87),(47,102),(61,110),(73,118),(74,139),(55,144),(24,142),(5,121)])
  signed=(xs-61)*-.76+(ys-126)*.65
  paint=region&((signed>0)|((xs<42)&(ys<119)))
  leg=repaint_rear_leg(a,before);allowed|=leg
 shape,texture,path,arc,near=skin_tail(original,points,widths,view)
 # Preserve the existing organ and foot occlusion. Paint the tail through its actual proximal join.
 lamp=np.zeros((160,160),bool);lamp[77:110,18:51]=True
 # Protect only the real organ pixels, leaving the curl surface within the nominal bulb rectangle editable.
 lamp &= before[:,:,3]>0
 lamp &= ~shape
 paint &= ~lamp
 foot=np.zeros((160,160),bool)
 if view=="front":foot[127:143,57:78]=True
 else:foot[126:140,65:91]=True
 paint &= ~foot
 a[paint]=0;a[paint&shape]=texture[paint&shape]
 opaque=a[:,:,3]>0
 interior=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 # One coherent outline follows the final silhouette, never a transverse seam.
 edge=paint&shape&~interior;a[edge,:3]=[43,27,21]
 # Root band matching extends to both sides of the join, retaining original anatomy.
 seam=region&shape&interior&(abs(signed)<2.3)&(ys>=110)&allowed&~foot
 a[seam]=texture[seam]
 feet_detail(a,view);lamp_detail(a)
 diff=np.any(a!=before,2)
 assert not np.any(diff&~allowed),(view,np.argwhere(diff&~allowed).tolist())
 Image.fromarray(a).save(D/("coalcrest_"+view+"-draft.png"))
 Image.fromarray(allowed.astype("uint8")*255).save(D/(view+"-authorized-regions.png"))
 Image.fromarray(diff.astype("uint8")*255).save(D/(view+"-changed-pixels.png"))
 bg=Image.new("RGBA",(160,160),(108,118,119,255));bg.alpha_composite(Image.fromarray(a))
 bg.resize((800,800),Image.Resampling.NEAREST).convert("RGB").save(D/(view+"-draft-5x.png"))
 records.append({"view":view,"changed_pixels":int(diff.sum()),"bbox":Image.fromarray(a).getbbox(),"tail_points":points,"tail_widths":widths})
(D/"draft-audit.json").write_text(json.dumps(records,indent=2));print(json.dumps(records))
