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
var stage := "talk"        # talk, choose, confirm, after, fly, done
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
var _presence: AudioStreamPlayer
var _choice_wait := 0.0
var _accept_released := true
var _answer := 1   # Yes / No: a fresh choice starts on No
var _auto_wait := 0.0
var _opening_fade := false
var _backdrop: SubViewport
var _background_area := Rect2(Vector2.ZERO, LOW)
var _previous_aspect: Window.ContentScaleAspect


func _ready() -> void:
	# Honor the title handoff and the saved preference when opening this scene directly.
	reduce_motion = reduce_motion or UI.reduce_motion()
	get_tree().root.content_scale_size = Vector2i(1152, 648)
	_previous_aspect = get_tree().root.content_scale_aspect
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	var vp := SubViewport.new()
	_backdrop = vp
	vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
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
	get_viewport().size_changed.connect(_fit_backdrop)
	_fit_backdrop()
	_presence = AudioStreamPlayer.new()
	_presence.stream = preload("res://assets/audio/sfx/dungeon/presence_swell.wav")
	_presence.volume_db = -14.0
	_presence.bus = &"UI"
	add_child(_presence)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	for k in 70:
		_motes.append([Vector2(rng.randf() * LOW.x, rng.randf() * LOW.y), rng.randf_range(2.0, 7.0), rng.randf() * TAU, rng.randf_range(0.3, 1.0)])
	Music.play(get_tree(), "hollow_flute")
	_start_line()
	if has_meta("opening_black"):
		_opening_fade = true
		_reveal_opening.call_deferred()


func _fit_backdrop() -> void:
	var size := get_viewport().get_visible_rect().size
	_backdrop.size = Vector2i(ceili(size.x / 3.0), ceili(size.y / 3.0))
	# Keep the authored composition centred on whole art pixels; the gradient fills the extra space.
	_void.position = ((Vector2(_backdrop.size) - Vector2(LOW)) * 0.5).floor()
	_ui.position = _void.position * 3.0
	_background_area = Rect2(-_void.position, Vector2(_backdrop.size))
	_void.queue_redraw()


func _exit_tree() -> void:
	var view := get_viewport()
	if view.size_changed.is_connected(_fit_backdrop): view.size_changed.disconnect(_fit_backdrop)
	# A destination added before this node is freed may already have chosen its own policy.
	if get_tree().root.content_scale_aspect == Window.CONTENT_SCALE_ASPECT_EXPAND:
		get_tree().root.content_scale_aspect = _previous_aspect


func _reveal_opening() -> void:
	var tree := get_tree()
	for frame in 2: await tree.process_frame
	if not is_inside_tree(): return
	await UI.fade_in(tree, 1.0 / 3.0)
	_opening_fade = false


func _current() -> Array:
	if stage == "confirm": return ["%s?" % NAMES[pick], ""]
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
	_choice_wait = maxf(0.0, _choice_wait - delta)
	if not _accept_down(): _accept_released = true
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
	if stage in ["choose", "confirm"]:
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
				if stage == "confirm": _answer = 0
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
					_choice_wait = 0.4
					_accept_released = false
					line = LINES.size() - 1
					shown = _text().length()
					return
				_start_line()
			elif stage == "after" and line < AFTER.size():
				_start_line()
			elif stage == "after":
				_fly()
		"choose":
			if not _choice_ready(): return
			stage = "confirm"
			_answer = 1
			_accept_released = false
			UI.tick("open")
		"confirm":
			if not _choice_ready(): return
			_accept_released = false
			if _answer == 1:
				_back_to_cards()
				return
			chosen = pick
			stage = "after"
			line = 0
			UI.tick("confirm")
			_presence.play()
			_start_line()


func _accept_down() -> bool:
	for action in UI.INPUT_ADVANCE:
		if Input.is_action_pressed(action): return true
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


func _choice_ready() -> bool:
	return _choice_wait <= 0.0 and _accept_released


func _back_to_cards() -> void:
	stage = "choose"
	_accept_released = false
	UI.tick("cancel")


func _move_pick(step: int) -> void:
	pick = posmod(pick + step, 3)
	UI.tick("cursor")


func _move_answer() -> void:
	_answer = 1 - _answer
	UI.tick("cursor")


