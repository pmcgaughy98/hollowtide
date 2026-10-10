extends SceneTree
## The music wiring (Claude, 2026-10-09): every place and situation picks its track, and the events
## play their jingles. Reads the music player's current track and last jingle.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/music_check.gd

const Music := preload("res://scripts/audio/music.gd")


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _now() -> String:
	return Music._inst.current if Music._inst != null else "(none)"


func _run() -> void:
	var lines: Array[String] = []
	# The town.
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(4)
	lines.append("town at home: %s" % _now())
	town.team[0]["pos"] = Vector2i(24, 9)
	await town.act_move(Vector2i(0, -1))
	await _frames(2)
	lines.append("by the Hall: %s" % _now())
	town.team[0]["pos"] = Vector2i(26, 27)
	await town.act_move(Vector2i(1, 0))
	await _frames(2)
	lines.append("at the ferry landing: %s" % _now())
	town.queue_free()
	await _frames(2)
	# The Hollow.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	lines.append("B1F: %s" % _now())
	dg.light = 20.0
	dg._music_update()
	await _frames(2)
	lines.append("B1F, lantern low: %s" % _now())
	dg.light = 100.0
	dg.monster_room = dg.data["rooms"][1]
	dg.monster_sprung = false
	dg.ents[0]["pos"] = dg.monster_room.get_center()
	dg._monster_house()
	await _frames(2)
	lines.append("a Monster House springs: %s" % _now())
	dg.floor_n = dg.FLOORS
	dg._build_floor(false)
	await _frames(2)
	lines.append("B%dF (before the boss): %s" % [dg.floor_n, _now()])
	dg.rest_floor = 2
	dg.floor_n = 2
	dg._build_floor(false)
	await _frames(2)
	lines.append("a rest floor: %s" % _now())
	dg.floor_n = dg.FLOORS + 1
	dg._build_floor(true)
	await _frames(2)
	lines.append("the boss floor, its scene: %s" % _now())
	for k in dg.talk.size():
		dg.act_talk()
	await _frames(2)
	lines.append("the boss fight: %s" % _now())
	dg.ents[dg.boss]["hp"] = 1
	dg._wound(0, dg.boss, 5, Color.WHITE)
	await _frames(2)
	lines.append("the boss falls: track '%s', jingle %s" % [_now(), Music._inst.last_jingle])
	dg.party.append([2, 0])
	dg.recruit_override = 1.0
	dg.queue_free()
	await _frames(4)
	# Jingles from their own calls.
	var d2: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	d2.floor_seed = 99
	d2.poll_input = false
	root.add_child(d2)
	await _frames(4)
	var w: Dictionary = d2._make(2, 0, 1, d2.ents[0]["pos"] + Vector2i(1, 0))
	d2.ents.append(w)
	d2.asking = d2.ents.size() - 1
	d2.act_recruit(true)
	await _frames(2)
	lines.append("a recruit joins: jingle %s" % Music._inst.last_jingle)
	d2._evolve([[0, "kithflare"]])
	await _frames(2)
	lines.append("an evolution: jingle %s" % Music._inst.last_jingle)
	d2.ents[0]["hp"] = 0
	d2._end_turn()
	await _frames(2)
	lines.append("a faint: jingle %s" % Music._inst.last_jingle)
	for l in lines:
		print(l)
	# Review-only teardown: let the forced faint/evolution/clear timers finish.
	await _frames(180)
	for child in root.get_children(): child.queue_free()
	Music._inst = null
	await _frames(4)
	quit()
