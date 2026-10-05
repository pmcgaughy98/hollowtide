extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/area-transition-review/"
var checks: Array=[]
func _initialize()->void:call_deferred("_run")
func frames(n:int)->void:
	for i in n:await process_frame
func key(code:Key)->void:
	for pressed in [true,false]:
		var e:=InputEventKey.new()
		e.keycode=code;e.physical_keycode=code;e.pressed=pressed
		Input.parse_input_event(e);await frames(3)
func click(at:Vector2)->void:
	for pressed in [true,false]:
		var e:=InputEventMouseButton.new()
		e.position=at;e.global_position=at;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=pressed
		Input.parse_input_event(e);await frames(3)
func _run()->void:
	for model in ["Male","Female"]:
		var menu:Node2D=load("res://scenes/main_menu_art_preview.tscn").instantiate()
		# Fixture suppresses preference writes; actual menu flow and scenery are inherited.
		menu.set_script(load(OUT+"menu_preview_noprefs.gd"))
		root.add_child(menu);current_scene=menu
		for i in 600:
			if menu.get("_route_scene")!=null:break
			await process_frame
		await frames(12)
		await key(KEY_ENTER)
		var index:=0 if model=="Male" else 1
		var button:Button=menu.get("_courier_buttons")[index]
		await click(button.get_global_rect().get_center())
		var selected:bool=menu.get("_selected_courier")==model and button.button_pressed and not menu.get("_courier_buttons")[1-index].button_pressed
		await key(KEY_DOWN);await key(KEY_ENTER)
		await frames(180)
		var okay:bool=current_scene!=null and current_scene.name=="WorldJourney" and current_scene.get("active_id")=="hometown"
		if okay:
			var player:Node=current_scene.get("active_area").get_node("Player")
			okay=selected and player.chibi_model==model and player.position==Vector2(224,280)
		checks.append({"model":model,"selection_exclusive":selected,"new_game_hometown":okay,"preference_writes_suppressed_in_fixture":true})
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT+"menu-to-hometown-"+model.to_lower()+".png")
		print("MENU_TO_HOMETOWN ",model," ",okay)
		current_scene.queue_free();current_scene=null;menu=null
		await frames(12)
	var file:=FileAccess.open(OUT+"menu-entry.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(checks,"\t"));file.close();file=null
	quit(0 if checks.all(func(c:Dictionary)->bool:return c.new_game_hometown) else 1)
