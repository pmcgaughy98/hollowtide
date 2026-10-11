extends SceneTree
## The Hollow's new wilds (Claude, 2026-10-10): Skimlet on the valley floor, Ozbender and Valvekin in the
## ruin; a recruited one carries through the team record into Highbank and back into a dungeon (the town
## asks scripts/creatures/lines.gd, which knows the dungeon-only lines). Windowed it saves a still of each floor.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/hollow_wilds_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const OUT := "res://docs/creatures/takes-2026-10-10/"
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


func _forms_on(floor_n: int) -> Array:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.poll_input = false
	dg.dungeon = "hollow"
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	var seen := {}
	for sd in [3, 11, 29, 47, 61]:
		dg.floor_seed = sd
		dg.floor_n = floor_n
		dg._build_floor(true)
		await _frames(2)
		for e in dg.ents:
			if e["team"] == 1:
				seen[e["form"]] = true
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "hollow_b%df.png" % floor_n))
	dg.queue_free()
	await _frames(2)
	return seen.keys()


func _run() -> void:
	var b1: Array = await _forms_on(1)
	_ok("B1F wilds over five floors: %s" % str(b1), "skimlet" in b1 and not "ozbender" in b1)
	var b2: Array = await _forms_on(2)
	_ok("B2F wilds over five floors: %s" % str(b2), "ozbender" in b2 and "valvekin" in b2)
	# A recruited Skimlet in the party: the town and a dungeon both build it.
	TeamState.start([[0, 0], [1, 0], [103, 0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	TeamState.give_to(town)
	root.add_child(town)
	await _frames(4)
	_ok("Town with a recruited Skimlet: %s" % str(town.team.map(func(e: Dictionary) -> String: return e["form"])), town.team.size() == 3 and town.team[2]["form"] == "skimlet")
	town.queue_free()
	await _frames(2)
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.poll_input = false
	TeamState.give_to(dg)
	root.add_child(dg)
	await _frames(4)
	var mates: Array = dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] == 0).map(func(e: Dictionary) -> String: return e["form"])
	_ok("Back in a dungeon: %s" % str(mates), "skimlet" in mates)
	dg.queue_free()
	print("HOLLOW WILDS: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()
