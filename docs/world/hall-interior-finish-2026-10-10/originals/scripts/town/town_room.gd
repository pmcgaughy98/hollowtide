extends Node2D
## Rooms inside Highbank's buildings (Claude, 2026-10-10; Preston: "do this for interiors too, I noticed
## main house and courier hall rooms were super small"). Walk in through the Home's or the Wayline Hall's
## door and the team stands in a room at the town's own scale (24 px tiles, the same creatures), painted
## in code like the dungeons (scripts/town/room_painter.gd), with things to use and the door back out.
## Codex's older courier-era rooms (scenes/courier_hall.tscn, courtyard_home.tscn) are untouched.
##   var room = load("res://scenes/town_room.tscn").instantiate(); room.room_id = "home"

const Arena := preload("res://scripts/arena/arena_prototype.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const Painter := preload("res://scripts/town/room_painter.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const T := 24
const VIEW := Vector2i(384, 216)
const SCALE := 3.0
const STEP_TIME := 0.13
const WALK_FPS := 12.0
const DIRS := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]

## Each room: its size in tiles (walls included), its door (on the bottom wall), the furniture that
## blocks walking, and the spots that answer E. The texts are Claude's drafts.
const ROOMS := {
	"home": {"name": "Home", "w": 14, "h": 10, "door": Vector2i(7, 9), "town_door": "home",
		"solid": [Rect2i(1, 2, 3, 2), Rect2i(9, 2, 4, 1), Rect2i(6, 4, 3, 2), Rect2i(1, 7, 2, 2), Rect2i(11, 6, 2, 2)],
		"spots": [
			{"id": "bed", "rect": Rect2i(1, 2, 3, 2), "name": "Moss Bed", "what": "Rest here and the day ends: the team wakes up whole. (Saving comes with the save system.)"},
			{"id": "hearth", "rect": Rect2i(9, 2, 4, 1), "name": "Hearth", "what": "Warm stones and a kettle. The light the house is built round."},
			{"id": "table", "rect": Rect2i(6, 4, 3, 2), "name": "Table", "what": "A lantern, a map of the river, the parcel slip from the first job."},
			{"id": "shelf", "rect": Rect2i(1, 7, 2, 2), "name": "Shelf", "what": "Jars of reedberries and a stack of old Wayline reports."},
			{"id": "plants", "rect": Rect2i(11, 6, 2, 2), "name": "Planters", "what": "Clover and a stubborn fern. Someone waters them."}]},
	"hall": {"name": "Wayline Hall", "w": 22, "h": 14, "door": Vector2i(11, 13), "town_door": "hall",
		"solid": [Rect2i(7, 3, 8, 1), Rect2i(2, 2, 2, 1), Rect2i(18, 2, 2, 1), Rect2i(3, 6, 1, 1), Rect2i(18, 6, 1, 1), Rect2i(3, 10, 1, 1), Rect2i(18, 10, 1, 1),
			Rect2i(1, 8, 1, 3), Rect2i(20, 8, 1, 3), Rect2i(5, 7, 2, 2), Rect2i(15, 7, 2, 2), Rect2i(2, 12, 2, 1), Rect2i(18, 12, 2, 1),
			Rect2i(4, 6, 1, 1), Rect2i(17, 6, 1, 1)],
		"spots": [
			{"id": "counter", "rect": Rect2i(7, 3, 8, 1), "name": "Dispatch Counter", "what": "The dispatcher hands out the board's requests and takes reports. (The Job Board outside lists them.)", "service": "jobs"},
			{"id": "notices", "rect": Rect2i(2, 2, 2, 1), "name": "Notice Wall", "what": "Sightings, closures, a warning about a crew poaching deliveries."},
			{"id": "roster", "rect": Rect2i(18, 2, 2, 1), "name": "Roster Board", "what": "Every team on the Wayline, by rank. Yours is near the bottom, for now."},
			{"id": "benches", "rect": Rect2i(1, 8, 1, 3), "name": "Bench", "what": "Where couriers wait for the river to settle."},
			{"id": "benches2", "rect": Rect2i(20, 8, 1, 3), "name": "Bench", "what": "Scratched initials and a forgotten glove."},
			{"id": "chart", "rect": Rect2i(5, 7, 2, 2), "name": "Chart Table", "what": "The river and its Hollows, pinned where couriers have gone. A new pin sits on the water near Highbank."},
			{"id": "scrolls", "rect": Rect2i(15, 7, 2, 2), "name": "Report Table", "what": "Reports waiting to be filed. One is stamped LATE in red."},
			{"id": "crates", "rect": Rect2i(2, 12, 2, 1), "name": "Parcels", "what": "Deliveries waiting for a runner."},
			{"id": "crates2", "rect": Rect2i(18, 12, 2, 1), "name": "Parcels", "what": "Undeliverable mail. The labels have washed out."}]},
}

