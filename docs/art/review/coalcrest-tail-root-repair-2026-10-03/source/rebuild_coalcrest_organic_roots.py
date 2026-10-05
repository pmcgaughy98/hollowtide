from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,hashlib
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"coalcrest-tail-root-repair"
ns={};exec((W/"assemble_kithflare_tail_material.py").read_text().split("records=[]")[0],ns);smooth=ns["smooth"]
def rgba(p):return np.array(Image.open(p).convert("RGBA"))
def shape_and_texture(material,points,widths,srcpoints,srcwidths,roi):
 path=smooth(points,widths);src=smooth(srcpoints,srcwidths)
 ta=np.cumsum(np.r_[0,np.linalg.norm(np.diff(path[:,:2],axis=0),axis=1)])
 sa=np.cumsum(np.r_[0,np.linalg.norm(np.diff(src[:,:2],axis=0),axis=1)])
 # Preserve native spacing through the root, then repeat the authored scale bands.
 arc=ta%(2*sa[-1]);arc=np.where(arc>sa[-1],2*sa[-1]-arc,arc)
 ids=np.searchsorted(sa,arc).clip(0,len(src)-1)
 tangent=np.gradient(path[:,:2],axis=0);tangent/=np.maximum(np.linalg.norm(tangent,axis=1)[:,None],.001)
 normal=np.column_stack([-tangent[:,1],tangent[:,0]])
 st=np.gradient(src[:,:2],axis=0);st/=np.maximum(np.linalg.norm(st,axis=1)[:,None],.001)
 sn=np.column_stack([-st[:,1],st[:,0]])
 y,x=np.mgrid[:160,:160];diff=np.stack([x,y],axis=-1)[:,:,None,:]-path[None,None,:,:2]
 dist=(diff*diff).sum(axis=3);near=dist.argmin(axis=2);shape=dist.min(axis=2)<=(path[near,2]/2)**2
 sample=np.zeros((160,160),bool);sample[roi[1]:roi[3],roi[0]:roi[2]]=True
 sample&=(material[:,:,3]>0)&(material[:,:,0]>60)&(material[:,:,0]>=material[:,:,1])&(material[:,:,1]>=material[:,:,2])
 sy,sx=np.nonzero(sample);out=np.zeros_like(material)
 for y,x in np.argwhere(shape):
  i=near[y,x];j=ids[i];u=np.dot(np.array([x,y])-path[i,:2],normal[i])/max(path[i,2]/2,.001)
  desired=src[j,:2]+sn[j]*u*max(src[j,2]/2-1,.5);rx,ry=np.rint(desired).astype(int)
  if not(0<=rx<160 and 0<=ry<160 and sample[ry,rx]):
   k=((sx-desired[0])**2+(sy-desired[1])**2).argmin();rx,ry=sx[k],sy[k]
  out[y,x]=material[ry,rx];out[y,x,3]=255
 return shape,out
