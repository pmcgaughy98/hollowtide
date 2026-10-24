extends SceneTree
## Every stage its own kit; Ember Feint replaces Flashstep (Claude, 2026-10-08). The feint
## hops out of reach even with the wall at its back and leaves embers that burn the chaser;
## Kithflare rakes and spits ember shots; Sparkwick fires Wick Bolt; Tallowroot burrows behind
## the target; Cinderhide pounces.
## Verdicts (Claude, 2026-10-24, factory pass 4): every step ends "-> ok" or "-> WRONG". Ember
## Shot and Wick Bolt now start with the enemy inside the move's range (it stood out of range,
## so the press was refused and nothing fired), and the Rimefin dive pair is gone: Rimefin no
## longer has a dive.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_stage_kits_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/stagekit_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(44)
	arena.team_size = 1
	# 1. Ember Feint in the open, then with the wall at its back.
	arena._you = 0; arena._you_stage = 2
	arena._rival = 3; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	_hold(foe)
	for m in me["cds"]:
		me["cds"][m] = 99.0
	var floor_rect: Rect2 = arena.ARENAS[arena._arena]["floor"]
	me["body"].position = floor_rect.get_center()
	foe["body"].position = me["body"].position + Vector2(20, 0)
	var d0: float = me["body"].position.distance_to(foe["body"].position)
	var start: Vector2 = me["body"].position
	me["cds"]["ember_feint"] = 0.0
	me["act"] = 0.0
	arena.cast(0)
	await process_frame
	var inv: float = me["invuln"]
	var patches := 0
	for e in arena._effects:
		if e["kind"] == "fire_patch":
			patches += 1
	var d1: float = me["body"].position.distance_to(foe["body"].position)
	await _frames(3)
	_save("stagekit_feint")
	foe["body"].position = start
	var f_hp: int = foe["hp"]
	await _frames(36)
	_check("Ember Feint (open floor)", d1 > d0 and inv > 0.0 and patches > 0 and foe["hp"] < f_hp,
		"%.0f px from the enemy to %.0f px, untouchable %.2f s, %d ember patches; the enemy walked onto them and lost %d in 1.2 s" % [d0, d1, inv, patches, f_hp - foe["hp"]])
	# At the wall: the enemy stands between it and the open floor.
	me["body"].position = Vector2(floor_rect.position.x + 2.0, floor_rect.get_center().y)
	foe["body"].position = me["body"].position + Vector2(20, 0)
	_hold(foe)
	me["cds"]["ember_feint"] = 0.0
	me["act"] = 0.0
	arena.cast(0)
	await process_frame
	var d_wall: float = me["body"].position.distance_to(foe["body"].position)
	_check("Ember Feint (back to the wall)", d_wall > d0,
		"hopped %.0f px and now stands %.0f px from the enemy (was %.0f)" % [me["body"].position.distance_to(Vector2(floor_rect.position.x + 2.0, floor_rect.get_center().y)), d_wall, d0])
	await _frames(3)
	_save("stagekit_feint_wall")
	# 2. Kithflare: Rake basic, Ember Feint and Ember Shot.
	arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	_hold(foe)
	for m in me["cds"]:
		me["cds"][m] = 99.0
	foe["body"].position = me["body"].position + Vector2(arena.MOVES["fireball"]["range"] * 0.6, 0)
	me["cds"]["fireball"] = 0.0
	me["act"] = 0.0
	arena.cast(1)
	while not me["windup"].is_empty():
		await process_frame
	var shots := 0
	for e in arena._effects:
		if e["kind"] == "fireball" and e["owner"] == 0:
			shots += 1
	_check("Kithflare kit", _kit_matches(me), "basic %s; abilities %s" % [arena.MOVES[me["kit"][0]]["name"], str(me["abilities"].map(func(m): return arena.MOVES[m]["name"]))])
	_check("Ember Shot", shots >= 1, "fired %d shot(s) at an enemy %.0f px away (range %.0f)" % [shots, me["body"].position.distance_to(foe["body"].position), arena.MOVES["fireball"]["range"]])
	_save("stagekit_kithflare")
	# 3. Sparkwick: Wick Bolt and Lantern Charge.
	arena._you_stage = 1
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	_hold(foe)
	for m in me["cds"]:
		me["cds"][m] = 99.0
	foe["body"].position = me["body"].position + Vector2(arena.MOVES["wick_bolt"]["range"] * 0.6, 0)
	me["cds"]["wick_bolt"] = 0.0
	me["act"] = 0.0
	var f_hp2: int = foe["hp"]
	arena.cast(1)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(8)
	_check("Sparkwick kit", _kit_matches(me), "abilities %s, passive %s" % [str(me["abilities"].map(func(m): return arena.MOVES[m]["name"])), me["passive"]])
	_check("Wick Bolt", foe["hp"] < f_hp2, "took the enemy %.0f px away (range %.0f) %d -> %d" % [me["body"].position.distance_to(foe["body"].position), arena.MOVES["wick_bolt"]["range"], f_hp2, foe["hp"]])
	# 4. Tallowroot burrows behind the target.
	arena._you = 1; arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	_hold(foe)
	for m in me["cds"]:
		me["cds"][m] = 99.0
	me["body"].position = foe["body"].position + Vector2(-100, 0)
	me["cds"]["burrow"] = 0.0
	me["act"] = 0.0
	arena.cast(1)
	var hid := false
	for k in 40:
		await process_frame
		if me["hidden"]:
			hid = true
	var rel: Vector2 = me["body"].position - foe["body"].position
	_check("%s %s" % [me["name"], arena.MOVES["burrow"]["name"]], hid and not me["hidden"] and rel.x > 0.0,
		"went under (%s) and came up %.0f px from the target on its far side (%s)" % ["yes" if hid else "no", rel.length(), "yes" if rel.x > 0 else "no"])
	# 5. Cinderhide pounces; and an AI 1v1 Stormwick against Rampartroot counting feints.
	arena._you = 3; arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	_check("Cinderhide kit", _kit_matches(me), "basic %s; abilities %s" % [arena.MOVES[me["kit"][0]]["name"], str(me["abilities"].map(func(m): return arena.MOVES[m]["name"]))])
	arena.auto_you = true
	arena._you = 0; arena._you_stage = 2
	arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	me = arena._fighters[0]
	var feints := 0
	var inv_was := false
	var frames := 0
	while arena._winner < 0 and frames < 3000:
		await process_frame
		frames += 1
		var inv_now: bool = me["invuln"] > 0.0 and me["tackle"].is_empty()
		if inv_now and not inv_was:
			feints += 1
		inv_was = inv_now
	_check("AI 1v1 Stormwick vs Rampartroot", arena._winner >= 0 and feints >= 1,
		"%s after %.0f s; Stormwick feinted %d times; dealt %d, took %d" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0, feints, me["dealt"], me["max_hp"] - me["hp"]])
	quit()


## Whether fighter f carries exactly its form's KITS entry: the basic first, then the abilities in order.
func _kit_matches(f: Dictionary) -> bool:
	var kit: Dictionary = arena.KITS[arena.LINES[f["line"]]["forms"][f["stage"]][0]]
	return f["kit"][0] == kit["moves"][0] and str(f["abilities"]) == str(kit["abilities"])


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
