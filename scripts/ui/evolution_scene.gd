extends CanvasLayer
## The evolution scene at the Growth Shrine (Claude, 2026-10-10; Preston: "evolution scene", "in town").
## Structure from the hand-made ones, nothing copied: pokeemerald's evolution scene (the old form,
## then old and new as white silhouettes trading places faster and faster, a flash, the new form) and
## Explorers of Sky's evolutions in a column of light at its spring. Hollowtide's own pieces: the big
## front idles (scripts/ui/creature_idle.gd), the moss-and-brass panel, the purple of the evolve bar,
## and its own words.
##   var s := EvolutionScene.new(); add_child(s)
##   await s.run(old_form, new_form, old_name, new_name, auto)   # auto: no key needed to finish

const UI := preload("res://scripts/ui/ui_style.gd")
const ControlsText := preload("res://scripts/ui/controls_text.gd")
const CreatureIdle := preload("res://scripts/ui/creature_idle.gd")
const CreatureFinish := preload("res://scripts/arena/creature_finish.gd")
const Music := preload("res://scripts/audio/music.gd")
const CENTER := Vector2(576, 300)
const HEIGHT := 250.0
## The light the creature turns into (Claude, 2026-10-22, UI-04): a white layer over the finished sprite.
## The creature itself wears the house finish (CreatureFinish, with its sparkwick palette and outline);
## this layer is its silhouette, one texel wider so the outline goes white too, at `white` opacity.
## The texel of room is the finish's own (sel_out.gdshaderinc).
const WHITE := """shader_type canvas_item;
uniform float white = 0.0;
void vertex() {
	VERTEX += (UV * 2.0 - 1.0);
	UV = (UV * (1.0 / TEXTURE_PIXEL_SIZE + 2.0) - 1.0) * TEXTURE_PIXEL_SIZE;
}
float art(sampler2D tex, vec2 uv) {
	return texture(tex, uv).a * step(0.0, uv.x) * step(0.0, uv.y) * (1.0 - step(1.0, uv.x)) * (1.0 - step(1.0, uv.y));
}
void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	float a = max(art(TEXTURE, UV), max(max(art(TEXTURE, UV + vec2(0.0, px.y)), art(TEXTURE, UV - vec2(0.0, px.y))),
		max(art(TEXTURE, UV + vec2(px.x, 0.0)), art(TEXTURE, UV - vec2(px.x, 0.0)))));
	COLOR = vec4(1.0, 1.0, 1.0, step(0.5, a) * white);
}"""
## Where a form's still is looked for when it has no idle: the arena still, then the dungeon set's and the
## arena's small set's, all facing the same way (CR-07). A form with none of them shows nothing, without an error.
const STILLS := ["res://assets/sprites/arena/%s/sw.png", "res://assets/sprites/arena/%s/dungeon/sw.png", "res://assets/sprites/arena/%s/small/sw.png"]

var _t := 0.0
var _flash := 0.0
var _rays := 0.0          # how bright the column of light is
var _text := ""
var _sub := ""
var _old: Sprite2D
var _new: Sprite2D
var _old_frames: Array = []
var _new_frames: Array = []
var _back: Control
var stage := "intro"     # intro, whiten, trade, reveal, done (the checks read it)


func _ready() -> void:
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	_back = Control.new()
	_back.size = Vector2(1152, 648)
	_back.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_back.draw.connect(_draw_back)
	add_child(_back)


func _sprite(form: String) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.position = CENTER
	var frames := CreatureIdle.frames(form)
	var box := CreatureIdle.box(frames) if not frames.is_empty() else Rect2i()
	if frames.is_empty():
		var still := _still(form)
		frames = [still] if still != null else []
		box = still.get_image().get_used_rect() if still != null else Rect2i()
	s.texture = frames[0] if not frames.is_empty() else null
	# The whole frame is drawn (no region: the finish's outline texel needs the texture's own edges), shifted
	# so the drawn box sits on CENTER, on whole pixels.
	if s.texture != null:
		s.offset = (s.texture.get_size() * 0.5 - Vector2(box.get_center())).round()
	# A whole scale of at least 1 (Claude, 2026-10-22, UI-04); turned to its right by a mirrored scale, not
	# flip_h, so the finish's texel of room grows outward.
	var k := clampf(floorf(HEIGHT / maxi(1, box.size.y)), 1.0, 3.0)
	s.scale = Vector2(-k, k)
	CreatureFinish.apply(s, false, form)   # the house outline and palette, as every creature on screen (ART-07)
	var glow := Sprite2D.new()
	glow.name = "White"
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	glow.texture = s.texture
	glow.offset = s.offset
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = WHITE
	mat.shader = sh
	glow.material = mat
	s.add_child(glow)
	s.set_meta("frames", frames)
	s.set_meta("white", glow)
	add_child(s)
	return s


## The first still a form has, from STILLS, or null.
func _still(form: String) -> Texture2D:
	for path in STILLS:
		if ResourceLoader.exists(path % form):
			return load(path % form)
	return null


func _white(s: Sprite2D, w: float) -> void:
	((s.get_meta("white") as Sprite2D).material as ShaderMaterial).set_shader_parameter("white", w)


