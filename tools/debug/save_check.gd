extends SceneTree
## The save (Claude, 2026-10-12): the team record is written when Highbank is reached or left for a run,
## and the title's Continue reads it back. Headless. Writes only its own file (user://check_team.save),
## never the real save, and proves the guard that keeps every check away from the real one.
##   Godot --headless --path . --script res://tools/debug/save_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const CHECK_PATH := "user://check_team.save"
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


func _scene() -> String:
	return current_scene.scene_file_path.get_file() if current_scene != null else "none"


func _run() -> void:
	# 1. The guard: a check that has not chosen its own file never writes the real save.
	TeamState.start([[0, 0], [1, 0]])
	TeamState.save_path = TeamState.SAVE_PATH
	var wrote := TeamState.autosave()
	_ok("A check leaves the real save alone (autosave returned %s, last_save_at %.0f)" % [str(wrote), TeamState.last_save_at], not wrote and TeamState.last_save_at == 0.0)

	# 2. A round trip through the file keeps int keys (levels by line) and Vector2i, which JSON would lose.
	TeamState.save_path = CHECK_PATH
	TeamState.erase_save()
	_ok("No save to begin with", not TeamState.has_save())
	TeamState.data = {
		"party": [[0, 1], [1, 0]], "roster": [[2, 0]], "bag": {"reedberry": 2, "lamp_oil": 1}, "taught": {"0:1": ["Tackle", "Spark"]},
		"growth": {"0:1": {"kos": 3, "floors": 2, "flank": 1, "ambush": 0, "took": 0, "slam": 0}}, "iq": {1: 7},
		"levels": {0: {"lv": 5, "exp": 12}, 1: {"lv": 4, "exp": 150}}, "pending_learn": [], "cleared": 2, "faints": 1, "tactic": "go",
		"jobs": [{"id": "parcel_1", "spot": Vector2i(3, 4)}], "rank": 15, "beaten": ["mouth", "first"],
		"story": {"met_crew": true, "parcel": "delivered", "stone": ""}, "metas": {}, "news": "cleared"}
	var want: Dictionary = TeamState.data.duplicate(true)
	want.erase("news")
	_ok("Saved to %s" % CHECK_PATH, TeamState.autosave() and FileAccess.file_exists(CHECK_PATH))
	TeamState.data = {}
	_ok("The save is seen", TeamState.has_save())
	var loaded := TeamState.load_save()
	_ok("Loaded back the same record, news dropped", loaded and var_to_str(TeamState.data) == var_to_str(want))
	if loaded:
		print("  levels keys %s, job spot %s, iq %s" % [str(TeamState.data["levels"].keys()), str(TeamState.data["jobs"][0]["spot"]), str(TeamState.data["iq"])])
	var s := TeamState.summary()
	_ok("Summary: party %s, cleared %d, beaten %s" % [str(s.get("party")), s.get("cleared", -1), str(s.get("beaten"))], s.get("cleared", -1) == 2 and s.get("beaten", []).size() == 2)

	# 3. Highbank opens with the loaded record and saves on arrival.
	TeamState.last_save_at = 0.0
	var town: Node = load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(town)
	change_scene_to_node(town)
	await _frames(6)
	_ok("Highbank opens with the saved team (party %s, cleared %d) and saves on arrival (at %.0f)" % [str(town.party), town.cleared, TeamState.last_save_at],
		town.party == [[0, 1], [1, 0]] and town.cleared == 2 and TeamState.last_save_at > 0.0)
	# Return to title from Highbank's pause menu saves what the town changed since the arrival.
	TeamState.last_save_at = 0.0
	TeamState.data["rank"] = 99
	var pm: Node = town.get_node("GamePauseMenu")
	pm.page = "title"
	pm.leave()
	await _frames(8)
	var on_disk: Dictionary = TeamState._read().get("data", {})
	_ok("Return to title from Highbank saves first (rank on disk %d, scene now %s)" % [int(on_disk.get("rank", -1)), _scene()], int(on_disk.get("rank", -1)) == 99 and TeamState.last_save_at > 0.0)

	# 4. The title lists Continue first when a save exists, and Continue opens Highbank with it.
	var title: Node = load("res://scenes/creature_opening.tscn").instantiate()
	change_scene_to_node(title)
	await _frames(10)
	var cont: Node = title.find_child("Continue", true, false)
	_ok("The title lists Continue first (buttons %s)" % str(title._buttons.map(func(b: Button) -> String: return b.name)), cont != null and title._buttons[0] == cont)
	var guard := 0
	while "_boot_done" in title and not title.get("_boot_done") and guard < 30 * 20:
		await process_frame
		guard += 1
	print("  the title's boot done after %d frames" % guard)
	TeamState.data = {}
	title._on_continue()
	guard = 0
	# The tree has no current scene for a frame while the title goes and Highbank arrives.
	while (current_scene == title or current_scene == null) and guard < 30 * 10:
		await process_frame
		guard += 1
	var back: Node = current_scene
	var party_now: Variant = back.get("party") if back != null else null
	_ok("Continue opens Highbank with the saved team after %d frames: scene %s, party %s" % [guard, _scene(), str(party_now)],
		_scene() == "hub_town.tscn" and party_now == [[0, 1], [1, 0]] and back.get("cleared") == 2)

	# 5. Without a save there is no Continue.
	TeamState.erase_save()
	var title2: Node = load("res://scenes/creature_opening.tscn").instantiate()
	change_scene_to_node(title2)
	await _frames(10)
	_ok("Without a save the title has no Continue (buttons %s)" % str(title2._buttons.map(func(b: Button) -> String: return b.name)), title2.find_child("Continue", true, false) == null)

	# 6. A quit mid-run keeps the run: Continue opens the same floor with the team as it stood, once.
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["levels"] = {0: {"lv": 3, "exp": 0}, 1: {"lv": 3, "exp": 0}}
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	TeamState.give_to(dg)
	dg.dungeon = "hollow"
	dg.return_to_town = true
	change_scene_to_node(dg)
	await _frames(6)
	dg.floor_n = 2
	dg.floor_seed = 11
	dg._build_floor(false)
	await _frames(3)
	dg.light = 40
	dg.turn = 57
	dg.ents[0]["hp"] = 5
	dg.bag["lamp_oil"] = 3
	var pm2: Node = dg.get_node("GamePauseMenu")
	pm2.page = "title"
	pm2.leave()
	await _frames(8)
	var kept: Dictionary = TeamState._read().get("data", {}).get("suspend", {})
	_ok("Quit mid-run keeps the run on disk: B%dF seed %d light %s hp %s, the scene now %s" % [int(kept.get("floor_n", 0)), int(kept.get("floor_seed", 0)), str(kept.get("light")), str(kept.get("hp")), _scene()],
		int(kept.get("floor_n", 0)) == 2 and int(kept.get("floor_seed", 0)) == 11 and kept.get("light") == 40 and kept.get("hp", [0])[0] == 5 and _scene() == "creature_opening.tscn")
	var title3: Node = current_scene
	guard = 0
	while "_boot_done" in title3 and not title3.get("_boot_done") and guard < 30 * 20:
		await process_frame
		guard += 1
	TeamState.data = {}
	title3._on_continue()
	guard = 0
	while (current_scene == title3 or current_scene == null) and guard < 30 * 10:
		await process_frame
		guard += 1
	var run: Node = current_scene
	var on_run: bool = _scene() == "dungeon.tscn"
	_ok("Continue resumes the run at the top of B%dF: seed %d, light %s, turn %d, leader HP %d, lamp oil %d, in %s" % [
			int(run.get("floor_n")) if on_run else 0, int(run.get("floor_seed")) if on_run else 0, str(run.get("light")) if on_run else "?",
			int(run.get("turn")) if on_run else 0, int(run.ents[0]["hp"]) if on_run else 0, int(run.bag.get("lamp_oil", 0)) if on_run else 0, str(run.get("dungeon")) if on_run else "?"],
		on_run and run.floor_n == 2 and run.floor_seed == 11 and run.light == 40 and run.turn == 57 and run.ents[0]["hp"] == 5 and run.bag.get("lamp_oil", 0) == 3 and run.dungeon == "hollow" and run.return_to_town)
	_ok("The run is consumed: the file holds no run now, so the next Continue goes to Highbank", not TeamState._read().get("data", {}).has("suspend") and not TeamState.has_suspended() and TeamState.has_save())
	# 7. A crash mid-write cannot cost the save (Claude, 2026-10-22): each save goes to .tmp and is renamed into
	# place, the one before it kept as .bak, and a save that will not read falls back to the .bak.
	TeamState.erase_save()
	for n in [3, 4, 5]:
		TeamState.data = {"party": [[0, 1], [1, 0]], "cleared": n}
		TeamState.autosave()
	var bak := CHECK_PATH + ".bak"
	var held: Variant = FileAccess.open(bak, FileAccess.READ).get_var() if FileAccess.file_exists(bak) else {}
	if not (held is Dictionary):
		held = {}
	_ok("Three saves keep the newest (cleared %d) and the one before as the .bak (cleared %d), no .tmp left" % [int(TeamState._read().get("data", {}).get("cleared", -1)), int(held.get("data", {}).get("cleared", -1))],
		int(TeamState._read().get("data", {}).get("cleared", -1)) == 5 and int(held.get("data", {}).get("cleared", -1)) == 4 and not FileAccess.file_exists(CHECK_PATH + ".tmp"))
	var cut := FileAccess.open(CHECK_PATH, FileAccess.WRITE)   # what a crash mid-write left before: a cut-short file
	cut.store_32(4096)
	cut.close()
	TeamState.data = {}
	_ok("A cut-short save falls back to the .bak: Continue stays (cleared %d)" % int(TeamState.summary().get("cleared", -1)),
		TeamState.has_save() and TeamState.load_save() and int(TeamState.data.get("cleared", -1)) == 4)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(CHECK_PATH))   # a crash between the two renames
	_ok("A missing save with a .bak still shows Continue", TeamState.has_save())
	TeamState.erase_save()
	_ok("erase_save takes the .bak too", not TeamState.has_save() and not FileAccess.file_exists(bak))
	TeamState.erase_save()
	TeamState.save_path = TeamState.SAVE_PATH
	print("SAVE: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
