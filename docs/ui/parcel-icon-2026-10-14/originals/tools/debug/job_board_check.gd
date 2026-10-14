extends SceneTree
## The Job Board loop (Claude, 2026-10-10): take two requests in Highbank, meet the lost client and
## pick up the lost item on their floor, come home and be paid. Windowed, it also saves stills.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/job_board_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const Jobs := preload("res://scripts/town/jobs.gd")
const OUT := "res://docs/design/job-board-2026-10-10/"
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _town() -> Node2D:
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	TeamState.give_to(town)
	root.add_child(town)
	await _frames(6)
	var board: Dictionary = town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "board")[0]
	town.team[0]["pos"] = board["door"]
	town._place(town.team[0])
	return town


func _run() -> void:
	TeamState.start([[0, 0], [1, 0]])
	# 1. The board: four requests; take the first two.
	var town := await _town()
	town.act_use()
	var rows: Array = town.board_rows()
	_ok("Board opens with %d requests: %s" % [rows.size(), ", ".join(rows.map(func(j: Dictionary) -> String: return "%s B%dF" % [Jobs.title(j), j["floor"]]))], town.panel.get("service", "") == "board" and rows.size() == Jobs.POSTED)
	town.act_board_pick()
	town.act_board_move(1)
	town.act_board_pick()
	await _frames(30)
	await _snap("board_taken")
	var jobs: Array = TeamState.data.get("jobs", [])
	_ok("Taken: %s" % str(jobs.map(func(j: Dictionary) -> String: return j["id"])), jobs.size() == 2)
	# Put the two on the first floor, one of each kind, so one floor tests both.
	jobs[0]["kind"] = "rescue"
	jobs[1]["kind"] = "lost_item"
	jobs[1]["item"] = "river_stone"
	for j in jobs:
		j["floor"] = 1
	town.queue_free()
	await _frames(2)
	# 2. The run: the client waits in a room, the item lies in one.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	TeamState.give_to(dg)
	dg.floor_seed = 4242
	dg.poll_input = false
	root.add_child(dg)
	await _frames(20)
	var job_items: Array = dg.floor_items.filter(func(it: Dictionary) -> bool: return it.has("job"))
	_ok("On B1F: %d client waiting, %d lost item" % [dg.clients.size(), job_items.size()], dg.clients.size() == 1 and job_items.size() == 1)
	var c: Dictionary = dg.clients[0]
	_ok("The client blocks the way like a wall", not dg.can_step(c["pos"] + Vector2i(1, 0), Vector2i(-1, 0)) or not dg._floor_at(c["pos"] + Vector2i(1, 0)))
	var lead: Dictionary = dg.ents[0]
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var q: Vector2i = c["pos"] - d
		if dg._floor_at(q) and dg._occupant(q) < 0:
			lead["pos"] = q
			dg._place(lead)
			dg._reveal()
			await _frames(10)
			await _snap("client_waiting")
			dg.act_move(d)
			break
	await _frames(20)
	await _snap("client_thanks")
	_ok("Walking into it: job done %s, its line '%s'" % [str(dg.jobs[0]["done"]), str(dg.talk[0][1]) if not dg.talk.is_empty() else ""], dg.jobs[0]["done"] and not dg.talk.is_empty() and dg.clients.is_empty())
	dg.talk.clear()
	var bag_before: Dictionary = dg.bag.duplicate()
	lead["pos"] = job_items[0]["pos"]
	dg._place(lead)
	dg._pick_up()
	_ok("Picking up the lost item: job done %s, bag unchanged %s" % [str(dg.jobs[1]["done"]), str(dg.bag == bag_before)], dg.jobs[1]["done"] and dg.bag == bag_before)
	# 3. Home: the board pays both.
	TeamState.take_from(dg, "test")
	var bag0: Dictionary = TeamState.data.get("bag", {}).duplicate()
	dg.queue_free()
	await _frames(2)
	town = await _town()
	town.act_use()
	await _frames(4)
	await _snap("board_paid")
	var paid: Array = town.panel.get("paid", [])
	var bag1: Dictionary = TeamState.data.get("bag", {})
	_ok("Paid: %s; rank %d; bag %s" % [str(paid), int(TeamState.data.get("rank", 0)), str(bag1)],
		paid.size() == 2 and int(TeamState.data["rank"]) > 0 and int(bag1.get("rally_seed", 0)) == int(bag0.get("rally_seed", 0)) + 1 and TeamState.data["jobs"].is_empty())
	town.queue_free()
	await _frames(2)
	# 4. Deliveries (R4, 2026-10-12): a taken parcel rides in the bag, the condition is judged at the client's
	#    feet, and the pay follows it. Two on B1F: one met (the lantern lit), one missed (a trap sprung).
	town = await _town()
	town.act_use()
	var open: Array = town.board_rows()
	var d1: Dictionary = open[0].duplicate(true)
	d1.merge({"id": "d_lit", "kind": "delivery", "floor": 1, "done": false, "reward": "lamp_oil", "count": 1, "pts": 25, "cond": "lit"}, true)
	var d2: Dictionary = open[1].duplicate(true)
	d2.merge({"id": "d_careful", "kind": "delivery", "floor": 1, "done": false, "reward": "lamp_oil", "count": 1, "pts": 25, "cond": "careful"}, true)
	print("  " + Jobs.toggle(TeamState.data, d1))
	Jobs.toggle(TeamState.data, d2)
	_ok("Two deliveries taken: parcels in the bag %d; '%s', asked '%s'" % [int(TeamState.data["bag"].get("parcel", 0)), Jobs.title(d1), Jobs.cond_text(d1)],
		int(TeamState.data["bag"].get("parcel", 0)) == 2 and Jobs.title(d1).begins_with("Deliver to") and Jobs.cond_text(d1) == "before the lantern goes out")
	Jobs.toggle(TeamState.data, d2)
	_ok("One put back: parcels %d" % int(TeamState.data["bag"].get("parcel", 0)), int(TeamState.data["bag"].get("parcel", 0)) == 1)
	Jobs.toggle(TeamState.data, d2)
	town.board_rows()   # the panel lists the two deliveries first; windowed, a still of their rows
	await _frames(4)
	await _snap("board_deliveries")
	var dropped: Array = Jobs.drop_parcels([d1, {"kind": "rescue", "done": false}])
	_ok("A faint drops the deliveries, keeps the rest: kept %d, lost %s" % [dropped[0].size(), str(dropped[1])], dropped[0].size() == 1 and dropped[1].size() == 1)
	town.queue_free()
	await _frames(2)
	dg = load("res://scenes/dungeon.tscn").instantiate()
	TeamState.give_to(dg)
	dg.floor_seed = 4242
	dg.poll_input = false
	root.add_child(dg)
	await _frames(20)
	_ok("Both clients wait on B1F (%d); the bag carries %d parcels" % [dg.clients.size(), int(dg.bag.get("parcel", 0))], dg.clients.size() == 2 and int(dg.bag.get("parcel", 0)) == 2)
	var info: Dictionary = dg._faint_info()
	_ok("A faint now would lose both parcels: %s" % str(info.get("lost_parcels")), info.get("lost_parcels", []).size() == 2)
	dg.act_use_item("parcel")
	await _frames(2)
	_ok("The parcel cannot be used (still %d in the bag)" % int(dg.bag.get("parcel", 0)), int(dg.bag.get("parcel", 0)) == 2)
	for round in 2:
		var cl: Dictionary = dg.clients[0]
		if String(cl["id"]) == "d_careful":
			dg.traps_sprung = 1
		lead = dg.ents[0]
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = cl["pos"] - d
			if dg._floor_at(q) and dg._occupant(q) < 0:
				lead["pos"] = q
				dg._place(lead)
				dg._reveal()
				await _frames(4)
				dg.act_move(d)
				break
		await _frames(20)
		dg.talk.clear()
	var j1: Dictionary = dg._job("d_lit")
	var j2: Dictionary = dg._job("d_careful")
	_ok("Delivered: lit met %s ('%s'), careful missed %s ('%s'), parcels left %d" % [str(j1.get("met")), Jobs.result_text(j1), str(j2.get("met")), Jobs.result_text(j2), int(dg.bag.get("parcel", 0))],
		j1.get("done", false) and j1.get("met") == true and j2.get("done", false) and j2.get("met") == false and not dg.bag.has("parcel"))
	TeamState.take_from(dg, "test")
	var oil0: int = int(TeamState.data.get("bag", {}).get("lamp_oil", 0))
	var rank0: int = int(TeamState.data.get("rank", 0))
	dg.queue_free()
	await _frames(2)
	town = await _town()
	town.act_use()
	await _frames(4)
	var paid2: Array = town.panel.get("paid", [])
	var oil1: int = int(TeamState.data.get("bag", {}).get("lamp_oil", 0))
	var rank1: int = int(TeamState.data.get("rank", 0))
	_ok("Paid by condition: %s; lamp oil +%d, rank +%d" % [str(paid2), oil1 - oil0, rank1 - rank0],
		paid2.size() == 2 and oil1 - oil0 == Jobs.MET_COUNT + 1 and rank1 - rank0 == 25 * 2 + Jobs.MET_PTS and TeamState.data["jobs"].is_empty())
	town.queue_free()
	print("JOB BOARD: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()
