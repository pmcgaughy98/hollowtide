extends RefCounted
## Shared display finish, following the saved Hollowtide Sprite Forge house style.
## Source art and palettes are never rebuilt. No time-dependent grain or dither.
const SHADER = preload("res://scripts/arena/creature_finish.gdshader")

static func apply(sprite: Sprite2D, details: bool = false, form: String = "") -> void:
	var finish := ShaderMaterial.new()
	finish.shader = SHADER
	finish.set_shader_parameter("detail_ink", 1.0 if details else 0.0)
	sprite.material = finish
	# Textures arrive after construction in town/dungeon and change during walking.
	# Follow the active texture, so only this form receives its material correction.
	var refresh := func() -> void:
		var path := sprite.texture.resource_path if sprite.texture != null else ""
		finish.set_shader_parameter("sparkwick_palette", is_sparkwick(path))
		finish.set_shader_parameter("detail_ink", 1.0 if details else crew_detail(path, form))
	sprite.texture_changed.connect(refresh)
	refresh.call()


static func is_sparkwick(path: String) -> bool:
	return "/arena/sparkwick/" in path or "/sparkwick_palette_locked/" in path or "/sparkwick_idle_texture_" in path or "/109_kithflare2/" in path or path.ends_with("/kithflare2_front.png") or path.ends_with("/kithflare2_back.png")


static func dialogue_form(path: String, form: String) -> bool:
	# Expression variants share their form's finish; rejected/source sheets do not opt in.
	var stem := path.get_file().get_basename()
	return path.get_base_dir().ends_with("/sprites/ui/dialogue") and (stem == form or stem.begins_with(form + "_"))

static func crew_detail(path: String, identity: String = "") -> float:
	for form in ["mirekit", "whinet", "gruntle"]:
		if ("/arena/" + form + "/") in path or dialogue_form(path, form) or (path.is_empty() and identity == form):
			return 0.65
	return 0.0

static func portrait_target(path: String) -> bool:
	return crew_detail(path) > 0.0 or dialogue_form(path, "starward")
