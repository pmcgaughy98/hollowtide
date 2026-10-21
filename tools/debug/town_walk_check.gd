extends SceneTree
## The town team walks (Claude, 2026-10-10; Preston: "add walking animations to our creatures in the
## world... they just hopped without animation"). Six steps east: how many different pictures each
## creature showed while moving, and whether each is back on its standing picture after.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/town_walk_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")


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
	for k in 6:
		town.act_move(Vector2i(1, 0))
		var f := 0
		while f < 5 or town.busy:   # the whole step: it takes STEP_TIME of real time, however fast frames run
			await process_frame
			f += 1
			for i in town.team.size():
				seen[i][town.team[i]["sprite"].texture] = true
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
	print("RESULT: %s" % ("the team walks" if bad == 0 else "%d problems" % bad))
	quit()
