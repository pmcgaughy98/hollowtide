extends SceneTree
## The Vitrecrag line in the arena (Claude, 2026-10-07): the three forms walking, Molten
## Glass in a 3v3, Kiln Heat filling while it stands, and an AI 1v1 against Rampartroot.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_vitrecrag_check.gd
## Stills to docs/creatures/arena-vitrecrag-2026-10-07/.

const OUT := "res://docs/creatures/arena-vitrecrag-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.auto_you = true
	seed(9)
	for stage in 3:
		arena.team_size = 1
		arena._you = 4; arena._you_stage = stage
		arena._rival = 3; arena._rival_stage = stage
		arena._new_match()
		await _frames(45)
		_save("line_stage%d" % (stage + 1))
	# Kiln Heat: hold still, heat should climb to 100 in about 2.2 s; walking cools it.
	arena._you_stage = 2; arena._rival_stage = 2
	arena._new_match()
	var me: Dictionary = arena._fighters[0]
	me["heat"] = 0.0
	await _frames(75)
	print("Kiln Heat after 2.5 s (walk time %.1f s this match): %.0f; cold beam %d, hot beam %d" % [me["walk"], me["heat"],
		arena._dmg("molten_beam", 0, 1), (func(): me["heat"] = 100.0; return arena._dmg("molten_beam", 0, 1)).call()])
	# Molten Glass in a 3v3.
	arena.team_size = 3
	arena._you = 4; arena._rival = 0
	arena._new_match()
	await _frames(40)
	arena._fighters[0]["meter"] = 100
	arena.signature(0)
	var hp_before: Array = arena._fighters.map(func(f): return f["hp"])
	for t in [1.3 + 0.5, 1.3 + 1.0, 1.3 + 1.4, 1.3 + 1.8]:
		while arena._sig.active and arena._sig._t < t:
			await process_frame
		_save("glass_%.2fs" % t)
	await _frames(20)
	var line := "Molten Glass:"
	for j in arena._fighters.size():
		var f: Dictionary = arena._fighters[j]
		line += "  [team %d] %s %d->%d" % [f["team"], f["name"], hp_before[j], f["hp"]]
	print(line)
	# AI 1v1 against Rampartroot.
	arena.team_size = 1
	arena._you = 4; arena._rival = 1
	arena._new_match()
	var frames := 0
	while arena._winner < 0 and frames < 2700:
		await process_frame
		frames += 1
		if frames == 150:
			_save("match")
	var w: Dictionary = arena._fighters[arena._winner] if arena._winner >= 0 else {}
	print("Match vs Rampartroot: %s after %.0f s; Vitrecrag dealt %d, Rampartroot dealt %d" % [w.get("name", "draw"), frames / 30.0,
		arena._fighters[0]["dealt"], arena._fighters[1]["dealt"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
