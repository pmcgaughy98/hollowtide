extends SceneTree
## The storm cold open (Claude, 2026-10-10; scripts/storm_open.gd): the storm on the riverbank with no ruin
## yet, lightning, time stopping (the picture greys, the rain hangs), the soul floating down to the waking
## spot, then the soul prologue. Windowed it saves stills to docs/design/storm-open-2026-10-10/.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/storm_open_check.gd

const OUT := "res://docs/design/storm-open-2026-10-10/"
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _until(cond: Callable, secs: float) -> bool:
	var t := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t < int(secs * 1000):
		if cond.call():
			return true
		await process_frame
	return cond.call()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var s: Node2D = load("res://scenes/storm_open.tscn").instantiate()
	root.add_child(s)
	await _until(func() -> bool: return s.get_child_count() > 0, 2.0)
	for k in 60:
		await process_frame
	await _snap("1_storm")
	var lit: bool = await _until(func() -> bool: return s.flash > 0.5, 12.0)
	_ok("Lightning strikes", lit)
	await _snap("2_lightning")
	var stopped: bool = await _until(func() -> bool: return s.frozen and s.grey > 0.99, 15.0)
	_ok("Time stops: the picture greys and the rain hangs", stopped)
	await _snap("3_still")
	var down: bool = await _until(func() -> bool: return s.soul_glow > 0.9 and s.soul_at.y > 30.0, 10.0)
	await _snap("4_soul")
	var landed: bool = await _until(func() -> bool: return s.soul_at.distance_to(s.WAKE_AT) < 1.0, 10.0)
	_ok("The soul floats down to the waking spot", down and landed)
	await _snap("5_landed")
	var next: bool = await _until(func() -> bool: return s.has_meta("next"), 8.0)
	_ok("Then the soul prologue begins (%s)" % s.get_meta("next", ""), next)
	print("STORM OPEN: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
