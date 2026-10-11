extends SceneTree
const W="D:/dev/hollowtide-waking-art-20261010/"
const State=preload("res://scripts/town/team_state.gd")
const Bank=preload("res://scripts/ui/waking_bank.gd")
const Finish=preload("res://scripts/ui/hollow_entrance_finish.gd")
var out:=W+"review/after/"
var bad:=0
var count:=0
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func check(ok:bool,text:String)->void:
	count+=1
	if not ok:bad+=1
	print("PASS " if ok else "FAIL ",text)
func hold(code:Key,n:int)->void:
	var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=true
	Input.parse_input_event(e);await frames(n)
	e=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=false
	Input.parse_input_event(e);await frames(3)
func shot(name:String)->void:
	await frames(6);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out+name+".png")
func run()->void:
	root.size=Vector2i(1152,648);root.grab_focus()
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	State.start([[1,0],[2,0]],{"creature_player":"tallowroot","opening_companion":"rimefin"})
	State.data["bag"]={"lamp_oil":2};State.data["iq"]={2:7}
	var snapshot:=State.data.duplicate(true)
	var scene:Node=load("res://scenes/waking_riverbank.tscn").instantiate();State.give_to(scene);scene.reduce_motion=true
	change_scene_to_node(scene);await frames(10)
	check(scene.actors.size()==2 and scene.party==[[1,0],[2,0]],"bank receives chosen team")
	check(scene.actors[0].position==Vector2(168,83) and scene.actors[1].position==Vector2(222,84),"original framing and foot anchors retained")
	check(scene.actors[0].scale==Vector2.ONE and scene.bank.clock==0.0,"sprite size and Reduce Motion retained")
	check(not scene.walkable(Vector2(80,40)) and scene.walkable(Vector2(240,82)),"river blocked; stone approach reachable")
	await shot("bank-exploration")
	await hold(KEY_RIGHT,48)
	check(current_scene.scene_file_path.ends_with("hollow_entrance.tscn"),"actual walking reaches walkway node and opens close-up immediately")
	scene=current_scene
	if not scene.entrance:quit(1);return
	check(scene.party==[[1,0],[2,0]] and scene.reduce_motion,"team and preference carry into entrance")
	check(scene.actors[0].material is ShaderMaterial and scene.actors[0].scale==Vector2.ONE,"close-up retains installed creature finish and size")
	check(not scene.walkable(Vector2(50,140)) and not scene.walkable(Vector2(130,95)) and scene.walkable(Vector2(192,118)),"water/facade blocked; arch approach walkable")
	await shot("entrance-exploration")
	await hold(KEY_LEFT,5);await hold(KEY_UP,39)
	check(scene.denied and current_scene==scene and scene.status.text.contains("Highbank"),"first visit retains Highbank story order without entering Warden dungeon")
	await shot("entrance-first-visit")
	check(State.data==snapshot,"exploration and blocked arch do not change team record")
	await hold(KEY_ESCAPE,1)
	check(current_scene.scene_file_path.ends_with("waking_riverbank.tscn") and current_scene.from_entrance,"Escape returns beside walkway without portal loop")
	await frames(30)
	check(current_scene.scene_file_path.ends_with("waking_riverbank.tscn"),"return spawn stays outside auto-entry trigger")
	await hold(KEY_H,1);await frames(10)
	check(current_scene.scene_file_path.ends_with("hub_town.tscn") and current_scene.party==[[1,0],[2,0]],"Highbank continuation retains chosen team")
	check(State.data.get("bag",{}).get("lamp_oil",0)==2 and State.data.get("iq",{}).get(2,0)==7,"inventory and IQ survive scenery route")
	# Facade GPU finish is bounded to the geometry mask; highlights and alpha stay exact.
	var img:=Bank.detailed_image("res://assets/sprites/world/waking_bank_2026_10_10/entrance_native.png")
	check(img!=null and img.get_size()==Vector2i(384,216),"entrance native asset exact canvas")
	var vp:=SubViewport.new();vp.size=Vector2i(384,216);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var sprite:=Sprite2D.new();sprite.centered=false;sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture=ImageTexture.create_from_image(img);vp.add_child(sprite);await frames(6);await RenderingServer.frame_post_draw
	var plain:=vp.get_texture().get_image()
	sprite.texture=ImageTexture.create_from_image(Finish.finished_image(img));Finish.apply(sprite,img)
	await frames(6);await RenderingServer.frame_post_draw
	var finished:=vp.get_texture().get_image();var mask:=Finish.mask(img)
	var outside:=0;var changed:=0;var alpha:=true;var bright:=true
	for y in 216:
		for x in 384:
			var a:=plain.get_pixel(x,y);var b:=finished.get_pixel(x,y)
			if a.a!=b.a:alpha=false
			if a!=b:
				changed+=1
				if mask.get_pixel(x,y).r<0.5:outside+=1
				if img.get_pixel(x,y).get_luminance()>0.68:bright=false
	check(outside==0 and changed>0,"close-up material finish bounded: %d changed, %d outside mask"%[changed,outside])
	check(alpha and bright,"entrance alpha and glowing/highlight pixels exact")
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("JOURNEY ",count-bad,"/",count," PASS");quit(0 if bad==0 else 1)
