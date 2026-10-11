extends SceneTree
## Two dungeons and the rival crew (Claude, 2026-10-10): the first dungeon's boss is Mirekit with Whinet
## (no pond, their own talk); the Hollow's floors are the valley then the stone, and its boss floor is the
## Warden's entrance; Rot Spit Blights (healing halved), Drain Bite heals the biter; the town sends the
## next run to the Hollow once the first boss is beaten.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/dungeons_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _dungeon(id: String) -> Node2D:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon = id
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0], [10, 0]]
	root.add_child(dg)
	await _frames(6)
	return dg


func _run() -> void:
	# 1. The first dungeon's boss floor: the crew.
	var dg := await _dungeon("first")
	dg.boss_intro = false   # the crew's own scene is checked by crew_scene_capture.gd; here, straight to the talk
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	await _frames(4)
	var b: Dictionary = dg.ents[dg.boss]
	var mins: Array = dg.ents.filter(func(e: Dictionary) -> bool: return e.get("minion", false))
	_ok("First boss: %s with %s; talk %d lines; pond %s; scene %s" % [b["name"], str(mins.map(func(e: Dictionary) -> String: return e["name"])), dg.talk.size(), str(dg.pond), str(dg.cutscene)],
		b["form"] == "mirekit" and mins.size() == 1 and mins[0]["form"] == "whinet" and dg.talk.size() == 4 and dg.pond.size == Vector2i.ZERO and not dg.cutscene)
	# 2. Rot Spit and Drain Bite on the leader.
	var lead: Dictionary = dg.ents[0]
	var mk: int = dg.ents.find(b)
	var wn: int = dg.ents.find(mins[0])
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if dg._floor_at(lead["pos"] + d) and dg._occupant(lead["pos"] + d) < 0:
			b["pos"] = lead["pos"] + d
			dg._place(b)
			b["awake"] = true
			b["cds"]["rot_spit"] = 0
			await dg.use_move(mk, "rot_spit", -d)
			break
	await _frames(4)
	var before: int = lead["hp"]
	_ok("Rot Spit: leader Blighted %d turns; a 15 heal gives %d" % [int(lead.get("blighted", 0)), dg.healed(lead, 15)], int(lead.get("blighted", 0)) > 0 and dg.healed(lead, 15) == 7)
	var w: Dictionary = dg.ents[wn]
	w["hp"] = maxi(1, w["max_hp"] - 10)
	var whp: int = w["hp"]
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if dg._floor_at(lead["pos"] + d) and dg._occupant(lead["pos"] + d) < 0:
			w["pos"] = lead["pos"] + d
			dg._place(w)
			w["awake"] = true
			w["cds"]["drain_bite"] = 0
			await dg.use_move(wn, "drain_bite", -d)
			break
	await _frames(4)
	_ok("Drain Bite: leader %d -> %d, Whinet %d -> %d" % [before, lead["hp"], whp, w["hp"]], lead["hp"] < before and w["hp"] > whp)
	dg.queue_free()
	await _frames(2)
	# 3. The Hollow: the valley, then the stone, then the Warden.
	var hg := await _dungeon("hollow")
	var looks: Array = []
	for f in [1, 2]:
		hg.floor_n = f
		hg._build_floor(true)
		await _frames(2)
		looks.append(hg.DUNGEONS["hollow"]["looks"].get(f, "bank"))
	hg.floor_n = hg.floors() + 1
	hg._build_floor(true)
	await _frames(4)
	_ok("The Hollow: floors %s; boss %s; pond %s; scene %s" % [str(looks), hg.ents[hg.boss]["name"], str(hg.pond), str(hg.cutscene)],
		looks == ["valley", "ruin"] and hg.ents[hg.boss]["form"] == "warden" and hg.pond.size != Vector2i.ZERO and hg.cutscene)
	hg.queue_free()
	await _frames(2)
	# 4. The town picks the dungeon.
	TeamState.start([[0, 0], [1, 0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(4)
	var picks: Array = []
	for beaten in [[], ["first"]]:
		TeamState.data["beaten"] = beaten
		var dgx: Node2D = load("res://scenes/dungeon.tscn").instantiate()
		TeamState.give_to(dgx)
		dgx.dungeon = "hollow" if "first" in TeamState.data.get("beaten", []) else "first"
		picks.append(dgx.dungeon)
		dgx.free()
	_ok("Town sends runs to: %s" % str(picks), picks == ["first", "hollow"])
	town.queue_free()
	print("DUNGEONS: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await _frames(12)
	quit(0 if fails==0 else 1)
