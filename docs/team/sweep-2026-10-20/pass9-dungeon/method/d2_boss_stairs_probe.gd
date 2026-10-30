extends SceneTree
## Pass 9 D2 probe (Claude, 2026-10-27, dungeon lane; a method file, not a check). The Hollow's last stairs, B2F to the
## Warden's B3F, staged in a window the way a player meets them (poll_input on, so the build takes the threaded,
## sliced path that only runs with a player at a window). Every frame from the stairs press until the Warden's scene
## has run 6 s is logged: its wall time, the mean luminance of the picture on screen (the viewport read back and
## shrunk to 32x18, as tools/debug/live_play_probe.gd does), whether the floor card is up and how dark the fade is.
## A long frame is judged black when the picture shown during it (the one drawn before it) and the one drawn at its
## end are both black. Then the boss floor's own build steps (dungeon.gd build_steps).
##   Godot --path . --fixed-fps 30 --max-fps 30 --resolution 1152x648 --script res://docs/team/sweep-2026-10-20/pass9-dungeon/method/d2_boss_stairs_probe.gd -- <seed>

const LONG_MS := 100
const BLACK_LUM := 3.0
var rows: Array = []   # [frame, ms, lum, card, fade, floor, cutscene]
var dg: Node2D
var last := 0
var frame := 0


func _initialize() -> void:
	_run.call_deferred()


func _lum() -> float:
	var img := root.get_texture().get_image()
	if img == null or img.is_empty():
		return -1.0
	img.resize(32, 18, Image.INTERPOLATE_NEAREST)
	img.convert(Image.FORMAT_RGB8)
	var d := img.get_data()
	var sum := 0
	for b in d:
		sum += b
	return sum / float(d.size())


func F(n := 1, log_it := false) -> void:
	for k in n:
		await process_frame
		frame += 1
		var now := Time.get_ticks_msec()
		if log_it:
			rows.append([frame, now - last, _lum(), not dg._card_lines.is_empty(), dg._fade.color.a, dg.floor_n, dg.cutscene])
		last = now


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var sd := int(args[0]) if args.size() > 0 else 4242
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = sd
	dg.dungeon = "hollow"
	dg.floor_n = 2
	dg.party = [[0, 1], [1, 0], [10, 0]]
	root.add_child(dg)
	current_scene = dg
	last = Time.get_ticks_msec()
	for k in 30 * 20:
		await F()
		if k > 60 and not dg.busy and dg._card_lines.is_empty() and not dg.ents.is_empty():
			break
	print("D2 seed %d: on B%dF of %s, threads %s, display %s" % [sd, dg.floor_n, dg.dungeon, dg._threads_ok(), DisplayServer.get_name()])
	dg.ents[0]["pos"] = dg.data["stairs"]
	dg._place(dg.ents[0])
	await F(30)
	var t0 := Time.get_ticks_msec()
	dg.act_stairs()
	var scene_from := -1
	for k in 30 * 60:
		await F(1, true)
		if dg.floor_n == 3 and scene_from < 0 and (dg.cutscene or not dg.talk.is_empty()):
			scene_from = frame
		if scene_from > 0 and frame - scene_from > 30 * 6:
			break
	print("D2 stairs to B3F: %d frames, %.1f s wall; boss floor build steps (ms since it began): %s" % [rows.size(), (Time.get_ticks_msec() - t0) / 1000.0, str(dg.build_steps)])
	var worst := 0
	var worst_black := false
	for i in rows.size():
		var r: Array = rows[i]
		if int(r[1]) >= LONG_MS:
			# the picture on screen during frame r is the one read on the row before it (drawn at the end of the last frame)
			var shown: float = rows[i - 1][2] if i > 0 else -1.0
			var black: bool = shown >= 0.0 and shown < BLACK_LUM and float(r[2]) < BLACK_LUM
			print("D2 LONG frame %d: %d ms; picture during it lum %.1f, after it %.1f -> %s; card %s, fade %.2f, floor %d, scene %s" % [
				r[0], r[1], shown, r[2], "black" if black else "LIT", r[3], r[4], r[5], r[6]])
			if int(r[1]) > worst:
				worst = int(r[1])
				worst_black = black
	print("D2 worst frame %d ms, %s; under 1.2 s: %s" % [worst, "black" if worst_black else "LIT", worst < 1200])
	var tsv := FileAccess.open("user://d2_rows_%d.tsv" % sd, FileAccess.WRITE)
	if tsv != null:
		tsv.store_line("frame\tms\tlum\tcard\tfade\tfloor\tscene")
		for r in rows:
			tsv.store_line("\t".join(r.map(func(v: Variant) -> String: return str(v))))
		print("D2 rows in %s" % ProjectSettings.globalize_path("user://d2_rows_%d.tsv" % sd))
	quit(0)
