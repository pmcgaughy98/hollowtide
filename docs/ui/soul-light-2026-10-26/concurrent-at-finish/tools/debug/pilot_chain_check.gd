extends SceneTree
## The whole pilot, start to evolution, as one run (Claude, 2026-10-11; Preston: "do wiring for us all the way up
## to the gameplay ... up to the evolution part", for a build to show working developers).
##
## One team record carries through the game's real scene changes. Dungeons are played on autopilot, every
## line is read as a player would press E, and the run reports each handoff:
##   flood talk -> riverbank -> Hollow Mouth (no boss) -> Highbank, way down held -> Job Board theft ->
##   guild trial -> way down opens -> Rootbank Warren and the crew boss -> parcel back -> runners named ->
##   roll call -> The Hollow -> the Warden and the stone -> the stone set in the Growth Shrine -> evolution.
## A faint sends the team home, as in the game; the run tries that dungeon again (up to 5 times).
## The storm and soul openings have their own checks (storm_open_check, soul_prologue_check).
## Pass 2 (Claude, 2026-10-22, factory lane 7, FLOW-21): the detours a player takes that the straight run never
## did. The first Warren try goes down on purpose and the faint screen is read page by page; a quit mid-run in The
## Hollow keeps the run, and the title's Continue resumes it. On by default; `-- --plain` runs the straight chain
## alone. Both read the end card after the first growth (GS-16, lane 3's pilot_end.gd).
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/pilot_chain_check.gd
## The step log goes to the runner's logs folder (HT_CHECK_LOGS, set by run_checks.py) as pilot-chain.log, or to
## user://pilot-chain.log on a direct run. `-- --update-doc` also rewrites the tracked
## docs/design/pilot-chain-2026-10-11.log, so a suite run leaves docs/ alone (Claude, 2026-10-23, LO-11).

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const CHECK_SAVE := "user://pilot_chain_check.save"   # pass 2's suspend writes here, never to the real save
var fails := 0
var log_lines: Array = []
var stage := ""
var faints := 0   # dungeon runs that ended in a faint (a balance signal for Grok)
var pass_two := not OS.get_cmdline_user_args().has("--plain")   # FLOW-21's detours, on unless `-- --plain`
var hold := false   # pass 2 holds the autopilot and the faint screen's presses while it reads them
var last_faint := ""   # what the last faint screen said (its info), printed beside a try that did not clear (Claude, 2026-10-22)
var boss_seen := false   # the dungeon in play had a boss set up (boss_cfg() not empty); reset by each _dungeon (Claude, 2026-10-24, H01)


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


## The growth changed one party entry, [line, stage], to the same line one stage on, and nothing else: the same
## party size, every other entry as it was (Claude, 2026-10-24, H01; "party != before" passed on any change).
func _grew_one(before: Array, after: Array) -> bool:
	if after.size() != before.size():
		return false
	var grew := 0
	for k in before.size():
		var b: Array = before[k]
		var a: Array = after[k]
		var same_rest := a.size() == b.size() and str(a.slice(2)) == str(b.slice(2))
		if same_rest and int(a[0]) == int(b[0]) and int(a[1]) == int(b[1]):
			continue
		if same_rest and int(a[0]) == int(b[0]) and int(a[1]) == int(b[1]) + 1:
			grew += 1
		else:
			return false
	return grew == 1


## One frame of a player who reads every line and lets the dungeon play itself.
func _tick() -> void:
	await process_frame
	var s := current_scene
	if s == null or not is_instance_valid(s):
		return
	var file := _scene()
	if file == "dungeon.tscn":
		s.autopilot = not hold
		s.check_bot = true   # the chain's bot reads the lines and welcomes recruits (dungeon.gd check_bot, L6-01)
		if s.has_method("boss_cfg") and not s.boss_cfg().is_empty():
			boss_seen = true
		if not s.talk.is_empty() and Engine.get_process_frames() % 4 == 0:
			UI.finish_line()
			s.act_talk()
	elif "talk" in s and s.talk is Array and not s.talk.is_empty() and Engine.get_process_frames() % 4 == 0:
		UI.finish_line()
		s.talk.pop_front()
	if file == "mouth_escape.tscn" and s.line != null and Engine.get_process_frames() % 4 == 0:
		UI.finish_line()   # the dawn walk up to Highbank, read like the flood talk
		s.advance()
	if file == "faint_screen.tscn" and last_faint == "":
		var fi: Dictionary = s.info
		last_faint = "%s %s, turns %s, fell to %s, leader %s" % [fi.get("dungeon", "?"), fi.get("floor", "?"), str(fi.get("turns", "?")), str(fi.get("fell_to", "?")), str(fi.get("leader", "?"))]
	if file == "faint_screen.tscn" and not hold and Engine.get_process_frames() % 8 == 0:
		s.advance()   # the faint screen (2026-10-12): the partner's word, the defeat panel, then home or back to the top
	if file == "hub_town.tscn" and s.panel is Dictionary and s.panel.get("service", "") == "news":
		s.panel = {}