@export var room_id := "home"
var poll_input := true
var team: Array = []
var busy := false
var panel := {}
var grid := PackedByteArray()
var _world: Node2D
var _hud: Node2D
var _keys_was := {}
var used_log: Array = []   # spots used, for the checks


func room() -> Dictionary:
	return ROOMS[room_id]


func _ready() -> void:
	var r := room()
	grid.resize(r["w"] * r["h"])
	for y in r["h"]:
		for x in r["w"]:
			var inside: bool = x >= 1 and x <= r["w"] - 2 and y >= 2 and y <= r["h"] - 2
			grid[y * r["w"] + x] = 1 if inside else 0
	for s in r["solid"]:
		for y in range(s.position.y, s.end.y):
			for x in range(s.position.x, s.end.x):
				grid[y * r["w"] + x] = 0
	grid[r["door"].y * r["w"] + r["door"].x] = 1
	var view := SubViewport.new()
	view.size = VIEW
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(view)
	var screen := Sprite2D.new()
	screen.texture = view.get_texture()
	screen.centered = false
	screen.scale = Vector2.ONE * SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	_world = Node2D.new()
	view.add_child(_world)
	var dark := ColorRect.new()
	dark.color = Color("#1a1410")
	dark.position = Vector2(-400, -400)
	dark.size = Vector2(r["w"] * T + 800, r["h"] * T + 800)
	_world.add_child(dark)
	var map := Sprite2D.new()
	map.centered = false
	map.texture = ImageTexture.create_from_image(Painter.paint(room_id, r))
	if room_id == "home":
		preload("res://scripts/town/home_room_art.gd").finish(map)
	_world.add_child(map)
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	# The team stands just inside the door, in a short line.
	var party: Array = TeamState.data.get("party", [[0, 0], [1, 0]])
	var d: Vector2i = r["door"]
	for k in party.size():
		var at := d + Vector2i(0, -1 - k)
		if k > 0 and not _open(at):
			at = d + Vector2i([1, -1][k % 2], -1)
		var e := _make(party[k][0], party[k][1], at)
		e["facing"] = "n"
		_place(e)
		team.append(e)
	preload("res://scripts/ui/game_pause_menu.gd").attach(self)


func _open(t: Vector2i) -> bool:
	var r := room()
	return t.x >= 0 and t.y >= 0 and t.x < r["w"] and t.y < r["h"] and grid[t.y * r["w"] + t.x] == 1


func _make(line: int, stage: int, pos: Vector2i) -> Dictionary:
	var form: String = Arena.LINES[line]["forms"][stage][0]
	var node := Node2D.new()
	_world.add_child(node)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	preload("res://scripts/arena/creature_finish.gd").apply(sprite)
	var set := "dungeon" if ResourceLoader.exists("res://assets/sprites/arena/%s/dungeon/s.png" % form) else "small"
	var still := {}
	var walk := {}
	for f in Arena.FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/%s/%s.png" % [form, set, f])
		var frames: Array = []
		for k in 8:
			var p := "res://assets/sprites/arena/%s/%s/walk_%s_f%d.png" % [form, set, f, k]
			if ResourceLoader.exists(p):
				frames.append(load(p))
		walk[f] = frames
	return {"line": line, "stage": stage, "form": form, "pos": pos, "node": node, "sprite": sprite, "still": still, "walk": walk,
		"facing": "s", "walk_t": 0.0, "walk_clock": 0.0}


func _px(t: Vector2i) -> Vector2:
	return Vector2(t) * T + Vector2(T * 0.5, T * 0.78)


func _place(e: Dictionary) -> void:
	e["node"].position = _px(e["pos"])
	if e.get("walk_t", 0.0) <= 0.0:
		e["sprite"].texture = e["still"][e["facing"]]
	e["sprite"].position = Vector2(0, -e["sprite"].texture.get_size().y * 0.5 + 4)
	e["node"].z_index = int(e["node"].position.y)


func _facing_of(d: Vector2i) -> String:
	return Arena.FACINGS[DIRS.find(d)] if DIRS.has(d) else "s"


