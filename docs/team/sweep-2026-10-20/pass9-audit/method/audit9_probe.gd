extends "res://tools/debug/live_play_probe.gd"
## Pass 9 live audit probe (Claude, 2026-10-27, scratch only, not a tools/ file). It extends the pass 8 live play probe
## (tools/debug/live_play_probe.gd) and adds the places pass 8 never filmed (its U9 list) and the open pass 8 items.
## Same flags as the parent. New phases:
##   town9   v1 Highbank on a save: arrival, the MENU chip, the Hall and its upper-floor mole (Grubbit), the Job Board,
##           the Growth Shrine (timed E, counts), the Training Yard, the Scroll Keeper, the Bluff Lookout, Storage,
##           Home, the pause menu, then growth at the shrine when someone is ready (the evolution scene).
##   mouth9  a Hollow Mouth run: a fight, an item from the bag, the stairs, autopilot to the end, back in Highbank,
##           then Quit from the pause menu at once (the quit-during-warm-up question). Logs QUIT REQUEST wall ms.
##   v2      scenes/debug/highbank_v2.tscn (its own save): the street, its open-air places, the north steps to
##           Tower Rise and the Tower reveal, the Tower's door and board, back down and the Old Ferry Ward.
##   warden  the Hollow's boss floor staged (as tools/debug/boss_size_capture.gd): the leader 3 to 7 tiles below the
##           Warden, the Warden's sprite top on screen logged.
##   nest    a nest staged on a floor that has one: the leader in the room, the nest sprung, the banner's frames.

const SceneKit9 := preload("res://scripts/town/scene_kit.gd")


func _run() -> void:
	if not phase in ["town9", "mouth9", "v2", "warden", "nest", "scrolls9", "xquit", "shrine9"]:
		await super._run()
		return
	prefix = {"town9": "T", "mouth9": "D", "v2": "V", "warden": "W", "nest": "N", "scrolls9": "C", "xquit": "Q", "shrine9": "G"}[phase]
	L("phase %s, %s, window %s, out %s" % [phase, "pad" if pad_mode else "keyboard", str(root.size), OUT])
	L("CLOCK %s, max fps %d" % ["real time" if real_time else "fixed (--fixed-fps)", Engine.max_fps])
	use_save()
	match phase:
		"town9":
			await phase_town9()
		"mouth9":
			await phase_mouth9()
		"v2":
			await phase_v2()
		"warden":
			await phase_warden()
		"shrine9":
			await phase_shrine9()
		"xquit":
			await phase_xquit()
		"scrolls9":
			await phase_scrolls9()
		"nest":
			await phase_nest()
	L("MARKS " + str(marks))
	L("DONE phase %s in %.1f s game, %.1f s wall" % [phase, frame / 30.0, Time.get_ticks_msec() / 1000.0])
	quit(0)


# ------------------------------------------------------------------ helpers

## The parent's walker routes over any open tile; in a room that includes the stairs and door links, so a walk across
## the Hall took the stairs down. Links, a room's way out and a town area's exits are only walked onto as the target.
func _walkable(t: Vector2i) -> bool:
	var s := current_scene
	if s != null and is_instance_valid(s) and s.has_method("room") and _scene() == "town_room.tscn":
		var r: Dictionary = s.room()
		for l in r.get("links", []):
			if (l["rect"] as Rect2i).has_point(t):
				return false
		if r.has("exit_rect") and (r["exit_rect"] as Rect2i).has_point(t):
			return false
		if t == r.get("door", Vector2i(-1, -1)):
			return false
	elif _scene() == "hub_town.tscn" and Layout.v2() and not Layout.exit_at(t).is_empty():
		return false
	return super._walkable(t)

## Press `act` and time how long until `done` is true, and the worst frame on the way (the E freeze).
func timed_press(act: StringName, done: Callable, label: String) -> void:
	var ev := _bind(act, pad_mode)
	if ev == null:
		L("NO BINDING " + String(act))
		return
	action = label
	action_frame = frame
	var w0 := Time.get_ticks_msec()
	var last := w0
	var worst := 0
	var got := -1
	_send(ev, true)
	for k in 45:
		await F()
		var now := Time.get_ticks_msec()
		worst = maxi(worst, now - last)
		last = now
		if k == 2:
			_send(ev, false)
		if got < 0 and done.call():
			got = now - w0
		if got >= 0 and k > 14:
			break
	L("TIMED %s: shown %d ms after the press, worst frame %d ms" % [label, got, worst])


