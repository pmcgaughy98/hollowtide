extends SceneTree
const Room := preload("res://scripts/town/town_room.gd")
const Art := preload("res://scripts/town/hall_floors_art.gd")
const Painter := preload("res://scripts/town/room_painter.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const OUT := "D:/dev/hollowtide-hall-floors-finish-20261011/"
var fails := 0
var checks := 0
func _initialize() -> void: _run.call_deferred()
func _ok(label: String, good: bool) -> void:
	checks += 1
	if not good: fails += 1
	print("%s -> %s" % [label,"ok" if good else "FAIL"])
func _frames(n: int) -> void:
	for k in n: await process_frame
func _map(room: Node2D) -> Sprite2D:
	for child in room._world.get_children():
		if child is Sprite2D and child.position == Vector2.ZERO: return child
	return null
func _reachable(r: Node2D) -> Dictionary:
	var seen := {r.team[0]["pos"]:true}
	var todo: Array = seen.keys()
	while not todo.is_empty():
		var p: Vector2i = todo.pop_front()
		for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var q: Vector2i = p+d
			if not seen.has(q) and r._open(q) and r._link_at(q).is_empty():
				seen[q] = true;todo.append(q)
	return seen
func _run() -> void:
	TeamState.start([[0,0],[1,0]])
	TeamState.data["story"]={"met_crew":true,"parcel":"stolen","guild_trial":true,"runner":true}
	for id in ["hall","hall_low","chamber","runners"]:
		var r := load("res://scenes/town_room.tscn").instantiate() as Node2D
		r.room_id=id;r.poll_input=false
		r.arrive={"hall":Vector2i(11,12),"hall_low":Vector2i(24,14),"chamber":Vector2i(8,8),"runners":Vector2i(1,5)}[id]
		root.add_child(r);await _frames(8)
		var map := _map(r)
		var raw := map.texture.get_image()
		var material := map.material as ShaderMaterial
		_ok(id+": native size and shared detail finish",raw.get_size()==Art.SIZES[id] and material!=null and material.shader==Art.SHADER and material.get_shader_parameter("detail_ink")==0.75)
		var texture: Texture2D = material.get_shader_parameter("detail_mask")
		var mask := texture.get_image()
		var view := SubViewport.new();view.size=raw.get_size();view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		view.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		root.add_child(view)
		var copy := Sprite2D.new();copy.centered=false;copy.texture=map.texture;copy.material=material;view.add_child(copy)
		await _frames(3);await RenderingServer.frame_post_draw
		var gpu := view.get_texture().get_image();gpu.convert(Image.FORMAT_RGBA8)
		gpu.save_png(OUT+"finished_"+id+".png");raw.save_png(OUT+"runtime_"+id+".png");mask.save_png(OUT+"mask_"+id+".png")
		var floor_changes := 0;var detail_changes := 0;var translucent := 0
		for y in raw.get_height():
			for x in raw.get_width():
				if raw.get_pixel(x,y).a<1.0: translucent+=1
				if gpu.get_pixel(x,y)!=raw.get_pixel(x,y):
					if mask.get_pixel(x,y).r<0.5: floor_changes+=1
					else: detail_changes+=1
		_ok(id+": opaque map; unselected floor exact",translucent==0 and floor_changes==0)
		_ok(id+": selected details actually render",detail_changes>0)
		var seen := _reachable(r)
		var service_count := 0
		for spot in r.room()["spots"]:
			var rect: Rect2i = spot["rect"]
			var reachable := false
			for p in seen:
				for d in Room.DIRS:
					if rect.has_point(p+d): reachable=true
			if reachable: service_count+=1
		_ok(id+": every wired service has a reachable approach",service_count==r.room()["spots"].size())
		if id=="hall":
			var original := Image.load_from_file(OUT+"before/whole_hall.png")
			var painted := Painter.paint(id,Room.ROOMS[id])
			var outside := 0;var changed := 0
			for y in original.get_height():
				for x in original.get_width():
					if original.get_pixel(x,y)!=painted.get_pixel(x,y):
						changed+=1
						if not Rect2i(336,240,48,48).has_point(Vector2i(x,y)): outside+=1
			_ok("Upper Hall art changes confined to wired stairs",outside==0 and changed>0)
			_ok("Cleared counter mask stays clear after stair finish",mask.get_pixel(200,70).r==0 and mask.get_pixel(345,250).r==1)
			var desks: Array = r._world.get_children().filter(func(n):return n is Sprite2D and n.position==Vector2(168,70))
			_ok("Original Guildmaster desk placement and finish preserved",desks.size()==1 and desks[0].z_index==116 and desks[0].texture.get_size()==Vector2(192,52) and desks[0].material.get_shader_parameter("detail_ink")==0.55)
		if id=="chamber":
			var old := Image.create(Room.ROOMS[id]["w"]*24,Room.ROOMS[id]["h"]*24,false,Image.FORMAT_RGBA8)
			Painter._chamber(old,Room.ROOMS[id])
			old.save_png(OUT+"before/current_whole_chamber.png")
			var current := Painter.paint(id,Room.ROOMS[id])
			var rect := Rect2i(165,240,78,24)
			_ok("Chamber south threshold exact",old.get_region(rect).get_data()==current.get_region(rect).get_data())
		view.queue_free();r.queue_free();await _frames(4)
	# Every fixture retains source alpha and all pixels away from its one-pixel material rim.
	var alpha_ok := true;var interior_ok := true
	for id in Art.PROPS:
		for p in Art.PROPS[id]:
			var original := Art._load(Art._path(p[0]))
			var rect: Rect2i=p[1]
			if original.get_size()!=rect.size:original.resize(rect.size.x,rect.size.y,Image.INTERPOLATE_NEAREST)
			var finished := Art._prop(p)
			for y in original.get_height():
				for x in original.get_width():
					var v := Vector2i(x,y)
					if original.get_pixelv(v).a!=finished.get_pixelv(v).a:alpha_ok=false
					var inside := true
					for d in Art.SelOut.DIRS:
						if not Art.SelOut._selected(original,v+d,null):inside=false
					if inside and original.get_pixelv(v)!=finished.get_pixelv(v):interior_ok=false
	_ok("Fixture sel-out preserves every source alpha",alpha_ok)
	_ok("Fixture sel-out preserves all material interiors",interior_ok)
	var home := Image.create(336,240,false,Image.FORMAT_RGBA8)
	Painter._home(home,Room.ROOMS["home"])
	home=preload("res://scripts/town/home_room_art.gd").paint(home)
	_ok("Finished Home remains byte-exact",home.get_data()==Painter.paint("home",Room.ROOMS["home"]).get_data())
	# Failure path is exercised only on our owned staging crop, immediately restored.
	if ProjectSettings.globalize_path("res://").begins_with("D:"):
		var path := ProjectSettings.globalize_path(Art.FOLDER+"pegs.png")
		var held := path+".check-held"
		var rename := DirAccess.rename_absolute(path,held)
		var fallback := Image.create(336,240,false,Image.FORMAT_RGBA8)
		Painter._runners(fallback,Room.ROOMS["runners"])
		var exact := rename==OK and not Art.available("runners") and Art.paint("runners",fallback).get_data()==fallback.get_data()
		if rename==OK:DirAccess.rename_absolute(held,path)
		_ok("Missing owned sprite restores original runners painter exactly",exact and Art.available("runners"))
	print("HALL ART: %d/%d passed" % [checks-fails,checks])
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await _frames(16);quit(1 if fails else 0)
