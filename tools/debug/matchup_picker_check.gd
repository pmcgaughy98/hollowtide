extends SceneTree
## Matchup picker check (Claude, 2026-10-07): opens the picker, saves a still of each step,
## picks Ironvent vs Scourmaw in 3v3, starts the fight and confirms the arena got it.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/matchup_picker_check.gd

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"

func _initialize() -> void:
	var picker: Node2D = load("res://scenes/move_preview.tscn").instantiate()
	root.add_child(picker)
	await process_frame
	await process_frame
	_save("picker_step1")
	picker._pick(3, 2)          # Ironvent
	await process_frame
	_save("picker_step2")
	picker._pick(2, 2)          # Scourmaw
	await process_frame
	picker._size = 3            # the picker's team size (renamed from _team_size in the 2026-10-09 rebuild)
	picker._build()
	await process_frame
	_save("picker_step3")
	picker.start_fight()
	for k in 40:
		await process_frame
	_save("picker_fight")
	var a: Node2D = picker._arena
	var names := []
	for f in a._fighters:
		names.append("%s(team %d)" % [f["name"], f["team"]])
	print("Picker: arena you=%d stage %d, rival=%d stage %d, team_size %d; fighters: %s" % [a._you, a._you_stage, a._rival, a._rival_stage, a.team_size, ", ".join(names)])
	# Escape returns to the picker.
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.physical_keycode = KEY_ESCAPE
	picker._unhandled_input(ev)
	await process_frame
	print("After Escape: arena %s, picker visible %s" % ["gone" if picker._arena == null else "still there", str(picker._ui.visible)])
	quit()


func _save(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return   # no frame to capture without a window
	root.get_texture().get_image().save_png(OUT + name + ".png")
