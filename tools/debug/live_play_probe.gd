extends SceneTree
## The live play probe (Claude, 2026-10-26, pass 8 U8 for LH8-13; moved here from the pass 7 live audit's scratch
## probe and the story lane's real-time pacing copy). It plays the real game windowed with real key or pad events
## (Input.parse_input_event), as a player who reads each page of a line for READ_MS after the page finishes typing,
## then presses on. It logs every line and page, every sound start (stream, bus, the input before it), each scene
## change with the time spent, frame luminance (black and frozen frames), stalls, the quiet stretches between lines,
## and at the end one PACE row per place: its longest quiet and its longest gap between text starts, by the wall clock.
##
## Page-aware: a line that runs to two pages is read a page at a time. The reader waits for UI._line.done (the page on
## screen has finished typing), reads it, presses, and waits again for the next page; it never presses through a page
## still typing and never waits on a line's later pages before pressing.
##
## The clock: pacing numbers (PACE, QUIET) are a player's only when the game runs in real time. Run the pacing
## phases (story, town) at --max-fps 30 WITHOUT --fixed-fps: under --fixed-fps a frame is a thirtieth of a second of
## game time however long it takes, so the game's clock and the wall clock part (the pass 7 audit's ran twice the
## wall clock and logged 13.5 to 15.3 s in the Hall that a player never sees). The probe logs which clock it ran on.
##   Godot --path <proj> --max-fps 30 --audio-driver Dummy --script res://tools/debug/live_play_probe.gd --
##       --phase story|town|storage|dungeon|pad|title|menus|hollowtime --save <a .save to copy> [--tag name]
##       [--out <folder>] [--pad] [--nolum] [--into-dungeon]
## Run it with APPDATA pointed at a temp folder: the save is copied into the output folder (user://live_play_probe/<tag>/
## unless --out names one) and the game plays that copy, never the player's own. Not a check: it judges nothing, the
## log is read by a person (or the PACE rows by a script).

