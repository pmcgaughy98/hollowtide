extends Node2D
## Detailed waking art over the existing riverbank staging; original code painting is the fallback.
## Same native canvas, actors, reflections and story wiring. Source PNGs/backups stay intact.
const Bank := preload("res://scripts/dungeon/riverbank_painter.gd")
const Stone := preload("res://scripts/dungeon/ruin_painter.gd")
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const ART := "res://assets/sprites/world/waking_bank_2026_10_10/waking_native.png"
const Finish := preload("res://scripts/ui/waking_bank_finish.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
var reduce_motion := false
var companion_visible := false
var show_actor_shadows := true
var clock := 0.0
var background: Sprite2D
var artwork: Image

func _ready() -> void:
	background = Sprite2D.new()
	background.centered = false
	background.z_index = -1
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	artwork = detailed_image()
	background.texture = finished_texture(artwork) if artwork != null else ImageTexture.create_from_image(paint())
	if artwork != null:Finish.apply_mask(background,mask_texture(artwork))
	add_child(background)

## The finished painting and its detail mask, made once a session (Claude, 2026-10-26, pass 7 S5 / LF7-05): every
## bank (the flood talk, the storm, the escape walk, the approach) spent about 0.34 s making the same two pictures
## again. Each is kept with the hash of the picture it came from, so another picture is still finished on its own.
## The finish math is Finish's, unchanged. Shared textures: a scene that wants a different picture makes a new one.
static var _finished: Texture2D
static var _finished_key := 0
static var _mask: Texture2D
static var _mask_key := 0

static func finished_texture(img: Image) -> Texture2D:
	var key := hash(img.get_data())
	if _finished == null or _finished_key != key:
		_finished = ImageTexture.create_from_image(Finish.finished_image(img))
		_finished_key = key
	return _finished

static func mask_texture(img: Image) -> Texture2D:
	var key := hash(img.get_data())
	if _mask == null or _mask_key != key:
		_mask = ImageTexture.create_from_image(Finish.mask(img))
		_mask_key = key
	return _mask

static func detailed_image(path: String = ART) -> Image:
	# Claude, 2026-10-24 (A4, LV-19): UI.res_image reads the imported texture, which an exported game has; the PNG it does not.
	var img := UI.res_image(path)
	if img == null or img.get_size() != Vector2i(384,216): return null
	return img

func water_at(x: int, y: int) -> bool:
	# Prevent drifting highlights from drawing on the painted slabs, roots or bank.
	# The absent-art fallback retains its original reflection behaviour exactly.
	if artwork == null: return true
	var c := artwork.get_pixel(x,y)
	return c.b > c.r * 1.25 and c.g > c.r * 1.10 and c.b > c.g * 0.80

func _process(delta: float) -> void:
	if reduce_motion:
		return
	clock += delta
	queue_redraw()

static func far_bank(x: int) -> int:
	return 22 + int(sin(x * 0.025) * 5.0 + sin(x * 0.081) * 2.0)

static func near_bank(x: int) -> int:
	return 65 + int(sin(x * 0.022 + 1.0) * 9.0 + sin(x * 0.074) * 3.0)

static func paint() -> Image:
	var tiles := PackedByteArray()
	tiles.resize(16 * 9)
	tiles.fill(Gen.FLOOR)
	var data := {"w":16, "h":9, "tiles":tiles}
	var clay := Image.create(384,216,false,Image.FORMAT_RGBA8)
	Bank._ground(clay,data,24,19)
	Bank._pebbles_and_roots(clay,data,24,19)
	var img := Image.create(384,216,false,Image.FORMAT_RGBA8)
	for y in 216:
		for x in 384:
			var n := Stone._h(x,y,93)
			var edge := near_bank(x)
			var c: Color
			if y < far_bank(x):
				c = Color("#243e37").lerp(Color("#365246"),n * 0.35)
				if x % 5 == 1 and y % 4 < 2 and n > 0.5:
					c = Color("#446151")
			elif y < edge:
				c = Color("#173541").lerp(Color("#315560"),float(y-far_bank(x))/48.0)
				if y % 7 == 0 and sin(x * 0.13 + y) > 0.7:
					c = c.lightened(0.07)
				if y < far_bank(x) + 2:
					c = Color("#131f23")
			elif y < edge + 10:
				# Fractured sediment face, an uneven lip and a dark contact seam.
				c = Bank.BANDS[(y-edge)/2 % Bank.BANDS.size()].darkened(0.32)
				if y == edge:
					c = Color("#a88c66") if n > 0.25 else Color("#342d27")
				elif y == edge + 9:
					c = Color("#302a24")
			else:
				c = clay.get_pixel(x,y).darkened(0.20)
			img.set_pixel(x,y,c)
	# Turf slabs torn from the bank; horizontal layers and dangling roots.
	for slab in [Rect2i(4,59,36,9),Rect2i(63,64,23,8),Rect2i(118,57,21,7),Rect2i(333,56,45,8)]:
		for x in range(slab.position.x,slab.end.x):
			var top: int = slab.position.y + int(Stone._h(x/3,slab.position.y,95)*3)
			var bottom: int = slab.end.y - int(Stone._h(x/4,slab.end.y,96)*3)
			for y in range(top,bottom):
				var c := Color("#304834")
				if y==top: c=Color("#63835a")
				elif y>bottom-3: c=Color("#5b4834")
				elif Stone._h(x,y,97)>0.65: c=Color("#425c3b")
				img.set_pixel(x,y,c)
		for k in range(3,slab.size.x,7):
			var x: int = slab.position.x + k
			for y in range(slab.end.y,slab.end.y + 8):
				img.set_pixel(x+(y-slab.end.y)/4,y,Color("#3b2a20"))
	# Broken clay plates scatter away from the collapse rather than enclosing a room.
	for point in [Vector2i(52,81),Vector2i(105,78),Vector2i(143,107),Vector2i(256,91),Vector2i(314,83)]:
		img.fill_rect(Rect2i(point+Vector2i(-5,0),Vector2i(12,4)),Color("#302b25"))
		img.fill_rect(Rect2i(point+Vector2i(-4,-3),Vector2i(10,4)),Color("#8c7050"))
		img.fill_rect(Rect2i(point+Vector2i(-2,-4),Vector2i(7,1)),Color("#b39770"))
	_hollow(img)
	# The stone approach has just surfaced. Its wet edges still meet the river.
	for k in 7:
		var x := 290 - k * 9
		var y := 45 + k * 4
		img.fill_rect(Rect2i(x-1,y+1,19,7),Color("#17292c"))
		img.fill_rect(Rect2i(x,y,17,5),Color("#5a716d"))
		img.fill_rect(Rect2i(x+1,y,14,1),Color("#a0b8a0"))
		img.set_pixel(x+6,y+3,Color("#304c40"))
	# Waterlogged envelopes: seals, folded corners, and small mud shadows.
	for point in [Vector2i(201,81),Vector2i(239,88),Vector2i(297,75)]:
		img.fill_rect(Rect2i(point+Vector2i(-1,1),Vector2i(11,7)),Color("#34372e"))
		img.fill_rect(Rect2i(point,Vector2i(9,5)),Color("#b4ab86"))
		img.fill_rect(Rect2i(point,Vector2i(9,1)),Color("#d8d1ac"))
		for k in 4: img.set_pixel(point.x+1+k,point.y+1+k/2,Color("#786c50"))
		img.set_pixel(point.x+4,point.y+3,Color("#865041"))
	return img

static func _hollow(img: Image) -> void:
	# A distant, river-washed structure, using the Hollow's actual stone colours.
	# Its silhouette/lighting is a staging proposal, not a new lore or dungeon layout.
	var outline := Color("#122024")
	for tower in [Rect2i(267,8,19,35),Rect2i(287,1,25,45),Rect2i(315,12,17,31)]:
		img.fill_rect(Rect2i(tower.position-Vector2i.ONE,tower.size+Vector2i(2,3)),outline)
		for y in range(tower.position.y,tower.end.y):
			for x in range(tower.position.x,tower.end.x):
				var c: Color = Stone.WALL[(y/7+x/9)%Stone.WALL.size()]
				if (y-tower.position.y)%7 == 0 or (x+(y/7%2)*5)%10 == 0:
					c = Stone.MORTAR
				elif Stone._h(x,y,94) < 0.14:
					c = c.lightened(0.12)
				img.set_pixel(x,y,c)
		img.fill_rect(Rect2i(tower.position-Vector2i(1,0),Vector2i(tower.size.x+2,2)),Stone.LIP.darkened(0.08))
		img.fill_rect(Rect2i(tower.position+Vector2i(3,4),Vector2i(tower.size.x-6,1)),Color("#7c998b"))
		var cx: int = tower.position.x + tower.size.x/2
		img.fill_rect(Rect2i(cx-3,tower.position.y+9,7,15),outline)
		img.fill_rect(Rect2i(cx-2,tower.position.y+7,5,18),outline)
		img.fill_rect(Rect2i(cx-1,tower.position.y+10,3,13),Color("#bbd9b9"))
		img.fill_rect(Rect2i(cx,tower.position.y+10,1,13),Color("#eef0c7"))
	# Submerged foundation, algae, waterline and a pale seam over the doorway.
	img.fill_rect(Rect2i(261,39,77,9),Color("#243a39"))
	img.fill_rect(Rect2i(261,39,77,2),Color("#75887b"))
	img.fill_rect(Rect2i(263,46,72,2),Color("#49705f"))
	img.fill_rect(Rect2i(291,31,15,15),outline)
	img.fill_rect(Rect2i(294,28,9,17),outline)
	img.fill_rect(Rect2i(296,30,5,15),Color("#849f80"))
	img.fill_rect(Rect2i(298,30,1,15),Color("#f1edbd"))
	for x in range(269,333,7):
		img.set_pixel(x,47,Color("#a6c1b6"))

func _draw() -> void:
	# Only the water glints drift. Reduce Motion freezes this complete composition.
	for k in 18:
		var x := posmod(k * 53 + int(clock * 3.0),384)
		var y := far_bank(x) + 7 + (k * 11) % 25
		if y < near_bank(x)-3 and not (x > 255 and x < 342 and y < 49) and water_at(x,y):
			draw_rect(Rect2(x,y,3+k%5,1),Color(Color("#628581"),0.45))
	for k in 5:
		var drift := int(sin(clock * 0.6 + k) * 2.0)
		var x := 292-k*4+drift
		var y := 49+k*3
		if water_at(x,y):
			draw_rect(Rect2(x,y,9+k*2,1),Color(Color("#bfd5aa"),0.55-k*0.06))
	# Creature contact shadows; source art and its house finish remain untouched.
	if show_actor_shadows:draw_ellipse_shadow(Vector2(168,84))
	if show_actor_shadows and companion_visible:
		draw_ellipse_shadow(Vector2(222,85))

func draw_ellipse_shadow(at: Vector2) -> void:
	draw_rect(Rect2(at-Vector2(10,1),Vector2(20,2)),Color(0.08,0.10,0.08,0.48))
	draw_rect(Rect2(at-Vector2(7,2),Vector2(14,4)),Color(0.08,0.10,0.08,0.32))
