extends SceneTree
const W := "D:/dev/hollowtide-canvaswing-walk-20261022"
const TeamState = preload("res://scripts/town/team_state.gd")
var good := 0
var total := 0
var stage := "candidate"
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, passed: bool) -> void:
	total+=1
	if passed:good+=1
	print("WALK_CHECK ",label," -> ","ok" if passed else "FAIL")
func texture(set_name: String, facing: String, frame: int) -> Texture2D:
	var relative="assets/sprites/arena/canvaswing/%s/walk_%s_f%d.png"%[set_name,facing,frame]
	if stage=="live":return load("res://"+relative)
	return ImageTexture.create_from_image(Image.load_from_file(W+"/project/"+relative))
func _run() -> void:
	stage=OS.get_environment("HT_WALK_STAGE")
	TeamState.save_path="user://canvaswing-walk-check.save"
	root.size=Vector2i(1152,648)
	root.content_scale_size=Vector2i(1152,648)
	var scene=Node2D.new();root.add_child(scene)
	var bg=ColorRect.new();bg.size=Vector2(1152,648);bg.color=Color(0.145,0.17,0.15);scene.add_child(bg)
	var sprite_list=[]
	var row:=0
	for set_name in ["dungeon","town","small"]:
		for facing in ["se","sw"]:
			var label=Label.new();label.text=set_name+" "+facing;label.position=Vector2(8,38+row*100);scene.add_child(label)
			for i in 8:
				var tex=texture(set_name,facing,i);var img=tex.get_image();var used=img.get_used_rect()
				var expected=Image.load_from_file(W+"/project/assets/sprites/arena/canvaswing/%s/walk_%s_f%d.png"%[set_name,facing,i]);img.convert(Image.FORMAT_RGBA8);expected.convert(Image.FORMAT_RGBA8)
				check("%s %s f%d exact pixels, body and margin"%[set_name,facing,i],img.get_data()==expected.get_data() and used.has_area() and used.position.x>0 and used.position.y>0 and used.end.x<img.get_width() and used.end.y<img.get_height())
				var sp=Sprite2D.new();sp.texture=tex;sp.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;sp.scale=Vector2(1.35,1.35);sp.position=Vector2(180+i*128,45+row*100);scene.add_child(sp)
				preload("res://scripts/arena/creature_finish.gd").apply(sp)
				sprite_list.append(sp)
			row+=1
	await frames(5);await RenderingServer.frame_post_draw
	var out=W+"/native-"+stage;DirAccess.make_dir_recursive_absolute(out);root.get_texture().get_image().save_png(out+"/sets.png")
	scene.queue_free();await frames(3)
	var dungeon=load("res://scenes/dungeon.tscn").instantiate();dungeon.poll_input=false;dungeon.floor_seed=23;dungeon.dungeon="first";root.add_child(dungeon);await frames(4);dungeon.set_process(false)
	var actor: Dictionary=dungeon._make(8,0,1,dungeon.ents[0]["pos"]+Vector2i(1,0));dungeon.ents.append(actor);actor["node"].position=dungeon.ents[0]["node"].position+Vector2(24,0)
	if stage!="live":
		for facing in ["se","sw"]:
			for i in 8:
				var tex=texture("dungeon",facing,i);actor["art"]["walk"][facing][i]=tex;actor["art"]["foot"][tex]=dungeon._foot_row(tex)
	for facing in ["se","sw"]:
		actor["facing"]=facing
		for parity in 2:
			dungeon.turn=parity
			for i in 4:
				actor["walk_len"]=dungeon.STEP_TIME;actor["walk_t"]=dungeon.STEP_TIME*(1.0-(i+0.25)/4.0)
				dungeon._process(0.0)
				check("real dungeon %s turn%d quarter%d selects f%d"%[facing,parity,i,i+parity*4],actor["sprite"].texture==actor["art"]["walk"][facing][i+parity*4])
	dungeon._banner["at"]=-100000;actor["walk_t"]=0.0;dungeon._process(0.0);await frames(2);await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/rootbank-actor.png")
	dungeon.queue_free();await frames(4);var music=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(4)
	print("CANVASWING WALK: ",good,"/",total)
	quit(0 if good==total else 1)
