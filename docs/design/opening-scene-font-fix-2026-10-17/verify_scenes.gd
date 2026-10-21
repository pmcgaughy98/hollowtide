extends SceneTree
var passed := 0
const TeamState = preload("res://scripts/town/team_state.gd")
func _initialize() -> void:
	_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, good: bool) -> void:
	print("OPENING_FIX_CHECK ",label," -> ","ok" if good else "FAIL")
	if good:passed+=1
func _run() -> void:
	TeamState.save_path="user://opening-fix-check.save"
	var out=OS.get_environment("HT_OPENING_DIAG_OUT")
	DirAccess.make_dir_recursive_absolute(out)
	for name in ["opening_flow","creature_opening"]:
		var scene=load("res://scenes/"+name+".tscn")
		check(name+" PackedScene loads",scene is PackedScene)
		if scene==null:quit(1);return
		change_scene_to_packed(scene)
		await frames(15)
		var title=current_scene
		check(name+" script instantiates",title.get_script()!=null and title.has_method("_build_wordmark"))
		check(name+" wordmark built",title.get("_wordmark")!=null)
		var expected=3 if name=="opening_flow" else 4
		check(name+" menu buttons built",title.get("_buttons").size()==expected)
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out+"/"+name+".png")
		title._finish_boot()
		await frames(90)
		check(name+" prelude reaches menu",title.get("_boot_done")==true)
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out+"/"+name+"-menu.png")
		print("OPENED ",name)
	if current_scene!=null:current_scene.queue_free()
	await frames(3)
	var music=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(3)
	print("OPENING FIX: ",passed,"/10")
	quit(0 if passed==10 else 1)
