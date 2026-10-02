extends "res://scripts/main_menu.gd"
## Courier Lookout review composition with menu-only Retro Diffusion idles.
## The flat backdrop and original source artwork remain preserved.

const IDLE_ART := MENU_ART + "retro_diffusion_idle_2026_10_01/"
const IDLE_FRAME_SIZE := 80

var _previous_aspect: Window.ContentScaleAspect
var _idle_actors: Array[Sprite2D] = []

func _ready() -> void:
	# Keep the full 16:9 composition when the review window is resized.
	_previous_aspect = get_tree().root.content_scale_aspect
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	super._ready()

func _exit_tree() -> void:
	get_tree().root.content_scale_aspect = _previous_aspect

func _build_scenery() -> void:
	_layer("courier_lookout_dusk_candidate_576.png", 0)
	_star_layer = _dots(_draw_stars)
	# The base animation expects a window sprite. Keep the flat art steady.
	_windows = Sprite2D.new()
	add_child(_windows)

func _build_characters() -> void:
	_menu_idle("CourierMenuIdle", "courier_idle_contrast_atlas.png", Vector2(300, 424), 2.4, 0.0, 3.0)
	_menu_contact_shadow(Vector2(432, 448))
	_menu_idle("CinderhideMenuIdle", "cinderhide_idle_dusk_lit_atlas.png", Vector2(432, 448), 3.2, 0.8)

func _menu_contact_shadow(feet: Vector2) -> void:
	# Two quiet, pixel-aligned footprints anchor the creature to the bluff.
	var shadow := Node2D.new()
	shadow.name = "CinderhideContactShadow"
	shadow.position = feet.round()
	add_child(shadow)
	var outer := Polygon2D.new()
	outer.name = "AmbientFootprint"
	outer.polygon = PackedVector2Array([
		Vector2(-66, -12), Vector2(-42, -20), Vector2(42, -22),
		Vector2(66, -16), Vector2(64, -10), Vector2(40, -2),
		Vector2(-12, 4), Vector2(-52, 0), Vector2(-66, -6)])
	outer.color = Color(0.20, 0.15, 0.18, 0.12)
	outer.antialiased = false
	shadow.add_child(outer)
	var inner := Polygon2D.new()
	inner.name = "ContactFootprint"
	inner.polygon = PackedVector2Array([
		Vector2(-56, -10), Vector2(-34, -16), Vector2(40, -18),
		Vector2(54, -14), Vector2(40, -6), Vector2(0, 0),
		Vector2(-42, -2), Vector2(-56, -6)])
	inner.color = Color(0.20, 0.15, 0.18, 0.18)
	inner.antialiased = false
	shadow.add_child(inner)

func _menu_idle(actor_name: String, file: String, feet: Vector2, cycle: float, phase: float, pixel_scale: float = PX) -> void:
	var actor := Sprite2D.new()
	actor.name = actor_name
	actor.texture = load(IDLE_ART + file)
	actor.hframes = int(actor.texture.get_width() / float(IDLE_FRAME_SIZE))
	actor.centered = false
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actor.scale = Vector2.ONE * pixel_scale
	var first := actor.texture.get_image().get_region(Rect2i(0, 0, IDLE_FRAME_SIZE, IDLE_FRAME_SIZE))
	var used := first.get_used_rect()
	# One fixed anchor for the full loop keeps the sprites on the path.
	actor.position = (feet - Vector2(used.position.x + used.size.x * 0.5, used.end.y) * pixel_scale).round()
	actor.set_meta("cycle", cycle)
	actor.set_meta("phase", phase)
	add_child(actor)
	_idle_actors.append(actor)
	# Drawn frames already contain breathing; no second deformation shader.

func _process(delta: float) -> void:
	super._process(delta)
	if _reduce_motion:
		return
	# Share the menu clock so Reduce Motion freezes every actor immediately.
	for actor in _idle_actors:
		var cycle: float = actor.get_meta("cycle")
		var phase: float = actor.get_meta("phase")
		actor.frame = int(floor(fposmod(_time + phase, cycle) / cycle * actor.hframes))

