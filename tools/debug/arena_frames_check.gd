extends SceneTree
## Frame data, role passives and part breaks (Claude, 2026-10-08): the frame table (startup,
## recovery, advantage on hit), counter hits and punishes, hitstun, the Tank/Damage/Support
## role layer, and rocks that drop reward shards and weaken as they crack.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_frames_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/frames_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(17)
	# 1. The frame table: every telegraphed move's startup, recovery and advantage on a real hit.
	print("Frame table (seconds): startup / recovery / on hit")
	var plus := 0
	var minus := 0
	for m in arena.TELEGRAPH:
		var start: float = arena.TELEGRAPH[m][1]
		var rec: float = arena._recovery(m)
		var adv: float = arena.HITSTUN - rec
		if adv > 0.0:
			plus += 1
		elif adv < 0.0:
			minus += 1
		print("  %-14s %4.2f / %4.2f / %+.2f" % [m, start, rec, adv])
	print("Frame table: %d moves plus on hit, %d minus" % [plus, minus])
	# 2. Counter hit: a hit during a wind-up is worth more and a real one breaks it; a tank's armour holds.
	arena.team_size = 1
	arena._you = 3; arena._you_stage = 2       # Ironvent
	arena._rival = 0; arena._rival_stage = 2   # Stormwick
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	foe["stun"] = 0.0
	foe["windup"] = {"m": "pounce", "kind": "melee", "t": 0.2, "total": 0.22, "target": 0}
	var hp: int = foe["hp"]
	arena._hurt(1, 10, Vector2(1, 0), 0)
	var counter_dmg: int = hp - foe["hp"]
	var broke: bool = foe["windup"].is_empty()
	_save("frames_counter")
	arena._rival = 1; arena._rival_stage = 2   # Rampartroot: armoured by its passive
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	foe["stun"] = 0.0
	foe["windup"] = {"m": "club_slam", "kind": "melee", "t": 0.3, "total": 0.35, "target": 0}
	hp = foe["hp"]
	arena._hurt(1, 10, Vector2(1, 0), 0)
	var armour_dmg: int = hp - foe["hp"]
	var armour_held: bool = not foe["windup"].is_empty()
	print("Counter hit: a 10 hit during Stormwick's wind-up took %d and %s; the same on Rampartroot's club took %d (its guard halves it) and its wind-up %s" % [counter_dmg, "broke it" if broke else "left it (WRONG)", armour_dmg, "held" if armour_held else "broke (WRONG)"])
	# 3. Punish and hitstun: a hit while the target recovers from its own move, and the stop a real hit puts on it.
	foe["windup"] = {}
	foe["recovering"] = "club_slam"
	foe["act"] = 0.45
	hp = foe["hp"]
	arena._hurt(1, 20, Vector2(1, 0), 0)
	var punish_dmg: int = hp - foe["hp"]
	var after_act: float = foe["act"]
	var after_rec: String = foe["recovering"]
	print("Punish: a 20 hit on a recovering Rampartroot took %d; hitstun left it unable to act for %.2f s with recovery cleared (%s)" % [punish_dmg, after_act, "yes" if after_rec == "" else "no"])
	# 4. Recovery: a jab recovers in 0.15 s, a club slam in 0.45.
	me["stun"] = 0.0
	arena._fire(0, "cinder_claw", 1)
	var claw_act: float = me["act"]
	me["cds"]["crest_ram"] = 0.0
	arena._fire(0, "vent_blast", 1)
	var blast_act: float = me["act"]
	print("Recovery: Ironvent's claw left it recovering %.2f s, Vent Blast %.2f s" % [claw_act, blast_act])
	# 5. Role passives: stage 1 inherits the line's role; hits on a tank give less meter and move it less.
	arena._you = 1; arena._you_stage = 0       # Tallowroot
	arena._rival = 4; arena._rival_stage = 2   # Vitrecrag (Tank, no rampart push immunity)
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	var inherited: String = "%s/%s" % [me["role"], me["group"]]
	arena._rival = 0   # Stormwick as the attacker: a final, Damage group
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]   # Tallowroot (tank group, stage 1)
	foe = arena._fighters[1]  # Stormwick
	for f in arena._fighters:
		f["stun"] = 60.0
	foe["meter"] = 0
	var p0: Vector2 = me["body"].position
	me["hp"] = me["max_hp"]
	arena._hurt(0, 5, Vector2(-1, 0) * 1.0, 1)
	var tank_meter: int = foe["meter"]
	var tank_push: float = me["body"].position.distance_to(p0)
	var wound: float = me["wound"]
	me["meter"] = 0
	foe["meter"] = 0
	foe["body"].position = p0 + Vector2(40, 0)
	var q0: Vector2 = foe["body"].position
	arena._hurt(1, 5, Vector2(1, 0) * 1.0, 0)
	var skirm_meter_given: int = 0   # Tallowroot is not a final, so no meter; compare the push instead
	var skirm_push: float = foe["body"].position.distance_to(q0)
	print("Tank passive: Tallowroot reads %s; a hit on it gave Stormwick %d meter (18 to anyone else) and moved it %.0f px against %.0f px for the same push on Stormwick; the Damage-role hit wounded it for %.1f s" % [inherited, tank_meter, tank_push, skirm_push, wound])
	# 6. Wound cuts mending; a Damage-role KO grants haste.
	me["hp"] = 10
	me["mend_acc"] = 0.0
	arena._mend(0, 10)
	var wounded_mend: int = me["hp"] - 10
	me["wound"] = 0.0
	me["hp"] = 10
	arena._mend(0, 10)
	var clean_mend: int = me["hp"] - 10
	me["hp"] = 3
	arena._hurt(0, 20, Vector2(-1, 0), 1)
	print("Wound: 10 mending healed %d while wounded and %d clean; the KO gave Stormwick %.1f s of haste" % [wounded_mend, clean_mend, foe["haste"]])
	# 7. Support regen: a Protector left alone mends itself.
	arena._you = 6; arena._you_stage = 2       # Starward
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["hp"] = me["max_hp"] - 20
	me["since_hit"] = 0.0
	await _frames(30)   # 1.0 s: nothing yet
	var at_1s: int = me["hp"]
	await _frames(36)   # 2.2 s: ticking
	print("Support passive: Starward at -20 HP had mended %d after 1 s and %d after 2.2 s" % [at_1s - (me["max_hp"] - 20), me["hp"] - (me["max_hp"] - 20)])
	# 8. Part breaks: each crack drops a shard and exposes the rock; a final picks the shard up for meter.
	var k := -1
	for r in arena._rocks.size():
		if arena._rocks[r]["kind"] == "boulder":
			k = r
	var rock: Dictionary = arena._rocks[k]
	arena._hit_rock(k, 20)
	var hp1: int = rock["hp"]
	arena._hit_rock(k, 20)
	var hp2: int = rock["hp"]
	var shards := 0
	var shard_pos := Vector2.ZERO
	for e in arena._effects:
		if e["kind"] == "shard":
			shards += 1
			shard_pos = e["pos"]
	_save("frames_shard")
	me["meter"] = 0
	me["body"].position = shard_pos
	await _frames(2)
	var left := 0
	for e in arena._effects:
		if e["kind"] == "shard":
			left += 1
	print("Part breaks: the boulder went 60 -> %d -> %d from two 20 hits (the second landed on an exposed rock); %d shards dropped; Starward walked onto one and its meter went 0 -> %d, %d shard left" % [hp1, hp2, shards, me["meter"], left])
	# 9. Kit Sense wants the counter hit.
	foe = arena._fighters[1]
	foe["body"].position = me["body"].position + Vector2(20, 0)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	foe["windup"] = {}
	var d_clean: float = arena._desire(0, "jab", 1, "engage")
	foe["windup"] = {"m": "club_slam", "kind": "melee", "t": 0.3, "total": 0.35, "target": 0}
	var d_counter: float = arena._desire(0, "jab", 1, "engage")
	print("Kit Sense: jab desire %.2f on a clean target, %.2f on one winding up a slow move" % [d_clean, d_counter])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
