extends SceneTree
## Records a scripted arena match, one PNG per frame (Claude, 2026-10-07).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_movie.gd
## then: ffmpeg -framerate 30 -i <user>/arena_movie/f%04d.png -pix_fmt yuv420p arena.mp4
## Kithflare fights the rival Tallowroot and lands Stormlantern; Rimefin vs Kithflare with
## Undertow; Tallowroot vs Rimefin on the stone arena with Root Rampart, then a win.
var OUT := ProjectSettings.globalize_path("user://arena_movie/")
var arena: Node2D
var n := 0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for f in DirAccess.get_files_at(OUT):
		DirAccess.remove_absolute(OUT + f)
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	await process_frame
	await _fight(110)
	await _signature()
	_switch(2, 0, 0)
	await _fight(60)
	await _signature()
	_switch(1, 2, 1)
	await _fight(60)
	await _signature()
	arena._fighters[1]["hp"] = 8
	await _fight(90)
	print("frames ", n)
	quit()

func _switch(you: int, rival: int, map: int) -> void:
	arena._you = you
	arena._rival = rival
	arena._set_arena(map)
	arena._new_match()

## You walk toward the rival, sidestep, and attack whenever lined up; the rival plays itself.
func _fight(frames: int) -> void:
	for i in frames:
		var me: Dictionary = arena._fighters[0]
		var foe: Dictionary = arena._fighters[1]
		var to_foe: Vector2 = foe["body"].position - me["body"].position
		var side := to_foe.normalized().orthogonal() * (1.0 if (i / 40) % 2 == 0 else -1.0)
		arena.debug_input = (to_foe.normalized() if to_foe.length() > 70.0 else Vector2.ZERO) + side * 0.5
		if i % 12 == 0:
			me["facing"] = arena._facing_of(to_foe)
			arena.debug_input = Vector2.ZERO
			arena.attack(0)
		await _frame()

func _signature() -> void:
	arena.debug_input = Vector2.ZERO
	arena._fighters[0]["meter"] = 100
	arena.signature(0)
	for i in 110:
		await _frame()

func _frame() -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + "f%04d.png" % n)
	n += 1
