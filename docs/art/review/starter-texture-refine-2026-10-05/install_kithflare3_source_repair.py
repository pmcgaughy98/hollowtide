from pathlib import Path
import json,hashlib,shutil
W=Path(__file__).parent;P=Path("C:/Users/pmcga/dev/hollowtide");a=json.loads((W/"kithflare3-source-repair.json").read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
resource=P/"data/creatures/110_kithflare3.tres";before=resource.read_bytes();text=before.decode("utf-8-sig")
target=P/"assets/sprites/creatures/starter_texture_refine_2026_10_05";assert not target.exists(),"Version folder exists; do not overwrite"
edits={}
for side,e in a["views"].items():
 assert sha(P/e["source_current_path"])==e["source_current_sha256"],("Shared art changed",side)
 assert sha(W/"candidates"/e["candidate_filename"])==e["candidate_sha256"]
 old="res://"+e["source_current_path"];new="res://assets/sprites/creatures/starter_texture_refine_2026_10_05/"+e["candidate_filename"]
 assert text.count(old)==1;edits[old]=new
updated=text
for old,new in edits.items():updated=updated.replace(old,new,1)
reverse=updated
for old,new in edits.items():reverse=reverse.replace(new,old,1)
assert reverse==text
(W/"installation").mkdir(exist_ok=True);(W/"installation/110_kithflare3-before.tres").write_bytes(before)
target.mkdir(parents=True)
for side,e in a["views"].items():shutil.copy2(W/"candidates"/e["candidate_filename"],target/e["candidate_filename"])
assert resource.read_bytes()==before,"Concurrent resource write; art copied but bindings not activated"
resource.write_text(updated,encoding="utf-8")
assert resource.read_text(encoding="utf-8")==updated
record={"date":"2026-10-05","resource":"data/creatures/110_kithflare3.tres","resource_before_sha256":hashlib.sha256(before).hexdigest(),"resource_after_sha256":sha(resource),"only_two_texture_bindings_changed":True,"current_battle_size_evolutions_essences_all_other_fields_preserved":True,"native_height_changed":False,"size_plan_rerun_needed":False,"source_art_overwritten":False,"paid_cost_usd":0,"new_pngs":[{"path":p.relative_to(P).as_posix(),"sha256":sha(p)} for p in sorted(target.glob("*.png"))],"native_runtime_verification":"pending"}
(W/"installation/kithflare3-source-repair-installation.json").write_text(json.dumps(record,indent=2)+"\n");print(json.dumps(record))
