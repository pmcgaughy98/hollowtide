extends SceneTree
## The first Hollow slice (Claude, 2026-10-09): the floor generator proven on 200 seeds (every
## floor tile, every room and the stairs reachable from the start; at least two rooms; spawns on
## the floor), a sheet of six layouts for the eye, then a floor played on autopilot: the leader
## walks around walls to the wild creatures, they wake when it comes into sight, the partner
## follows, nobody ends up inside a wall, and the stairs lead to B2F.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/hollow_check.gd
## Stills to docs/world/hollow-slice-2026-10-09/.

const OUT := "res://docs/world/hollow-slice-2026-10-09/"
const Gen := preload("res://scripts/hollow/hollow_gen.gd")

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	# 1. The generator on 200 seeds.
	var bad := 0
	var rooms_total := 0
	var links_total := 0
	var min_rooms := 99
	for s in 200:
		var d: Dictionary = Gen.generate(s * 7919 + 13, {"wild": 3})
		var w: int = d["w"]
		var tiles: PackedByteArray = d["tiles"]
		var dist := Gen.distances(tiles, w, d["h"], d["start"])
		var unreachable := 0
		for k in tiles.size():
			if tiles[k] == Gen.FLOOR and dist[k] < 0:
				unreachable += 1
		var stairs_ok: bool = dist[d["stairs"].y * w + d["stairs"].x] > 0
		var spawns_ok := true
		for sp in d["spawns"]:
			if tiles[sp.y * w + sp.x] != Gen.FLOOR:
				spawns_ok = false
		if unreachable > 0 or not stairs_ok or d["rooms"].size() < 2 or not spawns_ok:
			bad += 1
			print("WRONG: seed %d: %d unreachable tiles, stairs %s, %d rooms, spawns %s" % [s, unreachable, str(stairs_ok), d["rooms"].size(), str(spawns_ok)])
		rooms_total += d["rooms"].size()
		links_total += d["links"].size()
		min_rooms = mini(min_rooms, d["rooms"].size())
	print("Generator: 200 seeds, %d bad; rooms %.1f on average (fewest %d), hallway links %.1f on average" % [bad, rooms_total / 200.0, min_rooms, links_total / 200.0])
	# 2. Six layouts on one sheet.
	var sheet := Image.create(3 * 64 * 3, 2 * 40 * 3, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.1, 0.1, 0.12))
	for k in 6:
		var d: Dictionary = Gen.generate(k * 31 + 5, {"wild": 3})
		var ox: int = (k % 3) * 64 * 3 + 6
		var oy: int = (k / 3) * 40 * 3 + 6
		for y in d["h"]:
			for x in d["w"]:
				if d["tiles"][y * d["w"] + x] == Gen.FLOOR:
					sheet.fill_rect(Rect2i(ox + x * 3, oy + y * 3, 3, 3), Color(0.55, 0.7, 0.4))
		sheet.fill_rect(Rect2i(ox + d["start"].x * 3 - 2, oy + d["start"].y * 3 - 2, 7, 7), Color(0.35, 0.75, 1.0))
		sheet.fill_rect(Rect2i(ox + d["stairs"].x * 3 - 2, oy + d["stairs"].y * 3 - 2, 7, 7), Color(1.0, 0.85, 0.3))
		for sp in d["spawns"]:
			sheet.fill_rect(Rect2i(ox + sp.x * 3 - 1, oy + sp.y * 3 - 1, 5, 5), Color(1.0, 0.35, 0.3))
	sheet.save_png(OUT + "layouts.png")
	# 3. A floor on autopilot.
	var hollow: Node2D = load("res://scenes/hollow_floor.tscn").instantiate()
	hollow.floor_seed = 4242
	hollow.party = [[0, 1], [1, 1]]   # Sparkwick leading, Huskward following
	hollow.poll_input = false
	hollow.auto_you = true
	root.add_child(hollow)
	await _frames(3)
	var names := []
	for f in hollow._fighters:
		names.append("%s:%s%s" % ["you" if f["team"] == 0 else "wild", f["name"], "" if f["team"] == 0 else ("(awake)" if f.get("awake", true) else "(asleep)")])
	print("B1F: %s; map %dx%d tiles; the leader starts %d tiles from the stairs" % [str(names), hollow._data["w"], hollow._data["h"], Gen.distances(hollow._data["tiles"], hollow._data["w"], hollow._data["h"], hollow._data["start"])[hollow._data["stairs"].y * hollow._data["w"] + hollow._data["stairs"].x]])
	await _frames(20)
	_save("b1f_start")
	var in_wall := 0
	var woke := 0
	var awake_seen := {}
	var partner_far := 0
	var frames := 0
	var shot_fight := false
	var downed := 0
	while hollow.floor_n == 1 and hollow._winner < 0 and frames < 30 * 150:
		await process_frame
		frames += 1
		for j in hollow._fighters.size():
			var f: Dictionary = hollow._fighters[j]
			if f["hp"] > 0 and hollow._wall_px(f["body"].position):
				in_wall += 1
			if f["team"] == 1 and f.get("awake", true) and not awake_seen.has(j):
				awake_seen[j] = true
				woke += 1
				if not shot_fight:
					shot_fight = true
					await _frames(25)
					_save("b1f_fight")
		if hollow.floor_n == 1:
			var down_now := 0
			for f in hollow._fighters:
				if f["team"] == 1 and f["hp"] <= 0:
					down_now += 1
			downed = maxi(downed, down_now)
		var lead: Dictionary = hollow._fighters[hollow.controlled]
		for f in hollow._fighters:
			if f["team"] == 0 and f != lead and f["hp"] > 0 and f["body"].position.distance_to(lead["body"].position) > 160.0:
				partner_far += 1
	print("Autopilot on B1F: %s after %.0f s; %d wild creatures woke, %d were downed; frames with a creature inside a wall: %d; frames with the partner more than 160 px behind: %d" % ["reached B%dF" % hollow.floor_n if hollow.floor_n > 1 else ("fainted" if hollow._winner == 1 else "still on B1F (WRONG)"), frames / 30.0, woke, downed, in_wall, partner_far])
	await _frames(20)
	_save("b2f_start")
	var team_hp := []
	for f in hollow._fighters:
		if f["team"] == 0:
			team_hp.append("%s %d/%d" % [f["name"], f["hp"], f["max_hp"]])
	print("B2F: the team carried its health down: %s; a fresh floor with %d wild creatures asleep" % [str(team_hp), hollow._fighters.filter(func(f: Dictionary) -> bool: return f["team"] == 1 and not f.get("awake", true)).size()])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
