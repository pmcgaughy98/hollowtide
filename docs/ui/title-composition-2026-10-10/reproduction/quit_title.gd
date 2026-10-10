extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await process_frame
func click(b: Control) -> void:
	var at:=b.get_global_rect().get_center()
	for down in [true,false]:
		var e:=InputEventMouseButton.new(); e.button_index=MOUSE_BUTTON_LEFT; e.position=at; e.pressed=down
		Input.parse_input_event(e); await frames(2)
func run() -> void:
	root.size=Vector2i(1152,648)
	var menu: Node=load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(menu); current_scene=menu
	# Wait for the actual launch reveal, rather than racing a fixed frame count.
	for i in 120:
		if menu._boot_done:break
		await frames(1)
	if not menu._boot_done:quit(6);return
	await frames(6)
	await click(menu._buttons[2])
	if menu._page!="quit": quit(5); return
	print("TITLE QUIT CONFIRMATION REACHED; sending real mouse confirmation")
	create_timer(3.0,true).timeout.connect(quit.bind(7))
	# Finish the fixture before Quit destroys its SceneTree: no suspended frame await.
	var at: Vector2 = menu._quit_controls[1].get_global_rect().get_center()
	for down in [true,false]:
		var e := InputEventMouseButton.new()
		e.button_index=MOUSE_BUTTON_LEFT; e.position=at; e.pressed=down
		Input.parse_input_event(e)
