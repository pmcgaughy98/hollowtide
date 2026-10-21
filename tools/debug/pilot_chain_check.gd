extends SceneTree
## The whole pilot, start to evolution, as one run (Claude, 2026-10-11; Preston: "do wiring for us all the way up
## to the gameplay ... up to the evolution part", for a build to show working developers).
##
## One team record carries through the game's real scene changes. Dungeons are played on autopilot, every
## line is read as a player would press E, and the run reports each handoff:
##   flood talk -> riverbank -> Hollow Mouth (no boss) -> Highbank, way down held -> Job Board theft ->
##   guild trial -> way down opens -> Rootbank Warren and the crew boss -> parcel back -> runners named ->
##   roll call -> The Hollow -> the Warden and the stone -> the stone set in the Growth Shrine -> evolution.
## A faint sends the team home, as in the game; the run tries that dungeon again (up to 3 times).
## The storm and soul openings have their own checks (storm_open_check, soul_prologue_check).
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/pilot_chain_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
var fails := 0
var log_lines: Array = []
var stage := ""
var faints := 0   # dungeon runs that ended in a faint (a balance signal for Grok)


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	var line := "%s -> %s" % [what, "ok" if good else "FAIL"]
	print(line)
	log_lines.append(line)
	if not good:
		fails += 1


func _scene() -> String:
	return current_scene.scene_file_path.get_file() if current_scene != null and is_instance_valid(current_scene) else "none"


func _story() -> Dictionary:
	return TeamState.data.get("story", {})


## One frame of a player who reads every line and lets the dungeon play itself.
func _tick() -> void:
	await process_frame
	var s := current_scene
	if s == null or not is_instance_valid(s):
		return
	var file := _scene()
	if file == "dungeon.tscn":
		s.autopilot = true
		if not s.talk.is_empty() and Engine.get_process_frames() % 4 == 0:
			UI.finish_line()
			s.act_talk()
	elif "talk" in s and s.talk is Array and not s.talk.is_empty() and Engine.get_process_frames() % 4 == 0:
		UI.finish_line()
		s.talk.pop_front()
	if file == "mouth_escape.tscn" and s.line != null and Engine.get_process_frames() % 4 == 0:
		UI.finish_line()   # the dawn walk up to Highbank, read like the flood talk
		s.advance()
	if file == "faint_screen.tscn" and Engine.get_process_frames() % 8 == 0:
		s.advance()   # the faint screen (2026-10-12): the partner's word, the defeat panel, then home or back to the bank
	if file == "hub_town.tscn" and s.panel is Dictionary and s.panel.get("service", "") == "news":
		s.panel = {}


## Play frames until `done` is true or the frame budget runs out.
func _until(done: Callable, frames: int) -> bool:
	for k in frames:
		if done.call():
			return true
		await _tick()
	return done.call()


## A dungeon, played to the end (back in town); a faint retries it, as a player would.
func _dungeon(name: String, start: Callable) -> bool:
	# Five tries, not three (2026-10-12): a short Hollow Mouth seed sent the team into Rootbank Warren at level 2
	# and the crew beat it three times running while its levels climbed a step a try; a player keeps going, and
	# the game has no dead end there (every try keeps levels). Grok has the balance note (GROK_TASKS_2026-10-12.md).
	for attempt in 5:
		var before_cleared := int(TeamState.data.get("cleared", 0))
		start.call()
		await _until(func() -> bool: return _scene() == "dungeon.tscn", 30 * 20)
		var ok := await _until(func() -> bool: return _scene() == "hub_town.tscn", 30 * 900)
		var news := String(TeamState.data.get("news", ""))
		print("  %s, try %d: back in town %s, news '%s', cleared %d, party %s, levels %s, growth %s" % [name, attempt + 1, ok, news, int(TeamState.data.get("cleared", 0)), str(TeamState.data.get("party", [])), str(TeamState.data.get("levels", {})), str(TeamState.data.get("growth", {}))])
		if ok and int(TeamState.data.get("cleared", 0)) > before_cleared:   # the town clears its news message once shown
			return true
		if _scene() == "dungeon.tscn":
			print("  %s: still in the dungeon when the budget ran out, a stall and not a faint; no retry" % name)
			return false   # retrying from here called _town() on the dungeon and crashed on 'panel' four times
		faints += 1
	return false


func _town() -> Node:
	return current_scene if _scene() == "hub_town.tscn" else null


