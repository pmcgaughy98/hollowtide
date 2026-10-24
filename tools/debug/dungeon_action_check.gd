extends SceneTree
## Action animations in the dungeon (Claude, 2026-10-09): the stage 1 starters play an attack when
## they use a move, a hurt when hit, and a sleeping wild one loops its sleep until it wakes. Counts
## the frames each shows and keeps the creature on its own ground line throughout.
## Each is a verdict line (Claude, 2026-10-24, H08). The sleeper is staged the way a floor spawns one
## (dungeon.gd's spawn loop: made, awake false, a facing from Arena.FACINGS) and must show 2 or more
## sleep pictures over 2 s asleep as a player sees it (60 frames and 2 s on the wall clock, see below).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_action_check.gd
## Stills to docs/design/dungeon-actions-2026-10-09/.

const OUT := "res://docs/design/dungeon-actions-2026-10-09/"
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	dg.traps.clear()
	dg.monster_room = Rect2i()
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	for who in [[0, 0], [1, 0], [2, 0]]:
		var art: Dictionary = dg._load_art(dg.Arena.LINES[who[0]]["forms"][0][0])
		var counts := {}
		for act in ["attack", "hurt", "sleep"]:
			counts[act] = art["acts"][act]["s"].size() if art["acts"].has(act) and art["acts"][act].has("s") else 0
		var facings: int = art["acts"].get("attack", {}).size()
		_ok("%s: frames attack %d, hurt %d, sleep %d (facings with attack %d)" % [dg.Arena.LINES[who[0]]["forms"][0][0], counts["attack"], counts["hurt"], counts["sleep"], facings],
			counts["attack"] > 0 and counts["hurt"] > 0 and counts["sleep"] > 0 and facings == 8)
	# Kithflare attacks a Rimefin beside it; watch the textures change.
	var lead: Dictionary = dg.ents[0]
	var d := Vector2i.ZERO
	for dd in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0:
			d = dd
			break
	var w: Dictionary = dg._make(2, 0, 1, lead["pos"] + d)
	w["max_hp"] = 99
	w["hp"] = 99
	dg.ents.append(w)
	dg._place(w)
	var seen_lead := {}
	var seen_w := {}
	var foot_moves := 0
	var y0: float = lead["sprite"].position.y
	dg.use_move(0, lead["moves"][0], d)
	for k in 14:
		await process_frame
		seen_lead[lead["sprite"].texture] = true
		seen_w[w["sprite"].texture] = true
		if absf(lead["sprite"].position.y - y0) > 0.01:
			foot_moves += 1   # a frame the leader's sprite left its ground line
		if k == 5 and DisplayServer.get_name() != "headless":   # no viewport texture headless; stills need a window (Claude, 2026-10-21)
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "attack_hurt.png"))
	await _frames(10)
	var lead_still: bool = lead["sprite"].texture == lead["art"]["still"][lead["facing"]]
	var w_still: bool = w["sprite"].texture == w["art"]["still"][w["facing"]]
	_ok("Attack: the leader showed %d different pictures, the Rimefin %d; back to the still after: %s / %s" % [seen_lead.size(), seen_w.size(), str(lead_still), str(w_still)],
		seen_lead.size() >= 2 and seen_w.size() >= 2 and lead_still and w_still)
	var y1: float = lead["sprite"].position.y
	_ok("Attack: the leader stands on its ground line after the act (y %.1f, was %.1f; %d frames off it during the act)" % [y1, y0, foot_moves], absf(y1 - y0) <= 0.01)
	# A sleeping Rimefin loops its sleep; waking returns it to its still. Staged as dungeon.gd's spawn loop puts
	# a wild down asleep (made, awake false, a facing from Arena.FACINGS), on a free tile of its own, with no
	# act left over from a hit (Claude, 2026-10-24, H08).
	var zp := Vector2i(-1, -1)
	for dd in [Vector2i(0, 2), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, -2), Vector2i(2, 2), Vector2i(-2, -2), Vector2i(2, -2), Vector2i(-2, 2)]:
		if dg._floor_at(lead["pos"] + dd) and dg._occupant(lead["pos"] + dd) < 0:
			zp = lead["pos"] + dd
			break
	var z: Dictionary = dg._make(2, 0, 1, zp if zp.x >= 0 else lead["pos"] - d)
	z["awake"] = false
	z["facing"] = dg.Arena.FACINGS[2]
	dg.ents.append(z)
	dg._place(z)
	# 2 s asleep as a player sees it: at least 60 frames (2 s of game time at the fixed 30 fps) and 2 s on the wall
	# clock, which dungeon.gd's sleep loop reads (Time.get_ticks_msec). Headless draws frames several times faster
	# than the wall clock (1570 frames in 2 s on 2026-10-24), so 60 frames alone saw one picture of the 1.6 s loop.
	var seen_sleep := {}
	var in_60 := 0
	var frames := 0
	var t_wall := Time.get_ticks_msec()
	while (frames < 60 or Time.get_ticks_msec() - t_wall < 2000) and frames < 30 * 600:   # a cap well past 2 s of headless frames
		await process_frame
		frames += 1
		seen_sleep[z["sprite"].texture] = true
		if frames == 60:
			in_60 = seen_sleep.size()
	var wall_ms := Time.get_ticks_msec() - t_wall
	if DisplayServer.get_name() != "headless":   # same: skipped headless (Claude, 2026-10-21)
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "sleep.png"))
	_ok("Sleep: %d pictures over 2 s asleep (a %d-picture loop of %.1f s; %d frames, %d ms on the wall clock; %d pictures in the first 60 frames)" % [seen_sleep.size(), z["art"]["acts"].get("sleep", {}).get("s", []).size(), dg.SLEEP_LOOP, frames, wall_ms, in_60],
		seen_sleep.size() >= 2)
	z["awake"] = true
	await _frames(3)
	var z_still: bool = z["sprite"].texture == z["art"]["still"][z["facing"]]
	_ok("Sleep: awake again shows the still: %s" % str(z_still), z_still)
	quit(1 if fails else 0)
