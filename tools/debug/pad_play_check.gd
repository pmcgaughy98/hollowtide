extends SceneTree
## Pad-only play (Claude, 2026-10-23, factory pass 2: controller support and rebinding). Plays with joypad events
## alone (Input.parse_input_event with InputEventJoypadButton and InputEventJoypadMotion, device 0, the Xbox layout
## the Input Map uses) through what a controller player must be able to do. In Highbank: walk with the left stick and
## the D-pad, open the Job Board with A and close it with B, step into the Home with A and walk back out. In Rootbank
## Warren: walk, attack a placed wild creature with A, use move 1 (RB held, then A), open the bag with Y and eat a
## Reedberry with A, take the stairs with X, open the pause menu with Start and close it with B. Then the team goes
## down and A leaves the faint screen for Highbank. Each step is set up on its own (a teleport, a placed creature, a
## panel opened for it), so one that fails does not hide the rest; every step's effect is measured (a position, HP,
## the bag, the floor, the scene). Writes only its own save (user://check_pad_play.save), never the real one.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/pad_play_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const CHECK_PATH := "user://check_pad_play.save"
const TOWN := "res://scenes/hub_town.tscn"
const ROOM := "res://scenes/town_room.tscn"
const DUNGEON := "res://scenes/dungeon.tscn"
const FAINT := "res://scenes/faint_screen.tscn"
const STORY := {"met_crew": true, "parcel": "stolen", "guild_trial": true}   # past the board scene: no crew at the board
const PAD := {Vector2i(1, 0): JOY_BUTTON_DPAD_RIGHT, Vector2i(-1, 0): JOY_BUTTON_DPAD_LEFT,
	Vector2i(0, 1): JOY_BUTTON_DPAD_DOWN, Vector2i(0, -1): JOY_BUTTON_DPAD_UP}
const STEPS4 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
var fails := 0
var steps := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	steps += 1
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


## Wait until `done` holds, a frame at a time, up to `budget` frames.
func _until(done: Callable, budget := 90) -> bool:
	for k in budget:
		if done.call():
			return true
		await process_frame
	return done.call()


func _scene() -> String:
	return current_scene.scene_file_path if current_scene != null else ""


# ---------------------------------------------------------------- the pad

func _button(b: JoyButton, down: bool) -> void:
	var ev := InputEventJoypadButton.new()
	ev.device = 0
	ev.button_index = b
	ev.pressed = down
	Input.parse_input_event(ev)


func _axis(a: JoyAxis, v: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.device = 0
	ev.axis = a
	ev.axis_value = v
	Input.parse_input_event(ev)


## Press and let go, held three frames: long enough for a screen that reads the pad once a frame.
func _tap(b: JoyButton) -> void:
	_button(b, true)
	await _frames(3)
	_button(b, false)
	await _frames(3)


## Hold a button until `done` holds or the budget runs out, then let go.
func _hold_until(b: JoyButton, done: Callable, budget := 45) -> bool:
	_button(b, true)
	var got := await _until(done, budget)
	_button(b, false)
	await _frames(2)
	return got


## Nothing left down (a failed step can leave a stick pushed or the tree paused for the next one).
func _let_go() -> void:
	for b in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y, JOY_BUTTON_START, JOY_BUTTON_RIGHT_SHOULDER,
			JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]:
		if Input.is_joy_button_pressed(0, b):
			_button(b, false)
	for a in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
		if absf(Input.get_joy_axis(0, a)) > 0.01:
			_axis(a, 0.0)
	if paused:
		var pm: Node = current_scene.get_node_or_null("GamePauseMenu") if current_scene != null else null
		if pm != null and pm.overlay != null:
			pm.overlay.hide()
			pm.hint.show()
		paused = false
	await _frames(2)


# ---------------------------------------------------------------- Highbank

func _place_of(town: Node, id: String) -> Dictionary:
	return town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == id)[0]


