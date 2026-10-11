extends SceneTree
## The hub town blockout (Claude, 2026-10-09): the layout holds together (no place overlaps another,
## every door is on open ground and reachable from Home, the switchbacks connect the bluff to the
## ferry), the team walks and follows, every place answers E, and the Mouth of the Hollow starts a run.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/hub_town_check.gd
## Stills to docs/world/hub-layout-2026-10-09/.

const Layout := preload("res://scripts/town/town_layout.gd")
var OUT := "D:/dev/hollowtide-new-scene-selout-20261010/review/hub/"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):OUT="D:/dev/hollowtide-new-scene-selout-20261010/review/live-hub/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var g: PackedByteArray = Layout.grid()
	# Overlaps.
	var overlaps: Array = []
	for a in Layout.PLACES.size():
		for b in range(a + 1, Layout.PLACES.size()):
			if Layout.PLACES[a]["kind"] == "building" and Layout.PLACES[b]["kind"] == "building" and Layout.PLACES[a]["rect"].intersects(Layout.PLACES[b]["rect"]):
				overlaps.append([Layout.PLACES[a]["id"], Layout.PLACES[b]["id"]])
	# Reachable from the spawn.
	var seen := {Layout.SPAWN: true}
	var q: Array = [Layout.SPAWN]
	while not q.is_empty():
		var c: Vector2i = q.pop_front()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if n.x >= 0 and n.y >= 0 and n.x < Layout.W and n.y < Layout.H and g[n.y * Layout.W + n.x] == Layout.OPEN and not seen.has(n):
				seen[n] = true
				q.append(n)
	var unreached: Array = []
	for p in Layout.PLACES:
		if not seen.has(p["door"]):
			unreached.append(p["id"])
	print("Layout: %d places, building overlaps %s, doors not reachable from Home %s, the ferry reachable %s" % [Layout.PLACES.size(), str(overlaps), str(unreached), str(seen.has(Vector2i(28, 27)))])
	Layout.new()
	var img: Image = load("res://scripts/town/hub_town.gd").paint()
	img.save_png(ProjectSettings.globalize_path(OUT + "layout_full.png"))
	# Walk it.
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	for k in 4:
		await process_frame
	var start: Vector2i = town.team[0]["pos"]
	for k in 4:
		await town.act_move(Vector2i(1, 0))
	print("Walk: the leader went %s -> %s; the partner follows at %s (%d apart)" % [str(start), str(town.team[0]["pos"]), str(town.team[1]["pos"]), int(town.team[0]["pos"].distance_to(town.team[1]["pos"]))])
	# Every place answers.
	var answered := 0
	for p in Layout.PLACES:
		if p["service"] == "dungeon":
			continue
		town.panel = {}
		town.team[0]["pos"] = p["door"]
		town._place(town.team[0])
		var got: Dictionary = town.act_use()
		if got.get("id", "") == p["id"]:
			answered += 1
	town.panel = {}
	town.team[0]["pos"] = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "hall")[0]["door"] + Vector2i(0, 1)
	town._place(town.team[0])
	town.team[0]["facing"] = "n"
	town.act_use()
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "hall_panel.png"))
	print("Places: %d of %d answered E from their door" % [answered, Layout.PLACES.size() - 1])
	town.panel = {}
	town.team[0]["pos"] = Vector2i(32, 28)
	town._place(town.team[0])
	await town.act_move(Vector2i(1, 0))
	print("The Mouth of the Hollow: stepping on it started a run %s" % str(town.has_meta("entered")))
	await create_timer(2.0).timeout
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	for k in 12:await process_frame
	quit()