## Every shot in town or a room also logs where each teammate stands (the heap and wall questions).
func snap(name: String) -> String:
	var id: String = await super.snap(name)
	var s := current_scene
	if _scene() in ["hub_town.tscn", "town_room.tscn"] and "team" in s and s.team is Array:
		var row: Array = []
		for e in s.team:
			if e is Dictionary and e.has("pos"):
				row.append("%s@%s" % [str(e.get("form", e.get("line", "?"))), str(e["pos"])])
		L("TEAM %s area %s: %s" % [id, Layout.area_id(), ", ".join(row)])
	return id


## E tapped while the leader's last step is still sliding (a player pressing E as they arrive): kept or dropped?
## The Training Yard's gate shows a sign from the tile in front of it, so a kept press shows the sign.
func tap_test() -> void:
	await walk_to(Vector2i(41, 10))
	await F(10)
	var ev := _bind(&"interact", pad_mode)
	for wait in [1, 3, 5]:
		_dir_down(Vector2i(0, 1), true)
		await until(func() -> bool: return _lead_pos() != Vector2i(41, 10), 24)
		_dir_down(Vector2i(0, 1), false)
		await F(wait)
		var was_busy: bool = current_scene.busy
		action = "tap E %d frames into the step" % wait
		_send(ev, true)
		await F(3)
		_send(ev, false)
		await F(30)
		L("TAP E %d frames into the last step (busy %s): panel %s" % [wait, str(was_busy), str(_panel().get("service", "none"))])
		await snap("tap_%d" % wait)
		if not _panel().is_empty():
			await press(&"cancel")
			await F(10)
		await walk_to(Vector2i(41, 10))
		await F(10)
	await walk_to(Vector2i(41, 11))
	await F(15)
	await face(Vector2i(0, 1))
	await F(10)
	await press(&"interact")
	await F(20)
	L("TAP control, E after standing still: panel %s" % str(_panel().get("service", "none")))
	if not _panel().is_empty():
		await press(&"cancel")
		await F(10)


func _panel() -> Dictionary:
	var s := current_scene
	if s != null and is_instance_valid(s) and "panel" in s and s.panel is Dictionary:
		return s.panel
	return {}


## Walk to `tile`, turn to `d` (Vector2i.ZERO: stand there), press the use key (timed), shoot the panel, close it.
func visit(tile: Vector2i, d: Vector2i, name: String, close := true) -> Dictionary:
	if not await walk_to(tile):
		L("VISIT %s: could not reach %s (at %s)" % [name, str(tile), str(_lead_pos())])
		await snap(name + "_unreached")
		return {}
	if d != Vector2i.ZERO:
		await face(d)
	await snap(name + "_before")
	await timed_press(&"interact", func() -> bool: return not _panel().is_empty() or _talking() or _scene() != "hub_town.tscn", name)
	await F(20)
	await snap(name)
	var p := _panel().duplicate()
	L("VISIT %s panel %s" % [name, str(p).left(400)])
	if _talking():
		await read_all()
	if close and not _panel().is_empty() and _scene() == "hub_town.tscn":
		await press(&"cancel")
		await F(12)
		if not _panel().is_empty():
			await press(&"interact")
			await F(12)
	return p


func _read_scenes() -> void:
	var s := current_scene
	if s != null and is_instance_valid(s) and (("cutscene" in s and s.cutscene) or _talking()):
		var n := await read_all()
		mark("scene read, %d lines" % n)


## Screen rect (base 1152x648 px) of a dungeon entity's drawn sprites: the subviewport's canvas, times SCALE.
func _ent_screen_rect(dg: Node, e: Dictionary) -> Rect2:
	var out := Rect2()
	var first := true
	var stack: Array = [e["node"]]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is Sprite2D or n is AnimatedSprite2D:
			var ci: Node2D = n
			if ci.is_visible_in_tree():
				var r: Rect2
				if n is Sprite2D:
					r = (n as Sprite2D).get_rect()
				else:
					var sf: SpriteFrames = (n as AnimatedSprite2D).sprite_frames
					var tex: Texture2D = sf.get_frame_texture((n as AnimatedSprite2D).animation, (n as AnimatedSprite2D).frame) if sf != null else null
					var sz := tex.get_size() if tex != null else Vector2.ZERO
					r = Rect2(-sz / 2.0 if (n as AnimatedSprite2D).centered else Vector2.ZERO, sz)
				var g: Rect2 = ci.get_global_transform_with_canvas() * r
				out = g if first else out.merge(g)
				first = false
		for c in n.get_children():
			stack.append(c)
	var sc: float = float(dg.get_script().get_script_constant_map().get("SCALE", 1))
	return Rect2(out.position * sc, out.size * sc)


