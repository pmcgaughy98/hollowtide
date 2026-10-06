from pathlib import Path
from PIL import Image
import hashlib,json
W=Path(__file__).parent;A=json.loads((W/"source-audit.json").read_text());D=json.loads((W/"kithflare3-source-grid-diagnostic.json").read_text());R=json.loads((W/"kithflare3-source-repair.json").read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
out=W/"rebuilt-source-grid";out.mkdir(exist_ok=True);checks=[]
for side in ["front","back"]:
 donor=W/"inputs"/("kithflare3_full_size_"+side+".png");old=W/"inputs"/("110_kithflare3_"+side+".png")
 assert sha(donor)==D[side]["original_sha256"];assert sha(old)==A["lines"]["kithflare"][2]["views"][side]["sha256"]
 src=Image.open(donor).convert("RGBA");cur=Image.open(old).convert("RGBA");im=src.resize(cur.size,Image.Resampling.NEAREST);assert im.getchannel("A").tobytes()==cur.getchannel("A").tobytes()
 for y in range(im.height):
  for x in range(im.width):
   c=cur.getpixel((x,y))
   if c[3]==0:im.putpixel((x,y),c)
 p=out/R["views"][side]["candidate_filename"];im.save(p);assert sha(p)==R["views"][side]["candidate_sha256"]
 checks.append({"view":side,"byte_exact_rebuild":True,"sha256":sha(p)})
(out/"verification.json").write_text(json.dumps(checks,indent=2)+"\n");print(json.dumps(checks))