## Stand the leader on `t`, facing `facing`, with no panel open (a step's setup, not input).
func _stand(scene: Node, t: Vector2i, facing: String) -> void:
	scene.panel = {}
	scene.team[0]["pos"] = t
	scene.team[0]["facing"] = facing
	scene._place(scene.team[0])
	await _frames(2)


func _town() -> Node:
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = STORY.duplicate(true)
	TeamState.data["bag"] = {"reedberry": 2, "lamp_oil": 1}
	var town: Node = load(TOWN).instantiate()
	TeamState.give_to(town)
	change_scene_to_node(town)
	await _until(func() -> bool: return current_scene == town, 30)
	await _frames(12)   # the street comes up out of black
	return town


func _highbank() -> void:
	var town := await _town()
	_ok("Highbank opens as the current scene (%s)" % _scene().get_file(), _scene() == TOWN)
	if _scene() != TOWN:
		return
	# Walk: the left stick, then the D-pad.
	var lead: Dictionary = town.team[0]
	var start: Vector2i = lead["pos"]
	_axis(JOY_AXIS_LEFT_X, 1.0)
	await _until(func() -> bool: return lead["pos"].x >= start.x + 2, 60)
	_axis(JOY_AXIS_LEFT_X, 0.0)
	await _until(func() -> bool: return not town.busy, 30)
	_ok("Highbank: the left stick walks the leader right (%s -> %s)" % [start, lead["pos"]], lead["pos"].x > start.x and lead["pos"].y == start.y)
	await _let_go()
	var from: Vector2i = lead["pos"]
	await _hold_until(JOY_BUTTON_DPAD_LEFT, func() -> bool: return lead["pos"] != from, 30)
	await _until(func() -> bool: return not town.busy, 30)
	_ok("Highbank: the D-pad walks the leader left (%s -> %s)" % [from, lead["pos"]], lead["pos"].x < from.x)
	await _let_go()

	# The Job Board: A opens it at its door, B closes it.
	var board := _place_of(town, "board")
	await _stand(town, board["door"], "n")
	await _tap(JOY_BUTTON_A)
	var opened: bool = String(town.panel.get("service", "")) == "board"
	_ok("Highbank: A at the Job Board opens it (panel '%s')" % String(town.panel.get("name", "")), opened)
	await _let_go()
	if not opened:
		town.panel = town._board_panel(board)   # opened by hand, so B is still tried
		await _frames(2)
	await _tap(JOY_BUTTON_B)
	_ok("Highbank: B closes the Job Board (panel now %s)" % ("closed" if town.panel.is_empty() else "'%s'" % String(town.panel.get("name", ""))),
		town.panel.is_empty() and not paused)
	await _let_go()
	town.panel = {}

	# The Home: A at its door goes in; the D-pad walks back out of the room's door.
	var home := _place_of(town, "home")
	await _stand(town, home["door"], "n")
	await _tap(JOY_BUTTON_A)
	var inside := await _until(func() -> bool: return _scene() == ROOM, 60)
	_ok("Highbank: A at the Home's door goes inside (scene %s)" % _scene().get_file(), inside)
	await _let_go()
	if not inside:
		var made: Node = load(ROOM).instantiate()   # set up by hand, so walking out is still tried
		made.room_id = "home"
		TeamState.data["party"] = [[0, 0], [1, 0]]
		change_scene_to_node(made)
		await _until(func() -> bool: return _scene() == ROOM, 30)
	if _scene() != ROOM:
		_ok("The Home: the room could not be opened to walk out of", false)
		return
	var room: Node = current_scene
	await _frames(12)   # the fade lifts
	var at0: Vector2i = room.team[0]["pos"]
	var door: Vector2i = room.room()["door"]
	var out := await _walk_out(room)
	var at1: String = str(room.team[0]["pos"]) if is_instance_valid(room) and _scene() == ROOM else "outside"
	_ok("The Home: the D-pad walks the team from %s to the door at %s and back to Highbank (leader now %s, scene %s)" % [at0, door, at1, _scene().get_file()], out)
	await _let_go()