## One step for the leader; the others follow in a chain. Stepping onto the door leaves the room.
func act_move(d: Vector2i) -> void:
	if busy or not panel.is_empty():
		return
	var lead: Dictionary = team[0]
	lead["facing"] = _facing_of(d)
	var to: Vector2i = lead["pos"] + d
	if not _open(to) or (d.x != 0 and d.y != 0 and (not _open(lead["pos"] + Vector2i(d.x, 0)) or not _open(lead["pos"] + Vector2i(0, d.y)))):
		_place(lead)
		return
	busy = true
	var trail: Array = team.map(func(e: Dictionary) -> Vector2i: return e["pos"])
	lead["pos"] = to
	for k in range(1, team.size()):
		if team[k]["pos"].distance_to(team[k - 1]["pos"]) > 1.5:
			team[k]["facing"] = _facing_of((trail[k - 1] - team[k]["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1)))
			team[k]["pos"] = trail[k - 1]
	for e in team:
		if _px(e["pos"]) != e["node"].position:
			e["walk_t"] = STEP_TIME + 0.06
		create_tween().tween_property(e["node"], "position", _px(e["pos"]), STEP_TIME)
	await get_tree().create_timer(STEP_TIME).timeout
	for e in team:
		_place(e)
	busy = false
	if lead["pos"] == room()["door"]:
		leave()


## Use what the leader faces: a spot shows its panel; a second press closes it.
func act_use() -> Dictionary:
	if not panel.is_empty():
		panel = {}
		return {}
	var lead: Dictionary = team[0]
	var ahead: Vector2i = lead["pos"] + DIRS[Arena.FACINGS.find(lead["facing"])]
	for s in room()["spots"]:
		if s["rect"].has_point(ahead) or s["rect"].has_point(lead["pos"]):
			panel = s
			used_log.append(s["id"])
			if s["id"] == "bed":
				for e in team:
					e["facing"] = "s"
					_place(e)
			return s
	return {}


## Back out to Highbank, standing on this building's door.
func leave() -> void:
	TeamState.data["arrive_at"] = room()["town_door"]
	if is_inside_tree() and get_tree().current_scene == self:
		var town: Node = load("res://scenes/hub_town.tscn").instantiate()
		TeamState.give_to(town)
		get_tree().change_scene_to_node(town)
	else:
		set_meta("left", true)


func _process(delta: float) -> void:
	if poll_input and not busy:
		_poll()
	for e in team:
		if e["walk_t"] > 0.0:
			e["walk_t"] -= delta
			e["walk_clock"] += delta
			var frames: Array = e["walk"].get(e["facing"], [])
			if not frames.is_empty():
				e["sprite"].texture = frames[int(e["walk_clock"] * WALK_FPS) % frames.size()]
			if e["walk_t"] <= 0.0:
				e["sprite"].texture = e["still"][e["facing"]]
	if not team.is_empty():
		var r := room()
		var half := Vector2(VIEW) * 0.5
		var size := Vector2(r["w"], r["h"]) * T
		var focus: Vector2 = team[0]["node"].position + Vector2(0, -12)
		focus = Vector2(size.x * 0.5 if size.x <= VIEW.x else clampf(focus.x, half.x, size.x - half.x),
			size.y * 0.5 if size.y <= VIEW.y else clampf(focus.y, half.y, size.y - half.y))
		_world.position = (half - focus).round()
	_hud.queue_redraw()


func _tapped(k: int) -> bool:
	var now := Input.is_key_pressed(k)
	var was: bool = _keys_was.get(k, false)
	_keys_was[k] = now
	return now and not was


func _poll() -> void:
	if _tapped(KEY_E) or _tapped(KEY_J) or _tapped(KEY_ENTER):
		act_use()
		return
	if _tapped(KEY_ESCAPE):
		panel = {}
	var d := Vector2i(int(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		int(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - int(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)))
	if d != Vector2i.ZERO:
		act_move(d)


func _draw_hud() -> void:
	var h := _hud
	UI.panel(h, Rect2(6, 6, 330, 54))
	UI.text(h, Vector2(28, 43), String(room()["name"]), 26, UI.EDGE_LIGHT)
	UI.text(h, Vector2(946, 562), "WASD walk   E use", 14, Color(UI.MUTED, 0.85), 194, HORIZONTAL_ALIGNMENT_RIGHT)
	UI.text(h, Vector2(946, 580), "The door leads back out", 14, Color(UI.MUTED, 0.85), 194, HORIZONTAL_ALIGNMENT_RIGHT)
	if not panel.is_empty():
		var box := Rect2(196, 452, 760, 128)
		UI.panel(h, box, 0.95)
		UI.nameplate(h, box.position + Vector2(24, -22), String(panel["name"]))
		h.draw_multiline_string(UI.HEAD, box.position + Vector2(30, 50), String(panel["what"]), HORIZONTAL_ALIGNMENT_LEFT, 700, 18, 3, UI.TEXT)
		UI.next_arrow(h, box.end - Vector2(48, 36), Time.get_ticks_msec() / 1000.0)
