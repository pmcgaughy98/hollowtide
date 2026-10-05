from pathlib import Path
from PIL import Image
from collections import deque
import numpy as np,hashlib,json,shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");N=W/"kithflare-tail-polish";D=W/"kithflare-tail-review"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((N/"baseline.json").read_text())
changed=[rel for rel,h in baseline.items() if sha(P/rel)!=h]
assert not changed,("Concurrent files changed before install",changed)
def components(occ):
 remain=set((int(x),int(y)) for y,x in np.argwhere(occ));result=[]
 while remain:
  seed=next(iter(remain));seen={seed};remain.remove(seed);todo=[seed]
  while todo:
   x,y=todo.pop()
   for dx in [-1,0,1]:
    for dy in [-1,0,1]:
     v=(x+dx,y+dy)
     if v in remain:remain.remove(v);seen.add(v);todo.append(v)
  result.append(seen)
 return result
points={("kithflare","front"):((59,48),(92,90)),("kithflare","back"):((58,60),(90,87)),("wayburn","front"):((103,20),(118,70)),("wayburn","back"):((25,37),(88,91)),("coalcrest","front"):((35,91),(86,90)),("coalcrest","back"):((35,91),(87,90))}
checks=[]
ledger=json.loads((D/"source-ledger.json").read_text())
for entry in ledger:
 name,view=entry["name"],entry["view"];key=(name,view)
 original=np.array(Image.open(D/(name+"-"+view+"-before.png")).convert("RGBA"))
 previous=np.array(Image.open(N/(name+"-"+view+"-previous.png")).convert("RGBA"))
 final=np.array(Image.open(N/(name+"-"+view+"-polished.png")).convert("RGBA"))
 mask=np.array(Image.open(N/(name+"-"+view+"-mask.png")).convert("L"))>0
 assert original.shape==final.shape and np.array_equal(original[~mask],final[~mask])
 assert set(np.unique(final[:,:,3]))<={0,255}
 assert sha(P/entry["source"])==entry["sha256"]
 occ=final[:,:,3]>0;lamp,body=points[key];assert occ[lamp[1],lamp[0]] and occ[body[1],body[0]]
 seen={lamp};todo=deque([lamp])
 while todo:
  x,y=todo.popleft()
  for xx,yy in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
   v=(xx,yy)
   if 0<=yy<occ.shape[0] and 0<=xx<occ.shape[1] and occ[yy,xx] and v not in seen:seen.add(v);todo.append(v)
 assert body in seen,key
 connected=len(components(occ));old_connected=len(components(original[:,:,3]>0));prior_connected=len(components(previous[:,:,3]>0))
 assert connected<=max(old_connected,prior_connected),("new disconnected fragments",key,connected)
 if name=="coalcrest":
  bulb=np.array(Image.open(D/"original-coalcrest-lantern.png").convert("RGBA"));bm=bulb[:,:,3]>0
  assert np.array_equal(final[78:109,19:50][bm],bulb[bm])
  if view=="front":
   assert np.array_equal(final[129:153,60:118],original[129:153,60:118])
   fm=original[:103,45:112,3]>0
   assert np.array_equal(final[:103,45:112][fm],original[:103,45:112][fm])
   assert np.array_equal(final[:66],original[:66])
  else:assert Image.fromarray(final).getbbox()[3]==Image.fromarray(original).getbbox()[3]
 else:
  rect={"kithflare":(49,43,69,59) if view=="front" else (48,53,69,72),"wayburn":(92,11,114,27) if view=="front" else (17,28,33,42)}[name]
  x,y,x2,y2=rect;assert np.array_equal(final[y:y2,x:x2],original[y:y2,x:x2])
 checks.append({"name":name,"view":view,"four_neighbor_lantern_body_connection":True,"exact_original_lamp_pixels":True,"exact_rgba_outside_tail_mask":True,"native_canvas_and_binary_alpha":True,"original_completed_fin_exact":True if key==("coalcrest","front") else None,"front_foot_exact":True if key==("coalcrest","front") else None,"sprite_8_neighbor_components":connected,"original_components":old_connected,"changed_pixels_from_previous":int(np.any(final!=previous,axis=2).sum())})
(N/"pixel-checks.json").write_text(json.dumps({"checks":checks,"passed":True},indent=2))
dest=P/"assets/sprites/creatures/kithflare_tail_polish_2026_10_03";dest.mkdir(parents=True,exist_ok=False)
files=[]
for e in ledger:
 name,view=e["name"],e["view"];rel=dest.relative_to(P).as_posix()+"/"+name+"_"+view+".png"
 shutil.copy2(N/(name+"-"+view+"-polished.png"),P/rel);files.append(rel)
for id,name in [(103,"kithflare"),(104,"wayburn"),(105,"coalcrest")]:
 rel="data/creatures/%03d_%s.tres"%(id,name);resource=P/rel
 assert resource.read_bytes()==(N/(resource.name+"-before.txt")).read_bytes()
 before=resource.read_text();after=before.replace("kithflare_tail_attached_2026_10_03/","kithflare_tail_polish_2026_10_03/")
 assert after!=before
 resource.write_text(after,encoding="utf-8",newline="\n");files.append(rel)
(N/"installed-files.json").write_text(json.dumps(files,indent=2))
rt=(W/"kithflare_tail_runtime.gd").read_text().replace("kithflare-tail-review/runtime/","kithflare-tail-polish/runtime/")
rt=rt.replace("TAIL_CONNECTION_RUNTIME","TAIL_POLISH_RUNTIME")
(W/"kithflare_tail_polish_runtime.gd").write_text(rt,encoding="utf-8",newline="\n");(N/"runtime").mkdir(exist_ok=False)
print(json.dumps({"native_checks":6,"changed_views":5,"wayburn_front_inspected_retained":True,"new_pngs":6,"texture_reference_resources":3,"paid_generation_cost":0,"protected_baseline_files":len(baseline)}))
