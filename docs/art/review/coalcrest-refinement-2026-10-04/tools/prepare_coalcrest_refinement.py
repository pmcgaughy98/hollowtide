from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np,json,hashlib,shutil
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
P=Path(r"C:/Users/pmcga/dev/hollowtide")
D=W/"coalcrest-refinement-2026-10-04";D.mkdir(exist_ok=True)
baseline={}
for root in ["assets","data","scripts","scenes"]:
 for p in (P/root).rglob("*"):
  if p.is_file():baseline[p.relative_to(P).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
baseline["project.godot"]=hashlib.sha256((P/"project.godot").read_bytes()).hexdigest()
if not (D/"baseline.json").exists():(D/"baseline.json").write_text(json.dumps(baseline,indent=2))
shutil.copy2(P/"data/creatures/105_coalcrest.tres",D/"105_coalcrest-before.tres")
for view in ["front","back"]:
 p=P/"assets/sprites/creatures/coalcrest_tail_root_repaired_2026_10_03"/("coalcrest_"+view+".png")
 shutil.copy2(p,D/(view+"-before.png"))
 im=Image.open(p).convert("RGBA")
 bg=Image.new("RGBA",im.size,(102,111,114,255));bg.alpha_composite(im)
 bg.resize((960,960),Image.Resampling.NEAREST).convert("RGB").save(D/(view+"-enlarged-before.png"))
 # Ten-native-pixel coordinate grid over lower anatomy for authored region selection.
 crop=bg.crop((0,65,140,150)).resize((1120,680),Image.Resampling.NEAREST).convert("RGB")
 draw=ImageDraw.Draw(crop)
 for x in range(0,140,10):
  draw.line((x*8,0,x*8,680),fill=(130,137,140));draw.text((x*8+2,2),str(x),fill="white")
 for y in range(70,150,10):
  yy=(y-65)*8;draw.line((0,yy,1120,yy),fill=(130,137,140));draw.text((2,yy+2),str(y),fill="white")
 crop.save(D/(view+"-anatomy-coordinate-guide.png"))
 # Native skin palette counts around feet and root.
 a=np.array(im);r=a[109:143,50:126];c,n=np.unique(r[r[:,:,3]>0,:3],axis=0,return_counts=True);ix=np.argsort(-n)[:25]
 (D/(view+"-palette.json")).write_text(json.dumps([{"rgb":c[i].tolist(),"count":int(n[i])}for i in ix],indent=2))
print(json.dumps({"baseline_files":len(baseline),"output":str(D)}))
