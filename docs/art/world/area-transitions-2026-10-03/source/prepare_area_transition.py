from pathlib import Path
import hashlib,json,shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide")
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"area-transition-review"; D.mkdir(exist_ok=True)
paths=["scripts/main_menu.gd","scripts/first_route_prototype.gd","scripts/route1_crossing.gd","scripts/route1_landscape.gd","scripts/route1_map_polish.gd","scenes/first_route_prototype.tscn","project.godot","docs/AI_COLLABORATION.md"]
manifest={}
for rel in paths:
    src=P/rel; dest=D/"before"/rel; dest.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(src,dest)
    manifest[rel]=hashlib.sha256(src.read_bytes()).hexdigest()
(D/"before-manifest.json").write_text(json.dumps(manifest,indent=2))
art={str(f.relative_to(P)).replace("\\","/"):hashlib.sha256(f.read_bytes()).hexdigest() for folder in ["assets/sprites","assets/tilesets"] for f in (P/folder).rglob("*") if f.is_file() and f.suffix in [".png",".tres",".gdshader"]}
(D/"art-before.json").write_text(json.dumps(art,indent=2))
protected=["scripts/player.gd","scripts/player_party.gd","scripts/battle_screen.gd"]
protected += [str(f.relative_to(P)).replace("\\","/") for f in (P/"resources").rglob("*.tres")]
(D/"protected-before.json").write_text(json.dumps({r:hashlib.sha256((P/r).read_bytes()).hexdigest() for r in protected if (P/r).exists()},indent=2))
print("Snapshotted",len(manifest),"edited/shared files and",len(art),"existing art files")
