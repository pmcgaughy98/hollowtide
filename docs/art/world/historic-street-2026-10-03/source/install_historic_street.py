from pathlib import Path
from PIL import Image,ImageFilter
import numpy as np,json,hashlib,shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"historic-street-review"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline={}
for folder in ["assets","data","scripts","scenes"]:
 for p in (P/folder).rglob("*"):
  if p.is_file():baseline[p.relative_to(P).as_posix()]=sha(p)
baseline["project.godot"]=sha(P/"project.godot")
assert not (D/"baseline.json").exists()
(D/"baseline.json").write_text(json.dumps(baseline,indent=2))
for rel in ["scripts/world_journey.gd","scripts/area_landscape.gd","scripts/first_route_prototype.gd"]:shutil.copy2(P/rel,D/(Path(rel).name+".before"))
atlas=np.array(Image.open(P/"assets/tilesets/route1_rd_2026_10_01/route1_ground_atlas_polished.png").convert("RGBA"))
soil=atlas[:16,176:192];pavers=np.array(Image.open(W/"historic-riverfront-review/historic_pavers_tile_source.png").convert("RGBA"))
def stroke(shape,points,half):
 yy,xx=np.mgrid[:shape[0],:shape[1]];best=np.full(shape,1e9)
 for a,b in zip(points,points[1:]):
  vx,vy=b[0]-a[0],b[1]-a[1];t=np.clip(((xx-a[0])*vx+(yy-a[1])*vy)/max(vx*vx+vy*vy,.001),0,1)
  best=np.minimum(best,(xx-a[0]-t*vx)**2+(yy-a[1]-t*vy)**2)
 return best<half*half
