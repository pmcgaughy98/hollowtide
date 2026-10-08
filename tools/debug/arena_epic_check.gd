extends SceneTree
## Signature terrain and the marquee Furnace Roar (Claude, 2026-10-07 night): Molten Glass
## leaves glass pools that burn and slow enemies only; Furnace Roar's geysers stun every
## enemy and its lava seams stay burning along the cone.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_epic_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/epic_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.auto_you = true
	seed(77)
	# 1. Molten Glass in a 3v3: pools, then an enemy and an ally stand in one.
	arena.team_size = 3
	arena._you = 4; arena._you_stage = 2
	arena._rival = 0; arena._rival_stage = 2
	arena._new_match()
	await _frames(30)
	var me: Dictionary = arena._fighters[0]
	me["meter"] = 100
	arena.signature(0)
	while arena._sig.active:
		await process_frame
	var pools := []
	for e in arena._effects:
		if e["kind"] == "glass_pool":
			pools.append(e)
	_save("epic_glass_pools")
	var enemy := -1
	var ally := -1
	for j in arena._fighters.size():
		if arena._fighters[j]["hp"] > 0 and arena._fighters[j]["team"] == 1 and enemy < 0:
			enemy = j
		if arena._fighters[j]["team"] == 0 and j != 0 and ally < 0:
			ally = j
	for f in arena._fighters:
		f["stun"] = 60.0   # hold everyone still in or out of the pool
	arena._fighters[enemy]["body"].position = pools[0]["pos"]
	arena._fighters[ally]["body"].position = pools[1]["pos"]
	var e_hp: int = arena._fighters[enemy]["hp"]
	var a_hp: int = arena._fighters[ally]["hp"]
	await _frames(60)
	print("Molten Glass: %d glass pools; in 2 s the enemy standing in one lost %d HP, the ally standing in one lost %d; enemy slow factor %.2f, ally %.2f" % [pools.size(), e_hp - arena._fighters[enemy]["hp"], a_hp - arena._fighters[ally]["hp"], arena._hazard_slow(enemy), arena._hazard_slow(ally)])
	_save("epic_glass_stand")
	# 2. Furnace Roar in a 3v3 with Ironvent leading.
	arena._you = 3
	arena._new_match()
	await _frames(30)
	me = arena._fighters[0]
	me["meter"] = 100
	var hp_before: Array = arena._fighters.map(func(f): return f["hp"])
	arena.signature(0)
	var stunned_at_geysers := -1
	for t in [1.3 + 0.5, 1.3 + 0.8, 1.3 + 1.05, 1.3 + 1.4, 1.3 + 2.0]:
		while arena._sig.active and arena._sig._t < t:
			await process_frame
		_save("epic_roar_%.2fs" % t)
		if absf(t - (1.3 + 1.05)) < 0.01:
			stunned_at_geysers = 0
			for f in arena._fighters:
				if f["team"] == 1 and f["stun"] > 0.0:
					stunned_at_geysers += 1
	while arena._sig.active:
		await process_frame
	var seams := 0
	for e in arena._effects:
		if e["kind"] == "lava_seam":
			seams += 1
	var line := "Furnace Roar: %d of 3 enemies stunned by the geysers; %d lava seams on the floor; card %s;" % [stunned_at_geysers, seams, str(me["closeup"].resource_path.get_file())]
	for j in arena._fighters.size():
		var f: Dictionary = arena._fighters[j]
		if f["team"] == 1:
			line += "  %s %d->%d" % [f["name"], hp_before[j], f["hp"]]
	print(line)
	await _frames(20)
	_save("epic_roar_after")
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
