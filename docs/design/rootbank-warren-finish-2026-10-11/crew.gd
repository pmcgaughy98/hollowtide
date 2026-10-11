extends SceneTree
## The Shortcut Crew's scene played through (Claude, 2026-10-10): the entrance over the parcel, the
## fight started, then Mirekit knocked out by the leader for the flop, the getaway and the parcel.
## Each line is read after a beat; a still is saved at every beat. It passes when the crew has run,
## the parcel is in hand and the dungeon is marked beaten.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/crew_scene_capture.gd
## With --write-movie docs/design/rival-crew-2026-10-10/crew_scene/raw.avi it also records the scene.

const OUT := "D:/dev/hollowtide-rootbank-finish-20261011/crew/"
var dg: Node2D
var shot := {}


func _initialize() -> void:
	_run.call_deferred()


func _snap(name: String) -> void:
	if shot.has(name):
		return
	shot[name] = true
	if DisplayServer.get_name() == "headless":
		print("beat ", name)
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("still ", name)


## Read the lines on screen, a beat each, saving the first time each speaker talks in this part.
func _read(part: String) -> void:
	var wait := 0
	var frames := 0
	var n := 0
	while frames < 30 * 40:
		await process_frame
		frames += 1
		if dg.talk.is_empty():
			if dg.boss_met and part == "in":
				return
			if part == "out" and not dg.cutscene:
				return
			continue
		await _snap("%s_%02d_%s" % [part, n, String(dg.talk[0][0]).to_lower()])
		wait += 1
		if wait >= 45:
			wait = 0
			n += 1
			dg.act_talk()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1152,648)
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	dg.return_to_town = false
	dg.dungeon = "first"
	dg.party = [[0, 0], [1, 0], [10, 0]]
	root.add_child(dg)
	for k in 10:
		await process_frame
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	for k in 20:
		await process_frame
	await _snap("00_arguing")
	await _read("in")
	for k in 20:
		await process_frame
	await _snap("01_fight")
	var fought: bool = dg.boss_met and not dg.cutscene
	# Knock Mirekit out from the leader: it should flop, not fade.
	var b: Dictionary = dg.ents[dg.boss]
	b["hp"] = 1
	dg._wound(0, dg.boss, 5, Color.WHITE)
	for k in 50:
		await process_frame
	await _snap("02_flop")
	var flopped: bool = b["sprite"].flip_v and b["node"].modulate.a > 0.9
	await _read("out")
	var parcel_in_hand: bool = not dg.intro.has("parcel")
	for k in 120:   # the banner's hold and the fade before the dungeon counts as beaten
		await process_frame
	var ok_all: bool = fought and flopped and parcel_in_hand and "first" in dg.beaten
	print("fight started: %s, flopped on screen: %s, parcel taken: %s, beaten: %s" % [fought, flopped, parcel_in_hand, "first" in dg.beaten])
	print("CREW SCENE: %s" % ("ok" if ok_all else "FAILED"))
	var music := root.get_node_or_null("HollowtideMusic")
	if music != null: music.queue_free()
	dg.queue_free()
	for k in 4: await process_frame
	quit(0 if ok_all else 1)
