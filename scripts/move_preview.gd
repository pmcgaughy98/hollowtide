extends Node2D
## Matchup picker (Preston, 2026-10-07; rebuilt 2026-10-09 when he found it broken): the test
## scene for arena matchups. One screen: pick the team size, fill every slot on both sides from
## the grid of every form, choose who you steer, your charm, the arena and rocks, then FIGHT.
## The arena (scenes/arena_prototype.tscn) runs the match; Escape comes back here. Running the
## arena scene on its own opens this picker instead of a default fight.
##
## This replaced the Ember move preview (a nine-form mirror battle in the turn-based screen)
## on 2026-10-07; that screen is reference only now.

const Arena = preload("res://scripts/arena/arena_prototype.gd")
const ARENA_SCENE = preload("res://scenes/arena_prototype.tscn")
const FONT = preload("res://assets/fonts/Silkscreen-Bold.ttf")

var _size := 1                     # creatures a side
var _teams := [[null, null, null], [null, null, null]]   # [line, stage] per slot, null = empty
var _active := [0, 0]              # [side, slot] the next grid click fills
var _control := 0                  # which of yours you steer
var _charm := ""                   # your creature's charm ("" = its role's default)
var _map := 0
var _rocks := true
var _ui: Control
var _arena: Node2D


func _ready() -> void:
	_build()


func _build() -> void:
	if _ui:
		_ui.queue_free()
	_ui = Control.new()
	_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_ui)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.06, 0.07, 0.1)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui.add_child(backdrop)
	_label("HOLLOWTIDE  /  ARENA MATCHUPS", Vector2(40, 22), 22, Color("#F0F4F8"))
	# Row 1: team size, arena, rocks.
	_label("A SIDE", Vector2(40, 64), 11, Color(1, 1, 1, 0.6))
	for n in [1, 2, 3]:
		var b := _button("%d v %d" % [n, n], Vector2(40 + (n - 1) * 92, 80), Vector2(84, 34))
		if _size == n:
			b.modulate = Color(1.0, 0.85, 0.6)
		b.pressed.connect(func() -> void:
			_size = n
			_control = mini(_control, n - 1)
			_active = [0, 0]
			_build())
	_label("ARENA", Vector2(340, 64), 11, Color(1, 1, 1, 0.6))
	for k in ["GRASS", "STONE"]:
		var idx: int = 0 if k == "GRASS" else 1
		var b := _button(k, Vector2(340 + idx * 92, 80), Vector2(84, 34))
		if _map == idx:
			b.modulate = Color(1.0, 0.85, 0.6)
		b.pressed.connect(func() -> void:
			_map = idx
			_build())
	_label("ROCKS", Vector2(548, 64), 11, Color(1, 1, 1, 0.6))
	var rb := _button("ON" if _rocks else "OFF", Vector2(548, 80), Vector2(84, 34))
	rb.pressed.connect(func() -> void:
		_rocks = not _rocks
		_build())
	var rnd := _button("FILL RANDOM", Vector2(660, 80), Vector2(150, 34))
	rnd.pressed.connect(func() -> void:
		_fill_random()
		_build())
	var dungeon := _button("DUNGEON", Vector2(920, 40), Vector2(150, 34))
	dungeon.tooltip_text = "The turn-based Hollow with your side as the team (the first one leads)"   # the house word, never the genre label (Claude, 2026-10-22, GS-09)
	dungeon.pressed.connect(start_dungeon)
	var hollow := _button("HOLLOW", Vector2(920, 80), Vector2(150, 34))
	hollow.tooltip_text = "Explore a generated Hollow floor with your side as the team (the first one leads)"
	hollow.pressed.connect(start_hollow)
	var clr := _button("CLEAR", Vector2(820, 80), Vector2(90, 34))
	clr.pressed.connect(func() -> void:
		_teams = [[null, null, null], [null, null, null]]
		_active = [0, 0]
		_build())
	# Row 2: the slots. Click a slot to make it the one the grid fills.
	for side in 2:
		var y := 130.0 + side * 46.0
		_label("YOU" if side == 0 else "ENEMY", Vector2(40, y + 8), 13, Color("#ffb347") if side == 0 else Color("#ff6a5a"))
		for slot in _size:
			var pick = _teams[side][slot]
			var text: String = _form_name(pick).to_upper() if pick != null else "(EMPTY)"
			var b := _button(text, Vector2(120 + slot * 206, y), Vector2(196, 36))
			if pick != null:
				b.icon = load("res://assets/sprites/arena/%s/small/s.png" % Arena.LINES[pick[0]]["forms"][pick[1]][0])
				b.expand_icon = true
				b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			if _active[0] == side and _active[1] == slot:
				b.modulate = Color(1.0, 0.85, 0.6)
			b.pressed.connect(func() -> void:
				_active = [side, slot]
				_build())
	_label("CLICK A SLOT, THEN A CREATURE BELOW TO FILL IT", Vector2(760, 138), 10, Color(1, 1, 1, 0.5))
	# The grid: every line as a column, every stage as a row.
	var grid := GridContainer.new()
	grid.columns = Arena.LINES.size()
	grid.position = Vector2(40, 226)
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 5)
	_ui.add_child(grid)
	for stage in 3:
		for line in Arena.LINES.size():
			var form: Array = Arena.LINES[line]["forms"][stage]
			var data: CreatureData = load(form[1])
			var kit: Dictionary = Arena.KITS.get(form[0], {})
			var b := Button.new()
			b.custom_minimum_size = Vector2(104, 90)   # ten lines across a 1152 px window (2026-10-09)
			b.text = String(data.creature_name).to_upper() + ("\n" + String(kit["role"]).to_upper() if kit.has("role") else "")
			b.add_theme_font_override("font", FONT)
			b.add_theme_font_size_override("font_size", 8)
			b.icon = load("res://assets/sprites/arena/%s/small/s.png" % form[0])
			b.expand_icon = true
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			b.pressed.connect(_pick.bind(line, stage))
			grid.add_child(b)
	# Row 4: who you steer, your charm, fight.
	var y4 := 520.0
	if _size > 1:
		_label("YOU STEER", Vector2(40, y4 + 8), 11, Color(1, 1, 1, 0.6))
		for slot in _size:
			var pick = _teams[0][slot]
			var b := _button(_form_name(pick).to_upper() if pick != null else "SLOT %d" % (slot + 1), Vector2(130 + slot * 200, y4), Vector2(190, 34))
			if _control == slot:
				b.modulate = Color(1.0, 0.85, 0.6)
			b.pressed.connect(func() -> void:
				_control = slot
				_build())
	_label("YOUR CHARM", Vector2(40, y4 + 50), 11, Color(1, 1, 1, 0.6))
	var ck := 0
	for key in Arena.CHARMS:
		var b := _button(String(Arena.CHARMS[key]["name"]).to_upper(), Vector2(150 + ck * 86, y4 + 42), Vector2(80, 34))
		b.add_theme_font_size_override("font_size", 10)
		b.tooltip_text = Arena.CHARMS[key]["what"]
		if _charm == key:
			b.modulate = Color(1.0, 0.85, 0.6)
		b.pressed.connect(func() -> void:
			_charm = "" if _charm == key else key
			_build())
		ck += 1
	var hint: String = Arena.CHARMS[_charm]["what"] if _charm != "" else "none picked: your creature carries its role's charm"
	_label(hint, Vector2(150, y4 + 84), 10, Color(1, 1, 1, 0.6))
	var fight := _button("FIGHT", Vector2(870, y4), Vector2(240, 76))
	fight.add_theme_font_size_override("font_size", 26)
	fight.modulate = Color("#ffb347")
	fight.pressed.connect(start_fight)
	_label("WASD move  MOUSE aim  J or left click attack  RIGHT CLICK lock  SPACE dash  1 2 3 abilities  4 ultimate  C charm  Q/E target  TAB auto  ESC back", Vector2(40, 622), 10, Color(1, 1, 1, 0.5))


