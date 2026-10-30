extends "res://docs/team/sweep-2026-10-20/pass9-audit/method/audit9_probe.gd"
## Pass 9 rooms lane, R5 (H9-18, H9-33): the last captures (Claude, 2026-10-27; a record, not a tools/ file). Extends
## the pass 9 audit probe (its walker, snaps, TEAM lines and HITCH log). Same flags (--phase, --save, --out, --pad),
## plus --reduce, which turns Reduce motion on in this run's own (scratch APPDATA) preferences first. Phases:
##   places9  v1 Highbank on a save: the Item Shop's door, the Training Yard's gate and the Bluff Lookout, each with E.
##   east9    scenes/debug/highbank_v2.tscn: townsfolk counted on each area, the East Quarter (its road is open only
##            here), then up the north steps: the Tower reveal snapped every 6 frames (its moving parts: lamp, hoist
##            basket, cradles, chute parcels, smoke), and 20 more stills of the Tower from the Rise afterwards.
##   nest60   a nest sprung on a floor that has one (the audit's staging): 60 frames in a row, each snapped.
##   road9    scenes/road_to_highbank.tscn on the pad: the opening veil's lift traced a frame at a time, the lines read
##            with the pad, the party walked east with the D-pad held (DPAD_RIGHT), every frame's time kept, the
##            veil's fall at the end traced. Run once plain and once with --reduce.

const UIr := preload("res://scripts/ui/ui_style.gd")


func _run() -> void:
	if not phase in ["places9", "east9", "nest60", "road9"]:
		await super._run()
		return
	prefix = {"places9": "P", "east9": "E", "nest60": "N", "road9": "R"}[phase]
	L("phase %s, %s, window %s, out %s" % [phase, "pad" if pad_mode else "keyboard", str(root.size), OUT])
	if "--reduce" in OS.get_cmdline_user_args():
		UIr.save_pref("menu", "reduce_motion", true)
	L("REDUCE MOTION %s" % str(UIr.reduce_motion()))
	use_save()
	match phase:
		"places9":
			await phase_places9()
		"east9":
			await phase_east9()
		"nest60":
			await phase_nest60()
		"road9":
			await phase_road9()
	L("DONE phase %s in %.1f s game, %.1f s wall" % [phase, frame / 30.0, Time.get_ticks_msec() / 1000.0])
	quit(0)


## Each frame's wall time while `rec_times` is on (the road's walk): the parent's F, timed one frame at a time.
var rec_times := false
var frame_times: Array = []


func F(n := 1) -> void:
	for k in n:
		var before := Time.get_ticks_msec()
		await super.F(1)
		if rec_times:
			frame_times.append(Time.get_ticks_msec() - before)


## Walk to `t` unless already there (the parent's walk_to answers false for a walk of no steps).
func go(t: Vector2i) -> bool:
	if _lead_pos() == t:
		return true
	return await walk_to(t)


## E at `t` facing `d`: the still before, the still after, and what came up (panel or line), then closed.
func look_at(t: Vector2i, d: Vector2i, name: String) -> void:
	var reached := await go(t)
	await face(d)
	await F(10)
	await snap(name + "_front")
	await press(&"interact" if not pad_mode else &"confirm")
	await F(20)
	await snap(name + "_e")
	L("PLACE %s: reached %s (leader at %s), panel %s, talking %s" % [name, str(reached), str(_lead_pos()), str(_panel()).left(300), str(_talking())])
	if _talking():
		await read_all()
	if not _panel().is_empty():
		await press(&"cancel")
		await F(12)


func _folk() -> int:
	var s := current_scene
	return (s.npcs as Array).size() if s != null and "npcs" in s else -1


