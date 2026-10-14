extends SceneTree
## The Storage (R6 of the genre synthesis; Claude, 2026-10-12; scripts/town/storage.gd). Checks: shut until
## Rootbank Warren is beaten (the river road); then its painted room and counter panel that move items between the bag and the store,
## refuses parcels, honours the bag's kinds cap; what is kept survives a run's take_from and a faint, is named
## on the faint screen, and rides in the save. Windowed it saves a still of the panel.
##   Godot --headless --path . --script res://tools/debug/storage_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const Storage := preload("res://scripts/town/storage.gd")
const OUT := "res://docs/design/storage-2026-10-12/"
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


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	for k in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _town() -> Node2D:
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	TeamState.give_to(town)
	root.add_child(town)
	current_scene = town
	await _frames(6)
	var door: Dictionary = town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "storage")[0]
	town.team[0]["pos"] = door["door"] + Vector2i(0, 1)
	town.team[0]["facing"] = "n"
	town._place(town.team[0])
	return town


func _run() -> void:
	TeamState.save_path = CHECK_PATH
	TeamState.erase_save()
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["bag"] = {"reedberry": 2, "lamp_oil": 1, "parcel": 1}
	TeamState.data["beaten"] = ["mouth"]
	# 1. Shut until the river road is clear.
	var town := await _town()
	town.act_use()
	_ok("Before the Warren is beaten the Storage is shut: '%s'" % String(town.panel.get("what", "")).left(60), town.panel.get("service", "") == "storage_shut" and "river road" in String(town.panel.get("what", "")))
	town.panel = {}
	TeamState.data["beaten"] = ["mouth", "first"]
	town.act_use()
	await _frames(8)
	town = current_scene
	town.poll_input = false
	_ok("Unlocked door enters the painted Storage room", town.get("room_id") == "storage")
	for k in 4:
		await town.act_move(Vector2i.UP)
		await _frames(1)
	town.team[0]["facing"] = "n"
	town.act_use()
	var rows: Array = town.storage_rows()
	_ok("After: the panel opens with the bag's kinds %s" % str(rows), town.panel.get("service", "") == "storage" and rows.size() == 3 and rows[0][0] == "reedberry" and rows[0][1] == 2 and rows[0][2] == 0)
	# 2. In and out.
	town.act_store(1)
	var rec: Dictionary = TeamState.data
	_ok("E puts one reedberry in: bag %d, kept %d, said '%s'" % [int(rec["bag"].get("reedberry", 0)), int(rec["stored"].get("reedberry", 0)), String(town.panel["said"])],
		int(rec["bag"].get("reedberry", 0)) == 1 and int(rec["stored"].get("reedberry", 0)) == 1)
	await _snap("storage")
	town.act_store_move(2)
	town.act_store(1)
	_ok("The parcel is refused: '%s', kept has no parcel %s" % [String(town.panel["said"]), not rec["stored"].has("parcel")], "carrying" in String(town.panel["said"]) and not rec["stored"].has("parcel"))
	town.act_store_move(-2)
	town.act_store(-1)
	_ok("R takes it back out: bag %d, kept %s" % [int(rec["bag"].get("reedberry", 0)), str(rec["stored"])], int(rec["bag"].get("reedberry", 0)) == 2 and rec["stored"].is_empty())
	town.act_store(1)
	town.act_store(1)
	rows = town.storage_rows()
	_ok("Both berries in: the bag has none, the row stays as a kept-only row %s" % str(rows.filter(func(r: Array) -> bool: return r[0] == "reedberry")),
		not rec["bag"].has("reedberry") and int(rec["stored"].get("reedberry", 0)) == 2 and rows.any(func(r: Array) -> bool: return r[0] == "reedberry" and r[1] == 0 and r[2] == 2))
	# The bag's kinds cap on the way out.
	var cap: int = Storage.bag_kinds()
	var full: Dictionary = {}
	for k in cap:
		full["kind_%d" % k] = 1
	var saved_bag: Dictionary = rec["bag"]
	rec["bag"] = full
	var said := Storage.move(rec, "reedberry", -1)
	_ok("A full bag (%d kinds) cannot take a new kind out: '%s'" % [cap, said], "holds" in said and int(rec["stored"].get("reedberry", 0)) == 2)
	rec["bag"] = saved_bag
	town.queue_free()
	await _frames(2)
	# 3. Through a run and a faint: the store stays. And the faint screen says so.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 3
	dg.poll_input = false
	TeamState.give_to(dg)
	root.add_child(dg)
	await _frames(4)
	TeamState.take_from(dg, "fainted")
	_ok("After a run's take_from the store is untouched: %s" % str(TeamState.data.get("stored")), int(TeamState.data.get("stored", {}).get("reedberry", 0)) == 2)
	var fs: Node = load("res://scenes/faint_screen.tscn").instantiate()
	fs.info = {"leader": "Kithflare", "partner": "Tallowroot", "partner_form": "tallowroot", "dungeon": "The Hollow", "floor": "B1F", "fell_to": "a Listener", "turns": 12, "downed": 1, "lost_items": 3, "lost_recruits": [], "to_town": true}
	var kept_row: String = ""
	for r in fs._rows():
		if String(r[0]).begins_with("Kept"):
			kept_row = String(r[0])
	fs.free()
	dg.queue_free()
	await _frames(2)
	_ok("The faint screen's Kept row names the Storage: '%s'" % kept_row, "Storage" in kept_row)
	# 4. The save keeps it.
	TeamState.save_path = CHECK_PATH
	TeamState.erase_save()
	TeamState.autosave()
	TeamState.data = {}
	var loaded := TeamState.load_save()
	_ok("The save carries the store: loaded %s, kept %s" % [str(loaded), str(TeamState.data.get("stored"))], loaded and int(TeamState.data.get("stored", {}).get("reedberry", 0)) == 2)
	TeamState.erase_save()
	TeamState.save_path = TeamState.SAVE_PATH
	print("STORAGE: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	var music = root.get_node_or_null("HollowtideMusic")
	if music != null: music.queue_free()
	await _frames(4)
	quit(1 if fails else 0)
