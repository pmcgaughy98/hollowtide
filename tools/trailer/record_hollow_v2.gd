extends SceneTree
## Dungeon footage for trailer v2 from The Hollow, the Warden's dungeon (Claude, 2026-10-11; Preston: "use
## rootbank wardens dungeon for trailer"). The story team (Kithflare, Tallowroot and the Listener recruit)
## explores the valley floor, fights a Skimlet, then explores the ruin floor. Nothing here changes the game.
##   Godot --path . --fixed-fps 30 --write-movie docs/trailer/v2/hollow.avi --script res://tools/trailer/record_hollow_v2.gd
## Prints "SEG <name> <first frame> <last frame>" for tools/trailer/cut_trailer_v2.py.

var _base := 0
var _seg_name := ""
var _seg_start := 0


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _now() -> int:
	return Engine.get_process_frames() - _base


func _begin(name: String) -> void:
	_seg_name = name
	_seg_start = _now()


func _end() -> void:
	print("SEG %s %d %d" % [_seg_name, _seg_start, _now()])


func _run() -> void:
	_base = Engine.get_process_frames()
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon = "hollow"
	dg.floor_seed = 11
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0], [7, 0]]
	dg.levels = {0: {"lv": 6, "exp": 0}, 1: {"lv": 6, "exp": 0}, 7: {"lv": 5, "exp": 0}}
	root.add_child(dg)
	current_scene = dg
	await _frames(20)
	# 1. The valley floor, on autopilot.
	dg.autopilot = true
	_begin("valley")
	await _frames(540)
	_end()
	dg.autopilot = false
	await _frames(20)
	# 2. A close fight: the leader's moves on a wild Skimlet.
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	var lead: Dictionary = dg.ents[0]
	var d := Vector2i.ZERO
	for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0:
			d = dd
			break
	var foe: Dictionary = dg._make(103, 0, 1, lead["pos"] + d)
	foe["max_hp"] = 90
	foe["hp"] = 90
	foe["awake"] = true
	dg.ents.append(foe)
	dg._place(foe)
	lead["facing"] = dg._facing_of(d)
	await _frames(10)
	_begin("fight")
	for m in lead["cds"].keys():
		lead["cds"][m] = 0
		await dg.use_move(0, m, d)
		await _frames(20)
		if foe["hp"] <= 0:
			break
	await _frames(40)
	_end()
	# 3. The ruin floor.
	dg.floor_n = 2
	dg.floor_seed = 23
	dg._build_floor(false)
	await _frames(20)
	dg.autopilot = true
	_begin("ruin")
	await _frames(480)
	_end()
	quit()
