extends RefCounted
## Shared display finish, following the saved Hollowtide Sprite Forge house style.
## Source art and palettes are never rebuilt. No time-dependent grain or dither.
const SHADER = preload("res://scripts/arena/creature_finish.gdshader")

static func apply(sprite: Sprite2D, details: bool = false) -> void:
	var finish := ShaderMaterial.new()
	finish.shader = SHADER
	finish.set_shader_parameter("detail_ink", 1.0 if details else 0.0)
	sprite.material = finish
	# Textures arrive after construction in town/dungeon and change during walking.
	# Follow the active texture, so only this form receives its material correction.
	var refresh := func() -> void:
		var path := sprite.texture.resource_path if sprite.texture != null else ""
		finish.set_shader_parameter("sparkwick_palette", is_sparkwick(path))
	sprite.texture_changed.connect(refresh)
	refresh.call()


static func is_sparkwick(path: String) -> bool:
	return "/arena/sparkwick/" in path or "/sparkwick_palette_locked/" in path or "/sparkwick_idle_texture_" in path or "/109_kithflare2/" in path or path.ends_with("/kithflare2_front.png") or path.ends_with("/kithflare2_back.png")
