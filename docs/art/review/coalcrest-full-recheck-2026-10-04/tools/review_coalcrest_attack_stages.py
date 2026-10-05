from pathlib import Path
from PIL import Image,ImageDraw
import json
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"coalcrest-recheck-2026-10-04";F=D/"runtime-final"
check=json.loads((F/"runtime-checks.json").read_text());assert check["passed"]
assert not(F/"stderr.txt").read_text().strip()
S=D/"animation-review";S.mkdir(exist_ok=True)
inventory=[]
for view in ["front","back"]:
 for move in ["crest_signal","furnace_bolt","longfire_burst"]:
  files=sorted(F.glob("coalcrest-"+view+"-"+move+"-phase-*.png"))
  sheet=Image.new("RGB",(1140,810),(90,101,104));draw=ImageDraw.Draw(sheet)
  for i,p in enumerate(files):
   im=Image.open(p).convert("RGB")
   crop=im.crop((645,10,1025,390)if view=="front"else(80,190,460,570))
   x=(i%3)*380;y=(i//3)*405+25
   sheet.paste(crop,(x,y));draw.text((x+8,y-18),p.stem.split("-phase-")[1]+" / "+view+" / "+move,fill="white")
  out=S/(view+"-"+move+"-stages.png");sheet.save(out)
  inventory.append({"view":view,"move":move,"sampled_screens":len(files),"sheet":out.name})
(S/"inventory.json").write_text(json.dumps(inventory,indent=2))
print(json.dumps({"passed":check["passed"],"total_sampled_screens":sum(x["sampled_screens"]for x in inventory),"sheets":inventory}))