## A grid click fills the active slot and moves on to the next empty one.
func _pick(line: int, stage: int) -> void:
	_teams[_active[0]][_active[1]] = [line, stage]
	var found := false
	for side in 2:
		for slot in _size:
			if not found and _teams[side][slot] == null:
				_active = [side, slot]
				found = true
	if not found:
		_active = [_active[0], (_active[1] + 1) % _size] if _active[0] == 1 else [1, 0]
	_build()


func _fill_random() -> void:
	for side in 2:
		for slot in _size:
			if _teams[side][slot] == null:
				_teams[side][slot] = [randi() % Arena.LINES.size(), randi() % 3]


## Starts the arena with the chosen teams. Public so a test can call it. Empty slots are filled at random.
func start_fight() -> void:
	_fill_random()
	_ui.visible = false
	_arena = ARENA_SCENE.instantiate()
	var teams := [[], []]
	for side in 2:
		for slot in _size:
			teams[side].append(_teams[side][slot])
	_arena.teams_override = teams
	_arena._you = teams[0][0][0]
	_arena._you_stage = teams[0][0][1]
	_arena._rival = teams[1][0][0]
	_arena._rival_stage = teams[1][0][1]
	_arena.team_size = _size
	_arena.control_slot = _control
	_arena.charm_pick = _charm
	_arena.rocks_on = _rocks
	_arena.start_arena = _map
	add_child(_arena)


## The mystery-dungeon slice (2026-10-09, the pivot): turn-based floors with your side as the team.
func start_dungeon() -> void:
	_fill_random()
	_ui.visible = false
	_arena = load("res://scenes/dungeon.tscn").instantiate()
	var party := []
	for slot in _size:
		party.append(_teams[0][slot])
	_arena.party = party
	add_child(_arena)


## The first Hollow slice (2026-10-09): a generated dungeon floor with your side as the team.
## Empty slots are filled at random; the first slot leads and is the one you steer.
func start_hollow() -> void:
	_fill_random()
	_ui.visible = false
	_arena = load("res://scenes/hollow_floor.tscn").instantiate()
	var party := []
	for slot in _size:
		party.append(_teams[0][slot])
	_arena.party = party
	_arena.charm_pick = _charm
	add_child(_arena)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE and _arena:
		_arena.queue_free()
		_arena = null
		_ui.visible = true


func _form_name(pick) -> String:
	if pick == null:
		return ""
	var data: CreatureData = load(Arena.LINES[pick[0]]["forms"][pick[1]][1])
	return data.creature_name


func _label(text: String, at: Vector2, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = at
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	_ui.add_child(l)
	return l


func _button(text: String, at: Vector2, size: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.position = at
	b.custom_minimum_size = size
	b.add_theme_font_override("font", FONT)
	b.add_theme_font_size_override("font_size", 12)
	_ui.add_child(b)
	return b
