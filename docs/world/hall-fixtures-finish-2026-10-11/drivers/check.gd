extends SceneTree
const W := "D:/dev/hollowtide-hall-fixtures-20261011/"
const OUT := W+"review/after/"
const Room := preload("res://scripts/town/town_room.gd")
const Art := preload("res://scripts/town/hall_floors_art.gd")
const Finish := preload("res://scripts/town/hall_fixtures_art.gd")
const Painter := preload("res://scripts/town/room_painter.gd")
const State := preload("res://scripts/town/team_state.gd")
var fails:=0
var checks:=0
func _initialize() -> void:_run.call_deferred()
func _ok(label: String,good: bool) -> void:
	checks+=1
	if not good:fails+=1
	print(label+" -> "+("ok" if good else "FAIL"))
func _frames(n: int) -> void:
	for k in n:await process_frame
func _inside(id: String,p: Vector2i,halo: int=0) -> bool:
	for rect in Finish.regions(id):
		if rect.grow(halo).has_point(p):return true
	return false
func _reachable(r: Node2D) -> Dictionary:
	var seen:={r.team[0]["pos"]:true}
	var todo:Array=seen.keys()
	while not todo.is_empty():
		var p:Vector2i=todo.pop_front()
		for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var q:Vector2i=p+d
			if not seen.has(q) and r._open(q) and r._link_at(q).is_empty():seen[q]=true;todo.append(q)
	return seen
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	State.start([[0,0],[1,0]])
	State.data["story"]={"met_crew":true,"parcel":"stolen","guild_trial":true,"runner":true}
	var counts:={}
	for id in ["hall","hall_low","chamber","runners"]:
		var r:=load("res://scenes/town_room.tscn").instantiate() as Node2D
		r.room_id=id;r.poll_input=false
		r.arrive={"hall":Vector2i(11,12),"hall_low":Vector2i(24,14),"chamber":Vector2i(8,8),"runners":Vector2i(1,5)}[id]
		root.add_child(r);await _frames(8)
		var map:Sprite2D
		for child in r._world.get_children():
			if child is Sprite2D and child.position==Vector2.ZERO:map=child
		var raw:=map.texture.get_image()
		var material:=map.material as ShaderMaterial
		var mask_texture:Texture2D=material.get_shader_parameter("detail_mask")
		var mask:=mask_texture.get_image()
		_ok(id+": current native canvas and shared finish",raw.get_size()==Finish.SIZES[id] and material.shader==Art.SHADER and material.get_shader_parameter("detail_ink")==0.75)
		var before:=Image.load_from_file(W+"review/before/"+id+"_raw.png")
		var before_mask:=Image.load_from_file(W+"review/before/"+id+"_mask.png")
		var raw_changed:=0;var raw_outside:=0;var mask_outside:=0;var translucent:=0
		for y in raw.get_height():
			for x in raw.get_width():
				var p:=Vector2i(x,y)
				if raw.get_pixelv(p).a!=1.0:translucent+=1
				if raw.get_pixelv(p)!=before.get_pixelv(p):
					raw_changed+=1
					if not _inside(id,p):raw_outside+=1
				if mask.get_pixelv(p)!=before_mask.get_pixelv(p) and not _inside(id,p):mask_outside+=1
		_ok(id+": only corrected fixture pixels changed",raw_changed>0 and raw_outside==0 and translucent==0)
		_ok(id+": detail mask additions confined to fixtures",mask_outside==0)
		var v:=SubViewport.new();v.size=raw.get_size();v.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		v.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		root.add_child(v)
		var s:=Sprite2D.new();s.centered=false;s.texture=map.texture;s.material=material;v.add_child(s)
		await _frames(3);await RenderingServer.frame_post_draw
		var gpu:=v.get_texture().get_image();gpu.convert(Image.FORMAT_RGBA8)
		var old_gpu:=Image.load_from_file(W+"review/before/"+id+"_gpu.png")
		var floor_changed:=0;var selected_changed:=0;var gpu_outside:=0
		for y in raw.get_height():
			for x in raw.get_width():
				var p:=Vector2i(x,y)
				if gpu.get_pixelv(p)!=raw.get_pixelv(p):
					if mask.get_pixelv(p).r<0.5:floor_changed+=1
					elif _inside(id,p):selected_changed+=1
				if gpu.get_pixelv(p)!=old_gpu.get_pixelv(p) and not _inside(id,p,1):gpu_outside+=1
		_ok(id+": all unselected floor pixels exact through OpenGL",floor_changed==0)
		_ok(id+": native ink renders on the fixtures",selected_changed>0)
		_ok(id+": other room art exact outside one-pixel shader sampling",gpu_outside==0)
		var seen:=_reachable(r);var service_count:=0
		for spot in r.room()["spots"]:
			var rect:Rect2i=spot["rect"];var reachable:=false
			for p in seen:
				for d in Room.DIRS:
					if rect.has_point(p+d):reachable=true
			if reachable:service_count+=1
		_ok(id+": every service has a reachable approach",service_count==r.room()["spots"].size())
		if id=="hall":
			_ok("Downstairs: dark arch; treads brighten toward landing",raw.get_pixel(360,252).get_luminance()<0.05 and raw.get_pixel(345,282).get_luminance()>raw.get_pixel(345,263).get_luminance())
			_ok("Guildmaster desk mask stays clear",mask.get_pixel(200,70).r==0)
			var desks:Array=r._world.get_children().filter(func(n):return n is Sprite2D and n.position==Vector2(168,70))
			_ok("Guildmaster desk position, depth and material preserved",desks.size()==1 and desks[0].z_index==116 and desks[0].texture.get_size()==Vector2(192,52) and desks[0].material.get_shader_parameter("detail_ink")==0.55)
		if id=="hall_low":
			_ok("Upstairs: lit arch; treads brighten toward upper floor",raw.get_pixel(624,321).get_luminance()>0.6 and raw.get_pixel(609,331).get_luminance()>raw.get_pixel(609,355).get_luminance())
		if id in ["hall_low","runners"]:
			_ok(id+": side opening has a narrow timber edge and dark passage",raw.get_pixel(12,137).get_luminance()>raw.get_pixel(5,137).get_luminance()*2 and raw.get_pixel(19,137).get_luminance()<0.15)
		if id=="chamber":
			var exit:=Rect2i(165,240,78,24)
			_ok("Chamber south threshold exact",raw.get_region(exit).get_data()==before.get_region(exit).get_data())
		raw.save_png(OUT+id+"_raw.png");gpu.save_png(OUT+id+"_gpu.png");mask.save_png(OUT+id+"_mask.png")
		r.set_process(false)
		var rv:=r._world.get_parent() as SubViewport
		rv.size=raw.get_size();r._world.position=Vector2.ZERO
		await _frames(3);await RenderingServer.frame_post_draw
		rv.get_texture().get_image().save_png(OUT+id+"_room.png")
		counts[id]={"painted_pixels":raw_changed,"outside_paint":raw_outside,"outside_mask":mask_outside,"unselected_gpu":floor_changed,"gpu_outside_sampling_halo":gpu_outside,"fixture_ink_pixels":selected_changed,"reachable_services":service_count}
		v.queue_free();r.queue_free();await _frames(4)
	var wrong:=Image.create(10,10,false,Image.FORMAT_RGBA8);wrong.fill(Color.RED)
	_ok("Unknown room and wrong-size canvas pass through exact",Finish.paint("home",wrong)==wrong and Finish.paint("hall",wrong)==wrong and Finish.add_mask("hall",wrong)==wrong)
	var f:=FileAccess.open(OUT+"results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"passed":checks-fails,"rooms":counts},"\t"));f.close()
	print("HALL FIXTURES: %d/%d passed" % [checks-fails,checks])
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await _frames(16);quit(1 if fails else 0)
