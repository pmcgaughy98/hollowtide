from pathlib import Path
import json,hashlib,shutil
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");P=Path(r"C:/Users/pmcga/dev/hollowtide");D=W/"hometown-neighborhood-2026-10-04"
rel="assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader";p=P/rel
baseline=json.loads((D/"baseline.json").read_text());assert hashlib.sha256(p.read_bytes()).hexdigest()==baseline[rel],"Concurrent shader edit"
target=D/"before"/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,target)
s=p.read_text();a=s.index("float hash(");b=s.index("float patch(",a)
candidate=(D/"grass_surface_candidate.gdshader").read_text();c=candidate[candidate.index("float hash("):candidate.index("float patch(")]
final=s[:a]+c+s[b:]
assert final[final.index("float patch("):]==s[b:],"Only noise corner hash changes"
p.write_text(final,encoding="utf-8",newline="\n")
(D/"installed-grass-shader.gdshader").write_text(final)
print(json.dumps({"changed":rel,"only_hash_function_changed":True,"new_art":0,"rd_cost":0}))
