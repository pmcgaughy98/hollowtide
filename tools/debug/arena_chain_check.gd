extends SceneTree
## Punchybuns after Ravana (Claude, 2026-10-08): the three-punch chain whose third punch hooks
## through everyone in front, the Chain that pays out shields and speed at eight hits (stage 2
## up), and crowd-control diminishing returns after Smite.
## Verdicts (Claude, 2026-10-24, factory pass 4): every step ends "-> ok" or "-> WRONG". The
## diminishing-returns step now waits out the jabs' hitstop first; its first stun used to land in
## a frozen frame and never count.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_chain_check.gd

var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(31)
	# 1. The hook: Sparkjab against two enemies in front; punches 1 and 2 hit one, punch 3 hits both.
	arena.team_size = 3
	arena._you = 6; arena._you_stage = 1       # Sparkjab leads
	arena._rival = 3
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var enemies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var e0: Dictionary = arena._fighters[enemies[0]]
	var e1: Dictionary = arena._fighters[enemies[1]]
	e0["body"].position = me["body"].position + Vector2(22, 0)
	e1["body"].position = me["body"].position + Vector2(18, 14)
	e0["slabs"] = 0; e1["slabs"] = 0
	var hp0: int = e0["hp"]
	var hp1: int = e1["hp"]
	for k in 3:
		me["act"] = 0.0
		me["cds"]["jab"] = 0.0
		arena._fire(0, "jab", enemies[0])
	_check("Punch chain", hp1 - e1["hp"] > 0, "three jabs took %d from the target and %d from the enemy beside it (the third punch hooks through both); chain count %d" % [hp0 - e0["hp"], hp1 - e1["hp"], me["chain"]])
	# 2. The payout: eight hits in, Sparkjab shields itself and the ally beside it and speeds up.
	var ally := -1
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 0 and j != 0:
			ally = j
			break
	arena._fighters[ally]["body"].position = me["body"].position + Vector2(-20, 0)
	me["shield"] = 0
	arena._fighters[ally]["shield"] = 0
	while me["chain"] != 0 or me["shield"] == 0:
		me["act"] = 0.0
		me["cds"]["jab"] = 0.0
		arena._fire(0, "jab", enemies[0])
		if me["shield"] > 0:
			break
	var want: int = roundi(me["max_hp"] * arena.CHAIN_SHIELD)
	_check("Chain payout", me["shield"] == want and arena._fighters[ally]["shield"] == want and me["haste"] > 0.0 and me["chain_stacks"] >= 1 and me["chain_stacks"] <= arena.CHAIN_STACKS,
		"Sparkjab's shield %d (%.0f%% of %d HP is %d), the ally beside it shielded %d, haste %.1f s, stacks %d of %d" % [me["shield"], arena.CHAIN_SHIELD * 100.0, me["max_hp"], want, arena._fighters[ally]["shield"], me["haste"], me["chain_stacks"], arena.CHAIN_STACKS])
	# 3. Stage 1 counts but does not pay out.
	arena.team_size = 1
	arena._you_stage = 0
	arena._rival = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["charm_cd"] = 99.0; foe["dodge_cd"] = 99.0   # no charm breaks the stuns below (Claude, 2026-10-24)
	foe["body"].position = me["body"].position + Vector2(22, 0)
	var counts := []
	for k in 9:
		me["act"] = 0.0
		me["cds"]["jab"] = 0.0
		arena._fire(0, "jab", 1)
		counts.append(me["chain"])
	_check("Punchybun (stage 1)", me["shield"] == 0 and counts.max() <= arena.CHAIN_PAYOUT,
		"the chain after each of nine punches read %s (pays out at %d); shield %d (no passive yet)" % [str(counts), arena.CHAIN_PAYOUT, me["shield"]])
	# 4. Diminishing returns: the same 1 s stun, applied fresh four times in a row. Each one
	# ticks one frame (1/30 s, faster for a tank) and is then cut by DR_STEP per stack.
	foe["stun"] = 0.0
	for k in 120:
		if arena._hitstop <= 0.0:
			break
		await process_frame
	await _frames(2)
	var ten: float = arena.TENACITY if foe["role"] == "Tank" else 1.0
	var held := []
	var off := 0.0
	for k in 4:
		foe["stun"] = 1.0
		await process_frame
		held.append("%.2f" % foe["stun"])
		off = maxf(off, absf(foe["stun"] - (1.0 - ten / 30.0) * (1.0 - arena.DR_STEP * k)))
		foe["stun"] = 0.0
		await _frames(2)
	_check("Diminishing returns", off <= 0.02 and foe["dr"] == mini(4, arena.DR_MAX),
		"four 1 s stuns in a row held for %s (each %.0f%% less; worst miss %.3f s); %s's DR stacks: %d" % [str(held), arena.DR_STEP * 100.0, off, foe["name"], foe["dr"]])
	quit()


func _check(label: String, ok: bool, detail: String) -> void:
	print("%s: %s -> %s" % [label, detail, "ok" if ok else "WRONG"])


func _frames(n: int) -> void:
	for k in n:
		await process_frame
