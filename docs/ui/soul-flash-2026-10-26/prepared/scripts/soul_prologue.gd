extends Node2D
## The first scene of the campaign (Claude, 2026-10-10). Preston: "start of game to be a human soul
## reincarnating into a new world which is Hollowtide as a creature, and an ultra powerful entity is
## talking to it out of camera while the soul, a ball of light, is floating perplexed and confused,
## before given the decision to choose creature to start as."
##
## Structure from Explorers of Sky's opening (a voice in the dark, the choice of who you will be, then
## waking as a creature with no memory), nothing copied: its own words, its own look. The void and the
## soul are drawn at the game's low resolution (384x216, three times up) like the prologue after it,
## so the light is pixel light. The presence never appears: its light spills in from the top edge and
## brightens while it speaks. The lines are Claude's draft for Preston to rewrite (LINES, AFTER).
##
## The choice shows the three starters with their big front idles (scripts/ui/creature_idle.gd). After
## it, the soul flies into the chosen one and Codex's prologue (scenes/creature_prologue.tscn) opens
## on waking beneath the riverbank as that creature, the starter already chosen.
##   Keys: J / Enter / Space next and choose; A D / arrows pick; mouse works on the cards.

const UI := preload("res://scripts/ui/ui_style.gd")
const CreatureIdle := preload("res://scripts/ui/creature_idle.gd")
const Music := preload("res://scripts/audio/music.gd")
const PROLOGUE := "res://scenes/creature_prologue.tscn"
const LOW := Vector2i(384, 216)
const FORMS := ["kithflare", "tallowroot", "rimefin"]
const NAMES := ["Kithflare", "Tallowroot", "Rimefin"]
const ESSENCES := [["EMBER", "ELECTRIC"], ["BLOOM", "LOAM"], ["TIDE", "MURK"]]
const FEEL := ["Quick and bright. A spark that wants to run.", "Patient and rooted. It holds when others fall.", "Cool and watchful. It strikes from below."]
# [line, mood]: "?" puts a question over the soul, "river" shows Hollowtide far below, "choose" opens the choice.
const LINES := [
	["...There you are.", "?"],
	["No, don't reach for anything. There is nothing here to hold. Not yet.", ""],
	["You lived a whole life somewhere else. Streets, names, a sky that stayed where it was put. It ended. How it ended is not mine to tell.", "?"],
	["This is Hollowtide.", "river"],
	["A river world, wide and old. Its banks are home to creatures of every kind, and beneath them lie the Hollows: places that take, and give nothing back.", ""],
	["Lately the river has been losing more than it should. Light. Paths. Each other.", ""],
	["It needs someone who knows what it is to be lost. That is you.", "?"],
	["So you will go down to it. Not as what you were, but as one of them.", ""],
	["Choose the shape you will wear.", "choose"],
]
const AFTER := [
	["{name}. Yes. That suits you.", ""],
	["When you wake you will remember almost none of this. That is how it should be.", ""],
	["Someone will find you on the riverbank. Trust them.", ""],
]

var reduce_motion := false
var auto := false          # the checks: advance by itself and pick auto_pick
var auto_pick := 1
var stage := "talk"        # talk, choose, after, fly, done
var line := 0
var shown := 0.0           # characters typed so far
var pick := 0
var chosen := -1
var _t := 0.0
var _speak := 0.0          # how bright the presence's light is
var _jitter := 0.0         # the soul's confused wobble
var _question := 0.0
var _river := 0.0
var _flash := 0.0
var _soul := Vector2(192, 92)
var _soul_scale := 1.0
var _motes: Array = []
var _void: Node2D
var _ui: Control
var _blip: AudioStreamPlayer
var _auto_wait := 0.0


