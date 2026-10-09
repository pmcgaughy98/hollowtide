extends SceneTree
## The Rimefin line rekit as the ambusher (Claude, 2026-10-09): stage kits, Needle Bite,
## Lunge (a rush that bites and flings the target back), Silt Dive sharpening the next bite
## through the Ambush passive, the passive on an enemy not watching it, no hover, Undertow
## still the signature, and AI fights.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_ambusher_check.gd
## Stills to docs/creatures/arena-remakes-2026-10-09/.

const OUT := "res://docs/creatures/arena-remakes-2026-10-09/"
const LINE := 2
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(21)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = true
	arena.team_size = 1
	arena._rival = 3; arena._rival_stage = 2   # Ironvent: a bruiser that can be gripped (a rampart cannot, by design)
	for stage in 3:
		arena._you = LINE; arena._you_stage = stage
		arena._new_match()
		await _frames(3)
		var me: Dictionary = arena._fighters[0]
		var names := []
		for m in me["abilities"]:
			names.append(arena.MOVES[m]["name"])
		print("%s (stage %d): basic %s; abilities %s; passive '%s'; role %s/%s; signature %s; shadow %s, sprite rest %s" % [me["name"], stage + 1, arena.MOVES[me["kit"][0]]["name"], str(names), me["passive"], me["role"], me["group"], arena.LINES[LINE]["signature"] if me["final"] else "no", "shown" if me["body"].get_child(0).visible else "hidden (WRONG)", str(me["sprite"].position)])
		_save("ambusher_stage%d" % (stage + 1))
	# Needle Bite and Lunge on the final.
	arena._you_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	await _until_free(me)
	foe["body"].position = me["body"].position + Vector2(24, 0)
	arena.player_target = 1
	var hp: int = foe["hp"]
	arena._fire(0, "needle_bite", 1)
	await _frames(12)
	var bite: int = hp - foe["hp"]
	await _until_free(me)
	foe["body"].position = me["body"].position + Vector2(80, 0)
	var start: Vector2 = foe["body"].position
	hp = foe["hp"]
	me["cds"]["lunge"] = 0.0
	arena._fire(0, "lunge", 1)
	var gripped := false
	for k in 20:
		await process_frame
		if foe["grabbed"] > 0.0 or foe["carry_t"] > 0.0:
			gripped = true
	_save("lunge")
	await _frames(40)
	var moved: Vector2 = foe["body"].position - start
	print("Needle Bite from 24 px took %d. Lunge from 80 px: bite %d, the target %s and ended %d px %s of where it stood" % [bite, hp - foe["hp"], "gripped" if gripped else "not gripped (WRONG)", int(absf(moved.x)), "west (dragged back)" if moved.x < -5.0 else "east or still (WRONG)"])
	# Silt Dive, then the sharpened bite (the Ambush passive), then a plain bite.
	await _until_free(me)
	foe["stun"] = 60.0
	foe["grabbed"] = 0.0
	foe["carry_t"] = 0.0
	foe["body"].position = me["body"].position + Vector2(90, 0)
	foe["target"] = 0
	me["cds"]["sinkhole"] = 0.0
	arena._fire(0, "sinkhole", 1)
	await _frames(24)
	var behind: float = foe["body"].position.distance_to(me["body"].position)
	var ambush_t: float = me["ambush"]
	var sharp: int = arena._dmg("needle_bite", 0, 1)
	me["ambush"] = 0.0
	var plain: int = arena._dmg("needle_bite", 0, 1)
	foe["target"] = -1
	var unwatched: int = arena._dmg("needle_bite", 0, 1)
	foe["target"] = 0
	print("Silt Dive: surfaced %d px from the target with %.1f s of ambush; a bite then is %d, plain %d, on an enemy not watching it %d" % [int(behind), ambush_t, sharp, plain, unwatched])
	_save("silt_dive")
	# Undertow still the signature.
	me["meter"] = 100
	me["stun"] = 0.0
	arena.signature(0)
	await _frames(20)
	print("Signature: %s, card active %s" % [arena.LINES[LINE]["signature"], str(arena._sig.active)])
	while arena._sig.active:
		await process_frame
	# AI fights.
	arena._rival = 0
	arena._new_match()
	await _frames(3)
	var frames := 0
	var lunges := 0
	var seen := 0
	while arena._winner < 0 and frames < 2400:
		await process_frame
		frames += 1
		while seen < arena.ai_log.size():
			if "Scourmaw: " in arena.ai_log[seen] and "Lunge" in arena.ai_log[seen]:
				lunges += 1
			seen += 1
		if frames == 240:
			_save("ambusher_ai")
	print("AI 1v1 Scourmaw vs Stormwick: %s after %.0f s; Scourmaw dealt %d, took %d, called Lunge %d times" % ["Scourmaw" if arena._winner == 0 else ("Stormwick" if arena._winner == 1 else "draw"), frames / 30.0, arena._fighters[0]["dealt"], arena._fighters[0]["max_hp"] - arena._fighters[0]["hp"], lunges])
	quit()


func _until_free(me: Dictionary) -> void:
	for k in 120:
		await process_frame
		if me["windup"].is_empty() and me["act"] <= 0.0 and me["ram_t"] <= 0.0 and me["hidden"] == false and me["sink"] <= 0.0:
			return


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
