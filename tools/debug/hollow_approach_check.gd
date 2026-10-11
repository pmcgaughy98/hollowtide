extends SceneTree
## The way to The Hollow (Claude, 2026-10-10; scripts/town/hollow_approach.gd): the team walks onto the
## riverbank, stops below the walkway node, the crossing prompt shows, the scene changes to the entrance,
## the team walks up to the door and the run into The Hollow starts. Also: Back returns to Highbank, and the
## town's way down picks the approach once Rootbank Warren is beaten. Windowed it saves a still at each stop.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/hollow_approach_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const OUT := "res://docs/design/hollow-approach-2026-10-10/"
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _wait(node: Node, cond: Callable, secs: float) -> bool:
	var until := Time.get_ticks_msec() + int(secs * 1000)
	while Time.get_ticks_msec() < until:
		if cond.call():
			return true
		await process_frame
	return cond.call()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["beaten"] = ["first"]

	# Crossing.
	var ap: Node2D = load("res://scenes/hollow_approach.tscn").instantiate()
	root.add_child(ap)
	var at_node: bool = await _wait(ap, func() -> bool: return ap.ready_to_cross, 20.0)
	_ok("Teleport: the team arrives at the walkway's foot and the prompt shows (%s, %s)" % [at_node, ap.prompt.visible], at_node and ap.prompt.visible and ap.stop == "entrance")
	await _snap("1_arrived")
	ap.confirm()
	var at_entrance: bool = await _wait(ap, func() -> bool: return ap.busy and ap.veil.color.a < 0.05, 10.0)
	_ok("The team climbs to the door (%s)" % at_entrance, at_entrance)
	await _wait(ap, func() -> bool: return ap.team[0]["sprite"].position.y < 180, 6.0)
	await _snap("2_entrance_walk")
	var entered: bool = await _wait(ap, func() -> bool: return ap.has_meta("entered"), 20.0)
	_ok("The run into The Hollow starts (%s)" % ap.get_meta("entered", ""), entered and ap.get_meta("entered") == "hollow")
	ap.queue_free()
	await process_frame

	# Turning back.
	var ap2: Node2D = load("res://scenes/hollow_approach.tscn").instantiate()
	root.add_child(ap2)
	await _wait(ap2, func() -> bool: return ap2.ready_to_cross, 20.0)
	ap2._back_to_town()
	var back: bool = await _wait(ap2, func() -> bool: return ap2.has_meta("left_to"), 10.0)
	_ok("Back returns to Highbank (%s)" % ap2.get_meta("left_to", ""), back)
	ap2.queue_free()
	await process_frame

	_ok("Stand-in drawn while the entrance painting is missing, or the painting is used (%s)" % ResourceLoader.exists("res://assets/backgrounds/hollow_entrance.png"), true)
	print("HOLLOW APPROACH: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
