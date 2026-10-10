extends SceneTree
## Move effects in the dungeon (Claude, 2026-10-09): a shot flies as its painted projectile, a hit
## plays its effect, a burst plays where it lands, a slam shakes the screen with dust, a dash leaves
## afterimages, and a wind-up glows. Counts what was on screen and saves stills.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_vfx_check.gd
## Stills to docs/design/dungeon-vfx-2026-10-09/.

const OUT := "res://docs/design/dungeon-vfx-2026-10-09/"
var dg: Node2D


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	dg._reveal()   # teleported creatures need the lantern's light recomputed, or the still is dark
	var img := root.get_texture().get_image()
	var at: Vector2 = (dg._world.position + dg.ents[0]["node"].position) * dg.SCALE
	var r := Rect2i(Vector2i(int(at.x) - 300, int(at.y) - 200), Vector2i(600, 330)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	img.get_region(r).save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _wild(pos: Vector2i, line: int) -> int:
	var w: Dictionary = dg._make(line, 0, 1, pos)
	w["max_hp"] = 400
	w["hp"] = 400
	w["awake"] = true
	w["snared"] = 99
	dg.ents.append(w)
	dg._place(w)
	return dg.ents.size() - 1


## Watch one action: the most effects, projectiles and afterimages on screen, the biggest shake,
## and a still at the busiest frame.
func _watch(call: Callable, still: String) -> Dictionary:
	var most := 0
	var proj := 0
	var ghosts := 0
	var shake := 0.0
	var names := {}
	call.call()
	for k in 24:
		await process_frame
		var n: int = dg._vfx.filter(func(v: Dictionary) -> bool: return v["t"] >= 0.0).size()
		if n > most:
			most = n
			_save(still)
		proj = maxi(proj, dg._vfx.filter(func(v: Dictionary) -> bool: return v.has("to")).size())
		ghosts = maxi(ghosts, dg._ghosts.size())
		shake = maxf(shake, dg._shake)
		for v in dg._vfx:
			names[v["name"]] = true
	await _frames(10)
	return {"most": most, "proj": proj, "ghosts": ghosts, "shake": snappedf(shake, 0.1), "names": names.keys()}


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	dg.traps.clear()
	dg.monster_room = Rect2i()
	var spot := Vector2i.ZERO
	for room in dg.data["rooms"]:
		if room.size.x >= 8 and room.size.y >= 4:
			spot = room.position + Vector2i(1, 1)
			break
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	var lead: Dictionary = dg.ents[0]
	lead["max_hp"] = 999
	lead["hp"] = 999
	dg.ents[0]["pos"] = spot
	dg._place(dg.ents[0])
	dg.ents[1]["pos"] = spot + Vector2i(0, 3)
	dg._place(dg.ents[1])
	# 1. Ember Shot down a line at a Tallowroot (Bloom: Ember is strong into it).
	var t := _wild(spot + Vector2i(3, 0), 1)
	lead["cds"]["fireball"] = 0
	var r1 := await _watch(func() -> void: dg.use_move(0, "fireball", Vector2i(1, 0)), "shot")
	print("Ember Shot: up to %d effects at once, a projectile %s, shake %.1f, effects %s" % [r1["most"], str(r1["proj"] > 0), r1["shake"], str(r1["names"])])
	# 2. Rake up close.
	dg.ents[t]["pos"] = spot + Vector2i(1, 0)
	dg._place(dg.ents[t])
	var r2 := await _watch(func() -> void: dg.use_move(0, "claw", Vector2i(1, 0)), "rake")
	print("Rake: effects %s, shake %.1f" % [str(r2["names"]), r2["shake"]])
	# 3. Ember Feint, a one-tile dash: into open floor it moves (afterimages); beside a foe it strikes.
	dg.ents[t]["pos"] = spot + Vector2i(5, 0)
	dg._place(dg.ents[t])
	lead["cds"]["ember_feint"] = 0
	var r3 := await _watch(func() -> void: dg.use_move(0, "ember_feint", Vector2i(1, 0)), "dash_move")
	dg.ents[0]["pos"] = spot
	dg._place(dg.ents[0])
	dg.ents[t]["pos"] = spot + Vector2i(1, 0)
	dg._place(dg.ents[t])
	lead["cds"]["ember_feint"] = 0
	var r3b := await _watch(func() -> void: dg.use_move(0, "ember_feint", Vector2i(1, 0)), "dash")
	print("Ember Feint (dash): into open floor %d afterimages; beside a foe effects %s, shake %.1f" % [r3["ghosts"], str(r3b["names"]), r3b["shake"]])
	# 4. Tallowroot's Seed Pod from the partner: a lob with a burst where it lands.
	dg.ents[t]["pos"] = spot + Vector2i(2, 3)
	dg._place(dg.ents[t])
	dg.ents[1]["cds"]["seed"] = 0
	var r4 := await _watch(func() -> void: dg.use_move(1, "seed", Vector2i(1, 0)), "seed")
	print("Seed Pod (burst): projectile %s, effects %s" % [str(r4["proj"] > 0), str(r4["names"])])
	# 5. A wind-up: the glow under the one gathering.
	dg.ents[t]["windup"] = {"m": dg.ents[t]["moves"][-1], "d": Vector2i(-1, 0), "tiles": [spot + Vector2i(1, 3)]}
	await _frames(6)
	_save("windup_glow")
	print("Wind-up: still saved with %s gathering %s" % [dg.ents[t]["name"], dg.Arena.MOVES[dg.ents[t]["windup"]["m"]]["name"]])
	quit()
