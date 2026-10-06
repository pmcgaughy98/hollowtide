extends SceneTree
## Headless-free battle capture (needs a window for screenshots). Usage:
##   Summer.exe --path . --script res://tools/debug/battle_capture.gd -- <player> <foe> <player|foe> <move_index> <ms,ms,...> <name>
## A move index of -1 saves only the idle shot.
## e.g. -- 108_vitrecrag 002_cinderhide player 0 5500,8300,12500 mg
## Starts a battle, has one side use one move, and saves a screenshot at each
## millisecond mark to user://battle_captures/<name>_<ms>.png, printing state.
## Run one battle per process: the party persists between battles in one run.
var OUT := ProjectSettings.globalize_path("user://battle_captures/")
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	_run()
func _snap(n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + n + ".png")
func _run() -> void:
	var a := OS.get_cmdline_user_args()
	var p: CreatureData = load("res://data/creatures/" + a[0] + ".tres")
	var f: CreatureData = load("res://data/creatures/" + a[1] + ".tres")
	var who: String = a[2]          # "player" or "foe" uses the move
	var move_i: int = int(a[3])
	var shots: Array = Array(a[4].split(",")).map(func(x): return int(x))
	var holder := Node2D.new(); root.add_child(holder)
	var b: CanvasLayer = load("res://scripts/battle_screen.gd").new()
	b.player_creature = p
	holder.add_child(b)
	await process_frame
	b.start(f)
	await create_timer(1.5, true).timeout
	await _snap(a[5] + "_0idle")
	if move_i < 0:  # idle only, for creatures with no moves yet
		quit()
		return
	var user: CreatureData = p if who == "player" else f
	var mv: MoveData = user.moves[move_i]
	print("move ", mv.move_name, " frames ", mv.attack_frames.size())
	var t0 := Time.get_ticks_msec()
	b._attack(user, who == "player", mv)
	while Time.get_ticks_msec() - t0 < shots.back() + 300:
		await process_frame
		var t := Time.get_ticks_msec() - t0
		if not shots.is_empty() and t >= shots[0]:
			var n: int = shots.pop_front()
			await _snap("%s_%05d" % [a[5], n])
			print(n, " rev=", b._reversed, " far=", b._foe_sprite.texture.resource_path.get_file(), " near=", b._player_sprite.texture.resource_path.get_file(), " hp f/p=", b._foe_hp, "/", b._player_hp)
			if shots.is_empty(): break
	quit()
