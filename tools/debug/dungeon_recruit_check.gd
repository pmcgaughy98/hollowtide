extends SceneTree
## Recruiting (Claude, 2026-10-09): a beaten wild creature can get up and ask to join; Y adds it
## to the team at half health, following in the chain; N lets it go; with a full team it waits
## at the courier hall; answering costs no turn and nothing else happens while it asks; the
## recruit goes down the stairs with the team; a faint loses the run's recruits; a cleared run keeps them.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_recruit_check.gd
## Stills to docs/design/dungeon-recruiting-2026-10-09/.

const OUT := "res://docs/design/dungeon-recruiting-2026-10-09/"

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.real_time_battles = false   # this check tests the turn-based fight rules (2026-10-09: fights are real-time by default)
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	dg.recruit_override = 1.0
	var lead: Dictionary = dg.ents[0]
	dg.traps.clear()
	# 1. Down a wild creature next to the leader: it asks.
	var w := _wild(dg)
	var d := _place_next(dg, w)
	w["hp"] = 1
	await dg.act_attack(0)
	var asked: bool = dg.asking >= 0
	var t0: int = dg.turn
	await dg.act_rest()
	var blocked: bool = dg.turn == t0
	_save("asking")
	print("Asks: %s wants to join: %s; a rest while it asks does nothing: %s" % [w["name"], str(asked), str(blocked)])
	# 2. Y: it joins at half health and follows.
	dg.act_recruit(true)
	print("Joined: team %s; %s on team 0 with %d/%d HP; turn spent answering: %s" % [_team(dg), w["name"], w["hp"], w["max_hp"], str(dg.turn != t0)])
	for k in 6:
		var dd := _free(dg, lead["pos"])
		await dg.act_move(dd)
	print("Follows: after six steps %s is %d tiles from the leader" % [w["name"], dg._cheb(w["pos"], lead["pos"])])
	_save("joined")
	# 3. N: the next one leaves.
	var w2 := _wild(dg)
	_place_next(dg, w2)
	w2["hp"] = 1
	await dg.act_attack(0)
	dg.act_recruit(false)
	print("Declined: %s on the floor: %s; team still %s" % [w2["name"], str(w2["hp"] > 0), _team(dg)])
	# 4. A full team: the next recruit waits at the courier hall.
	dg.party.append([5, 0])
	var extra: Dictionary = dg._make(5, 0, 0, lead["pos"] + _free(dg, lead["pos"]))
	dg.ents.append(extra)
	dg._place(extra)
	# Stage it in the open: in a hallway the team can fill every side of the leader.
	for room in dg.data["rooms"]:
		var c: Vector2i = room.get_center()
		if room.size.x >= 4 and room.size.y >= 4 and dg._occupant(c) < 0:
			lead["pos"] = c
			dg._place(lead)
			break
	var w3 := _wild(dg)
	if not w3.is_empty():
		_place_next(dg, w3)
		w3["hp"] = 1
		await dg.act_attack(0)
		var asked_full: bool = dg.asking >= 0
		dg.act_recruit(true)
		print("   (the full-team recruit: %s at %s from the leader, hp %d after the attack, asked %s)" % [w3["name"], str(w3["pos"] - lead["pos"]), w3["hp"], str(asked_full)])
		print("Full team (4): %s went to the hall roster: %s; roster %s" % [w3["name"], str(not dg.roster.is_empty()), str(dg.roster)])
	# 5. Down the stairs: the recruit comes along.
	var before: int = dg.party.size()
	lead["pos"] = dg.data["stairs"]
	dg._place(lead)
	await dg.act_stairs()
	await _frames(4)
	print("B2F: team %s (party list %d -> %d)" % [_team(dg), before, dg.party.size()])
	# 6. A faint loses the run's recruits and the roster entry.
	dg.ents[0]["hp"] = 0
	dg.bag.erase("rally_seed")
	dg._end_turn()
	await _frames(4)
	print("Faint: party back to %s, roster %s" % [str(dg.party), str(dg.roster)])
	# 7. A cleared run keeps them.
	dg.recruit_override = 1.0
	var w4 := _wild(dg)
	_place_next(dg, w4)
	w4["hp"] = 1
	await dg.act_attack(0)
	dg.act_recruit(true)
	for f in range(dg.floor_n, dg.FLOORS + 1):
		dg.ents[0]["pos"] = dg.data["stairs"]
		dg._place(dg.ents[0])
		await dg.act_stairs()
		await _frames(3)
	print("Cleared: %d cleared, party now %s (the recruit stays)" % [dg.cleared, str(dg.party)])
	quit()


func _wild(dg: Node2D) -> Dictionary:
	for e in dg.ents:
		if e["team"] == 1 and e["hp"] > 0:
			return e
	return {}


func _place_next(dg: Node2D, w: Dictionary) -> Vector2i:
	var lead: Dictionary = dg.ents[0]
	for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)] + dg.DIRS:   # diagonals too: a full team can fill the four sides
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0:
			w["pos"] = lead["pos"] + dd
			w["awake"] = true
			dg._place(w)
			lead["facing"] = dg._facing_of(dd)
			return dd
	return Vector2i.ZERO


func _free(dg: Node2D, p: Vector2i) -> Vector2i:
	for dd in dg.DIRS:
		if dg.can_step(p, dd) and dg._occupant(p + dd) < 0:
			return dd
	return Vector2i(1, 0)


func _team(dg: Node2D) -> String:
	var names := []
	for e in dg.ents:
		if e["team"] == 0 and e["hp"] > 0:
			names.append(e["name"])
	return str(names)


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