func _run() -> void:
	var t0 := Time.get_ticks_msec()
	# 1. The flood talk (the soul chose Kithflare), then the riverbank.
	var pro: Node = load("res://scenes/creature_prologue.tscn").instantiate()
	pro.hero = 0
	pro.chosen_by_soul = true
	root.add_child(pro)
	current_scene = pro
	await _until(func() -> bool: return pro.line != null, 60)
	for k in 60:
		if _scene() != "creature_prologue.tscn":
			break
		UI.finish_line()
		pro.advance()
		await _until(func() -> bool: return false, 4)
	await _until(func() -> bool: return _scene() == "waking_riverbank.tscn", 30 * 10)
	_ok("Flood talk -> the riverbank (%s), team %s" % [_scene(), str(TeamState.data.get("party", []))], _scene() == "waking_riverbank.tscn")
	# 2. The ruin rises; the arch opens the Hollow Mouth.
	var bank: Node = current_scene
	await _until(func() -> bool: return not bank.leaving, 30 * 20)
	var mouth_ok := await _dungeon("Hollow Mouth", func() -> void:
		var arch: Node2D = load("res://scenes/hollow_entrance.tscn").instantiate()
		arch.party = TeamState.data.get("party", [[0, 0], [1, 0]])
		root.add_child(arch)
		current_scene.queue_free()
		current_scene = arch
		arch._enter_arch())
	_ok("Hollow Mouth cleared, no boss; parcel '%s', beaten %s" % [_story().get("parcel", ""), str(TeamState.data.get("beaten", []))], mouth_ok and _story().get("parcel", "") == "saved" and "mouth" in TeamState.data.get("beaten", []))
	# 3. Highbank: the way down is held until the guild is told.
	var town := _town()
	town.enter_hollow()
	_ok("Highbank: the way down is held before the Job Board (%s)" % town.has_meta("gated"), town.has_meta("gated"))
	town.remove_meta("gated")
	town.panel = {}
	# 4. The Job Board: the crew take the parcel.
	preload("res://scripts/town/board_scene.gd").run(town)
	await _until(func() -> bool: return _story().get("parcel", "") == "stolen" and not town.cutscene, 30 * 120)
	_ok("Job Board: the parcel is stolen (%s)" % _story().get("parcel", ""), _story().get("parcel", "") == "stolen")
	# 5. The guild: Starward sets the trial.
	town.enter_room("hall")
	await _until(func() -> bool: return _scene() == "town_room.tscn", 30 * 5)
	await _until(func() -> bool: return _story().get("guild_trial", false) and not current_scene.cutscene, 30 * 180)
	_ok("Wayline Hall: the trial is set (%s)" % _story().get("guild_trial", false), _story().get("guild_trial", false))
	current_scene.leave()
	await _until(func() -> bool: return _scene() == "hub_town.tscn", 30 * 5)
	# 6. Rootbank Warren and the crew boss.
	var warren_ok := await _dungeon("Rootbank Warren", func() -> void: _town().enter_hollow())
	_ok("Rootbank Warren cleared; parcel '%s', beaten %s" % [_story().get("parcel", ""), str(TeamState.data.get("beaten", []))], warren_ok and _story().get("parcel", "") == "recovered" and "first" in TeamState.data.get("beaten", []))
	town = _town()
	town.enter_hollow()
	_ok("Back in Highbank: The Hollow is held until Starward has the parcel (%s)" % town.has_meta("gated"), town.has_meta("gated"))
	town.remove_meta("gated")
	town.panel = {}
	# 7. The runners, then the roll call downstairs.
	town.enter_room("hall")
	await _until(func() -> bool: return _scene() == "town_room.tscn", 30 * 5)
	await _until(func() -> bool: return _story().get("runner", false) and not current_scene.cutscene, 30 * 180)
	_ok("Starward names them runners (%s, parcel '%s')" % [_story().get("runner", false), _story().get("parcel", "")], _story().get("runner", false))
	var hall: Node = current_scene
	# Compare rooms by id, not by node: the old room is freed on the way out, and a wait that held it logged
	# "Lambda capture ... was freed" every frame after (Claude, 2026-10-21).
	var hall_id := hall.get_instance_id()
	hall.go_room({"to": "hall_low", "at": Vector2i(24, 14), "facing": "w", "sfx": "stairs"})
	await _until(func() -> bool: return _scene() == "town_room.tscn" and current_scene.get_instance_id() != hall_id and current_scene.room_id == "hall_low", 30 * 5)
	var low: Node = current_scene
	await _until(func() -> bool: return low.cutscene, 30 * 3)
	var played: bool = low.cutscene
	await _until(func() -> bool: return not low.cutscene, 30 * 120)
	_ok("The mail call plays on the lower floor (%s), crew at posts %d" % [played, low.npcs.size()], played and low.npcs.size() >= 4)
	var low_id := low.get_instance_id()
	low.go_room({"to": "hall", "at": Vector2i(13, 10), "facing": "w", "sfx": "stairs"})
	await _until(func() -> bool: return _scene() == "town_room.tscn" and current_scene.get_instance_id() != low_id, 30 * 5)
	current_scene.leave()
	await _until(func() -> bool: return _scene() == "hub_town.tscn", 30 * 5)
	# 8. The Hollow by the teleport, the Warden, the stone.
	var hollow_ok := await _dungeon("The Hollow", func() -> void:
		_town().enter_hollow()
		(func() -> void:
			await _until(func() -> bool: return _scene() == "hollow_approach.tscn", 30 * 5)
			if _scene() == "hollow_approach.tscn":
				current_scene.confirm()).call())
	_ok("The Hollow cleared, the Warden beaten; the stone is '%s'" % _story().get("stone", ""), hollow_ok and _story().get("stone", "") == "carried")
	# 9. The Growth Shrine: the stone goes in, then the evolution.
	town = _town()
	if town != null:
		var shrine: Dictionary = town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "shrine")[0]
		town.team[0]["pos"] = shrine["door"]
		town._place(town.team[0])
		town.panel = {}
		town.act_use()
		var asked: String = town.panel.get("service", "")
		town.act_use()
		await _until(func() -> bool: return not town.evolving_now and town.stone_state() == "installed", 30 * 20)
		_ok("The stone is set in the Growth Shrine (asked '%s', now %s)" % [asked, town.stone_state()], town.stone_state() == "installed")
		town.panel = {}
		town.act_use()
		var offer: String = town.panel.get("service", "")
		var ready_n: int = load("res://scripts/town/evolution.gd").ready_list(TeamState.data).size()
		print("  At the shrine: %d ready to evolve; levels %s; growth %s" % [ready_n, str(TeamState.data.get("levels", {})), str(TeamState.data.get("growth", {}))])
		_ok("The shrine offers an evolution after the pilot's three dungeons (%s, %d ready)" % [offer, ready_n], offer == "evolve_ask")
		if offer == "evolve_ask":
			var before: Array = TeamState.data.get("party", []).duplicate(true)
			town.act_use()
			# The growth scene starts a frame or two later; wait for it to begin, then to end (2026-10-12: the check
			# read the party too early, then walked to the way down while the scene still owned the town).
			await _until(func() -> bool: return town.evolving_now, 30 * 3)
			await _until(func() -> bool: return not town.evolving_now, 30 * 90)   # the whole growth scene, with room to spare
			_ok("Grown: party %s -> %s" % [str(before), str(TeamState.data.get("party", []))], TeamState.data.get("party", []) != before)
		# 10. After the pilot the way down offers every dungeon again; a replay has no boss (Preston, 2026-10-11).
		town = _town()
		await _until(func() -> bool: return not town.evolving_now and not town.cutscene and town.talk.is_empty(), 30 * 10)
		town.panel = {}
		town.enter_hollow()
		var pick: String = town.panel.get("service", "")
		_ok("After the pilot the way down asks where to go (%s)" % pick, pick == "way_pick")
		if pick == "way_pick":
			var warren_again := await _dungeon("Rootbank Warren again", func() -> void:
				_town().panel["sel"] = 1
				_town().act_use())
			_ok("A Warren replay clears with no boss and comes home (story parcel '%s')" % _story().get("parcel", ""), warren_again)
	print("Faints along the way: %d" % faints)
	log_lines.append("Faints along the way: %d" % faints)
	print("PILOT CHAIN: %s in %.0f s" % ["all ok" if fails == 0 else "%d FAILED" % fails, (Time.get_ticks_msec() - t0) / 1000.0])
	var f := FileAccess.open("res://docs/design/pilot-chain-2026-10-11.log", FileAccess.WRITE)
	if f:
		f.store_string("\n".join(log_lines) + "\n")
	quit(1 if fails else 0)
