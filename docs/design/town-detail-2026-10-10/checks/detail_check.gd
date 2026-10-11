extends SceneTree
const W="D:/dev/hollowtide-town-detail-20261010/"
const Art=preload("res://scripts/town/town_detail_art.gd")
const Marks=preload("res://scripts/town/landmark_exteriors.gd")
const OldMarks=preload("D:/dev/hollowtide-town-detail-20261010/originals/scripts/town/landmark_exteriors.gd")
const OldGround=preload("D:/dev/hollowtide-town-detail-20261010/originals/scripts/town/highbank_painter.gd")
const Ground=preload("res://scripts/town/highbank_painter.gd")
const Town=preload("res://scripts/town/hub_town.gd")
const Layout=preload("res://scripts/town/town_layout.gd")
var count:=0
var fails:=0
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func check(ok:bool,text:String)->void:
	count+=1
	if not ok:fails+=1
	print("PASS " if ok else "FAIL ",text)
func run()->void:
	for id in ["lookout","landing","dock"]:
		check(Art.image(id)!=null and Art.image(id).get_size()==Art.SIZES[id],id+" detailed native bounds and complete fringe")
		check(Marks.paint_fallback(id).get_data()==OldMarks.paint(id).get_data(),id+" original fallback byte exact")
	check(Art.image("missing")==null,"missing asset preserves code fallback")
	var hall:=Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/world/hall_interior_2026_10_10/hall_native.png"))
	check(Art.image("floor").get_data()==hall.get_region(Rect2i(48,144,160,96)).get_data(),"approved interior stone material reused exactly")
	check(Art.image("lookout").get_pixel(84,90).a<0.5,"lookout service approach remains clear")
	check(Art.image("landing").get_pixel(60,42).a<0.5,"landing reading/interaction tile remains clear")
	var gate_clear:=true
	for y in range(24,72):
		for x in range(168,216):
			if Art.image("landing").get_pixel(x,y).a>=0.5:gate_clear=false
	check(gate_clear,"landing art stays clear of separate Hollow Mouth")
	var block:=Town.paint_blockout()
	var base:Image=load("res://scripts/town/highbank_ground_painter.gd").paint(block)
	var before:=OldGround.paint(base);var after:=Ground.paint(base)
	var allowed:Array[Rect2i]=[Rect2i(0,696,1152,72)]
	for id in ["lookout","landing"]:
		var place:=Marks.place(id);allowed.append(Rect2i(place.rect.position*24,place.rect.size*24))
	var outside:=0;var changed:=0;var opaque:=true;var protected:=true
	for y in 768:
		for x in 1152:
			if after.get_pixel(x,y).a!=1.0:opaque=false
			if before.get_pixel(x,y)==after.get_pixel(x,y):continue
			changed+=1;var ok:=false
			for r in allowed:
				if r.has_point(Vector2i(x,y)):ok=true
			if not ok:outside+=1
	check(changed>0 and outside==0,"map detail changes only selected platforms and shoreline: %d changed, %d outside"%[changed,outside])
	check(opaque,"river compositing leaves world fully opaque")
	var terrain:=Art.river(before)
	for id in ["landing","dock","gate"]:
		var place:=Marks.place(id);var rect:=Rect2i(place.rect.position*24,place.rect.size*24)
		if id=="dock":rect.size.y+=24
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x):
				if terrain.get_pixel(x,y)!=before.get_pixel(x,y):protected=false
	check(protected,"shore overlay preserves all platform and entrance floor pixels")
	# Real town objects retain position, service and house finish at native scale.
	load("res://scripts/town/team_state.gd").start([[0,0],[1,0]])
	var town:Node=load("res://scenes/hub_town.tscn").instantiate();town.poll_input=false;root.add_child(town);await frames(8)
	for id in ["lookout","landing","dock"]:
		var data:Dictionary=town._building_exteriors.buildings[id]
		check(data.base.position==Vector2(Marks.place(id).rect.position*24) and data.sprite.scale==Vector2.ONE,id+" original placement and native scale retained")
		check(data.sprite.material.shader==preload("res://scripts/town/exterior_finish.gdshader") and data.sprite.material.get_shader_parameter("detail_ink")==1.0,id+" shared material rim/detail finish")
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12);print("TOWN DETAIL ",count-fails,"/",count," PASS");quit(0 if fails==0 else 1)
