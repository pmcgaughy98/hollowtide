from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib,re
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"historic-frontage-2026-10-04"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((D/"baseline.json").read_text())
changed=[x for x,h in baseline.items() if not (P/x).exists() or sha(P/x)!=h]
new=[]
for folder in ["assets","data","scripts","scenes"]:
 for p in (P/folder).rglob("*"):
  if p.is_file() and p.relative_to(P).as_posix() not in baseline:new.append(p.relative_to(P).as_posix())
expected=["scripts/historic_street.gd"]
assert changed==expected or sorted(changed)==expected, changed
def functions(s):
 result={};name=None;lines=[]
 for line in s.splitlines():
  if line.startswith("func "):
   if name:result[name]="\n".join(lines).rstrip()
   name=line[5:].split("(",1)[0];lines=[]
  if name and not line.startswith("#"):lines.append(line)
 if name:result[name]="\n".join(lines).rstrip()
 return result
old=(D/"before/scripts/historic_street.gd").read_text();cur=(P/"scripts/historic_street.gd").read_text()
a=functions(old);b=functions(cur)
guarded=["visit_board","visit_shop","visit_ledger","offer_handoff_if_requested","_record_handoff","_update_board","objective_text","board_summary","notes_text","_process","_open_journey"]
checks={x:a[x].rstrip()==b[x].rstrip() for x in guarded}
assert all(checks.values()),checks
assets=[]
for original,name in [("repair_workshop_v2","repair_workshop"),("rear_rowhomes_v2","rear_rowhomes"),("workshop_keeper","workshop_keeper")]:
 src=Image.open(D/(original+"-original.png")).convert("RGBA");crop=src.crop(src.getbbox())
 target=P/"assets/sprites/world/historic_frontage_2026_10_04"/(name+".png")
 im=Image.open(target);ar=np.array(im)
 same=np.array_equal(np.array(crop),ar[12:12+crop.height,12:12+crop.width])
 margin=bool(np.all(ar[:12,:,3]==0) and np.all(ar[-12:,:,3]==0) and np.all(ar[:,:12,3]==0) and np.all(ar[:,-12:,3]==0))
 assert same and margin and np.unique(ar[:,:,3]).tolist()==[0,255]
 assets.append({"name":name,"source_pixels_exact":same,"transparent_padding_12px":margin,"alpha_binary":True,"native_size":im.size,"displayed_visible_height":crop.height*(0.5 if name=="workshop_keeper" else 0.75 if name=="repair_workshop" else 0.85)})
record={"existing_count":len(baseline),"existing_exact":len(baseline)-len(changed),"changed_existing":changed,"new_runtime":sorted(new),"original_activity_functions_exact":checks,"native_assets":assets,"original_launch_exact":sha(P/"project.godot")==baseline["project.godot"],"all_creature_runtime_exact":all(sha(P/x)==h for x,h in baseline.items() if x.startswith("data/creatures/") or x.startswith("assets/sprites/creatures/"))}
(D/"preservation-audit.json").write_text(json.dumps(record,indent=2))
print(json.dumps(record,indent=2))
