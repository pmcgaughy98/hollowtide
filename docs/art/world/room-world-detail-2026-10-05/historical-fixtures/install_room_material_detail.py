from pathlib import Path
import shutil,json,hashlib
W=Path(__file__).resolve().parent;P=Path("C:/Users/pmcga/dev/hollowtide")
D=W/"room-coalcrest-detail-2026-10-05";R=W/"home-interior-linework-2026-10-04"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
script=P/"scripts/courtyard_home_room.gd";old=script.read_bytes()
installed=json.loads((R/"installation.json").read_text(encoding="utf-8"))
assert sha(script)==installed["files"]["scripts/courtyard_home_room.gd"],"Concurrent room script change"
before=D/"before";before.mkdir(exist_ok=True)
(before/"courtyard_home_room.gd").write_bytes(old)
baseline={}
for folder in ("assets","data","scripts","scenes"):
 for path in (P/folder).rglob("*"):
  if path.is_file():baseline[path.relative_to(P).as_posix()]=sha(path)
baseline["project.godot"]=sha(P/"project.godot")
(D/"room-installation-baseline.json").write_text(json.dumps(baseline,indent=2)+"\n",encoding="utf-8")
directory="assets/sprites/world/courtyard_home_detail_2026_10_05/"
names=["home_room","home_stove_front","home_coat_front","home_threshold_front"]
new=old
for name in names:
 a=("res://assets/sprites/world/courtyard_home_linework_2026_10_04/"+name+".png").encode()
 b=("res://"+directory+name+".png").encode()
 assert new.count(a)==1
 new=new.replace(a,b)
 assert not (P/directory/(name+".png")).exists()
(P/directory).mkdir(parents=True,exist_ok=True)
for name in names:shutil.copy2(D/"prepared"/(name+".png"),P/directory/(name+".png"))
script.write_bytes(new)
record={"date":"2026-10-05","baseline_files":len(baseline),"existing_room_script_texture_paths_only":True,"files":{"scripts/courtyard_home_room.gd":sha(script),**{directory+n+".png":sha(P/directory/(n+".png")) for n in names}}}
(D/"room-installation.json").write_text(json.dumps(record,indent=2)+"\n",encoding="utf-8")
(D/"proof/walk").mkdir(parents=True,exist_ok=True);(D/"proof/overview").mkdir(parents=True,exist_ok=True)
for source,target in [("sharper_home_walk.gd","detail_home_walk.gd"),("sharper_world_overview.gd","detail_world_overview.gd")]:
 s=(W/source).read_text(encoding="utf-8")
 s=s.replace("home-interior-linework-2026-10-04/proof/","room-coalcrest-detail-2026-10-05/proof/")
 s=s.replace("assets/sprites/world/courtyard_home_linework_2026_10_04/","assets/sprites/world/courtyard_home_detail_2026_10_05/")
 (W/target).write_text(s,encoding="utf-8")
print(json.dumps(record))
