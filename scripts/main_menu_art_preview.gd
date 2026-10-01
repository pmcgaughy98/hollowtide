extends "res://scripts/main_menu.gd"
## Isolated composition candidate. Original menu layers remain intact.
## Flat nearest-sampled backdrop, not extracted parallax or approved final art.

var _previous_aspect: Window.ContentScaleAspect

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
	# Base animation expects a window sprite. An empty placeholder avoids
	# flickering the entire flat landscape or adding duplicate stand-in windows.
	_windows = Sprite2D.new()
	add_child(_windows)

func _build_characters() -> void:
	# Reuse the selected chibi's existing UP first pose, not new actor artwork.
	# Nearest sampling gives the menu actor a consistent logical pixel grid.
	var sheet: Texture2D = load("res://assets/sprites/player/courier_chibi_walk_2026_10_01.png")
	var back := sheet.get_image().get_region(Rect2i(0, 816, 272, 272))
	back.resize(96, 96, Image.INTERPOLATE_NEAREST)
	_character(ImageTexture.create_from_image(back), Vector2(300, 424), PX, 0.012)
	_character(load("res://assets/sprites/creatures/cinderhide_back.png"), Vector2(432, 448), PX, 0.026)
