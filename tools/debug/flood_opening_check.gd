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
const OUT := "res://docs/design/flood-opening-2026-10-10/"
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
	_ok("The road to Highbank is under water during the flood (%s)" % bank.line.contains("water"), bank.line.contains("water") and not bank.leaving)

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

	# 3. The last floor's stairs lead down into the Warden's pond garden, and the garden's stairs clear it, no boss
	# (2026-10-28, docs/design/mouth-garden-2026-10-28/PLAN.md slice 1).
	if dg != null and dg.get("dungeon") == "mouth":
		dg.return_to_town = false   # stay here so the check can read the result
		# Halfway across B2F the flood catches up and washes the team down to B4F (slice 3). The leader is set on the
		# stairs (no walk left at all) and rests one turn.
		dg.floor_n = dg.SWEEP_FLOOR
		dg._build_floor(false)
		_ok("B2F waits for the flood (the walk across is %d steps)" % dg._sweep_from, dg._sweep_from > 0)
		dg.ents[0]["pos"] = dg.data["stairs"]
		dg._place(dg.ents[0])
		dg.act_rest()
		var saw3 := false
		var dazed := false
		for k in 1500:
			await process_frame
			saw3 = saw3 or dg.floor_n == 3
			dazed = dazed or dg.intro.get("dazed", false)
			if not dg.talk.is_empty() and k % 2 == 0:
				dg.talk.pop_front()
			if dg.story.get("swept", false) and dg.floor_n == dg.SWEEP_TO and not dg.cutscene and not dg.busy and dg.talk.is_empty():
				break
		_ok("The flood sweeps the team from B2F down to B4F, past B3F (floor %d, B3F seen %s, swept %s, dazed on arrival %s, free to move %s)" % [dg.floor_n, str(saw3), str(dg.story.get("swept", false)), str(dazed), str(not dg.cutscene and not dg.busy)],
			dg.floor_n == 4 and not saw3 and dg.story.get("swept", false) and dazed and not dg.cutscene and not dg.busy)
		dg.floor_n = dg.floors()
		dg.ents[0]["pos"] = dg.data["stairs"]
		dg._place(dg.ents[0])
		dg.act_stairs()
		var t_down := Time.get_ticks_msec()
		while (dg.floor_kind() != "garden" or dg.busy) and Time.get_ticks_msec() - t_down < 8000:
			await process_frame
		_ok("The last floor's stairs lead down into the garden (floor kind %s, pond %s)" % [dg.floor_kind(), str(dg.pond.size)],
			dg.floor_kind() == "garden" and dg.pond.size != Vector2i.ZERO)
		var wilds: int = dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] != 0).size()
		_ok("The garden holds no wild creatures (%d) and the parcel beat waits for its way out (parcel '%s')" % [wilds, dg.story.get("parcel", "")],
			wilds == 0 and dg.story.get("parcel", "") == "")
		await _read_through(dg)
		_ok("The team finds the garden in its own scene (garden_found %s)" % str(dg.story.get("garden_found", false)), dg.story.get("garden_found", false))
		dg.ents[0]["pos"] = dg.data["stairs"]
		dg._place(dg.ents[0])
		dg.act_stairs()   # the garden's way out talks first (the rumble, the parcel); read through it
		await _read_through(dg)
		_ok("At the way out the partner shows the parcel (story parcel %s)" % dg.story.get("parcel", ""), dg.story.get("parcel", "") == "saved")
		var t1 := Time.get_ticks_msec()
		var eyes_peak := 0.0
		var shadow_peak := 0.0
		var lights_out := false   # read while it plays: the clear resets the scene's state
		while not "mouth" in dg.beaten and Time.get_ticks_msec() - t1 < 40000:
			await process_frame
			eyes_peak = maxf(eyes_peak, float(dg.intro.get("eyes", 0.0)))
			shadow_peak = maxf(shadow_peak, float(dg.intro.get("pond_shadow", 0.0)))
			lights_out = lights_out or dg.intro.has("lights_out_at")
		_ok("After they leave, the Warden's eyes open under the pond (eyes peak %.2f, shadow peak %.2f, fireflies out %s, once %s)" % [eyes_peak, shadow_peak, str(lights_out), str(dg.story.get("garden_eyes", false))],
			eyes_peak > 0.95 and shadow_peak > 0.8 and lights_out and dg.story.get("garden_eyes", false))
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
	quit(1 if fails else 0)


## Read a scene through: one line a frame until the scene lets go.
func _read_through(dg) -> void:
	for k in 400:
		await process_frame
		if not dg.talk.is_empty():
			dg.talk.pop_front()
		if not dg.cutscene and dg.talk.is_empty() and k > 5:
			break
