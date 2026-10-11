extends Node2D
## The hub town blockout (Claude, 2026-10-09). The layout is scripts/town/town_layout.gd; this scene
## walks it. Codex fills the art: everything drawn here is a plain block standing in for a building,
## a lane, a cliff or the river (see docs/world/hub-layout-2026-10-09/README.md). The team walks
## tile by tile at the dungeon's scale, E or J uses the place in front of or under the leader, and
## the Mouth of the Hollow starts a dungeon run with the same team.

const Layout := preload("res://scripts/town/town_layout.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const Evolution := preload("res://scripts/town/evolution.gd")
const Jobs := preload("res://scripts/town/jobs.gd")
const Music := preload("res://scripts/audio/music.gd")
const RETURN_SPOT := Vector2i(24, 8)   # back from a run: on the Hall's steps (the guild, as in Explorers of Sky)
const FONT := preload("res://assets/fonts/Silkscreen-Bold.ttf")
const UI := preload("res://scripts/ui/ui_style.gd")   # the shared look (Claude, 2026-10-10)
const WALK_FPS := 12.0   # walk frames a second in town
const StoneScene := preload("res://scripts/dungeon/stone_scene.gd")
const T := Layout.T
const VIEW := Vector2i(384, 216)
const SCALE := 3.0
const STEP_TIME := 0.13
const DIRS := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]
const BLOCK := {"grass": Color("#6f8f4e"), "terrace": Color("#8a7f5a"), "cliff": Color("#5a4a3a"), "water": Color("#3f6f96"),
	"path": Color("#b49a6a"), "building": Color("#7a5a44"), "roof": Color("#9c4a3a"), "area": Color("#c9b98a"), "spot": Color("#e0c060")}

var party: Array = [[0, 0], [1, 0]]
var roster: Array = []
var cleared := 0
var poll_input := true
var grid := PackedByteArray()
var team: Array[Dictionary] = []          # {line, stage, form, pos, node, sprite, art, facing}
var panel := {}                           # the place being shown, or {}
var busy := false
var _view: SubViewport
var _world: Node2D
var _labels: Node2D
var _hud: Node2D
var _keys_was := {}
var _building_exteriors: Node2D


func _ready() -> void:
	grid = Layout.grid()
	_view = SubViewport.new()
	_view.size = VIEW
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(_view)
	var screen := Sprite2D.new()
	screen.texture = _view.get_texture()
	screen.centered = false
	screen.scale = Vector2.ONE * SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	_world = Node2D.new()
	_view.add_child(_world)
	var map := Sprite2D.new()
	map.centered = false
	map.texture = ImageTexture.create_from_image(paint())
	_world.add_child(map)
	if ResourceLoader.exists("res://scripts/town/building_exteriors.gd"):
		_building_exteriors = load("res://scripts/town/building_exteriors.gd").attach(_world, self)
	_labels = Node2D.new()
	_labels.z_index = 2000
	_labels.draw.connect(_draw_labels)
	_world.add_child(_labels)
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	var news: String = TeamState.data.get("news", "")
	TeamState.data.erase("news")
	var at: Vector2i = RETURN_SPOT if news != "" else Layout.SPAWN
	# Back out of a building's room: standing on its door, below it (Claude, 2026-10-10).
	var back: String = TeamState.data.get("arrive_at", "")
	TeamState.data.erase("arrive_at")
	for p in Layout.PLACES:
		if p["id"] == back:
			at = p["door"] + Vector2i(0, 1)
	for k in party.size():
		var pos: Vector2i = at + Vector2i(0, k) if news != "" else (at + Vector2i(-k, 0) if k < 2 else at + Vector2i(1, 0))
		if not open_at(pos):
			pos = at
		team.append(_make(party[k][0], party[k][1], pos))
	_music_update()
	preload("res://scripts/ui/game_pause_menu.gd").attach(self)
	if news == "cleared":
		panel = {"name": "Back in Highbank", "what": "The Hollow is cleared. The bag and the new partners came home. (Cleared %d.)" % cleared, "service": "news"}
		if stone_state() == "carried":
			panel["what"] = "Home from the Hollow with the %s from the Warden's pond. It hums near the Growth Shrine's empty socket." % StoneScene.STONE_NAME
	elif news == "fainted":
		panel = {"name": "Back in Highbank", "what": "The team was carried back from the Hollow. The bag was lost; the partners are resting.", "service": "news"}


