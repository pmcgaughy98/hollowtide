extends SceneTree
## V4 (Codex,2026-10-14): current indoor Storage shot, derived from Claude's preserved V3.
## --storage-only records only the exact shared Storage segment. Full eight-shot branch is not yet re-recorded.
## Records the moments built since trailer v2 for the pitch capture (Claude, 2026-10-12; the pitch kit's
## "two-minute capture of the best moments"): the title with Continue, the mail call, the Job Board with
## deliveries, the valley floor with the water rising, a faint and the defeat screen, the Storage, growth at
## the shrine, and the Warden stand-off with the stone. Run with Godot's Movie Maker at a fixed 30 fps:
##   Godot --path . --fixed-fps 30 --write-movie docs/trailer/v4/raw.avi --script res://tools/trailer/record_pitch_v4.gd
## Prints "SEG <name> <first frame> <last frame>" for tools/trailer/a future cut_pitch_v4.py. Nothing here changes the
## game; the save it writes for the Continue shot is its own file and is erased at the end.

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const SAVE := "user://pitch_capture_v4.save"

var _base := 0
var _seg_name := ""
var _seg_start := 0
var _checks: Array = []
var _markers: Array = []
var _review := ""


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _now() -> int:
	return Engine.get_process_frames() - _base


func _begin(name: String) -> void:
	_seg_name = name
	_seg_start = _now()


func _end() -> void:
	print("SEG %s %d %d" % [_seg_name, _seg_start, _now()])


func _scene() -> String:
	return current_scene.scene_file_path.get_file() if current_scene != null else "none"


## Read a scene's lines at a viewer's pace: each line types out, holds, then the next.
func _read(host: Node, frames: int, hold := 50) -> void:
	var since := 0
	for k in frames:
		await process_frame
		if host == null or not is_instance_valid(host):
			return
		var talk: Array = host.get("talk")
		if talk == null or talk.is_empty():
			since = 0
			continue
		var line := String(talk[0][1])
		if UI.line_done(line):
			since += 1
			if since >= hold:
				if host.has_method("act_talk"):
					host.act_talk()
				else:
					talk.pop_front()
				since = 0