## Breadth-first over the room's open tiles from the leader to its door, then each step on the D-pad.
func _walk_out(room: Node) -> bool:
	var goal: Vector2i = room.room()["door"]
	var start: Vector2i = room.team[0]["pos"]
	var came := {start: start}
	var q: Array = [start]
	while not q.is_empty():
		var c: Vector2i = q.pop_front()
		if c == goal:
			break
		for d in STEPS4:
			var n: Vector2i = c + d
			if not came.has(n) and room._open(n) and not room.npcs.any(func(e: Dictionary) -> bool: return e["pos"] == n):
				came[n] = c
				q.append(n)
	if not came.has(goal):
		return false
	var path: Array = []
	var at := goal
	while at != start:
		path.push_front(at)
		at = came[at]
	for step: Vector2i in path:
		if not is_instance_valid(room) or _scene() != ROOM:
			break
		var d: Vector2i = step - room.team[0]["pos"]
		if not PAD.has(d):
			return false
		_button(PAD[d], true)
		var ref: WeakRef = weakref(room)   # a lambda holding the room itself errors once walking out frees it (Claude, 2026-10-23)
		await _until(func() -> bool: return ref.get_ref() == null or _scene() != ROOM or ref.get_ref().team[0]["pos"] == step, 40)
		_button(PAD[d], false)
		await _frames(2)
		if is_instance_valid(room) and _scene() == ROOM:
			await _until(func() -> bool: return ref.get_ref() == null or not ref.get_ref().busy, 30)
	return await _until(func() -> bool: return _scene() == TOWN, 60)


# ---------------------------------------------------------------- Rootbank Warren

## A way the leader can step: open, nobody there, not the stairs.
func _free_dir(dg: Node, p: Vector2i) -> Vector2i:
	for d in STEPS4:
		if dg.can_step(p, d) and dg._occupant(p + d) < 0 and p + d != dg.data["stairs"]:
			return d
	return Vector2i.ZERO


## The floor's wild creatures, traps, items and Monster House taken away, so only the placed creature acts.
func _quiet_floor(dg: Node) -> void:
	dg.traps.clear()
	dg.floor_items.clear()
	dg.monster_room = Rect2i()
	var keep: Array[Dictionary] = []
	for e: Dictionary in dg.ents:
		if e["team"] == 1:
			e["node"].queue_free()
		else:
			keep.append(e)
	dg.ents = keep


func _said(dg: Node, words: String) -> bool:
	return dg.log_lines.any(func(l: String) -> bool: return words in l)


func _move_name(dg: Node, m: String) -> String:
	return String(dg.Arena.MOVES[m]["name"])


func _warren() -> Node:
	TeamState.data["bag"] = {"reedberry": 2, "lamp_oil": 1}
	TeamState.data["story"] = STORY.duplicate(true)
	TeamState.data["party"] = [[0, 0], [1, 0]]
	var dg: Node = load(DUNGEON).instantiate()
	TeamState.give_to(dg)
	dg.dungeon = "first"
	dg.floor_seed = 4242
	dg.return_to_town = true
	change_scene_to_node(dg)
	await _until(func() -> bool: return current_scene == dg, 30)
	await _frames(10)
	return dg


func _dungeon() -> void:
	var dg := await _warren()
	_ok("Rootbank Warren B%dF opens as the current scene (%s)" % [dg.floor_n, _scene().get_file()], _scene() == DUNGEON)
	if _scene() != DUNGEON:
		return
	_quiet_floor(dg)
	await _until(func() -> bool: return not dg.busy, 30)

	# Walk: the D-pad, then the left stick a little off straight (it reads straight inside 30 degrees).
	var lead: Dictionary = dg.ents[0]
	var from: Vector2i = lead["pos"]
	var d := _free_dir(dg, from)
	var walked := false
	if d != Vector2i.ZERO:
		walked = await _hold_until(PAD[d], func() -> bool: return lead["pos"] != from, 45)
		await _until(func() -> bool: return not dg.busy, 60)
	_ok("Rootbank Warren: the D-pad walks the leader (%s -> %s)" % [from, lead["pos"]], walked and lead["pos"] - from == d)
	await _let_go()
	from = lead["pos"]
	d = _free_dir(dg, from)
	walked = false
	if d != Vector2i.ZERO:
		var main_axis := JOY_AXIS_LEFT_X if d.x != 0 else JOY_AXIS_LEFT_Y
		var side_axis := JOY_AXIS_LEFT_Y if d.x != 0 else JOY_AXIS_LEFT_X
		_axis(side_axis, 0.2)
		_axis(main_axis, 0.95 * float(d.x + d.y))
		walked = await _until(func() -> bool: return lead["pos"] != from, 45)
		_axis(main_axis, 0.0)
		_axis(side_axis, 0.0)
		await _until(func() -> bool: return not dg.busy, 60)
	_ok("Rootbank Warren: the left stick, a little off straight, walks the leader straight (%s -> %s, wanted %s)" % [from, lead["pos"], from + d],
		walked and lead["pos"] - from == d)
	await _let_go()
	await _until(func() -> bool: return not dg.busy, 60)

	# A wild creature beside the leader: A attacks it with the basic move.
	var wd := _free_dir(dg, lead["pos"])
	if wd == Vector2i.ZERO:
		_ok("Rootbank Warren: no open tile beside the leader for a wild creature", false)
		return
	var w: Dictionary = dg._make(2, 0, 1, lead["pos"] + wd)
	w["max_hp"] = 99
	w["hp"] = 99
	dg.ents.append(w)
	dg._place(w)
	lead["facing"] = dg._facing_of(wd)
	dg._place(lead)
	var m0: String = lead["moves"][0]
	dg.log_lines.clear()
	await _tap(JOY_BUTTON_A)
	await _until(func() -> bool: return not dg.busy, 120)
	_ok("Rootbank Warren: A attacks the wild %s with %s (its HP 99 -> %d)" % [w["name"], _move_name(dg, m0), w["hp"]],
		w["hp"] < 99 and _said(dg, "used %s!" % _move_name(dg, m0)))
	await _let_go()

	# Move 1: RB held, then A. The chord rule: that A is not also the basic attack.
	if lead["moves"].size() > 1 and lead["hp"] > 0:
		var m1: String = lead["moves"][1]
		var turn0: int = dg.turn
		w["hp"] = maxi(w["hp"], 50)
		dg.log_lines.clear()
		_button(JOY_BUTTON_RIGHT_SHOULDER, true)
		await _frames(2)
		await _tap(JOY_BUTTON_A)
		_button(JOY_BUTTON_RIGHT_SHOULDER, false)
		await _frames(2)
		await _until(func() -> bool: return not dg.busy, 120)
		_ok("Rootbank Warren: RB held and A uses move 1, %s, and not the basic (turn %d -> %d; said: %s)" % [_move_name(dg, m1), turn0, dg.turn, " / ".join(dg.log_lines.slice(0, 2))],
			dg.turn > turn0 and _said(dg, _move_name(dg, m1)) and not _said(dg, "used %s!" % _move_name(dg, m0)))
	else:
		_ok("Rootbank Warren: the leader has a move 1 to use (moves %s, HP %d)" % [str(lead["moves"]), lead["hp"]], false)
	await _let_go()
	# The wild creature leaves, so the bag, the stairs and the menu are tried in peace.
	if dg.ents.has(w):
		dg.ents.erase(w)
		w["node"].queue_free()
	lead["hp"] = maxi(1, int(lead["hp"]))
	await _until(func() -> bool: return not dg.busy, 60)

	# The bag: Y opens it, A eats the first thing in it, the Reedberry.
	dg.bag = {"reedberry": 2, "lamp_oil": 1}
	var berries := int(dg.bag.get("reedberry", 0))
	await _tap(JOY_BUTTON_Y)
	var bag_up: bool = dg.bag_open
	_ok("Rootbank Warren: Y opens the bag", bag_up)
	await _let_go()
	if not bag_up:
		dg.bag_open = true   # opened by hand, so A is still tried
	dg.bag_sel = 0
	await _tap(JOY_BUTTON_A)
	await _until(func() -> bool: return not dg.busy, 90)
	_ok("Rootbank Warren: A eats a Reedberry from the bag (Reedberries %d -> %d)" % [berries, int(dg.bag.get("reedberry", 0))],
		int(dg.bag.get("reedberry", 0)) == berries - 1 and not dg.bag_open)
	dg.bag_open = false
	await _let_go()

	# The stairs: the leader stands on them and X goes down.
	var stairs: Vector2i = dg.data["stairs"]
	var there: int = dg._occupant(stairs)
	if there > 0:
		dg.ents[there]["pos"] = lead["pos"]
		dg._place(dg.ents[there])
	lead["pos"] = stairs
	dg._place(lead)
	await _frames(2)
	var floor0: int = dg.floor_n
	await _tap(JOY_BUTTON_X)
	await _until(func() -> bool: return dg.floor_n != floor0 and not dg.busy, 180)
	_ok("Rootbank Warren: X on the stairs goes down (B%dF -> B%dF)" % [floor0, dg.floor_n], dg.floor_n == floor0 + 1)
	await _let_go()
	await _until(func() -> bool: return not dg.busy, 90)
	await _frames(4)

	# The pause menu: Start opens it, B closes it.
	var pm: Node = dg.get_node_or_null("GamePauseMenu")
	if pm == null:
		_ok("Rootbank Warren: the pause menu is attached", false)
	else:
		await _tap(JOY_BUTTON_START)
		var menu_up: bool = pm.overlay.visible and paused
		_ok("Rootbank Warren: Start opens the pause menu (shown %s, paused %s)" % [str(pm.overlay.visible), str(paused)], menu_up)
		if not menu_up:
			await _let_go()
			pm.open()   # opened by hand, so B is still tried
			await _frames(2)
		await _tap(JOY_BUTTON_B)
		var shut := await _until(func() -> bool: return not paused and not pm.overlay.visible, 30)
		_ok("Rootbank Warren: B closes the pause menu (shown %s, paused %s)" % [str(pm.overlay.visible), str(paused)], shut)
		await _let_go()

	# Down: the faint screen, and A leaves it for Highbank.
	dg.ents[0]["hp"] = 0
	dg._end_turn()
	var down := await _until(func() -> bool: return _scene() == FAINT, 90)
	_ok("The team went down: the faint screen (scene %s)" % _scene().get_file(), down)
	if not down:
		return
	var screen: Node = current_scene
	var presses := 0
	for k in 10:
		if _scene() != FAINT:
			break
		presses += 1
		await _tap(JOY_BUTTON_A)
		await _frames(2)
	var home := await _until(func() -> bool: return _scene() == TOWN, 60)
	_ok("The faint screen: A carries the team home to Highbank (%d presses; scene %s)" % [presses, _scene().get_file()], home and not is_instance_valid(screen))
	await _let_go()


func _run() -> void:
	TeamState.save_path = CHECK_PATH   # never the real save
	TeamState.erase_save()
	await _let_go()
	await _highbank()
	await _let_go()
	await _dungeon()
	await _let_go()
	TeamState.erase_save()
	print("PAD PLAY: %s" % ("all %d steps ok" % steps if fails == 0 else "%d of %d steps FAILED" % [fails, steps]))
	quit(1 if fails else 0)