## The stand-in picture: terrain bands, cliffs, the river, lanes, then each place as a block. Codex
## replaces this with art drawn to the same rects.
static func paint() -> Image:
	var blockout := paint_blockout()
	var ground := blockout
	if ResourceLoader.exists("res://scripts/town/highbank_ground_painter.gd"):
		ground = load("res://scripts/town/highbank_ground_painter.gd").paint(blockout)
	# The dungeons' treatment over Codex's ground, leaving Codex's places as they are (Claude, 2026-10-10).
	if ResourceLoader.exists("res://scripts/town/highbank_painter.gd"):
		ground = load("res://scripts/town/highbank_painter.gd").paint(ground)
	return ground


static func paint_blockout() -> Image:
	var img := Image.create(Layout.W * T, Layout.H * T, false, Image.FORMAT_RGBA8)
	for y in Layout.H:
		var kind: String = Layout.band_of(y)
		img.fill_rect(Rect2i(0, y * T, Layout.W * T, T), BLOCK[kind])
		if kind == "cliff":
			for x in Layout.W:
				img.fill_rect(Rect2i(x * T, y * T + T - 6, T, 6), BLOCK[kind].darkened(0.3))
	for r in Layout.PATHS:
		img.fill_rect(Rect2i(r.position * T, r.size * T), BLOCK["path"])
	for p in Layout.PLACES:
		var r: Rect2i = p["rect"]
		var px := Rect2i(r.position * T, r.size * T)
		match p["kind"]:
			"building":
				img.fill_rect(px, BLOCK["building"])
				img.fill_rect(Rect2i(px.position, Vector2i(px.size.x, px.size.y / 2)), BLOCK["roof"])
			"area":
				img.fill_rect(px.grow(-2), BLOCK["area"])
			"spot":
				img.fill_rect(px.grow(-4), BLOCK["spot"])
		var d: Vector2i = p["door"]
		img.fill_rect(Rect2i(d * T + Vector2i(6, 4), Vector2i(T - 12, T - 4)), Color("#2a1a12") if p["kind"] == "building" else Color(1, 0.95, 0.6))
	return img


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
	var walk := {}   # facing -> the walk cycle (the dungeon set's 8 frames), so the team walks, not slides
	for f in Arena.FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/%s/%s.png" % [form, set, f])
		var frames: Array = []
		for k in 8:
			var path := "res://assets/sprites/arena/%s/%s/walk_%s_f%d.png" % [form, set, f, k]
			if ResourceLoader.exists(path):
				frames.append(load(path))
		walk[f] = frames
	var e := {"line": line, "stage": stage, "form": form, "pos": pos, "node": node, "sprite": sprite, "still": still, "walk": walk,
		"facing": "s", "walk_t": 0.0, "walk_clock": 0.0}
	_place(e)
	return e


func _px(t: Vector2i) -> Vector2:
	return Vector2(t) * T + Vector2(T * 0.5, T * 0.78)


func _place(e: Dictionary) -> void:
	e["node"].position = _px(e["pos"])
	if e.get("walk_t", 0.0) <= 0.0:
		e["sprite"].texture = e["still"][e["facing"]]   # mid-walk it keeps the walk frame
	e["sprite"].position = Vector2(0, -e["sprite"].texture.get_size().y * 0.5 + 4)
	e["node"].z_index = int(e["node"].position.y)


func open_at(t: Vector2i) -> bool:
	return t.x >= 0 and t.y >= 0 and t.x < Layout.W and t.y < Layout.H and grid[t.y * Layout.W + t.x] == Layout.OPEN


func _facing_of(d: Vector2i) -> String:
	return Arena.FACINGS[DIRS.find(d)] if DIRS.has(d) else "s"


## One step for the leader; the partners follow in a chain, each to where the one ahead stood.
func act_move(d: Vector2i) -> void:
	if busy or not panel.is_empty():
		return
	var lead: Dictionary = team[0]
	lead["facing"] = _facing_of(d)
	var to: Vector2i = lead["pos"] + d
	if not open_at(to) or (d.x != 0 and d.y != 0 and (not open_at(lead["pos"] + Vector2i(d.x, 0)) or not open_at(lead["pos"] + Vector2i(0, d.y)))):
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
			e["walk_t"] = STEP_TIME + 0.06   # walk while it moves (a held key keeps the cycle going)
		else:
			e["sprite"].texture = e["still"][e["facing"]]
		create_tween().tween_property(e["node"], "position", _px(e["pos"]), STEP_TIME)
	await get_tree().create_timer(STEP_TIME).timeout
	for e in team:
		_place(e)
	busy = false
	_music_update()
	if Layout.place_at(lead["pos"]).get("service", "") == "dungeon":
		act_use()