func _fly() -> void:
	stage = "fly"
	var target := Vector2(64 + chosen * 128, 100)   # into the creature on its card
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "_soul", target, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "_soul_scale", 0.2, 0.9)
	await tw.finished
	_flash = 0.4 if reduce_motion else 1.6
	var tree := get_tree()
	var covered := is_inside_tree() and tree.current_scene == self
	if covered:
		for frame in 2: await tree.process_frame
		await UI.fade_out(tree, 1.0 / 3.0)
	else:
		await tree.create_timer(0.7).timeout   # preserve the non-scene check handoff
	stage = "done"
	var next: Node = load(PROLOGUE).instantiate()
	next.reduce_motion = reduce_motion
	next.hero = chosen
	next.partner = (chosen + 1) % 3
	next.chosen_by_soul = true
	if covered:
		# The flood scene already builds under its own opaque veil, then lifts it after the first draw.
		# Give that veil the black without stacking a second reveal over it.
		UI.fade_in(tree, 0.0)
		tree.change_scene_to_node(next)
	else:
		set_meta("handoff", next)   # the checks read it instead of leaving the scene


func _input(event: InputEvent) -> void:
	# UI.pressed ignores centre events; feed them to its shared edge tracker too.
	if event is InputEventJoypadMotion: UI._motion_edge(event)
	if not _accept_down(): _accept_released = true
	if auto or _opening_fade or stage in ["fly", "done"]: return
	if stage == "confirm" and UI.pressed(event, "cancel"):
		_back_to_cards()
	elif stage in ["choose", "confirm"] and UI.pressed(event, "move_left"):
		if stage == "choose": _move_pick(-1)
		else: _move_answer()
	elif stage in ["choose", "confirm"] and UI.pressed(event, "move_right"):
		if stage == "choose": _move_pick(1)
		else: _move_answer()
	else:
		var next := false
		for action in UI.INPUT_ADVANCE:
			if UI.pressed(event, action): next = true
		if not next: return
		if stage in ["choose", "confirm"]:
			advance()
			_accept_released = false   # even a press inside the opening guard needs releasing
		elif _accept_released:
			_accept_released = false
			advance()   # one event, even when J/A belongs to multiple advance actions
	get_viewport().set_input_as_handled()


func _card_rect(k: int) -> Rect2:
	return Rect2(66 + k * 348, 176 - (12 if k == pick else 0), 324, 312)


func _answer_rect(k: int) -> Rect2:
	return Rect2(676 + k * 144, 524, 124, 48)


func _on_click(event: InputEvent) -> void:
	if auto or _opening_fade or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT): return
	if stage == "confirm":
		if not _choice_ready():
			_accept_released = false
			return
		for k in 2:
			if _answer_rect(k).has_point(event.position):
				_answer = k
				advance()
				return
		return
	if stage == "choose":
		if not _choice_ready():
			_accept_released = false
			return
		for k in 3:
			if _card_rect(k).has_point(event.position):
				if k == pick: advance()
				else:
					pick = k
					UI.tick("cursor")
					_accept_released = false
				return
		return
	if _accept_released:
		_accept_released = false
		advance()


# ---------------------------------------------------------------- drawing

func _draw_void() -> void:
	var c := _void
	# The void: a deep indigo, darker toward the edges.
	for y in range(floori(_background_area.position.y), ceili(_background_area.end.y)):
		var k := (float(y) - _background_area.position.y) / _background_area.size.y
		c.draw_rect(Rect2(_background_area.position.x, y, _background_area.size.x, 1), Color(0.03 + 0.02 * k, 0.03 + 0.015 * k, 0.07 + 0.03 * (1.0 - absf(k - 0.4))))
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
			var poly := PackedVector2Array([Vector2(x0, _background_area.position.y - 2), Vector2(x0 + w, _background_area.position.y - 2), Vector2(x0 + w * 2.4 - 40, 150), Vector2(x0 - 40, 150)])
			var top := Color(1.0, 0.92, 0.72, 0.05 * _speak)
			var end := Color(top, 0.0)
			c.draw_polygon(poly, PackedColorArray([top, top, end, end]))
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
		c.draw_rect(_background_area, Color(1, 1, 1, minf(1.0, _flash)))


