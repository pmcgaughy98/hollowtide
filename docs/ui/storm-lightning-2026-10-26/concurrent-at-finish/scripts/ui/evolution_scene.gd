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
## The tallest the two stages may stand on screen (Claude, 2026-10-24, pass 5 T2: 380 so a pair of front idles is drawn
## at 2x, where 250 put Kithflare at 2x and Sparkwick at 1x; the box under them starts at 520).
const HEIGHT := 380.0
## The trade's quickest swap (Claude, 2026-10-26, ACC-01): 0.2 s apart is 2.5 light-dark flashes a second, under the
## three a second WCAG allows for an area this large. Under Reduce motion one cross-fade of CROSS_FADE replaces the
## trade, and the reveal's white goes to CALM_FLASH instead of full.
const SWAP_MIN := 0.2
const CROSS_FADE := 0.4
const CALM_FLASH := 0.35
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
## The light behind the creature (the column, the turning rays, the glow and the motes) is drawn at the world's own
## pixel size and shown at 3x, so every edge steps in whole UI pixels like the soul prologue's beams (Claude,
## 2026-10-24, L6-32: the rays were smooth polygons at screen size). Colours and timing are as they were.
const LOW := Vector2i(384, 216)
var _glow_vp: SubViewport
var _glow: Node2D
var stage := "intro"     # intro, whiten, trade, reveal, done (the checks read it)
## Both stages from one family of art at one whole scale (Claude, 2026-10-24, pass 5 T2 / LV-05). Each used to take its
## own: Kithflare's front idle at 2x turned into Sparkwick's at 1x, and the grown form stood smaller than the young one.
var family := ""         # "idle" (the front idles) or the STILLS pattern both were drawn from (the probes read it)
var scale_k := 1         # the one whole scale of both


func _ready() -> void:
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	_glow_vp = SubViewport.new()
	_glow_vp.name = "GlowLow"
	_glow_vp.size = LOW
	_glow_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_glow_vp)
	_glow = Node2D.new()
	_glow.draw.connect(_draw_glow)
	_glow_vp.add_child(_glow)
	_back = Control.new()
	_back.size = Vector2(1152, 648)
	_back.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_back.draw.connect(_draw_back)
	add_child(_back)


## The art both stages are drawn from: [family, old frames, old box, new frames, new box]. The front idles when both
## forms have one, else the first of STILLS both have; of those, the first in which the new form stands at least as
## tall as the old (Rimefin to Riftfin is shorter in the arena and dungeon stills, not in the small ones), else the
## first. Empty frames when a form has no art at all.
func _pick(old_form: String, new_form: String) -> Array:
	var options: Array = []
	var oi := CreatureIdle.frames(old_form)
	var ni := CreatureIdle.frames(new_form)
	if not oi.is_empty() and not ni.is_empty():
		options.append(["idle", oi, ni])
	for path in STILLS:
		if ResourceLoader.exists(path % old_form) and ResourceLoader.exists(path % new_form):
			options.append([path, [load(path % old_form)], [load(path % new_form)]])
	if options.is_empty():
		return ["", [], Rect2i(), [], Rect2i()]
	var pick: Array = options[0]
	for o in options:
		if CreatureIdle.box(o[2]).size.y >= CreatureIdle.box(o[1]).size.y:
			pick = o
			break
	return [pick[0], pick[1], CreatureIdle.box(pick[1]), pick[2], CreatureIdle.box(pick[2])]


