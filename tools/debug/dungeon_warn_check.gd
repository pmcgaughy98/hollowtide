extends SceneTree
## Enemy warnings (Claude, 2026-10-09): a wild creature's dash, line or burst ability spends a
## turn gathering itself and marks its tiles; a leader who steps out is missed, one who stays is
## hit; basics stay instant; the autopilot steps out of marked tiles and still clears a floor.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_warn_check.gd
## Stills to docs/design/dungeon-warnings-2026-10-09/.

const OUT := "res://docs/design/dungeon-warnings-2026-10-09/"

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.real_time_battles = false   # this check tests the turn-based fight rules (2026-10-09: fights are real-time by default)
	dg.party = [[0, 0]]   # the leader alone, so no partner steps in
	root.add_child(dg)
	await _frames(4)
	var lead: Dictionary = dg.ents[0]
	# A room with space for a row of four tiles and a free tile beside the start of it.
	var spot := Vector2i.ZERO
	for room in dg.data["rooms"]:
		if room.size.x >= 6 and room.size.y >= 3:
			spot = room.position + Vector2i(1, 1)
			break
	dg.traps.clear()
	dg.floor_items.clear()
	# One wild Rimefin three tiles east; every other wild creature out of the way.
	var rim := -1
	for k in dg.ents.size():
		var e: Dictionary = dg.ents[k]
		if e["team"] == 1:
			e["pos"] = Vector2i(-50 - k, -50)
			e["awake"] = false
	var w: Dictionary = dg._make(2, 0, 1, spot + Vector2i(3, 0))
	w["awake"] = true
	w["facing"] = "w"
	dg.ents.append(w)
	rim = dg.ents.size() - 1
	lead["pos"] = spot
	dg._place(lead)
	dg._place(w)
	dg._reveal()
	var hp: int = lead["hp"]
	# 1. A rest: the Rimefin gathers its Lunge and marks the tiles.
	await dg.act_rest()
	var wound: Dictionary = w.get("windup", {})
	var marks: Array = wound.get("tiles", [])
	print("Wind-up: %s; marked tiles %s; the leader's tile is marked: %s; the leader took %d this turn" % [("gathering " + dg.Arena.MOVES[wound["m"]]["name"]) if not wound.is_empty() else "none (WRONG)", str(marks), str(lead["pos"] in marks), hp - lead["hp"]])
	await _frames(3)
	_save("warning")
	# 2. Step out of the line: the Lunge lands on nobody.
	await dg.act_move(Vector2i(0, 1))
	print("Stepped aside: the leader took %d; misses so far %d; the Rimefin ran to %s" % [hp - lead["hp"], dg.dodged, str(w["pos"] - spot)])
	# 3. Again, standing still: the Lunge hits.
	w["pos"] = spot + Vector2i(3, 1)
	w["cds"]["lunge"] = 0
	w.erase("windup")
	dg._place(w)
	await dg.act_rest()
	var gathered: bool = w.has("windup")
	hp = lead["hp"]
	await dg.act_rest()
	print("Stood still: gathered %s, then the leader took %d" % [str(gathered), hp - lead["hp"]])
	_save("hit")
	# 4. A basic up close stays instant.
	w["pos"] = lead["pos"] + Vector2i(1, 0)
	w["cds"]["lunge"] = 9
	w.erase("windup")
	dg._place(w)
	hp = lead["hp"]
	await dg.act_rest()
	print("Adjacent basic: wind-up %s; the leader took %d the same turn" % ["none" if not w.has("windup") else "set (WRONG)", hp - lead["hp"]])
	# 5. The autopilot with warnings on a fresh floor and the usual team.
	dg.party = [[0, 0], [1, 0]]
	dg.floor_seed = 99
	dg._build_floor(true)
	await _frames(3)
	dg.dodged = 0
	dg.autopilot = true
	var frames := 0
	var gathered_n := 0
	var seen := 0
	while dg.floor_n == 1 and frames < 30 * 240:
		await process_frame
		frames += 1
		while seen < dg.log_lines.size():
			if "is gathering itself" in dg.log_lines[seen]:
				gathered_n += 1
			seen += 1
		if seen > 38:
			seen = dg.log_lines.size()
	print("Autopilot: %s after %d turns, %d faints; wind-ups seen %d, of which landed on nobody %d" % ["reached B2F" if dg.floor_n > 1 else "stuck (WRONG)", dg.turn, dg.faints, gathered_n, dg.dodged])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
