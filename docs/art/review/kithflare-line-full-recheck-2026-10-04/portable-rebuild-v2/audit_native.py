from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,collections
W=Path(__file__).resolve().parent;D=W
def components(mask):
 seen=np.zeros_like(mask,bool);counts=[]
 for y,x in np.argwhere(mask):
  if seen[y,x]:continue
  queue=collections.deque([(int(x),int(y))]);seen[y,x]=True;n=0
  while queue:
   x,y=queue.popleft();n+=1
   for dy in [-1,0,1]:
    for dx in [-1,0,1]:
     yy,xx=y+dy,x+dx
     if 0<=yy<mask.shape[0] and 0<=xx<mask.shape[1] and mask[yy,xx] and not seen[yy,xx]:
      seen[yy,xx]=True;queue.append((xx,yy))
  counts.append(n)
 return sorted(counts,reverse=True)
def corridor_path(a,points,widths):
 from coalcrest_curve_helpers import smooth
 h,w=a.shape[:2];path=smooth(points,widths);yy,xx=np.mgrid[:h,:w]
 dist=(xx[:,:,None]-path[None,None,:,0])**2+(yy[:,:,None]-path[None,None,:,1])**2
 near=dist.argmin(2);corridor=(dist.min(2)<=(path[near,2]/2+2)**2)&(a[:,:,3]>0)
 def seed(pt):
  yx=np.argwhere(corridor);idx=((yx[:,1]-pt[0])**2+(yx[:,0]-pt[1])**2).argmin()
  return tuple(yx[idx,::-1]),float(np.sqrt(((yx[idx,::-1]-pt)**2).sum()))
 start,ds=seed(points[0]);end,de=seed(points[-1]);assert ds<3 and de<3,(ds,de)
 seen=set([start]);queue=collections.deque([start])
 while queue:
  x,y=queue.popleft()
  for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]:
   nxt=(x+dx,y+dy);xx,yy=nxt
   if nxt not in seen and 0<=xx<w and 0<=yy<h and corridor[yy,xx]:
    seen.add(nxt);queue.append(nxt)
 return end in seen,len(seen)