func _draw_ui() -> void:
	var c := _ui
	if stage in ["choose", "confirm", "after", "fly"]:
		for k in 3: _draw_card(k)
	var box := Rect2(140, 498, 872, 122)
	if stage in ["choose", "confirm"]:
		# Choices stay fully visible, independent of the shared story typewriter's last page.
		UI.panel(c, box, 0.95)
		UI.nameplate(c, box.position + Vector2(24, -22), "???")
		UI.say(c, box.position + Vector2(30, 56), _text(), "story", UI.TEXT)
		var hint := "%s / %s  choose      %s  review" % [UI.binding_text("move_left"), UI.binding_text("move_right"), UI.binding_text("confirm")]
		if stage == "confirm":
			for k in 2:
				var answer := _answer_rect(k)
				UI.panel(c, answer, 1.0, k == _answer)
				UI.say(c, answer.position + Vector2(0, 32), "Yes" if k == 0 else "No", "button", UI.EDGE_LIGHT if k == _answer else UI.TEXT, answer.size.x, HORIZONTAL_ALIGNMENT_CENTER)
			hint = "%s / %s  choose      %s  confirm      %s  back" % [UI.binding_text("move_left"), UI.binding_text("move_right"), UI.binding_text("confirm"), UI.binding_text("cancel")]
		UI.say(c, box.position + Vector2(30, 104), hint, "label", UI.TEXT, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
	elif stage in ["talk", "after"]:
		UI.dialogue(c, box, "???", _text(), null, _t)


var _shared_scale := 0.0

## One whole-pixel scale for the existing full-body showcase family, shared by all three.
func _card_scale() -> float:
	if _shared_scale > 0.0:
		return _shared_scale
	var fit := 2.0
	for form in FORMS:
		var frames := CreatureIdle.frames(form)
		if frames.is_empty():
			continue
		var box := CreatureIdle.box(frames)
		fit = minf(fit, minf(156.0 / box.size.y, 256.0 / box.size.x))
	_shared_scale = maxf(1.0, floorf(fit))
	return _shared_scale


func _draw_card(k: int) -> void:
	var c := _ui
	var r := _card_rect(k)
	var on := k == pick and stage in ["choose", "confirm"] or k == chosen
	var fade := 1.0 if stage in ["choose", "confirm"] or k == chosen else 0.35
	UI.panel(c, r, 0.95 if fade >= 1.0 else 0.7, on)
	var stage_r := Rect2(r.position + Vector2(22, 22), Vector2(r.size.x - 44, 180))
	c.draw_style_box(UI.frame("portrait"), stage_r)
	# Main-essence colours from the dungeon's existing essence palette.
	var tint: Color = [Color(1, 0.55, 0.25), Color(0.5, 0.9, 0.4), Color(0.35, 0.75, 1)][k]
	c.draw_rect(stage_r.grow(-8), Color(tint, 0.12 * fade))
	var frames := CreatureIdle.frames(FORMS[k])
	if not frames.is_empty():
		var box := CreatureIdle.box(frames)
		var s := _card_scale()   # one scale for all three, so they keep their true sizes (Preston, 2026-10-11: Kithflare looked bigger)
		var size := Vector2(box.size) * s
		var dest := Rect2(stage_r.position + Vector2((stage_r.size.x - size.x) * 0.5, (stage_r.size.y - size.y) * 0.5), size)
		var tex: Texture2D = CreatureIdle.frame_at(frames, _t if on else 0.0)
		c.draw_set_transform(Vector2(dest.position.x + dest.size.x, dest.position.y), 0.0, Vector2(-1, 1))   # turned to its right
		c.draw_texture_rect_region(tex, Rect2(Vector2.ZERO, dest.size), Rect2(box), Color(1, 1, 1, fade))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	UI.say(c, r.position + Vector2(28, 248), NAMES[k], "title", (UI.EDGE_LIGHT if on else UI.TEXT) * Color(1, 1, 1, fade), r.size.x - 56)
	var ix: float = r.position.x + r.size.x - 28 - 30 * ESSENCES[k].size()
	for es in ESSENCES[k]:   # the main essence first, as on the party screen
		var icon := UI.essence_icon(es)
		if icon != null:
			c.draw_texture_rect(icon, Rect2(ix, r.position.y + 32, 24, 24), false, Color(1, 1, 1, fade))
		ix += 30
	c.draw_multiline_string(UI.font("body"), r.position + Vector2(28, 278), FEEL[k], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 56, UI.type_size("body"), 2, UI.MUTED * Color(1, 1, 1, fade))