shape=(896,768);yy,xx=np.mgrid[:896,:768]
mask=stroke(shape,[(384,896),(384,540)],34)
mask|=stroke(shape,[(80,480),(688,480)],40)
for x in [224,544]:mask|=stroke(shape,[(x,394),(x,480)],30)
mask|=stroke(shape,[(224,480),(168,568),(184,664),(304,728),(464,728),(584,664),(600,568),(544,480)],18)
mask|=((xx-384)/120)**2+((yy-620)/68)**2<1
street=np.zeros((896,768,4),np.uint8);street[mask]=pavers[yy[mask]%48,xx[mask]%48];street[mask,3]=255
# Native worn stone curbs, two pixels, following the authored street boundary.
inner=np.array(Image.fromarray(mask.astype("uint8")*255).filter(ImageFilter.MinFilter(5)))>0
curb=mask&~inner;street[curb,:3]=(91,80,64)
Image.fromarray(street).save(D/"street_pavers.png")
shape=(768,1024);yy,xx=np.mgrid[:768,:1024]
mask=stroke(shape,[(816,512),(864,512),(880,496),(880,0)],16)
approach=np.zeros((768,1024,4),np.uint8);approach[mask]=soil[yy[mask]%16,xx[mask]%16];approach[mask,3]=255
Image.fromarray(approach).save(D/"riverfront_north_lane.png")
dest=P/"assets/sprites/world/historic_street_2026_10_03";dest.mkdir(parents=True,exist_ok=False)
for name in ["street_pavers.png","riverfront_north_lane.png"]:shutil.copy2(D/name,dest/name)
# Retain the prepared local activity, adapting its ownership to a cached area.
old=(W/"historic_riverfront.candidate.gd").read_text()
methods=old[old.index("func visit_board()"):old.index("func _ellipse(")]
methods=methods.replace("func visit_shop() -> void:\n","func visit_shop() -> void:\n\tstarted = true\n").replace("func visit_ledger() -> void:\n","func visit_ledger() -> void:\n\tstarted = true\n")
methods=methods.replace("The historic street is north along the marked lane.","Take the northern marked lane into the historic street.")
methods=methods.replace('if handoff_verified: return "CITY HANDOFF COMPLETE','if not started: return "HISTORIC STREET  /  Read the street courier board"\n\tif handoff_verified: return "CITY HANDOFF COMPLETE')
header=(W/"historic_street.header.gd").read_text().replace("    ","\t")
script=header+"\n"+methods
(P/"scripts/historic_street.gd").write_text(script,encoding="utf-8",newline="\n")
scene='''[gd_scene load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/historic_street.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/player.tscn" id="2"]
[node name="HistoricStreet" type="Node2D"]
y_sort_enabled = true
script = ExtResource("1")
[node name="RouteDecor" type="Node2D" parent="."]
y_sort_enabled = true
[node name="Player" parent="." instance=ExtResource("2")]
position = Vector2(384,848)
'''
(P/"scenes/historic_street.tscn").write_text(scene,encoding="utf-8",newline="\n")
p=P/"scripts/world_journey.gd";s=p.read_text()
s=s.replace('"riverfront": preload("res://scenes/city_riverfront.tscn"),','"riverfront": preload("res://scenes/city_riverfront.tscn"),\n    "historic_street": preload("res://scenes/historic_street.tscn"),')
s=s.replace('"courier_hall") var initial_area','"courier_hall", "historic_street") var initial_area')
s=s.replace('"riverfront":Vector2(320,512)}[initial_area]','"riverfront":Vector2(320,512),"historic_street":Vector2(384,848)}[initial_area]')
s=s.replace('    route.set("player", courier)','    route.set("player", courier)\n    if id == "historic_street":\n        route.set("city_activity",area)')
s=s.replace('        "riverfront":\n            _gate', '        "historic_street":\n            _gate(entrances, "RiverfrontReturn", Vector2(384,888), Vector2(56,16), "riverfront", Vector2(880,48), Vector2.DOWN)\n        "riverfront":\n            _gate(entrances, "HistoricStreetEntrance", Vector2(880,8), Vector2(40,16), "historic_street", Vector2(384,848), Vector2.UP)\n            _gate')
s=s.replace('"riverfront":"CITY / RIVERFRONT"}[active_id]','"riverfront":"CITY / RIVERFRONT", "historic_street":"CITY / HISTORIC STREET"}[active_id]\n    if active_id == "historic_street" or (active_id == "riverfront" and cached.has("historic_street") and cached["historic_street"].started):\n        route.get("_objective").text = cached["historic_street"].call("objective_text")')
s=s.replace('        active_area.call("interact", route)','        var site: String = active_area.call("nearest_site")\n        active_area.call("interact", route)\n        if active_id == "riverfront" and site == "city_clerk" and cached.has("historic_street"):\n            cached["historic_street"].call("offer_handoff_if_requested")')
p.write_text(s,encoding="utf-8",newline="\n")
p=P/"scripts/area_landscape.gd";s=p.read_text()
s=s.replace('const CITY_ROAD =','const HISTORIC_LANE = preload("res://assets/sprites/world/historic_street_2026_10_03/riverfront_north_lane.png")\nconst CITY_ROAD =')
s=s.replace('    _wall("North",Vector2(512,-8),Vector2(1024,16))','    if area_id == "hometown":\n        _wall("North",Vector2(512,-8),Vector2(1024,16))\n    else:\n        _wall("NorthWest",Vector2(428,-8),Vector2(856,16))\n        _wall("NorthEast",Vector2(964,-8),Vector2(120,16))\n        _surface("HistoricStreetLane",HISTORIC_LANE,Vector2.ZERO,-6)')
s=s.replace('func _build_city() -> void:\n','func _build_city() -> void:\n    _prop("HistoricStreetWaymark",MARK,Vector2(912,88),0.6)\n    _label("OLD CITY ^",Vector2(866,54))\n')
p.write_text(s,encoding="utf-8",newline="\n")
p=P/"scripts/first_route_prototype.gd";s=p.read_text()
s=s.replace('func _refresh_notes() -> void:','func _refresh_notes() -> void:')
s=s.replace('func _refresh_objective() -> void:', 'var city_activity: Node2D\n\nfunc _refresh_objective() -> void:')
s=s.replace('\t_notes_body.text = notes','\tif is_instance_valid(city_activity):\n\t\tnotes += city_activity.call("notes_text")\n\t_notes_body.text = notes')
s=s.replace('The historic, works, school and trade quarters will each have their own entrances as they are built.','The marked northern lane reaches the historic street, with its repaired shop, public ledger and courier board. The works, school and trade quarters will have separate entrances as they are built.')
p.write_text(s,encoding="utf-8",newline="\n")
manifest={"new_runtime":["scripts/historic_street.gd","scenes/historic_street.tscn","assets/sprites/world/historic_street_2026_10_03/street_pavers.png","assets/sprites/world/historic_street_2026_10_03/riverfront_north_lane.png"],"existing_changes":["scripts/world_journey.gd","scripts/area_landscape.gd","scripts/first_route_prototype.gd"],"map_size":[768,896],"gate_from_riverfront":[880,8],"historic_arrival":[384,848],"sites":{"board":[384,664],"ledger":[224,428],"shop":[544,428]},"paid_generation":0,"local_run_state_only":True}
(D/"installation.json").write_text(json.dumps(manifest,indent=2));print(json.dumps(manifest))
