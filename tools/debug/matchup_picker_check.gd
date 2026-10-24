extends SceneTree
## Matchup picker check (Claude, 2026-10-07): opens the picker, saves a still of each step,
## picks Ironvent vs Scourmaw in 3v3, starts the fight and confirms the arena got it.
## Judged since Claude, 2026-10-24 (H26): the arena's lines, stages, team size and fighter
## count, and Escape returning to the picker.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/matchup_picker_check.gd

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var fails := 0

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
	_ok("The arena got Ironvent (line 3, stage 2) against Scourmaw (line 2, stage 2)", a._you == 3 and a._you_stage == 2 and a._rival == 2 and a._rival_stage == 2)
	_ok("The arena runs a 3v3 with 6 fighters", a.team_size == 3 and a._fighters.size() == 6)
	# Escape returns to the picker.
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.physical_keycode = KEY_ESCAPE
	picker._unhandled_input(ev)
	await process_frame
	print("After Escape: arena %s, picker visible %s" % ["gone" if picker._arena == null else "still there", str(picker._ui.visible)])
	_ok("Escape drops the arena and shows the picker again", picker._arena == null and picker._ui.visible)
	print("MATCHUP PICKER: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails > 0 else 0)


## One judged line: "what -> ok" or "what -> FAIL" (Claude, 2026-10-24).
func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _save(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return   # no frame to capture without a window
	root.get_texture().get_image().save_png(OUT + name + ".png")
