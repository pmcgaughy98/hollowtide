extends SceneTree
## The town team walks (Claude, 2026-10-10; Preston: "add walking animations to our creatures in the
## world... they just hopped without animation"). Ten steps along the street: how many different pictures
## each creature showed while moving, whether each is back on its standing picture after, and (Claude,
## 2026-10-22, LP-18) that no two team members share a tile after any step: the chain's followers each
## take the tile the one ahead just left.
## Claude, 2026-10-23, T4 / L21: a scripted walk up the Hall's steps, along its two door tiles and back, then in and
## out of Home's door; after every step no partner stands where a follower may not (a building's footprint, its door
## tiles included) or on the leader's tile. T5 / LO-04: while the Training Yard is shut its gate tile (41,12; the
## anchor yard_gate) cannot be entered, and E from the tile in front, facing it, still reads the board.
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
	# Past the facades (T4): [the anchor the leader starts on, each partner's offset from it], then the leader's steps.
	# The anchors are the tiles this check used to name, (24,9) below the Hall's steps and (5,9) below Home's door, in
	# today's map (scripts/world/areas/highbank_v1.gd); with Highbank v2 on, the same places in their areas (lane A,
	# Claude, 2026-10-26: Tower Rise and the street), entered first.
	var walks := [
		["lane_walk", [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)], [Vector2i(0, -1), Vector2i(0, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, 1), Vector2i(-1, 1)]],
		["home_walk", [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-2, 0)], [Vector2i(0, -1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]],
	]
	var facade_steps := 0
	var facade_bad: Array[String] = []
	for w in walks:
		town.enter_area(Layout.anchor_area(w[0]), w[0])
		for i in town.team.size():
			town.team[i]["pos"] = Layout.anchor(w[0]) + w[1][i]
			town._place(town.team[i])
		for d in w[2]:
			town.act_move(d)
			var f2 := 0
			while f2 < 5 or town.busy:
				await process_frame
				f2 += 1
			facade_steps += 1
			var lead: Vector2i = town.team[0]["pos"]
			var at2 := {lead: 0}
			for i in range(1, town.team.size()):
				var p: Vector2i = town.team[i]["pos"]
				if not town.follower_ok(p) or at2.has(p):
					facade_bad.append("%s on %s with the leader on %s%s" % [town.team[i]["form"], str(p), str(lead), "" if town.follower_ok(p) else " (a footprint or solid tile)"])
				at2[p] = i
	var facade_ok := facade_bad.is_empty()
	print("Past the facades: %d steps by the Hall's and Home's doors, partners never on a footprint, a door tile or the leader's tile%s -> %s" % [facade_steps, "" if facade_ok else "; " + ", ".join(facade_bad.slice(0, 3)), "ok" if facade_ok else "WRONG"])
	bad += 0 if facade_ok else 1
	# The shut Training Yard (T5): the leader stops at the rope and reads the board.
	town.enter_area(Layout.anchor_area("yard_gate"), "yard_gate_front")
	var gate := Layout.anchor("yard_gate")
	var front := Layout.anchor("yard_gate_front")
	for i in town.team.size():
		town.team[i]["pos"] = front + Vector2i(-i, 0)
		town._place(town.team[i])
	town.act_move(Vector2i(0, 1))
	for f3 in 5:
		await process_frame
	var stopped: bool = not town.open_at(gate) and town.team[0]["pos"] == front
	town.act_use()
	var read: bool = String(town.panel.get("service", "")) == "shut" and String(town.panel.get("name", "")) == "Training Yard"
	var sign: String = String(town.panel.get("what", ""))
	town.panel = {}
	print("Training Yard shut: its gate %s cannot be entered (the leader stays on %s), and E in front of it reads \"%s\" -> %s" % [str(gate), str(town.team[0]["pos"]), sign.left(40), "ok" if stopped and read else "WRONG"])
	bad += 0 if stopped and read else 1
	print("RESULT: %s" % ("the team walks" if bad == 0 else "%d problems" % bad))
	quit()
