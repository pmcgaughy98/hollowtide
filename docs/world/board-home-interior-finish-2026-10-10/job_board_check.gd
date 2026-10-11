extends SceneTree
## The Job Board loop (Claude, 2026-10-10): take two requests in Highbank, meet the lost client and
## pick up the lost item on their floor, come home and be paid. Windowed, it also saves stills.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/job_board_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const Jobs := preload("res://scripts/town/jobs.gd")
const OUT := "D:/dev/hollowtide-board-home-20261010/review/job_board_check/"
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
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
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
	print("JOB BOARD: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	await _frames(4)
	quit(1 if fails else 0)
