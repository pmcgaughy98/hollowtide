extends SceneTree
## Kit Sense (Claude, 2026-10-08): the AI's modes and desires. A newly held enemy becomes the
## team's called target and damage dealers switch to it; a kill on the table puts a creature
## in finish mode and it takes it; a skirmisher that is low with a blow coming kites; the
## protector peels; and the log explains every decision.
## Judged since Claude, 2026-10-24 (H22): the call, the finish and its kill, kite, peel, and a
## full 3v3 that runs to a winner with calls and engage decisions. How many switched to the
## called target stays printed, not judged (Q11).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_kitsense_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/kitsense_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D
var fails := 0

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.auto_you = true
	arena.show_ai_log = true
	seed(7)
	# 1. The called target: a 3v3, everyone held except our team; one enemy gets rooted.
	arena.team_size = 3
	arena._you = 0; arena._you_stage = 2       # Stormwick, Rampartroot, Scourmaw
	arena._rival = 3; arena._rival_stage = 2   # Ironvent, Vitrecrag, Oxbowarchon
	arena._new_match()
	await _frames(5)
	var enemies := []
	var mine := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
			arena._fighters[j]["stun"] = 60.0
		else:
			mine.append(j)
	await _frames(3)
	var at: Vector2 = arena._fighters[0]["body"].position
	arena._fighters[enemies[0]]["body"].position = at + Vector2(70, -30)
	arena._fighters[enemies[1]]["body"].position = at + Vector2(70, 30)
	arena._fighters[enemies[2]]["body"].position = at + Vector2(140, 0)
	for j in enemies:
		arena._fighters[j]["stun"] = 0.0
		arena._fighters[j]["held_was"] = false
		arena._fighters[j]["act"] = 60.0
		for m in arena._fighters[j]["cds"]:
			arena._fighters[j]["cds"][m] = 99.0
	await _frames(2)
	for j in mine:
		arena._fighters[j]["target"] = enemies[0]
		arena._fighters[j]["retarget"] = 5.0
	arena._fighters[enemies[1]]["rooted"] = 2.0   # someone rooted this one
	await _frames(6)
	var called: int = arena._called[0]["target"]
	var switched := 0
	for j in mine:
		if arena._foe_of(j) == enemies[1]:
			switched += 1
	print("Called target: the rooted %s is the team's call (%s); %d of 3 switched to it" % [arena._fighters[enemies[1]]["name"], "yes" if called == enemies[1] else "no", switched])
	_ok("The rooted enemy becomes the team's called target", called == enemies[1])
	_save("kitsense_call")
	# 2. Finish: an enemy at 8 HP beside Stormwick.
	for j in enemies:
		arena._fighters[j]["stun"] = 60.0
	var me: Dictionary = arena._fighters[0]
	arena._fighters[enemies[0]]["hp"] = 8
	arena._fighters[enemies[0]]["body"].position = me["body"].position + Vector2(30, 0)
	me["cds"]["pounce"] = 0.0
	me["act"] = 0.0
	var before: int = arena.ai_log.size()
	await _frames(30)
	var finish_line := ""
	for k in range(before, arena.ai_log.size()):
		if arena.ai_log[k].find("finish") >= 0:
			finish_line = arena.ai_log[k]
			break
	print("Finish: %s; the 8 HP enemy is %s" % [finish_line if finish_line != "" else "no finish decision logged", "down" if arena._fighters[enemies[0]]["hp"] <= 0 else "still up"])
	_ok("A finish decision is logged and the 8 HP enemy goes down", finish_line != "" and arena._fighters[enemies[0]]["hp"] <= 0)
	# 3. Kite: a Scourmaw at a third of its HP with a claw coming.
	arena.team_size = 1
	arena._you = 2
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 0.0
	foe["body"].position = me["body"].position + Vector2(20, 0)
	me["hp"] = int(me["max_hp"] * 0.3)
	foe["windup"] = {"m": "cinder_claw", "kind": "melee", "t": 0.1, "total": 0.25, "target": 0}
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	before = arena.ai_log.size()
	await _frames(3)
	var kite_line := ""
	for k in range(before, arena.ai_log.size()):
		if arena.ai_log[k].find("kite") >= 0:
			kite_line = arena.ai_log[k]
	print("Kite: mode %s; %s" % [me["mode"], kite_line if kite_line != "" else "no kite decision logged"])
	_ok("The low skirmisher with a blow coming is in kite mode and logs it", me["mode"] == "kite" and kite_line != "")
	# 4. Peel: Starward with a hurt ally and an enemy on it.
	arena.team_size = 3
	arena._you = 6
	arena._rival = 1
	arena._new_match()
	await _frames(5)
	me = arena._fighters[0]
	enemies.clear(); mine.clear()
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
		elif j != 0:
			mine.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	arena._fighters[mine[0]]["body"].position = me["body"].position + Vector2(80, 0)
	arena._fighters[mine[0]]["hp"] = int(arena._fighters[mine[0]]["max_hp"] * 0.3)
	arena._fighters[enemies[0]]["body"].position = me["body"].position + Vector2(100, 4)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	before = arena.ai_log.size()
	await _frames(4)
	var peel_line := ""
	for k in range(before, arena.ai_log.size()):
		if arena.ai_log[k].find("peel") >= 0:
			peel_line = arena.ai_log[k]
	var peel_gap: float = me["body"].position.distance_to(arena._fighters[mine[0]]["body"].position)
	print("Peel: mode %s; %s; Starward now %.0f px from the hurt ally" % [me["mode"], peel_line if peel_line != "" else "no peel decision logged", peel_gap])
	_ok("The protector peels, logs it and stays within 80 px of the hurt ally", me["mode"] == "peel" and peel_line != "" and peel_gap < 80.0)
	_save("kitsense_peel")
	# 5. A full AI 3v3 with the log on.
	arena._you = 0
	arena._rival = 3
	arena._new_match()
	var frames := 0
	# The match ends on points after MATCH_SECONDS of unfrozen time; hitstop and signatures stop
	# that clock, so the budget is the full match plus 60 s of slack (Claude, 2026-10-24).
	var budget: int = int(arena.MATCH_SECONDS * 30.0) + 1800
	while arena._winner < 0 and frames < budget:
		await process_frame
		frames += 1
		if frames == 300:
			_save("kitsense_log")
	var calls := 0
	var modes := {}
	for line in arena.ai_log:
		if line.find("calls it") >= 0:
			calls += 1
		for mode in ["finish", "peel", "kite", "hold", "engage"]:
			if line.find(" " + mode + ":") >= 0:
				modes[mode] = modes.get(mode, 0) + 1
	# _winner is a team index (0 yours, 1 the rival's), not a fighter index (Claude, 2026-10-24).
	print("AI 3v3 Stormwick team vs Ironvent team: %s after %.0f s; in the last %d logged decisions: %s; %d calls" % [("your team" if arena._winner == 0 else "the rival team") if arena._winner >= 0 else "no winner yet", frames / 30.0, arena.ai_log.size(), str(modes), calls])
	for k in range(maxi(0, arena.ai_log.size() - 6), arena.ai_log.size()):
		print("  " + arena.ai_log[k])
	_ok("The AI 3v3 reaches a winner within the match clock plus slack", arena._winner >= 0)
	_ok("The AI 3v3 makes at least one call and some engage decisions", calls >= 1 and modes.has("engage"))
	print("ARENA KIT SENSE: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails > 0 else 0)


## One judged line: "what -> ok" or "what -> FAIL" (Claude, 2026-10-24).
func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
