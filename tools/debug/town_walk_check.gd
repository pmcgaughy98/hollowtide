extends SceneTree
## The town team walks (Claude, 2026-10-10; Preston: "add walking animations to our creatures in the
## world... they just hopped without animation"). Ten steps along the street: how many different pictures
## each creature showed while moving, whether each is back on its standing picture after, and (Claude,
## 2026-10-22, LP-18) that no two team members share a tile after any step: the chain's followers each
## take the tile the one ahead just left.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/town_walk_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const STEPS := 10


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	TeamState.start([[0, 0], [1, 0], [10, 0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	for k in 6:
		await process_frame
	var seen := []
	for e in town.team:
		seen.append({})
	var start: Vector2i = town.team[0]["pos"]
	var steps := 0
	var overlaps := 0
	var first_overlap := ""
	for k in STEPS:
		# East along the street while it is open, else the first open side; never onto a place's door tile.
		var d := Vector2i.ZERO
		for cand in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(-1, 0)]:
			var to: Vector2i = town.team[0]["pos"] + cand
			if town.open_at(to) and Layout.place_at(to).is_empty():
				d = cand
				break
		if d == Vector2i.ZERO:
			break
		town.act_move(d)
		steps += 1
		var f := 0
		while f < 5 or town.busy:   # the whole step: it takes STEP_TIME of real time, however fast frames run
			await process_frame
			f += 1
			for i in town.team.size():
				seen[i][town.team[i]["sprite"].texture] = true
		var at := {}
		for i in town.team.size():
			var p: Vector2i = town.team[i]["pos"]
			if at.has(p):
				overlaps += 1
				if first_overlap == "":
					first_overlap = "; first at step %d: %s and %s both on %s" % [steps, town.team[at[p]]["form"], town.team[i]["form"], str(p)]
			at[p] = i
	for f in 20:
		await process_frame
	await create_timer(0.3).timeout   # the walk cycle runs on real time (STEP_TIME + 0.06 after the last step)
	var bad := 0
	for i in town.team.size():
		var e: Dictionary = town.team[i]
		var still: bool = e["sprite"].texture == e["still"][e["facing"]]
		var ok: bool = seen[i].size() >= 4 and still
		print("%s: %d different pictures while walking, standing again %s -> %s" % [e["form"], seen[i].size(), str(still), "ok" if ok else "WRONG"])
		bad += 0 if ok else 1
	var tiles: Array = town.team.map(func(e: Dictionary) -> Vector2i: return e["pos"])
	var walked_ok: bool = steps == STEPS and overlaps == 0
	print("Tiles: %d of %d steps from %s, the team now on %s; steps ending with two members on one tile: %d%s -> %s" % [steps, STEPS, str(start), str(tiles), overlaps, first_overlap, "ok" if walked_ok else "WRONG"])
	bad += 0 if walked_ok else 1
	print("RESULT: %s" % ("the team walks" if bad == 0 else "%d problems" % bad))
	quit()