## Play frames until `done` is true or the frame budget runs out.
func _until(done: Callable, frames: int) -> bool:
	for k in frames:
		if done.call():
			return true
		await _tick()
	return done.call()


## A dungeon, played to the end (back in town); a faint retries it, as a player would. `detour` (pass 2) runs once
## the first try is underway; it returns true when it put the team down on purpose, which is not a balance faint.
func _dungeon(name: String, start: Callable, detour := Callable()) -> bool:
	# Five tries, not three (2026-10-12): a short Hollow Mouth seed sent the team into Rootbank Warren at level 2
	# and the crew beat it three times running while its levels climbed a step a try; a player keeps going, and
	# the game has no dead end there (every try keeps levels). Grok has the balance note (GROK_TASKS_2026-10-12.md).
	boss_seen = false   # _tick sets it while any try of this dungeon has a boss set up (Claude, 2026-10-24, H01)
	for attempt in 5:
		var before_cleared := int(TeamState.data.get("cleared", 0))
		last_faint = ""
		start.call()
		await _until(_in_dungeon, 30 * 20)
		var forced := false
		if attempt == 0 and detour.is_valid() and _in_dungeon():
			forced = await detour.call()
		var ok := await _until(_in_town, 30 * 900)
		var news := String(TeamState.data.get("news", ""))
		print("  %s, try %d: back in town %s, news '%s', cleared %d, party %s, levels %s, growth %s" % [name, attempt + 1, ok, news, int(TeamState.data.get("cleared", 0)), str(TeamState.data.get("party", [])), str(TeamState.data.get("levels", {})), str(TeamState.data.get("growth", {}))])
		if ok and int(TeamState.data.get("cleared", 0)) > before_cleared:   # the town clears its news message once shown
			return true
		if _scene() == "dungeon.tscn":
			print("  %s: still in the dungeon when the budget ran out, a stall and not a faint; no retry" % name)
			return false   # retrying from here called _town() on the dungeon and crashed on 'panel' four times
		if not forced:
			faints += 1
			print("  %s, try %d did not clear; the faint screen said: %s" % [name, attempt + 1, last_faint if last_faint != "" else "(no faint screen seen)"])
	return false


