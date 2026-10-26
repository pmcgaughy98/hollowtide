extends SceneTree
## The walk back-and-forth on the turn-based grid (Preston, 2026-10-09: "its doing the walk back and
## forth glitch again... its when I walk in hallways"). Before the fix: about 2,200 pacing turns in
## four runs and three floors never cleared; after: 6, all a leader turning round. Pass: a handful.
## A "partner" count is nearly always a swap echo, not the partner's own following: the leader walks onto a partner in
## its way (often after standing still, as at the end of a fight; sometimes turning round), the two trade tiles, and the
## partner steps back in behind it the next turn. 2026-10-21: partner 4 to 7 per run, 32 of 34 in six probe runs were
## such swaps; damage rolls and recruits use the unseeded global RNG, so counts and turn totals vary run to run.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_pace_check.gd
## Autopilot over several floors; after every turn, record each
## creature's tile; a creature that returns to the tile it stood on two turns ago, without
## attacking between, is pacing. Also counts sprite pull-backs: frames where a creature's sprite
## moves away from its tile after having been closer.
## Judged since 2026-10-22 (Claude, the factory pass, FEEL-17): a FAIL on any idle pull-back and on any
## A -> B -> A by a leader, a partner or a wild creature. A partner's swap echo (the leader stood on B, then
## on A, while the partner went A, B, A) is the chain following as designed; it is counted apart, not failed.
## So is a teammate's pickup detour: the step onto B took the item lying there, then it stepped back.
## The global RNG is seeded per floor, so a run repeats and the counts mean something.

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var pace := {}
	var swaps := 0
	var detours := 0
	var shoves := 0   # knock-backs walked back from, counted apart like the detours (Claude, 2026-10-22)
	var examples: Array[String] = []
	var pulls := 0
	for sd in [99, 4242, 7, 31337]:
		seed(sd)   # damage rolls and recruits draw from the global RNG (Claude, 2026-10-22)
		var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
		dg.floor_seed = sd
		dg.poll_input = false
		dg.real_time_battles = false
		root.add_child(dg)
		for k in 4:
			await process_frame
		dg.autopilot = true
		dg.check_bot = true   # reads lines and welcomes recruits on autopilot (dungeon.gd check_bot, L6-01)
		var hist := {}
		var last_turn: int = dg.turn
		var last_dist := {}
		var snaps: Array = []   # the floor items' tiles at each turn, to tell a pickup detour from pacing
		var frames := 0
		while dg.floor_n == 1 and frames < 30 * 90:
			await process_frame
			frames += 1
			for e in dg.ents:
				if e["hp"] <= 0:
					continue
				var dist: float = e["node"].position.distance_to(dg._tile_px(e["pos"]))
				var key: int = dg.ents.find(e)
				if last_dist.has(key) and dist > last_dist[key] + 0.5 and dist > 3.0 and not dg.busy:
					pulls += 1
					if examples.size() < 12:
						examples.append("seed %d turn %d: %s's sprite pulled back to %.1f px from its tile %s while idle" % [sd, dg.turn, e["name"], dist, str(e["pos"])])
				last_dist[key] = dist
			if dg.turn == last_turn:
				continue
			last_turn = dg.turn
			var here := {}
			for it in dg.floor_items:
				here[it["pos"]] = true
			snaps.append(here)
			for k in dg.ents.size():
				var e: Dictionary = dg.ents[k]
				if e["hp"] <= 0 or (e["team"] == 1 and not e["awake"]):
					continue
				var h: Array = hist.get(k, [])
				h.append(e["pos"])
				hist[k] = h
				if h.size() >= 3 and h[-1] == h[-3] and h[-2] != h[-1]:
					var who: String = "leader" if k == 0 else ("partner" if e["team"] == 0 else "wild")
					# A partner stepping back in behind the leader after trading tiles with it: the header's swap echo.
					var lh: Array = hist.get(0, [])
					if who == "partner" and lh.size() >= 3 and lh[-3] == h[-2] and lh[-2] == h[-3]:
						swaps += 1
						continue
					# A teammate stepping onto an item and back again (the pickup is the point of the step): the
					# item lay on B before that step and was gone after it. Counted apart (Claude, 2026-10-22).
					if e["team"] == 0 and snaps.size() >= 3 and snaps[-3].has(h[-2]) and not snaps[-1].has(h[-2]):
						detours += 1
						continue
					# A knock-back (a dash's shove; dungeon.gd stamps the turn in "shoved_at") carried it to B, and walking
					# back in is not pacing (Claude, 2026-10-22).
					if int(e.get("shoved_at", -99)) >= last_turn - 2:
						shoves += 1
						continue
					pace[who] = pace.get(who, 0) + 1
					if examples.size() < 12:
						var t: int = dg._target(k) if k > 0 else -1
						examples.append("seed %d turn %d: %s %s %s -> %s -> %s; target %s; leader at %s" % [sd, dg.turn, who, e["name"], str(h[-3]), str(h[-2]), str(h[-1]), dg.ents[t]["name"] + str(dg.ents[t]["pos"]) if t >= 0 else "none", str(dg.ents[0]["pos"])])
		print("seed %d: %d turns, floor %d" % [sd, dg.turn, dg.floor_n])
		dg.queue_free()
		await process_frame
	var paced := 0
	for who in pace:
		paced += int(pace[who])
	print("Pacing (A -> B -> A) by kind: %s; partner swap echoes (not pacing): %d; pickup detours (not pacing): %d; knock-backs walked back (not pacing): %d; sprite pull-backs while idle: %d" % [str(pace), swaps, detours, shoves, pulls])
	for x in examples:
		print("   ", x)
	var ok := paced == 0 and pulls == 0
	print("RESULT: %s" % ("no pacing and no pull-backs" if ok else "%d problems (pacing %d, pull-backs %d)" % [paced + pulls, paced, pulls]))
	quit(0 if ok else 1)
