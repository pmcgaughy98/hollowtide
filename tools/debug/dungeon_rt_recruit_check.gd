extends SceneTree
## The real-time battle path never recruits a boss or its minions (Claude, 2026-10-27, pass 9 D6, H9-37). Dungeon
## fights are turn-based (real_time_battles is off, Preston 2026-10-09), but the arena hand-over is kept, and its end
## (_end_battle) asked downed wild creatures to join without the boss and minion guard the turn path has had since
## 2026-10-21 ("minions and bosses never recruit"). Three staged fights with the recruit chance forced to 1: a plain
## wild Rimefin, the same one marked as a minion, and one marked as a boss. Each is knocked out in the arena and the
## battle ends won; only the plain one may ask to join.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/dungeon_rt_recruit_check.gd

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


func _run() -> void:
	var plain: Dictionary = await _fight("")
	var minion: Dictionary = await _fight("minion")
	var boss: Dictionary = await _fight("boss")
	_ok("A plain wild knocked out in the arena may ask to join (battle %s, asking %s)" % [plain["battle"], plain["asks"]], plain["battle"] and plain["asks"])
	_ok("A minion knocked out in the arena does not ask (battle %s, asking %s)" % [minion["battle"], minion["asks"]], minion["battle"] and not minion["asks"])
	_ok("A boss knocked out in the arena does not ask (battle %s, asking %s)" % [boss["battle"], boss["asks"]], boss["battle"] and not boss["asks"])
	print("DUNGEON RT RECRUIT: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()


## One staged arena fight on B1F of Rootbank Warren: a wild Rimefin awake four tiles from the leader, marked `mark`.
func _fight(mark: String) -> Dictionary:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 1], [1, 1]]
	root.add_child(dg)
	await _frames(4)
	dg.real_time_battles = true
	dg.recruit_override = 1.0
	dg.traps.clear()
	var lead: Dictionary = dg.ents[0]
	var spot := Vector2i.ZERO
	for room in dg.data["rooms"]:
		if room.size.x >= 7 and room.size.y >= 3:
			spot = room.position + Vector2i(1, 1)
			break
	for e in dg.ents:
		if e["team"] == 1:
			e["pos"] = Vector2i(-60, -60)
			e["awake"] = false
	lead["pos"] = spot
	dg.ents[1]["pos"] = spot + Vector2i(0, 1)
	var w: Dictionary = dg._make(2, 0, 1, spot + Vector2i(4, 0))
	w["awake"] = true
	if mark != "":
		w[mark] = true
	dg.ents.append(w)
	var k_w: int = dg.ents.size() - 1
	for e in dg.ents:
		dg._place(e)
	dg._reveal()
	# The walk sets in_battle and then defers _start_battle (dungeon.gd, end of the leader's step); do the same here
	# (pass 9 integration: without it the first run read "battle false" with the arena running).
	dg.in_battle = true
	dg._start_battle()
	await _frames(2)
	var b: Node2D = dg._battle
	var out := {"battle": b != null and dg.in_battle, "asks": false}
	if b != null:
		for n in b._fighters.size():
			if b._fighters[n]["team"] == 1:
				b._fighters[n]["hp"] = 0
		dg._end_battle(0)
		out["asks"] = dg.asking == k_w
	dg.queue_free()
	await _frames(3)
	return out
