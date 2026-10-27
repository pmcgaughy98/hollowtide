extends SceneTree
## The dawn scene out of the Hollow Mouth (scripts/mouth_escape.gd). Plays every line as a player would and checks
## it hands off to the road up to Highbank with the team intact (since lane S, 2026-10-26, the bank plays the road
## talk's "start" title and road_check judges the road and the arrival in Highbank). With HT_RECORD=1 it reads at a
## watchable pace for --write-movie.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/mouth_escape_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _run() -> void:
	var paced := OS.get_environment("HT_RECORD") == "1"
	TeamState.start([[0, 0], [1, 0]], {})
	TeamState.data["story"] = {"parcel": "saved", "road_talk": true}
	TeamState.data["beaten"] = ["mouth"]
	var scene: Node = load("res://scenes/mouth_escape.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	var lines := 0
	var walked := 0
	for k in 600:
		await process_frame
		if current_scene != scene or scene.leaving:
			break
		if scene.line == null or scene.leaving:
			continue
		if paced:
			# Each page typed out and held long enough to read, then the next page (long lines run to two).
			for page in 4:
				for w in int(50 + mini(scene.line.text.length(), 110) * 1.3):
					await process_frame
				if UI.line_done(scene.line.text):
					break
				UI.finish_line()
		UI.finish_line()
		var before: int = scene._stop
		await scene.advance()
		lines += 1
		walked = maxi(walked, scene._stop)
	for k in 180:   # the fade, then the scene change (current_scene is briefly null in between)
		if current_scene != null and current_scene != scene:
			break
		await process_frame
	var now := current_scene.scene_file_path.get_file() if current_scene != null else "none"
	_ok("Read %d lines on the bank (walked %d stretches)" % [lines, walked], lines >= 8 or OS.get_environment("HT_RECORD") == "1")
	_ok("Hands off to the road up to Highbank (%s), team %s" % [now, str(TeamState.data.get("party", []))],
		now == "road_to_highbank.tscn" and (TeamState.data.get("party", []) as Array).size() >= 2)
	print("MOUTH ESCAPE: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
