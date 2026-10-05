from pathlib import Path
import shutil,json,hashlib
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"coalcrest-tail-root-repair"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((D/"baseline.json").read_text())
assert all((P/k).exists() and sha(P/k)==v for k,v in baseline.items())
audit=json.loads((D/"pixel-checks.json").read_text());assert audit["passed"]
dest=P/"assets/sprites/creatures/coalcrest_tail_root_repaired_2026_10_03";dest.mkdir(exist_ok=False)
files=[]
for e in audit["checks"]:
 view=e["view"];source=D/("coalcrest-"+view+"-organic-root.png")
 assert sha(source)==e["sha256"]
 target=dest/("coalcrest_"+view+".png");shutil.copy2(source,target);files.append(target.relative_to(P).as_posix())
resource=P/"data/creatures/105_coalcrest.tres"
assert resource.read_bytes()==(D/"105_coalcrest.tres-before.txt").read_bytes()
before=resource.read_text();after=before.replace("kithflare_tail_polish_2026_10_03/coalcrest_","coalcrest_tail_root_repaired_2026_10_03/coalcrest_")
assert before.count("kithflare_tail_polish_2026_10_03/coalcrest_")==2
assert after.replace("coalcrest_tail_root_repaired_2026_10_03/coalcrest_","kithflare_tail_polish_2026_10_03/coalcrest_")==before
resource.write_text(after,encoding="utf-8",newline="\n");files.append(resource.relative_to(P).as_posix())
rt=(W/"kithflare_tail_polish_runtime.gd").read_text().replace("kithflare-tail-polish/runtime/","coalcrest-tail-root-repair/runtime/").replace("TAIL_POLISH_RUNTIME","COALCREST_ROOT_RUNTIME")
rt=rt.replace('    [103,"kithflare","res://assets/sprites/creatures/rd_material_match_2026_10_01/kithflare_front.png"],\n','').replace('    [104,"wayburn","res://assets/sprites/creatures/rd_material_match_2026_10_01/wayburn_front.png"],\n','')
(W/"coalcrest_tail_root_runtime.gd").write_text(rt,encoding="utf-8",newline="\n");(D/"runtime").mkdir(exist_ok=False)
(D/"installed-files.json").write_text(json.dumps(files,indent=2));print(json.dumps({"installed":files,"only_resource_texture_paths_changed":True,"generation_cost":0}))
