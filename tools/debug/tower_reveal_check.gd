extends SceneTree
## The Wayline Tower scene (Claude, 2026-10-26, placeholder factory lane S; scripts/story/tower_reveal.gd). In Highbank:
## with the v2 switch off it never starts by itself. Run, it plays once: the two walk to the Tower's doors, the camera
## pans up the Tower to the beacon and back down to them while every line is read, control comes back (no scene, no
## camera override, the sky behind the Tower gone, the town's camera on the leader) and tower_seen is set. With
## tower_seen set it does not play again. Under Reduce motion the camera cuts to the top and back instead of panning.
## With HT_HIGHBANK_V2=1 and lane A's Tower Rise in, it also checks the scene is due there before the flag.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/tower_reveal_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const Reveal := preload("res://scripts/story/tower_reveal.gd")
const STORY := {"met_crew": true, "parcel": "stolen", "guild_trial": true}   # past the board scene: no crew at the board
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _until(done: Callable, budget: int) -> bool:
	for k in budget:
		if done.call():
			return true
		await process_frame
	return done.call()


## Play the scene to its end, reading each line after a few frames as a player would, and follow the camera.
## Returns {frames, read, top (the highest look), up (frames from the doors to the top), between (frames neither at
## the doors nor at the top), end (the last look), started (the scene and the flag on in its first frame)}.
func _play(town: Node, geo: Dictionary) -> Dictionary:
	var half_y: float = town.VIEW.y * 0.5
	var door_y: float = geo["door_look"].y
	var top_y: float = geo["top_look"].y
	var out := {"frames": 0, "read": 0, "top": INF, "up": -1, "between": 0, "end": Vector2.ZERO, "started": false}
	var left_doors := -1
	Reveal.run(town)
	out["started"] = town.cutscene and Reveal.seen(town) and Reveal.playing
	for k in 30 * 90:
		await process_frame
		out["frames"] = k + 1
		var look_y: float = half_y - town._world.position.y
		out["top"] = minf(out["top"], look_y)
		if look_y < door_y - 8.0 and left_doors < 0:
			left_doors = k
		if look_y <= top_y + 4.0 and int(out["up"]) < 0 and left_doors >= 0:
			out["up"] = k - left_doors
		if look_y < door_y - 8.0 and look_y > top_y + 8.0:
			out["between"] = int(out["between"]) + 1
		if not town.talk.is_empty() and k % 6 == 0:
			UI.finish_line()
			town.talk.pop_front()
			out["read"] = int(out["read"]) + 1
		if not Reveal.playing:
			break
		if k % 150 == 0:
			out["stages"] = String(out.get("stages", "")) + " %d:%s/%d" % [k, Reveal.stage, town.talk.size()]
	await _frames(2)
	out["end"] = Vector2(town.VIEW) * 0.5 - town._world.position
	return out


func _run() -> void:
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = STORY.duplicate()
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	town.force_scenes = true
	root.add_child(town)
	current_scene = town
	await _until(func() -> bool: return not town.team.is_empty(), 300)
	await _frames(4)
	# 1. Never by itself with the switch off; with it on, due on Tower Rise.
	if not Layout.v2():
		_ok("Highbank v2 off: the scene is never due (pending %s)" % Reveal.pending(town), not Reveal.pending(town))
	elif not Layout.area(Reveal.AREA).is_empty():
		town.enter_area(Reveal.AREA)
		await _frames(30)
		_ok("Highbank v2 on, on Tower Rise (%s): the scene is due before tower_seen" % Layout.area_id(), Reveal.pending(town))
	else:
		print("Highbank v2 is on but Tower Rise is not in yet; the scene is run directly")
	# 2. Run it.
	var geo := Reveal.geometry(town)
	Reveal.reduce_override = 0
	var got := await _play(town, geo)
	print("Tower %s, foot %s, beacon %s; looks: doors %s, top %s" % [str(geo["canvas"]), str(geo["foot"]), str(geo["beacon"]), str(geo["door_look"]), str(geo["top_look"])])
	_ok("It starts at once: a scene, tower_seen set (%s)" % got["started"], got["started"])
	_ok("The camera pans up to the beacon: highest look %.0f, the top look %.0f, %d frames from the doors" % [got["top"], geo["top_look"].y, got["up"]],
		float(got["top"]) <= geo["top_look"].y + 4.0 and int(got["up"]) >= 90)
	var home: Vector2 = Reveal.town_look(town)
	_ok("And back down to the two: the last look %s, the town's own %s" % [str(got["end"]), str(home)], got["end"].distance_to(home) <= 2.0)
	_ok("Every line read (%d) in %d frames (stages%s)" % [got["read"], got["frames"], String(got.get("stages", ""))], int(got["read"]) >= 11)
	var stand: Array = geo["stand"]
	_ok("The two stand at the Tower's doors (%s, %s), facing it (%s)" % [str(town.team[0]["pos"]), str(town.team[1]["pos"]), town.team[0]["facing"]],
		town.team[0]["pos"] == stand[0] and town.team[1]["pos"] == stand[1] and String(town.team[0]["facing"]).begins_with("n"))
	var leftover: Array = []
	for n in ["TowerCam", "TowerSky", "TowerBeacon"]:
		if town.find_child(n, true, false) != null:
			leftover.append(n)
	_ok("Control comes back: scene %s, playing %s, cam_focus %s, left over %s" % [town.cutscene, Reveal.playing, str(town.cam_focus), str(leftover)],
		not town.cutscene and not Reveal.playing and town.cam_focus == null and leftover.is_empty())
	# 3. Plays once.
	_ok("tower_seen is set and the scene is not due again (pending %s)" % Reveal.pending(town), Reveal.seen(town) and not Reveal.pending(town))
	var look_before: Vector2 = town._world.position
	Reveal.run(town)
	await _frames(20)
	_ok("Run again with tower_seen set: nothing plays (scene %s, camera moved %s)" % [town.cutscene, look_before != town._world.position],
		not town.cutscene and not Reveal.playing and town.find_child("TowerCam", true, false) == null)
	# 4. Reduce motion: cuts, no pan.
	TeamState.data["story"].erase(Reveal.FLAG)
	Reveal.reduce_override = 1
	var cut := await _play(town, geo)
	_ok("Reduce motion cuts to the top (%.0f) and back, no frame between (%d)" % [cut["top"], cut["between"]],
		float(cut["top"]) <= geo["top_look"].y + 4.0 and int(cut["between"]) == 0 and not town.cutscene)
	Reveal.reduce_override = -1
	print("TOWER REVEAL: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
