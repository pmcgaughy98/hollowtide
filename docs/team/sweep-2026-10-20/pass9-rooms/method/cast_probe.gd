extends SceneTree
## Scratch, pass 9 R2: how long the mail call's cast (hall_low) takes to read, and what a spawn costs on the main thread
## after a read ahead of 0, 10 (the stairs fade) or all frames. Run windowed: --mode ahead_all | ahead_fade | none.

const SK := preload("res://scripts/town/scene_kit.gd")
const GC := preload("res://scripts/town/guild_crew.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")


func _initialize() -> void:
	_run.call_deferred()


func _paths(forms: Array) -> Array:
	var out: Array = []
	for form in forms:
		var dir: String = SK._sprite_dir(String(form))
		out.append(dir + "idle_s.png")
		for f in Arena.FACINGS:
			out.append(dir + f + ".png")
			for k in 8:
				out.append(dir + "walk_%s_f%d.png" % [f, k])
	return out


func _run() -> void:
	var mode := "ahead_fade"
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--mode" and i + 1 < args.size():
			mode = args[i + 1]
	for k in 30:
		await process_frame
	var forms: Array = GC.cast_of("hall_low")
	var paths := _paths(forms).filter(func(p: String) -> bool: return ResourceLoader.exists(p))
	print("CAST %s: %d forms, %d pictures, display %s" % [mode, forms.size(), paths.size(), DisplayServer.get_name()])
	var t0 := Time.get_ticks_msec()
	var last := t0
	var worst := 0
	if mode != "none":
		SK.read_ahead(forms)
		print("  requested in %d ms" % (Time.get_ticks_msec() - t0))
		var frames := 0
		while frames < 600:
			await process_frame
			frames += 1
			var now := Time.get_ticks_msec()
			worst = maxi(worst, now - last)
			last = now
			if mode == "ahead_fade" and frames >= 10:
				break
			var left := paths.filter(func(p: String) -> bool: return ResourceLoader.load_threaded_get_status(p) != ResourceLoader.THREAD_LOAD_LOADED)
			if left.is_empty():
				break
		var left2 := paths.filter(func(p: String) -> bool: return ResourceLoader.load_threaded_get_status(p) != ResourceLoader.THREAD_LOAD_LOADED)
		print("  after %d frames, %d ms: %d of %d still reading, worst frame %d ms" % [frames, Time.get_ticks_msec() - t0, left2.size(), paths.size(), worst])
	var t1 := Time.get_ticks_usec()
	var per: Dictionary = {}
	for form in forms:
		var tf := Time.get_ticks_usec()
		for p: String in _paths([form]):
			SK._sprite(p)
		per[form] = snappedf((Time.get_ticks_usec() - tf) / 1000.0, 0.1)
	print("  taking them on the main thread: %.1f ms, by form %s" % [(Time.get_ticks_usec() - t1) / 1000.0, str(per)])
	var t2 := Time.get_ticks_msec()
	await process_frame
	await process_frame
	print("  next two frames %d ms" % (Time.get_ticks_msec() - t2))
	quit(0)
