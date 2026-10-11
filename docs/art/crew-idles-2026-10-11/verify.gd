extends SceneTree
const W := "D:/dev/hollowtide-crew-idles-20261011/"
const Finish := preload("res://scripts/arena/creature_finish.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
var checks:=0
var fails:=0
var out:=W+"review/stage/"
func _initialize() -> void:run.call_deferred()
func frames(n:int) -> void:
	for k in n:await process_frame
func check(ok:bool,label:String) -> void:
	checks+=1
	if not ok:fails+=1
	print("PASS " if ok else "FAIL ",label)
func run() -> void:
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	var manifest:Array=JSON.parse_string(FileAccess.get_file_as_string(W+"manifest.json"))
	var v:=SubViewport.new();v.size=Vector2i(600,300);v.transparent_bg=true;v.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(v)
	for k in manifest.size():
		var r:Dictionary=manifest[k];var tex:Texture2D=load("res://"+r.output)
		var imported:=tex.get_image();imported.convert(Image.FORMAT_RGBA8)
		var png:=Image.load_from_file(W+"prepared/"+r.output);png.convert(Image.FORMAT_RGBA8)
		check(imported.get_data()==png.get_data() and tex.get_size()==Vector2(r.size[0],r.size[1]),r.form+": native import RGBA and town canvas exact")
		var walk:Texture2D=load("res://assets/sprites/arena/"+r.form+"/town/s.png")
		check(tex.get_size()==walk.get_size() and imported.get_used_rect().end.y==r.baseline+1,r.form+": town south baseline and padding preserved")
		for side in 2:
			var s:=Sprite2D.new();s.centered=false;s.position=Vector2((k%3)*200+side*100+5,(k/3)*150+5);s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
			v.add_child(s);s.texture=walk if side==0 else tex;Finish.apply(s)
	await frames(5);await RenderingServer.frame_post_draw
	var im:=v.get_texture().get_image();var unclipped:=true
	for k in manifest.size():
		for side in 2:
			var tile:=im.get_region(Rect2i((k%3)*200+side*100,(k/3)*150,100,150));var box:=tile.get_used_rect()
			unclipped=unclipped and box.has_area() and box.position.x>0 and box.position.y>0 and box.end.x<100 and box.end.y<150
	im.save_png(out+"native-pairs.png")
	check(unclipped,"all six idle/walk textures render with the shared shader inside padded cells")
	v.queue_free();await frames(4)
	# Preview the prepared assets on the real NPC sprite holders; production swap belongs to Claude.
	TeamState.start([[0,0],[1,0]])
	TeamState.data["story"]={"met_crew":true,"guild_trial":true,"runner":true}
	TeamState.data["rollcall_runs"]=0
	var room:Node2D=load("res://scenes/town_room.tscn").instantiate();room.room_id="hall_low";room.poll_input=false;root.add_child(room);await frames(8)
	for k in manifest.size():
		var r:Dictionary=manifest[k];var found:Array=room.npcs.filter(func(e:Dictionary)->bool:return e.form==r.form)
		var e:Dictionary=found[0] if not found.is_empty() else SceneKit.spawn(room,r.form,Vector2i(17,11),"s")
		var original:Texture2D=e.still.s;var anchor:Vector2=e.sprite.position
		e.still.s=load("res://"+r.output);e.facing="s";room._place(e)
		check(e.sprite.texture==e.still.s and e.sprite.position==anchor and e.sprite.material is ShaderMaterial,r.form+": idle preview uses actual room shader and unchanged anchor")
		var walks_ok:=true
		for facing in ["s","se","e","ne","n","nw","w","sw"]:
			for f in 8:
				e.facing=facing;e.walk_t=1.0;e.walk_clock=(f+0.05)/room.WALK_FPS;room._process(0.0)
				walks_ok=walks_ok and e.sprite.texture.resource_path.ends_with("/walk_"+String(facing)+"_f"+str(f)+".png") and e.sprite.position==anchor
		check(walks_ok,r.form+": all 64 current walking frames still select normally")
		e.facing="s";e.walk_t=0.0;room._place(e)
		check(e.sprite.texture==e.still.s,r.form+": preview returns to prepared idle after walking")
	await frames(4)
	room.set_process(false);var rv:SubViewport=room._world.get_parent();rv.size=Vector2i(room.room().w*room.T,room.room().h*room.T);room._world.position=Vector2.ZERO
	await frames(3);await RenderingServer.frame_post_draw;rv.get_texture().get_image().save_png(out+"hall-idle-preview.png")
	room.queue_free();await frames(6)
	for child in root.get_children():child.queue_free()
	await frames(16)
	print("CREW IDLES ",checks-fails,"/",checks," PASS")
	quit(0 if fails==0 else 1)