func _ready() -> void:
	# Honor the title handoff and the saved preference when opening this scene directly.
	reduce_motion = reduce_motion or UI.reduce_motion()
	get_tree().root.content_scale_size = Vector2i(1152, 648)
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var vp := SubViewport.new()
	vp.size = LOW
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var display := Sprite2D.new()
	display.texture = vp.get_texture()
	display.centered = false
	display.scale = Vector2.ONE * 3
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(display)
	_void = Node2D.new()
	_void.draw.connect(_draw_void)
	vp.add_child(_void)
	var layer := CanvasLayer.new()
	add_child(layer)
	_ui = Control.new()
	_ui.size = Vector2(1152, 648)
	_ui.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui.draw.connect(_draw_ui)
	_ui.gui_input.connect(_on_click)
	layer.add_child(_ui)
	_blip = AudioStreamPlayer.new()
	_blip.stream = load("res://assets/audio/sfx/ui/text.wav")
	_blip.volume_db = -20.0
	_blip.bus = &"UI"   # the typed blip with the clicks (FEEL-08; Claude, 2026-10-22)
	add_child(_blip)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	for k in 70:
		_motes.append([Vector2(rng.randf() * LOW.x, rng.randf() * LOW.y), rng.randf_range(2.0, 7.0), rng.randf() * TAU, rng.randf_range(0.3, 1.0)])
	Music.play(get_tree(), "hollow_flute")
	_start_line()


func _current() -> Array:
	if stage in ["talk", "choose"]:
		return LINES[line]   # the choice keeps its question on screen
	return AFTER[line] if stage == "after" else ["", ""]


func _text() -> String:
	return String(_current()[0]).replace("{name}", NAMES[chosen] if chosen >= 0 else "")


func _start_line() -> void:
	shown = 0.0
	var mood: String = _current()[1]
	_jitter = 1.0 if mood == "?" else 0.4
	if mood == "?":
		_question = 2.2


func _process(delta: float) -> void:
	_t += delta
	var full := _text().length()
	if stage in ["talk", "after"]:
		shown = minf(full, shown + delta * (200.0 if reduce_motion else 46.0))
		_speak = move_toward(_speak, 1.0 if shown < full else 0.45, delta * 2.0)
		if String(_current()[1]) == "river":
			_river = move_toward(_river, 1.0, delta * 0.6)
	else:
		_speak = move_toward(_speak, 0.2, delta)
	_jitter = maxf(0.0, _jitter - delta * 0.8)
	_question = maxf(0.0, _question - delta)
	_flash = maxf(0.0, _flash - delta * 0.9)
	# The soul: floating, bobbing, unsure; over the creature it is considering when choosing.
	var home := Vector2(192, 92)
	if stage == "choose":
		home = Vector2(64 + pick * 128, 46)
	if stage != "fly":
		_soul = _soul.lerp(home, minf(1.0, delta * 3.0))
	if auto:
		_auto_wait += delta
		if _auto_wait > (0.9 if stage != "choose" else 1.2):
			_auto_wait = 0.0
			if stage == "choose" and pick != auto_pick:
				_move_pick(1 if auto_pick > pick else -1)
			else:
				advance()
	_void.queue_redraw()
	_ui.queue_redraw()


func advance() -> void:
	match stage:
		"talk", "after":
			# Finish the current shared dialogue page before moving to the next story line.
			if not UI.line_done(_text()):
				UI.finish_line()
				shown = _text().length()
				return
			if shown < _text().length():
				shown = _text().length()   # the first press finishes the line
				return
			line += 1
			if stage == "talk" and line < LINES.size():
				if String(LINES[line][1]) == "choose":
					stage = "choose"   # the last line is shown over the choice
					line = LINES.size() - 1
					shown = _text().length()
					return
				_start_line()
			elif stage == "after" and line < AFTER.size():
				_start_line()
			elif stage == "after":
				_fly()
		"choose":
			chosen = pick
			stage = "after"
			line = 0
			_start_line()


func _move_pick(step: int) -> void:
	pick = posmod(pick + step, 3)
	_blip.play()


func _fly() -> void:
	stage = "fly"
	var target := Vector2(64 + chosen * 128, 100)   # into the creature on its card
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "_soul", target, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "_soul_scale", 0.2, 0.9)
	await tw.finished
	_flash = 0.4 if reduce_motion else 1.6
	await get_tree().create_timer(0.7).timeout
	stage = "done"
	var next: Node = load(PROLOGUE).instantiate()
	next.reduce_motion = reduce_motion
	next.hero = chosen
	next.partner = (chosen + 1) % 3
	next.chosen_by_soul = true
	if is_inside_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_node(next)
	else:
		set_meta("handoff", next)   # the checks read it instead of leaving the scene


