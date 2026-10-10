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
const CreatureIdle := preload("res://scripts/ui/creature_idle.gd")
const Music := preload("res://scripts/audio/music.gd")
const CENTER := Vector2(576, 300)
const HEIGHT := 250.0
const WHITE := """shader_type canvas_item;
uniform float white = 0.0;
#include "res://scripts/arena/sparkwick_palette.gdshaderinc"
void fragment() {
	vec4 c = sparkwick_colour(texture(TEXTURE, UV));
	COLOR = vec4(mix(c.rgb, vec3(1.0), white), c.a);
}"""

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
	s.flip_h = true   # turned to its right, like the headshots
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = WHITE
	mat.shader = sh
	mat.set_shader_parameter("sparkwick_palette", form == "sparkwick")
	s.material = mat
	s.position = CENTER
	s.region_enabled = true
	var frames := CreatureIdle.frames(form)
	var box := CreatureIdle.box(frames) if not frames.is_empty() else Rect2i()
	if frames.is_empty():
		var still: Texture2D = load("res://assets/sprites/arena/%s/sw.png" % form)
		frames = [still]
		box = still.get_image().get_used_rect()
	s.texture = frames[0]
	s.region_rect = Rect2(box)
	var k := floorf(clampf(HEIGHT / box.size.y, 0.5, 3.0) * 2.0) / 2.0
	s.scale = Vector2(k, k)
	s.set_meta("frames", frames)
	add_child(s)
	return s


func _white(s: Sprite2D, w: float) -> void:
	(s.material as ShaderMaterial).set_shader_parameter("white", w)


func _process(delta: float) -> void:
	_t += delta
	for s in [_old, _new]:
		if s != null and s.visible:
			var frames: Array = s.get_meta("frames")
			s.texture = CreatureIdle.frame_at(frames, _t)
	_flash = maxf(0.0, _flash - delta * 1.6)
	_back.queue_redraw()


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


func _sound(name: String, db: float) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load("res://assets/audio/sfx/dungeon/%s.wav" % name)
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
	_text = "%s evolved into %s!" % [old_name, new_name]
	_sub = "" if auto else "J  continue"
	await _wait(0.8)
	if auto:
		await _wait(1.0)
	else:
		var waited := 0.0
		while waited < 6.0 and not (Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_J) or Input.is_key_pressed(KEY_E)):
			await get_tree().process_frame
			waited += get_process_delta_time()
	stage = "done"
	var out := create_tween()
	out.tween_property(self, "_rays", 0.0, 0.3)
	await _wait(0.3)


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
		UI.text(c, box.position + Vector2(0, 76), _sub, 15, UI.MUTED, box.size.x - 20, HORIZONTAL_ALIGNMENT_RIGHT)
	if _flash > 0.0:
		c.draw_rect(Rect2(0, 0, 1152, 648), Color(1, 1, 1, _flash))
