extends SceneTree
## Stills of every screen a player passes through, for UI review (Claude, 2026-10-10; Preston:
## "UI upgrades and visuals... from main menu to town to battle, everything"). Windowed only:
## a headless run has no viewport picture.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/ui_tour_capture.gd
## Writes docs/ui/ui-tour-2026-10-10/<n>_<screen>.png.

const OUT := "res://docs/ui/ui-tour-2026-10-10/"


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("saved ", name)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	# The title (the wordmark prelude played out).
	var title: Node = load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(title)
	await _frames(240)
	await _snap("01_title")
	title.queue_free()
	await _frames(4)
	# Town.
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(30)
	await _snap("02_town")
	var place: Dictionary = {}
	for p in town.Layout.PLACES:
		if p["id"] == "hall":
			place = p
	town.team[0]["pos"] = place["door"]
	town.act_use()
	await _frames(20)
	await _snap("03_town_panel")
	town.queue_free()
	await _frames(4)
	# The dungeon: arriving, a fight, the pause menu, the bag and a level move question.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0], [10, 0]]
	root.add_child(dg)
	await _frames(60)
	await _snap("04_dungeon")
	var lead: Dictionary = dg.ents[0]
	var d := Vector2i.ZERO
	for dd in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0:
			d = dd
			break
	var w: Dictionary = dg._make(2, 0, 1, lead["pos"] + d)
	w["max_hp"] = 60
	w["hp"] = 60
	dg.ents.append(w)
	dg._place(w)
	lead["facing"] = dg._facing_of(d)
	dg.use_move(0, lead["moves"][0], d)
	await _frames(8)
	await _snap("05_fight_hit")
	await _frames(40)
	dg.bag["lamp_oil"] = 1
	dg.bag["scroll:pounce"] = 1
	dg.bag_open = true
	await _frames(6)
	await _snap("06_bag")
	dg.bag_open = false
	dg.levels[0] = {"lv": 3, "exp": 0}
	lead["moves"].assign(["claw", "ember_feint", "fireball", "cinder_claw"])
	dg._offer(0, "pounce")
	await _frames(6)
	await _snap("07_learn_question")
	dg.act_teach(0, -2)
	var menu: CanvasLayer = dg.get_node("GamePauseMenu")
	menu.open()
	await _frames(6)
	await _snap("08_pause")
	menu.show_page("team")
	await _frames(6)
	await _snap("09_pause_team")
	menu.resume()
	await _frames(20)
	print("done")
	quit()
