extends "res://scripts/main_menu.gd"
## Courier Lookout menu with Retro Diffusion walk-in and idle animation.
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
	var courier := _menu_idle("CourierMenuIdle", "courier_idle_contrast_atlas.png", Vector2(300, 424), 2.4, 0.0, 3.0)
	var shadow := _menu_contact_shadow(Vector2(432, 448))
	var cinderhide := _menu_idle("CinderhideMenuIdle", "cinderhide_idle_dusk_lit_atlas.png", Vector2(432, 448), 3.2, 0.8)
	_walk_in(courier, "menu_courier_walk_atlas.png", Vector2(-126, 42), 0.8, 0.3)
	_walk_in(cinderhide, "menu_cinderhide_walk_atlas.png", Vector2(-136, 50), 0.96, 0.5, shadow)
	_update_menu_actors()

func _menu_contact_shadow(feet: Vector2) -> Node2D:
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
	return shadow

func _menu_idle(actor_name: String, file: String, feet: Vector2, cycle: float, phase: float, pixel_scale: float = PX) -> Sprite2D:
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
	actor.set_meta("feet", feet)
	actor.set_meta("idle_texture", actor.texture)
	actor.set_meta("idle_home", actor.position)
	add_child(actor)
	_idle_actors.append(actor)
	# Drawn frames already contain breathing; no second deformation shader.
	return actor

func _walk_in(actor: Sprite2D, file: String, travel: Vector2, cycle: float, start: float, shadow: Node2D = null) -> void:
	var walk_texture: Texture2D = load(IDLE_ART + file)
	var first := walk_texture.get_image().get_region(Rect2i(0, 0, IDLE_FRAME_SIZE, IDLE_FRAME_SIZE))
	var used := first.get_used_rect()
	var feet: Vector2 = actor.get_meta("feet")
	var anchor := Vector2(used.position.x + used.size.x * 0.5, used.end.y)
	actor.set_meta("walk_texture", walk_texture)
	actor.set_meta("walk_home", (feet - anchor * actor.scale.x).round())
	actor.set_meta("travel", travel)
	actor.set_meta("walk_cycle", cycle)
	actor.set_meta("walk_start", start)
	actor.set_meta("walk_duration", cycle * 3.0)
	if shadow != null:
		actor.set_meta("contact_shadow", shadow)

func _process(delta: float) -> void:
	super._process(delta)
	if _reduce_motion:
		return
	_update_menu_actors()

func _update_menu_actors() -> void:
	# Arrival and drawn frames share the clock, so Reduce Motion freezes both.
	for actor in _idle_actors:
		var local_time: float = maxf(0.0, _time - float(actor.get_meta("walk_start")))
		var duration: float = actor.get_meta("walk_duration")
		var feet: Vector2 = actor.get_meta("feet")
		if local_time < duration:
			var travel: Vector2 = actor.get_meta("travel")
			var walk_texture: Texture2D = actor.get_meta("walk_texture")
			var gait: float = actor.get_meta("walk_cycle")
			var displacement := travel * (1.0 - local_time / duration)
			actor.texture = walk_texture
			actor.hframes = int(walk_texture.get_width() / float(IDLE_FRAME_SIZE))
			actor.frame = int(floor(fposmod(local_time, gait) / gait * actor.hframes))
			actor.position = (Vector2(actor.get_meta("walk_home")) + displacement).round()
			if actor.has_meta("contact_shadow"):
				var shadow: Node2D = actor.get_meta("contact_shadow")
				shadow.position = (feet + displacement).round()
		else:
			var idle_texture: Texture2D = actor.get_meta("idle_texture")
			var cycle: float = actor.get_meta("cycle")
			actor.texture = idle_texture
			actor.hframes = int(idle_texture.get_width() / float(IDLE_FRAME_SIZE))
			actor.frame = int(floor(fposmod(local_time - duration, cycle) / cycle * actor.hframes))
			actor.position = actor.get_meta("idle_home")
			if actor.has_meta("contact_shadow"):
				var shadow: Node2D = actor.get_meta("contact_shadow")
				shadow.position = feet.round()