# ------------------------------------------------------------------ town9

func phase_town9() -> void:
	await title_continue()
	var town := await wait_town()
	if town == null:
		L("no town")
		return
	mark("highbank arrival")
	await snap("arrive")
	await F(60)
	await snap("arrive_settled")
	await _read_scenes()
	var s := current_scene
	L("TOWN npcs %d: %s" % [s.npcs.size(), str(s.npcs.map(func(n: Dictionary) -> String: return "%s@%s lines=%s" % [str(n.get("form", "")), str(n.get("pos", "")), str(n.has("lines"))]))])
	L("STORY " + str(TeamState.data.get("story", {})) + " beaten " + str(TeamState.data.get("beaten", [])))
	# a street chat: anyone in the street with a line
	for n in s.npcs:
		if n.has("lines") or true:
			for off in [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]:
				if _walkable(n["pos"] + off) and await walk_to(n["pos"] + off):
					await face(-off)
					await press(&"interact")
					await F(20)
					await snap("street_chat")
					await read_all()
					break
			break
	# the pause menu in town
	await press(&"pause")
	await F(15)
	await snap("pause_town")
	await press(&"cancel")
	await F(15)
	# the Hall (still the legacy Hall in v1) and its upper-floor mole, Grubbit at (17, 11) facing west
	await walk_to(Vector2i(24, 6))
	await face(Vector2i(0, -1))
	await timed_press(&"interact", func() -> bool: return _scene() == "town_room.tscn", "hall_door")
	await until(func() -> bool: return _scene() == "town_room.tscn", 30 * 6)
	await F(20)
	await snap("hall")
	await _read_scenes()
	var rm := current_scene
	if _scene() == "town_room.tscn":
		L("HALL npcs " + str(rm.npcs.map(func(n: Dictionary) -> String: return "%s@%s" % [str(n.get("form", "")), str(n["pos"])])))
		var mole: Dictionary = {}
		for n in rm.npcs:
			if String(n.get("form", "")) == "grubbit":
				mole = n
		if mole.is_empty():
			L("MOLE not in the Hall")
		else:
			for off in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]:
				var t: Vector2i = mole["pos"] + off
				if _walkable(t) and await walk_to(t):
					await face(-off)
					await snap("mole_before")
					await press(&"interact")
					await F(25)
					await snap("mole_talk")
					var k := 0
					while _talking() and k < 8:
						await read_line()
						await F(8)
						await snap("mole_line%d" % k)
						k += 1
					break
		# a spot panel in the Hall (contrast)
		await walk_to(Vector2i(6, 9))
		await face(Vector2i(0, -1))
		await press(&"interact")
		await F(20)
		await snap("hall_chart_panel")
		if not current_scene.panel.is_empty():
			await press(&"cancel")
			await F(10)
		await walk_to(current_scene.room()["door"])
		await wait_town()
	await snap("hall_out")
	# the Job Board
	await visit(Vector2i(26, 8), Vector2i(0, -1), "board", false)
	await press(&"move_down")
	await F(6)
	await snap("board_down")
	await press(&"cancel")
	await F(12)
	# the Growth Shrine: timed E, the counts
	var shrine := await visit(Vector2i(7, 12), Vector2i.ZERO, "shrine", false)
	await F(30)
	await snap("shrine_held")
	var ready_to_grow := String(shrine.get("service", "")) == "evolve_ask"
	await press(&"cancel")
	await F(15)
	if not _panel().is_empty():
		await press(&"interact")
		await F(15)
	# the places pass 8 never filmed
	await tap_test()
	await visit(Vector2i(41, 11), Vector2i(0, 1), "yard")
	# the Scroll Keeper's door is walkable, so stand still a moment after turning before E
	await walk_to(Vector2i(33, 11))
	await F(15)
	await face(Vector2i(0, 1))
	await F(15)
	L("SCROLLS leader at %s facing %s" % [str(_lead_pos()), str(current_scene.team[0].get("facing", "?"))])
	await visit(_lead_pos(), Vector2i.ZERO, "scrolls")
	await visit(Vector2i(13, 6), Vector2i(0, -1), "lookout")
	# Storage: the room and its panel
	await walk_to(Vector2i(40, 7))
	await face(Vector2i(0, -1))
	await press(&"interact")
	await until(func() -> bool: return _scene() == "town_room.tscn", 30 * 6)
	await F(20)
	await snap("storage_room")
	if _scene() == "town_room.tscn":
		await walk_to(Vector2i(8, 7))
		await face(Vector2i(0, -1))
		await press(&"interact")
		await F(20)
		await snap("storage_panel")
		await press(&"cancel")
		await F(10)
		await walk_to(current_scene.room()["door"])
		await wait_town()
	# Home
	await walk_to(Vector2i(5, 7))
	await face(Vector2i(0, -1))
	await press(&"interact")
	await until(func() -> bool: return _scene() == "town_room.tscn", 30 * 6)
	await F(20)
	await snap("home")
	if _scene() == "town_room.tscn":
		await walk_to(Vector2i(7, 6))
		await face(Vector2i(0, -1))
		await press(&"interact")
		await F(20)
		await snap("home_table_panel")
		if not current_scene.panel.is_empty():
			await press(&"cancel")
			await F(10)
		await walk_to(current_scene.room()["door"])
		await wait_town()
	await snap("street_end")
	# growth, if someone is ready: the evolution scene
	if ready_to_grow:
		await walk_to(Vector2i(7, 12))
		await press(&"interact")
		await F(20)
		await snap("growth_ask")
		if String(_panel().get("service", "")) == "evolve_ask":
			mark("growth starts")
			await press(&"interact")
			var n := 0
			for k in 30 * 60:
				if not current_scene.evolving_now:
					break
				await F()
				if k % 45 == 20 and n < 14:
					await snap("evo_%02d" % n)
					n += 1
			await F(20)
			await snap("evo_after")
			mark("growth ends")
			await F(READ)
			await snap("evo_result")
			await press(&"interact")
			await F(30)
			await snap("evo_closed")
			await _read_scenes()
	else:
		L("GROWTH nobody ready on this save")