## Pass 2 (FLOW-21): the first Warren try goes down on purpose on B1F. The faint screen is read as a player sees
## it, the partner's word and then the defeat panel, and E carries the team home; the chain tries the Warren again.
func _faint_in_warren() -> bool:
	hold = true
	var id := current_scene.get_instance_id()
	await _until(func() -> bool:
		var d: Object = instance_from_id(id)
		return d == null or (not d.ents.is_empty() and d.talk.is_empty() and not d.busy and not d.cutscene), 30 * 20)
	var dg: Object = instance_from_id(id)
	if dg == null or _scene() != "dungeon.tscn" or dg.ents.is_empty():
		hold = false
		_ok("Pass 2: the Warren is underway for the faint on purpose (%s)" % _scene(), false)
		return false
	var faints_before := int(TeamState.data.get("faints", 0))
	dg.autopilot = false
	dg.bag.erase("rally_seed")   # no Second Wind: going down is the point here
	dg.ents[0]["hp"] = 0
	dg._end_turn()
	await _until(func() -> bool: return _scene() == "faint_screen.tscn", 30 * 5)
	if _scene() != "faint_screen.tscn":
		hold = false
		_ok("Pass 2: going down in the Warren opens the faint screen (%s)" % _scene(), false)
		return false
	var screen: Node = current_scene
	var info: Dictionary = screen.info
	var word := String(screen._word())
	_ok("Pass 2: going down in Rootbank Warren opens the faint screen: %s %s, going home %s, %s speaks first: '%s'" % [info.get("dungeon"), info.get("floor"), str(info.get("to_town")), info.get("partner", ""), word],
		info.get("dungeon") == "Rootbank Warren" and info.get("to_town") == true and screen.page == 0 and String(info.get("partner", "")) != "" and "home" in word.to_lower())
	for k in 4:   # the first press finishes the typed line, the next turns to the panel
		if screen.page == 1:
			break
		screen.advance()
		await _until(func() -> bool: return false, 2)
	# The panel's lines as drawn (lane 5's _layout: heading, rows, key hint), or the rows alone on an older screen.
	var lines: Array = screen.call("_layout")[0].map(func(item: Array) -> String: return String(item[0])) if screen.has_method("_layout") else screen._rows().map(func(r: Array) -> String: return String(r[0]))
	var said := " ".join(lines)
	_ok("Pass 2: the defeat panel reads '%s'" % " | ".join(lines),
		screen.page == 1 and "went down on B1F of Rootbank Warren" in said and "Lost:" in said and "Kept:" in said)
	screen.advance()   # E: home
	hold = false
	var home := await _until(_in_town, 30 * 10)
	_ok("Pass 2: E carries the team home (%s): faints %d -> %d, parcel '%s', trial %s" % [_scene(), faints_before, int(TeamState.data.get("faints", 0)), _story().get("parcel", ""), str(_story().get("guild_trial", false))],
		home and int(TeamState.data.get("faints", 0)) == faints_before + 1 and _story().get("parcel", "") == "stolen" and _story().get("guild_trial", false))
	return true


## Pass 2 (FLOW-21): a quit mid-run in The Hollow. The pause menu's leave keeps the run (dungeon.suspend()), the
## title comes up with Continue, and Continue opens the run again at the top of the same floor; the chain then
## plays it out as before. The save goes to CHECK_SAVE, never the real one.
func _suspend_in_hollow() -> bool:
	var id := current_scene.get_instance_id()
	await _until(func() -> bool:
		var d: Object = instance_from_id(id)
		return d == null or d.turn >= 12, 30 * 90)   # a few turns in, so the turn count and the lantern have moved
	hold = true
	for k in 30 * 20:   # a quiet moment, one a player could open the menu in
		var d: Object = instance_from_id(id)
		if d == null:
			break
		if d.asking >= 0:
			d.act_recruit(true)
		if not d.busy and d.talk.is_empty() and not d.cutscene and d.asking < 0 and not d._finishing:
			break
		await _tick()
	var dg: Object = instance_from_id(id)
	if dg == null or _scene() != "dungeon.tscn":
		hold = false
		_ok("Pass 2: The Hollow is underway for the quit (%s)" % _scene(), false)
		return false
	var was := {"floor_n": int(dg.floor_n), "floor_seed": int(dg.floor_seed), "turn": int(dg.turn), "hp": int(dg.ents[0]["hp"])}
	TeamState.save_path = CHECK_SAVE
	TeamState.erase_save()
	var pm: Node = dg.get_node("GamePauseMenu")
	pm.page = "title"
	pm.leave()
	var at_title := await _until(func() -> bool: return _scene() == "creature_opening.tscn", 30 * 10)
	var kept: Dictionary = TeamState._read().get("data", {}).get("suspend", {})
	_ok("Pass 2: a quit mid-run in The Hollow keeps the run on disk: B%dF, seed %d, turn %d (the title is up: %s)" % [int(kept.get("floor_n", 0)), int(kept.get("floor_seed", 0)), int(kept.get("turn", 0)), at_title],
		at_title and String(kept.get("dungeon", "")) == "hollow" and int(kept.get("floor_n", 0)) == was["floor_n"] and int(kept.get("floor_seed", 0)) == was["floor_seed"] and int(kept.get("turn", 0)) == was["turn"])
	if not at_title:
		hold = false
		return false
	var tid := current_scene.get_instance_id()
	await _until(func() -> bool:
		var t: Object = instance_from_id(tid)
		return t == null or not ("_boot_done" in t) or bool(t.get("_boot_done")), 30 * 20)
	var title: Object = instance_from_id(tid)
	if title == null:
		hold = false
		_ok("Pass 2: the title stays up for Continue", false)
		return false
	TeamState.data = {}   # Continue reads the file, not what is still in memory
	title._on_continue()
	var back := await _until(_in_dungeon, 30 * 10)
	var run: Node = current_scene
	_ok("Pass 2: Continue resumes The Hollow at the top of B%dF: seed %d, turn %d, leader HP %d (was %d), home after %s, the kept run used up %s" % [
			int(run.get("floor_n")) if back else 0, int(run.get("floor_seed")) if back else 0, int(run.get("turn")) if back else 0,
			int(run.ents[0]["hp"]) if back else 0, was["hp"], str(run.get("return_to_town")) if back else "?", str(not TeamState.has_suspended())],
		back and run.dungeon == "hollow" and run.floor_n == was["floor_n"] and run.floor_seed == was["floor_seed"] and run.turn == was["turn"]
			and int(run.ents[0]["hp"]) == mini(int(was["hp"]), int(run.ents[0]["max_hp"])) and run.return_to_town and not TeamState.has_suspended())
	hold = false
	return false


