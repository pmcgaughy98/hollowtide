extends SceneTree
## Records the kit system: creatures choosing their own moves, Stormwick's lantern, and the
## new Stormlantern (Claude, 2026-10-07). One PNG per frame; prints every move each side used.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_kit_movie.gd
var OUT := ProjectSettings.globalize_path("user://arena_kit_movie/")
var arena: Node2D
var n := 0
var used := {}

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for f in DirAccess.get_files_at(OUT):
		DirAccess.remove_absolute(OUT + f)
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	await process_frame
	# You: Stormwick, against a Scourmaw rival. You run circles round it; your Stormwick
	# picks its own moves. Then you fire Stormlantern.
	arena._you = 0; arena._you_stage = 2; arena._rival = 2; arena._rival_stage = 2
	arena._new_match()
	for i in 240:
		var me: Dictionary = arena._fighters[0]
		var to: Vector2 = arena._fighters[1]["body"].position - me["body"].position
		arena.debug_input = to.normalized() * (1.0 if to.length() > 60.0 else -0.3) + to.normalized().orthogonal() * 0.9
		arena._fighters[1]["meter"] = 0   # keep the rival from firing its own signature first
		await _frame()
	arena.debug_input = Vector2.ZERO
	arena._fighters[0]["meter"] = 100
	arena.signature(0)
	print("stormlantern started: ", arena._sig.active)
	for i in 100:
		if i == 60:
			print("rival stun after the sweep: ", snappedf(arena._fighters[1]["stun"], 0.01))
		await _frame()
	# You: Scourmaw, against a Stormwick rival.
	arena._you = 2; arena._you_stage = 2; arena._rival = 0; arena._rival_stage = 2
	arena._new_match()
	for i in 210:
		var me: Dictionary = arena._fighters[0]
		var to: Vector2 = arena._fighters[1]["body"].position - me["body"].position
		arena.debug_input = to.normalized() * (0.6 if to.length() > 70.0 else -0.4) + to.normalized().orthogonal() * 0.5
		await _frame()
	print("frames ", n)
	for k in used:
		print("  ", k, " x", used[k])
	quit()

func _frame() -> void:
	for l in arena._labels:
		if l["t"] == 0.0 or l["t"] < 0.034:
			var key: String = ("you " if l["who"] == 0 else "rival ") + arena._fighters[l["who"]]["name"] + ": " + l["text"]
			if not used.has(key + "@" + str(n)):
				used[key] = used.get(key, 0) + 1
				used[key + "@" + str(n)] = true
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + "f%04d.png" % n)
	n += 1