## Use the place the leader stands on or faces: show what it is; the Mouth of the Hollow starts a run.
func act_use() -> Dictionary:
	if evolving_now:
		return {}
	if panel.get("service", "") == "evolve_ask":
		evolve_at_shrine(int(panel["k"]))
		return {}
	if panel.get("service", "") == "stone_ask":
		install_stone()
		return {}
	if panel.get("service", "") == "board":
		act_board_pick()
		return {}
	if not panel.is_empty():
		panel = {}
		return {}
	var lead: Dictionary = team[0]
	var p: Dictionary = Layout.place_at(lead["pos"])
	if p.is_empty():
		p = Layout.place_at(lead["pos"] + DIRS[Arena.FACINGS.find(lead["facing"])])
	if p.is_empty():
		return {}
	if p["service"] == "dungeon":
		enter_hollow()
		return p
	if p["service"] in ["home", "guild"]:
		enter_room("home" if p["service"] == "home" else "hall")
		return p
	panel = p
	if p["service"] == "growth":
		panel = _shrine_panel(p)
	if p["service"] == "jobs":
		panel = _board_panel(p)
		_sfx("board_paper")
	elif p["service"] in DOOR_SERVICES:
		_sfx("door")
	return p


## Places with a door (Claude, 2026-10-09): opening one plays the door; the job board rustles paper.
## Lookouts, the waymark and the landing are open air and stay quiet.
const DOOR_SERVICES := ["guild", "home", "shop", "storage", "scrolls", "arena", "growth"]
var last_sfx := ""


func _sfx(name: String) -> void:
	last_sfx = name
	var p := AudioStreamPlayer.new()
	p.stream = load("res://assets/audio/sfx/dungeon/%s.wav" % name)
	p.volume_db = -4.0
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


## The town's track by where the leader is: Highbank's theme on the bluff, the Hall's march around
## Wayline Hall, the ferry landing's quiet theme on the terraces below the cliff.
func music_track() -> String:
	var p: Vector2i = team[0]["pos"]
	if p.y >= 19:
		return "ferry_landing"
	if Rect2i(17, 0, 14, 9).has_point(p):
		return "wayline_hall"
	return "highbank"


func _music_update() -> void:
	if not team.is_empty():
		Music.play(get_tree(), music_track())


## The Growth Shrine (Claude, 2026-10-10; Preston: evolving happens "outside dungeon at a specific
## location"): it names who is ready and asks before anything changes; yes plays the evolution scene
## (scripts/ui/evolution_scene.gd) and applies it to the carried record (scripts/town/evolution.gd).
var evolving_now := false
var evolved_log: Array = []   # [old name, new name], for the checks


func _record() -> Dictionary:
	if TeamState.data.is_empty():
		TeamState.start(party)
	TeamState.data["party"] = party.duplicate(true)
	return TeamState.data


## The Job Board (scripts/town/jobs.gd): finished jobs are paid first, then the board lists the jobs
## the team carries and the open requests. W/S choose, E takes or puts back, Esc closes.
func _board_panel(p: Dictionary) -> Dictionary:
	var rec := _record()
	Jobs.refresh(rec)
	var paid := Jobs.pay(rec)
	return {"name": p["name"], "service": "board", "sel": 0, "paid": paid, "said": ""}


var _faces := {}


## A creature's 48 px headshot (tools/arena/build_portraits.py), loaded once.
func _face(form: String) -> Texture2D:
	if not _faces.has(form):
		var path := "res://assets/sprites/arena/%s/portrait.png" % form
		_faces[form] = load(path) if ResourceLoader.exists(path) else null
	return _faces[form]


func board_rows() -> Array:
	return Jobs.rows(_record())


func act_board_pick() -> void:
	var rows := board_rows()
	if rows.is_empty():
		return
	var k: int = clampi(int(panel.get("sel", 0)), 0, rows.size() - 1)
	panel["said"] = Jobs.toggle(_record(), rows[k])
	panel["paid"] = []
	_ui_sfx("confirm")