records=[]
for view in ["front","back"]:
 original=rgba(W/"kithflare-tail-review"/("coalcrest-"+view+"-before.png"))
 prev=rgba(D/("coalcrest-"+view+"-previous.png"));out=prev.copy()
 ys,xs=np.mgrid[:160,:160]
 if view=="front":
  # Cross-section follows the native broad tail behind the thigh, not a rectangle.
  center=np.array([51.,121.]);direction=np.array([-.67,.74])
  points=[(64,106),(51,121),(40,130),(26,128),(15,115),(13,99),(17,85),(24,75),(31,72),(35,79)]
  widths=[24,22,15,10,8,7,6,5,4,4]
  srcpoints=[(64,106),(51,121),(40,126),(28,128)];srcwidths=[24,22,17,12];roi=(19,99,72,137)
  region=(xs>=7)&(xs<80)&(ys>=88)&(ys<145)
 else:
  center=np.array([43.,132.]);direction=np.array([-1.,-.08])
  points=[(64,121),(52,131),(40,134),(28,128),(16,114),(13,98),(16,84),(24,75),(31,72),(35,79)]
  widths=[20,18,14,12,10,8,7,6,5,4]
  srcpoints=[(64,121),(52,131),(40,133),(27,128)];srcwidths=[20,18,14,11];roi=(19,115,76,141)
  region=(xs>=7)&(xs<83)&(ys>=88)&(ys<145)
 bulb_guard=rgba(W/"kithflare-tail-review/original-coalcrest-lantern.png")[:,:,3]>0
 lamp_guard=np.zeros((160,160),bool);lamp_guard[78:109,19:50]=bulb_guard
 region &= ~lamp_guard
 signed=(xs-center[0])*direction[0]+(ys-center[1])*direction[1]
 if view=="back":
  paint=region&(((xs<58)&(ys>=119))|((xs<40)&(ys<119)))
 else:paint=region&(signed>0)
 root=region&~paint&(original[:,:,3]>0)
 newshape,newtexture=shape_and_texture(original,points,widths,srcpoints,srcwidths,roi)
 # Rejoin through an oblique continuous cross-section and original proximal anatomy.
 out[region&~paint]=original[region&~paint]
 out[paint]=0;out[paint&newshape]=newtexture[paint&newshape];out[root]=original[root]
 if view=="front":
  # Preserve the visible thigh and both actual feet in front of the rebuilt tail.
  thigh=region&(xs>=60)&(ys<120)&(original[:,:,3]>0);out[thigh]=original[thigh]
  out[130:153,60:118]=original[130:153,60:118];out[129,60:71]=original[129,60:71];out[129,94:118]=original[129,94:118]
  stem=np.zeros((160,160),bool);stem[121:130,72:94]=True;stem[122:129,104:154]=True
  out[stem]=0
  removed=stem&(prev[:,:,3]>0)
  adj=np.array(Image.fromarray(removed.astype("uint8")*255).filter(ImageFilter.MaxFilter(3)))>0
  edge=adj&~stem&(out[:,:,3]>0)&(out[:,:,0]>65)&(ys>=120)&(ys<130)
  out[edge,:3]=[43,27,21]
 else:
  # Authored far foot stays behind the curl, and the near leg remains exact.
  foot=(xs>=71)&(ys>=126)&(ys<137)&(original[:,:,3]>0);out[foot]=original[foot]
 # Match the outer contour, leaving no dark internal cross-cut at the overlap.
 opaque=out[:,:,3]>0
 interior=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 outer=region&opaque&~interior
 # Only silhouette edges of the rebuilt tail, never the preserved original body.
 edge=outer&paint&newshape;out[edge,:3]=[43,27,21]
 # Hidden root contour pixels become native surface where tail skin now crosses them.
 seam=region&interior&(np.abs(signed)<=2.1)&(out[:,:,0]<65)&(ys>=108)
 for y,x in np.argwhere(seam&newshape):out[y,x]=newtexture[y,x]
 bulb=rgba(W/"kithflare-tail-review/original-coalcrest-lantern.png");b=bulb[:,:,3]>0
 assert np.array_equal(out[78:109,19:50][b],bulb[b])
 assert np.array_equal(out[:88],prev[:88])
 if view=="front":
  out[114,43]=0;out[115,43,:3]=[43,27,21]
  out[130:153,60:118]=original[130:153,60:118];out[129,60:71]=original[129,60:71];out[129,94:118]=original[129,94:118]
  assert np.array_equal(out[130:153,60:118],original[130:153,60:118])
  assert np.array_equal(out[129,60:71],original[129,60:71])
  assert np.array_equal(out[129,94:118],original[129,94:118])
 if view=="back":
  # Remove the final old underside ledge at the proximal overlap.
  for x in range(57,65):
   bottom=139 if x<=60 else 138
   out[bottom+1:145,x]=0;out[bottom,x]=[43,27,21,255]
 diff=np.any(out!=prev,axis=2)
 Image.fromarray(out).save(D/("coalcrest-"+view+"-organic-root.png"))
 Image.fromarray(diff.astype("uint8")*255).save(D/("coalcrest-"+view+"-organic-mask.png"))
 Image.fromarray(root.astype("uint8")*255).save(D/("coalcrest-"+view+"-organic-original-root.png"))
 records.append({"view":view,"changed_pixels":int(diff.sum()),"bbox":Image.fromarray(out).getbbox()})
sheet=Image.new("RGB",(540,360),(60,68,69))
for row,view in enumerate(["front","back"]):
 for col,suf in enumerate(["previous","root-repaired","organic-root"]):
  im=Image.open(D/("coalcrest-"+view+"-"+suf+".png"))
  sheet.paste(im,(col*180+8,row*180+16),im);ImageDraw.Draw(sheet).text((col*180+5,row*180+2),view.upper()+" "+suf,fill="white")
sheet.resize((1620,1080),Image.Resampling.NEAREST).save(D/"organic-root-comparison.png")
(D/"organic-draft-audit.json").write_text(json.dumps(records,indent=2));print(json.dumps(records))
