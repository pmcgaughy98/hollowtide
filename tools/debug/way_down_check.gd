extends SceneTree
## Can a player walk to the way down in Highbank, and does it open at each point of the story? (Claude,
## 2026-10-11; Preston: after the guild trial "I couldn't get to them", the rival crew in Rootbank Warren.)
## Walks the town grid from where the team arrives to the Mouth of the Hollow, then steps on it with the
## story set to each stage.
##   Godot --headless --path . --script res://tools/debug/way_down_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _run() -> void:
	TeamState.start([[0, 0], [1, 0]], {})
	TeamState.data["beaten"] = ["mouth"]
	TeamState.data["story"] = {"parcel": "stolen", "met_crew": true, "guild_trial": true, "road_talk": true}
	TeamState.data["news"] = ""
	var town: Node = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	TeamState.give_to(town)
	root.add_child(town)
	await process_frame
	await process_frame
	var start: Vector2i = town.team[0]["pos"]
	var gate: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "gate")[0]
	var goal: Vector2i = gate["door"]
	# Breadth-first over open tiles, as the player walks (four directions and diagonals).
	var seen := {start: true}
	var q := [start]
	while not q.is_empty():
		var t: Vector2i = q.pop_front()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = t + d
			if not seen.has(n) and town.open_at(n):
				seen[n] = true
				q.append(n)
	_ok("The Mouth of the Hollow (%s) can be walked to from where the team starts (%s); %d tiles reachable" % [goal, start, seen.size()], seen.has(goal))
	if not seen.has(goal):
		var near := goal
		for t in seen:
			if Vector2(t).distance_to(Vector2(goal)) < Vector2(near).distance_to(Vector2(goal)) or near == goal:
				near = t
		print("  nearest reachable tile to the gate: %s; gate tile open: %s" % [near, town.open_at(goal)])
	town.panel = {}
	town.enter_hollow()
	_ok("After the guild trial the way down lets the team go (gated '%s')" % str(town.get_meta("gated", "")), not town.has_meta("gated"))
	var aim: Dictionary = load("res://scripts/town/objective.gd").current(TeamState.data["story"], TeamState.data["beaten"])
	_ok("The objective points at the Warren and the way down ('%s')" % aim["short"], "Rootbank Warren" in String(aim["short"]))
	if DisplayServer.get_name() != "headless":   # windowed: stills of the Next line and the Objective page
		town.remove_meta("gated")
		town.panel = {}
		for k in 30:
			await process_frame
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/design/objective-2026-10-11"))
		root.get_texture().get_image().save_png("res://docs/design/objective-2026-10-11/town_next.png")
		var menu: Node = town.get_node("GamePauseMenu")
		menu.open()
		await process_frame
		menu.show_page("goal")
		for k in 20:
			await process_frame
		root.get_texture().get_image().save_png("res://docs/design/objective-2026-10-11/menu_objective.png")
	print("WAY DOWN: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
