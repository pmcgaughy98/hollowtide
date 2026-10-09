extends SceneTree
## The River Listener line in the arena (Claude, 2026-10-08): Cutbank Listener, Bend Caller,
## Quietwater Warden, the Controller. Stage kits, Echo Tap, Interrupt Call, Deep Brace,
## Still Water, the Listening passive, Hush, then AI fights.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_listener_check.gd
## Stills to docs/creatures/arena-listener-2026-10-08/.

const OUT := "res://docs/creatures/arena-listener-2026-10-08/"
const LINE := 7
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(19)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.team_size = 1
	arena._rival = 0; arena._rival_stage = 2   # Stormwick
	# 1. Each stage's kit.
	for stage in 3:
		arena._you = LINE; arena._you_stage = stage
		arena._new_match()
		await _frames(3)
		var me: Dictionary = arena._fighters[0]
		var names := []
		for m in me["abilities"]:
			names.append(arena.MOVES[m]["name"])
		print("%s (stage %d): basic %s; abilities %s; passive '%s'; role %s/%s; signature %s" % [me["name"], stage + 1, arena.MOVES[me["kit"][0]]["name"], str(names), me["passive"], me["role"], me["group"], "yes" if me["final"] else "no"])
		_save("line_stage%d" % (stage + 1))
	# 2. Echo Tap, Interrupt Call, Deep Brace on stage 1.
	arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["body"].position = me["body"].position + Vector2(40, 0)
	var hp: int = foe["hp"]
	arena._fire(0, "echo_tap", 1)
	var tap: int = hp - foe["hp"]
	foe["stun"] = 0.0
	foe["windup"] = {"m": "pounce", "kind": "melee", "t": 0.2, "total": 0.22, "target": 0}
	hp = foe["hp"]
	me["act"] = 0.0
	arena._fire(0, "interrupt_call", 1)
	print("Echo Tap took %d. Interrupt Call: the enemy's wind-up %s, it took %d and is stunned %.1f s" % [tap, "was cancelled" if foe["windup"].is_empty() else "survived (WRONG)", hp - foe["hp"], foe["stun"]])
	_save("interrupt_call")
	me["act"] = 0.0
	arena._fire(0, "deep_brace", 1)
	me["act"] = 0.0
	me["recovering"] = ""
	foe["body"].position = me["body"].position + Vector2(28, 0)
	var p0: Vector2 = me["body"].position
	var q0: Vector2 = foe["body"].position
	hp = me["hp"]
	foe["stun"] = 60.0
	arena._hurt(0, 20, Vector2(-1, 0) * 1.2, 1)
	await _frames(3)
	print("Deep Brace: a 20 shove took %d, moved the Listener %.0f px and shoved the attacker back %.0f px" % [hp - me["hp"], me["body"].position.distance_to(p0), foe["body"].position.distance_to(q0)])
	# 3. Still Water and Listening on stage 2.
	arena._you_stage = 1
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["body"].position = me["body"].position + Vector2(50, 0)
	arena._fire(0, "still_water", 1)
	foe["cds"]["pounce"] = 4.0
	me["cds"]["echo_tap"] = 4.0
	await _frames(30)
	print("Still Water: after 1 s the enemy's 4 s cooldown is at %.2f (in the water: %s) and the Caller's own at %.2f" % [foe["cds"]["pounce"], "yes" if arena._in_still(1) else "no", me["cds"]["echo_tap"]])
	_save("still_water")
	var factor: float = arena._listen_factor(1)
	foe["stun"] = 0.0
	for m in foe["cds"]:
		foe["cds"][m] = 0.0
	foe["act"] = 0.0
	foe["hush"] = 0.0
	var waited := 0
	while foe["windup"].is_empty() and waited < 90:
		await process_frame
		waited += 1
	var w: Dictionary = foe["windup"]
	var base: float = arena.TELEGRAPH[w["m"]][1] if not w.is_empty() else 0.0
	print("Listening: the enemy %d px away winds up %.2fx slower; its %s telegraph runs %.2f s against %.2f s normally" % [foe["body"].position.distance_to(me["body"].position), factor, arena.MOVES[w["m"]]["name"] if not w.is_empty() else "(none)", w.get("total", 0.0), base])
	# 4. Hush on the Warden, in a 1v1: the enemy winding up as the river goes still.
	arena._you_stage = 2
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	me["meter"] = 100
	foe["body"].position = me["body"].position + Vector2(90, 0)
	arena.signature(0)
	await _frames(60)   # 2.0 s in: the card is over, the rings are spreading
	_save("hush_rings")
	foe["stun"] = 0.0
	foe["windup"] = {"m": "lantern_volley", "kind": "line", "t": 1.0, "total": 1.0, "target": 0}
	var waited_fall := 0
	while foe["hush"] <= 0.0 and waited_fall < 40:   # the fall comes at 2.5 s into the signature
		await process_frame
		waited_fall += 1
	var cancelled: bool = foe["windup"].is_empty()
	var hushed: float = foe["hush"]
	var dazed: float = foe["dazzle"]
	_save("hush_fall")
	for m in foe["cds"]:
		foe["cds"][m] = 0.0
	foe["act"] = 0.0
	var used_ability := false
	for k in 45:
		await process_frame
		if not foe["windup"].is_empty() and foe["windup"]["m"] in foe["abilities"]:
			used_ability = true
		if foe["last_move"] in foe["abilities"] and foe["hush"] > 0.0:
			used_ability = true
	print("Hush: at the fall the enemy's wind-up %s, it is hushed for %.1f s, dazed %.1f s (invuln %.2f, phase %.2f); in the next 1.5 s with every cooldown clear it %s; still water over the floor: %s" % ["was cancelled" if cancelled else "survived (WRONG)", hushed, dazed, foe["invuln"], foe["phase"], "used an ability (WRONG)" if used_ability else "used only its basic", "yes" if arena._in_still(1) else "no"])
	while arena._sig.active:
		await process_frame
	# 5. AI 1v1: the Warden against Stormwick, both AI.
	arena._new_match()
	await _frames(3)
	arena.auto_you = true
	var frames := 0
	var calls := 0
	var was_call := false
	while arena._winner < 0 and frames < 2400:
		await process_frame
		frames += 1
		if frames == 240:
			_save("ai_1v1")
		var is_call: bool = arena._fighters[0]["last_move"] == "interrupt_call" and arena._fighters[0]["cds"]["interrupt_call"] > 7.0
		if is_call and not was_call:
			calls += 1   # the log keeps only its last lines, so count the calls as they happen
		was_call = is_call
	print("AI 1v1 Warden vs Stormwick: %s after %.0f s; the Warden called %d times; dealt %d, took %d" % ["the Warden" if arena._winner == 0 else ("Stormwick" if arena._winner == 1 else "draw"), frames / 30.0, calls, arena._fighters[0]["dealt"], arena._fighters[0]["max_hp"] - arena._fighters[0]["hp"]])
	# 6. AI 3v3 with the Warden leading.
	arena.team_size = 3
	arena._rival = 3
	arena._new_match()
	await _frames(3)
	var team := []
	for f in arena._fighters:
		if f["team"] == 0:
			team.append(f["name"])
	frames = 0
	while arena._winner < 0 and frames < 2700:
		await process_frame
		frames += 1
		if frames == 360:
			_save("ai_3v3")
	var hushes := 0
	for line in arena.ai_log:
		if line.find("Hushed") >= 0 or line.find("hush") >= 0:
			hushes += 1
	print("AI 3v3 %s vs the Ironvent team: %s after %.0f s" % [str(team), "the Warden's team" if arena._winner == 0 else ("the rival team" if arena._winner == 1 else "draw"), frames / 30.0])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
