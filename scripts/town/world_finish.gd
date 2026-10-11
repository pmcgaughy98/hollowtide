extends RefCounted
## Highbank terrain sel-out. Connected lane borders and exposed cliffs only;
## existing landmark art, river/glints and quiet floor interiors stay untouched.
const Layout := preload("res://scripts/town/town_layout.gd")
const SelOut := preload("res://scripts/art/selout.gd")
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const T := Layout.T
const SIZE := Vector2i(Layout.W*T,Layout.H*T)
static var _lane: Image
static var _cliff: Image
static var _detail: Image

static func _protected() -> Array:
	var rects := []
	for p in Layout.PLACES:
		var tiles: Rect2i = p["rect"].grow(1)
		rects.append(Rect2i(tiles.position*T,tiles.size*T).intersection(Rect2i(Vector2i.ZERO,SIZE)))
	return rects

static func _shapes() -> void:
	if _detail != null: return
	_lane=Image.create(SIZE.x,SIZE.y,false,Image.FORMAT_RGBA8);_lane.fill(Color.BLACK)
	_cliff=Image.create(SIZE.x,SIZE.y,false,Image.FORMAT_RGBA8);_cliff.fill(Color.BLACK)
	for r in Layout.PATHS:
		_lane.fill_rect(Rect2i(r.position*T,r.size*T),Color.WHITE)
	for band in Layout.BANDS:
		if band["kind"]=="cliff":
			_cliff.fill_rect(Rect2i(0,band["from"]*T,SIZE.x,(band["to"]-band["from"]+1)*T),Color.WHITE)
	# Stair channels divide the cliff silhouette. Do not outline the individual24px tiles.
	for r in Layout.PATHS:
		_cliff.fill_rect(Rect2i(r.position*T,r.size*T),Color.BLACK)
	_detail=_cliff.duplicate() as Image
	# Narrow outside borders on the joined roads; the stone walking surface stays calm.
	for r in Layout.PATHS:
		for y in range(r.position.y*T,r.end.y*T):
			for x in range(r.position.x*T,r.end.x*T):
				var p := Vector2i(x,y)
				for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
					var q: Vector2i=p+d*2
					if not Rect2i(Vector2i.ZERO,SIZE).has_point(q) or _lane.get_pixelv(q).r<0.5:
						_detail.set_pixelv(p,Color.WHITE);break
	# All existing tread faces at the two cliff crossings receive the same bounded internal ink.
	for band in Layout.BANDS:
		if band["kind"]!="cliff":continue
		var strip := Rect2i(0,band["from"]*T,SIZE.x,(band["to"]-band["from"]+1)*T)
		for r in Layout.PATHS:
			var crossing := strip.intersection(Rect2i(r.position*T,r.size*T))
			if crossing.has_area():_detail.fill_rect(crossing,Color.WHITE)
	# The one-tile margin also protects foundations, approach fans and contact shadows.
	for r in _protected():_detail.fill_rect(r,Color.BLACK)

static func mask() -> Image:
	_shapes()
	return _detail

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
