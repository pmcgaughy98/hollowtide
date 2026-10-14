extends RefCounted
## Native Storage shell plus separate foot-sorted props; source PNGs already carry the shared CPU rim.
const ROOT := "res://assets/sprites/world/storage_interior_2026_10_14/"
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const PROPS := [
	["cabinet_left",Vector2(48,16),112], ["cabinet_right",Vector2(288,16),112],
	["counter",Vector2(132,96),156], ["crates",Vector2(48,216),264],
	["basket",Vector2(312,220),260], ["lamp",Vector2(140,24),56], ["lamp",Vector2(252,24),56]]
static func shell() -> Texture2D:
	return load(ROOT+"shell.png")
static func finish(world: Node2D, map: Sprite2D) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("detail_mask",load(ROOT+"shell-mask.png"))
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
		sprite.texture = load(ROOT+"props/"+p[0]+".png")
		sprite.position = p[1]
		sprite.z_index = p[2]
		sprite.material = prop_mat
		world.add_child(sprite)
