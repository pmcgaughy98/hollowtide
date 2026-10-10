extends SceneTree
## Stills of the rival crew and the Hollow (Claude, 2026-10-10): Rot Spit, Drain Bite, Buzz Dart and a
## Blighted leader; the crew's boss floor with its talk; the Hollow's stone floor. Windowed only.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/crew_capture.gd

const OUT := "D:/dev/hollowtide-crew-dungeon-selout-20261010/review/before/"


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("still ", name)


func _beside(dg: Node2D, e: Dictionary, lead: Dictionary, dist: int) -> Vector2i:
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var ok := true
		for k in range(1, dist + 1):
			if not dg._floor_at(lead["pos"] + d * k) or dg._occupant(lead["pos"] + d * k) >= 0:
				ok = false
		if ok:
			e["pos"] = lead["pos"] + d * dist
			dg._place(e)
			e["awake"] = true
			return -d
	return Vector2i.ZERO


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon = "first"
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [10, 0]]
	root.add_child(dg)
	await _frames(30)
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	var lead: Dictionary = dg.ents[0]
	# Rot Spit from three tiles.
	var mk: Dictionary = dg._make(100, 0, 1, lead["pos"])
	dg.ents.append(mk)
	var d := _beside(dg, mk, lead, 3)
	mk["facing"] = dg._facing_of(d)
	dg.use_move(dg.ents.size() - 1, "rot_spit", d)
	await _frames(7)
	await _snap("rot_spit")
	await _frames(30)
	await _snap("blighted")
	mk["hp"] = 0
	mk["node"].visible = false
	# Drain Bite from beside.
	var wn: Dictionary = dg._make(101, 0, 1, lead["pos"])
	dg.ents.append(wn)
	wn["hp"] = wn["max_hp"] - 8
	d = _beside(dg, wn, lead, 1)
	wn["facing"] = dg._facing_of(d)
	dg.use_move(dg.ents.size() - 1, "drain_bite", d)
	await _frames(9)
	await _snap("drain_bite")
	await _frames(30)
	# Buzz Dart from three tiles.
	d = _beside(dg, wn, lead, 3)
	wn["facing"] = dg._facing_of(d)
	wn["cds"]["buzz_dart"] = 0
	dg.use_move(dg.ents.size() - 1, "buzz_dart", d)
	await _frames(6)
	await _snap("buzz_dart")
	await _frames(30)
	# The crew's boss floor and its talk.
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	await _frames(40)
	await _snap("crew_boss")
	dg.queue_free()
	await _frames(2)
	# The Hollow's stone floor.
	var hg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	hg.dungeon = "hollow"
	hg.floor_seed = 77
	hg.poll_input = false
	hg.party = [[0, 0], [1, 0], [10, 0]]
	root.add_child(hg)
	await _frames(10)
	hg.floor_n = 2
	hg._build_floor(true)
	await _frames(40)
	await _snap("hollow_stone")
	hg.floor_n = 1
	hg._build_floor(true)
	await _frames(40)
	await _snap("hollow_valley")
	quit()

