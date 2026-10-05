from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"coalcrest-refinement-2026-10-04"
from coalcrest_curve_helpers import shape_and_texture
def rgba(p):return np.array(Image.open(p).convert("RGBA"))
def polygon(points):
 im=Image.new("L",(160,160));ImageDraw.Draw(im).polygon(points,fill=255);return np.array(im)>0
def paint_poly(a,points,c):
 m=polygon(points);a[m]=[*c,255]
def choose(rgb,palette):
 return palette[((palette-np.array(rgb))**2).sum(1).argmin()].tolist()
orig_lamp=rgba(W/"kithflare-tail-review/original-coalcrest-lantern.png")
palette=np.unique(orig_lamp[orig_lamp[:,:,3]>0,:3],axis=0).astype(int)
lc=lambda c:choose(c,palette)
def lantern(a):
 # Keep the authored hanging organ/cage identity, with a slimmer, rounded silhouette.
 # Original organ is erased before reconstructing the tail; never clear its whole rectangle.
 O=lc((30,14,10));Dk=lc((65,39,31));B=lc((104,67,48));H=lc((151,98,53))
 A=lc((196,114,20));G=lc((248,174,32));Y=lc((255,210,62));L=lc((255,233,123))
 paint_poly(a,[(31,78),(37,78),(38,82),(43,84),(47,90),(48,98),(46,103),(42,107),(27,107),(23,103),(20,98),(21,89),(25,84),(30,82)],O)
 paint_poly(a,[(31,81),(37,81),(38,85),(42,87),(45,91),(45,98),(43,102),(40,104),(29,104),(25,101),(23,97),(24,90),(28,86)],A)
 paint_poly(a,[(29,86),(39,86),(42,90),(43,97),(41,101),(38,103),(29,102),(25,97),(26,90)],G)
 paint_poly(a,[(30,86),(38,86),(40,91),(40,98),(38,102),(30,101),(28,97),(28,90)],Y)
 paint_poly(a,[(32,87),(35,87),(36,91),(36,96),(33,97),(31,93)],L)
 # Rib arcs follow the bulb contour. Three shaded ribs match the original cage.
 paint_poly(a,[(26,85),(29,84),(27,90),(26,98),(29,105),(26,103),(24,98),(25,90)],Dk)
 paint_poly(a,[(28,87),(29,87),(27,93),(27,98),(29,103),(28,103),(26,98),(26,93)],B)
 paint_poly(a,[(33,82),(36,82),(38,88),(38,98),(36,106),(33,106),(34,98),(34,89)],Dk)
 paint_poly(a,[(34,84),(35,84),(36,89),(36,99),(35,104),(34,104),(35,98),(35,89)],B)
 paint_poly(a,[(40,85),(42,87),(44,93),(44,99),(41,105),(39,106),(41,98),(41,92)],Dk)
 paint_poly(a,[(41,88),(42,89),(43,94),(43,98),(41,102),(40,102),(42,97)],B)
 paint_poly(a,[(29,82),(32,80),(36,80),(39,83),(38,85),(31,84)],Dk)
 paint_poly(a,[(31,81),(35,81),(37,82),(33,82)],H)
 paint_poly(a,[(29,105),(40,105),(39,107),(30,107)],Dk)
 return a
O=(37,27,25);S=(49,30,29);M=(75,48,40);B=(106,70,50);H=(120,84,64)
def front_feet(a):
 # Left foot keeps the authored ankle angle, with fine claws and less square edges.
 a[128:143,57:78]=0
 paint_poly(a,[(61,128),(67,128),(68,132),(68,134),(72,135),(75,138),(74,140),(72,139),(70,137),(68,138),(68,140),(66,141),(64,140),(64,138),(62,137),(61,140),(59,140),(59,136),(60,133)],(10,2,0))
 paint_poly(a,[(61,128),(66,128),(66,132),(67,134),(70,135),(72,137),(70,136),(67,136),(66,137),(65,139),(64,137),(61,136),(60,138),(60,135)],M)
 paint_poly(a,[(61,129),(63,129),(63,132),(65,134),(65,135),(63,134),(61,133)],B)
 paint_poly(a,[(65,129),(66,130),(66,133),(65,134)],S)
 paint_poly(a,[(60,136),(61,136),(60,139)],(96,62,46))
 paint_poly(a,[(65,138),(66,138),(66,140),(65,140)],(96,62,46))
 paint_poly(a,[(72,137),(73,138),(73,139)],(96,62,46))
 # Right foot: shin stays attached; an unbroken heel and three tapered toe ends.
 a[127:141,91:121]=0
 paint_poly(a,[(94,127),(100,127),(100,130),(104,132),(111,132),(116,134),(118,137),(116,139),(113,137),(112,135),(109,135),(111,137),(109,138),(107,135),(103,135),(104,137),(101,137),(97,135),(94,132)],O)
 paint_poly(a,[(95,127),(98,127),(98,131),(102,133),(110,133),(113,134),(115,136),(114,136),(111,134),(106,134),(104,135),(100,135),(97,133),(95,130)],M)
 paint_poly(a,[(95,127),(96,127),(97,130),(100,132),(103,133),(100,133),(97,132),(95,130)],B)
 paint_poly(a,[(105,133),(110,133),(110,134),(105,134)],B)
 paint_poly(a,[(115,135),(116,136),(116,137),(115,136)],H)
 paint_poly(a,[(109,135),(110,137),(109,137)],H)
def rear_leg(a):
 # Repaint and tuck in the old emitter-shaped silhouette as a slim, shaded far leg.
 m=polygon([(55,102),(65,100),(66,112),(65,125),(55,126),(55,116)])
 bounds=[61,61,60,60,60,60,59,59,59,59,58,58,58,57,57,57,56,56,56]
 for y,left in enumerate(bounds,104):
  for x in range(55,65):
   if not m[y,x]:continue
   if x<left:a[y,x]=0
   elif a[y,x,3]>0:
    a[y,x,:3]=(37,27,25) if x==left else (M if x<=left+1 else B)
 # Far hind foot is side-on and partly hidden behind the tail.
 a[127:140,65:91]=0
 paint_poly(a,[(72,126),(77,126),(77,129),(79,131),(84,131),(89,133),(89,135),(87,135),(84,133),(82,133),(84,135),(82,136),(80,134),(77,134),(74,133),(72,131)],(9,1,1))
 paint_poly(a,[(73,126),(76,126),(76,129),(78,131),(80,132),(83,132),(86,133),(87,134),(85,133),(82,132),(81,133),(78,133),(75,132),(73,130)],M)
 paint_poly(a,[(74,127),(75,127),(75,130),(77,131),(76,132),(74,131)],(96,62,46))
 paint_poly(a,[(82,132),(84,133),(84,134),(82,133)],B)
 paint_poly(a,[(87,133),(88,134),(88,134)],(96,62,46))
 return m
