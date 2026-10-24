extends RefCounted
## Hall presentation over the existing 22x14 room/event grid; original painter remains the fallback.
const ART := "res://assets/sprites/world/hall_interior_2026_10_10/hall_native.png"
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const UI := preload("res://scripts/ui/ui_style.gd")
const FOLDER := "res://assets/sprites/world/hall_interior_2026_10_10/"
const PROPS := [
	["pillar",Rect2i(73,122,22,46)],["pillar",Rect2i(433,122,22,46)],
	["pillar",Rect2i(73,218,22,46)],["pillar",Rect2i(433,218,22,46)],
	["fern",Rect2i(96,136,24,32)],["fern",Rect2i(408,136,24,32)],
	["bench",Rect2i(26,192,20,70)],["bench",Rect2i(482,192,20,70)],
	["chart",Rect2i(120,172,48,42)],["reports",Rect2i(360,172,48,42)],
	["parcels",Rect2i(48,280,44,26)],["parcels",Rect2i(432,280,44,26)]
]

static func _prop(name: String) -> Image:
	# Claude, 2026-10-24 (A4, LV-19): UI.res_image reads the imported texture, which an exported game has; the PNG it does not.
	return UI.res_image(FOLDER+name+".png")

static func available() -> bool:
	if not UI.res_exists(ART): return false
	for p in PROPS:
		if not UI.res_exists(FOLDER+p[0]+".png"): return false
	return true

static func paint(fallback: Image) -> Image:
	if not available(): return fallback
	var img := UI.res_image(ART)
	if img == null or img.get_size()!=fallback.get_size():
		push_warning("Hall interior art does not match the room; retaining original painter.")
		return fallback
	# Transparent prop sprites are fitted to the original painter's exact visual rectangles.
	# The floor is clean beneath them; no copied floor patches or moved collision tiles.
	for p in PROPS:
		var prop := _prop(p[0])
		var r: Rect2i = p[1]
		if prop.get_size()!=r.size:
			push_warning("Hall prop does not fit its original spot; retaining original painter.")
			return fallback
		img.blend_rect(prop,Rect2i(Vector2i.ZERO,r.size),r.position)
	# Claude's actual south exit is restored exactly, with no generated warp or moved tile.
	var door := Rect2i(261,312,30,24)
	img.blit_rect(fallback,door,door.position)
	return img

static func mask() -> Image:
	var img := Image.create(528,336,false,Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)
	img.fill_rect(Rect2i(168,54,192,42),Color.WHITE)
	for p in PROPS:
		var prop := _prop(p[0])
		var r: Rect2i = p[1]
		for y in r.size.y:
			for x in r.size.x:
				if prop.get_pixel(x,y).a>0.5: img.set_pixelv(r.position+Vector2i(x,y),Color.WHITE)
	for r in [Rect2i(0,0,528,48),Rect2i(0,0,24,336),Rect2i(504,0,24,336),Rect2i(0,312,528,24)]:
		img.fill_rect(r,Color.WHITE)
	img.fill_rect(Rect2i(261,312,30,24),Color.BLACK)
	return img

static func finish(sprite: Sprite2D) -> void:
	if not available() or sprite.texture.get_size()!=Vector2(528,336): return
	var material := ShaderMaterial.new()
	material.shader=SHADER
	material.set_shader_parameter("detail_mask",ImageTexture.create_from_image(mask()))
	material.set_shader_parameter("detail_ink",0.75)
	sprite.material=material
