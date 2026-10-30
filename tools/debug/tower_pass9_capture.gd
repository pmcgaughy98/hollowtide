extends SceneTree
## Pass 9, tower lane: windowed stills for the result (Claude). Not a check (the runner only runs *_check.gd).
##   Godot --fixed-fps 30 --resolution 1152x648 --path <repo> --script res://tools/debug/tower_pass9_capture.gd -- <mode> [<prefix>]
## Run it with its own APPDATA, as the checks are run, so no save of Preston's is read or written.
## mode reveal: the two settled at the doors (W1), the hold at the top (W4, the lamp and its glow), the pan down half
##   way (W2: no box). mode road: the first line of each trail talk (W3: the far Tower beside the willows).
## mode title: the title with Highbank and the Tower (W5's crook at title size).

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const Reveal := preload("res://scripts/story/tower_reveal.gd")
const OUT := "res://docs/team/sweep-2026-10-20/pass9-tower/"

var town: Node2D
var prefix := ""


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	img.save_png(ProjectSettings.globalize_path(OUT + prefix + name + ".png"))
	print("saved ", prefix + name, " ", img.get_size())


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var mode: String = args[0] if args.size() > 0 else "reveal"
	prefix = args[1] if args.size() > 1 else ""
	print("mode ", mode, " v2 ", Layout.v2(), " window ", root.size)
	match mode:
		"reveal":
			await _reveal()
		"road":
			await _road()
		"title":
			await _title()
	quit()


func _reveal() -> void:
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "stolen", "guild_trial": true}
	town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	town.force_scenes = true
	root.add_child(town)
	current_scene = town
	for k in 300:
		if not town.team.is_empty():
			break
		await process_frame
	await _frames(6)
	town.enter_area(Reveal.AREA)
	await _frames(30)
	Reveal.reduce_override = 0
	Reveal.run(town)
	var got := {}
	var start_top := 0.0
	var hold_top := 0.0
	var k := 0
	while Reveal.playing and k < 30 * 120:
		await process_frame
		k += 1
		var top: float = -town._world.position.y
		var boxed: bool = not town.talk.is_empty()
		if Reveal.stage == "start" and not got.has("settle") and boxed:
			got["settle"] = true
			start_top = top
			await _frames(8)
			print("settle: stage ", Reveal.stage, " top ", -town._world.position.y, " box ", not town.talk.is_empty())
			await _snap("01_reveal_settle")
		if Reveal.stage in ["hold", "top"] and not got.has("hold") and boxed:
			got["hold"] = true
			hold_top = top
			print("hold: stage ", Reveal.stage, " top ", top)
			await _snap("03_reveal_hold_lamp")
		if Reveal.stage == "down" and not got.has("down") and got.has("hold") and top > (hold_top + start_top) * 0.5:
			got["down"] = true
			print("down: stage ", Reveal.stage, " top ", top, " box ", not town.talk.is_empty())
			await _snap("02_reveal_mid_pan_down")
		if boxed and k % 24 == 0:
			UI.finish_line()
			town.talk.pop_front()
	print("reveal done after ", k, " frames, got ", got.keys())


func _road() -> void:
	TeamState.start([[0, 0], [1, 0]], {})
	TeamState.data["story"] = {"parcel": "saved", "road_talk": true}
	TeamState.data["beaten"] = ["mouth"]
	TeamState.data["news"] = "cleared"
	load("res://scripts/town/hub_town.gd")
	var scene: Node = load("res://scenes/road_to_highbank.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for k in 150:
		if scene.started:
			break
		await process_frame
	scene.autopilot = true
	var done := {}
	var n := 0
	for k in 30 * 150:
		await process_frame
		if not is_instance_valid(scene) or current_scene != scene or scene.in_vista:
			break
		var b := String(scene.beat_now)
		if b in ["bluff", "tower", "parcel", "crew"] and not done.has(b) and scene.line != null:
			done[b] = true
			n += 1
			await _snap("%02d_road_%s" % [3 + n, b])
		if done.size() == 4:
			break
	print("road done: ", done.keys())
	scene.autopilot = false
	scene.queue_free()   # free the road before quitting; quitting with it mid-line crashed on exit (0xC0000005)
	await _frames(3)


func _title() -> void:
	var menu: Node = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(menu)
	current_scene = menu
	await _frames(300)
	await _snap("08_title")
