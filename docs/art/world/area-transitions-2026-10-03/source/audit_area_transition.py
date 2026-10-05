from pathlib import Path
from PIL import Image
import json,hashlib,re
P=Path(r"C:/Users/pmcga/dev/hollowtide"); W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"area-transition-review"
before=json.loads((D/"art-before.json").read_text()); changed=[r for r,h in before.items() if hashlib.sha256((P/r).read_bytes()).hexdigest()!=h]
protected=json.loads((D/"protected-before.json").read_text()); pc=[r for r,h in protected.items() if hashlib.sha256((P/r).read_bytes()).hexdigest()!=h]
quest=[]
old=(D/"before/scripts/first_route_prototype.gd").read_text()
new=(P/"scripts/first_route_prototype.gd").read_text()
def fn(source,name):
    result=re.search(r"(?ms)^func "+re.escape(name)+r"\(.*?(?=^func |\Z)",source)
    assert result,name
    return result.group().rstrip()
for name in ["_visit_dispatch","_visit_marker","_visit_post","_visit_river","_visit_height_post","_offer_report","_record_report","_refresh_objective","_toggle_notes","_toggle_party","_refresh_party","_select_party_member","_refresh_notes","_show_message"]:
    quest.append({"function":name,"exact":fn(old,name)==fn(new,name)})
checks={"existing_art_count":len(before),"existing_art_changed":changed,"protected_changed":pc,"quest_functions":quest,"launch_setting_exact":hashlib.sha256((P/"project.godot").read_bytes()).hexdigest()==json.loads((D/"before-manifest.json").read_text())["project.godot"]}
checks["male"]=json.loads((D/"male-walkthrough.json").read_text())
checks["female"]=json.loads((D/"female-walkthrough.json").read_text())
checks["menu"]=json.loads((D/"menu-entry.json").read_text())
checks["final_log_sizes"]={name:(D/name).stat().st_size for name in ["male-walk.err.log","female-walk.err.log","menu-entry.err.log"]}
assert not changed and not pc and all(q["exact"] for q in quest)
assert checks["launch_setting_exact"] and all(checks[n]["passed"] for n in ["male","female"]) and all(c["new_game_hometown"] for c in checks["menu"])
assert all(v==0 for v in checks["final_log_sizes"].values())
(D/"verification.json").write_text(json.dumps(checks,indent=2))
for name in ["cottonwood_west.png","cottonwood_north.png","cottonwood_bank_bend.png","cottonwood_east.png","cottonwood_office_grove.png","cottonwood_ridge.png"]:
    im=Image.open(P/"assets/sprites/world/route1_rd_2026_10_02"/name);box=im.getbbox()
    print(name,im.size,box,"height",box[3]-box[1])
print("Verified: preserved",len(before),"existing art files,",len(quest),"quest functions; both walks/menu entries; clean runtime logs.")
