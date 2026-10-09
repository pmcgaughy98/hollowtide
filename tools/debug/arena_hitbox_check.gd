extends SceneTree
## Moves as hitboxes (Claude, 2026-10-08 night, item 4): a melee move is a sweep that lands on
## whoever is still in its arc at the active moment and whiffs otherwise; area moves and lobs
## land on the spot the telegraph showed.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_hitbox_check.gd
## Stills to docs/creatures/arena-hitbox-2026-10-08/.

const OUT := "res://docs/creatures/arena-hitbox-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(47)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = true
	arena.team_size = 1
	arena._you = 3; arena._you_stage = 2       # Ironvent
	arena._rival = 0; arena._rival_stage = 2   # Stormwick
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["dodge_cd"] = 99.0; foe["charm_cd"] = 99.0
	# 1. A claw that lands: the target stays in the arc through the telegraph and the active moment.
	foe["body"].position = me["body"].position + Vector2(24, 0)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena.player_target = 1
	var hp: int = foe["hp"]
	arena.cast_as(0, "cinder_claw")
	await _frames(14)   # telegraph 0.25 s + the active moment
	var landed: int = hp - foe["hp"]
	_save("sweep_land")
	# 2. A claw that whiffs: the target steps 40 px aside during the telegraph.
	await _frames(6)
	me["act"] = 0.0
	for m in me["cds"]:
		me["cds"][m] = 0.0
	foe["body"].position = me["body"].position + Vector2(24, 0)
	hp = foe["hp"]
	arena.cast_as(0, "cinder_claw")
	await _frames(3)
	foe["body"].position = me["body"].position + Vector2(-40, 0)   # behind it
	var whiffed := false
	for k in 14:
		await process_frame
		for l in arena._labels:
			if l["text"] == "WHIFF":
				whiffed = true
	print("Sweep: the claw landed for %d when the target stayed; when it stepped behind Ironvent the claw %s and it took %d" % [landed, "whiffed" if whiffed else "still hit (WRONG)", hp - foe["hp"]])
	_save("sweep_whiff")
	# 3. Ground Spikes land where the telegraph showed: the target walks off the spot.
	arena._you = 5; arena._you_stage = 1       # Oathfen
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["dodge_cd"] = 99.0; foe["charm_cd"] = 99.0
	foe["body"].position = me["body"].position + Vector2(70, 0)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena.player_target = 1
	var spot: Vector2 = foe["body"].position
	hp = foe["hp"]
	arena.cast_as(0, "ground_spikes")
	await _frames(4)
	foe["body"].position = spot + Vector2(0, 40)   # off the ring
	await _frames(16)
	var spikes_at := Vector2.ZERO
	for e in arena._effects:
		if e["kind"] == "spikes":
			spikes_at = e["pos"]
	print("Ground Spikes: the jade erupted %.0f px from where the telegraph showed (the target had walked 40 px off it) and the target took %d" % [spikes_at.distance_to(spot), hp - foe["hp"]])
	_save("spikes_miss")
	# 4. The same spikes on a target that stays: a hit and the hold.
	await _frames(20)
	me["act"] = 0.0
	for m in me["cds"]:
		me["cds"][m] = 0.0
	foe["body"].position = me["body"].position + Vector2(70, 0)
	hp = foe["hp"]
	arena.cast_as(0, "ground_spikes")
	await _frames(20)
	print("Ground Spikes on a target that stayed: took %d, rooted %.2f s" % [hp - foe["hp"], foe["rooted"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