## The window's close button right after Highbank comes up (the warm-up starts 0.25 s after the arrival and paints
## rooms and the walkway on workers): the close notification as the window sends it, then the tree's own quit, as
## auto_accept_quit does. The outer timer measures how long the process takes to end.
func phase_xquit() -> void:
	await title_continue()
	await until(func() -> bool: return _scene() == "hub_town.tscn" and not current_scene.team.is_empty(), 30 * 20)
	await F(12)
	await snap("town_at_close")
	L("XQUIT close request at w%d" % Time.get_ticks_msec())
	root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	quit(0)
	for k in 30 * 300:
		await process_frame


## The Growth Shrine as the first thing a player does in Highbank: E timed, then again after closing it.
func phase_shrine9() -> void:
	await title_continue()
	if await wait_town() == null:
		return
	await F(30)
	await walk_to(Vector2i(7, 12))
	await F(15)
	await timed_press(&"interact", func() -> bool: return not _panel().is_empty(), "shrine_first")
	await F(10)
	await snap("shrine_first")
	L("SHRINE panel " + str(_panel()).left(200))
	await press(&"cancel")
	await F(20)
	await timed_press(&"interact", func() -> bool: return not _panel().is_empty(), "shrine_second")
	await F(10)
	await snap("shrine_second")
	await press(&"cancel")
	await F(20)


## The Scroll Keeper's door: E in front of it, then E standing on it.
func phase_scrolls9() -> void:
	await title_continue()
	if await wait_town() == null:
		return
	await walk_to(Vector2i(33, 10))
	await F(15)
	await step(Vector2i(0, 1))
	await F(20)
	L("SCROLLS in front: leader %s facing %s, open (33,12) %s" % [str(_lead_pos()), str(current_scene.team[0]["facing"]), str(_walkable(Vector2i(33, 12)))])
	await press(&"interact")
	await F(20)
	L("SCROLLS E in front: panel %s last_sfx %s" % [str(_panel()), str(current_scene.last_sfx)])
	await snap("scrolls_front")
	if not _panel().is_empty():
		await press(&"cancel")
		await F(12)
	var moved := await step(Vector2i(0, 1))
	await F(20)
	L("SCROLLS stepped %s: leader %s facing %s" % [str(moved), str(_lead_pos()), str(current_scene.team[0]["facing"])])
	await snap("scrolls_on_door")
	await press(&"interact")
	await F(20)
	L("SCROLLS E on the door: panel %s scene %s" % [str(_panel()), _scene()])
	await snap("scrolls_on_door_e")


# ------------------------------------------------------------------ mouth9

