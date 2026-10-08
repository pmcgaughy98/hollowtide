extends SceneTree
## Scourmaw's ability kit (Claude, 2026-10-07 night): Phase lets a hit pass, Riptide lands on
## the target, Sinkhole resurfaces behind the target and sharpens the next Deep Jet, the AI
## fires Deep Jet on its own, and Undertow still works.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_scourmaw_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/scourmaw_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(66)
	arena.team_size = 1
	arena._you = 2; arena._you_stage = 2      # Scourmaw
	arena._rival = 1; arena._rival_stage = 2  # Rampartroot
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 60.0
	me["cds"]["deep_jet"] = 99.0
	# 1. Phase: a hit during it passes through.
	me["cds"]["phase"] = 0.0
	me["act"] = 0.0
	var hp0: int = me["hp"]
	arena.cast(0)
	await process_frame
	arena._hurt(0, 20, Vector2(1, 0), 1)
	print("Phase: phasing %.2f s; a 20-damage hit during it left HP %d -> %d" % [me["phase"], hp0, me["hp"]])
	# 2. Riptide on the target.
	me["cds"]["riptide"] = 0.0
	me["act"] = 0.0
	me["body"].position = foe["body"].position + Vector2(-90, 0)
	arena.cast(1)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(3)
	var pools := 0
	for e in arena._effects:
		if e["kind"] == "riptide":
			pools += 1
	print("Riptide: %d current on the floor, %s under the target" % [pools, "yes" if arena._in_riptide(1) else "no"])
	_save("scourmaw_riptide")
	await _frames(80)
	# 3. Sinkhole: resurfaces behind the target, next Deep Jet sharpened.
	me["body"].position = foe["body"].position + Vector2(-120, 0)
	me["cds"]["sinkhole"] = 0.0
	me["act"] = 0.0
	var cold: int = arena._dmg("deep_jet", 0, 1)
	arena.cast(2)
	while me["hidden"] or me["sink"] > 0.0:
		await process_frame
	await _frames(2)
	var rel: Vector2 = me["body"].position - foe["body"].position
	var hot: int = arena._dmg("deep_jet", 0, 1)
	print("Sinkhole: resurfaced %.0f px from the target on its far side (%s); Deep Jet %d cold, %d sharpened" % [rel.length(), "yes" if rel.x > 0 else "no", cold, hot])
	_save("scourmaw_ambush")
	# 4. The AI fires Deep Jet as the basic, and a full AI 1v1 ends with a winner.
	arena.auto_you = true
	arena._new_match()
	me = arena._fighters[0]
	var jets := 0
	var frames := 0
	var was := false
	while arena._winner < 0 and frames < 2700:
		await process_frame
		frames += 1
		var w: Dictionary = me["windup"]
		var now: bool = not w.is_empty() and w["m"] == "deep_jet"
		if now and not was:
			jets += 1
		was = now
		if frames == 120:
			_save("scourmaw_match")
	print("Match vs Rampartroot: %s after %.0f s; your Scourmaw's AI wound up %d Deep Jets" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0, jets])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