ys,xs=np.mgrid[:160,:160];records=[]
for view in ["front","back"]:
 prev=rgba(D/(view+"-before.png"));original=rgba(W/"kithflare-tail-review"/("coalcrest-"+view+"-before.png"));out=prev.copy()
 if view=="front":
  points=[(64,106),(55,116),(45,124),(34,128),(24,123),(17,113),(15,99),(18,85),(25,75),(31,72),(35,79)]
  widths=[22,17,12,9,7,6,5,4.5,4,3.5,3.5]
  srcpoints=[(64,106),(51,121),(40,126),(28,128)];srcwidths=[24,22,17,12];roi=(19,99,72,137)
  tail_region=polygon([(5,66),(41,66),(46,85),(45,101),(60,109),(61,125),(48,139),(29,144),(14,138),(5,120)])
  signed=(xs-55)*-.67+(ys-116)*.74
  paint=tail_region&((signed>0)|((xs<44)&(ys<116)))
  foot_region=np.zeros((160,160),bool);foot_region[127:143,57:78]=True;foot_region[127:141,91:121]=True
  allowed=tail_region|foot_region
 else:
  points=[(64,121),(52,130),(40,132),(28,126),(18,113),(15,98),(18,84),(25,75),(31,72),(35,79)]
  widths=[20,14,9,7.5,6,5,4.5,4,3.5,3.5]
  srcpoints=[(64,121),(52,131),(40,133),(27,128)];srcwidths=[20,18,14,11];roi=(19,115,76,141)
  tail_region=polygon([(5,66),(41,66),(46,87),(47,102),(61,110),(73,118),(74,139),(55,144),(24,142),(5,121)])
  signed=(xs-61)*-.76+(ys-126)*.65
  paint=tail_region&((signed>0)|((xs<42)&(ys<119)))
  leg_region=rear_leg(out);far_leg_layer=out.copy()
  foot_region=np.zeros((160,160),bool);foot_region[126:140,65:91]=True
  allowed=tail_region|leg_region|foot_region
 lamp_region=np.zeros((160,160),bool);lamp_region[77:110,18:51]=True
 allowed|=lamp_region
 old_lamp_mask=np.zeros((160,160),bool);old_lamp_mask[78:109,19:50]=orig_lamp[:,:,3]>0
 out[old_lamp_mask]=0
 shape,texture=shape_and_texture(original,points,widths,srcpoints,srcwidths,roi)
 out[paint]=0;out[paint&shape]=texture[paint&shape]
 opaque=out[:,:,3]>0
 interior=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
 edge=paint&shape&~interior;out[edge,:3]=[43,27,21]
 seam=paint&shape&interior&(abs(signed)<2)&(out[:,:,0]<65)&(ys>106)
 out[seam]=texture[seam]
 if view=="front":front_feet(out)
 else:
  # Far foot is in front of the hidden tail cross-section, with no amber remnant.
  layer_mask=(leg_region|foot_region)&~shape
  out[layer_mask]=far_leg_layer[layer_mask]
 lantern(out)
 diff=np.any(prev!=out,axis=2)
 assert not np.any(diff&~allowed),("outside allowed",view,np.argwhere(diff&~allowed).tolist())
 assert np.array_equal(prev[:65],out[:65])
 Image.fromarray(out).save(D/("coalcrest_"+view+"-draft.png"))
 Image.fromarray(allowed.astype("uint8")*255).save(D/(view+"-authorized-regions.png"))
 Image.fromarray(diff.astype("uint8")*255).save(D/(view+"-changed-pixels.png"))
 bg=Image.new("RGBA",(160,160),(102,111,114,255));bg.alpha_composite(Image.fromarray(out))
 bg.resize((960,960),Image.Resampling.NEAREST).convert("RGB").save(D/(view+"-draft-enlarged.png"))
 records.append({"view":view,"changed_pixels":int(diff.sum()),"bbox":Image.fromarray(out).getbbox(),"tail_parameters":{"points":points,"widths":widths}})
sheet=Image.new("RGB",(720,400),(89,99,101));draw=ImageDraw.Draw(sheet)
for row,view in enumerate(["front","back"]):
 for col,suf in enumerate(["before","draft"]):
  path=D/(view+"-before.png" if suf=="before" else "coalcrest_"+view+"-draft.png")
  im=Image.open(path).convert("RGBA").resize((320,320),Image.Resampling.NEAREST)
  # full-size comparison has one row per view, native 160px at 1x in this composite before 3x display
  im=Image.open(path).convert("RGBA");sheet.paste(im,(col*360+95,row*200+28),im)
  draw.text((col*360+95,row*200+8),view+" "+suf,fill="white")
sheet.resize((1440,800),Image.Resampling.NEAREST).save(D/"draft-comparison.png")
(D/"draft-audit.json").write_text(json.dumps(records,indent=2));print(json.dumps(records))
