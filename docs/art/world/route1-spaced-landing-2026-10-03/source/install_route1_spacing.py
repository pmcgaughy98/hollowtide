from pathlib import Path
import json,hashlib,shutil
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");P=Path(r"C:/Users/pmcga/dev/hollowtide");D=W/"route1-spaced-landing-review"
guard=json.loads((D/"before-manifest.json").read_text())
rels=["scripts/first_route_prototype.gd","scripts/route1_landing_loop.gd","scripts/route1_crossing.gd","scripts/route1_landscape.gd","scenes/first_route_prototype.tscn"]
for rel in rels:
    assert hashlib.sha256((P/rel).read_bytes()).hexdigest()==guard[rel],rel+" concurrently changed"
    assert (D/"candidate"/Path(rel).name).exists()
assert (D/"bake.err.log").stat().st_size==0
assert json.loads((D/"candidate-bake-results.json").read_text())["error"]==0
dest=P/"assets/sprites/world/route1_spaced_landing_2026_10_03/landing_south_loop.png";dest.parent.mkdir(parents=True,exist_ok=True)
assert not dest.exists()
shutil.copy2(D/"landing_south_loop.png",dest)
for rel in rels:(P/rel).write_bytes((D/"candidate"/Path(rel).name).read_bytes())
(D/"installed-files.json").write_text(json.dumps(rels+[dest.relative_to(P).as_posix()],indent=2))
print("Installed focused Route 1 stop spacing, native-material southern loop and cached-return canopy correction.")