func act_board_move(dy: int) -> void:
	var n := board_rows().size()
	if n > 0:
		panel["sel"] = posmod(int(panel.get("sel", 0)) + dy, n)
		_ui_sfx("cursor")


func _ui_sfx(name: String) -> void:
	last_sfx = name
	var p := AudioStreamPlayer.new()
	p.stream = load("res://assets/audio/sfx/ui/%s.wav" % name)
	p.volume_db = -8.0
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


func _shrine_panel(p: Dictionary) -> Dictionary:
	# The shrine sleeps until the pond stone is set in it (the pilot's payoff, docs/design/pilot-story-2026-10-10.md).
	match stone_state():
		"":
			return {"name": p["name"], "what": "The shrine is dark. At its heart is a round socket, empty, worn smooth, as if something sat there once.", "service": "growth"}
		"carried":
			return {"name": p["name"], "what": "The %s grows warm as you near the empty socket. Set it in?" % StoneScene.STONE_NAME, "service": "stone_ask"}
	var ready := Evolution.ready_list(_record())
	if ready.is_empty():
		return {"name": p["name"], "what": "No one is ready to evolve yet. The Team page (P) shows what each creature still needs.", "service": "growth"}
	var k: int = ready[0]
	var name: String = load(Arena.LINES[party[k][0]]["forms"][party[k][1]][1]).creature_name
	return {"name": p["name"], "what": "%s is ready to evolve. Let it evolve here?      E  yes      Esc  not now" % name, "service": "evolve_ask", "k": k}


## The pilot's story state carried in the team record: the pond stone is "", "carried" or "installed".
func stone_state() -> String:
	return String(_record().get("story", {}).get("stone", ""))


var stone_fx := {}   # the stone on its way into the socket, and the wave of light when the shrine wakes
var shrine_view := false   # the camera looks at the shrine, above the text box, while the stone goes in


## The socket: the emblem at the heart of Codex's shrine art (assets/sprites/world/growth_shrine_2026_10_10).
func _socket_px() -> Vector2:
	var shrine: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "shrine")[0]
	return Vector2(shrine["rect"].position * T) + Vector2(72, 64)


## The stone leaves the leader, settles into the socket, and the shrine wakes in a ring of light.
func install_stone() -> void:
	evolving_now = true   # holds input like the evolution scene
	panel = {}
	shrine_view = true
	var from: Vector2 = team[0]["node"].position + Vector2(0, -30)
	var to := _socket_px()
	_sfx("presence_swell")
	var tw := create_tween()
	tw.tween_method(func(t: float) -> void: stone_fx["at"] = from.lerp(to, t) + Vector2(0, -24.0 * sin(t * PI)), 0.0, 1.0, 1.4).set_trans(Tween.TRANS_SINE)
	await tw.finished
	stone_fx.erase("at")
	_record()["story"] = _record().get("story", {})
	_record()["story"]["stone"] = "installed"
	_sfx("evolve_ready")
	stone_fx["wake_at"] = Time.get_ticks_msec()
	await get_tree().create_timer(1.6).timeout
	stone_fx.erase("wake_at")
	panel = {"name": "Growth Shrine", "what": "The stone settles into the socket, and the shrine wakes: light runs through its old stones. A creature that is ready can evolve here now.", "service": "growth_done"}
	evolving_now = false