func _sprite(form: String, frames: Array, box: Rect2i) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.position = CENTER
	s.texture = frames[0] if not frames.is_empty() else null
	# The whole frame is drawn (no region: the finish's outline texel needs the texture's own edges), shifted
	# so the drawn box sits on CENTER, on whole pixels.
	if s.texture != null:
		s.offset = (s.texture.get_size() * 0.5 - Vector2(box.get_center())).round()
	# The scene's one whole scale (run() sets it from the taller stage; 2026-10-22 UI-04, pass 5 T2); turned to its
	# right by a mirrored scale, not flip_h, so the finish's texel of room grows outward.
	var k := float(scale_k)
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
	_glow.queue_redraw()
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
	var pick := _pick(old_form, new_form)
	family = pick[0]
	scale_k = int(clampf(floorf(HEIGHT / maxi(1, maxi(pick[2].size.y, pick[4].size.y))), 1.0, 3.0))
	_old = _sprite(old_form, pick[1], pick[2])
	_new = _sprite(new_form, pick[3], pick[4])
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
	# Old and new trade places, faster and faster, never closer than SWAP_MIN (ACC-01: the gaps reached 0.058 s, eight
	# swaps of a 67,005 px2 silhouette in the last second). Under Reduce motion the two cross-fade once instead.
	stage = "trade"
	var calm := UI.reduce_motion()
	if calm:
		_new.modulate.a = 0.0
		_new.visible = true
		var x := create_tween().set_parallel(true)
		x.tween_property(_new, "modulate:a", 1.0, CROSS_FADE)
		x.tween_property(_old, "modulate:a", 0.0, CROSS_FADE)
		await _wait(CROSS_FADE)
	else:
		var gap := 0.42
		var showing_new := false
		var at_floor := 0
		while at_floor < 5:   # 0.42 s down to the floor, then five at it: nine swaps in about 2.3 s, ending on the new form
			showing_new = not showing_new
			_old.visible = not showing_new
			_new.visible = showing_new
			await _wait(gap)
			if gap <= SWAP_MIN:
				at_floor += 1
			gap = maxf(SWAP_MIN, gap * 0.82)
	# The flash, and the new form.
	stage = "reveal"
	_old.visible = false
	_old.modulate.a = 1.0
	_new.visible = true
	_new.modulate.a = 1.0
	_flash = CALM_FLASH if calm else 1.0
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
	# The light dies down while the caller takes the screen to black: it returns at once (pass 5 T1, so the black
	# starts on the press; it waited the 0.3 s at full light first).
	stage = "done"
	var out := create_tween()
	out.tween_property(self, "_rays", 0.0, 0.3)


## A "next" action down (UI.INPUT_ADVANCE: J, Space, E, Enter; A or X on a pad). Held, not tapped, as the old
## J and E reads were: a key still down from the shrine's question moves on at once (Claude, 2026-10-23).
func _advance_held() -> bool:
	for a in UI.INPUT_ADVANCE:
		if UI.held(a):
			return true
	return false


func _draw_back() -> void:
	var c := _back
	# The dark and the light behind the creature, from the low layer at 3x (_back draws with no smoothing).
	c.draw_texture_rect(_glow_vp.get_texture(), Rect2(0, 0, 1152, 648), false)
	# The words, in the game's panel, in the talk box's own face and size (TYPE "story"; Claude, 2026-10-26, pass 8 U3 for
	# L11: the old size 26 fell to the 19 px body face and read small in this box). A line too wide for the story face
	# steps down the FIT chain on its own. The words sit a little higher when the key line shares the box.
	var box := Rect2(236, 520, 680, 92)
	UI.panel(c, box, 0.95)
	var pad := 24.0
	UI.say(c, box.position + Vector2(pad, 50.0 if _sub != "" else 58.0), _text, "story", UI.EDGE_LIGHT, box.size.x - pad * 2.0, HORIZONTAL_ALIGNMENT_CENTER)
	if _sub != "":
		UI.text(c, box.position + Vector2(0, 80), "%s  %s" % [ControlsText.advance_text(), _sub], 15, UI.MUTED, box.size.x - 20, HORIZONTAL_ALIGNMENT_RIGHT)
	if _flash > 0.0:
		c.draw_rect(Rect2(0, 0, 1152, 648), Color(1, 1, 1, _flash))


## The low layer, in UI pixels (a third of the screen's): the dark, then the column of light and the turning rays,
## the glow round the creature and the motes, each the same shape, colour and pace as at screen size before.
func _draw_glow() -> void:
	var c := _glow
	var mid := CENTER / 3.0
	c.draw_rect(Rect2(Vector2.ZERO, Vector2(LOW)), Color(0.07, 0.09, 0.08))
	if _rays <= 0.0:
		return
	for k in 14:
		var a := _t * 0.25 + k * TAU / 14.0
		var tip := mid + Vector2(cos(a), sin(a)) * 300.0
		var side := Vector2(-sin(a), cos(a)) * 20.0
		c.draw_colored_polygon(PackedVector2Array([mid, tip + side, tip - side]), Color(UI.EVO, 0.07 * _rays))
	c.draw_rect(Rect2(mid.x - 30, 0, 60, LOW.y), Color(UI.PORTRAIT_BG, 0.08 * _rays))
	c.draw_circle(mid, 50.0, Color(UI.EVO, 0.10 * _rays))
	c.draw_circle(mid, 30.0, Color(1, 1, 1, 0.06 * _rays))
	# Motes rising through the light, one UI pixel each (they were 2 or 3 screen pixels at any position).
	for k in 26:
		var x := CENTER.x + sin(k * 12.9898) * 170.0
		var y := fposmod(560.0 - (_t * (30.0 + (k % 7) * 9.0) + k * 37.0), 520.0) + 40.0
		c.draw_rect(Rect2(floorf(x / 3.0), floorf(y / 3.0), 1, 1), Color(1, 1, 1, 0.5 * _rays))
