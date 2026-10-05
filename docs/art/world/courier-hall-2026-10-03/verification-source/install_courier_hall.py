from pathlib import Path
from PIL import Image
import json,hashlib,shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/courier-hall-review")
files=["scripts/world_journey.gd","scripts/world_area.gd","scripts/area_landscape.gd"]
before={}
for f in files:
    path=P/f;before[f]=hashlib.sha256(path.read_bytes()).hexdigest();shutil.copy2(path,D/(Path(f).name+".before"))
(D/"before-hashes.json").write_text(json.dumps(before,indent=2))
im=Image.open(D/"rd-room-original.png").convert("RGBA")
color=im.getpixel((0,0))
from PIL import ImageDraw
# Remove only the flat exterior canvas contiguous with the four corners.
ImageDraw.floodfill(im,(0,0),(0,0,0,0),thresh=0)
im.save(D/"courier-hall-native.png")
A=P/"assets/sprites/world/courier_hall_2026_10_03";A.mkdir(exist_ok=True)
shutil.copy2(D/"courier-hall-native.png",A/"courier_hall_native.png")
im.crop((103,90,230,130)).save(A/"counter_foreground.png")
hall='''extends Node2D
## This room calls the existing dispatcher; assignment and party stay in WorldJourney.
const ROOM = preload("res://assets/sprites/world/courier_hall_2026_10_03/courier_hall_native.png")
const COUNTER = preload("res://assets/sprites/world/courier_hall_2026_10_03/counter_foreground.png")
const DISPATCHER = preload("res://assets/sprites/world/route1_rd_2026_10_01/dispatcher.png")
const SITES = {"dispatch":Vector2(132,142), "board":Vector2(72,86), "sorting":Vector2(180,171)}
func _ready() -> void:
    var room:=Sprite2D.new()
    room.name="RoomArt";room.texture=ROOM;room.centered=false
    room.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;room.z_index=-10
    add_child(room)
    var clerk:=Sprite2D.new()
    clerk.name="Dispatcher";clerk.texture=DISPATCHER
    clerk.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    clerk.scale=Vector2.ONE*(30.0/46.0)
    clerk.position=Vector2(132,96)
    var used:=DISPATCHER.get_image().get_used_rect()
    clerk.offset.y=floorf(DISPATCHER.get_height()*0.5)-used.end.y
    $RouteDecor.add_child(clerk)
    var front:=Sprite2D.new()
    front.name="CounterFront";front.texture=COUNTER;front.centered=false
    front.position=Vector2(103,130);front.offset=Vector2(0,-40)
    front.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    $RouteDecor.add_child(front)
    for pair in [
        ["NorthWall",Rect2(20,20,215,53)],
        ["WestWall",Rect2(20,73,9,163)],
        ["EastWall",Rect2(229,73,7,163)],
        ["DispatchDesk",Rect2(103,56,126,74)],
        ["WestSorting",Rect2(28,74,20,125)],
        ["EastSorting",Rect2(195,132,30,65)],
        ["SouthWestWall",Rect2(20,200,89,35)],
        ["SouthEastWall",Rect2(143,200,92,35)]]:
        _solid(pair[0],pair[1])
    var camera:Camera2D=$Player/Camera2D
    camera.limit_left=-64;camera.limit_right=320
    camera.limit_top=0;camera.limit_bottom=256
    camera.offset=Vector2.ZERO;camera.position=Vector2(0,-24)
    camera.reset_smoothing()
func _solid(label:String, bounds:Rect2) -> void:
    var body:=StaticBody2D.new();body.name=label
    body.position=bounds.get_center()
    var shape:=CollisionShape2D.new()
    var rectangle:=RectangleShape2D.new();rectangle.size=bounds.size
    shape.shape=rectangle;body.add_child(shape);add_child(body)
func nearest_site() -> String:
    var closest:=""
    var distance:=24.0
    for site in SITES:
        var gap:float=$Player.position.distance_to(SITES[site])
        if gap<distance:distance=gap;closest=site
    return closest
func interaction_hint() -> String:
    match nearest_site():
        "dispatch":return "E  Speak to dispatcher"
        "board":return "E  Read courier board"
        "sorting":return "E  Inspect sorting shelves"
    return "WASD / arrows  Move    Walk through south doorway to leave"
func interact(controller:Node2D) -> void:
    match nearest_site():
        "dispatch":controller.call("_visit_dispatch")
        "board":
            controller.call("_show_message","COURIER BOARD\\n"+controller.get("_objective").text+"\\n"+controller.get("_board").text)
        "sorting":
            controller.call("_show_message","SORTING SHELVES\\nTied canvas bags are arranged beside the counter. Your sealed route pouch stays closed; the dispatcher handles the assignment.")
'''
(P/"scripts/courier_hall.gd").write_text(hall,encoding="utf-8",newline="\n")
scene='''[gd_scene load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/courier_hall.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/player.tscn" id="2"]
[node name="CourierHall" type="Node2D"]
y_sort_enabled = true
script = ExtResource("1")
[node name="RouteDecor" type="Node2D" parent="."]
y_sort_enabled = true
[node name="Player" parent="." instance=ExtResource("2")]
position = Vector2(128,208)
'''
(P/"scenes/courier_hall.tscn").write_text(scene,encoding="utf-8",newline="\n")
journey=P/"scripts/world_journey.gd";s=journey.read_text()
s=s.replace('"hometown": preload("res://scenes/hometown.tscn"),','"hometown": preload("res://scenes/hometown.tscn"),\n    "courier_hall": preload("res://scenes/courier_hall.tscn"),')
s=s.replace('@export_enum("hometown", "route1", "riverfront")','@export_enum("hometown", "route1", "riverfront", "courier_hall")')
s=s.replace('"hometown":Vector2(224,280),"route1"','"hometown":Vector2(224,280),"courier_hall":Vector2(128,208),"route1"')
needle='        "hometown":\n            _gate(entrances, "LeveeEntrance"'
s=s.replace(needle,'        "hometown":\n            _gate(entrances, "CourierHallDoor", Vector2(768,424), Vector2(20,8), "courier_hall", Vector2(128,208), Vector2.UP)\n            _gate(entrances, "LeveeEntrance"')
s=s.replace('        "route1":\n            _gate','        "courier_hall":\n            _gate(entrances, "HallExit", Vector2(128,244), Vector2(22,12), "hometown", Vector2(768,452), Vector2.DOWN)\n        "route1":\n            _gate')
s=s.replace('route.get("_area_label").text = "HOMETOWN / COURTYARD STREETS" if active_id == "hometown" else "CITY / RIVERFRONT"','route.get("_area_label").text = {"hometown":"HOMETOWN / COURTYARD STREETS", "courier_hall":"HOMETOWN / COURIER HALL", "riverfront":"CITY / RIVERFRONT"}[active_id]')
journey.write_text(s,encoding="utf-8",newline="\n")
area=P/"scripts/world_area.gd";s=area.read_text().replace('"dispatch": Vector2(768,456)','"hall": Vector2(768,442)')
s=s.replace('"dispatch": return "E  Speak to dispatcher"','"hall": return "Walk up through courier hall doorway"')
s=s.replace('"dispatch": controller.call("_visit_dispatch")','"hall": controller.call("_show_message", "COURIER HALL\\nThe dispatcher is inside. Walk up through the front doorway to collect or report your route.")')
area.write_text(s,encoding="utf-8",newline="\n")
landscape=P/"scripts/area_landscape.gd";s=landscape.read_text()
line='    _prop("Dispatcher",DISPATCHER,Vector2(768,456),0.652174)\n'
assert s.count(line)==1;s=s.replace(line,"")
landscape.write_text(s,encoding="utf-8",newline="\n")
print(json.dumps({"runtime_files":[*files,"scripts/courier_hall.gd","scenes/courier_hall.tscn"],"art_canvas":im.size,"counter_region":[103,90,127,40],"exterior_backdrop_color":color}))
