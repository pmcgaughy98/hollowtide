from pathlib import Path
import hashlib,json,shutil,re
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"area-transition-review"; C=D/"candidate"
P=Path(r"C:/Users/pmcga/dev/hollowtide")
before=json.loads((D/"before-manifest.json").read_text())
for rel,sha in before.items():
    assert hashlib.sha256((P/rel).read_bytes()).hexdigest()==sha,"Concurrent edit: "+rel
changes={}
def change(rel,old,new,count=1):
    text=changes.get(rel,(P/rel).read_text(encoding="utf-8-sig"))
    assert text.count(old)==count,(rel,old[:90],text.count(old))
    changes[rel]=text.replace(old,new,count)
change("scripts/main_menu.gd",'const FIRST_SCENE := "res://scenes/first_route_prototype.tscn"','const FIRST_SCENE := "res://scenes/world_journey.tscn"')
old='''\t# Set the exported model before Player._ready builds its eight-direction atlas.
\tvar destination := _route_scene.instantiate()
\tvar player := destination.get_node_or_null("Player")
\tif player == null:
\t\tdestination.free()
\t\t_set_route_error()
\t\treturn
\tplayer.set("chibi_model", _selected_courier)'''
new='''\t# Set the courier before any area builds its eight-direction atlas.
\tvar destination := _route_scene.instantiate()
\tif not destination.has_method("set_courier_model"):
\t\tdestination.free()
\t\t_set_route_error()
\t\treturn
\tdestination.call("set_courier_model", _selected_courier)'''
change("scripts/main_menu.gd",old,new)
change("scripts/first_route_prototype.gd",'\tcamera.limit_left = -480','\tcamera.limit_left = -768')
change("scripts/first_route_prototype.gd",'\tcamera.limit_right = 1024','\tcamera.limit_right = 704')
change("scripts/first_route_prototype.gd",'''\tcamera.limit_bottom = 384 if player.position.x < 0 else 640
\tvar at_home := player.position.x < 200.0 and player.position.y < 248.0
\tcamera.position.y = move_toward(camera.position.y, -84.0 if at_home else -24.0, _delta * 96.0)''','''\tcamera.limit_bottom = 640
\tcamera.position.y = -24.0''')
change("scripts/first_route_prototype.gd",'''\t\tif player.position.x < 0:
\t\t\t_area_label.text = "HOMETOWN / COURTYARD LANE"
\t\telif player.position.x >= 672:
\t\t\t_area_label.text = "CITY RIVERFRONT"''','''\t\tif player.position.x < 0:
\t\t\t_area_label.text = "ROUTE 1 / LEVEE MEADOW"
\t\telif player.position.x >= 672:
\t\t\t_area_label.text = "BRIDGE / CITY ENTRANCE"''')
change("scripts/first_route_prototype.gd",'\t\t\t_area_label.text = "HOME / DISPATCH LANE"','\t\t\t_area_label.text = "ROUTE 1 / WEST APPROACH"')
for line in ['\t"dispatch": Vector2(80, 192),\n','\t"city_clerk": Vector2(816, 480),\n','\t"city_directions": Vector2(912, 444),\n','\t"home_courtyard": Vector2(-336, 184),\n','\t"home_directions": Vector2(-32, 192),\n','\t"shared_garden": Vector2(-172, 310),\n']:
    change("scripts/first_route_prototype.gd",line,"")
