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
	var town: Node=load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town); current_scene=town
	await frames(6)
	var p: Node=town.get_node("GamePauseMenu")
	await click(p.hint); await click(p.content.get_node("Quit"))
	if not paused or p.page!="quit": quit(5); return
	await frames(4)
	root.get_texture().get_image().save_png("D:/dev/hollowtide-hall-door-20261010/review/leave-confirmation.png")
	print("PAUSE QUIT CONFIRMATION REACHED; sending real mouse confirmation")
	create_timer(3.0,true).timeout.connect(quit.bind(7))
	# Finish the fixture before Quit destroys its SceneTree: no suspended frame await.
	var at: Vector2 = p.content.get_node("ConfirmLeave").get_global_rect().get_center()
	for down in [true,false]:
		var e := InputEventMouseButton.new()
		e.button_index=MOUSE_BUTTON_LEFT; e.position=at; e.pressed=down
		Input.parse_input_event(e)
