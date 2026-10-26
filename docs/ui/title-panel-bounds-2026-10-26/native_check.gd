extends SceneTree
const W := "D:/dev/hollowtide-title-bounds-20261026"
const Team := preload("res://scripts/town/team_state.gd")
var stage := "before"
var failures := 0
var total := 0
var measured := {}

func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for i in n: await process_frame
func check(label: String, passed: bool) -> void:
	total+=1
	if not passed: failures+=1
	print("TITLE_BOUNDS ",label," -> ","ok" if passed else "FAIL")
func bounds(key: String, panel: Control, bottom := 636.0) -> void:
	var r := panel.get_global_rect()
	measured[key]={"x":r.position.x,"y":r.position.y,"width":r.size.x,"height":r.size.y,"right":r.end.x,"bottom":r.end.y}
	print("TITLE_RECT ",key," ",r)
	check(key+" full frame inside safe screen", r.position.x>=16 and r.position.y>=0 and r.end.x<=1136 and r.end.y<=bottom)
func snap(key: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"/native-"+stage+"/"+key+".png")

func _run() -> void:
	stage=OS.get_environment("HT_TITLE_STAGE")
	root.size=Vector2i(1152,648)
	root.content_scale_size=Vector2i(1152,648)
	Team.save_path="user://title-bounds-private.save"
	DirAccess.make_dir_recursive_absolute(W+"/native-"+stage)
	var scenes=["creature_opening","opening_flow"] if stage=="before" else (["opening_flow"] if stage=="legacy" else ["creature_opening"])
	for scene in scenes:
		var title=load("res://scenes/"+scene+".tscn").instantiate()
		root.add_child(title)
		var waited:=0
		while not (title._boot_done and title._page=="main") and waited<300:
			await process_frame
			waited+=1
		check(scene+" reaches main menu",title._boot_done and title._page=="main")
		# The legacy opening still preloads its retired route. Let that worker finish before freeing the menu.
		if scene=="opening_flow":
			var loading:=0
			while ResourceLoader.load_threaded_get_status(title.FIRST_SCENE)==ResourceLoader.THREAD_LOAD_IN_PROGRESS and loading<900:
				await process_frame
				loading+=1
			title._poll_route()
		title._buttons.filter(func(b):return b.name=="Options")[0].pressed.emit()
		await frames(5)
		bounds(scene+"-options",title._options_panel)
		check(scene+" options focus visible",title._options_panel.is_visible_in_tree() and title._options_controls.has(root.gui_get_focus_owner()))
		await snap(scene+"-options")
		title._close_panel()
		await frames(3)
		if scene=="creature_opening":
			title._help_button.pressed.emit()
			await frames(3)
			for i in 2:
				title._help_controls[i].pressed.emit()
				await frames(5)
				var topic="journey" if i==0 else "controls"
				bounds(scene+"-help-"+topic,title._help_panel)
				for j in [2,3]:
					var button: Control=title._help_controls[j]
					check(topic+" action "+button.name+" inside frame",title._help_panel.get_global_rect().encloses(button.get_global_rect()))
				await snap(scene+"-help-"+topic)
			title._close_panel()
			await frames(3)
		title._buttons.filter(func(b):return b.name=="Quit")[0].pressed.emit()
		await frames(5)
		bounds(scene+"-quit",title._quit_panel)
		var heading: Control=title._quit_panel.get_node("Choices").get_child(0)
		check(scene+" quit question fully inside viewport",Rect2(16,0,1120,636).encloses(heading.get_global_rect()))
		await snap(scene+"-quit")
		title._quit_controls[0].pressed.emit()
		await frames(4)
		check(scene+" cancel returns to main",title._page=="main" and title._main_panel.visible and not title._quit_panel.visible)
		title.queue_free()
		await frames(4)
	var music=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(3)
	var f=FileAccess.open(W+"/measurements-"+stage+".json",FileAccess.WRITE)
	f.store_string(JSON.stringify(measured,"\t"));f.close()
	print("TITLE BOUNDS: ",total-failures,"/",total)
	quit(0 if stage=="before" or failures==0 else 1)