func _process(delta: float) -> void:
	_t += delta
	for s in [_old, _new]:
		if s != null and s.visible:
			var frames: Array = s.get_meta("frames")
			s.texture = CreatureIdle.frame_at(frames, _t)
			(s.get_meta("white") as Sprite2D).texture = s.texture
	_flash = maxf(0.0, _flash - delta * 1.6)
	_back.queue_redraw()


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


func _sound(name: String, db: float) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load("res://assets/audio/sfx/dungeon/%s.wav" % name)
	p.bus = &"SFX"
	p.volume_db = db
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


func run(old_form: String, new_form: String, old_name: String, new_name: String, auto := false) -> void:
	_old = _sprite(old_form)
	_new = _sprite(new_form)
	_new.visible = false
	# The old form glows in the shrine's light.
	stage = "intro"
	_text = "%s is glowing..." % old_name
	_sound("evolve_ready", -4.0)
	var tw := create_tween()
	tw.tween_property(self, "_rays", 1.0, 1.4)
	await _wait(1.4)
	# It turns to light.
	stage = "whiten"
	_text = "Something is changing in %s!" % old_name
	var w := create_tween()
	w.tween_method(func(v: float) -> void: _white(_old, v), 0.0, 1.0, 0.8)
	await _wait(0.9)
	_white(_new, 1.0)
	# Old and new trade places, faster and faster.
	stage = "trade"
	var gap := 0.42
	var showing_new := false
	while gap > 0.05:
		showing_new = not showing_new
		_old.visible = not showing_new
		_new.visible = showing_new
		await _wait(gap)
		gap *= 0.82
	# The flash, and the new form.
	stage = "reveal"
	_old.visible = false
	_new.visible = true
	_flash = 1.0
	_sound("revive", -2.0)
	Music.jingle(get_tree(), "evolution")
	var r := create_tween()
	r.tween_method(func(v: float) -> void: _white(_new, v), 1.0, 0.0, 0.7)
	_text = "%s has grown into %s!" % [old_name, new_name]
	# The town's key first, in the house column style (Claude, 2026-10-22, W12); J and Enter still answer.
	# The key is the device's in use, drawn each frame: E, or A on a pad (Claude, 2026-10-23).
	_sub = "" if auto else "continue"
	await _wait(0.8)
	if auto:
		await _wait(1.0)
	else:
		var waited := 0.0
		while waited < 6.0 and not (Input.is_action_just_pressed("ui_accept") or _advance_held()):
			await get_tree().process_frame
			waited += get_process_delta_time()
	stage = "done"
	var out := create_tween()
	out.tween_property(self, "_rays", 0.0, 0.3)
	await _wait(0.3)


## A "next" action down (UI.INPUT_ADVANCE: J, Space, E, Enter; A or X on a pad). Held, not tapped, as the old
## J and E reads were: a key still down from the shrine's question moves on at once (Claude, 2026-10-23).
func _advance_held() -> bool:
	for a in UI.INPUT_ADVANCE:
		if UI.held(a):
			return true
	return false


func _draw_back() -> void:
	var c := _back
	c.draw_rect(Rect2(0, 0, 1152, 648), Color(0.07, 0.09, 0.08))
	# The column of light and the turning rays behind the creature.
	if _rays > 0.0:
		for k in 14:
			var a := _t * 0.25 + k * TAU / 14.0
			var tip := CENTER + Vector2(cos(a), sin(a)) * 900.0
			var side := Vector2(-sin(a), cos(a)) * 60.0
			c.draw_colored_polygon(PackedVector2Array([CENTER, tip + side, tip - side]), Color(UI.EVO, 0.07 * _rays))
		c.draw_rect(Rect2(CENTER.x - 90, 0, 180, 648), Color(UI.PORTRAIT_BG, 0.08 * _rays))
		c.draw_circle(CENTER, 150.0, Color(UI.EVO, 0.10 * _rays))
		c.draw_circle(CENTER, 90.0, Color(1, 1, 1, 0.06 * _rays))
		# Motes rising through the light.
		for k in 26:
			var x := CENTER.x + sin(k * 12.9898) * 170.0
			var y := fposmod(560.0 - (_t * (30.0 + (k % 7) * 9.0) + k * 37.0), 520.0) + 40.0
			c.draw_rect(Rect2(roundf(x), roundf(y), 2 + k % 2, 2 + k % 2), Color(1, 1, 1, 0.5 * _rays))
	# The words, in the game's panel.
	var box := Rect2(236, 520, 680, 92)
	UI.panel(c, box, 0.95)
	UI.text(c, box.position + Vector2(0, 44), _text, 26, UI.EDGE_LIGHT, box.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	if _sub != "":
		UI.text(c, box.position + Vector2(0, 76), "%s  %s" % [ControlsText.advance_text(), _sub], 15, UI.MUTED, box.size.x - 20, HORIZONTAL_ALIGNMENT_RIGHT)
	if _flash > 0.0:
		c.draw_rect(Rect2(0, 0, 1152, 648), Color(1, 1, 1, _flash))
