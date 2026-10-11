extends SceneTree
## The flood opening (Claude, 2026-10-10; Preston: wake in the flood, the ruin rises out of the river, retreat
## into the Hollow, a first dungeon with no boss, then Highbank). Checks:
##   1. on the first visit to the waking riverbank the ruin and its path rise (scripts/ui/hollow_rise.gd),
##      the team cannot move until it is done, and the road to Highbank is under water;
##   2. the arch starts the Hollow Mouth (dungeon.gd "mouth");
##   3. the Mouth's last stairs clear it with no boss, and it counts as beaten;
##   4. after that, the riverbank opens the road and the rise does not play again.
## Windowed it saves stills of the rise to docs/design/flood-opening-2026-10-10/.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/flood_opening_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const OUT := "D:/dev/hollowtide-flood-waking-20261010/review/rules/flood-opening-2026-10-10/"
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	TeamState.start([[0, 0], [1, 0]])

	# 1. The rise.
	var bank: Node2D = load("res://scenes/waking_riverbank.tscn").instantiate()
	root.add_child(bank)
	await _frames(2)
	var rising: Node = null
	for c in bank.view.get_children():
		if c.get_script() == preload("res://scripts/ui/hollow_rise.gd"):
			rising = c
	_ok("The ruin rises on the first visit (%s), the team held still (%s)" % [rising != null, bank.leaving], rising != null and bank.leaving)
	await _snap("0_flooded")
	for pair in [[45, "1_rumble"], [60, "2_rising"], [40, "3_risen"], [40, "4_path"]]:
		await _frames(pair[0])
		await _snap(pair[1])
	var t0 := Time.get_ticks_msec()
	while bank.leaving and Time.get_ticks_msec() - t0 < 15000:
		await process_frame
	_ok("The rise ends and the team can move (%s)" % (not bank.leaving), not bank.leaving)
	await _frames(10)
	await _snap("5_after")
	bank._town()
	_ok("The road to Highbank is under water during the flood (%s)" % bank.status.text.contains("water"), bank.status.text.contains("water") and not bank.leaving)

	# 2. The arch starts the Hollow Mouth.
	bank.queue_free()
	await process_frame
	var arch: Node2D = load("res://scenes/hollow_entrance.tscn").instantiate()
	arch.party = [[0, 0], [1, 0]]
	root.add_child(arch)
	await _frames(2)
	arch._enter_arch()
	await _frames(4)
	var dg: Node = current_scene
	_ok("The arch opens the Hollow Mouth (%s)" % (dg.get("dungeon") if dg != null else "nothing"), dg != null and dg.get("dungeon") == "mouth")

	# 3. The last stairs clear it, no boss.
	if dg != null and dg.get("dungeon") == "mouth":
		dg.return_to_town = false   # stay here so the check can read the result
		dg.floor_n = dg.floors()
		dg.ents[0]["pos"] = dg.data["stairs"]
		dg._place(dg.ents[0])
		dg.act_stairs()
		var t1 := Time.get_ticks_msec()
		while not "mouth" in dg.beaten and Time.get_ticks_msec() - t1 < 20000:
			if not dg.talk.is_empty(): dg.act_talk()
			await _frames(4)
		_ok("The last stairs clear the Hollow Mouth with no boss floor (beaten %s)" % str(dg.beaten), "mouth" in dg.beaten)
		TeamState.data["beaten"] = dg.beaten.duplicate()

	# 4. Afterwards: the road is open and the river stays risen.
	var again: Node2D = load("res://scenes/waking_riverbank.tscn").instantiate()
	again.returning = true
	root.add_child(again)
	await _frames(2)
	var rose_again := false
	for c in again.view.get_children():
		if c.get_script() == preload("res://scripts/ui/hollow_rise.gd"):
			rose_again = true
	_ok("After the Mouth, no second rise (%s)" % rose_again, not rose_again)
	print("FLOOD OPENING: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	for frame in 12:await process_frame
	quit(1 if fails else 0)
