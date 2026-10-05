from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,shutil,numpy as np
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");P=Path(r"C:/Users/pmcga/dev/hollowtide")
D=W/"coalcrest-recheck-2026-10-04";D.mkdir(exist_ok=True)
base={}
for root in ["assets","data","scripts","scenes"]:
 for p in(P/root).rglob("*"):
  if p.is_file():base[p.relative_to(P).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
base["project.godot"]=hashlib.sha256((P/"project.godot").read_bytes()).hexdigest()
if not(D/"baseline.json").exists():(D/"baseline.json").write_text(json.dumps(base,indent=2))
if not(D/"105_coalcrest-before.tres").exists():shutil.copy2(P/"data/creatures/105_coalcrest.tres",D/"105_coalcrest-before.tres")
for view in ["front","back"]:
 p=P/"assets/sprites/creatures/coalcrest_refined_2026_10_04"/("coalcrest_"+view+".png")
 if not(D/(view+"-before.png")).exists():shutil.copy2(p,D/(view+"-before.png"))
 im=Image.open(p).convert("RGBA")
 # Focus on root and both feet without interpolation.
 crop=im.crop((40,100,125,145));bg=Image.new("RGBA",crop.size,(108,118,119,255));bg.alpha_composite(crop)
 big=bg.resize((1020,540),Image.Resampling.NEAREST).convert("RGB");draw=ImageDraw.Draw(big)
 for x in range(40,125,5):
  xx=(x-40)*12;draw.line((xx,0,xx,540),fill=(135,145,146));draw.text((xx+2,2),str(x),fill="white")
 for y in range(100,145,5):
  yy=(y-100)*12;draw.line((0,yy,1020,yy),fill=(135,145,146));draw.text((2,yy+3),str(y),fill="white")
 big.save(D/(view+"-root-feet-grid.png"))
 bg=Image.new("RGBA",(160,160),(108,118,119,255));bg.alpha_composite(im);bg.resize((800,800),Image.Resampling.NEAREST).convert("RGB").save(D/(view+"-before-5x.png"))
print(json.dumps({"existing_files":len(base),"review":str(D)}))
