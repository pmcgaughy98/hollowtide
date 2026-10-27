extends RefCounted
## Hall presentation over the existing 22x14 room/event grid; original painter remains the fallback.
## The picture and its props are art slots (Claude, 2026-10-26, placeholder factory lane R): town.room.hall and
## town.prop.hall.<name>, today's files through ArtSlots until a slot file is installed at the same size. On the
## placeholder (HT_FORCE_PLACEHOLDERS=1, or a file missing) the original painter shows, as it always did.
const SLOT := "town.room.hall"
const PROP_SLOT := "town.prop.hall."
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const Slots := preload("res://scripts/town/room_slots.gd")
const PROPS := [
	["pillar",Rect2i(73,122,22,46)],["pillar",Rect2i(433,122,22,46)],
	["pillar",Rect2i(73,218,22,46)],["pillar",Rect2i(433,218,22,46)],
	["fern",Rect2i(96,136,24,32)],["fern",Rect2i(408,136,24,32)],
	["bench",Rect2i(26,192,20,70)],["bench",Rect2i(482,192,20,70)],
	["chart",Rect2i(120,172,48,42)],["reports",Rect2i(360,172,48,42)],
	["parcels",Rect2i(48,280,44,26)],["parcels",Rect2i(432,280,44,26)]
]

static func _prop(name: String) -> Image:
	return Slots.image(PROP_SLOT+name)

static func available() -> bool:
	if not Slots.real(SLOT): return false
	for p in PROPS:
		if not Slots.real(PROP_SLOT+p[0]): return false
	return true

static func paint(fallback: Image) -> Image:
	if not available(): return fallback
	var img := Slots.image(SLOT)
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
	# The way out is the art's own doorway, given a step and the daylight (Claude, 2026-10-26, pass 8 R3 / L13). It used
	# to be the fallback painter's door pasted over it 12 px right of the carpet, a flat pale-green block.
	_doorway(img)
	return img


## The doorway at the carpet's end (Claude, 2026-10-26, pass 8 R3 / L13). The Hall art draws two posts and a threshold
## centred on the carpet (x 264, the line between tiles 10 and 11, the two tiles town_room.gd opens as the way out).
## Three things make it read as an opening onto the street rather than a patch of floor: a sandstone sill where the
## carpet ends, lit along its top and shadowed under its front; the threshold brightening toward the street the way
## daylight comes in; and a short spill of that light on the carpet's last rows, widening into the room. Flat bands of
## light, one dithered row where two bands meet, as room_painter.gd lights its doors; never a smooth gradient.
const DOOR := Rect2i(249, 303, 30, 33)   # the opening between the posts, from the sill to the picture's foot
const DAY := Color("#ffe6b0")             # the light outside
const SILL := Color("#c9a874")            # sandstone, the threshold's own colour
const SPILL := [[4, 0.20], [4, 0.12], [3, 0.06]]   # the light on the carpet, from the sill up: [rows, strength]
const STEPS := [0.10, 0.20, 0.32, 0.44]           # the threshold's bands, from the sill to the street


## How much of DAY a pixel takes: the band's strength, or on a band's first row the one before it on half the pixels.
static func _lit(x: int, y: int, now: float, before: float, first: bool) -> float:
	return before if first and (x + y) % 2 == 0 else now


static func _doorway(img: Image) -> void:
	var x0 := DOOR.position.x
	var x1 := DOOR.end.x
	var y0 := DOOR.position.y
	# The spill on the carpet: each band a pixel wider each side than the one below it.
	var y := y0 - 1
	var widen := 0
	var below := 0.0
	for band in SPILL:
		for r in int(band[0]):
			for x in range(x0 - widen, x1 + widen):
				var v := _lit(x, y, float(band[1]), below, r == 0 and below > 0.0)
				img.set_pixel(x, y, img.get_pixel(x, y).lerp(DAY, v))
			y -= 1
		below = float(band[1])
		widen += 1
	# The sill: a sandstone slab across the opening, its top lit, its front edge and the shadow under it dark.
	img.fill_rect(Rect2i(x0, y0, x1 - x0, 1), SILL.lightened(0.3))
	img.fill_rect(Rect2i(x0, y0 + 1, x1 - x0, 2), SILL)
	img.fill_rect(Rect2i(x0, y0 + 3, x1 - x0, 1), SILL.darkened(0.3))
	img.fill_rect(Rect2i(x0, y0 + 4, x1 - x0, 1), Color("#3a2614"))
	# The threshold: the art's own sand in bands lit more toward the street; the columns by the posts keep their shade.
	var rows := DOOR.end.y - (y0 + 5)
	for yy in range(y0 + 5, DOOR.end.y):
		var k := mini(STEPS.size() - 1, (yy - y0 - 5) * STEPS.size() / rows)
		var first := k > 0 and (yy - y0 - 5) * STEPS.size() / rows != (yy - y0 - 6) * STEPS.size() / rows
		for x in range(x0, x1):
			var v := _lit(x, yy, STEPS[k], STEPS[maxi(0, k - 1)], first)
			if x == x0 or x == x1 - 1:
				v *= 0.4   # the jambs shade the light beside them
			img.set_pixel(x, yy, img.get_pixel(x, yy).lerp(DAY, v))

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
	img.fill_rect(DOOR,Color.BLACK)   # the lit threshold takes no ink (pass 8 R3); the posts keep theirs
	return img

static func finish(sprite: Sprite2D) -> void:
	if not available() or sprite.texture.get_size()!=Vector2(528,336): return
	var material := ShaderMaterial.new()
	material.shader=SHADER
	material.set_shader_parameter("detail_mask",ImageTexture.create_from_image(mask()))
	material.set_shader_parameter("detail_ink",0.75)
	sprite.material=material