## Over the town: the stone in its socket once set (a slow pulse, motes rising), the dark socket before,
## the stone in flight, and the ring of light as the shrine wakes.
func _draw_stone() -> void:
	var c := _labels
	var t := Time.get_ticks_msec() / 1000.0
	var sock := _socket_px()
	if stone_state() == "installed" and not stone_fx.has("at"):
		for k in 4:   # motes drifting up off it
			var ph := fmod(t * 0.5 + k / 4.0, 1.0)
			var p := (sock + Vector2(sin(k * 2.3 + t) * 6.0, -6.0 - ph * 26.0)).round()
			c.draw_rect(Rect2(p, Vector2(1, 1)), Color(0.75, 0.97, 0.94, 1.0 - ph))
		StoneScene.draw_stone(c, sock + Vector2(0, -4), t, 1.0)
	else:
		c.draw_set_transform(sock, 0.0, Vector2(1.0, 0.5))
		c.draw_circle(Vector2.ZERO, 6.0, Color("#2a2420"))
		c.draw_circle(Vector2(0, 1), 4.0, Color("#15110e"))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if stone_fx.has("at"):
		StoneScene.draw_stone(c, stone_fx["at"], t, 1.0)
	if stone_fx.has("wake_at"):
		var a: float = (Time.get_ticks_msec() - int(stone_fx["wake_at"])) / 1600.0
		c.draw_set_transform(sock, 0.0, Vector2(1.0, 0.55))
		c.draw_arc(Vector2.ZERO, 8.0 + a * 70.0, 0, TAU, 48, Color(0.75, 0.97, 0.94, 1.0 - a), 2.0)
		c.draw_arc(Vector2.ZERO, 4.0 + a * 46.0, 0, TAU, 40, Color(1, 1, 1, (1.0 - a) * 0.6), 1.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func evolve_at_shrine(k: int) -> void:
	evolving_now = true
	panel = {}
	var rec := _record()
	var ln: int = party[k][0]
	var st: int = party[k][1]
	var scene: CanvasLayer = load("res://scripts/ui/evolution_scene.gd").new()
	add_child(scene)
	await scene.run(Arena.LINES[ln]["forms"][st][0], Arena.LINES[ln]["forms"][st + 1][0],
		load(Arena.LINES[ln]["forms"][st][1]).creature_name, load(Arena.LINES[ln]["forms"][st + 1][1]).creature_name, not poll_input)
	scene.queue_free()
	var res := Evolution.evolve(rec, k)
	party = rec["party"].duplicate(true)
	evolved_log.append([res["old_name"], res["new_name"]])
	# Its sprite on the street becomes the new form.
	var old_e: Dictionary = team[k]
	team[k] = _make(ln, st + 1, old_e["pos"])
	team[k]["facing"] = old_e["facing"]
	_place(team[k])
	old_e["node"].queue_free()
	var notes: Array = []
	if not res["learned"].is_empty():
		notes.append("It learned %s." % ", ".join(res["learned"].map(func(m: String) -> String: return Arena.MOVES[m]["name"])))
	if not res["lost"].is_empty():
		notes.append("Its new body can't use %s." % ", ".join(res["lost"].map(func(m: String) -> String: return Arena.MOVES[m]["name"])))
	if not res["waiting"].is_empty():
		notes.append("%s will be offered on the next run." % ", ".join(res["waiting"].map(func(m: String) -> String: return Arena.MOVES[m]["name"])))
	panel = {"name": "Growth Shrine", "what": "%s evolved into %s! %s" % [res["old_name"], res["new_name"], " ".join(notes)], "service": "growth_done"}
	evolving_now = false


## Step inside the Home or the Wayline Hall: a room at the town's scale (scripts/town/town_room.gd).
func enter_room(id: String) -> void:
	_sfx("door")
	TeamState.data["party"] = party.duplicate(true)
	if is_inside_tree() and get_tree().current_scene == self:
		var room: Node = load("res://scenes/town_room.tscn").instantiate()
		room.room_id = id
		get_tree().change_scene_to_node(room)
	else:
		set_meta("entered_room", id)   # the checks read this instead of leaving the scene


func enter_hollow() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	if TeamState.data.is_empty():
		TeamState.start(party)
	TeamState.data["party"] = party.duplicate(true)
	TeamState.give_to(dg)
	# The next dungeon whose boss is not beaten (the town has one way down for now; Codex's layout
	# can give each its own entrance later).
	var beaten: Array = TeamState.data.get("beaten", [])
	dg.dungeon = "hollow" if "first" in beaten else "first"
	dg.return_to_town = true
	if is_inside_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_node(dg)
	else:
		set_meta("entered", true)   # the checks read this instead of leaving the scene
		dg.free()


func _process(_delta: float) -> void:
	if poll_input and not busy and not evolving_now:
		_poll()
	# The walk cycle (Claude, 2026-10-10; Preston: "they just hopped without animation").
	for e in team:
		if e["walk_t"] > 0.0:
			e["walk_t"] -= _delta
			e["walk_clock"] += _delta
			var frames: Array = e["walk"].get(e["facing"], [])
			if not frames.is_empty():
				e["sprite"].texture = frames[int(e["walk_clock"] * WALK_FPS) % frames.size()]
			if e["walk_t"] <= 0.0:
				e["sprite"].texture = e["still"][e["facing"]]
	if not team.is_empty():
		var half := Vector2(VIEW) * 0.5
		if shrine_view and not evolving_now and panel.is_empty():
			shrine_view = false   # back to following the leader once the shrine's line is closed
		var look: Vector2 = (_socket_px() + Vector2(0, 22)) if shrine_view else (team[0]["node"].position + Vector2(0, -12))
		var focus: Vector2 = look.clamp(half, Vector2(Layout.W, Layout.H) * T - half)
		_world.position = (half - focus).round()
	_labels.queue_redraw()
	_hud.queue_redraw()


func _key(k: int) -> bool:
	return Input.is_key_pressed(k)


func _tapped(k: int) -> bool:
	var now := Input.is_key_pressed(k)
	var was: bool = _keys_was.get(k, false)
	_keys_was[k] = now
	return now and not was


func _poll() -> void:
	if panel.get("service", "") == "board":
		if _tapped(KEY_W) or _tapped(KEY_UP):
			act_board_move(-1)
		if _tapped(KEY_S) or _tapped(KEY_DOWN):
			act_board_move(1)
	if _tapped(KEY_E) or _tapped(KEY_J) or _tapped(KEY_ENTER):
		act_use()
		return
	if _tapped(KEY_ESCAPE):
		panel = {}
	var d := Vector2i(int(_key(KEY_D) or _key(KEY_RIGHT)) - int(_key(KEY_A) or _key(KEY_LEFT)), int(_key(KEY_S) or _key(KEY_DOWN)) - int(_key(KEY_W) or _key(KEY_UP)))
	if d != Vector2i.ZERO:
		act_move(d)


func _draw_labels() -> void:
	_draw_stone()
	for p in Layout.PLACES:
		if is_instance_valid(_building_exteriors) and _building_exteriors.buildings.has(p["id"]):
			continue   # Finished entrances have their own sign / lantern; other plaques stay.
		var r: Rect2i = p["rect"]
		var at := Vector2(r.position.x * T, r.position.y * T + (r.size.y * T) * 0.5)
		# A small signboard: a dark plaque with a brass rim behind the name, so it reads on any ground.
		var name := String(p["name"]).to_upper()
		var w: float = FONT.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 10.0
		var mid: float = at.x + r.size.x * T * 0.5
		# Landing overlaps the finished Mouth; keep its temporary plaque at its own spot.
		if p["id"] == "landing" and is_instance_valid(_building_exteriors) and _building_exteriors.buildings.has("gate"):
			mid = p["door"].x * T + T * 0.5
			at.y = p["door"].y * T + 6
		var plaque := Rect2(Vector2(mid - w * 0.5, at.y - 9).round(), Vector2(w, 13).round())
		_labels.draw_rect(plaque, Color(UI.PANEL, 0.82))
		_labels.draw_rect(plaque, Color(UI.EDGE, 0.9), false, 1.0)
		_labels.draw_string(FONT, Vector2(plaque.position.x, at.y).round(), name, HORIZONTAL_ALIGNMENT_CENTER, plaque.size.x, 8, UI.TEXT)


func _draw_hud() -> void:
	# The shared look (scripts/ui/ui_style.gd), as in the Hollow: where you are at the top left, the
	# keys short at the bottom right, a place's sign in a panel at the bottom. Claude, 2026-10-10.
	var h := _hud
	UI.panel(h, Rect2(6, 6, 330, 54))
	UI.text(h, Vector2(28, 43), "Highbank", 26, UI.EDGE_LIGHT)
	var here: Dictionary = Layout.place_at(team[0]["pos"]) if not team.is_empty() else {}
	if not here.is_empty():
		UI.text(h, Vector2(28, 43), String(here["name"]), 16, UI.TEXT, 282, HORIZONTAL_ALIGNMENT_RIGHT)
	UI.text(h, Vector2(946, 562), "WASD walk   E use", 14, Color(UI.MUTED, 0.85), 194, HORIZONTAL_ALIGNMENT_RIGHT)
	UI.text(h, Vector2(946, 580), "The Hollow's mouth starts a run", 14, Color(UI.MUTED, 0.85), 194, HORIZONTAL_ALIGNMENT_RIGHT)
	if panel.get("service", "") == "board":
		_draw_board(h)
	elif not panel.is_empty():
		var box := Rect2(196, 452, 760, 128)
		UI.panel(h, box, 0.95)
		UI.text(h, box.position + Vector2(22, 34), String(panel["name"]), 23, UI.EDGE_LIGHT, 716)
		h.draw_multiline_string(UI.HEAD, box.position + Vector2(22, 64), String(panel["what"]), HORIZONTAL_ALIGNMENT_LEFT, 716, 18, 2, UI.TEXT)
		var hint := "E  evolve     Esc  not now" if panel.get("service", "") == "evolve_ask" else ("E  set it in     Esc  not now" if panel.get("service", "") == "stone_ask" else "E  close")
		UI.text(h, box.position + Vector2(22, 116), hint, 15, UI.MUTED, 716, HORIZONTAL_ALIGNMENT_RIGHT)


## The board, drawn the Explorers of Sky way: the rank at the top, one row per request with the
## client's headshot, where to go and what it pays; a brass TAKEN tab on the ones in the satchel.
func _draw_board(h: CanvasItem) -> void:
	var rec := _record()
	var rows := board_rows()
	var box := Rect2(166, 64, 820, 132 + 70 * maxi(1, rows.size()))
	UI.panel(h, box, 0.96)
	UI.nameplate(h, box.position + Vector2(28, -22), String(panel["name"]), 22)
	var rk: Array = Jobs.rank_of(int(rec.get("rank", 0)))
	var rank_s := "Courier Rank %d    %d points" % [rk[0], int(rec.get("rank", 0))] + ("" if rk[1] < 0 else "  (%d for the next)" % rk[1])
	UI.text(h, box.position + Vector2(30, 46), rank_s, 18, UI.EDGE_LIGHT)
	var carried: int = rec.get("jobs", []).size()
	UI.text(h, box.position + Vector2(30, 46), "Taken %d / %d" % [carried, Jobs.TAKE_MAX], 16, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
	var note := ""
	if not panel.get("paid", []).is_empty():
		note = "Paid: " + "   ".join(panel["paid"])
	elif String(panel.get("said", "")) != "":
		note = String(panel["said"])
	UI.text(h, box.position + Vector2(30, 74), note if note != "" else "Take a request, then go down to the Hollow. Reach the client on its floor.", 16, UI.TEXT if note != "" else UI.MUTED, box.size.x - 60)
	if rows.is_empty():
		UI.text(h, box.position + Vector2(30, 124), "No requests today.", 18, UI.MUTED)
	for k in rows.size():
		var j: Dictionary = rows[k]
		var r := Rect2(box.position + Vector2(24, 94 + k * 70), Vector2(box.size.x - 48, 62))
		var on: bool = k == int(panel.get("sel", 0))
		if on:
			h.draw_rect(r, UI.FOCUS)
			h.draw_rect(r, UI.EDGE_LIGHT, false, 2.0)
		var face_r := Rect2(r.position + Vector2(8, 7), Vector2(48, 48))
		h.draw_rect(face_r, UI.PORTRAIT_BG)
		var face := _face(Jobs.client_form(j))
		if face != null:
			h.draw_texture_rect(face, face_r, false)
		h.draw_rect(face_r, UI.EDGE, false, 1.0)
		var done: bool = j.get("done", false)
		UI.text(h, r.position + Vector2(70, 27), Jobs.title(j), 20, UI.EDGE_LIGHT if on else UI.TEXT, 340)
		UI.text(h, r.position + Vector2(70, 51), "B%dF   %s" % [int(j["floor"]), "done, paid on return" if done else ("lost there" if j["kind"] == "rescue" else "dropped there")], 15, UI.MUTED, 300)
		var icon := UI.item_icon(String(j["reward"]))
		if icon != null:
			h.draw_texture(icon, r.position + Vector2(420, 15))
		UI.text(h, r.position + Vector2(458, 37), "%s x%d   +%d" % [Jobs.item_name(j["reward"]), int(j["count"]), int(j["pts"])], 16, UI.TEXT, 180)
		if Jobs.is_taken(rec, j):
			UI.nameplate(h, r.position + Vector2(r.size.x - 112, 13), "Taken", 18)
	UI.text(h, box.end + Vector2(-box.size.x + 30, -22), "W/S choose     E take or put back     Esc close", 15, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
