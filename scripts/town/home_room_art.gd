extends RefCounted
## Finished Home art over Claude's unchanged room/event grid. Original painter is the fallback.
## The picture is the art slot town.room.home (Claude, 2026-10-26, placeholder factory lane R): today's file through
## ArtSlots, a slot file at the same size when one is installed, and the original painter on the placeholder.
const SLOT := "town.room.home"
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const Slots := preload("res://scripts/town/room_slots.gd")
const DETAILS := [Rect2i(20,38,80,62),Rect2i(222,18,96,47),Rect2i(141,98,76,48),Rect2i(19,163,57,56),Rect2i(264,143,54,51)]

static func available() -> bool:
	return Slots.real(SLOT)

static func paint(fallback: Image) -> Image:
	if not available(): return fallback
	var img := Slots.image(SLOT)
	if img == null or img.get_size()!=fallback.get_size():
		push_warning("Home interior art does not match the room; retaining original painter.")
		return fallback
	# The live south exit and its frame are the exact original drawing, never a generated warp.
	var door := Rect2i(165,216,30,24)
	img.blit_rect(fallback,door,door.position)
	return img

static func mask() -> Image:
	var img := Image.create(336,240,false,Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)
	for r in DETAILS: img.fill_rect(r,Color.WHITE)
	for r in [Rect2i(0,0,336,48),Rect2i(0,0,24,240),Rect2i(312,0,24,240),Rect2i(0,216,336,24)]:
		img.fill_rect(r,Color.WHITE)
	# Keep the original door/light exactly as painted by Claude.
	img.fill_rect(Rect2i(165,216,30,24),Color.BLACK)
	return img

static func finish(sprite: Sprite2D) -> void:
	if not available() or sprite.texture.get_size()!=Vector2(336,240): return
	var material := ShaderMaterial.new()
	material.shader=SHADER
	material.set_shader_parameter("detail_mask",ImageTexture.create_from_image(mask()))
	material.set_shader_parameter("detail_ink",0.75)
	sprite.material=material
