extends SceneTree
const OUT="D:/dev/hollowtide-village-light-20261009/"
var checks:Array[Dictionary]=[]
var failed:Array[String]=[]
func _initialize() -> void:call_deferred("run")
func check(s:String,ok:bool) -> void:
	checks.append({"check":s,"passed":ok})
	if not ok:failed.append(s)
	print(s,": ",ok)
func frames(n:int) -> void:
	for i in n:await process_frame
func shot(name:String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
func run() -> void:
	root.size=Vector2i(1152,648)
	var menu:Node2D=load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(menu);current_scene=menu
	await frames(3);menu._finish_boot();await frames(40)
	check("Dedicated Punchybun and Cinderhide actors",menu.companions.size()==2 and menu.companions[0].name=="PunchybunVillageAnimation" and menu.companions[1].name=="CinderhideVillageAnimation")
	check("Both wear shared creature finish",menu.companions[0].material!=null and menu.companions[1].material!=null)
	var base:Array=[]
	for actor in menu.companions:
		base.append(actor.position)
		check(actor.name+" loads eight menu frames",actor.frames.size()==8)
	var seen=[{},{}]
	DirAccess.make_dir_recursive_absolute(OUT+"capture")
	for sample in 90:
		await frames(6)
		for i in menu.companions.size():
			var actor:Sprite2D=menu.companions[i]
			seen[i][actor.texture.resource_path]=true
			if actor.position!=base[i]:failed.append("Ground anchor drift "+actor.name)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT+"capture/frame_%03d.png"%sample)
	check("Both real loops reach all eight frames",seen[0].size()==8 and seen[1].size()==8)
	check("Shared canvas anchors do not drift",failed.filter(func(s:String):return s.begins_with("Ground anchor drift")).is_empty())
	menu._reduce_motion=true;await frames(2)
	var frozen:Array=[]
	for actor in menu.companions:frozen.append([actor.position,actor.texture])
	var clock:float=menu._time
	await frames(30)
	check("Reduce Motion freezes both actors and clock",menu._time==clock and menu.companions[0].position==frozen[0][0] and menu.companions[0].texture==frozen[0][1] and menu.companions[1].texture==frozen[1][1])
	await shot("title")
	menu._reduce_motion=false;await frames(35)
	check("Animation resumes",menu._time>clock)
	menu._on_options();await frames(3);await shot("options")
	menu._close_panel();await frames(2)
	menu._on_new_game();await frames(45)
	check("New Game still enters the awakening",current_scene.has_method("choose"))
	current_scene.queue_free();await frames(3)
	var f:=FileAccess.open(OUT+"animation-checks.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"checks":checks,"failures":failed},"  "));f.close()
	print("RESULT ",checks.size()," checks / ",failed.size()," failures")
	quit(0 if failed.is_empty() else 1)