func phase_mouth9() -> void:
	await title_continue()
	var town := await wait_town()
	if town == null:
		return
	mark("town up")
	await walk_to(Vector2i(33, 27))
	await walk_to(Vector2i(33, 28))
	await F(20)
	await snap("way_pick")
	L("WAY " + str(_panel()).left(300))
	await press(&"interact")
	await until(func() -> bool: return _scene() == "dungeon.tscn" and not current_scene.ents.is_empty(), 30 * 15)
	mark("dungeon up")
	await F(5)
	await snap("floor_card")
	await F(60)
	await snap("b1f")
	await clear_teach()
	var dg := current_scene
	L("RUN dungeon %s floors %d" % [str(dg.dungeon), dg.floors()])
	await _fight(dg)
	# an item from the bag
	L("BAG before " + str(dg.bag))
	await press(&"bag")
	await F(12)
	await snap("bag_open")
	await press(&"confirm")
	await until(func() -> bool: return not dg.busy, 90)
	await F(15)
	await snap("item_used")
	L("BAG after " + str(dg.bag))
	# autopilot to the stairs
	var b := int(dg.floor_n)
	for k in 30 * 120:
		if _scene() != "dungeon.tscn" or int(current_scene.floor_n) > b:
			break
		var s := current_scene
		if not s.talk.is_empty():
			await read_line()
		elif s.asking >= 0:
			await press(&"yes")
		elif s.teach_kind != "":
			await press(&"confirm")
		elif not s.autopilot and not s.busy and not s.cutscene:
			await press(&"autopilot")
		else:
			await F()
	await F(3)
	await snap("stairs_card")
	await F(30)
	await snap("b2f")
	# on to the end, as a player leaning on autopilot (nest banners, if any, are logged and shot by play_dungeon's timer)
	var end := await play_dungeon(30 * 900, 300)
	L("RUN ENDED, scene " + end)
	for k in 30 * 90:
		if _scene() == "hub_town.tscn" and not current_scene.team.is_empty():
			break
		if _talking():
			await read_line()
		else:
			await F()
	if _scene() != "hub_town.tscn":
		L("never got back to town")
		return
	mark("back in town")
	await snap("back_town")
	# quit at once from the pause menu while the town's warm-up may still be painting
	await press(&"pause")
	await F(8)
	L("PAUSE FOCUS " + _focus_name())
	if await focus_to("Quit"):
		await press(&"ui_accept")
		await F(8)
		if await focus_to("ConfirmLeave"):
			await snap("quit_confirm")
			L("QUIT REQUEST via pause menu at w%d" % Time.get_ticks_msec())
			await press(&"ui_accept", 3, 0)
			for k in 30 * 300:
				await F()   # the game quits itself; the outer timer measures how long that takes
			L("QUIT never happened after 300 s")
			return
	L("QUIT REQUEST via probe quit() at w%d (no pause row)" % Time.get_ticks_msec())


# ------------------------------------------------------------------ v2

func _area() -> String:
	return Layout.area_id()


func _wait_area(id: String, budget := 30 * 10) -> bool:
	return await until(func() -> bool: return _scene() == "hub_town.tscn" and _area() == id and not current_scene.busy, budget)


## Through a scene that moves the camera: a shot every 40 frames, lines read as they finish.
func film_scene(tag: String, budget := 30 * 120) -> void:
	var n := 0
	for k in budget:
		var s := current_scene
		if s == null or not is_instance_valid(s):
			await F()
			continue
		var on: bool = ("cutscene" in s and s.cutscene) or _talking()
		if not on:
			break
		if k % 40 == 0:
			await snap("%s_%02d" % [tag, n])
			n += 1
		if _talking() and bool(UI._line.get("done", false)):
			await read_line()
		else:
			await F()