func _record() -> void:
	TeamState.start([[0, 0], [1, 0], [7, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "delivered", "guild_trial": true, "runner": true, "road_talk": true}
	TeamState.data["beaten"] = ["mouth", "first"]
	TeamState.data["levels"] = {0: {"lv": 5, "exp": 20}, 1: {"lv": 5, "exp": 20}, 7: {"lv": 4, "exp": 0}}
	TeamState.data["bag"] = {"reedberry": 2, "lamp_oil": 1, "river_stone": 1, "rally_seed": 1}
	TeamState.data["cleared"] = 2
	TeamState.data["rank"] = 70


func _run() -> void:
	_base = Engine.get_process_frames()
	TeamState.save_path = SAVE
	_review = OS.get_environment("HT_CAPTURE_REVIEW")
	if _review == "": _review = ProjectSettings.globalize_path("user://pitch_v4_review")
	DirAccess.make_dir_recursive_absolute(_review)
	if "--storage-only" in OS.get_cmdline_user_args():
		var good := await _storage_shot()
		await _finish_capture(good)
		return
	# 1. The title with Continue, into Highbank.
	TeamState.save_path = SAVE
	_record()
	TeamState.save()
	var title: Node = load("res://scenes/creature_opening.tscn").instantiate()
	change_scene_to_node(title)
	await _frames(150)
	_begin("title_continue")
	await _frames(70)
	title._on_continue()
	var guard := 0
	while _scene() != "hub_town.tscn" and guard < 300:
		await process_frame
		guard += 1
	await _frames(100)
	_end()
	TeamState.erase_save()
	# Keep every shot on this recorder's private save path.

	# 2. The mail call on the Hall's lower floor.
	_record()
	TeamState.data["story"]["parcel"] = "stolen"
	TeamState.data["story"].erase("runner")
	var low: Node2D = load("res://scenes/town_room.tscn").instantiate()
	low.room_id = "hall_low"
	low.poll_input = false
	low.force_scenes = true
	change_scene_to_node(low)
	await _frames(20)
	_begin("mail_call")
	await _read(low, 30 * 55, 45)
	_end()

	# 3. The Job Board with deliveries.
	_record()
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	TeamState.give_to(town)
	change_scene_to_node(town)
	await _frames(10)
	var board: Dictionary = town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "board")[0]
	town.team[0]["pos"] = board["door"]
	town._place(town.team[0])
	town.act_use()
	var posted: Array = TeamState.data.get("board", [])
	if posted.size() >= 2:
		posted[0].merge({"kind": "delivery", "cond": "lit", "reward": "lamp_oil", "count": 1, "pts": 25, "floor": 1}, true)
		posted[1].merge({"kind": "delivery", "cond": "careful", "reward": "lamp_oil", "count": 1, "pts": 25, "floor": 2}, true)
	await _frames(10)
	_begin("board")
	await _frames(50)
	town.act_board_pick()
	await _frames(70)
	town.act_board_move(1)
	await _frames(40)
	town.act_board_pick()
	await _frames(80)
	_end()
	town.panel = {}

	# 4. The valley floor: the water rises under the autopilot's feet.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon = "hollow"
	dg.floor_seed = 1
	dg.poll_input = false
	TeamState.give_to(dg)
	dg.party = [[0, 0], [1, 0], [7, 0]]
	dg.return_to_town = true
	change_scene_to_node(dg)
	await _frames(20)
	# The team at the low end of the valley, walking the shore, so the camera is there when the water comes up
	# (turns 10, 20, 30: a rise every WATER_EVERY turns) and the current carries them a tile downstream.
	var shore := Vector2i(-1, -1)
	for y in range(dg.water_base - 1, -1, -1):
		for x in range(2, int(dg.data["w"]) - 8):
			var p := Vector2i(x, y)
			if dg._floor_at(p) and dg._occupant(p) < 0 and dg._floor_at(p + Vector2i(1, 0)) and dg._floor_at(p + Vector2i(2, 0)) and dg._floor_at(p + Vector2i(3, 0)):
				shore = p
				break
		if shore != Vector2i(-1, -1):
			break
	if shore != Vector2i(-1, -1):
		var k := 0
		for e in dg.ents:
			if e["team"] != 0:
				continue
			e["pos"] = shore + Vector2i(k, 0) if k < 3 else shore + Vector2i(0, -1)
			dg._place(e)
			k += 1
		dg.ents[0]["facing"] = "e"
		dg._reveal()
	dg.turn = 8
	await _frames(10)
	_begin("water")
	var dir := Vector2i(1, 0)
	for step in 26:
		var lead: Dictionary = dg.ents[0]
		if not dg.can_step(lead["pos"], dir) or dg._occupant(lead["pos"] + dir) >= 0:
			dir = -dir
		await dg.act_move(dir)
		await _frames(12)
	await _frames(30)
	_end()
	await _frames(10)

	# 5. The leader goes down: the faint screen, the partner's word, the defeat panel.
	dg.bag.erase("rally_seed")   # no Second Wind, or the leader gets back up and there is no faint to show
	dg.fell_to = "Troughspine"
	dg.downed = 3
	dg.ents[0]["hp"] = 0
	_begin("faint")
	dg._end_turn()
	guard = 0
	while _scene() != "faint_screen.tscn" and guard < 200:
		await process_frame
		guard += 1
	var fs: Node = current_scene
	await _frames(30 * 5)
	if fs != null and fs.has_method("advance"):
		fs.advance()
	await _frames(30 * 6)
	_end()
	if fs != null and is_instance_valid(fs) and fs.has_method("advance"):
		fs.advance()
	guard = 0
	while _scene() != "hub_town.tscn" and guard < 300:
		await process_frame
		guard += 1
	await _frames(20)

	# 6. Current Storage room: entry, counter, deposit/withdraw and exit.
	if not await _storage_shot():
		await _finish_capture(false)
		return

	# 7. Growth at the shrine: Kithflare has grown into Sparkwick.
	var c: Dictionary = load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()
	var r: Dictionary = c["EVO"][0]
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "delivered", "guild_trial": true, "runner": true, "road_talk": true, "stone": "installed"}
	TeamState.data["beaten"] = ["mouth", "first", "hollow"]
	TeamState.data["levels"] = {0: {"lv": c["EVO_LEVEL"][0], "exp": 0}, 1: {"lv": 3, "exp": 0}}
	TeamState.data["growth"] = {"0:0": {"kos": r["kos"][0], "floors": r["floors"][0], "flank": r["need"][0], "ambush": 0, "took": 0, "slam": 0}}
	TeamState.data["taught"] = {"0:0": ["claw", "ember_feint", "fireball"]}
	var town2: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town2.poll_input = false
	TeamState.give_to(town2)
	change_scene_to_node(town2)
	await _frames(10)
	var shrine: Dictionary = town2.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "shrine")[0]
	town2.team[0]["pos"] = shrine["door"]
	town2._place(town2.team[0])
	town2.act_use()
	await _frames(40)
	_begin("growth")
	town2.act_use()
	guard = 0
	while town2.evolving_now and guard < 30 * 40:
		await process_frame
		guard += 1
	await _frames(90)
	_end()

	# 8. The Warden stand-off and the stone.
	TeamState.start([[0, 1], [1, 0], [7, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "delivered", "guild_trial": true, "runner": true, "road_talk": true}
	TeamState.data["beaten"] = ["mouth", "first"]
	TeamState.data["levels"] = {0: {"lv": 6, "exp": 0}, 1: {"lv": 5, "exp": 0}, 7: {"lv": 5, "exp": 0}}
	var bd: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	bd.floor_seed = 7
	bd.poll_input = false
	TeamState.give_to(bd)
	bd.dungeon = "hollow"
	bd.return_to_town = true
	change_scene_to_node(bd)
	await _frames(6)
	bd.floor_n = bd.floors() + 1
	bd._build_floor(false)
	await _frames(6)
	bd.boss_met = true
	bd.cutscene = false
	bd.talk.clear()
	var w: Dictionary = bd.ents[bd.boss]
	w["awake"] = true
	w["hp"] = maxi(1, int(round(w["max_hp"] * 0.3)))
	bd.ents[0]["hp"] = 0
	_begin("standoff")
	bd._end_turn()
	guard = 0
	while is_instance_valid(bd) and _scene() == "dungeon.tscn" and guard < 30 * 75:
		await process_frame
		guard += 1
		if not is_instance_valid(bd):
			break
		var talk: Array = bd.talk
		if not talk.is_empty() and guard % 55 == 0:
			bd.act_talk()
	await _frames(60)   # the stone carried home: Highbank's first frames
	_end()
	await _finish_capture(true)


func _checked(label: String, good: bool) -> bool:
	_checks.append({"label":label,"passed":good})
	print("CAPTURE_CHECK %s -> %s" % [label,"ok" if good else "FAIL"])
	return good

func _mark(name: String) -> void:
	_markers.append({"name":name,"frame":_now(),"seconds":_now()/30.0})
	print("SHOT %s %d" % [name,_now()])

func _still(name: String) -> void:
	await _frames(3)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_review+"/"+name+".png")

func _walk_to(room: Node, to: Vector2i) -> bool:
	var start: Vector2i=room.team[0]["pos"]
	var came := {start:start}
	var q: Array = [start]
	while not q.is_empty():
		var c: Vector2i=q.pop_front()
		for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var n: Vector2i=c+d
			if not came.has(n) and room._open(n):
				came[n]=c;q.append(n)
	if not came.has(to): return false
	var path: Array=[]
	var at:=to
	while at!=start:
		path.push_front(at);at=came[at]
	for step in path:
		await room.act_move(step-room.team[0]["pos"])
		await _frames(1)
	return room.team[0]["pos"]==to

func _storage_shot() -> bool:
	_record()
	var expected_party: Array=TeamState.data["party"].duplicate(true)
	var town: Node=load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input=false
	TeamState.give_to(town)
	change_scene_to_node(town)
	await _frames(10)
	var door: Dictionary=town.Layout.PLACES.filter(func(p: Dictionary) -> bool:return p["id"]=="storage")[0]
	# Shot setup, as in V3: start beside the town door, then use actual scene transitions and walk the room.
	town.team[0]["pos"]=door["door"]+Vector2i.DOWN
	town.team[0]["facing"]="n";town._place(town.team[0])
	_begin("storage");_mark("storage_door")
	await _frames(30)
	town.act_use()
	await _frames(10)
	var room: Node=current_scene
	if not _checked("door enters current Storage room",room.get("room_id")=="storage"):return false
	room.poll_input=false
	if not _checked("all three current party members enter",room.team.size()==expected_party.size() and expected_party.size()==3):return false
	_mark("storage_interior");await _still("01_entry");await _frames(40)
	if not _checked("walk behind the counter",await _walk_to(room,Vector2i(8,4))):return false
	_mark("storage_shelves");await _still("02_shelves");await _frames(50)
	if not _checked("walk to the counter front",await _walk_to(room,Vector2i(8,7))):return false
	room.team[0]["facing"]="n";room._place(room.team[0])
	room.act_use()
	if not _checked("counter opens the real Storage panel",room.panel.get("service","")=="storage"):return false
	_mark("storage_panel");await _still("03_panel");await _frames(35)
	room.act_store(1)
	if not _checked("deposit is exactly one berry",TeamState.data["bag"].get("reedberry",0)==1 and TeamState.data["stored"].get("reedberry",0)==1):return false
	_mark("storage_deposit");await _still("04_deposit");await _frames(70)
	room.act_store(-1)
	if not _checked("withdraw restores two berries and empty store",TeamState.data["bag"].get("reedberry",0)==2 and TeamState.data["stored"].is_empty()):return false
	_mark("storage_withdraw");await _still("05_withdraw");await _frames(70)
	room.panel={}
	if not _checked("walk back to the south threshold",await _walk_to(room,Vector2i(8,11))):return false
	await room.act_move(Vector2i.DOWN)
	await _frames(10)
	var returned: Node=current_scene
	if not _checked("door returns to real Highbank scene",_scene()=="hub_town.tscn"):return false
	returned.poll_input=false
	if not _checked("return lands outside Storage",returned.team[0]["pos"]==door["door"]+Vector2i.DOWN):return false
	if not _checked("party record survives the shot",TeamState.data["party"]==expected_party):return false
	if not _checked("capture uses its own save",TeamState.save_path==SAVE):return false
	_mark("storage_return");await _still("06_return");await _frames(45)
	_end()
	print("STORAGE SHOT: 12/12")
	return true

func _finish_capture(good: bool) -> void:
	FileAccess.open(_review+"/shot-markers.json",FileAccess.WRITE).store_string(JSON.stringify({"fps":30,"mode":"storage-only" if "--storage-only" in OS.get_cmdline_user_args() else "full","checks":_checks,"markers":_markers,"last_segment_frame":_now()},"  "))
	if current_scene!=null:current_scene.queue_free()
	await _frames(4)
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await _frames(4)
	TeamState.erase_save()
	print("RECORDED %d frames" % _now())
	quit(0 if good else 1)
