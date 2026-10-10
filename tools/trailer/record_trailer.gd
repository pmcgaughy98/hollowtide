extends SceneTree
## Records the real game for the trailer (Claude, 2026-10-10; Preston: "make a trailer for us").
## Run with Godot's Movie Maker so every frame is written at a fixed 30 fps:
##   Godot --path . --write-movie docs/trailer/raw.avi --fixed-fps 30 --script res://tools/trailer/record_trailer.gd
## It plays the beats one after another and prints "SEG <name> <first frame> <last frame>" for each,
## which tools/trailer/cut_trailer.py reads to cut the shots. Nothing here changes the game.

const TeamState := preload("res://scripts/town/team_state.gd")

var frame := 0
var _base := 0
var _seg_name := ""
var _seg_start := 0


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame
		frame += 1


# Frame numbers come from Godot's own counter, so waits inside the game (a move animating) count too.
func _now() -> int:
	return Engine.get_process_frames() - _base


func _begin(name: String) -> void:
	_seg_name = name
	_seg_start = _now()


func _end() -> void:
	print("SEG %s %d %d" % [_seg_name, _seg_start, _now()])


func _run() -> void:
	_base = Engine.get_process_frames()
	# 1. The title.
	var title: Node = load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(title)
	await _frames(150)   # the wordmark prelude plays out
	_begin("title")
	await _frames(180)
	_end()
	title.queue_free()
	await _frames(2)

	# 2. Highbank: the team walks Market Street toward the Wayline Hall.
	TeamState.start([[0, 0], [1, 0], [10, 0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(10)
	_begin("town")
	for k in 12:
		town.act_move(Vector2i(1, 0))
		await _frames(9)
	_end()
	town.queue_free()
	await _frames(2)

	# 3. The Hollow: autopilot explores and fights.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0], [10, 0]]
	dg.levels = {0: {"lv": 4, "exp": 0}, 1: {"lv": 4, "exp": 0}, 10: {"lv": 4, "exp": 0}}
	root.add_child(dg)
	await _frames(20)
	dg.autopilot = true
	_begin("explore")
	await _frames(420)
	_end()
	dg.autopilot = false
	await _frames(30)

	# 4. A close fight: the leader's Ember on a Bloom creature (super effective), then a Seep heal.
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	var lead: Dictionary = dg.ents[0]
	var d := Vector2i.ZERO
	for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0 and dg.can_step(lead["pos"], -dd) and dg._occupant(lead["pos"] - dd) < 0:
			d = dd
			break
	var foe: Dictionary = dg._make(1, 0, 1, lead["pos"] + d)
	foe["max_hp"] = 120
	foe["hp"] = 120
	foe["awake"] = true
	dg.ents.append(foe)
	dg._place(foe)
	var tr: Dictionary = dg.ents[2]
	tr["pos"] = lead["pos"] - d
	dg._place(tr)
	lead["facing"] = dg._facing_of(d)
	await _frames(10)
	_begin("fight")
	for m in ["claw", "ember_feint"]:
		lead["cds"][m] = 0
		await dg.use_move(0, m, d)
		await _frames(18)
	lead["hp"] = int(lead["max_hp"] * 0.4)
	tr["cds"]["seep"] = 0
	await dg.use_move(2, "seep", Vector2i(0, 1))
	await _frames(30)
	dg._gain_exp(dg.exp_to_next(4))
	await _frames(40)
	_end()

	# 5. The party screen, with the detailed idle.
	var menu: CanvasLayer = dg.get_node("GamePauseMenu")
	menu.open()
	await _frames(4)
	menu.show_page("team")
	await _frames(4)
	_begin("party")
	await _frames(60)
	var party: Control = menu.overlay.get_node("PartyScreen")
	party.sel = 1
	await _frames(45)
	party.page = 1
	party.move_sel = 0
	party.picking = true
	await _frames(45)
	_end()
	menu.resume()
	await _frames(10)
	dg.queue_free()
	await _frames(2)

	# 6. The Growth Shrine: Kithflare evolves.
	var c: Dictionary = load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()
	var r: Dictionary = c["EVO"][0]
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["levels"] = {0: {"lv": c["EVO_LEVEL"][0], "exp": 0}}
	TeamState.data["growth"] = {"0:0": {"kos": r["kos"][0], "floors": r["floors"][0], "flank": r["need"][0], "ambush": 0, "took": 0, "slam": 0}}
	TeamState.data["taught"] = {"0:0": ["claw", "ember_feint", "fireball"]}
	var town2: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town2.poll_input = false
	root.add_child(town2)
	await _frames(6)
	var shrine: Dictionary = town2.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "shrine")[0]
	town2.team[0]["pos"] = shrine["door"]
	town2._place(town2.team[0])
	town2.act_use()
	_begin("evolution")
	town2.act_use()
	while town2.evolving_now:
		await _frames(1)
	await _frames(20)
	_end()
	town2.queue_free()
	await _frames(2)

	# 7. The boss: the Quietwater Warden's floor, its scene, the fight.
	var bd: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	bd.floor_seed = 7
	bd.dungeon = "hollow"   # the Warden is the Hollow's boss (2026-10-10)
	bd.poll_input = false
	bd.party = [[0, 1], [1, 0], [10, 0]]
	bd.levels = {0: {"lv": 9, "exp": 0}, 1: {"lv": 8, "exp": 0}, 10: {"lv": 8, "exp": 0}}
	root.add_child(bd)
	await _frames(10)
	bd.floor_n = bd.floors() + 1
	bd._build_floor(true)
	await _frames(10)
	_begin("boss")
	for k in 6:
		if not bd.talk.is_empty():
			await _frames(40)
			bd.act_talk()
	await _frames(70)
	bd.autopilot = true
	await _frames(300)
	_end()
	bd.queue_free()
	print("RECORDED %d frames" % _now())
	quit()
