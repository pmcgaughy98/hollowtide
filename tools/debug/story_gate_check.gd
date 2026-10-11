extends SceneTree
## The pilot's order at Highbank's way down (Claude, 2026-10-11): Rootbank Warren waits until the guild sends the
## team after the stolen parcel, and The Hollow waits until Starward has the parcel back
## (hub_town.story_gate). An older record with no parcel story is never held back.
##   Godot --headless --path . --script res://tools/debug/story_gate_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


## Open the town with this story and these beaten dungeons, press the way down, report what happened.
func _try(story: Dictionary, beaten: Array) -> String:
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = story.duplicate(true)
	TeamState.data["beaten"] = beaten.duplicate()
	var t: Node = load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(t)
	t.poll_input = false
	root.add_child(t)
	for k in 4:
		await process_frame
	t.enter_hollow()
	var result := "entered" if t.has_meta("entered") else ("held: " + String(t.get_meta("gated", "")) if t.has_meta("gated") else "nothing")
	t.queue_free()
	for k in 2:
		await process_frame
	return result


func _run() -> void:
	var r := await _try({"parcel": "saved"}, ["mouth"])
	_ok("Parcel still saved (before the Job Board): held (%s)" % r, r.begins_with("held"))
	r = await _try({"parcel": "stolen", "met_crew": true}, ["mouth"])
	_ok("Stolen, guild not told yet: held (%s)" % r, r.begins_with("held"))
	r = await _try({"parcel": "stolen", "met_crew": true, "guild_trial": true}, ["mouth"])
	_ok("Stolen and the guild has sent them: Rootbank Warren opens (%s)" % r, r == "entered")
	r = await _try({"parcel": "recovered", "met_crew": true, "guild_trial": true}, ["mouth", "first"])
	_ok("Parcel back but not yet shown to Starward: The Hollow is held (%s)" % r, r.begins_with("held"))
	r = await _try({"parcel": "delivered", "runner": true, "guild_trial": true}, ["mouth", "first"])
	_ok("Runners: The Hollow opens (%s)" % r, r == "entered")
	r = await _try({}, [])
	_ok("An old record with no parcel story is not held (%s)" % r, r == "entered")
	print("STORY GATE: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
