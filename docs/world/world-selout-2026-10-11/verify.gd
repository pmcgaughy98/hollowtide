extends SceneTree
const OUT := "D:/dev/hollowtide-world-selout-20261011/"
const Town := preload("res://scripts/town/hub_town.gd")
const Finish := preload("res://scripts/town/world_finish.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
var fails := 0
var checks := 0
func _initialize() -> void: _run.call_deferred()
func _frames(n:int)->void:
	for k in n:await process_frame
func _ok(label:String,good:bool)->void:
	checks+=1
	if not good:fails+=1
	print("%s -> %s" % [label,"ok" if good else "FAIL"])
func _run()->void:
	var before := Image.load_from_file(OUT+"before.png");before.convert(Image.FORMAT_RGBA8)
	var raw := Town.paint()
	var mask := Finish.mask()
	raw.save_png(OUT+"after_raw.png");mask.save_png(OUT+"detail_mask.png")
	var view := SubViewport.new();view.size=Finish.SIZE;view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	view.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST;root.add_child(view)
	var sprite := Sprite2D.new();sprite.centered=false;sprite.texture=ImageTexture.create_from_image(raw);Finish.apply(sprite);view.add_child(sprite)
	await _frames(4);await RenderingServer.frame_post_draw
	var gpu := view.get_texture().get_image();gpu.convert(Image.FORMAT_RGBA8);gpu.save_png(OUT+"after.png")
	var cpu_changes:=0;var outside:=0;var quiet:=0;var alpha_changes:=0;var gpu_changes:=0
	for y in Finish.SIZE.y:
		for x in Finish.SIZE.x:
			var a:=before.get_pixel(x,y);var b:=raw.get_pixel(x,y);var c:=gpu.get_pixel(x,y)
			if a.a!=b.a or b.a!=c.a:alpha_changes+=1
			if a!=b:
				cpu_changes+=1
				if mask.get_pixel(x,y).r<0.5:outside+=1
			if b!=c:
				gpu_changes+=1
				if mask.get_pixel(x,y).r<0.5:quiet+=1
	_ok("Native map dimensions and opacity exact",raw.get_size()==before.get_size() and gpu.get_size()==Finish.SIZE and alpha_changes==0)
	_ok("Material rim changes confined to terrain mask (%d pixels)" % cpu_changes,cpu_changes>0 and outside==0)
	_ok("Quiet unselected terrain exact in real GPU output",quiet==0)
	_ok("Actual selected detail shader renders (%d pixels)" % gpu_changes,gpu_changes>0)
	for p in Layout.PLACES:
		var area: Rect2i=Rect2i(p["rect"].grow(1).position*Layout.T,p["rect"].grow(1).size*Layout.T).intersection(Rect2i(Vector2i.ZERO,Finish.SIZE))
		_ok(p["id"]+": art, shadows and approaches pixel-exact",gpu.get_region(area).get_data()==before.get_region(area).get_data())
	var river := Rect2i(0,696,Finish.SIZE.x,72)
	_ok("River bank, water and glints pixel-exact",gpu.get_region(river).get_data()==before.get_region(river).get_data())
	var fallback:=Image.create(48,48,false,Image.FORMAT_RGBA8);fallback.fill(Color("#456789"))
	_ok("Other-sized worlds retain exact fallback",Finish.paint(fallback).get_data()==fallback.get_data())
	view.queue_free();await _frames(4)
	load("res://scripts/town/team_state.gd").start([[0,0],[1,0]])
	var town:Node2D=load("res://scenes/hub_town.tscn").instantiate();town.poll_input=false;root.size=Vector2i(1152,648);root.add_child(town);await _frames(8)
	var maps:Array=town._world.get_children().filter(func(n):return n is Sprite2D and n.position==Vector2.ZERO)
	_ok("Real town applies the masked finish once",maps.size()==1 and maps[0].material.shader==Finish.SHADER and maps[0].material.get_shader_parameter("detail_ink")==0.55)
	_ok("Actual walking grid unchanged",town.grid==Layout.grid())
	for entry in [["lane",Vector2i(13,10)],["switchback",Vector2i(23,20)],["landing",Vector2i(28,28)]]:
		town.team[0]["pos"]=entry[1];town._place(town.team[0]);await _frames(8)
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+"after_"+entry[0]+".png")
	print("WORLD SEL-OUT: %d/%d passed" % [checks-fails,checks])
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await _frames(16);quit(1 if fails else 0)
