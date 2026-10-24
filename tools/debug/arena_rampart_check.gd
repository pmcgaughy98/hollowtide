extends SceneTree
## Playtest fixes (Claude, 2026-10-07 night): no damage during the tackle (Thorns), Ember Feint
## (it replaced Flashstep on 2026-10-08), Rampartroot's tank kit (Tail Club, Root Snare, Root
## Rampart) and the Verdant Roar signature, and longer fights.
## Verdicts (Claude, 2026-10-24, factory pass 4): every step ends "-> ok" or "-> WRONG". Root
## Rampart now waits for the Tail Club carry to finish before it stages its target; the carry
## used to drag Stormwick off the spot the roots were aimed at, so they missed.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_rampart_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/rampart_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(44)
	# 1. Tackle against Rampartroot: Thorns must not touch an invulnerable attacker.
	arena.team_size = 1
	arena._you = 0; arena._you_stage = 2
	arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	_hold(foe)
	me["cds"]["pounce"] = 99.0
	foe["marked"] = 8.0
	me["cds"]["lantern_tackle"] = 0.0
	me["act"] = 0.0
	var hp0: int = me["hp"]
	arena.cast(2)
	while not me["tackle"].is_empty():
		await process_frame
	_check("Tackle vs Rampartroot", me["hp"] == hp0, "my HP %d -> %d during the whole tackle (Thorns used to leak through)" % [hp0, me["hp"]])
	# 2. Ember Feint: a hop back out of reach, untouchable for the hop.
	foe["marked"] = 0.0
	me["act"] = 0.0
	var before: Vector2 = me["body"].position
	arena.cast(0)
	await process_frame
	var moved: float = before.distance_to(me["body"].position)
	_check("Ember Feint", absf(moved - arena.FEINT_HOP) <= 1.0 and me["invuln"] > 0.0,
		"hopped %.0f px (rule %.0f), invulnerable %.2f s" % [moved, arena.FEINT_HOP, me["invuln"]])
	_save("rampart_flashstep")
	# 3. Rampartroot's kit, you controlling it: Tail Club carries, Root Rampart roots and raises pillars.
	arena._you = 1; arena._rival = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	_hold(foe)
	me["cds"]["seed"] = 99.0
	foe["body"].position = me["body"].position + Vector2(24, 0)
	me["cds"]["club_slam"] = 0.0
	me["act"] = 0.0
	var fp: Vector2 = foe["body"].position
	arena.cast(0)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(10)
	var carried: float = fp.distance_to(foe["body"].position)
	_check("Tail Club", carried > 0.0, "Stormwick carried %.0f px" % carried)
	# Whether the club slams the target into the floor has no agreed rule yet (Q11): printed, not judged.
	print("Tail Club slam (printed only): %s" % ("yes" if foe["dazzle"] > 0.0 else "no"))
	# Root Rampart: let the carry and Rampartroot's recovery finish first, so the target stands
	# where the roots are aimed.
	for k in 90:
		if foe["carry_t"] <= 0.0 and me["windup"].is_empty() and me["act"] <= 0.0:
			break
		await process_frame
	foe["body"].position = me["body"].position + Vector2(80, 0)
	me["cds"]["root_rampart"] = 0.0
	me["act"] = 0.0
	var hp1: int = foe["hp"]
	var walls0: int = arena._walls.size()
	arena.cast(2)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(8)
	_save("rampart_rootrun")
	await _frames(10)
	_check("Root Rampart", foe["rooted"] > 0.0 and foe["hp"] < hp1 and arena._walls.size() > walls0,
		"Stormwick HP %d -> %d, rooted %.2f s, pillars standing %d (were %d)" % [hp1, foe["hp"], foe["rooted"], arena._walls.size(), walls0])
	_save("rampart_pillars")
	# 4. Verdant Roar in a 3v3: every rival rooted, a vine field at the target.
	arena.team_size = 3
	arena._new_match()
	await _frames(30)
	me = arena._fighters[0]
	for f in arena._fighters:
		if f["team"] == 1:
			f["charm_cd"] = 99.0   # Beads would shed the roots this step counts
	me["meter"] = 100
	arena.signature(0)
	var rooted := -1
	for t in [1.3 + 0.1, 1.3 + 0.45, 1.3 + 1.1, 1.3 + 1.45]:
		while arena._sig.active and arena._sig._t < t:
			await process_frame
		_save("rampart_roar_%.2fs" % t)
		if absf(t - (1.3 + 0.45)) < 0.01:
			rooted = 0
			for f in arena._fighters:
				if f["team"] == 1 and f["rooted"] > 0.0:
					rooted += 1
	await _frames(10)
	var vines := 0
	for e in arena._effects:
		if e["kind"] == "vines":
			vines += 1
	_check("Verdant Roar", rooted == 3 and vines >= 1, "%d of 3 rivals rooted by the roar; vine fields on the floor %d" % [rooted, vines])
	print("Verdant Roar card art is the title card: %s" % str(me["closeup"].resource_path.get_file()))
	# 5. Fight length: AI 1v1 Stormwick vs Scourmaw and Ironvent vs Rampartroot.
	arena.auto_you = true
	arena.team_size = 1
	for pair in [[0, 2], [3, 1]]:
		arena._you = pair[0]; arena._rival = pair[1]
		arena._new_match()
		var frames := 0
		while arena._winner < 0 and frames < 4500:
			await process_frame
			frames += 1
		_check("Fight length %s vs %s" % [arena._fighters[0]["name"], arena._fighters[1]["name"]], arena._winner >= 0 and frames >= 600,
			"%s after %.0f s (20 s or longer; was 11 to 20 s at 100 HP)" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0])
	quit()


## Holds fighter f still for a staged step: a long stun, and no charm or dodge to break it
## (Beads cleanse a stun; Claude, 2026-10-24).
func _hold(f: Dictionary) -> void:
	f["stun"] = 60.0
	f["charm_cd"] = 99.0
	f["dodge_cd"] = 99.0


func _check(label: String, ok: bool, detail: String) -> void:
	print("%s: %s -> %s" % [label, detail, "ok" if ok else "WRONG"])


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