func _input(event: InputEvent) -> void:
	if auto or stage in ["fly", "done"] or not (event is InputEventKey or event is InputEventJoypadButton) or not event.is_pressed() or event.is_echo():
		return
	if stage == "choose" and (event.is_action_pressed("ui_left") or (event is InputEventKey and event.physical_keycode == KEY_A)):
		_move_pick(-1)
	elif stage == "choose" and (event.is_action_pressed("ui_right") or (event is InputEventKey and event.physical_keycode == KEY_D)):
		_move_pick(1)
	elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.physical_keycode in [KEY_J, KEY_SPACE, KEY_E]):
		advance()
	else:
		return
	get_viewport().set_input_as_handled()


func _card_rect(k: int) -> Rect2:
	return Rect2(66 + k * 348, 176 - (12 if k == pick else 0), 324, 312)


func _on_click(event: InputEvent) -> void:
	if auto or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if stage == "choose":
		for k in 3:
			if _card_rect(k).has_point(event.position):
				if k == pick:
					advance()
				else:
					pick = k
					_blip.play()
				return
	advance()


# ---------------------------------------------------------------- drawing

func _draw_void() -> void:
	var c := _void
	# The void: a deep indigo, darker toward the edges.
	for y in LOW.y:
		var k := float(y) / LOW.y
		c.draw_rect(Rect2(0, y, LOW.x, 1), Color(0.03 + 0.02 * k, 0.03 + 0.015 * k, 0.07 + 0.03 * (1.0 - absf(k - 0.4))))
	# Motes drifting up, slower the farther away they are.
	for m in _motes:
		var p: Vector2 = m[0]
		var y := fposmod(p.y - _t * m[1], LOW.y)
		var x := p.x + sin(_t * 0.4 + m[2]) * 3.0
		var a: float = m[3] * (0.35 + 0.25 * sin(_t * 1.5 + m[2]))
		c.draw_rect(Rect2(roundf(x), roundf(y), 1, 1), Color(0.75, 0.8, 1.0, a))
	# The presence, out of view above: shafts of warm light from the top edge, brighter as it speaks.
	if _speak > 0.0:
		for k in 5:
			var x0 := 120.0 + k * 36.0 + sin(_t * 0.3 + k) * 6.0
			var w := 18.0 + 6.0 * sin(_t * 0.7 + k * 1.3)
			var poly := PackedVector2Array([Vector2(x0, -2), Vector2(x0 + w, -2), Vector2(x0 + w * 2.4 - 40, 150), Vector2(x0 - 40, 150)])
			c.draw_colored_polygon(poly, Color(1.0, 0.92, 0.72, 0.05 * _speak))
		c.draw_rect(Rect2(0, 0, LOW.x, 3), Color(1.0, 0.94, 0.78, 0.35 * _speak))
	# Hollowtide, far below: the river shimmering into view.
	if _river > 0.0:
		for y in range(176, LOW.y):
			var k := float(y - 176) / 40.0
			for x in range(0, LOW.x, 2):
				var s := sin(x * 0.11 + _t * 1.6 + y * 0.7) * 0.5 + 0.5
				if s > 0.72:
					c.draw_rect(Rect2(x, y, 2, 1), Color(0.45, 0.85, 0.85, _river * (0.15 + 0.35 * k) * s))
	# The soul: a ball of light, bobbing; it wobbles when it does not understand.
	var bob := sin(_t * 1.3) * 3.0
	var wob := sin(_t * 31.0) * 2.2 * _jitter
	var tilt := Vector2(wob, bob - 2.0 * _speak) if stage != "fly" else Vector2.ZERO
	var at := (_soul + tilt).round()
	var pulse := 1.0 + 0.08 * sin(_t * 2.6)
	var sc := _soul_scale * pulse
	c.draw_circle(at, 26.0 * sc, Color(0.75, 0.85, 1.0, 0.06))
	c.draw_circle(at, 16.0 * sc, Color(0.85, 0.92, 1.0, 0.12))
	c.draw_circle(at, 9.0 * sc, Color(0.95, 0.97, 1.0, 0.45))
	c.draw_circle(at, 5.0 * sc, Color(1.0, 1.0, 1.0, 0.95))
	# A few sparks trail behind it.
	for k in 6:
		var a2 := _t * 0.9 + k * TAU / 6.0
		var r := (12.0 + 4.0 * sin(_t * 2.0 + k)) * _soul_scale
		c.draw_rect(Rect2((at + Vector2(cos(a2), sin(a2) * 0.6) * r).round(), Vector2(1, 1)), Color(1, 1, 1, 0.6))
	if _question > 0.0:
		UI.say(c, at + Vector2(10, -16), "?", "label", Color(1.0, 0.95, 0.8, minf(1.0, _question)))
	if _flash > 0.0:
		c.draw_rect(Rect2(Vector2.ZERO, LOW), Color(1, 1, 1, minf(1.0, _flash)))


func _draw_ui() -> void:
	var c := _ui
	if stage == "choose" or stage == "after" or stage == "fly":
		for k in 3:
			_draw_card(k)
	if stage in ["talk", "after", "choose"]:
		var box := Rect2(140, 498, 872, 122)
		# An unseen voice uses the same story role and two-row pages as the waking dialogue.
		UI.dialogue(c, box, "???", _text(), null, _t)
		if stage == "choose":
			UI.finish_line()   # the short choice prompt stays fully visible
			UI.say(c, box.position + Vector2(0, 108), "A / D  choose      J  this shape", "label", Color(UI.MUTED, 0.6 + 0.4 * sin(_t * 4.0)), box.size.x - 30, HORIZONTAL_ALIGNMENT_RIGHT)


var _shared_scale := 0.0

## The largest half-step scale at which every starter fits its card, shared by all three.
func _card_scale() -> float:
	if _shared_scale > 0.0:
		return _shared_scale
	var fit := 2.0
	for form in FORMS:
		var frames := CreatureIdle.frames(form)
		if frames.is_empty():
			continue
		var box := CreatureIdle.box(frames)
		fit = minf(fit, minf(146.0 / box.size.y, 246.0 / box.size.x))
	_shared_scale = floorf(clampf(fit, 0.5, 2.0) * 2.0) / 2.0
	return _shared_scale


func _draw_card(k: int) -> void:
	var c := _ui
	var r := _card_rect(k)
	var on := k == pick and stage == "choose" or k == chosen
	var fade := 1.0 if stage == "choose" or k == chosen else 0.35
	UI.panel(c, r, 0.95 if fade >= 1.0 else 0.7, on)
	var stage_r := Rect2(r.position + Vector2(22, 22), Vector2(r.size.x - 44, 180))
	c.draw_style_box(UI.frame("portrait"), stage_r)
	var frames := CreatureIdle.frames(FORMS[k])
	if not frames.is_empty():
		var box := CreatureIdle.box(frames)
		var s := _card_scale()   # one scale for all three, so they keep their true sizes (Preston, 2026-10-11: Kithflare looked bigger)
		var size := Vector2(box.size) * s
		var dest := Rect2(stage_r.position + Vector2((stage_r.size.x - size.x) * 0.5, stage_r.size.y - size.y - 18), size)
		var tex: Texture2D = CreatureIdle.frame_at(frames, _t if on else 0.0)
		c.draw_set_transform(Vector2(dest.position.x + dest.size.x, dest.position.y), 0.0, Vector2(-1, 1))   # turned to its right
		c.draw_texture_rect_region(tex, Rect2(Vector2.ZERO, dest.size), Rect2(box), Color(1, 1, 1, fade))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	UI.say(c, r.position + Vector2(28, 238), NAMES[k], "name", (UI.EDGE_LIGHT if on else UI.TEXT) * Color(1, 1, 1, fade))
	var ix: float = r.position.x + r.size.x - 28 - 30 * ESSENCES[k].size()
	for es in ESSENCES[k]:   # the main essence first, as on the party screen
		var icon := UI.essence_icon(es)
		if icon != null:
			c.draw_texture_rect(icon, Rect2(ix, r.position.y + 214, 28, 28), false, Color(1, 1, 1, fade))
		ix += 30
	c.draw_multiline_string(UI.font("body"), r.position + Vector2(28, 262), FEEL[k], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 56, UI.type_size("body"), 2, UI.MUTED * Color(1, 1, 1, fade))
