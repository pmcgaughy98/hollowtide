extends SceneTree
const W := "D:/dev/hollowtide-crew-selout-20261011/"
const Finish := preload("res://scripts/arena/creature_finish.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const Crew := preload("res://scripts/town/guild_crew.gd")
const FORMS := ["grubbit","muskin","slipjaw","stillwade","wickglow","rinsepaw","cairnshell","crawdukes"]
const FACINGS := ["s","se","e","ne","n","nw","w","sw"]
var checks := 0
var fails := 0
var out := W+"review/native/"
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
	var records:Array=JSON.parse_string(FileAccess.get_file_as_string(W+"manifest.json"))
	var imported:=0
	for form in FORMS:
		var exact:=true
		for r in records:
			if r.form!=form or not String(r.path).begins_with("assets/"):continue
			var tex:Texture2D=load("res://"+r.path)
			var actual:=tex.get_image();actual.convert(Image.FORMAT_RGBA8)
			var expected:=Image.load_from_file(W+"prepared/"+r.path);expected.convert(Image.FORMAT_RGBA8)
			exact=exact and actual.get_size()==expected.get_size()
			var a:=actual.get_data();var b:=expected.get_data()
			for j in range(0,b.size(),4):
				if a[j+3]!=b[j+3] or (b[j+3]>0 and (a[j]!=b[j] or a[j+1]!=b[j+1] or a[j+2]!=b[j+2])):
					exact=false;print("IMPORT MISMATCH ",r.path," pixel ",j/4);break
			imported+=1
		check(exact,form+": all 152 imported textures match current prepared opaque RGB/alpha/dimensions")
	check(imported==1216,"all 1216 runtime textures checked through ResourceLoader")
	var v:=SubViewport.new();v.size=Vector2i(1856,1856);v.transparent_bg=true;v.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(v)
	var sprites:Array[Sprite2D]=[]
	for k in 64:
		var s:=Sprite2D.new();s.centered=false;s.position=Vector2((k%8)*232+12,(k/8)*232+12);s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		v.add_child(s);Finish.apply(s);sprites.append(s)
	for form in FORMS:
		for kind in ["town","dungeon","full"]:
			var count:=8 if kind=="full" else 64
			for k in 64:
				sprites[k].visible=k<count
				if k>=count:continue
				var path:String="res://assets/sprites/arena/"+form+"/"
				path+=FACINGS[k]+".png" if kind=="full" else kind+"/walk_"+FACINGS[k/8]+"_f"+str(k%8)+".png"
				sprites[k].texture=load(path)
			await frames(3);await RenderingServer.frame_post_draw
			var im:=v.get_texture().get_image();var valid:=true
			for k in count:
				var tile:=im.get_region(Rect2i((k%8)*232,(k/8)*232,232,232))
				var box:=tile.get_used_rect()
				valid=valid and box.has_area() and box.position.x>0 and box.position.y>0 and box.end.x<232 and box.end.y<232 and sprites[k].material is ShaderMaterial
			im.save_png(out+form+"_"+kind+".png")
			check(valid,form+" "+kind+": all native finished frames render inside padded cells")
	v.queue_free();await frames(4)
	TeamState.start([[0,0],[1,0]])
	TeamState.data["story"]={"met_crew":true,"guild_trial":true,"runner":true,"parcel":"delivered"}
	TeamState.data["rollcall_runs"]=0
	for id in ["hall","hall_low"]:
		var room:Node2D=load("res://scenes/town_room.tscn").instantiate()
		room.room_id=id;room.poll_input=false;root.add_child(room);await frames(12)
		var valid:bool=not room.cutscene
		for p in Crew.POSTS[id]:
			var found:Array=room.npcs.filter(func(e:Dictionary)->bool:return e.form==p[0])
			valid=valid and found.size()==1
			if found.size()==1:
				valid=valid and found[0].pos==p[1] and found[0].facing==p[2]
				valid=valid and found[0].sprite.texture.resource_path=="res://assets/sprites/arena/"+String(p[0])+"/town/"+String(p[2])+".png" and found[0].sprite.material is ShaderMaterial
		check(valid,id+": real crew posts/facings remain intact")
		var walks_ok:=true
		for p in Crew.POSTS[id]:
			if p[0] not in FORMS:continue
			var e:Dictionary=room.npcs.filter(func(n:Dictionary)->bool:return n.form==p[0])[0]
			var anchor:Vector2=e.sprite.position
			for facing in FACINGS:
				for k in 8:
					e.facing=facing;e.walk_t=1.0;e.walk_clock=(k+0.05)/room.WALK_FPS
					room._process(0.0)
					walks_ok=walks_ok and e.sprite.texture.resource_path=="res://assets/sprites/arena/"+String(p[0])+"/town/walk_"+String(facing)+"_f"+str(k)+".png" and e.sprite.position==anchor
				e.walk_t=0.0;e.facing=p[2];room._place(e)
		check(walks_ok,id+": room animation selects all eight frames/facings without moving sprite anchors")
		room.cam_focus=room._px(Vector2i(6,7) if id=="hall_low" else Vector2i(14,8))
		await frames(4)
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+id+".png")
		# Capture the real room's whole world layer for visual review, after logic checks.
		room.set_process(false)
		var room_view:SubViewport=room._world.get_parent()
		room_view.size=Vector2i(room.room().w*room.T,room.room().h*room.T)
		room._world.position=Vector2.ZERO
		await frames(3);await RenderingServer.frame_post_draw
		room_view.get_texture().get_image().save_png(out+id+"_whole.png")
		room.queue_free();await frames(6)
	# Autoload audio is released before quitting this owned fixture.
	for child in root.get_children():child.queue_free()
	await frames(16)
	print("CREW SELOUT ",checks-fails,"/",checks," PASS")
	quit(0 if fails==0 else 1)
