extends SceneTree
## Stills of the Ironvent line, Furnace Roar, rocks and slams (Claude, 2026-10-07):
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_rocks_capture.gd
## Saves to docs/creatures/arena-ironvent-2026-10-07/ and prints what happened.

const OUT := "res://docs/creatures/arena-ironvent-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.auto_you = true
	seed(11)

	# 1. The three forms of the line side by side, walking (1v1s, one per stage).
	for stage in 3:
		arena.team_size = 1
		arena._you = 3; arena._you_stage = stage
		arena._rival = 0; arena._rival_stage = stage
		arena._new_match()
		await _frames(50)
		_save("line_stage%d" % (stage + 1))

	# 2. Furnace Roar in a 3v3: Ironvent leads your team; its meter is filled and it fires.
	arena.team_size = 3
	arena._you = 3; arena._you_stage = 2
	arena._rival = 0; arena._rival_stage = 2
	arena._new_match()
	await _frames(40)
	arena._fighters[0]["meter"] = 100
	arena.signature(0)
	var hp_before: Array = arena._fighters.map(func(f): return f["hp"])
	for t in [1.3 + 0.45, 1.3 + 0.85, 1.3 + 1.1, 1.3 + 1.6]:
		await _until(t)
		_save("roar_%.2fs" % t)
	await _frames(20)
	var line := "Furnace Roar:"
	for j in arena._fighters.size():
		var f: Dictionary = arena._fighters[j]
		line += "  [team %d] %s %d->%d" % [f["team"], f["name"], hp_before[j], f["hp"]]
	print(line)

	# 3. A wall slam: the rival is hit hard toward the arena's right wall.
	arena.team_size = 1
	arena._you = 1; arena._you_stage = 2
	arena._rival = 0; arena._rival_stage = 2
	arena._new_match()
	await _frames(5)
	var floor_rect: Rect2 = arena.ARENAS[arena._arena]["floor"]
	arena._fighters[1]["body"].position = Vector2(floor_rect.end.x - 20, floor_rect.get_center().y)
	var hp := int(arena._fighters[1]["hp"])
	arena._hurt(1, 10, Vector2(3, 0), 0)
	await _frames(12)
	_save("wall_slam")
	print("Wall slam: rival HP %d -> %d, dazzle %.2f, wall marks %d" % [hp, arena._fighters[1]["hp"], arena._fighters[1]["dazzle"], arena._wall_marks.size()])

	# 4. A rock slam and a rock breaking into rubble.
	var rock: Dictionary = arena._rocks[0]   # the boulder
	arena._fighters[1]["body"].position = rock["pos"] + Vector2(-rock["rx"] - 20, 0)
	await _frames(2)
	arena._hurt(1, 10, Vector2(3, 0), 0)
	await _frames(12)
	print("Rock slam: rock HP %d of %d" % [rock["hp"], rock["max_hp"]])
	_save("rock_slam")
	arena.auto_you = false   # hold still: no AI signature cards over the rubble shot
	var shots := 0
	while arena._rocks.size() == 3:
		for f in arena._fighters:
			f["meter"] = 0
		arena._hit_rock(0, 15)
		shots += 1
		if shots == 2:
			await _frames(8)
			_save("rock_cracked")
		await _frames(8)
	await _frames(40)
	_save("rock_rubble")
	print("Rock broken: %d rocks left, %d rubble bits on the floor" % [arena._rocks.size(), arena._rubble_bits.size()])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


## Waits until the running signature's clock (card included) reaches t seconds.
func _until(t: float) -> void:
	while arena._sig.active and arena._sig._t < t:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