func phase_places9() -> void:
	await title_continue()
	if await wait_town() == null:
		L("no town")
		return
	await F(30)
	await look_at(Vector2i(33, 8), Vector2i(0, -1), "shop")       # highbank_v1.gd: the Item Shop's door (33, 7)
	await look_at(Vector2i(41, 11), Vector2i(0, 1), "yard")       # the Training Yard's gate (41, 12)
	await look_at(Vector2i(13, 6), Vector2i(0, -1), "lookout")    # the Bluff Lookout (13, 5)


func phase_east9() -> void:
	change_scene_to_file("res://scenes/debug/highbank_v2.tscn")
	await F(2)
	if await wait_town() == null:
		L("no town")
		return
	await F(30)
	L("FOLK area %s: %d townsfolk" % [_area(), _folk()])
	await snap("street")
	# the East Quarter, through the street's road east (55, 8), which only this debug scene opens
	await go(Vector2i(54, 8))
	await step(Vector2i(1, 0))
	var got := await _wait_area("east_quarter")
	await F(30)
	await snap("east_quarter")
	L("PLACE east_quarter: reached %s, area %s, %d townsfolk" % [str(got), _area(), _folk()])
	await go(Vector2i(14, 9))
	await F(10)
	await snap("east_quarter_mid")
	await go(Vector2i(1, 8))
	await step(Vector2i(-1, 0))
	await _wait_area("street")
	await F(20)
	# up the north steps: the Tower reveal plays the first time
	await go(Vector2i(46, 1))
	await step(Vector2i(0, -1))
	await until(func() -> bool: return _area() == "hall_rise" or current_scene.cutscene, 30 * 8)
	L("FOLK area %s: %d townsfolk" % [_area(), _folk()])
	var n := 0
	var w := Time.get_ticks_msec()
	var worst := 0
	for k in 30 * 150:
		var s := current_scene
		var on: bool = s != null and is_instance_valid(s) and (("cutscene" in s and s.cutscene) or _talking())
		if not on and k > 30:
			break
		if k % 6 == 0:
			await snap("reveal_%03d" % n)
			n += 1
		if _talking() and bool(UI._line.get("done", false)):
			await read_line()
		else:
			await F()
		var now := Time.get_ticks_msec()
		worst = maxi(worst, now - w)
		w = now
	L("REVEAL %d stills, worst step %d ms" % [n, worst])
	await F(30)
	for k in 20:
		await F(2)
		await snap("rise_parts_%02d" % k)
	L("FOLK area %s: %d townsfolk" % [_area(), _folk()])


func phase_nest60() -> void:
	var dg: Node2D = null
	for sd in [41, 11, 23, 37, 53, 67, 71, 89, 97, 101, 131, 151]:   # 41 had a nest in the audit
		if dg != null:
			dg.queue_free()
			await F(2)
		dg = load("res://scenes/dungeon.tscn").instantiate()
		dg.floor_seed = sd
		dg.poll_input = false
		dg.dungeon = "mouth"
		dg.beaten = ["mouth", "first", "hollow"]
		dg.party = [[0, 1], [1, 0], [7, 0], [10, 0]]
		root.add_child(dg)
		current_scene = dg
		await F(10)
		for k in 6:
			await F()
			if not dg.talk.is_empty():
				dg.act_talk()
		if dg.monster_room.size != Vector2i.ZERO:
			L("NEST seed %d floor %d room %s" % [sd, int(dg.floor_n), str(dg.monster_room)])
			break
	if dg == null or dg.monster_room.size == Vector2i.ZERO:
		L("NEST none found")
		return
	var lead: Dictionary = dg.ents[0]
	var c: Vector2i = dg.monster_room.get_center()
	for k in 30:
		if dg._floor_at(c):
			break
		c += Vector2i(1, 0)
	lead["pos"] = c
	dg._place(lead)
	await F(20)
	await snap("nest_before")
	dg._monster_house()
	L("NEST sprung: banner rect %s" % str(dg.banner_rect()))
	var w := Time.get_ticks_msec()
	for k in 60:
		await F()
		await snap("nest_f%02d" % k)
		L("NEST f%02d alpha %.2f talk %s step %d ms" % [k, float(dg.banner_alpha()), str(not dg.talk.is_empty()), Time.get_ticks_msec() - w])
		w = Time.get_ticks_msec()


