extends Node2D
## The hub town blockout (Claude, 2026-10-09). The layout is scripts/town/town_layout.gd; this scene
## walks it. Codex fills the art: everything drawn here is a plain block standing in for a building,
## a lane, a cliff or the river (see docs/world/hub-layout-2026-10-09/README.md). The team walks
## tile by tile at the dungeon's scale, E or J uses the place in front of or under the leader, and
## the Mouth of the Hollow starts a dungeon run with the same team.

const Layout := preload("res://scripts/town/town_layout.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const RETURN_SPOT := Vector2i(24, 8)   # back from a run: on the Hall's steps (the guild, as in Explorers of Sky)
const FONT := preload("res://assets/fonts/Silkscreen-Bold.ttf")
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
	for k in party.size():
		var pos: Vector2i = at + Vector2i(0, k) if news != "" else (at + Vector2i(-k, 0) if k < 2 else at + Vector2i(1, 0))
		if not open_at(pos):
			pos = at
		team.append(_make(party[k][0], party[k][1], pos))
	if news == "cleared":
		panel = {"name": "Back in Highbank", "what": "The Hollow is cleared. The bag and the new partners came home. (Cleared %d.)" % cleared, "service": "news"}
	elif news == "fainted":
		panel = {"name": "Back in Highbank", "what": "The team was carried back from the Hollow. The bag was lost; the partners are resting.", "service": "news"}


## The stand-in picture: terrain bands, cliffs, the river, lanes, then each place as a block. Codex
## replaces this with art drawn to the same rects.
static func paint() -> Image:
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
	for f in Arena.FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/%s/%s.png" % [form, set, f])
	var e := {"line": line, "stage": stage, "form": form, "pos": pos, "node": node, "sprite": sprite, "still": still, "facing": "s"}
	_place(e)
	return e


func _px(t: Vector2i) -> Vector2:
	return Vector2(t) * T + Vector2(T * 0.5, T * 0.78)


func _place(e: Dictionary) -> void:
	e["node"].position = _px(e["pos"])
	e["sprite"].texture = e["still"][e["facing"]]
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
		e["sprite"].texture = e["still"][e["facing"]]
		create_tween().tween_property(e["node"], "position", _px(e["pos"]), STEP_TIME)
	await get_tree().create_timer(STEP_TIME).timeout
	for e in team:
		_place(e)
	busy = false
	if Layout.place_at(lead["pos"]).get("service", "") == "dungeon":
		act_use()


## Use the place the leader stands on or faces: show what it is; the Mouth of the Hollow starts a run.
func act_use() -> Dictionary:
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
	panel = p
	return p


func enter_hollow() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	if TeamState.data.is_empty():
		TeamState.start(party)
	TeamState.data["party"] = party.duplicate(true)
	TeamState.give_to(dg)
	dg.return_to_town = true
	if is_inside_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_node(dg)
	else:
		set_meta("entered", true)   # the checks read this instead of leaving the scene
		dg.free()


func _process(_delta: float) -> void:
	if poll_input and not busy:
		_poll()
	if not team.is_empty():
		var half := Vector2(VIEW) * 0.5
		var focus: Vector2 = (team[0]["node"].position + Vector2(0, -12)).clamp(half, Vector2(Layout.W, Layout.H) * T - half)
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
	if _tapped(KEY_E) or _tapped(KEY_J) or _tapped(KEY_ENTER):
		act_use()
		return
	if _tapped(KEY_ESCAPE):
		panel = {}
	var d := Vector2i(int(_key(KEY_D) or _key(KEY_RIGHT)) - int(_key(KEY_A) or _key(KEY_LEFT)), int(_key(KEY_S) or _key(KEY_DOWN)) - int(_key(KEY_W) or _key(KEY_UP)))
	if d != Vector2i.ZERO:
		act_move(d)


func _draw_labels() -> void:
	for p in Layout.PLACES:
		var r: Rect2i = p["rect"]
		var at := Vector2(r.position.x * T, r.position.y * T + (r.size.y * T) * 0.5)
		_labels.draw_string(FONT, at.round() + Vector2(2, 0), String(p["name"]).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, r.size.x * T - 4, 8, Color(1, 1, 1, 0.9))


func _draw_hud() -> void:
	_hud.draw_string(FONT, Vector2(16, 24), "HIGHBANK (BLOCKOUT)   WASD WALK   E USE   THE MOUTH OF THE HOLLOW STARTS A RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.8))
	if not panel.is_empty():
		var box := Rect2(196, 470, 760, 110)
		_hud.draw_rect(box, Color(0.05, 0.07, 0.1, 0.94))
		_hud.draw_rect(box, Color(1, 0.85, 0.4), false, 2.0)
		_hud.draw_string(FONT, box.position + Vector2(18, 28), String(panel["name"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 724, 13, Color(1, 0.85, 0.4))
		_hud.draw_string(FONT, box.position + Vector2(18, 56), panel["what"], HORIZONTAL_ALIGNMENT_LEFT, 724, 11, Color(1, 1, 1))
		_hud.draw_string(FONT, box.position + Vector2(18, 90), "(BLOCKOUT: CODEX DRAWS THIS PLACE; ITS SERVICE IS \"%s\")   E CLOSE" % String(panel["service"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 724, 9, Color(1, 1, 1, 0.5))
