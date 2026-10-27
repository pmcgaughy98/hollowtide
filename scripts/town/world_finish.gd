extends RefCounted
## Highbank terrain sel-out. Connected lane borders and exposed cliffs only;
## existing landmark art, river/glints and quiet floor interiors stay untouched.
const Layout := preload("res://scripts/town/town_layout.gd")
const Tiles := preload("res://scripts/town/world_tile_art.gd")   # the ground being painted (lane C, 2026-10-26)
const SelOut := preload("res://scripts/art/selout.gd")
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const T := Layout.T
const SIZE := Vector2i(Layout.W*T,Layout.H*T)
static var _lane: Image
static var _cliff: Image
static var _detail: Image

static func _protected() -> Array:
	_shapes()
	return _protected_in(SIZE, _v1_places)

static func _protected_in(size: Vector2i, places: Array) -> Array:
	var rects := []
	for p in places:
		var tiles: Rect2i = p["rect"].grow(1)
		rects.append(Rect2i(tiles.position*T,tiles.size*T).intersection(Rect2i(Vector2i.ZERO,size)))
	return rects

static var _v1_places: Array = []

## The cliff of the map world_tile_art.gd's view holds, as pixel rects: each row's runs of cliff tiles (on today's map,
## the two cliff bands, whole rows).
static func _view_cliffs() -> Array:
	var cliffs := []
	for ty in Tiles.rows:
		var x0 := -1
		for tx in Tiles.cols + 1:
			var on := tx < Tiles.cols and Tiles.band(tx,ty)=="cliff"
			if on and x0 < 0:
				x0 = tx
			elif not on and x0 >= 0:
				cliffs.append(Rect2i(x0*T,ty*T,(tx-x0)*T,T))
				x0 = -1
	return cliffs

## Today's map's shapes, made once (Claude, 2026-10-26, lane C: from world_tile_art.gd's view of today's map, the same
## pixels as from town_layout.gd's lists, which hold the shown area once Highbank v2 is on).
static func _shapes() -> void:
	if _detail != null: return
	Tiles.lock.lock()
	Tiles.use_v1()
	_v1_places = Tiles.places
	var shapes := _build(SIZE, Tiles.paths, _view_cliffs(), Tiles.places)
	Tiles.lock.unlock()
	_lane=shapes[0];_cliff=shapes[1];_detail=shapes[2]

## The lane, cliff and detail masks for a map of `size` px: its lanes (tile rects), its cliff (pixel rects) and its
## places (Claude, 2026-10-26, lane C: today's _shapes body, given the map instead of reading town_layout.gd).
static func _build(size: Vector2i, paths: Array, cliffs: Array, places: Array) -> Array:
	var lane := Image.create(size.x,size.y,false,Image.FORMAT_RGBA8);lane.fill(Color.BLACK)
	var cliff := Image.create(size.x,size.y,false,Image.FORMAT_RGBA8);cliff.fill(Color.BLACK)
	for r in paths:
		lane.fill_rect(Rect2i(r.position*T,r.size*T),Color.WHITE)
	for strip in cliffs:
		cliff.fill_rect(strip,Color.WHITE)
	# Stair channels divide the cliff silhouette. Do not outline the individual24px tiles.
	for r in paths:
		cliff.fill_rect(Rect2i(r.position*T,r.size*T),Color.BLACK)
	var detail := cliff.duplicate() as Image
	# Narrow outside borders on the joined roads; the stone walking surface stays calm.
	for r in paths:
		for y in range(r.position.y*T,r.end.y*T):
			for x in range(r.position.x*T,r.end.x*T):
				var p := Vector2i(x,y)
				for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
					var q: Vector2i=p+d*2
					if not Rect2i(Vector2i.ZERO,size).has_point(q) or lane.get_pixelv(q).r<0.5:
						detail.set_pixelv(p,Color.WHITE);break
	# All existing tread faces at the two cliff crossings receive the same bounded internal ink.
	for strip in cliffs:
		for r in paths:
			var crossing: Rect2i = strip.intersection(Rect2i(r.position*T,r.size*T))
			if crossing.has_area():detail.fill_rect(crossing,Color.WHITE)
	# The one-tile margin also protects foundations, approach fans and contact shadows.
	for r in _protected_in(size, places):detail.fill_rect(r,Color.BLACK)
	return [lane, cliff, detail]

static func mask() -> Image:
	_shapes()
	return _detail

## The finish mask a town area's picture takes in the street's shader (Claude, 2026-10-26, lane C, for
## TownLayout's areas): mask()'s cliff ledges and stair crossings for that area, less the lanes' borders off the
## cliffs, as hub_town.gd's _finish_mask makes it for today's map (the lanes fray into the ground instead).
static func street_mask(area: Dictionary) -> Image:
	Tiles.lock.lock()
	Tiles.use_area(area)
	var size := Vector2i(Tiles.cols*T,Tiles.rows*T)
	var m: Image = _build(size, Tiles.paths, _view_cliffs(), Tiles.places)[2]
	for r in Tiles.paths:
		for ty in range(r.position.y, r.end.y):
			if Tiles.band(r.position.x, ty) != "cliff":
				m.fill_rect(Rect2i(r.position.x * T, ty * T, r.size.x * T, T), Color.BLACK)
	Tiles.use_v1()
	Tiles.lock.unlock()
	return m

static func paint(base: Image) -> Image:
	if base.get_size()!=SIZE:return base
	_shapes()
	var result := SelOut.selout(base,_cliff)
	result=SelOut.selout(result,_lane)
	for r in _protected():result.blit_rect(base,r,r.position)
	return result

static func apply(sprite: Sprite2D) -> void:
	if sprite.texture==null or Vector2i(sprite.texture.get_size())!=SIZE:return
	var material := ShaderMaterial.new()
	material.shader=SHADER
	material.set_shader_parameter("detail_mask",ImageTexture.create_from_image(mask()))
	material.set_shader_parameter("detail_ink",0.55)
	sprite.material=material