change("scripts/first_route_prototype.gd",'Follow the worn lane east to the courier hall. The dispatcher waits in front. From there, the marked levee entrance leads to Route 1 and the river bridge. This lane returns to the courtyard homes.','The courier hall stands beside the eastern street. Follow the Route 1 sign to the opening at the end of that street. Beyond the entrance, the meadow path bends toward the raised levee and river bridge. The courtyard streets return to your home.')
change("scripts/first_route_prototype.gd","The dispatcher is taking runners at the east end of the lane.","The dispatcher is taking runners beside the eastern street.")
change("scripts/first_route_prototype.gd","The lane leads back to the dispatcher and the raised river route.","The eastern street leads to the dispatcher and the marked Route 1 entrance.")
change("scripts/first_route_prototype.gd","The loop around the beds returns to the dispatch lane.","The loop around the beds returns to the main courtyard street.")
change("scripts/first_route_prototype.gd","Historic quarter: north and uphill. Works district: south along the river. The older school quarter lies beyond the historic streets; the newer trade roads continue inland. The bridge returns to your hometown.","This riverfront branch marks your arrival in the city. The brick frontage and records house are local landmarks. The historic, works, school and trade quarters will each have their own entrances as they are built. Return west over the bridge for Route 1 and the hometown.")
change("scenes/first_route_prototype.tscn",'[ext_resource type="PackedScene" path="res://scenes/hometown_courtyard.tscn" id="hometown_level"]','[ext_resource type="Script" path="res://scripts/route1_approach.gd" id="route_approach"]')
change("scenes/first_route_prototype.tscn",'position = Vector2(-336, 192)','position = Vector2(-720, 512)')
change("scenes/first_route_prototype.tscn",'[node name="HometownCourtyard" parent="." instance=ExtResource("hometown_level")]','[node name="MeadowApproach" type="Node2D" parent="."]\nscript = ExtResource("route_approach")')
change("scripts/route1_crossing.gd",'\t_build_city_road_surface()\n',"")
change("scripts/route1_crossing.gd",'\t_build_arrival()\n',"""\t# The dispatcher and eastern branch now live in their own area scenes.
\t_route.get_node("RouteDecor/WaylineOffice").hide()
\t_route.get_node("Dispatcher").hide()
\tfor body in _route.get_node("RouteDecor/WaylineOffice").find_children("*", "StaticBody2D"):
\t\tbody.collision_layer = 0
\t\tbody.collision_mask = 0
""")
change("scripts/route1_crossing.gd",'\tfor x in range(64):','\tfor x in range(44):')
citypaths='''\t# Paths below the original slice and through the arrival courtyard.
\t_trail(terrain, Vector2i(42, 26), Vector2i(60, 26), 1)
\t_trail(terrain, Vector2i(50, 26), Vector2i(50, 30), 1)
\t_trail(terrain, Vector2i(55, 23), Vector2i(55, 33), 1)
\tfor x in range(46, 59):
\t\tfor y in range(26, 31):
\t\t\tterrain.set_cell(Vector2i(x, y), 0, Vector2i(11, 0))'''
change("scripts/route1_crossing.gd",citypaths,"")
change("scripts/route1_crossing.gd",'''\t_obstacle(bounds, "North", Vector2(512, -8), Vector2(1024, 16))
\t_obstacle(bounds, "South", Vector2(512, 648), Vector2(1024, 16))
\t# The home lane is the only opening in the west edge.
\t_obstacle(bounds, "WestAboveHomeLane", Vector2(-8, 84), Vector2(16, 168))
\t_obstacle(bounds, "WestBelowHomeLane", Vector2(-8, 428), Vector2(16, 424))
\t_obstacle(bounds, "East", Vector2(1032, 320), Vector2(16, 640))''','''\t_obstacle(bounds, "North", Vector2(-32, -8), Vector2(1472, 16))
\t_obstacle(bounds, "South", Vector2(-32, 648), Vector2(1472, 16))
\t_obstacle(bounds, "WestAboveEntrance", Vector2(-776, 242), Vector2(16, 484))
\t_obstacle(bounds, "WestBelowEntrance", Vector2(-776, 590), Vector2(16, 100))
\t_obstacle(bounds, "EastAboveBridge", Vector2(712, 200), Vector2(16, 400))
\t_obstacle(bounds, "EastBelowBridge", Vector2(712, 536), Vector2(16, 208))''')
change("scripts/route1_landscape.gd",'\t\tvar tree: Sprite2D = decor.get_node(pair[0])\n\t\ttree.texture = TREES[pair[1]]','\t\tvar tree: Sprite2D = decor.get_node_or_null(pair[0])\n\t\tif tree:\n\t\t\ttree.texture = TREES[pair[1]]')
change("scripts/route1_map_polish.gd",'\t_contact(_route.get_node("RouteDecor/WaylineOffice").position, Vector2(51, 5))','\tif _route.get_node("RouteDecor/WaylineOffice").visible:\n\t\t_contact(_route.get_node("RouteDecor/WaylineOffice").position, Vector2(51, 5))')
change("scripts/route1_map_polish.gd",'\t\t_contact(node.position, Vector2(7 if actor != "CinderhideEncounter" else 13, 2))','\t\tif node.visible:\n\t\t\t_contact(node.position, Vector2(7 if actor != "CinderhideEncounter" else 13, 2))')
# Finalize candidates before touching runtime.
host=(C/"world_journey.gd").read_text().replace('Vector2(144,512)','Vector2(320,512)').replace('"route1", Vector2(680,416)','"route1", Vector2(432,416)')
(C/"world_journey.gd").write_text(host,encoding="utf-8")
land=(C/"area_landscape.gd").read_text().replace('Vector2(1032,240),Vector2(16,480)','Vector2(1032,248),Vector2(16,496)').replace('Vector2(1032,662),Vector2(16,212)','Vector2(1032,656),Vector2(16,224)')
(C/"area_landscape.gd").write_text(land,encoding="utf-8")
scenes={}
scenes["world_journey.tscn"]='''[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/world_journey.gd" id="1"]
[node name="WorldJourney" type="Node2D"]
script = ExtResource("1")
'''
for file,id in [("hometown.tscn","hometown"),("city_riverfront.tscn","riverfront")]:
    scenes[file]='''[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://scripts/world_area.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/player.tscn" id="2"]
[ext_resource type="Script" path="res://scripts/area_landscape.gd" id="3"]
[node name="'''+("Hometown" if id=="hometown" else "CityRiverfront")+'''" type="Node2D"]
y_sort_enabled = true
script = ExtResource("1")
area_id = "'''+id+'''"
[node name="RouteDecor" type="Node2D" parent="."]
y_sort_enabled = true
[node name="Player" parent="." instance=ExtResource("2")]
position = Vector2(224,280)
[node name="Landscape" type="Node2D" parent="."]
script = ExtResource("3")
area_id = "'''+id+'''"
'''
for file,data in scenes.items(): (C/file).write_text(data,encoding="utf-8")
for rel,data in changes.items(): (C/Path(rel).name).write_text(data,encoding="utf-8")
# Atomic baseline guard again immediately before writes.
for rel,sha in before.items():
    assert hashlib.sha256((P/rel).read_bytes()).hexdigest()==sha,"Concurrent edit: "+rel
