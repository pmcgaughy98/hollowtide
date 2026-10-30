extends SceneTree
## A stick tap counts once, and a second tap the same way counts again (Claude, 2026-10-27, factory pass 9 R4 / H9-35).
## UI.pressed (ui_style.gd) turns the left stick's stream of motion into one press per push (_motion_edge): a push counts
## when the stick crosses TAP_DEAD from inside it. That needs the stick's return to the centre to be seen. The centre
## event is not a press of any action, so a screen that reads the stick only through UI.pressed never passed it on, and
## the next push the same way was taken for the old one still held. Codex's three screens fed every motion event to
## _motion_edge by hand (opening_flow.gd, soul_prologue.gd, storm_open.gd); the Team page and the riverbank did not.
## This sends real joypad motion (Input.parse_input_event, device 0) to three listeners: one reading ui_down and
## move_down through UI.pressed on every event, one shaped like the Team page (party_screen.gd _input: it drops events
## that are not presses before it asks UI.pressed), and one counting what the stick did. Each pattern is a push, the
## stick straight back to the centre, and a push again; a push let back slowly through the dead zone; down then up;
## a held push that sends more motion while held. No save, no scene.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/stick_edge_check.gd

const UI := preload("res://scripts/ui/ui_style.gd")
var fails := 0


class Listener extends Node:
	var guard := false        # the Team page's shape: only events that are presses reach UI.pressed
	var counts := {}

	func _input(event: InputEvent) -> void:
		if guard and not event.is_pressed():
			return
		for a: StringName in [&"ui_down", &"ui_up", &"move_down"]:
			if UI.pressed(event, a):
				counts[a] = int(counts.get(a, 0)) + 1


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _axis(v: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.device = 0
	ev.axis = JOY_AXIS_LEFT_Y
	ev.axis_value = v
	Input.parse_input_event(ev)
	await _frames(2)


## Send `values` one motion event at a time, once to each listener alone (the other takes no input, so one cannot pass
## the centre on for the other), and return each listener's counts.
func _play(plain: Listener, guarded: Listener, values: Array) -> Array:
	var out: Array = []
	for who: Listener in [plain, guarded]:
		plain.set_process_input(who == plain)
		guarded.set_process_input(who == guarded)
		who.counts.clear()
		for v in values:
			await _axis(float(v))
		await _axis(0.0)   # every pattern ends at rest
		await _frames(2)
		out.append(who.counts.duplicate())
	return out


func _run() -> void:
	var plain := Listener.new()
	var guarded := Listener.new()
	guarded.guard = true
	root.add_child(plain)
	root.add_child(guarded)
	await _frames(4)
	await _axis(0.0)
	# 1. A push, straight back to the centre, a push again: two presses on every listener.
	var r: Array = await _play(plain, guarded, [1.0, 0.0, 1.0])
	print("STICK twice, straight back: plain %s, Team-page shape %s" % [r[0], r[1]])
	_ok("Two pushes down, straight back between: ui_down counts 2 on a screen that reads every event (%d)" % int(r[0].get(&"ui_down", 0)), int(r[0].get(&"ui_down", 0)) == 2)
	_ok("Two pushes down: move_down counts 2 (%d)" % int(r[0].get(&"move_down", 0)), int(r[0].get(&"move_down", 0)) == 2)
	_ok("Two pushes down on the Team page's shape (presses only reach UI.pressed): ui_down counts 2 (%d)" % int(r[1].get(&"ui_down", 0)), int(r[1].get(&"ui_down", 0)) == 2)
	# 2. Let back slowly through the dead zone (0.7, 0.4, 0.1), then a push again.
	r = await _play(plain, guarded, [1.0, 0.7, 0.4, 0.1, 0.0, 0.8])
	print("STICK twice, let back slowly: plain %s, Team-page shape %s" % [r[0], r[1]])
	_ok("Let back slowly, a push again: ui_down 2 on both shapes (%d, %d)" % [int(r[0].get(&"ui_down", 0)), int(r[1].get(&"ui_down", 0))], int(r[0].get(&"ui_down", 0)) == 2 and int(r[1].get(&"ui_down", 0)) == 2)
	# 3. Down, then up: one each.
	r = await _play(plain, guarded, [1.0, 0.0, -1.0])
	_ok("Down then up: ui_down 1 and ui_up 1 (%s)" % str(r[0]), int(r[0].get(&"ui_down", 0)) == 1 and int(r[0].get(&"ui_up", 0)) == 1)
	# 4. Held: more motion while the stick stays past the line is still one push.
	r = await _play(plain, guarded, [0.9, 1.0, 0.95, 1.0, 0.85])
	_ok("Held down through five motion events: one press (%d, Team-page shape %d)" % [int(r[0].get(&"ui_down", 0)), int(r[1].get(&"ui_down", 0))], int(r[0].get(&"ui_down", 0)) == 1 and int(r[1].get(&"ui_down", 0)) == 1)
	# 5. Five taps the same way, as a player stepping down a list: five presses.
	r = await _play(plain, guarded, [1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0])
	_ok("Five taps down: ui_down 5 on both shapes (%d, %d)" % [int(r[0].get(&"ui_down", 0)), int(r[1].get(&"ui_down", 0))], int(r[0].get(&"ui_down", 0)) == 5 and int(r[1].get(&"ui_down", 0)) == 5)
	print("STICK: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()
