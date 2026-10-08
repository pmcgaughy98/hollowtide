extends SceneTree
## The Oxbowarchon line in the arena (Claude, 2026-10-08): Bound Slabs swallow two blows and
## re-form, Ground Spikes hold the target, Stone Cocoon guards then bursts, Slab Vortex throws
## back what is close, the AI fires Jade Lance, and Kingstone Rail lands on the target, floors
## the enemy beside it, leaves the ally alone and ringes the crater with shards.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_oxbowarchon_check.gd
## Stills to docs/creatures/arena-oxbowarchon-2026-10-08/.

const OUT := "res://docs/creatures/arena-oxbowarchon-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(99)
	# The three stages, side by side with Ironvent for scale.
	arena.team_size = 1
	arena._rival = 3; arena._rival_stage = 2
	for stage in 3:
		arena._you = 5; arena._you_stage = stage
		arena._new_match()
		await _frames(8)
		_save("line_stage%d" % (stage + 1))
	# 1. Abilities, 1v1 against a held Ironvent.
	arena._you_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 60.0
	for m in me["cds"]:
		me["cds"][m] = 99.0
	# Bound Slabs: two blows swallowed, the third lands, and a slab re-forms in time.
	var hp0: int = me["hp"]
	arena._hurt(0, 20, Vector2(1, 0), 1)
	arena._hurt(0, 20, Vector2(1, 0), 1)
	var after_two: int = me["hp"]
	var slabs_after_two: int = me["slabs"]
	arena._hurt(0, 20, Vector2(1, 0), 1)
	var after_three: int = me["hp"]
	await _frames(int(arena.SLAB_REFORM * 30) + 15)
	print("Bound Slabs: HP %d -> %d after two blows (%d slabs left), %d after the third; %d slab(s) re-formed after %.0f s" % [hp0, after_two, slabs_after_two, after_three, me["slabs"], arena.SLAB_REFORM])
	# Ground Spikes from 80 px.
	me["body"].position = foe["body"].position + Vector2(-80, 0)
	me["cds"]["ground_spikes"] = 0.0
	me["act"] = 0.0
	var f_hp: int = foe["hp"]
	arena.cast(0)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(2)
	print("Ground Spikes: the target lost %d and is rooted %.2f s" % [f_hp - foe["hp"], foe["rooted"]])
	_save("spikes")
	# Stone Cocoon: a blow during it, then the burst on the enemy beside it.
	me["body"].position = foe["body"].position + Vector2(-30, 0)
	me["cds"]["stone_cocoon"] = 0.0
	me["act"] = 0.0
	me["slabs"] = 0
	arena.cast(1)
	await process_frame
	var my_hp: int = me["hp"]
	arena._hurt(0, 20, Vector2(1, 0), 1)
	var took: int = my_hp - me["hp"]
	f_hp = foe["hp"]
	await _frames(12)
	_save("cocoon")
	await _frames(int(arena.COCOON_SECONDS * 30) + 10)
	print("Stone Cocoon: a 20 blow during it took %d; the burst hit the enemy beside it for %d" % [took, f_hp - foe["hp"]])
	# Slab Vortex up close.
	foe["body"].position = me["body"].position + Vector2(24, 0)
	me["cds"]["slab_vortex"] = 0.0
	me["act"] = 0.0
	f_hp = foe["hp"]
	var before: Vector2 = foe["body"].position
	arena.cast(2)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(12)
	print("Slab Vortex: the enemy lost %d and was thrown %.0f px" % [f_hp - foe["hp"], foe["body"].position.distance_to(before)])
	_save("vortex")
	# The AI fires Jade Lance on its own.
	arena.auto_you = true
	arena._new_match()
	me = arena._fighters[0]
	var lances := 0
	var was := false
	for k in 150:
		await process_frame
		var w: Dictionary = me["windup"]
		var now: bool = not w.is_empty() and w["m"] == "jade_lance"
		if now and not was:
			lances += 1
		was = now
		if k == 40:
			_save("lance")
	print("Jade Lance: your Oxbowarchon's AI wound up %d in 5 s" % lances)
	# 2. Kingstone Rail in a 3v3: the target, an enemy beside it, an ally beside it.
	arena.team_size = 3
	arena._rival = 4; arena._rival_stage = 2
	arena._new_match()
	await _frames(10)
	me = arena._fighters[0]
	var enemies := []
	var allies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
		elif j != 0:
			allies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var target_pos: Vector2 = me["body"].position + Vector2(100, 0)
	arena._fighters[enemies[0]]["body"].position = target_pos
	arena._fighters[enemies[1]]["body"].position = target_pos + Vector2(30, 10)
	arena._fighters[enemies[2]]["body"].position = target_pos + Vector2(90, -20)
	arena._fighters[allies[0]]["body"].position = target_pos + Vector2(-22, 12)
	arena._fighters[allies[1]]["body"].position = me["body"].position + Vector2(0, 30)
	arena.player_target = enemies[0]
	var hp: Array = arena._fighters.map(func(f): return f["hp"])
	me["meter"] = 100
	arena.signature(0)
	for t in [1.3 + 0.7, 1.3 + 1.2, 1.3 + 1.95, 1.3 + 2.12, 1.3 + 2.5]:
		while arena._sig.active and arena._sig._t < t:
			await process_frame
		_save("rail_%.2fs" % (t - 1.3))
	while arena._sig.active:
		await process_frame
	await _frames(2)
	var shards := 0
	for e in arena._effects:
		if e["kind"] == "shards":
			shards += 1
	var g: int = enemies[1]
	print("Kingstone Rail: target %d->%d; the enemy 32 px away %d->%d (%s); the far enemy %d->%d; the ally beside the target %d->%d; %d shard crater(s); the near enemy stands in shards: %s, walks at x%.2f" % [
		hp[enemies[0]], arena._fighters[enemies[0]]["hp"], hp[g], arena._fighters[g]["hp"], "Floored" if arena._fighters[g]["dazzle"] > 0.0 else "not floored",
		hp[enemies[2]], arena._fighters[enemies[2]]["hp"], hp[allies[0]], arena._fighters[allies[0]]["hp"], shards, "yes" if arena._in_shards(g) else "no", arena._hazard_slow(g)])
	await _frames(15)
	_save("rail_after")
	# 3. A full AI 1v1 against Rampartroot.
	arena.team_size = 1
	arena._rival = 1
	arena._new_match()
	me = arena._fighters[0]
	var frames := 0
	while arena._winner < 0 and frames < 3600:
		await process_frame
		frames += 1
		if frames == 150:
			_save("match")
	print("Match vs Rampartroot: %s after %.0f s; dealt %d, took %d" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0, me["dealt"], me["max_hp"] - me["hp"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