const UI := preload("res://scripts/ui/ui_style.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const Objective := preload("res://scripts/town/objective.gd")
const READ := 45          # frames a menu or panel is left up for a look (the menus and panels, not the lines)
const READ_MS := 1500     # how long the reader keeps a finished page up, by the wall clock
const PACING := ["story", "town"]   # the phases whose PACE rows are about a player's time

var phase := "story"
var pad_mode := false
var no_lum := false
var save_src := ""
var OUT := ""
var prefix := "S"
var frame := 0
var shot_n := 0
var logf: FileAccess
var audiof: FileAccess
var lumf: FileAccess
var players := {}
var action := "start"
var action_frame := 0
var last_scene := ""
var scene_t0 := 0
var scene_w0 := 0
var last_line := ""
var last_log_n := 0
var last_panel := ""
var _wall := 0
var _prev_hash := 0
var marks: Array = []
var lines_seen := 0
var was_talking := false
var quiet_from := -1
var quiet_w := -1          # wall ms when the last line went away
var last_page := 0
var real_time := true      # false under --fixed-fps (the clock check in _initialize)
var into_dungeon := false  # the story phase plays on into a Hollow instead of stopping at its door
var place := ""            # the scene, and the room in town_room.tscn ("town_room.tscn:hall")
var last_start := -1       # wall ms of the last text start (a new line or a new page) in this place
var pace := {}             # place -> {"quiet": longest quiet ms, "gap": longest gap ms, "gaps": n, "lines": n}


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var i := a.find("--phase")
	if i >= 0:
		phase = a[i + 1]
	i = a.find("--save")
	if i >= 0:
		save_src = a[i + 1]
	pad_mode = a.has("--pad")
	no_lum = a.has("--nolum")
	into_dungeon = a.has("--into-dungeon")
	prefix = {"story": "S", "town": "T", "pad": "P", "dungeon": "D", "title": "O", "endcard": "E", "storage": "K", "walls": "W"}.get(phase, "X")
	var tag: String = a[a.find("--tag") + 1] if a.has("--tag") else phase
	OUT = a[a.find("--out") + 1] if a.has("--out") else ProjectSettings.globalize_path("user://live_play_probe/%s" % tag)
	OUT = OUT.replace("\\", "/").trim_suffix("/") + "/"
	DirAccess.make_dir_recursive_absolute(OUT + "shots")
	real_time = not OS.get_cmdline_args().has("--fixed-fps")
	logf = FileAccess.open(OUT + "log.txt", FileAccess.WRITE)
	audiof = FileAccess.open(OUT + "audio.tsv", FileAccess.WRITE)
	audiof.store_line("frame\tscene\taction\tsince\tstream\tbus\tdb")
	lumf = FileAccess.open(OUT + "lum.tsv", FileAccess.WRITE)
	node_added.connect(_on_added)
	_run.call_deferred()


# ------------------------------------------------------------------ watchers

func L(s: String) -> void:
	var t := "[%05d %6.1fs w%8d] %s" % [frame, frame / 30.0, Time.get_ticks_msec(), s]
	print(t)
	logf.store_line(t)
	logf.flush()


func _on_added(n: Node) -> void:
	if n is AudioStreamPlayer or n is AudioStreamPlayer2D:
		players[n.get_instance_id()] = [false, 0.0, null]


func _scene() -> String:
	return current_scene.scene_file_path.get_file() if current_scene != null and is_instance_valid(current_scene) else "none"


func _audio_poll() -> void:
	for id in players.keys():
		var p: Object = instance_from_id(id)
		if p == null or not is_instance_valid(p):
			players.erase(id)
			continue
		var w: Array = players[id]
		var playing: bool = p.playing
		var pos: float = p.get_playback_position() if playing else 0.0
		var st: Resource = p.stream
		if playing and (not w[0] or st != w[2] or pos + 0.04 < float(w[1])):
			var sp := "null"
			if st != null:
				sp = st.resource_path.trim_prefix("res://assets/audio/") if st.resource_path != "" else st.get_class()
			audiof.store_line("%d\t%s\t%s\t%d\t%s\t%s\t%.1f" % [frame, _scene(), action, frame - action_frame, sp, String(p.bus), p.volume_db])
			audiof.flush()
		players[id] = [playing, pos, st]


func _text_watch() -> void:
	var s := current_scene
	var file := _scene()
	if file != last_scene:
		L("SCENE %s -> %s after %.1f s game, %.1f s wall in %s" % [last_scene, file, (frame - scene_t0) / 30.0, (Time.get_ticks_msec() - scene_w0) / 1000.0, last_scene])
		last_scene = file
		scene_t0 = frame
		scene_w0 = Time.get_ticks_msec()
		last_log_n = 0
	var here := file + (":" + String(s.room_id) if s != null and is_instance_valid(s) and "room_id" in s else "")
	if here != place:
		place = here
		last_start = -1     # gaps and quiet stretches are counted inside one place
		quiet_from = -1
		quiet_w = -1
	var now := Time.get_ticks_msec()
	var talking := _talking()
	if talking != was_talking:
		if talking:
			if quiet_from >= 0:
				L("QUIET %.2f s wall (%.2f s game) before this line (cutscene %s)" % [(now - quiet_w) / 1000.0, (frame - quiet_from) / 30.0, str(s.cutscene) if s != null and is_instance_valid(s) and "cutscene" in s else "?"])
				_pace("quiet", now - quiet_w)
		else:
			quiet_from = frame
			quiet_w = now
		was_talking = talking
	var pg := int(UI._line.get("page", 0))
	if pg != last_page and String(UI._line.get("text", "")) == last_line and last_line != "":
		L("PAGE %d of [%s]" % [pg + 1, last_line.left(30)])
		_text_start(now)
	last_page = pg
	var line := String(UI._line.get("text", ""))
	if line != last_line:
		last_line = line
		if line != "":
			lines_seen += 1
			_text_start(now)
			var who := ""
			if s != null and is_instance_valid(s) and "talk" in s and s.talk is Array and not s.talk.is_empty() and s.talk[0] is Array:
				who = str(s.talk[0][0])
			L("LINE [%s] %s" % [who, line.replace("\n", " / ")])
	if s == null or not is_instance_valid(s):
		return
	if "panel" in s and s.panel is Dictionary:
		var svc := ""
		if not s.panel.is_empty():
			svc = "%s|%s|%s" % [str(s.panel.get("service", "")), str(s.panel.get("name", "")), str(s.panel.get("what", "")).replace("\n", " / ")]
		if svc != last_panel:
			last_panel = svc
			if svc != "":
				L("PANEL " + svc)
	if file == "dungeon.tscn" and "log_lines" in s:
		var ll: Array = s.log_lines
		if ll.size() < last_log_n:
			last_log_n = 0
		for k in range(last_log_n, ll.size()):
			L("LOG " + String(ll[k]))
		last_log_n = ll.size()


## A line or a page began typing at `now` (wall ms): the gap since the last one in this place.
func _text_start(now: int) -> void:
	if last_start >= 0:
		_pace("gap", now - last_start)
	last_start = now
	_pace("lines", 1)


## One PACE number for the place the probe is in: the longest quiet and gap, the counts.
func _pace(what: String, n: int) -> void:
	var row: Dictionary = pace.get(place, {"quiet": 0, "gap": 0, "gaps": 0, "lines": 0})
	match what:
		"quiet":
			row["quiet"] = maxi(int(row["quiet"]), n)
		"gap":
			row["gap"] = maxi(int(row["gap"]), n)
			row["gaps"] = int(row["gaps"]) + 1
		"lines":
			row["lines"] = int(row["lines"]) + n
	pace[place] = row


func _lum() -> void:
	if no_lum:
		return
	var img := root.get_texture().get_image()
	if img == null:
		return
	img.resize(32, 18, Image.INTERPOLATE_NEAREST)
	img.convert(Image.FORMAT_RGB8)
	var d := img.get_data()
	var sum := 0
	for b in d:
		sum += b
	var h := d.hex_encode().hash()
	lumf.store_line("%d\t%d\t%s\t%.1f\t%d" % [frame, Time.get_ticks_msec(), _scene(), sum / float(d.size()), 1 if h == _prev_hash else 0])
	_prev_hash = h


func F(n := 1) -> void:
	for k in n:
		await process_frame
		frame += 1
		var now := Time.get_ticks_msec()
		if _wall > 0 and now - _wall > 250:
			L("HITCH %d ms for one frame in %s (after %s)" % [now - _wall, _scene(), action])
		_wall = now
		_audio_poll()
		_text_watch()
		_lum()


func until(done: Callable, budget := 90) -> bool:
	for k in budget:
		if done.call():
			return true
		await F()
	return done.call()


func snap(name: String) -> String:
	await RenderingServer.frame_post_draw
	shot_n += 1
	var id := "%s%02d_%s" % [prefix, shot_n, name]
	var img := root.get_texture().get_image()
	img.save_png(OUT + "shots/" + id + ".png")
	L("SHOT %s scene %s" % [id, _scene()])
	return id


func mark(what: String) -> void:
	marks.append([what, frame, Time.get_ticks_msec(), lines_seen])
	L("MARK %s (game %.1f s, lines so far %d)" % [what, frame / 30.0, lines_seen])


# ------------------------------------------------------------------ input

func _bind(act: StringName, want_pad: bool) -> InputEvent:
	if not InputMap.has_action(act):
		return null
	for ev: InputEvent in InputMap.action_get_events(act):
		if want_pad and (ev is InputEventJoypadButton or ev is InputEventJoypadMotion):
			return ev
		if not want_pad and ev is InputEventKey:
			return ev
	return null


func _send(ev: InputEvent, down: bool) -> void:
	if ev is InputEventKey:
		var e := InputEventKey.new()
		var code: int = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
		e.keycode = code
		e.physical_keycode = code
		e.pressed = down
		Input.parse_input_event(e)
	elif ev is InputEventJoypadButton:
		var b := InputEventJoypadButton.new()
		b.device = 0
		b.button_index = ev.button_index
		b.pressed = down
		Input.parse_input_event(b)
	elif ev is InputEventJoypadMotion:
		var m := InputEventJoypadMotion.new()
		m.device = 0
		m.axis = ev.axis
		m.axis_value = ev.axis_value if down else 0.0
		Input.parse_input_event(m)


## One press of an action on the device in play (keyboard, or the pad with --pad).
func press(act: StringName, hold := 3, gap := 6) -> void:
	var ev := _bind(act, pad_mode)
	if ev == null:
		L("NO BINDING for %s on %s" % [act, "pad" if pad_mode else "keyboard"])
		return
	action = "%s(%s)" % [act, UI.event_text(ev)]
	action_frame = frame
	_send(ev, true)
	await F(hold)
	_send(ev, false)
	await F(gap)


func key(code: int, hold := 3, gap := 6, label := "") -> void:
	action = label if label != "" else OS.get_keycode_string(code)
	action_frame = frame
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = true
	Input.parse_input_event(e)
	await F(hold)
	var u := InputEventKey.new()
	u.keycode = code
	u.physical_keycode = code
	u.pressed = false
	Input.parse_input_event(u)
	await F(gap)


func pad_button(b: int, hold := 3, gap := 6, label := "") -> void:
	action = label if label != "" else "pad%d" % b
	action_frame = frame
	var ev := InputEventJoypadButton.new()
	ev.device = 0
	ev.button_index = b
	ev.pressed = true
	Input.parse_input_event(ev)
	await F(hold)
	var u := InputEventJoypadButton.new()
	u.device = 0
	u.button_index = b
	u.pressed = false
	Input.parse_input_event(u)
	await F(gap)


func _dir_down(d: Vector2i, down: bool) -> void:
	if pad_mode:
		for ax in [[JOY_AXIS_LEFT_X, d.x], [JOY_AXIS_LEFT_Y, d.y]]:
			var m := InputEventJoypadMotion.new()
			m.device = 0
			m.axis = ax[0]
			m.axis_value = float(ax[1]) * 0.9 if down else 0.0
			Input.parse_input_event(m)
		return
	var keys: Array = []
	if d.x < 0: keys.append(KEY_A)
	if d.x > 0: keys.append(KEY_D)
	if d.y < 0: keys.append(KEY_W)
	if d.y > 0: keys.append(KEY_S)
	for c in keys:
		var e := InputEventKey.new()
		e.keycode = c
		e.physical_keycode = c
		e.pressed = down
		Input.parse_input_event(e)


func _lead_pos() -> Vector2i:
	var s := current_scene
	if s == null or not ("team" in s) or s.team.is_empty():
		return Vector2i(-99, -99)
	return s.team[0]["pos"]


## One step in direction d: hold until the leader's tile changes (or 24 frames), then let go.
func step(d: Vector2i) -> bool:
	var was := _lead_pos()
	action = "step %s" % str(d)
	action_frame = frame
	_dir_down(d, true)
	var moved := await until(func() -> bool: return _lead_pos() != was, 24)
	_dir_down(d, false)
	await F(2)
	await until(func() -> bool: return current_scene == null or not ("busy" in current_scene) or not current_scene.busy, 20)
	return moved


func _walkable(t: Vector2i) -> bool:
	var s := current_scene
	if s == null:
		return false
	if s.has_method("open_at"):
		return s.open_at(t)
	if s.has_method("_open"):
		if "npcs" in s:
			for n in s.npcs:
				if n["pos"] == t:
					return false
		return s._open(t)
	return false


func _path(from: Vector2i, to: Vector2i) -> Array:
	var prev := {from: from}
	var q: Array = [from]
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
	while not q.is_empty():
		var c: Vector2i = q.pop_front()
		if c == to:
			break
		for d: Vector2i in dirs:
			var n: Vector2i = c + d
			if prev.has(n) or n.x < 0 or n.y < 0 or n.x > 80 or n.y > 60:
				continue
			if not (_walkable(n) or n == to):
				continue
			if d.x != 0 and d.y != 0 and (not _walkable(c + Vector2i(d.x, 0)) or not _walkable(c + Vector2i(0, d.y))):
				continue
			prev[n] = c
			q.append(n)
	if not prev.has(to):
		return []
	var out: Array = []
	var c2: Vector2i = to
	while c2 != from:
		out.push_front(c2 - prev[c2])
		c2 = prev[c2]
	return out


## Walk the leader to `to` along open ground, step by step with real input; stops early if the scene changes or a
## scene starts (cutscene). True when it got there.
func walk_to(to: Vector2i, max_steps := 120) -> bool:
	var sc := _scene()
	for tries in 4:
		var path := _path(_lead_pos(), to)
		if path.is_empty():
			L("WALK no path from %s to %s in %s" % [str(_lead_pos()), str(to), sc])
			return false
		for d in path:
			if _scene() != sc or ("cutscene" in current_scene and current_scene.cutscene):
				return false
			if not await step(d):
				break
			max_steps -= 1
			if max_steps <= 0:
				return false
		if _lead_pos() == to:
			return true
	return _lead_pos() == to


func face(d: Vector2i) -> void:
	# a tap that turns without stepping into a wall: the leader turns when the step is blocked
	_dir_down(d, true)
	await F(2)
	_dir_down(d, false)
	await F(4)


## Read the page that is up, as a player: wait until it has finished typing (UI._line.done is the page on screen, not
## the whole line), keep it up READ_MS by the wall clock, then press on. A two-page line is two calls: the press turns
## the page and the next call waits for that page to finish typing.
func read_line() -> void:
	var line := String(UI._line.get("text", ""))
	var page := int(UI._line.get("page", 0))
	await until(func() -> bool: return line == "" or bool(UI._line.get("done", true)) or String(UI._line.get("text", "")) != line or int(UI._line.get("page", 0)) != page, 240)
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < READ_MS:
		await F()
	await press(&"interact" if not pad_mode else &"confirm", 3, 4)


func _talking() -> bool:
	var s := current_scene
	if s == null or not is_instance_valid(s):
		return false
	if "talk" in s and s.talk is Array and not s.talk.is_empty():
		return true
	return false


## Keep reading while the scene has lines up; stop when none for `quiet` frames.
func read_all(budget := 6000, quiet := 75) -> int:
	var n := 0
	var idle := 0
	for k in budget:
		if _talking():
			idle = 0
			if n % 6 == 0:
				await snap("line%02d" % n)
			await read_line()
			n += 1
		else:
			idle += 1
			if idle >= quiet:
				break
			await F()
	return n


# ------------------------------------------------------------------ dungeon play

## Play the dungeon the way a player who leans on autopilot would: Tab, read lines, welcome recruits, learn moves.
func play_dungeon(budget_frames := 30 * 900, shot_every := 600) -> String:
	var since := 0
	var t0 := frame
	while frame - t0 < budget_frames:
		var s := current_scene
		var file := _scene()
		if file != "dungeon.tscn":
			return file
		if s.ents.is_empty() or s._finishing:
			await F()
			continue
		since += 1
		if since >= shot_every:
			since = 0
			await snap("B%dF_turn%d" % [int(s.floor_n), int(s.turn)])
		if s.asking >= 0:
			await snap("recruit_ask")
			await F(READ)
			await press(&"yes")
			continue
		if s.teach_kind != "":
			await snap("teach_" + String(s.teach_kind).validate_filename().left(16))
			await F(READ)
			if s.skip_ask:
				await press(&"yes")
			else:
				await press(&"confirm")
			continue
		if not s.talk.is_empty():
			await read_line()
			continue
		if s.cutscene or s.busy:
			await F()
			continue
		if not s.autopilot:
			await press(&"autopilot")
			await F(4)
			continue
		await F()
	return _scene()


# ------------------------------------------------------------------ title

func title_continue() -> void:
	change_scene_to_file("res://scenes/creature_opening.tscn")
	await F(2)
	await until(func() -> bool: return current_scene != null and "_boot_done" in current_scene and current_scene._boot_done, 30 * 20)
	await F(10)
	await snap("title_boot")
	# past "Enter to continue" if it asks, then Continue (the first row when a save exists)
	for k in 6:
		if _scene() != "creature_opening.tscn":
			break
		var f := root.gui_get_focus_owner()
		if f != null and String(f.name) == "Continue":
			await snap("title_continue_focused")
			await press(&"ui_accept")
			break
		await press(&"ui_accept")
		await F(20)
	await until(func() -> bool: return _scene() != "creature_opening.tscn", 30 * 10)


func wait_town() -> Node:
	await until(func() -> bool: return _scene() == "hub_town.tscn" and not current_scene.team.is_empty(), 30 * 20)
	await F(20)
	return current_scene if _scene() == "hub_town.tscn" else null


func use_save() -> void:
	if save_src == "":
		return
	var dst := OUT + "slot.save"
	DirAccess.copy_absolute(save_src, dst)
	TeamState.save_path = dst
	L("save %s -> %s" % [save_src, dst])


# ------------------------------------------------------------------ phases

func _run() -> void:
	L("phase %s, %s, window %s, out %s" % [phase, "pad" if pad_mode else "keyboard", str(root.size), OUT])
	L("CLOCK %s, max fps %d" % ["real time" if real_time else "fixed (--fixed-fps): wall and game clocks part", Engine.max_fps])
	if not real_time and phase in PACING:
		L("CLOCK WARNING: the PACE and QUIET numbers of a %s run are a player's only without --fixed-fps (use --max-fps 30)" % phase)
	use_save()
	match phase:
		"story":
			await phase_story()
		"town":
			await phase_town()
		"storage":
			await phase_storage()
		"dungeon":
			await phase_dungeon()
		"pad":
			await phase_pad()
		"title":
			await phase_title()
		"menus":
			await phase_menus()
		"hollowtime":
			await phase_hollowtime()
	L("MARKS " + str(marks))
	for p in pace:
		var row: Dictionary = pace[p]
		L("PACE %s: longest quiet %.2f s, longest gap between text starts %.2f s over %d gaps, %d text starts (%s)" % [p,
			int(row["quiet"]) / 1000.0, int(row["gap"]) / 1000.0, int(row["gaps"]), int(row["lines"]), "real time" if real_time else "fixed clock"])
	L("DONE phase %s in %.1f s game, %.1f s wall" % [phase, frame / 30.0, Time.get_ticks_msec() / 1000.0])
	quit(0)


func _objective() -> Dictionary:
	var d := TeamState.data
	return Objective.current(d.get("story", {}), d.get("beaten", []))


## Where the objective points in Highbank, and whether to press E there.
func _goal_tile(goal: String) -> Array:
	if "Job Board" in goal:
		return [Vector2i(26, 9), false]
	if "Starward" in goal or "Wayline Tower" in goal:
		return [Vector2i(24, 6), true]
	if "Rootbank" in goal or "The Hollow" in goal or "Hollow" in goal and not "Shrine" in goal:
		return [Vector2i(33, 28), false]
	if "Shrine" in goal:
		return [Vector2i(7, 12), true]
	return [Vector2i(-1, -1), false]


func phase_story() -> void:
	await title_continue()
	var town := await wait_town()
	mark("highbank arrival")
	await snap("arrive")
	var mail_done := false
	var guard := 0
	while guard < 600:
		guard += 1
		var file := _scene()
		var s := current_scene
		if file == "hub_town.tscn":
			if s.cutscene or _talking():
				await snap("scene")
				var n := await read_all()
				mark("town scene read, %d lines" % n)
				continue
			if not s.panel.is_empty():
				await snap("panel_" + str(s.panel.get("service", "")))
				var svc := str(s.panel.get("service", ""))
				await F(READ)
				if svc in ["stone_ask", "evolve_ask"]:
					await press(&"interact")
					await F(30)
					if svc == "evolve_ask":
						mark("growth starts")
						await until(func() -> bool: return not current_scene.evolving_now, 30 * 90)
						await F(30)
						await snap("after_growth")
						mark("growth ends")
						await F(READ)
						await press(&"interact")   # close the result: the end card rolls
						await F(30)
						await snap("endcard_start")
						mark("end card starts")
						await _read_endcard()
						mark("end card done")
						return
				else:
					await press(&"interact")
				continue
			var goal := String(_objective()["short"])
			var g := _goal_tile(goal)
			L("OBJECTIVE '%s' -> %s" % [goal, str(g)])
			await snap("objective")
			if g[0] == Vector2i(-1, -1):
				L("no goal tile, stop")
				return
			await walk_to(g[0])
			if g[1] and _scene() == "hub_town.tscn" and not current_scene.cutscene:
				if not "Shrine" in goal:
					await face(Vector2i(0, -1))   # a building door: turn to it (the shrine is open ground, stand on it)
				await press(&"interact")
			await F(10)
			continue
		if file == "town_room.tscn":
			if s.cutscene or _talking():
				await snap("room_scene")
				var n2 := await read_all()
				mark("room scene read (%s), %d lines" % [s.room_id, n2])
				continue
			var st: Dictionary = TeamState.data.get("story", {})
			if s.room_id == "hall" and st.get("runner", false) and not mail_done:
				mail_done = true
				await walk_to(Vector2i(14, 10))
				await until(func() -> bool: return _scene() == "town_room.tscn" and current_scene.room_id == "hall_low", 30 * 8)
				await F(10)
				await snap("hall_low")
				continue
			if s.room_id == "hall_low":
				await walk_to(Vector2i(25, 13))
				await F(20)
				continue
			# leave the room by its door
			var dr: Vector2i = s.room()["door"]
			mark("leave room %s" % s.room_id)
			await walk_to(dr)
			await F(20)
			continue
		if file == "dungeon.tscn":
			if not into_dungeon:
				mark("dungeon %s starts: stop" % str(s.dungeon))
				return
			await snap("dungeon_start")
			var where := await play_dungeon(30 * 1200)
			mark("dungeon left to %s" % where)
			continue
		if file == "hollow_approach.tscn":
			await until(func() -> bool: return _scene() != "hollow_approach.tscn" or current_scene.ready_to_cross, 30 * 15)
			await snap("approach")
			await F(READ)
			await press(&"ui_accept")
			await F(30)
			continue
		if file == "faint_screen.tscn":
			await snap("faint")
			await F(READ)
			await press(&"interact")
			await F(30)
			continue
		await F(30)


func _read_endcard() -> void:
	for k in 60:
		var s := current_scene
		if s == null or not s.has_node("PilotEnd"):
			break
		await F(60)
		await snap("endcard%02d" % k)
		await press(&"interact")
	await F(30)
	await snap("after_endcard")


func phase_town() -> void:
	await title_continue()
	var town := await wait_town()
	if town == null:
		L("no town")
		return
	await snap("arrive")
	await F(60)
	await snap("arrive_settled")
	# the field menu in town
	await press(&"pause")
	await F(15)
	await snap("menu_town")
	await press(&"move_down")
	await snap("menu_town_down")
	await press(&"cancel")
	await F(10)
	# home: door, the bed
	await walk_to(Vector2i(5, 7))
	await face(Vector2i(0, -1))
	await press(&"interact")
	await until(func() -> bool: return _scene() == "town_room.tscn", 30 * 5)
	await F(20)
	await snap("home")
	await walk_to(Vector2i(4, 3))
	await face(Vector2i(-1, 0))
	await press(&"interact")
	await F(20)
	await snap("bed_panel")
	await press(&"interact")
	await F(90)
	await snap("bed_after")
	await F(60)
	await snap("bed_after2")
	if not current_scene.panel.is_empty():
		await press(&"interact")
	await walk_to(current_scene.room()["door"])
	await wait_town()
	# an NPC in town, if any
	var s := current_scene
	if "npcs" in s and not s.npcs.is_empty():
		var n: Dictionary = s.npcs[0]
		L("NPC %s at %s" % [str(n.get("form", "")), str(n["pos"])])
		var spot: Vector2i = n["pos"] + Vector2i(0, 1)
		await walk_to(spot)
		await face(Vector2i(0, -1))
		await press(&"interact")
		await F(20)
		await snap("npc")
		await read_all()
	# the Job Board
	await walk_to(Vector2i(26, 8))
	await face(Vector2i(0, -1))
	await press(&"interact")
	await F(20)
	await snap("board")
	await press(&"move_down")
	await snap("board_down")
	await press(&"interact")
	await F(10)
	await snap("board_pick")
	await press(&"cancel")
	await F(10)
	# the Wayline Hall, in and out
	await walk_to(Vector2i(24, 6))
	await face(Vector2i(0, -1))
	await press(&"interact")
	await until(func() -> bool: return _scene() == "town_room.tscn", 30 * 5)
	await F(20)
	await snap("hall")
	await read_all()
	# talk to someone in the Hall if anyone stands there
	var rm := current_scene
	if "npcs" in rm:
		for n2 in rm.npcs:
			if n2.has("lines"):
				L("HALL NPC %s at %s" % [str(n2.get("form", "")), str(n2["pos"])])
				for off in [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]:
					if _walkable(n2["pos"] + off) and await walk_to(n2["pos"] + off):
						await face(-off)
						await press(&"interact")
						await F(20)
						await snap("hall_npc")
						await read_all()
						break
				break
	await walk_to(current_scene.room()["door"])
	await wait_town()
	await snap("back_out")


func phase_storage() -> void:
	await title_continue()
	var town := await wait_town()
	if town == null:
		return
	await walk_to(Vector2i(40, 7))
	await face(Vector2i(0, -1))
	await press(&"interact")
	await until(func() -> bool: return _scene() == "town_room.tscn", 30 * 5)
	await F(20)
	await snap("storage_room")
	await walk_to(Vector2i(8, 7))
	await face(Vector2i(0, -1))
	await press(&"interact")
	await F(15)
	await snap("storage_panel")
	L("ROWS " + str(current_scene.storage_rows()))
	await press(&"interact")   # put one in
	await F(10)
	await snap("storage_put")
	L("ROWS " + str(current_scene.storage_rows()) + " bag " + str(TeamState.data.get("bag", {})))
	await press(&"take_out")   # take one out
	await F(10)
	await snap("storage_take")
	L("ROWS " + str(current_scene.storage_rows()) + " bag " + str(TeamState.data.get("bag", {})))
	await press(&"move_up")   # the list wraps: up from the top is the last row, a kind kept but not carried
	await F(6)
	await snap("storage_last_row")
	await press(&"take_out")   # nine kinds in the bag: this one makes ten
	await F(10)
	await snap("storage_tenth")
	L("ROWS " + str(current_scene.storage_rows()) + " bag " + str(TeamState.data.get("bag", {})))
	await press(&"move_up")   # the rows keep their order while the panel is open: the kept-only row is just above
	await F(6)
	await snap("storage_eleventh_row")
	await press(&"take_out")   # an eleventh kind: refused
	await F(10)
	await snap("storage_cap")
	L("ROWS " + str(current_scene.storage_rows()) + " bag " + str(TeamState.data.get("bag", {})))
	await press(&"cancel")
	await F(10)
	await snap("storage_closed")


func phase_dungeon() -> void:
	await title_continue()
	var town := await wait_town()
	if town == null:
		return
	# the way down, pick the first row (Hollow Mouth)
	await walk_to(Vector2i(33, 27))
	await walk_to(Vector2i(33, 28))
	await F(20)
	await snap("way_pick")
	await press(&"interact")
	await until(func() -> bool: return _scene() == "dungeon.tscn" and not current_scene.ents.is_empty(), 30 * 15)
	await F(5)
	await snap("floor_card_or_start")
	await F(60)
	await snap("b1f")
	await clear_teach()
	var dg := current_scene
	# a fight: walk at the nearest foe with keys, attack with J, then a move with 1
	await _fight(dg)
	await press(&"bag")
	await F(10)
	await snap("bag_open")
	await press(&"move_down")
	await snap("bag_down")
	await press(&"bag")
	await F(10)
	await press(&"tactics")
	await F(10)
	await snap("team_orders")
	await press(&"log")
	await F(10)
	await snap("log_open")
	await press(&"log")
	await F(10)
	await press(&"pause")
	await F(15)
	await snap("field_menu")
	for k in 6:
		await press(&"move_down")
		await snap("field_menu_row%d" % k)
	await press(&"cancel")
	await F(15)
	await press(&"rest")
	await F(10)
	await snap("rested")
	# on with autopilot to the stairs and B2F
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
	if current_scene.autopilot:
		await press(&"autopilot")
	await _fight(current_scene)
	await snap("b2f_after_fight")


## Walk at the nearest awake foe with direction keys, then J; then the first move with 1.
func _fight(dg: Node) -> void:
	for k in 40:
		if _scene() != "dungeon.tscn":
			return
		var lead: Dictionary = dg.ents[0]
		var near: Dictionary = {}
		var best := 999
		for e in dg.ents:
			if e["team"] == 1 and e["hp"] > 0:
				var dd: int = maxi(absi(e["pos"].x - lead["pos"].x), absi(e["pos"].y - lead["pos"].y))
				if dd < best:
					best = dd
					near = e
		if near.is_empty():
			L("FIGHT no foe on the floor")
			return
		if best <= 1:
			await snap("foe_adjacent")
			await press(&"attack")
			await until(func() -> bool: return not dg.busy, 60)
			await snap("attacked")
			await press(&"move_slot_1")
			await until(func() -> bool: return not dg.busy, 60)
			await F(10)
			await snap("move_used")
			return
		var d2: Vector2i = (near["pos"] - lead["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))
		_dir_down(d2, true)
		await F(6)
		_dir_down(d2, false)
		await until(func() -> bool: return not dg.busy, 60)
		if not dg.talk.is_empty():
			await read_line()
		if dg.asking >= 0:
			await press(&"no")


func phase_pad() -> void:
	pad_mode = true
	await title_continue()
	var town := await wait_town()
	if town == null:
		return
	await snap("arrive_pad")
	await walk_to(Vector2i(26, 8))
	await face(Vector2i(0, -1))
	await press(&"interact")
	await F(20)
	await snap("board_pad")
	await press(&"move_down")
	await snap("board_pad_down")
	await press(&"confirm")
	await F(10)
	await snap("board_pad_pick")
	await press(&"cancel")
	await F(10)
	await press(&"pause")
	await F(15)
	await snap("pause_town_pad")
	await press(&"cancel")
	await F(10)
	await walk_to(Vector2i(33, 27))
	await walk_to(Vector2i(33, 28))
	await F(20)
	await snap("way_pick_pad")
	await press(&"confirm")
	await until(func() -> bool: return _scene() == "dungeon.tscn" and not current_scene.ents.is_empty(), 30 * 15)
	await F(60)
	await snap("b1f_pad")
	await clear_teach()
	await _fight(current_scene)
	await press(&"bag")
	await F(10)
	await snap("bag_pad")
	await press(&"confirm")
	await F(20)
	await snap("bag_used_pad")
	await press(&"pause")
	await F(15)
	await snap("pause_dungeon_pad")
	await press(&"cancel")
	await F(15)
	var b := int(current_scene.floor_n)
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
	await snap("stairs_pad")
	await F(40)
	await snap("b2f_pad")


func phase_title() -> void:
	change_scene_to_file("res://scenes/creature_opening.tscn")
	await F(2)
	for k in [10, 30, 60, 90, 150]:
		await F(20)
		await snap("logo_f%d" % frame)
	await until(func() -> bool: return current_scene != null and "_boot_done" in current_scene and current_scene._boot_done, 30 * 20)
	await F(30)
	await snap("title_ready")
	var f0 := root.gui_get_focus_owner()
	L("TITLE FOCUS %s" % (String(f0.name) if f0 != null else "(none)"))
	# Options
	for k in 6:
		var f := root.gui_get_focus_owner()
		if f != null and String(f.name) == "Options":
			break
		await press(&"ui_down")
	await press(&"ui_accept")
	await F(20)
	await snap("options")
	for k in 8:
		await press(&"ui_down")
		await snap("options_row%d" % k)
		var f2 := root.gui_get_focus_owner()
		L("FOCUS %s" % (String(f2.name) + " " + str(f2.get("text")) if f2 != null else "(none)"))
		if f2 != null and "Rebind" in String(f2.name):
			await press(&"ui_accept")
			await F(20)
			await snap("rebind")
			for j in 6:
				await press(&"ui_down")
			await snap("rebind_down")
			await press(&"ui_cancel")
			await F(15)
			await snap("rebind_back")
			break
	await press(&"ui_cancel")
	await F(15)
	await snap("options_closed")
	for k in 6:
		var f3 := root.gui_get_focus_owner()
		if f3 != null and String(f3.name) == "HowToPlay":
			break
		await press(&"ui_down")
	await press(&"ui_accept")
	await F(20)
	await snap("howto")
	await press(&"ui_right")
	await press(&"ui_accept")
	await F(10)
	await snap("howto_controls")
	await press(&"ui_cancel")
	await F(15)
	# New Game
	for k in 6:
		var f4 := root.gui_get_focus_owner()
		if f4 != null and String(f4.name) == "NewGame":
			break
		await press(&"ui_up")
	await snap("newgame_focus")
	await press(&"ui_accept")
	await F(30)
	await snap("newgame_pressed")
	var t0 := frame
	var last := ""
	while frame - t0 < 30 * 400:
		var file := _scene()
		if file != last:
			last = file
			mark("opening scene " + file)
			await F(15)
			await snap("open_" + file.get_basename())
		if file == "waking_riverbank.tscn":
			await F(90)
			await snap("riverbank")
			break
		if file == "soul_prologue.tscn" or file == "storm_open.tscn" or file == "creature_prologue.tscn" or file == "opening_flow.tscn":
			if (frame - t0) % 150 == 0:
				await snap("open_%d" % frame)
			await F(READ)
			await press(&"ui_accept")
			continue
		await F(5)


## Timing only: Continue, the way down to The Hollow, its floors on autopilot until the boss floor is reached.
func phase_hollowtime() -> void:
	await title_continue()
	var town := await wait_town()
	if town == null:
		return
	await walk_to(Vector2i(33, 27))
	await walk_to(Vector2i(33, 28))
	await until(func() -> bool: return _scene() == "hollow_approach.tscn", 30 * 10)
	await until(func() -> bool: return _scene() != "hollow_approach.tscn" or current_scene.ready_to_cross, 30 * 15)
	await F(READ)
	await press(&"ui_accept")
	await until(func() -> bool: return _scene() == "dungeon.tscn" and not current_scene.ents.is_empty(), 30 * 30)
	for k in 30 * 600:
		if _scene() != "dungeon.tscn":
			break
		var s := current_scene
		if int(s.floor_n) >= 3 and not s.ents.is_empty():
			await F(60)
			await snap("boss_floor")
			break
		if not s.talk.is_empty():
			await read_line()
		elif s.asking >= 0:
			await press(&"yes")
		elif s.teach_kind != "":
			await press(&"confirm")
		elif not s.autopilot and not s.busy and not s.cutscene and not s.ents.is_empty():
			await press(&"autopilot")
		else:
			await F()


## A move to learn waits on arrival (the growth's new move): read it, then take it in place of the first one listed.
func clear_teach() -> void:
	for k in 8:
		var s := current_scene
		if _scene() != "dungeon.tscn" or s.teach_kind == "":
			return
		await snap("teach_panel")
		await F(READ)
		if s.skip_ask:
			await press(&"no")
		else:
			await press(&"confirm")
		await F(10)


func _focus_name() -> String:
	var f := root.gui_get_focus_owner()
	return String(f.name) if f != null else "(none)"


## Move focus down until a control named  has it (at most 14 presses).
func focus_to(want: String) -> bool:
	for k in 14:
		if _focus_name() == want:
			return true
		await press(&"ui_down", 3, 4)
	return _focus_name() == want


func phase_menus() -> void:
	await title_continue()
	var town := await wait_town()
	if town == null:
		return
	await press(&"pause")
	await F(15)
	L("PAUSE FOCUS " + _focus_name())
	for row in ["Objective", "Team", "Bag", "Controls"]:
		if await focus_to(row):
			await press(&"ui_accept")
			await F(15)
			await snap("page_" + row)
			await press(&"ui_cancel")
			await F(10)
			L("BACK FOCUS " + _focus_name())
		else:
			L("NO ROW " + row)
	if await focus_to("Options"):
		await press(&"ui_accept")
		await F(15)
		await snap("page_Options")
		for k in 8:
			L("OPTIONS FOCUS " + _focus_name() + " " + str(root.gui_get_focus_owner().get("text") if root.gui_get_focus_owner() != null else ""))
			if _focus_name() == "Rebind":
				break
			await press(&"ui_down", 3, 4)
		if _focus_name() == "Rebind":
			await press(&"ui_accept")
			await F(15)
			await snap("rebind_top")
			for k in 10:
				await press(&"ui_down", 3, 3)
			await snap("rebind_mid")
			for k in 14:
				await press(&"ui_down", 3, 3)
			await snap("rebind_end")
			await press(&"ui_cancel")
			await F(10)
		await press(&"ui_cancel")
		await F(10)
	await press(&"ui_cancel")
	await F(10)
	await snap("menus_closed")
