extends SceneTree
## The faint flow (Claude, 2026-10-12; Preston: a wipe must bring the team home like Mystery Dungeon, with a defeat
## information screen). A wipe in a run from town fades to the faint screen: the partner's word first, then the
## defeat panel (where, what beat you, the turns, what was lost). E carries the team home to Highbank with the record
## intact: the faint counted, the bag gone, the story untouched, and the next run starts whole. In the Hollow Mouth
## before the road to town is open, E starts the Mouth again from B1F instead. The words on the screen have to match
## where E goes (FLOW-06, 2026-10-22). Windowed it saves both pages to docs/design/faint-2026-10-12/.
##   Godot --headless --path . --script res://tools/debug/faint_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const OUT := "res://docs/design/faint-2026-10-12/"
const FAINT := "res://scenes/faint_screen.tscn"
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


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	for k in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


## The defeat panel's lines top to bottom (heading, rows, key hint), from the screen's _layout() (lane 5, LP-22);
## [] when the screen draws them inline, which a headless run cannot read. Claude, 2026-10-22.
func _panel(screen: Node) -> Array:
	if not screen.has_method("_layout"):
		return []
	var laid: Array = screen.call("_layout")
	if laid.is_empty() or not (laid[0] is Array):
		return []
	return laid[0].map(func(item: Array) -> String: return String(item[0]))


## How the panel reads in an ok line: its heading and key hint.
func _panel_note(lines: Array) -> String:
	return ", panel '%s' ... '%s'" % [lines[0], lines[-1]] if not lines.is_empty() else " (the panel is drawn inline, not read)"


func _scene() -> String:
	return current_scene.scene_file_path.get_file() if current_scene and current_scene.scene_file_path != "" else str(current_scene)


## A dungeon run the way the town starts one, as the current scene.
func _dungeon(id: String, story: Dictionary) -> Node2D:
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = story
	TeamState.data["bag"] = {"reedberry": 2, "lamp_oil": 1}
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	TeamState.give_to(dg)
	dg.dungeon = id
	dg.return_to_town = true
	root.add_child(dg)
	current_scene = dg
	await _frames(4)
	return dg


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	# 1. Rootbank Warren on the trial: a wipe on B1F.
	var dg := await _dungeon("first", {"met_crew": true, "parcel": "stolen", "guild_trial": true})
	dg.fell_to = "Whinet"   # as if the crew's grunt landed the last hit
	dg.ents[0]["hp"] = 0
	dg._end_turn()
	await create_timer(0.9).timeout   # the fade
	var screen: Node = current_scene
	_ok("A wipe opens the faint screen (%s)" % _scene(), current_scene.scene_file_path == FAINT)
	if current_scene.scene_file_path != FAINT:
		print("FAINT: 1 FAILED")
		quit(1)
		return
	var info: Dictionary = screen.info
	_ok("It knows the run: %s %s, beaten by %s, %d items lost, going home %s" % [info.get("dungeon"), info.get("floor"), info.get("fell_to"), int(info.get("lost_items", 0)), str(info.get("to_town"))],
		info.get("dungeon") == "Rootbank Warren" and info.get("floor") == "B1F" and info.get("fell_to") == "Whinet" and int(info.get("lost_items", 0)) == 3 and info.get("to_town") == true)
	_ok("The partner speaks first (%s): %s" % [info.get("partner"), screen._word()], String(info.get("partner", "")) != "" and screen.page == 0)
	await _snap("1_partner")
	screen.advance()   # the line finishes
	screen.advance()   # the panel
	_ok("Then the defeat panel (page %d)" % screen.page, screen.page == 1)
	# FLOW-06 (Claude, 2026-10-22, factory lane 7): the words match the next scene. Here that is Highbank.
	var word1 := String(screen._word())
	var panel1 := _panel(screen)
	_ok("The words match the next scene, Highbank: '%s'%s" % [word1, _panel_note(panel1)],
		"home" in word1.to_lower() and (panel1.is_empty() or ("HOME" in String(panel1[0]).to_upper() and "home" in String(panel1[-1]).to_lower())))
	await _snap("2_panel")
	screen.advance()   # home
	await _frames(6)
	var town: Node = current_scene
	var home := current_scene.scene_file_path == "res://scenes/hub_town.tscn"
	_ok("E carries the team home (%s), with news: %s" % [_scene(), str(town.panel.get("what", "")) if home else "none"],
		home and String(town.panel.get("service", "")) == "news")
	_ok("The record: faints %d, bag %s, parcel %s" % [int(TeamState.data.get("faints", 0)), str(TeamState.data.get("bag", {})), str(TeamState.data.get("story", {}).get("parcel", ""))],
		int(TeamState.data.get("faints", 0)) == 1 and TeamState.data.get("bag", {}) == {"reedberry": 1} and String(TeamState.data.get("story", {}).get("parcel", "")) == "stolen")
	town.queue_free()
	await _frames(2)
	# The next run starts whole.
	var again: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	TeamState.give_to(again)
	again.dungeon = "first"
	again.return_to_town = true
	root.add_child(again)
	current_scene = again
	await _frames(4)
	_ok("The next run starts with the leader whole (%d of %d HP) and faints carried (%d)" % [again.ents[0]["hp"], again.ents[0]["max_hp"], again.faints],
		again.ents[0]["hp"] == again.ents[0]["max_hp"] and again.ents[0]["hp"] > 0 and again.faints == 1)
	again.queue_free()
	await _frames(2)
	# 2. The Hollow Mouth before the road to town is open: back to the bank, not to Highbank.
	var mouth := await _dungeon("mouth", {})
	mouth.ents[0]["hp"] = 0
	mouth._end_turn()
	await create_timer(0.9).timeout
	var s2: Node = current_scene
	var on_screen := current_scene.scene_file_path == FAINT
	_ok("In the Mouth before the road: the faint screen sends the team back into the Mouth (going home %s)" % (str(s2.info.get("to_town")) if on_screen else "no screen"),
		on_screen and s2.info.get("to_town") == false)
	if on_screen:
		# FLOW-06: E starts the Mouth again at B1F, so nothing on the screen may promise the bank or home (the bank
		# is where the team woke, not where E goes); the panel's heading says the top.
		var word2 := String(s2._word())
		var panel2 := _panel(s2)
		var said := (word2 + " " + " ".join(panel2)).to_lower()
		_ok("The words match the next scene, the Mouth's B1F: '%s'%s" % [word2, _panel_note(panel2)],
			not ("bank" in said) and not ("home" in said) and (panel2.is_empty() or "TOP" in String(panel2[0]).to_upper()))
		# Press until it leaves, not a set three: this line pages once the portrait inset grew to 162
		# (2026-10-14; 528 px wraps it to three rows, two pages, five presses). Claude, 2026-10-14.
		for k in 8:
			if current_scene != s2:
				break
			s2.advance()
			await _frames(2)
		await _frames(6)
	var in_dungeon := current_scene.scene_file_path == "res://scenes/dungeon.tscn"
	_ok("E takes the team back into the Mouth, B1F (%s%s)" % [_scene(), (", %s floor %d, faints %d" % [current_scene.dungeon, current_scene.floor_n, current_scene.faints]) if in_dungeon else ""],
		in_dungeon and current_scene.dungeon == "mouth" and current_scene.floor_n == 1 and current_scene.faints == 1)
	print("FAINT: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