func phase_v2() -> void:
	change_scene_to_file("res://scenes/debug/highbank_v2.tscn")
	await F(2)
	var town := await wait_town()
	if town == null:
		L("no town")
		return
	L("V2 area %s, v2 %s" % [_area(), str(Layout.v2())])
	mark("street up")
	await snap("street_arrive")
	await F(45)
	await snap("street_settled")
	await _read_scenes()
	# the street's open-air places (street.gd): the Shrine (14, 11), the Yard (24, 11), the Lookout (4, 12)
	await visit(Vector2i(14, 10), Vector2i(0, 1), "v2_shrine")
	await visit(Vector2i(24, 10), Vector2i(0, 1), "v2_yard")
	await visit(Vector2i(4, 11), Vector2i(0, 1), "v2_lookout")
	await walk_to(Vector2i(40, 8))
	await snap("v2_street_east")
	# up the north steps to Tower Rise: the Tower reveal plays the first time
	await walk_to(Vector2i(46, 1))
	await snap("north_steps")
	await step(Vector2i(0, -1))
	await until(func() -> bool: return _area() == "hall_rise" or current_scene.cutscene, 30 * 8)
	mark("tower rise")
	await F(6)
	await snap("rise_arrive")
	await film_scene("reveal")
	mark("reveal over")
	await F(30)
	await snap("rise_after")
	L("STORY " + str(TeamState.data.get("story", {})))
	# the Tower's door
	await walk_to(Vector2i(12, 9))
	await face(Vector2i(0, -1))
	await timed_press(&"interact", func() -> bool: return _scene() == "town_room.tscn", "tower_door")
	await until(func() -> bool: return _scene() == "town_room.tscn", 30 * 6)
	await F(20)
	await snap("tower_room")
	await _read_scenes()
	if _scene() == "town_room.tscn":
		await walk_to(current_scene.room()["door"])
		await wait_town()
		await F(20)
		await snap("tower_out")
	# the Job Board on the Rise
	await visit(Vector2i(16, 10), Vector2i(0, -1), "rise_board")
	# down the steps to the street, then the south steps to the Old Ferry Ward
	await walk_to(Vector2i(12, 12))
	await step(Vector2i(0, 1))
	await _wait_area("street")
	await F(20)
	await snap("street_from_rise")
	await walk_to(Vector2i(46, 14))
	await step(Vector2i(0, 1))
	await _wait_area("ferry_ward")
	await F(20)
	await snap("ferry_ward")
	await _read_scenes()
	L("V2 done in area " + _area())


# ------------------------------------------------------------------ warden (staged)

func phase_warden() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	dg.dungeon = "hollow"
	dg.party = [[0, 1], [1, 0], [10, 0]]
	root.add_child(dg)
	current_scene = dg
	await F(10)
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	# the entrance plays through first (its lines read as they finish), then the fight's own camera holds
	for k in 30 * 90:
		await F()
		if not dg.talk.is_empty() and bool(UI._line.get("done", true)):
			dg.act_talk()
		if k > 30 and dg.talk.is_empty() and not dg.cutscene and not dg.busy:
			break
	L("WARDEN entrance over at frame %d, cutscene %s" % [frame, str(dg.cutscene)])
	await snap("warden_fight_start")
	if dg.boss < 0:
		L("WARDEN no boss on the floor")
		return
	var b: Dictionary = dg.ents[dg.boss]
	L("WARDEN %s at %s" % [str(b.get("name", "")), str(b["pos"])])
	var lead: Dictionary = dg.ents[0]
	for dy in [3, 4, 5, 6, 7]:
		var want: Vector2i = b["pos"] + Vector2i(0, dy)
		var spot := Vector2i(-99, -99)
		for dx in [0, 1, -1, 2, -2]:
			if dg._floor_at(want + Vector2i(dx, 0)):
				spot = want + Vector2i(dx, 0)
				break
		if spot == Vector2i(-99, -99):
			L("WARDEN no floor %d tiles below" % dy)
			continue
		lead["pos"] = spot
		dg._place(lead)
		for k in 120:
			await F()
			if not dg.talk.is_empty():
				dg.act_talk()
		await snap("warden_dy%d" % dy)
		var r := _ent_screen_rect(dg, b)
		var rl := _ent_screen_rect(dg, lead)
		L("WARDEN dy %d: leader at %s, Warden sprite top %.1f px (bottom %.1f), leader top %.1f bottom %.1f, screen h %d" % [dy, str(spot), r.position.y, r.end.y, rl.position.y, rl.end.y, root.size.y])


# ------------------------------------------------------------------ nest (staged)

func phase_nest() -> void:
	var dg: Node2D = null
	for sd in [11, 23, 37, 41, 53, 67, 71, 89, 97, 101, 131, 151]:
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
		L("NEST seed %d floor %d room %s" % [sd, int(dg.floor_n), str(dg.monster_room)])
		if dg.monster_room.size != Vector2i.ZERO:
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
	var hr: Array = dg.hud_rects()
	L("NEST sprung: banner rect %s, hud rects %s" % [str(dg.banner_rect()), str(hr)])
	for k in 60:
		await F()
		if k % 5 == 0:
			await snap("nest_f%02d" % k)
			L("NEST f%d alpha %.2f talk %s" % [k, float(dg.banner_alpha()), str(not dg.talk.is_empty())])
