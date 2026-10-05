from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,shutil,collections
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
P=Path(r"C:/Users/pmcga/dev/hollowtide");D=W/"coalcrest-refinement-2026-10-04"
def rgba(p):return np.array(Image.open(p).convert("RGBA"))
def component(a,start):
 y,x=start
 if not a[y,x]:return set()
 seen={(y,x)};q=collections.deque(seen)
 while q:
  y,x=q.popleft()
  for dy,dx in [(0,1),(1,0),(-1,0),(0,-1)]:
   yy,xx=y+dy,x+dx
   if 0<=yy<160 and 0<=xx<160 and a[yy,xx] and (yy,xx)not in seen:seen.add((yy,xx));q.append((yy,xx))
 return seen
records=[]
for view in ["front","back"]:
 before=rgba(D/(view+"-before.png"));a=rgba(D/("coalcrest_"+view+"-draft.png"));mask=np.array(Image.open(D/(view+"-authorized-regions.png")))>0
 diff=np.any(a!=before,2);opaque=a[:,:,3]>0
 full=component(opaque,(95,32))
 # Actual pixels on the raised curl, organ, root and both feet must connect.
 probes=[(93,32),(75,25),(98,15),(113,18)]
 if view=="front":probes +=[(128,34),(124,45),(131,63),(133,98)]
 else:probes +=[(132,40),(130,52),(121,64),(131,75),(133,106)]
 probe_ok=all(p in full for p in probes)
 # No detached opaque fragments anywhere within the edited regions.
 isolated=[(int(y),int(x))for y,x in np.argwhere(opaque&mask)if(y,x)not in full]
 # Fin, head, throat and upper body retain exact RGBA from the baseline.
 protected=np.zeros((160,160),bool);protected[:65]=True
 if view=="front":protected[:103,51:130]=True
 else:protected[:97,66:126]=True
 fixed_exact=not np.any(diff&protected)
 old_stem=True
 if view=="front":old_stem=not np.any(opaque[122:129,118:154])
 flare=not np.any((a[102:122,57:65,0]>195)&(a[102:122,57:65,1]>115)&(a[102:122,57:65,3]>0)) if view=="back"else True
 # The widths are authored monotonically tapering, not inferred from the pixel diff.
 free=np.zeros((160,160),bool);free[113:144,7:57]=True
 old_count=int(((before[:,:,3]>0)&free).sum());new_count=int((opaque&free).sum())
 checks={"size_160":a.shape==(160,160,4),"binary_alpha":set(np.unique(a[:,:,3])).issubset({0,255}),"changes_within_predeclared_regions":not np.any(diff&~mask),"fin_head_upper_body_exact":fixed_exact,"tail_lamp_root_feet_connected":probe_ok,"no_detached_edited_pixels":not isolated,"old_front_stem_absent":old_stem,"rear_leg_emitter_removed":flare,"canvas_margin":not(np.any(opaque[0])or np.any(opaque[-1])or np.any(opaque[:,0])or np.any(opaque[:,-1]))}
 records.append({"view":view,"checks":checks,"passed":all(checks.values()),"changed_pixels":int(diff.sum()),"isolated_pixels":isolated,"free_lower_curl_before_pixels":old_count,"free_lower_curl_after_pixels":new_count,"hash":hashlib.sha256((D/("coalcrest_"+view+"-draft.png")).read_bytes()).hexdigest()})
(D/"native-qa.json").write_text(json.dumps(records,indent=2))
print(json.dumps(records))
assert all(r["passed"]for r in records)
# Versioned installation: touch only the subject's two references, retaining prior versions.
F=P/"assets/sprites/creatures/coalcrest_refined_2026_10_04";F.mkdir(exist_ok=True)
for view in ["front","back"]:shutil.copy2(D/("coalcrest_"+view+"-draft.png"),F/("coalcrest_"+view+".png"))
rp=P/"data/creatures/105_coalcrest.tres";s=rp.read_text();old=(D/"105_coalcrest-before.tres").read_text()
assert s in [old,old.replace("coalcrest_tail_root_repaired_2026_10_03/","coalcrest_refined_2026_10_04/")],"Concurrent resource change; stop before replacement."
s=s.replace("coalcrest_tail_root_repaired_2026_10_03/","coalcrest_refined_2026_10_04/")
assert s.count("coalcrest_refined_2026_10_04/")==2
rp.write_text(s)
fixture=(W/"coalcrest_tail_root_runtime.gd").read_text().replace("coalcrest-tail-root-repair/runtime-final/","coalcrest-refinement-2026-10-04/runtime-final/").replace("COALCREST_ROOT_RUNTIME","COALCREST_REFINEMENT_RUNTIME")
(D/"runtime-final").mkdir(exist_ok=True)
(W/"coalcrest_refinement_runtime.gd").write_text(fixture)
# Review showing complete sprites on a neutral field at exact 3x nearest scale.
sheet=Image.new("RGB",(1000,520),(95,105,108));dr=ImageDraw.Draw(sheet)
for i,view in enumerate(["front","back"]):
 im=Image.open(F/("coalcrest_"+view+".png")).convert("RGBA").resize((480,480),Image.Resampling.NEAREST)
 sheet.paste(im,(10+i*500,30),im);dr.text((20+i*500,12),view.upper()+" - refined",fill="white")
sheet.save(D/"coalcrest-refined-review.png")
