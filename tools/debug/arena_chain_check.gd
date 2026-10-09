extends SceneTree
## Punchybuns after Ravana (Claude, 2026-10-08): the three-punch chain whose third punch hooks
## through everyone in front, the Chain that pays out shields and speed at eight hits (stage 2
## up), and crowd-control diminishing returns after Smite.
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
	print("Punch chain: three jabs took %d from the target and %d from the enemy beside it (the third punch hooks through both); chain count %d" % [hp0 - e0["hp"], hp1 - e1["hp"], me["chain"]])
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
	print("Chain payout: Sparkjab's shield %d (7%% of %d HP), the ally beside it shielded %d, haste %.1f s, stacks %d" % [me["shield"], me["max_hp"], arena._fighters[ally]["shield"], me["haste"], me["chain_stacks"]])
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
	foe["body"].position = me["body"].position + Vector2(22, 0)
	var counts := []
	for k in 9:
		me["act"] = 0.0
		me["cds"]["jab"] = 0.0
		arena._fire(0, "jab", 1)
		counts.append(me["chain"])
	print("Punchybun (stage 1): the chain after each of nine punches read %s; shield %d (no passive yet)" % [str(counts), me["shield"]])
	# 4. Diminishing returns: the same 1 s stun, applied fresh four times in a row.
	foe["stun"] = 0.0
	await _frames(2)
	var held := []
	for k in 4:
		foe["stun"] = 1.0
		await process_frame
		held.append("%.2f" % foe["stun"])
		foe["stun"] = 0.0
		await _frames(2)
	print("Diminishing returns: four 1 s stuns in a row held for %s (Stormwick's DR stacks: %d)" % [str(held), foe["dr"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame
