extends RefCounted
## Highbank's remaining open-air services. Presentation only; original paths/services stay.
const Layout := preload("res://scripts/town/town_layout.gd")
const Detail := preload("res://scripts/town/town_detail_art.gd")
const Finish := preload("res://scripts/town/exterior_finish.gd")
const INK := Color("#0b0e11")
const STONE := Color("#9b927b")
const STONE_LIT := Color("#c4b894")
const STONE_SHADE := Color("#685f4b")
const WOOD := Color("#8a6a48")
const WOOD_LIT := Color("#b59768")
const WOOD_SHADE := Color("#59432f")
const MOSS := Color("#4f6a38")
const ROPE := Color("#cab58b")
static func available(id: String) -> bool:
	return id in ["lookout","landing","dock"]
# Claude, 2026-10-26 (placeholder factory lane B): the rect comes from the area showing (v1: the PLACES row itself).
static func place(id: String) -> Dictionary:
	return BuildingTemplate.place_entry(id)
static func _block(img: Image,r: Rect2i,col: Color,lit: Color,shade: Color) -> void:
	img.fill_rect(r,INK)
	img.fill_rect(r.grow(-1),col)
	img.fill_rect(Rect2i(r.position+Vector2i(1,1),Vector2i(r.size.x-2,1)),lit)
	img.fill_rect(Rect2i(r.position+Vector2i(1,2),Vector2i(1,r.size.y-3)),lit)
	img.fill_rect(Rect2i(r.position+Vector2i(1,r.size.y-2),Vector2i(r.size.x-2,1)),shade)
	img.fill_rect(Rect2i(r.position+Vector2i(r.size.x-2,2),Vector2i(1,r.size.y-3)),shade)
static func _stone(img: Image,r: Rect2i) -> void:
	_block(img,r,STONE,STONE_LIT,STONE_SHADE)
	if r.size.x>9:
		img.set_pixelv(r.position+Vector2i(r.size.x-4,2),STONE_SHADE)
		img.set_pixelv(r.position+Vector2i(r.size.x-3,3),STONE_LIT)
static func _post(img: Image,p: Vector2i,height: int) -> void:
	_block(img,Rect2i(p,Vector2i(7,height)),WOOD,WOOD_LIT,WOOD_SHADE)
	_block(img,Rect2i(p+Vector2i(-1,0),Vector2i(9,4)),WOOD,WOOD_LIT,WOOD_SHADE)
	img.fill_rect(Rect2i(p+Vector2i(2,height-5),Vector2i(2,4)),INK)
	img.fill_rect(Rect2i(p+Vector2i(4,height-3),Vector2i(3,2)),MOSS)
static func _wave_mark(img: Image,p: Vector2i) -> void:
	_stone(img,Rect2i(p+Vector2i(3,14),Vector2i(12,8)))
	_block(img,Rect2i(p,Vector2i(18,17)),STONE,STONE_LIT,STONE_SHADE)
	for y in [6,10]:
		for x in range(4,14):
			var at := p+Vector2i(x,y+(1 if x%6 in [0,1,2] else 0))
			img.set_pixelv(at+Vector2i(0,1),INK)
			img.set_pixelv(at,Color("#9bb8b1"))
static func paint(id: String) -> Image:
	# Claude, 2026-10-26 (placeholder factory lane B): an installed slot file, or the forced placeholder, wins; with
	# neither, today's art (the slot's legacy is the same file) and today's coded fallback.
	var slot := "town.landmark." + id
	if ArtSlots.has(slot) and (ArtSlots.forcing() or ArtSlots.source(slot) == "file"):
		return ArtSlots.image(slot)
	var art:=Detail.image(id)
	return art if art!=null else paint_fallback(id)

static func paint_fallback(id: String) -> Image:
	var size: Vector2i=place(id)["rect"].size*Layout.T
	if id=="dock":size.y+=Layout.T # Claude's existing planks already extend a tile over water.
	var img := Image.create(size.x,size.y,false,Image.FORMAT_RGBA8)
	match id:
		"lookout":
			# Low weathered masonry, with crisp black mortar; the southern approach stays open.
			for x in range(8,136,16):
				_stone(img,Rect2i(x,5,16,8))
				_stone(img,Rect2i(x,1,16,5))
			for x in [0,66,132]:
				_stone(img,Rect2i(x,2,12,16))
				_stone(img,Rect2i(x,0,12,5))
				img.fill_rect(Rect2i(x+2,15,4,2),MOSS)
			for y in range(20,73,13):
				_stone(img,Rect2i(1,y,7,13))
				_stone(img,Rect2i(136,y,7,13))
			# A low stone bench, visibly built into the overlook rather than a floating plaque.
			_stone(img,Rect2i(20,47,6,9))
			_stone(img,Rect2i(46,47,6,9))
			_stone(img,Rect2i(17,42,38,7))
			_wave_mark(img,Vector2i(110,47))
		"landing":
			# Replace each existing little post at its same mooring position and foot row.
			for x in range(10,283,36):
				_post(img,Vector2i(x,76),17)
				for k in 3:
					img.fill_rect(Rect2i(x+1,81+k*2,5,1),ROPE if k!=1 else WOOD_SHADE)
			# Retired courier gear stays west of the reading tile and clear of the Hollow Mouth.
			_block(img,Rect2i(12,34,23,19),WOOD,WOOD_LIT,WOOD_SHADE)
			for x in [18,28]:img.fill_rect(Rect2i(x,36,2,15),INK)
			for y in [40,47]:img.fill_rect(Rect2i(14,y,19,1),WOOD_LIT)
			img.fill_rect(Rect2i(14,49,4,2),MOSS)
			_wave_mark(img,Vector2i(92,35))
		"dock":
			# Timber edge beams and low rope-posts. The original (39,28) entrance stays clear.
			for x in [1,138]:
				_block(img,Rect2i(x,8,5,61),WOOD,WOOD_LIT,WOOD_SHADE)
			for x in [0,72,135]:
				_post(img,Vector2i(x+1,0),15)
				_post(img,Vector2i(x+1,55),15)
			# Open centre and three worn entrance treads, at the actual approach tile.
			for y in [3,7,11]:
				img.fill_rect(Rect2i(27,y,19,1),WOOD_LIT)
				img.fill_rect(Rect2i(28,y+1,18,1),WOOD_SHADE)
			for x in range(9,135):
				var y := 61+(1 if x%36 in range(10,27) else 0)
				img.set_pixel(x,y,INK)
				img.set_pixel(x,y-1,ROPE)
	return img
static func attach(parent: Node2D,_host: Node2D,id: String) -> Dictionary:
	var base := Node2D.new()
	base.name=id.capitalize()+"Exterior"
	base.position=Vector2(place(id)["rect"].position*Layout.T)
	base.z_index=0 # Low open-air props remain below the walking creatures.
	parent.add_child(base)
	var tex := ImageTexture.create_from_image(paint(id))
	var shadow := Sprite2D.new()
	shadow.name="ContactShadow"
	shadow.centered=false
	shadow.position=Vector2(2,2)
	shadow.texture=tex
	shadow.modulate=Color(0,0,0,0.22)
	shadow.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	base.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.name="LandmarkDetails"
	sprite.centered=false
	sprite.texture=tex
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	Finish.apply(sprite,true)
	base.add_child(sprite)
	return {"base":base,"sprite":sprite,"shadow":shadow,"landmark":true}
