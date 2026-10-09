extends SceneTree
## The walk back-and-forth on the turn-based grid (Preston, 2026-10-09: "its doing the walk back and
## forth glitch again... its when I walk in hallways"). Before the fix: about 2,200 pacing turns in
## four runs and three floors never cleared; after: 6, all a leader turning round. Pass: a handful.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_pace_check.gd
## Autopilot over several floors; after every turn, record each
## creature's tile; a creature that returns to the tile it stood on two turns ago, without
## attacking between, is pacing. Also counts sprite pull-backs: frames where a creature's sprite
## moves away from its tile after having been closer.

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var pace := {}
	var examples: Array[String] = []
	var pulls := 0
	for sd in [99, 4242, 7, 31337]:
		var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
		dg.floor_seed = sd
		dg.poll_input = false
		dg.real_time_battles = false
		root.add_child(dg)
		for k in 4:
			await process_frame
		dg.autopilot = true
		var hist := {}
		var last_turn: int = dg.turn
		var last_dist := {}
		var frames := 0
		while dg.floor_n == 1 and frames < 30 * 90:
			await process_frame
			frames += 1
			for e in dg.ents:
				if e["hp"] <= 0:
					continue
				var dist: float = e["node"].position.distance_to(dg._tile_px(e["pos"]))
				var key: int = e.get_instance_id() if false else dg.ents.find(e)
				if last_dist.has(key) and dist > last_dist[key] + 0.5 and dist > 3.0 and not dg.busy:
					pulls += 1
				last_dist[key] = dist
			if dg.turn == last_turn:
				continue
			last_turn = dg.turn
			for k in dg.ents.size():
				var e: Dictionary = dg.ents[k]
				if e["hp"] <= 0 or (e["team"] == 1 and not e["awake"]):
					continue
				var h: Array = hist.get(k, [])
				h.append(e["pos"])
				hist[k] = h
				if h.size() >= 3 and h[-1] == h[-3] and h[-2] != h[-1]:
					var who: String = "leader" if k == 0 else ("partner" if e["team"] == 0 else "wild")
					pace[who] = pace.get(who, 0) + 1
					if examples.size() < 12:
						var t: int = dg._target(k) if k > 0 else -1
						examples.append("seed %d turn %d: %s %s %s -> %s -> %s; target %s; leader at %s" % [sd, dg.turn, who, e["name"], str(h[-3]), str(h[-2]), str(h[-1]), dg.ents[t]["name"] + str(dg.ents[t]["pos"]) if t >= 0 else "none", str(dg.ents[0]["pos"])])
		print("seed %d: %d turns, floor %d" % [sd, dg.turn, dg.floor_n])
		dg.queue_free()
		await process_frame
	print("Pacing (A -> B -> A) by kind: %s; sprite pull-backs while idle: %d" % [str(pace), pulls])
	for x in examples:
		print("   ", x)
	quit()
