extends SceneTree
## Follow-ups (Claude, 2026-10-09, Preston: "5"): an ability that lands opens a 0.9 s window;
## a basic that lands inside it hits 1.3 times and gives 0.5 s of that ability back; after
## the window a basic is plain; the AI gets the same rhythm.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_combo_check.gd
## Stills to docs/creatures/arena-combo-2026-10-09/.

const OUT := "res://docs/creatures/arena-combo-2026-10-09/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(13)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = false
	arena.team_size = 1
	arena._you = 3; arena._you_stage = 2   # Ironvent
	arena._rival = 0; arena._rival_stage = 2   # Stormwick (no tank armour in the way)
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["dodge_cd"] = 99.0; foe["charm_cd"] = 99.0
	var basic: String = me["kit"][0]
	var ab: String = me["abilities"][1]   # Vent Barrage
	# 1. An ability lands: the window opens.
	me["last_move"] = ab
	me["cds"][ab] = 6.0
	arena._hurt(1, 10, Vector2(1, 0), 0)
	print("%s landed: follow-up window %.2f s, remembered as %s" % [arena.MOVES[ab]["name"], me["follow_t"], arena.MOVES[me["follow_m"]]["name"] if me["follow_m"] != "" else "nothing (WRONG)"])
	await process_frame
	_save("window")
	# 2. A basic inside the window: harder, and the ability comes back a little.
	var cd_before: float = me["cds"][ab]
	me["last_move"] = basic
	var hp: int = foe["hp"]
	arena._hurt(1, 20, Vector2(1, 0), 0)
	var follow: int = hp - foe["hp"]
	var refund: float = cd_before - me["cds"][ab]
	var closed: bool = me["follow_t"] <= 0.0
	await process_frame
	_save("follow_up")
	# 3. A plain basic for comparison, outside any window.
	hp = foe["hp"]
	arena._hurt(1, 20, Vector2(1, 0), 0)
	var plain: int = hp - foe["hp"]
	print("A 20 basic inside the window took %d, the same basic outside it %d; %s got %.1f s back (%.1f before, %.1f after); the window closed: %s" % [follow, plain, arena.MOVES[ab]["name"], refund, cd_before, me["cds"][ab], str(closed)])
	# 4. The window runs out: 0.5 s later a basic is plain.
	me["last_move"] = ab
	arena._hurt(1, 10, Vector2(1, 0), 0)
	await _frames(40)   # 1.3 s, past the window and the hitstop
	me["last_move"] = basic
	hp = foe["hp"]
	arena._hurt(1, 20, Vector2(1, 0), 0)
	print("A basic 1.3 s after the ability landed took %d (plain), window %.2f" % [hp - foe["hp"], me["follow_t"]])
	# 5. The AI gets the rhythm too: a 20 s fight, follow-ups in the log.
	arena.auto_you = true
	arena._you = 0; arena._rival = 3
	arena._new_match()
	var n := 0
	var opened := 0
	var seen := 0
	var sample := ""
	var open_was := {0: false, 1: false}
	for k in 1800:   # 60 s: windows are rare between two finals that dodge
		await process_frame
		for i in 2:
			var is_open: bool = arena._fighters[i]["follow_t"] > 0.0
			if is_open and not open_was[i]:
				opened += 1
			open_was[i] = is_open
		while seen < arena.ai_log.size():   # the log keeps 60 lines, so read it as it grows
			if "follow-up" in arena.ai_log[seen]:
				n += 1
				sample = arena.ai_log[seen]
			seen += 1
	print("AI 1v1 Stormwick vs Ironvent for 60 s: %d windows opened, %d follow-ups landed%s" % [opened, n, (" (last: " + sample.strip_edges() + ")") if n > 0 else ""])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
