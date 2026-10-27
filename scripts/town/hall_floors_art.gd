extends RefCounted
## Presentation only: finished fixtures on Claude's exact Hall room footprints.
## The original room painter is returned whole if any required crop is missing or malformed.
## Every strip and prop is an art slot (Claude, 2026-10-26, placeholder factory lane R): town.room.<room>.<strip> and
## the prop slots of slot_id(), read through room_slots.gd, so a slot file installed at the same size replaces today's
## crop. On a placeholder (HT_FORCE_PLACEHOLDERS=1, or a file missing) the original room painter shows whole.
const SelOut := preload("res://scripts/art/selout.gd")
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const Slots := preload("res://scripts/town/room_slots.gd")
const SIZES := {"hall": Vector2i(528,336), "hall_low": Vector2i(720,432), "chamber": Vector2i(408,264), "runners": Vector2i(336,240)}
const SHELLS := {"hall_low":"lower", "chamber":"chamber", "runners":"runners"}
const PROPS := {
	# 2026-10-11 (Claude, Preston's notes): side-wall doors, the kitchen hatch, the pegs, the shelves and
	# the stairs down are drawn by room_painter._fixtures after this layer, edge-on or against the back wall.
	"hall": [],
	"hall_low": [
		["runner",Rect2i(342,48,36,128)], ["rollcall",Rect2i(284,170,153,93)],
		["north_door",Rect2i(330,2,60,46)], ["window",Rect2i(74,8,44,32)], ["window",Rect2i(602,8,44,32)],
		["banner",Rect2i(268,6,16,38)], ["banner",Rect2i(436,6,16,38)], ["duty",Rect2i(214,10,52,28)],
		["lamp",Rect2i(163,12,10,18)], ["lamp",Rect2i(523,12,10,18)],
		["fern",Rect2i(288,40,24,32)], ["fern",Rect2i(408,40,24,32)],
		["pillar",Rect2i(217,98,22,46)], ["pillar",Rect2i(481,98,22,46)],
		["pillar",Rect2i(217,266,22,46)], ["pillar",Rect2i(481,266,22,46)],
		["mess",Rect2i(72,286,144,50)]],
	"chamber": [
		["teal_rug",Rect2i(96,72,216,120)], ["dais",Rect2i(168,66,72,52)],
		["river_map",Rect2i(72,8,96,32)], ["window_wide",Rect2i(240,8,96,32)],
		["lamp",Rect2i(55,12,10,18)], ["lamp",Rect2i(343,12,10,18)]],
	"runners": [
		["rust_rug",Rect2i(108,120,96,48)],
		["bunk_ochre",Rect2i(72,42,48,52)], ["bunk_slate",Rect2i(192,42,48,52)],
		["window",Rect2i(138,8,36,32)], ["river_map",Rect2i(240,10,48,28)],
		["chest",Rect2i(264,170,48,22)], ["lamp",Rect2i(43,12,10,18)]]
}

## The art slot a prop of room `room` draws from (lane R). The pillar and fern are the work floor's (town.prop.hall),
## the rest the lower floor's unless the chamber or the runners' room has its own: the chamber's rug and wide window,
## and the runners' window and map, which the rooms draw at a size their old file is not (room_slots.gd DRAWN).
static func slot_id(room: String, name: String) -> String:
	match name:
		"fern","pillar": return "town.prop.hall."+name
		"teal_rug": return "town.prop.chamber.rug"
		"dais","window_wide": return "town.prop.chamber."+name
		"rust_rug","bunk_ochre","bunk_slate","chest": return "town.prop.runners."+name
		"window": return "town.prop.runners.window" if room == "runners" else "town.prop.hall_low.window"
		"river_map": return "town.prop.runners.river_map" if room == "runners" else "town.prop.chamber.river_map"
	return "town.prop.hall_low."+name

