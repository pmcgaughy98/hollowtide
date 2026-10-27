extends SceneTree
## The music wiring (Claude, 2026-10-09): every place and situation picks its track, and the events
## play their jingles. Reads the music player's current track and last jingle.
## Judged rows (Claude, 2026-10-22, the factory pass): after each scene's _ready no AudioStreamPlayer sits
## on the Master bus (every player names SFX, UI or Music: docs/audio/sources.md, "Buses and the mix"), the
## way to The Hollow plays hollow_flute, and the faint screen beds storm_rain on SFX. A one-shot click is
## freed before a tree walk can see it, so the sources are read too: every player made in code sets a bus.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/music_check.gd

const Music := preload("res://scripts/audio/music.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const FAINT := "res://scenes/faint_screen.tscn"

var bad := 0


func _initialize() -> void:
	_run.call_deferred()


## Every AudioStreamPlayer (plain or 2D) under `node` that sits on `bus`, as paths from the root.
func _players_on(bus: StringName, node: Node, out: Array[String]) -> void:
	if (node is AudioStreamPlayer or node is AudioStreamPlayer2D) and node.bus == bus:
		out.append(str(root.get_path_to(node)))
	for c in node.get_children():
		_players_on(bus, c, out)


## The bus contract: after a scene's _ready, no player is left on Master.
func _master_row(where: String) -> void:
	var found: Array[String] = []
	_players_on(&"Master", root, found)
	print("players on Master after %s: %s -> %s" % [where, "none" if found.is_empty() else str(found), "ok" if found.is_empty() else "WRONG"])
	bad += found.size()


## Every AudioStreamPlayer.new() under `dir` whose variable gets no ".bus =" in the next 15 lines, and
## every bus set to Master (or a bus argument that defaults to it), as file:line (Claude, 2026-10-22).
## Left out, as outside the campaign: the arena (its own mode) and the old Route 1 battle screen.
const LEFT_OUT := ["res://scripts/arena", "res://scripts/battle_screen.gd"]


func _unbussed(dir: String, out: Array[String]) -> void:
	var made := RegEx.create_from_string("(\\w+)\\s*:?=\\s*AudioStreamPlayer(2D)?\\.new\\(\\)")
	var master := RegEx.create_from_string("bus\\s*(:\\s*StringName)?\\s*=\\s*&?\"Master\"")
	for f in DirAccess.get_files_at(dir):
		var path := dir.path_join(f)
		if not f.ends_with(".gd") or path in LEFT_OUT:
			continue
		var src := FileAccess.get_file_as_string(path).split("\n")
		for i in src.size():
			var m := made.search(src[i])
			var loose: bool = m != null and not "\n".join(src.slice(i, i + 15)).contains(m.get_string(1) + ".bus =")
			if loose or master.search(src[i]) != null:
				out.append("%s:%d" % [path.trim_prefix("res://"), i + 1])
	for d in DirAccess.get_directories_at(dir):
		if not dir.path_join(d) in LEFT_OUT:
			_unbussed(dir.path_join(d), out)


## The first playing player of the named sound (its stream's file, or a node named for it), with its bus.
## `same` is the sound itself: a looped copy (stream.duplicate(), as storm_rain.gd makes) has no file
## name left, so a WAV with the same samples counts too.
func _playing(sound: String, node: Node, same: AudioStream = null) -> String:
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		var s: AudioStream = node.stream
		var file: String = s.resource_path.get_file() if s != null else ""
		var copy: bool = s is AudioStreamWAV and same is AudioStreamWAV and s.data.size() == same.data.size() and s.data == same.data
		if node.playing and (file.begins_with(sound) or node.name.to_lower().contains(sound) or copy):
			return "%s on %s" % [str(root.get_path_to(node)), node.bus]
	for c in node.get_children():
		var r := _playing(sound, c, same)
		if r != "":
			return r
	return ""


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
	_master_row("Highbank")
	lines.append("town at home: %s" % _now())
	# The tile is an anchor of the town's areas (lane A, Claude, 2026-10-26): in today's map the one this check named; with
	# Highbank v2 on (HT_HIGHBANK_V2=1) the town goes into that anchor's area first.
	town.enter_area(town.Layout.anchor_area("music_street"), "music_street")
	town.team[0]["pos"] = town.Layout.anchor("music_street")
	await town.act_move(Vector2i(0, -1))
	await _frames(2)
	await create_timer(town.MUSIC_SETTLE + 0.2).timeout   # the street's track waits for the leader to stay (pass 6 T3)
	lines.append("by the Hall: %s" % _now())
	town.enter_area(town.Layout.anchor_area("music_ferry"), "music_ferry")
	town.team[0]["pos"] = town.Layout.anchor("music_ferry")
	await town.act_move(Vector2i(1, 0))
	await _frames(2)
	await create_timer(town.MUSIC_SETTLE + 0.2).timeout
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
	_master_row("the Hollow, B1F")
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
	dg.boss_intro = false   # the Warden's entrance has its own check (boss_intro_capture.gd); this one reads the plain hand-over
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
	_master_row("a second run")
	var w: Dictionary = d2._make(2, 0, 1, d2.ents[0]["pos"] + Vector2i(1, 0))
	d2.ents.append(w)
	d2.asking = d2.ents.size() - 1
	d2.act_recruit(true)
	await _frames(2)
	lines.append("a recruit joins: jingle %s" % Music._inst.last_jingle)
	# Evolving happens at the Growth Shrine now (2026-10-10): its scene plays the jingle.
	var evo: CanvasLayer = load("res://scripts/ui/evolution_scene.gd").new()
	root.add_child(evo)
	await _frames(1)
	_master_row("the evolution scene")
	await evo.run("kithflare", "sparkwick", "Kithflare", "Sparkwick", true)
	evo.queue_free()
	lines.append("an evolution: jingle %s" % Music._inst.last_jingle)
	d2.ents[0]["hp"] = 0
	d2._end_turn()
	await _frames(2)
	lines.append("a faint: jingle %s" % Music._inst.last_jingle)
	d2.queue_free()
	await _frames(4)
	for l in lines:
		print(l)
	# The way to The Hollow (scripts/town/hollow_approach.gd): its _ready names the approach's track.
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["beaten"] = ["first"]
	var ap: Node2D = load("res://scenes/hollow_approach.tscn").instantiate()
	root.add_child(ap)
	await _frames(4)
	print("the way to The Hollow plays: %s -> %s" % [_now(), "ok" if _now() == "hollow_flute" else "WRONG"])
	bad += 0 if _now() == "hollow_flute" else 1
	_master_row("the way to The Hollow")
	ap.queue_free()
	await _frames(2)
	# The faint screen (scenes/faint_screen.tscn), reached the way the player reaches it: a wipe in a run
	# started from town, as faint_check does. Under it, storm_rain on SFX.
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "stolen", "guild_trial": true}
	TeamState.data["bag"] = {"reedberry": 2, "lamp_oil": 1}
	var d3: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	TeamState.give_to(d3)
	d3.dungeon = "first"
	d3.return_to_town = true
	d3.poll_input = false
	root.add_child(d3)
	current_scene = d3
	await _frames(4)
	d3.ents[0]["hp"] = 0
	d3._end_turn()
	var until := Time.get_ticks_msec() + 4000   # the 0.6 s fade, then the hand-over
	while Time.get_ticks_msec() < until and (current_scene == null or current_scene.scene_file_path != FAINT):
		await process_frame
	var on_faint: bool = current_scene != null and current_scene.scene_file_path == FAINT
	print("a wipe opens the faint screen: %s -> %s" % [current_scene.scene_file_path.get_file() if on_faint else str(current_scene), "ok" if on_faint else "WRONG"])
	bad += 0 if on_faint else 1
	await _frames(2)
	var bed := _playing("storm_rain", root, load("res://assets/audio/sfx/story/storm_rain.wav"))
	print("the faint screen beds storm_rain: %s -> %s" % [bed if bed != "" else "nothing plays it", "ok" if bed.ends_with("on SFX") else "WRONG"])
	bad += 0 if bed.ends_with("on SFX") else 1
	_master_row("the faint screen")
	var loose: Array[String] = []
	_unbussed("res://scripts", loose)
	print("players made in code with no bus, or on Master: %s -> %s" % ["none" if loose.is_empty() else str(loose), "ok" if loose.is_empty() else "WRONG"])
	bad += loose.size()
	print("RESULT:%s" % ("music and buses wired" if bad == 0 else "%d problems" % bad))
	quit()
