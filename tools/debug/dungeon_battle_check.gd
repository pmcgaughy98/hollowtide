extends SceneTree
## The hybrid (Claude, 2026-10-09, Preston: "keep the movement turns for encounters, then when the
## battle starts it's kind of arena style"): a wild creature awake and in sight within reach starts
## a real-time battle on the same floor, from the same tiles and health; when it's won everyone is
## back on the grid with what they kept and the turn and lantern have moved on; running far ends
## it with the foe still there; a floor on autopilot goes from fight to fight down the stairs.
## Preston turned the hybrid off the same night (real_time_battles false: dungeon fights stay turn-based).
## With it off the check judges the turn-based floor (Claude, 2026-10-24, H02): a wild in sight does not
## open the arena, the exchange spends turns, everyone ends on open floor with no shared tile, the
## autopilot reaches B2F, and no arena battle ever starts. The hybrid's own steps run only with it on.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_battle_check.gd
## Stills to docs/design/dungeon-hybrid-2026-10-09/ (with a window and the hybrid on).

const OUT := "res://docs/design/dungeon-hybrid-2026-10-09/"
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _run() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 1], [1, 1]]   # Sparkwick and Huskward
	root.add_child(dg)
	await _frames(4)
	var lead: Dictionary = dg.ents[0]
	dg.traps.clear()
	# A wild Rimefin awake four tiles off, in the leader's room; the rest asleep far away.
	var spot := Vector2i.ZERO
	for room in dg.data["rooms"]:
		if room.size.x >= 7 and room.size.y >= 3:
			spot = room.position + Vector2i(1, 1)
			break
	for e in dg.ents:
		if e["team"] == 1:
			e["pos"] = Vector2i(-60, -60)
			e["awake"] = false
	lead["pos"] = spot
	dg.ents[1]["pos"] = spot + Vector2i(0, 1)
	var w: Dictionary = dg._make(2, 0, 1, spot + Vector2i(4, 0))
	w["awake"] = true
	dg.ents.append(w)
	for e in dg.ents:
		dg._place(e)
	dg._reveal()
	lead["hp"] = lead["max_hp"] - 10
	var t0: int = dg.turn
	var light0: float = dg.light
	# 1. A rest with the wild in sight: with the hybrid on, the battle starts.
	dg.autopilot = true   # the arena plays your side too, for the check (turn-based: the dungeon's autopilot)
	await dg.act_rest()
	for k in 30:   # the battle starts on the next frame; measure it before anyone moves
		await process_frame
		if dg._battle != null and not dg._battle._fighters.is_empty():
			break
	var b: Node2D = dg._battle
	var started: bool = dg.in_battle and b != null
	if dg.real_time_battles:
		var names := []
		var px_ok := true
		var frac_ok := true
		if started:
			for n in b._fighters.size():
				var f: Dictionary = b._fighters[n]
				var e: Dictionary = dg.ents[dg._battle_ids[n]]
				names.append("%s:%s" % ["you" if f["team"] == 0 else "wild", f["name"]])
				px_ok = px_ok and f["body"].position.distance_to(dg._tile_px(e["pos"])) < 1.0
				frac_ok = frac_ok and absf(float(f["hp"]) / f["max_hp"] - float(e["hp"]) / e["max_hp"]) < 0.02
		print("Battle start: %s; fighters %s; each where its tile is: %s; each with its health share: %s; the dungeon screen hidden: %s" % [str(started), str(names), str(px_ok), str(frac_ok), str(not dg._screen.visible)])
		_save("battle_start")
	else:
		_ok("Turn-based: a wild in sight does not open the arena (in battle %s, arena battles %d)" % [started, dg.battles], not started and dg.battles == 0)
	# 2. Let it play out (the arena's AI plays both sides; turn-based, the autopilot fights on the grid).
	var frames := 0
	var shot := false
	if dg.real_time_battles:
		while dg.in_battle and frames < 30 * 90:
			await process_frame
			frames += 1
			if not shot and frames == 120:
				shot = true
				_save("battle_mid")
	else:
		# Until the Rimefin is down, 20 s, or the autopilot takes the stairs (part 4 starts its own floor).
		while w["hp"] > 0 and dg.floor_n == 1 and dg.faints == 0 and frames < 30 * 20:
			await process_frame
			frames += 1
		dg.autopilot = false
		while dg.busy:
			await process_frame
		await _frames(2)
	var seen := {}
	var overlap := false
	var on_floor := true
	for e in dg.ents:
		if e["hp"] > 0 and e["pos"].x >= 0:   # the parked wild creatures off the map do not count
			overlap = overlap or seen.has(e["pos"])
			seen[e["pos"]] = true
			on_floor = on_floor and dg._floor_at(e["pos"])
	print("Battle end after %.0f s: %s; Rimefin HP %d; team %s; back on the grid: on open floor %s, no two on a tile %s; turns %d -> %d; lantern %d -> %d" % [frames / 30.0, dg.log_lines[-1] if not dg.log_lines.is_empty() else "", w["hp"], _team(dg), str(on_floor), str(not overlap), t0, dg.turn, int(light0), int(dg.light)])
	if not dg.real_time_battles:
		_ok("Turn-based: the exchange spent turns (%d -> %d)" % [t0, dg.turn], dg.turn > t0)
		_ok("Turn-based: everyone is on open floor (%s) and no two share a tile (%s)" % [on_floor, not overlap], on_floor and not overlap)
	await _frames(3)
	if dg.real_time_battles:
		_save("battle_after")
	# 3. Running away: a second Rimefin, then the leader carried far off inside the battle. A hybrid step only.
	dg.autopilot = false
	if dg.real_time_battles:
		var w2: Dictionary = dg._make(2, 0, 1, lead["pos"] + Vector2i(3, 0))
		if not dg._floor_at(w2["pos"]):
			w2["pos"] = lead["pos"] + Vector2i(0, 3)
		w2["awake"] = true
		dg.ents.append(w2)
		dg._place(w2)
		if dg.asking >= 0:
			dg.act_recruit(false)
		await dg.act_rest()
		await _frames(6)
		var b2: Node2D = dg._battle
		if b2 != null:
			var far_tile: Vector2i = dg.data["stairs"]
			b2._fighters[0]["body"].position = dg._tile_px(far_tile)
			for f in b2._fighters:
				if f["team"] == 1:
					f["stun"] = 60.0
			var waited := 0
			while dg.in_battle and waited < 30 * 5:
				await process_frame
				waited += 1
			print("Flee: the battle ended after %.1f s of distance; log '%s'; the wild Rimefin still standing: %s" % [waited / 30.0, dg.log_lines[-1], str(w2["hp"] > 0)])
		else:
			print("Flee: no battle started (WRONG)")
	else:
		print("Flee: not run; real-time battles are off by Preston's 2026-10-09 call, so there is nothing to flee")
	if dg.asking >= 0:
		dg.act_recruit(false)
	# 4. A whole floor on autopilot: fight to fight to the stairs.
	while dg.busy: await process_frame   # the autopilot switched on in part 1 may still be mid-turn; rebuilding the floor under it left its creature indexes pointing past the new list
	dg.floor_n = 1   # part 1's autopilot may have taken the stairs; this part starts on B1F (Claude, 2026-10-24)
	dg.floor_seed = 99
	dg._build_floor(true)
	await _frames(3)
	dg.autopilot = true
	dg.check_bot = true   # reads lines and welcomes recruits on autopilot (dungeon.gd check_bot, L6-01)
	var n0: int = dg.battles
	frames = 0
	while dg.floor_n == 1 and frames < 30 * 400:
		await process_frame
		frames += 1
	print("Autopilot floor: %s after %.0f s, %d battles, %d faints, team %s" % ["reached B2F" if dg.floor_n > 1 else "still on B1F", frames / 30.0, dg.battles - n0, dg.faints, _team(dg)])
	_ok("The autopilot reaches B2F (B%dF after %.0f s)" % [dg.floor_n, frames / 30.0], dg.floor_n > 1)
	if not dg.real_time_battles:
		_ok("Turn-based: no arena battle started in the whole run (%d)" % dg.battles, dg.battles == 0)
	quit(1 if fails else 0)


func _team(dg: Node2D) -> String:
	var names := []
	for e in dg.ents:
		if e["team"] == 0:
			names.append("%s %d/%d" % [e["name"], e["hp"], e["max_hp"]])
	return str(names)


func _frames(n: int) -> void:
	for k in n:
		await process_frame


## The hybrid's stills. Headless has no viewport texture, so they need a window (Claude, 2026-10-24).
func _save(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.get_texture().get_image().save_png(OUT + name + ".png")
