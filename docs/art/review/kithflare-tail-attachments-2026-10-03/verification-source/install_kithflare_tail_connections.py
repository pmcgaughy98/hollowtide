from pathlib import Path
from PIL import Image
from collections import deque
import json,numpy as np,hashlib,shutil,re
P=Path(r"C:/Users/pmcga/dev/hollowtide")
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"kithflare-tail-review"
dest=P/"assets/sprites/creatures/kithflare_tail_attached_2026_10_03"
checks=[]
points={("kithflare","front"):((59,48),(92,90)),("kithflare","back"):((58,60),(90,87)),("wayburn","front"):((103,20),(118,70)),("wayburn","back"):((25,37),(88,91)),("coalcrest","front"):((35,91),(86,90)),("coalcrest","back"):((35,91),(87,90))}
for record in json.loads((D/"source-ledger.json").read_text()):
 name,view=record["name"],record["view"]
 candidate=D/(name+"-"+view+"-tail-connected.png")
 before=np.array(Image.open(D/(name+"-"+view+"-before.png")).convert("RGBA"))
 after=np.array(Image.open(candidate).convert("RGBA"))
 allowed=np.array(Image.open(D/(name+"-"+view+"-final-mask.png")).convert("L"))>0
 assert before.shape==after.shape and np.array_equal(before[~allowed],after[~allowed])
 occ=after[:,:,3]>0;lamp,body=points[name,view]
 # Pick occupied points nearest the intended landmarks, then require one 4-neighbor component.
 ys,xs=np.nonzero(occ)
 def seed(point):
  n=((xs-point[0])**2+(ys-point[1])**2).argmin()
  return int(xs[n]),int(ys[n])
 a=seed(lamp);b=seed(body);visited={a};q=deque([a])
 while q:
  x,y=q.popleft()
  for xx,yy in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
   if 0<=yy<occ.shape[0] and 0<=xx<occ.shape[1] and occ[yy,xx] and (xx,yy) not in visited:
    visited.add((xx,yy));q.append((xx,yy))
 connected=b in visited
 assert connected,(name,view,a,b)
 if name=="coalcrest":
  assert np.array_equal(after[:66],before[:66])
  original=np.array(Image.open(D/"original-coalcrest-lantern.png").convert("RGBA"))
  glow=original[:,:,3]>0
  assert np.array_equal(after[78:109,19:50][glow],original[glow])
 else:
  rect={"kithflare":(49,43,69,59) if view=="front" else (48,53,69,72),"wayburn":(92,11,114,27) if view=="front" else (17,28,33,42)}[name]
  x,y,x2,y2=rect;assert np.array_equal(after[y:y2,x:x2],before[y:y2,x:x2])
 checks.append({"name":name,"view":view,"lamp_body_4_neighbor_connected":connected,"lamp_seed":list(a),"body_seed":list(b),"outside_tail_mask_exact":True,"lamp_pixels_exact":True,"native_canvas_preserved":True,"bounds":Image.fromarray(after).getbbox(),"visible_changed_pixels":int((np.any(after!=before,axis=2)&((after[:,:,3]>0)|(before[:,:,3]>0))).sum())})
(D/"connection-pixel-checks.json").write_text(json.dumps({"checks":checks,"passed":True},indent=2))
# Source/hash guards protect concurrent edits and all six original approved sprites.
ledger=json.loads((D/"source-ledger.json").read_text())
for entry in ledger:assert hashlib.sha256((P/entry["source"]).read_bytes()).hexdigest()==entry["sha256"],entry["source"]
for id,name in [(103,"kithflare"),(104,"wayburn"),(105,"coalcrest")]:
 resource=P/("data/creatures/%03d_%s.tres"%(id,name))
 assert resource.read_bytes()==(D/(resource.name+"-before.txt")).read_bytes()
dest.mkdir(parents=True,exist_ok=False)
for entry in ledger:
 name,view=entry["name"],entry["view"]
 target=dest/(name+"_"+view+".png")
 shutil.copy2(D/(name+"-"+view+"-tail-connected.png"),target)
for id,name in [(103,"kithflare"),(104,"wayburn"),(105,"coalcrest")]:
 resource=P/("data/creatures/%03d_%s.tres"%(id,name))
 text=resource.read_text()
 for entry in ledger:
  if entry["name"]==name:
   new="assets/sprites/creatures/kithflare_tail_attached_2026_10_03/"+name+"_"+entry["view"]+".png"
   text=text.replace('res://'+entry["source"],'res://'+new)
 resource.write_text(text,encoding="utf-8",newline="\n")
print(json.dumps({"six_connections_verified":len(checks),"files_installed":6,"resources_updated":3,"passed":True}))
