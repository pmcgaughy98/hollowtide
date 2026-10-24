extends SceneTree
## The painted-VFX pass (Claude, 2026-10-07 night): stages each new sheet in play and saves a
## still: lantern balls in flight, the light slash on a pounce, the teleport flash, a molten
## splash, stone dust on a shatter, the vent flame, a root eruption, and the mark glyph.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_vfx_pass_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/vfx_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(55)
	arena.team_size = 1
	arena._you = 0; arena._you_stage = 2      # Stormwick
	arena._rival = 3; arena._rival_stage = 2  # Ironvent
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 60.0
	me["cds"]["pounce"] = 99.0
	# Lantern balls and marks: a volley across the field.
	me["body"].position = foe["body"].position + Vector2(-90, 0)
	me["cds"]["lantern_volley"] = 0.0
	me["act"] = 0.0
	arena.cast(1)
	await _frames(14)
	_save("vfx_lantern_balls")
	await _frames(40)
	_save("vfx_marks")
	# Ember Feint toward the marked target (Claude, 2026-10-24): slot 0 has been Ember Feint since
	# it replaced Flashstep on 2026-10-08 (KITS "stormwick"); the still keeps its old file name.
	foe["marked"] = 8.0
	me["cds"]["ember_feint"] = 0.0
	me["act"] = 0.0
	arena.cast(0)
	await _frames(3)
	_save("vfx_teleport")
	print("Ember Feint still (slot 0, toward the marked target): vfx_teleport.png")
	# Light slash: a pounce strike.
	me["cds"]["pounce"] = 0.0
	me["body"].position = foe["body"].position + Vector2(-40, 0)
	await _frames(2)
	arena._do_move(0, "pounce", 1)
	await _frames(5)
	_save("vfx_slash")
	# Vent flame: Ironvent's Stoke venting (heat full, then a Vent Barrage).
	foe["stun"] = 0.0
	foe["heat"] = 100.0
	foe["cds"]["vent_barrage"] = 0.0
	arena._do_move(1, "vent_barrage", 0)
	await _frames(4)
	_save("vfx_vent_flame")
	foe["stun"] = 60.0
	# Stone dust: the boulder shatters.
	var hits := 0
	while arena._rocks.size() == 5 and hits < 10:
		arena._hit_rock(0, 20)
		hits += 1
		await _frames(2)
	await _frames(4)
	_save("vfx_rock_dust")
	# Root eruption and molten splash: Rampartroot's Root Rampart and Vitrecrag's Molten Cannon on Stormwick.
	arena._you = 1; arena._rival = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	foe["stun"] = 60.0
	me["cds"]["seed"] = 99.0
	foe["body"].position = me["body"].position + Vector2(80, 0)
	arena._do_move(0, "root_rampart", 1)
	await _frames(17)
	_save("vfx_root_burst")
	arena._you = 4
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	foe["stun"] = 60.0
	foe["body"].position = me["body"].position + Vector2(90, 0)
	arena._do_move(0, "molten_cannon", 1)
	await _frames(17)
	_save("vfx_glass_splash")
	print("VFX pass stills saved; sheets loaded: %d" % arena._impact_frames.size())
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