tails={
"kithflare-front":([(63,94),(45,87),(32,72),(29,53),(37,33),(48,27),(57,35),(59,48)],[18,16,13,11,10,9,6,10]),
"kithflare-back":([(71,107),(45,94),(33,80),(31,63),(38,44),(47,40),(56,47),(58,59)],[17,15,13,11,10,8,5,10]),
"wayburn-front":([(77,81),(62,85),(43,81),(29,70),(25,54),(31,39),(43,31),(57,32),(70,37),(83,34),(93,28),(100,20)],[13,13,11,10,8,8,8,7,6,5,3,10]),
"wayburn-back":([(65,98),(43,103),(28,99),(20,88),(20,77),(27,67),(40,61),(39,52),(33,46),(24,35)],[17,15,13,10,8,6,4,3,3,12]),
"coalcrest-front":([(64,106),(55,116),(45,124),(34,128),(24,123),(17,113),(15,99),(18,85),(25,75),(31,72),(35,79),(34,93)],[22,17,12,9,7,6,5,4.5,4,3.5,3.5,18]),
"coalcrest-back":([(64,121),(52,130),(40,132),(28,126),(18,113),(15,98),(18,84),(25,75),(31,72),(35,79),(34,94)],[20,14,9,7.5,6,5,4.5,4,3.5,3.5,18])
}
rear=json.loads((D/"coalcrest-rear-geometry.json").read_text())
tails["coalcrest-back"]=(rear["tail_points"]+[(42,94)],rear["tail_widths"]+[18])
records=[]
for spec in json.loads((D/"current-specs.json").read_text()):
 key=spec["species"]+"-"+spec["view"];before=np.array(Image.open(D/"sources"/spec["snapshot"]).convert("RGBA"));a=np.array(Image.open(D/"draft"/(key+"-draft.png")).convert("RGBA"))
 allowed=np.array(Image.open(D/"masks"/(key+"-allowed.png")))>0;diff=np.any(a!=before,2);opaque=a[:,:,3]>0
 c=components(opaque);oldc=components(before[:,:,3]>0)
 points,widths=tails[key];connected,pathpixels=corridor_path(a,points,widths)
 bounds=Image.fromarray(a).getbbox();h,w=a.shape[:2]
 palette=set(map(tuple,before[before[:,:,3]>0,:3]));nativepalette=all(tuple(rgb) in palette for rgb in a[opaque,:3])
 # Eye catchlights are authored white; isolate that known anatomy from fringe checks.
 white=(opaque&(a[:,:,:3].min(2)>244));eye=np.zeros_like(white)
 if key=="kithflare-front":eye[31:38,100:110]=True
 foot_guard=diff.copy()
 if key=="wayburn-front":foot_guard[130:133,43]=False
 if key=="coalcrest-back":foot_guard[allowed]=False
 # Local material masks exclude every head/eye/frill/torso/limb except the three toe highlights.
 tests={"canvas_preserved":a.shape==before.shape,"binary_alpha":set(np.unique(a[:,:,3])).issubset({0,255}),"native_palette_only":nativepalette,"outside_regions_exact":not np.any(diff&~allowed),"no_new_islands":len(c)<=len(oldc),"single_body_component":len(c)==1,"tail_corridor_4_connected":connected,"no_canvas_clipping":bounds[0]>0 and bounds[1]>0 and bounds[2]<w and bounds[3]<h,"head_eyes_frill_exact":not np.any(diff[(np.indices(diff.shape)[1]>=94) if key=="wayburn-front" else np.zeros(diff.shape,bool)]),"no_unclassified_white_pixels":not np.any(white&~eye),"feet_except_three_toe_highlights_exact":not np.any(foot_guard[112:]),"foot_silhouette_exact":np.array_equal(a[112:,:,3],before[112:,:,3])}
 # All other guarded artwork is exact, including the organ/neck/root regions outside the edit.
 tests["light_organ_exact"]=not np.any(diff[11:26,92:114]) if key=="wayburn-front" else not np.any(diff[:45])
 if key=="coalcrest-back":
  lamp=np.array(Image.open(D/"masks/coalcrest-back-lamp-source.png"))>0
  ly,lx=np.nonzero(lamp)
  tests["light_organ_exact"]=np.array_equal(a[ly,lx+8],before[ly,lx])
  tests["foot_silhouette_exact"]=np.array_equal(a[128:,94:,3],before[128:,94:,3])
  tests["near_hind_leg_exact"]=np.array_equal(a[90:140,94:125],before[90:140,94:125])
  tests["fin_head_upper_torso_exact"]=np.array_equal(a[:67],before[:67])
  tests["old_left_tail_curl_cleared"]=not np.any(a[80:114,12:21,3])
  tests["leg_tail_negative_space"]=int(np.sum(a[114:121,65:76,3]==0))>=18 and int(np.sum(before[114:121,65:76,3]==0))<10
  if rear.get("far_leg_hidden",False):
   original=np.array(Image.open(D/"sources/coalcrest-back-authored-material.png").convert("RGBA"))
   foot=np.array(Image.open(D/"masks/coalcrest-back-original-far-foot.png"))>0
   tail=np.array(Image.open(D/"masks/coalcrest-back-foreground-tail.png"))>0
   exposed=foot&~tail
   tests["far_leg_hidden_inside_curl"]=not np.any(a[111:123,55:74,3])
   tests["original_far_foot_position"]=not np.any((a[:,:,3]>0)&~(original[:,:,3]>0)&exposed)
   tests["original_far_foot_colors"]=np.array_equal(a[exposed],original[exposed])
   tests["foot_peeks_beneath_tail"]=int(exposed.sum())>=4 and np.any((a[129:138,76:94,3]>0))
   tests["foreground_tail_over_foot"]=bool(np.all(a[tail&foot,3]==255))
  else:
   tests["far_leg_4_connected"]=corridor_path(a,rear["leg_points"]+[rear.get("far_foot_path_end",[77,133])],rear["leg_widths"]+[8])[0]
   underleg=np.array(Image.open(D/"draft/coalcrest-back-leg-before-occlusion.png"))
   tests["continuous_leg_before_occlusion"]=corridor_path(underleg,rear["leg_points"]+[rear.get("far_foot_path_end",[77,133])],rear["leg_widths"]+[8])[0]
   tests["tail_root_right_of_far_leg"]=rear["tail_points"][0][0]>rear["leg_points"][0][0]+10
   tests["far_leg_no_emitter_colors"]=not np.any((a[108:127,55:68,0]>200)&(a[108:127,55:68,1]>120)&(a[108:127,55:68,3]>0))
 tests={key:bool(value) for key,value in tests.items()}
 passed=all(tests.values())
 records.append({"key":key,"tests":tests,"passed":passed,"changed_pixels":int(diff.sum()),"components":c,"tail_path_pixels":pathpixels,"bounds":bounds,"sha256":hashlib.sha256((D/"draft"/(key+"-draft.png")).read_bytes()).hexdigest()})
 for matte,color in [("light",(229,222,207)),("dark",(21,25,29)),("neutral",(65,74,76))]:
  tile=Image.new("RGBA",(w,h),(*color,255));tile.alpha_composite(Image.fromarray(a));tile.resize((w*4,h*4),Image.Resampling.NEAREST).convert("RGB").save(D/"review"/(key+"-matte-"+matte+".png"))
line=Image.new("RGB",(736,1074),(63,71,72));draw=ImageDraw.Draw(line)
for i,name in enumerate(["kithflare","wayburn","coalcrest"]):
 for j,view in enumerate(["front","back"]):
  im=Image.open(D/"draft"/(name+"-"+view+"-draft.png"));tile=im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST)
  line.paste(tile,(j*368,30+i*358),tile);draw.text((j*368+8,8+i*358),name.upper()+" "+view.upper(),fill="white")
line.save(D/"review"/"final-six-view-line.png")
(D/"native-checks.json").write_text(json.dumps({"checks":records,"passed":all(r["passed"] for r in records)},indent=2));print(json.dumps(records,indent=2))
