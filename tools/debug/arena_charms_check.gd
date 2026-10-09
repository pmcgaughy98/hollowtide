extends SceneTree
## Charms after Smite's relics (Claude, 2026-10-08 night): each of the eight does what it says,
## your pick from the picker lands on your creature, and the AI reaches for its beads.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_charms_check.gd

var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(41)
	arena.poll_input = false
	arena.team_size = 3
	arena._you = 3; arena._you_stage = 2       # Ironvent, Vitrecrag, Oxbowarchon
	arena._rival = 0; arena._rival_stage = 2   # Stormwick, Rampartroot, Scourmaw
	arena.charm_pick = "blink"
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var mine := []
	var enemies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 0:
			mine.append(j)
		else:
			enemies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var roles := []
	for j in arena._fighters.size():
		roles.append("%s:%s" % [arena._fighters[j]["role"], arena._fighters[j]["charm"]])
	print("Charms by role: %s (your pick 'blink' landed on %s)" % [str(roles), me["name"]])
	# Blink
	var p0: Vector2 = me["body"].position
	arena._player_dir = Vector2.RIGHT
	var ok: bool = arena._use_charm(0)
	print("Blink: %s, moved %.0f px, cooldown %.0f s" % ["used" if ok else "refused (WRONG)", me["body"].position.distance_to(p0), me["charm_cd"]])
	# Beads: a stunned, rooted creature breaks free and is immune for a second.
	me["charm"] = "beads"; me["charm_cd"] = 0.0
	me["stun"] = 2.0; me["rooted"] = 2.0
	ok = arena._use_charm(0)
	me["stun"] = 1.0   # a fresh stun inside the immunity
	await process_frame
	print("Beads: %s; stun %.2f, roots %.2f after, a fresh stun inside the second reads %.2f" % ["used" if ok else "refused (WRONG)", me["stun"], me["rooted"], me["stun"]])
	# Aegis: untouchable and still.
	me["charm"] = "aegis"; me["charm_cd"] = 0.0
	ok = arena._use_charm(0)
	var hp: int = me["hp"]
	arena._hurt(0, 30, Vector2(1, 0), enemies[0])
	p0 = me["body"].position
	arena._player_dir = Vector2.RIGHT
	await _frames(6)
	print("Aegis: %s; a 30 hit took %d; steering moved it %.0f px while it held" % ["used" if ok else "refused (WRONG)", hp - me["hp"], me["body"].position.distance_to(p0)])
	me["aegis"] = 0.0; me["invuln"] = 0.0
	arena._player_dir = Vector2.ZERO
	# Thorns: the attacker takes a share back.
	me["charm"] = "thorns"; me["charm_cd"] = 0.0
	ok = arena._use_charm(0)
	var e0: Dictionary = arena._fighters[enemies[0]]
	e0["body"].position = me["body"].position + Vector2(20, 0)
	var ehp: int = e0["hp"]
	arena._hurt(0, 20, Vector2(1, 0), enemies[0])
	print("Thorns: %s; the enemy's 20 hit cost it %d" % ["used" if ok else "refused (WRONG)", ehp - e0["hp"]])
	me["thorns"] = 0.0
	# Spear: the target takes more from everyone.
	me["charm"] = "spear"; me["charm_cd"] = 0.0
	arena.player_target = enemies[0]
	ok = arena._use_charm(0)
	e0["slabs"] = 0
	ehp = e0["hp"]
	arena._hurt(enemies[0], 20, Vector2(1, 0), mine[1])
	print("Spear: %s; a 20 hit from an ally on the sundered target took %d" % ["used" if ok else "refused (WRONG)", ehp - e0["hp"]])
	# Emblem: enemies close by are slowed.
	me["charm"] = "emblem"; me["charm_cd"] = 0.0
	arena._fighters[enemies[1]]["body"].position = me["body"].position + Vector2(-30, 10)
	ok = arena._use_charm(0)
	print("Emblem: %s; slowed %s and %s (%.1f s)" % ["used" if ok else "refused (WRONG)", "yes" if e0["slowed"] > 0.0 else "no", "yes" if arena._fighters[enemies[1]]["slowed"] > 0.0 else "no", e0["slowed"]])
	# Shell and Wings on the allies beside it.
	for j in mine:
		arena._fighters[j]["body"].position = me["body"].position + Vector2(0, 20 * (j + 1))
		arena._fighters[j]["shield"] = 0
		arena._fighters[j]["haste"] = 0.0
	me["charm"] = "shell"; me["charm_cd"] = 0.0
	ok = arena._use_charm(0)
	var shields := []
	for j in mine:
		shields.append(arena._fighters[j]["shield"])
	me["charm"] = "wings"; me["charm_cd"] = 0.0
	var ok2: bool = arena._use_charm(0)
	var hastes := []
	for j in mine:
		hastes.append("%.1f" % arena._fighters[j]["haste"])
	print("Shell: %s, shields %s (15%% of max HP); Wings: %s, haste %s s" % ["used" if ok else "refused (WRONG)", str(shields), "used" if ok2 else "refused (WRONG)", str(hastes)])
	# The AI reaches for beads when stunned.
	e0["charm"] = "beads"; e0["charm_cd"] = 0.0
	e0["stun"] = 1.5
	await _frames(15)   # past the hitstop the earlier hits left
	print("AI beads: the stunned enemy's charm %s (stun now %.2f, cooldown %.0f s)" % ["went off" if e0["charm_cd"] > 0.0 else "stayed (WRONG)", e0["stun"], e0["charm_cd"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame
