extends SceneTree
## Terrain in motion (Claude, 2026-10-08 night, item 5): a burrow leaves a trench that slows
## enemies and stops their dashes while allies cross free; a riptide drifts toward the nearest
## enemy; the trench fades.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_terrain_check.gd
## Stills to docs/creatures/arena-terrain-2026-10-08/.

const OUT := "res://docs/creatures/arena-terrain-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(53)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = true
	arena.team_size = 3
	arena._you = 1; arena._you_stage = 0       # Tallowroot leads
	arena._rival = 3; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var enemies := []
	var mine := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
		else:
			mine.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var foe: Dictionary = arena._fighters[enemies[0]]
	foe["body"].position = me["body"].position + Vector2(90, 0)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena.player_target = enemies[0]
	arena._fire(0, "burrow", enemies[0])
	await _frames(30)   # under, then up on the far side
	var trench: Dictionary = {}
	for e in arena._effects:
		if e["kind"] == "trench":
			trench = e
	print("Trench: after the burrow a trench %s, %.0f px long, water %s" % ["was laid" if not trench.is_empty() else "is missing (WRONG)", trench["from"].distance_to(trench["to"]) if not trench.is_empty() else 0.0, str(trench.get("water", false))])
	_save("trench")
	# An enemy on the trench is slowed and cannot dash; an ally is not.
	var mid: Vector2 = trench["from"].lerp(trench["to"], 0.5)
	foe["body"].position = mid
	var ally: Dictionary = arena._fighters[mine[1]]
	ally["body"].position = mid + Vector2(0, 2)
	foe["dash_cd"] = 0.0; foe["stun"] = 0.0
	var dashed: bool = arena._dash(enemies[0], Vector2.RIGHT, 0.18, 0.0)
	print("On the trench: the enemy moves at x%.2f and its dash %s; the ally moves at x%.2f" % [arena._hazard_slow(enemies[0]), "was refused" if not dashed else "went (WRONG)", arena._hazard_slow(mine[1])])
	# The riptide drifts toward the nearest enemy.
	arena.team_size = 1
	arena._you = 2; arena._you_stage = 2       # Scourmaw
	arena._rival = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	var start: Vector2 = me["body"].position + Vector2(40, 0)
	foe["body"].position = start + Vector2(60, 0)
	arena._effects.append({"kind": "riptide", "owner": 0, "pos": start, "t": 0.0})
	await _frames(30)
	var rip: Dictionary = {}
	for e in arena._effects:
		if e["kind"] == "riptide":
			rip = e
	print("Riptide: in 1 s the whirlpool drifted %.0f px toward the enemy 60 px away (%s)" % [rip["pos"].distance_to(start) if not rip.is_empty() else 0.0, "it hunts" if not rip.is_empty() and rip["pos"].x > start.x + 10.0 else "it stayed (WRONG)"])
	_save("riptide_drift")
	# The trench fades.
	arena._effects.append({"kind": "trench", "owner": 0, "from": start + Vector2(-40, 30), "to": start + Vector2(40, 30), "t": arena.TRENCH_SECONDS - 0.5, "water": true})
	await _frames(20)
	var left := 0
	for e in arena._effects:
		if e["kind"] == "trench":
			left += 1
	print("Trench fade: %d trench left after its %d s" % [left, int(arena.TRENCH_SECONDS)])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
