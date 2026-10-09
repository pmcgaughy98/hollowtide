extends SceneTree
## VFX pass 2 (Claude, 2026-10-08): the 24 new painted sheets load, and stills show them in
## place: zones on the floor, statuses on creatures, one-shots on moves.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_vfx2_check.gd
## Stills to docs/creatures/arena-vfx2-2026-10-08/.

const OUT := "res://docs/creatures/arena-vfx2-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(29)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var missing := []
	for name in arena.IMPACTS:
		if not arena._impact_frames.has(name):
			missing.append(name)
	print("Sheets: %d of %d loaded%s" % [arena._impact_frames.size(), arena.IMPACTS.size(), "" if missing.is_empty() else ", missing " + str(missing)])
	# 1. Zones: a 3v3 with everyone held; riptide, still water, downdraft, glass pool, star field, ember patches, a snare.
	arena.team_size = 3
	arena._you = 7; arena._you_stage = 2       # Warden, Galeshear, Stormwick
	arena._rival = 2; arena._rival_stage = 2   # Scourmaw, Ironvent, Vitrecrag
	arena._new_match()
	await _frames(3)
	var mine := []
	var enemies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 0:
			mine.append(j)
		else:
			enemies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	var centre: Vector2 = arena.ARENAS[arena._arena]["floor"].get_center()
	var spots := [Vector2(-120, -40), Vector2(0, -50), Vector2(120, -40), Vector2(-120, 50), Vector2(0, 60), Vector2(120, 50)]
	for k in 3:
		arena._fighters[mine[k]]["body"].position = centre + spots[k]
		arena._fighters[enemies[k]]["body"].position = centre + spots[3 + k]
	arena._effects.append({"kind": "riptide", "owner": enemies[0], "pos": centre + Vector2(-120, -40), "t": 0.5})
	arena._effects.append({"kind": "still_water", "owner": mine[0], "pos": centre + Vector2(-120, 50), "r": arena.STILL_RADIUS, "t": 0.6, "life": arena.STILL_SECONDS})
	arena._effects.append({"kind": "downdraft", "owner": mine[1], "pos": centre + Vector2(0, -50), "t": 0.6})
	arena._effects.append({"kind": "glass_pool", "owner": enemies[2], "pos": centre + Vector2(120, -40), "r": 40.0, "t": 0.5, "tick": 0.0})
	arena._effects.append({"kind": "star_field", "owner": mine[2], "pos": centre + Vector2(0, 60), "t": 0.6, "tick": 0.5})
	for k in 3:
		arena._effects.append({"kind": "fire_patch", "owner": mine[2], "pos": centre + Vector2(60 + k * 14, 0), "t": 0.2, "tick": 0.3, "damage": 3})
	arena._fighters[enemies[1]]["rooted"] = 5.0
	arena._effects.append({"kind": "snare", "who": enemies[1], "t": 0.5})
	await _frames(6)
	_save("zones")
	# 2. Statuses: glassed, smouldering, cocoon, braced, star shield, sail cover.
	arena._fighters[enemies[0]]["glassed"] = 5.0
	arena._fighters[enemies[1]]["smoulder"] = 5.0
	arena._fighters[enemies[2]]["cocoon"] = 5.0
	arena._fighters[mine[0]]["brace"] = 5.0
	arena._shield(mine[2], 25, 5.0)
	arena._shield(mine[1], 20, 5.0, "sail_cover")
	await _frames(6)
	_save("statuses")
	# 3. One-shots: a call, a slam, a jade spike, a spark, a sail slash, a hush ring, a gust.
	arena._effects.append({"kind": "impact", "anim": "sonar_ring", "pos": centre + Vector2(-120, 58), "t": 0.0, "scale": 2.5})
	arena._effects.append({"kind": "impact", "anim": "slam_shock", "pos": centre + Vector2(0, 66), "t": 0.0, "scale": 1.4})
	arena._effects.append({"kind": "impact", "anim": "jade_spikes", "pos": centre + Vector2(120, 56), "t": 0.0, "scale": 1.3})
	arena._effects.append({"kind": "impact", "anim": "spark_bolt", "pos": centre + Vector2(-120, -32), "t": 0.0})
	arena._effects.append({"kind": "impact", "anim": "sail_slash", "pos": centre + Vector2(0, -54), "t": 0.0, "scale": 1.5})
	arena._effects.append({"kind": "impact", "anim": "gust_lift", "pos": centre + Vector2(120, -44), "t": 0.0, "scale": 1.3})
	arena._effects.append({"kind": "impact", "anim": "steam_puff", "pos": centre + Vector2(-60, 0), "t": 0.0})
	arena._effects.append({"kind": "impact", "anim": "jade_burst", "pos": centre + Vector2(60, -20), "t": 0.0, "scale": 1.5})
	await _frames(4)
	_save("oneshots")
	# 4. A seed lob and a slab vortex mid-flight.
	arena._effects.append({"kind": "seed", "owner": enemies[0], "from": centre + Vector2(-120, 50), "to": centre + Vector2(0, -50), "t": 0.0, "damage": 1})
	arena._effects.append({"kind": "vortex", "who": enemies[2], "t": 0.0})
	await _frames(7)
	_save("projectiles")
	print("Stills: zones, statuses, oneshots, projectiles")
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
