extends SceneTree
## The physical verbs (Claude, 2026-10-08 night, item 3): Plate Lunge seizes and hurls,
## Kingstone Lift throws a rock or the target, Molten Beam pins to the wall and drags, and two
## beams clash.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_verbs_check.gd
## Stills to docs/creatures/arena-verbs-2026-10-08/.

const OUT := "res://docs/creatures/arena-verbs-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(43)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = true
	arena.team_size = 1
	# 1. Plate Lunge: Vitrecrag seizes Stormwick and hurls it into the right wall.
	arena._you = 4; arena._you_stage = 2       # Vitrecrag
	arena._rival = 0; arena._rival_stage = 2   # Stormwick
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var floor_rect: Rect2 = arena.ARENAS[arena._arena]["floor"]
	me["body"].position = Vector2(floor_rect.end.x - 45.0, floor_rect.get_center().y)   # the throw reaches the wall
	foe["body"].position = me["body"].position + Vector2(22, 0)
	foe["stun"] = 0.0
	foe["dodge_cd"] = 9.0; foe["charm_cd"] = 99.0
	var hp: int = foe["hp"]
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena._fire(0, "plate_lunge", 1)
	await _frames(6)   # past the hitstop
	var seized: bool = foe["grabbed"] > 0.0 and foe["airborne"] > 0.0
	_save("seized")
	await _frames(12)
	var thrown: bool = foe["carry_t"] > 0.0 or foe["body"].position.x > me["body"].position.x + 30.0
	await _frames(14)
	var edge: float = floor_rect.end.x - foe["body"].position.x
	print("Plate Lunge: Stormwick %s, then %s; it ended %.0f px from the wall, took %d in all, dazed %.1f s" % ["was seized" if seized else "was not seized (WRONG)", "was thrown" if thrown else "stayed put (WRONG)", edge, hp - foe["hp"], foe["dazzle"]])
	_save("thrown")
	# 2. Kingstone Lift with a rock in reach: the boulder rises and comes down on the target.
	arena._you = 5; arena._you_stage = 2       # Oxbowarchon
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var rk := -1
	for k in arena._rocks.size():
		if arena._rocks[k]["kind"] == "boulder":
			rk = k
	var rock: Dictionary = arena._rocks[rk]
	me["body"].position = rock["pos"] + Vector2(-50, 10)
	foe["body"].position = rock["pos"] + Vector2(110, 10)
	var rocks0: int = arena._rocks.size()
	hp = foe["hp"]
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena._fire(0, "kingstone_lift", 1)
	await _frames(9)
	var lifted: float = rock.get("lift", 0.0)
	_save("lift")
	await _frames(22)
	print("Kingstone Lift: the boulder rose %.0f px (lifted %s), rocks %d -> %d after the landing, Stormwick took %d and was launched %s" % [lifted, "yes" if lifted > 0.0 else "no (WRONG)", rocks0, arena._rocks.size(), hp - foe["hp"], "yes" if foe["airborne"] > 0.0 or foe["airborne_len"] > 0.0 else "no"])
	_save("landing")
	# 3. Kingstone Lift with no rock in reach: the target itself is seized and flung.
	me["body"].position = floor_rect.get_center() + Vector2(-60, 0)
	foe["body"].position = me["body"].position + Vector2(40, 0)
	for k in arena._rocks.size():
		arena._rocks[k]["pos"] = Vector2(floor_rect.position.x + 20, floor_rect.position.y + 20)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	foe["carry_t"] = 0.0
	var fx0: float = foe["body"].position.x
	arena._fire(0, "kingstone_lift", 1)
	await _frames(2)
	var held: bool = foe["grabbed"] > 0.0
	await _frames(40)   # the hold, then the fling
	print("Kingstone Lift without a rock: Stormwick %s and was flung %.0f px" % ["was seized" if held else "was not seized (WRONG)", foe["body"].position.x - fx0])
	# 4. Molten Beam pins Stormwick to the right wall and drags it.
	arena._you = 4
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	me["body"].position = Vector2(floor_rect.end.x - 90.0, floor_rect.get_center().y)
	foe["body"].position = me["body"].position + Vector2(50, 0)
	foe["dodge_cd"] = 9.0; foe["charm_cd"] = 99.0
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	var marks0: int = arena._wall_marks.size()
	hp = foe["hp"]
	arena._fire(0, "molten_beam", 1)
	await _frames(24)   # the shove reaches the wall at about frame 19
	var pinned: bool = foe["pinned"] > 0.0
	var at_wall: float = floor_rect.end.x - foe["body"].position.x
	_save("pinned")
	await _frames(14)
	print("Molten Beam: Stormwick %s %.0f px from the wall, took %d over the beam, %d scorch marks on the wall" % ["was pinned" if pinned else "was not pinned (WRONG)", at_wall, hp - foe["hp"], arena._wall_marks.size() - marks0])
	# 5. Beam clash: Scourmaw's Deep Jet into Vitrecrag's Molten Beam, head on.
	arena._rival = 2   # Scourmaw
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["stun"] = 0.0
	me["body"].position = floor_rect.get_center() + Vector2(-60, 0)
	foe["body"].position = floor_rect.get_center() + Vector2(60, 0)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	for m in foe["cds"]:
		foe["cds"][m] = 0.0
	me["act"] = 0.0; foe["act"] = 0.0
	arena._fire(0, "molten_beam", 1)
	arena._fire(1, "deep_jet", 0)
	foe["stun"] = 60.0
	await _frames(4)
	var clash := false
	for e in arena._effects:
		if e["kind"] == "clash":
			clash = true
	_save("clash")
	var mehp: int = me["hp"]
	var foehp: int = foe["hp"]
	await _frames(70)   # the clash point walks 40 px a second to the weaker caster
	print("Beam clash: %s; afterwards Vitrecrag lost %d and Scourmaw lost %d (the stronger beam breaks through)" % ["a clash point formed" if clash else "no clash (WRONG)", mehp - me["hp"], foehp - foe["hp"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