## A dungeon floor once it is built: since pass 4 (L03b) an arrival with input on shows the floor card for two frames
## before _build_floor, so "the scene is dungeon" alone met an empty ents and the faint on purpose stopped on
## ents[0] (Claude, 2026-10-24).
func _in_dungeon() -> bool:
	return _scene() == "dungeon.tscn" and not current_scene.ents.is_empty()


## Highbank once it is built. Since pass 4 (T4) a first arrival with input on puts the place card up and waits two
## frames before it builds the street and the team, so "the scene is hub_town" alone met an empty town.team and
## the Job Board scene stopped on team[0] (Claude, 2026-10-24). The team is the last thing _ready waits for.
func _in_town() -> bool:
	return _scene() == "hub_town.tscn" and not current_scene.team.is_empty()


func _town() -> Node:
	return current_scene if _in_town() else null


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
	_ok("Hollow Mouth cleared, no boss fought (boss set up %s); parcel '%s', beaten %s" % [boss_seen, _story().get("parcel", ""), str(TeamState.data.get("beaten", []))], mouth_ok and not boss_seen and _story().get("parcel", "") == "saved" and "mouth" in TeamState.data.get("beaten", []))
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
	_ok("Wayline Tower: the trial is set (%s)" % _story().get("guild_trial", false), _story().get("guild_trial", false))
	current_scene.leave()
	await _until(_in_town, 30 * 5)
	# 6. Rootbank Warren and the crew boss.
	var warren_ok := await _dungeon("Rootbank Warren", func() -> void: _town().enter_hollow(), _faint_in_warren if pass_two else Callable())
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
	await _until(_in_town, 30 * 5)
	# 8. The Hollow by the teleport, the Warden, the stone.
	var hollow_ok := await _dungeon("The Hollow", func() -> void:
		_town().enter_hollow()
		(func() -> void:
			await _until(func() -> bool: return _scene() == "hollow_approach.tscn", 30 * 5)
			if _scene() == "hollow_approach.tscn":
				current_scene.confirm()).call(),
		_suspend_in_hollow if pass_two else Callable())
	_ok("The Hollow cleared, the Warden beaten; the stone is '%s'" % _story().get("stone", ""), hollow_ok and _story().get("stone", "") == "carried")
	# 9. The Growth Shrine: the stone goes in, then the evolution.
	town = _town()
	if town != null:
		town.enter_area(town.Layout.area_of("shrine"), "shrine")   # Highbank v2: the shrine's area first (lane A, 2026-10-26)
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
			# Exactly one creature grew one stage and the rest of the party is as it was (Claude, 2026-10-24, H01).
			_ok("Grown: party %s -> %s" % [str(before), str(TeamState.data.get("party", []))], _grew_one(before, TeamState.data.get("party", [])))
			# 9b. The end card (GS-16, lane 3's pilot_end.gd; Claude, 2026-10-22, factory lane 7, FLOW-21): closing the
			# growth's line rolls it, once a save; it sets story.pilot_end_seen and hands the street back. With the
			# town's poll_input off the card reads itself, as a player's E would end it.
			town = _town()
			if town != null and ResourceLoader.exists("res://scripts/town/pilot_end.gd") and town.has_method("_close_panel"):
				var grew_line: bool = town.panel.get("grew", false)
				town.poll_input = false
				town._close_panel()
				var card_id := town.get_instance_id()
				await _until(func() -> bool:
					var t: Object = instance_from_id(card_id)
					return t == null or (bool(_story().get("pilot_end_seen", false)) and not t.cutscene and not t.has_node("PilotEnd")), 30 * 30)
				town = _town()
				if town != null:
					town.poll_input = true
				_ok("The end card plays after the first growth and hands back the street (growth line %s, pilot_end_seen %s, %s)" % [grew_line, str(_story().get("pilot_end_seen", false)), _scene()],
					grew_line and bool(_story().get("pilot_end_seen", false)) and town != null and not town.cutscene and not town.has_node("PilotEnd"))
			else:   # a missing step fails instead of passing quietly (Claude, 2026-10-24, H01)
				_ok("The end card can play: back in town %s, scripts/town/pilot_end.gd %s, hub_town._close_panel %s" % [town != null, ResourceLoader.exists("res://scripts/town/pilot_end.gd"), town != null and town.has_method("_close_panel")], false)
		# 10. After the pilot the way down offers every dungeon again; a replay has no boss (Preston, 2026-10-11).
		town = _town()
		var town_id := town.get_instance_id() if town != null else 0
		await _until(func() -> bool:
			var t: Object = instance_from_id(town_id)
			return t == null or (not t.evolving_now and not t.cutscene and t.talk.is_empty()), 30 * 10)
		town.panel = {}
		town.enter_hollow()
		var pick: String = town.panel.get("service", "")
		_ok("After the pilot the way down asks where to go (%s)" % pick, pick == "way_pick")
		if pick == "way_pick":
			var warren_again := await _dungeon("Rootbank Warren again", func() -> void:
				# A retry after a faint starts from the street, so the way down is asked again (Claude, 2026-10-22:
				# the retry used to press E on a closed picker and never left town).
				if _town().panel.get("service", "") != "way_pick":
					_town().panel = {}
					_town().enter_hollow()
				_town().panel["sel"] = 1
				_town().act_use())
			_ok("A Warren replay clears with no boss fought (boss set up %s) and comes home (story parcel '%s')" % [boss_seen, _story().get("parcel", "")], warren_again and not boss_seen)
	else:   # The Hollow did not bring the team home, so steps 9 and 10 cannot run (Claude, 2026-10-24, H01)
		_ok("Back in Highbank after The Hollow (%s)" % _scene(), false)
	var tally := "Faints along the way: %d%s" % [faints, " (pass 2 went down once more on purpose, not counted)" if pass_two else ""]
	print(tally)
	log_lines.append(tally)
	if TeamState.save_path == CHECK_SAVE:   # never erase while the path is the real save's
		TeamState.erase_save()
	TeamState.save_path = TeamState.SAVE_PATH
	print("PILOT CHAIN: %s in %.0f s" % ["all ok" if fails == 0 else "%d FAILED" % fails, (Time.get_ticks_msec() - t0) / 1000.0])
	var log_dir := OS.get_environment("HT_CHECK_LOGS")   # the runner's --logs folder (Claude, 2026-10-23, LO-11)
	var log_paths: Array = [log_dir.path_join("pilot-chain.log") if log_dir != "" else "user://pilot-chain.log"]
	if OS.get_cmdline_user_args().has("--update-doc"):
		log_paths.append("res://docs/design/pilot-chain-2026-10-11.log")
	for path in log_paths:
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f:
			f.store_string("\n".join(log_lines) + "\n")
			print("Chain log written to %s" % ProjectSettings.globalize_path(path))
		else:
			print("Chain log could not be written to %s (error %d)" % [path, FileAccess.get_open_error()])
	quit(1 if fails else 0)
