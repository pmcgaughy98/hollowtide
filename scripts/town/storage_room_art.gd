extends RefCounted
## Native Storage shell plus separate foot-sorted props; source PNGs already carry the shared CPU rim.
## Each picture is an art slot (Claude, 2026-10-26, placeholder factory lane R): town.room.storage.shell and
## .shell_mask, town.prop.storage.<name>. ArtSlots hands back today's loaded textures until a slot file is installed
## at the same size, and the placeholders when forcing (the finish's ink then stays off the placeholder shell).
const SHELL := "town.room.storage.shell"
const MASK := "town.room.storage.shell_mask"
const PROP_SLOT := "town.prop.storage."
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const PROPS := [
	["cabinet_left",Vector2(48,16),112], ["cabinet_right",Vector2(288,16),112],
	["counter",Vector2(132,96),156], ["crates",Vector2(48,216),264],
	["basket",Vector2(312,220),260], ["lamp",Vector2(140,24),56], ["lamp",Vector2(252,24),56]]
static func shell() -> Texture2D:
	return ArtSlots.texture(SHELL)
static func finish(world: Node2D, map: Sprite2D) -> void:
	if ArtSlots.source(MASK) != "placeholder" and ArtSlots.source(SHELL) != "placeholder":
		var mat := ShaderMaterial.new()
		mat.shader = SHADER
		mat.set_shader_parameter("detail_mask",ArtSlots.texture(MASK))
		mat.set_shader_parameter("detail_ink",0.75)
		map.material = mat
	var white := Image.create(1,1,false,Image.FORMAT_RGBA8)
	white.fill(Color.WHITE)
	var prop_mat := ShaderMaterial.new()
	prop_mat.shader = SHADER
	prop_mat.set_shader_parameter("detail_mask",ImageTexture.create_from_image(white))
	prop_mat.set_shader_parameter("detail_ink",0.75)
	for p in PROPS:
		var sprite := Sprite2D.new()
		sprite.name = "Storage_"+p[0]+"_"+str(p[1].x)
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.texture = ArtSlots.texture(PROP_SLOT+p[0])
		sprite.position = p[1]
		sprite.z_index = p[2]
		sprite.material = prop_mat
		world.add_child(sprite)
