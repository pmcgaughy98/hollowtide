extends SceneTree
## Stills of the dungeon VFX pass (Claude, 2026-10-10): a super-effective hit, a plain hit, a Seep
## heal, a level up and a faint, each a few frames after it starts. Windowed only.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/vfx_capture.gd

const OUT := "res://docs/design/dungeon-vfx-2026-10-10/"


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
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
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
	var d := Vector2i.ZERO
	for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0:
			d = dd
			break
	# A Tallowroot (Bloom): Kithflare's Ember claw is super effective.
	var w: Dictionary = dg._make(1, 0, 1, lead["pos"] + d)
	w["max_hp"] = 99
	w["hp"] = 99
	w["awake"] = true
	dg.ents.append(w)
	dg._place(w)
	dg.use_move(0, "claw", d)
	await _frames(9)
	await _snap("super_hit")
	await _frames(40)
	# A plain hit: a Rimefin (Tide/Murk) takes Ember for less.
	w["hp"] = 0
	w["node"].visible = false
	var r: Dictionary = dg._make(2, 0, 1, lead["pos"] + d)
	r["max_hp"] = 99
	r["hp"] = 99
	r["awake"] = true
	dg.ents.append(r)
	dg._place(r)
	lead["cds"]["claw"] = 0
	dg.use_move(0, "claw", d)
	await _frames(9)
	await _snap("weak_hit")
	await _frames(40)
	r["hp"] = 0
	r["node"].visible = false
	# Seep: Troughspine heals the hurt leader beside it.
	var tr: Dictionary = dg.ents[1]
	lead["hp"] = 10
	tr["pos"] = lead["pos"] - d
	dg._place(tr)
	tr["cds"]["seep"] = 0
	dg.use_move(1, "seep", Vector2i(0, 1))
	await _frames(12)
	await _snap("seep")
	await _frames(30)
	# A level up.
	dg._gain_exp(dg.exp_to_next(1))
	await _frames(10)
	await _snap("level_up")
	await _frames(30)
	# A faint.
	var f: Dictionary = dg._make(2, 0, 1, lead["pos"] + d)
	f["awake"] = true
	dg.ents.append(f)
	dg._place(f)
	dg._wound(0, dg.ents.size() - 1, 999, Color.WHITE)
	await _frames(10)
	await _snap("faint")
	print("done")
	quit()