## [old file name, rect, slot] for each of a room's five strips: floor, north, south, west, east.
static func _bands(id: String) -> Array:
	var s: Vector2i = SIZES[id]
	var base: String = SHELLS[id]
	var slot := "town.room.%s." % id
	return [[base+"_floor",Rect2i(24,48,s.x-48,s.y-72),slot+"floor"],
		[base+"_north",Rect2i(0,0,s.x,48),slot+"north"], [base+"_south",Rect2i(0,s.y-24,s.x,24),slot+"south"],
		[base+"_west",Rect2i(0,48,24,s.y-72),slot+"west"], [base+"_east",Rect2i(s.x-24,48,24,s.y-72),slot+"east"]]

## Every slot has finished art (today's file, today's resize or an installed file). The slots are each exactly their
## rect's size (town_room_check measures it), so the old per-crop size checks are the loader's now.
static func available(id: String) -> bool:
	if not SIZES.has(id): return false
	for p in PROPS[id]:
		if not Slots.real(slot_id(id,p[0])): return false
	if id != "hall":
		for p in _bands(id):
			if not Slots.real(p[2]): return false
	return true

static func _prop(p: Array, room: String) -> Image:
	var img := Slots.image(slot_id(room,p[0]))
	var r: Rect2i = p[1]
	if img.get_size() != r.size: img.resize(r.size.x,r.size.y,Image.INTERPOLATE_NEAREST)
	return SelOut.selout(img)

static func paint(id: String, fallback: Image) -> Image:
	if not available(id) or fallback.get_size() != SIZES[id]: return fallback
	var img := fallback.duplicate() as Image
	if id != "hall":
		for p in _bands(id):
			var r: Rect2i = p[1]
			img.blit_rect(Slots.image(p[2]),Rect2i(Vector2i.ZERO,r.size),r.position)
	for p in PROPS[id]:
		var r: Rect2i = p[1]
		img.blend_rect(_prop(p,id),Rect2i(Vector2i.ZERO,r.size),r.position)
	if id == "chamber":
		# Keep the wired south threshold exact, including its lit lintel and two open tiles.
		var exit := Rect2i(165,240,78,24)
		img.blit_rect(fallback,exit,exit.position)
	return img

static func mask(id: String) -> Image:
	var s: Vector2i = SIZES[id]
	var img := Image.create(s.x,s.y,false,Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)
	if id != "hall":
		for r in [Rect2i(0,0,s.x,48),Rect2i(0,s.y-24,s.x,24),Rect2i(0,48,24,s.y-72),Rect2i(s.x-24,48,24,s.y-72)]:
			img.fill_rect(r,Color.WHITE)
	for p in PROPS[id]:
		var prop := _prop(p,id)
		var r: Rect2i = p[1]
		for y in r.size.y:
			for x in r.size.x:
				if prop.get_pixel(x,y).a > 0.5: img.set_pixelv(r.position+Vector2i(x,y),Color.WHITE)
	if id == "chamber": img.fill_rect(Rect2i(165,240,78,24),Color.BLACK)
	return preload("res://scripts/town/hall_fixtures_art.gd").add_mask(id, img)

static func finish(sprite: Sprite2D, id: String) -> void:
	if not available(id) or Vector2i(sprite.texture.get_size()) != SIZES[id]: return
	var material := sprite.material as ShaderMaterial
	if id == "hall":
		# Called AFTER _guild_desk: preserve its cleared counter mask and add only the new stairs.
		if material == null: return
		var existing: Texture2D = material.get_shader_parameter("detail_mask")
		if existing == null: return
		var detail := existing.get_image().duplicate() as Image
		detail.fill_rect(Rect2i(336,240,48,48),Color.WHITE)
		detail = preload("res://scripts/town/hall_fixtures_art.gd").add_mask(id, detail)
		material.set_shader_parameter("detail_mask",ImageTexture.create_from_image(detail))
	else:
		material = ShaderMaterial.new()
		material.shader = SHADER
		material.set_shader_parameter("detail_mask",ImageTexture.create_from_image(mask(id)))
		material.set_shader_parameter("detail_ink",0.75)
		sprite.material = material
