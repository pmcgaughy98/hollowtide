from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,hashlib,shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"coalcrest-tail-root-repair"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
if not (D/"baseline.json").exists():
 baseline={}
 for folder in ["assets","data","scripts","scenes"]:
  for p in (P/folder).rglob("*"):
   if p.is_file():baseline[p.relative_to(P).as_posix()]=sha(p)
 baseline["project.godot"]=sha(P/"project.godot");(D/"baseline.json").write_text(json.dumps(baseline,indent=2))
 shutil.copy2(P/"data/creatures/105_coalcrest.tres",D/"105_coalcrest.tres-before.txt")
 for view in ["front","back"]:shutil.copy2(P/"assets/sprites/creatures/kithflare_tail_polish_2026_10_03"/("coalcrest_"+view+".png"),D/("coalcrest-"+view+"-previous.png"))
records=[]
for view in ["front","back"]:
 original=np.array(Image.open(W/"kithflare-tail-review"/("coalcrest-"+view+"-before.png")).convert("RGBA"))
 previous=np.array(Image.open(D/("coalcrest-"+view+"-previous.png")).convert("RGBA"));out=previous.copy()
 root=np.zeros(original.shape[:2],bool)
 root[88:(120 if view=="front" else 132),48:79]=original[88:(120 if view=="front" else 132),48:79,3]>0
 # Recover the authored proximal tail and rump that the rectangular mask erased.
 out[root]=original[root]
 stem=np.zeros(root.shape,bool)
 if view=="front":
  # Two exposed sections of the old thin branch, separated by the foreground leg.
  stem[121:129,75:94]=True
  stem[122:129,104:154]=True
  out[stem]=0
  # Exposed body/leg edges get one native outline pixel, rather than cut brown fill.
  removed=stem&(previous[:,:,3]>0)
  adjacent=np.array(Image.fromarray(removed.astype("uint8")*255).filter(ImageFilter.MaxFilter(3)))>0
  edge=adjacent&~stem&(out[:,:,3]>0)&(out[:,:,0]>65)
  edge[129:]=False
  # Avoid touching the retained far foot and the opaque torso above the branch.
  edge[:120]=False
  out[edge,:3]=[43,27,21]
 # Original sail/head, true foot regions, and banded lamp are separately guarded.
 assert np.array_equal(out[:88],previous[:88])
 if view=="front":assert np.array_equal(out[129:153,60:118],original[129:153,60:118])
 bulb=np.array(Image.open(W/"kithflare-tail-review/original-coalcrest-lantern.png").convert("RGBA"));opaque=bulb[:,:,3]>0
 assert np.array_equal(out[78:109,19:50][opaque],bulb[opaque])
 mask=np.any(out!=previous,axis=2);Image.fromarray(mask.astype("uint8")*255).save(D/("coalcrest-"+view+"-repair-mask.png"))
 Image.fromarray(out).save(D/("coalcrest-"+view+"-root-repaired.png"))
 Image.fromarray(root.astype("uint8")*255).save(D/("coalcrest-"+view+"-original-root-mask.png"))
 if view=="front":Image.fromarray(stem.astype("uint8")*255).save(D/"old-stem-removal-mask.png")
 records.append({"view":view,"original_root_pixels_restored":int(np.any(out[root]!=previous[root],axis=1).sum()),"changed_pixels":int(mask.sum()),"old_visible_stem_pixels_removed":int((stem&(previous[:,:,3]>0)).sum()),"feet_and_fin_and_lamp_guarded":True,"sha256":sha(D/("coalcrest-"+view+"-root-repaired.png"))})
sheet=Image.new("RGB",(360,360),(60,68,69))
for row,view in enumerate(["front","back"]):
 for col,suf in enumerate(["previous","root-repaired"]):
  im=Image.open(D/("coalcrest-"+view+"-"+suf+".png")).convert("RGBA")
  sheet.paste(im,(col*180+8,row*180+16),im)
  ImageDraw.Draw(sheet).text((col*180+5,row*180+2),view.upper()+" "+("PREVIOUS" if col==0 else "ROOT REPAIRED"),fill="white")
sheet.resize((1080,1080),Image.Resampling.NEAREST).save(D/"root-repair-comparison.png")
(D/"draft-audit.json").write_text(json.dumps(records,indent=2));print(json.dumps(records))
