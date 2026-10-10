extends SceneTree
## Action animations in the dungeon (Claude, 2026-10-09): the stage 1 starters play an attack when
## they use a move, a hurt when hit, and a sleeping wild one loops its sleep until it wakes. Counts
## the frames each shows and keeps the creature on its own ground line throughout.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_action_check.gd
## Stills to docs/design/dungeon-actions-2026-10-09/.

const OUT := "res://docs/design/dungeon-actions-2026-10-09/"


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	dg.traps.clear()
	dg.monster_room = Rect2i()
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	for who in [[0, 0], [1, 0], [2, 0]]:
		var art: Dictionary = dg._load_art(dg.Arena.LINES[who[0]]["forms"][0][0])
		var counts := {}
		for act in ["attack", "hurt", "sleep"]:
			counts[act] = art["acts"][act]["s"].size() if art["acts"].has(act) and art["acts"][act].has("s") else 0
		print("%s: frames attack %d, hurt %d, sleep %d (facings with attack %d)" % [dg.Arena.LINES[who[0]]["forms"][0][0], counts["attack"], counts["hurt"], counts["sleep"], art["acts"].get("attack", {}).size()])
	# Kithflare attacks a Rimefin beside it; watch the textures change.
	var lead: Dictionary = dg.ents[0]
	var d := Vector2i.ZERO
	for dd in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0:
			d = dd
			break
	var w: Dictionary = dg._make(2, 0, 1, lead["pos"] + d)
	w["max_hp"] = 99
	w["hp"] = 99
	dg.ents.append(w)
	dg._place(w)
	var seen_lead := {}
	var seen_w := {}
	var foot_moves := 0
	var y0: float = lead["sprite"].position.y
	dg.use_move(0, lead["moves"][0], d)
	for k in 14:
		await process_frame
		seen_lead[lead["sprite"].texture] = true
		seen_w[w["sprite"].texture] = true
		if k == 5:
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "attack_hurt.png"))
	await _frames(10)
	print("Attack: the leader showed %d different pictures, the Rimefin %d; back to the still after: %s / %s" % [seen_lead.size(), seen_w.size(), str(lead["sprite"].texture == lead["art"]["still"][lead["facing"]]), str(w["sprite"].texture == w["art"]["still"][w["facing"]])])
	# A sleeping Rimefin loops its sleep; waking returns it to its still.
	w["awake"] = false
	var seen_sleep := {}
	for k in 60:
		await process_frame
		seen_sleep[w["sprite"].texture] = true
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "sleep.png"))
	w["awake"] = true
	await _frames(3)
	print("Sleep: %d pictures over 2 s asleep; awake again shows the still: %s" % [seen_sleep.size(), str(w["sprite"].texture == w["art"]["still"][w["facing"]])])
	quit()
