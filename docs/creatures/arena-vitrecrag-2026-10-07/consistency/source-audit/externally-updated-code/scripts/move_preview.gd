extends Node2D
## Matchup picker (Preston, 2026-10-07): the test scene for viewing arena matchups. Three
## steps: choose your creature, choose the enemy, choose 1v1 or 3v3, then FIGHT. The arena
## (scenes/arena_prototype.tscn) runs the match; Escape comes back here.
##
## In a 3v3 your creature leads your team and the enemy leads theirs; the arena fills the other
## two slots on each side with the other lines at the same stage (its existing rule).
##
## This replaced the Ember move preview (a nine-form mirror battle in the turn-based screen)
## on 2026-10-07; that screen is reference only now.

const Arena = preload("res://scripts/arena/arena_prototype.gd")
const ARENA_SCENE = preload("res://scenes/arena_prototype.tscn")
const FONT = preload("res://assets/fonts/Silkscreen-Bold.ttf")

var _you := [-1, -1]      # [line, stage]
var _enemy := [-1, -1]
var _team_size := 1
var _step := 0            # 0 your creature, 1 the enemy, 2 the mode
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
	_label("HOLLOWTIDE  /  ARENA MATCHUPS", Vector2(48, 36), 26, Color("#F0F4F8"))
	var steps := ["1. YOUR CREATURE", "2. THE ENEMY", "3. MODE"]
	_label(steps[_step], Vector2(48, 84), 18, Color("#ffb347"))
	var picked := ""
	if _you[0] >= 0:
		picked += "YOU: " + _form_name(_you).to_upper()
	if _enemy[0] >= 0:
		picked += "     ENEMY: " + _form_name(_enemy).to_upper()
	_label(picked, Vector2(48, 112), 13, Color(1, 1, 1, 0.8))
	if _step < 2:
		_grid()
	else:
		_mode_buttons()
	if _step > 0:
		var back := _button("BACK", Vector2(48, 580), Vector2(140, 44))
		back.pressed.connect(func() -> void:
			_step -= 1
			_build())


## The twelve forms: one column per line, one row per stage, with the arena sprite as the icon.
func _grid() -> void:
	var grid := GridContainer.new()
	grid.columns = Arena.LINES.size()
	grid.position = Vector2(48, 140)
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	_ui.add_child(grid)
	for stage in 3:
		for line in Arena.LINES.size():
			var form: Array = Arena.LINES[line]["forms"][stage]
			var data: CreatureData = load(form[1])
			var kit: Dictionary = Arena.KITS.get(form[0], {})
			var b := Button.new()
			b.custom_minimum_size = Vector2(150, 136)
			b.text = String(data.creature_name).to_upper() + ("\n" + String(kit["role"]).to_upper() if kit.has("role") else "")
			b.add_theme_font_override("font", FONT)
			b.add_theme_font_size_override("font_size", 11)
			b.icon = load("res://assets/sprites/arena/%s/small/s.png" % form[0])
			b.expand_icon = true
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var chosen: Array = _you if _step == 0 else _enemy
			if chosen[0] == line and chosen[1] == stage:
				b.modulate = Color(1.0, 0.85, 0.6)
			b.pressed.connect(_pick.bind(line, stage))
			grid.add_child(b)


func _pick(line: int, stage: int) -> void:
	if _step == 0:
		_you = [line, stage]
	else:
		_enemy = [line, stage]
	_step += 1
	_build()


func _mode_buttons() -> void:
	_label("HOW MANY A SIDE?", Vector2(48, 170), 14, Color(1, 1, 1, 0.8))
	for opt in [[1, "1 v 1", Vector2(48, 200)], [3, "3 v 3", Vector2(268, 200)]]:
		var b := _button(opt[1], opt[2], Vector2(200, 90))
		b.add_theme_font_size_override("font_size", 24)
		if _team_size == opt[0]:
			b.modulate = Color(1.0, 0.85, 0.6)
		b.pressed.connect(func() -> void:
			_team_size = opt[0]
			_build())
	var fight := _button("FIGHT", Vector2(48, 320), Vector2(420, 70))
	fight.add_theme_font_size_override("font_size", 28)
	fight.modulate = Color("#ffb347")
	fight.pressed.connect(start_fight)
	_label("In the fight: LEFT/RIGHT pick the enemy your creature goes for, UP lets it choose, 1 2 3 fire its abilities, 4 the ultimate, ESC comes back here.", Vector2(48, 410), 12, Color(1, 1, 1, 0.7))


## Starts the arena with the chosen matchup. Public so a test can call it.
func start_fight() -> void:
	if _you[0] < 0 or _enemy[0] < 0:
		return
	_ui.visible = false
	_arena = ARENA_SCENE.instantiate()
	_arena._you = _you[0]
	_arena._you_stage = _you[1]
	_arena._rival = _enemy[0]
	_arena._rival_stage = _enemy[1]
	_arena.team_size = _team_size
	add_child(_arena)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE and _arena:
		_arena.queue_free()
		_arena = null
		_ui.visible = true


func _form_name(pick: Array) -> String:
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
	b.add_theme_font_size_override("font_size", 14)
	_ui.add_child(b)
	return b