dest=P/"assets/sprites/world/area_transitions_2026_10_03"; dest.mkdir(exist_ok=True)
for name in ["hometown_streets.png","route1_meadow_approach.png","riverfront_streets.png","riverfront_water_mask.png"]:
    assert not (dest/name).exists()
    shutil.copy2(C/name,dest/name)
for original,name in [("reused_brick_shop_native.png","brick_shop.png"),("street_ledger_house_native.png","ledger_house.png")]:
    shutil.copy2(W/"historic-riverfront-review"/original,dest/name)
for name in ["world_journey.gd","world_area.gd","area_landscape.gd","route1_approach.gd"]:
    assert not (P/"scripts"/name).exists()
    shutil.copy2(C/name,P/"scripts"/name)
for name in scenes:
    assert not (P/"scenes"/name).exists()
    shutil.copy2(C/name,P/"scenes"/name)
for rel,data in changes.items(): (P/rel).write_text(data,encoding="utf-8",newline="\n")
(D/"installed-files.json").write_text(json.dumps(list(changes)+["scripts/"+n for n in ["world_journey.gd","world_area.gd","area_landscape.gd","route1_approach.gd"]]+["scenes/"+n for n in scenes]+["assets/sprites/world/area_transitions_2026_10_03/"+n.name for n in dest.iterdir() if n.is_file()],indent=2))
print("Installed",len(changes),"targeted edits, four scripts, three independent scenes, six PNGs.")