func _dpad(down: bool) -> void:
	var ev := InputEventJoypadButton.new()
	ev.button_index = JOY_BUTTON_DPAD_RIGHT
	ev.pressed = down
	Input.parse_input_event(ev)


## The road's black veil, a frame at a time, until it settles at `to` (or `budget` frames): "alpha@frame" pairs.
func trace_veil(to: float, budget := 120) -> Array:
	var out: Array = []
	var t0 := Time.get_ticks_msec()
	for k in budget:
		var s := current_scene
		if s == null or not is_instance_valid(s) or not "_veil" in s or s._veil == null:
			await F()
			continue
		var a: float = s._veil.color.a
		out.append("%.2f@%d" % [a, k])
		if absf(a - to) < 0.01 and k > 0:
			break
		await F()
	var first := 0
	while first < out.size() - 1 and String(out[first]).get_slice("@", 0) == String(out[0]).get_slice("@", 0):
		first += 1
	L("VEIL to %.0f: %d frames, %d ms, moving from frame %d: %s" % [to, out.size(), Time.get_ticks_msec() - t0, maxi(first - 1, 0), " ".join(out.slice(maxi(first - 1, 0), maxi(first - 1, 0) + 60))])
	return out


func phase_road9() -> void:
	pad_mode = true
	if TeamState.data.is_empty():
		TeamState.start([[0, 1], [1, 0]])
	change_scene_to_file("res://scenes/road_to_highbank.tscn")
	await F(2)
	await snap("road_open")
	await trace_veil(0.0, 240)
	await snap("road_lifted")
	frame_times.clear()
	rec_times = true
	var lines := 0
	var k := 0
	var held := false
	var x0 := -1.0
	while k < 30 * 240 and _scene() == "road_to_highbank.tscn":
		var s := current_scene
		if s == null or not is_instance_valid(s):
			await F()
			continue
		if x0 < 0.0 and "xs" in s and not (s.xs as Array).is_empty():
			x0 = float(s.xs[0])
		if "leaving" in s and s.leaving:
			break
		var reading: bool = s.line != null or s.asking
		if reading:
			if held:
				_dpad(false)
				held = false
			if lines % 4 == 0:
				await snap("road_line%02d" % lines)
			await press(&"confirm", 3, 8)
			lines += 1
		else:
			if not held:
				_dpad(true)
				held = true
			await F()
			if k % 90 == 0:
				await snap("road_walk%03d" % (k / 90))
		k += 1
	if held:
		_dpad(false)
	rec_times = false
	var times := frame_times.duplicate()
	var s2 := current_scene
	L("ROAD walked from x %.0f to %s, %d lines read, leaving %s" % [x0, str(s2.xs[0]) if s2 != null and "xs" in s2 and not (s2.xs as Array).is_empty() else "?", lines, str(s2.leaving) if s2 != null and "leaving" in s2 else "?"])
	await trace_veil(1.0, 120)
	await snap("road_leaving")
	var sorted := times.duplicate()
	sorted.sort()
	var over := times.filter(func(t: int) -> bool: return t > 50).size()
	var hitch := times.filter(func(t: int) -> bool: return t > 250).size()
	L("ROAD FRAMES %d steps: median %d ms, 95th %d ms, worst %d ms, over 50 ms %d, over 250 ms %d" % [times.size(),
		sorted[sorted.size() / 2] if not sorted.is_empty() else -1, sorted[int(sorted.size() * 0.95)] if not sorted.is_empty() else -1,
		sorted[-1] if not sorted.is_empty() else -1, over, hitch])
	await until(func() -> bool: return _scene() != "road_to_highbank.tscn", 30 * 10)
	await F(20)
	await snap("after_road")
