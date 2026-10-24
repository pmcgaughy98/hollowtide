extends RefCounted
## Native terrain materials; global pixel phase keeps joined paths and neighbouring tiles continuous.
const DIR="res://assets/sprites/world/world_tiles_2026_10_10/"
const Layout=preload("res://scripts/town/town_layout.gd")
const Crossroads=preload("res://scripts/town/crossroads_painter.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
const R=preload("res://scripts/dungeon/ruin_painter.gd") # hash and noise
const BAYER=[0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5] # 4 x 4 ordered dither
const T=Layout.T
const SIZES={"grass":Vector2i(192,192),"earth":Vector2i(192,192),"lane":Vector2i(192,192),"cliff":Vector2i(192,24),"cliff_b":Vector2i(192,24)}
static var cache:Dictionary={}
static func image(id:String)->Image:
	if cache.has(id):return cache[id]
	if not SIZES.has(id):return null
	var path:=DIR+id+"_native.png"
	# Claude, 2026-10-24 (A4, LV-19): UI.res_image reads the imported texture, which an exported game has; the PNG it does not.
	var source:=UI.res_image(path)
	if source==null or source.get_size()!=SIZES[id]:return null
	cache[id]=source
	return source
static func sample(source:Image,x:int,y:int)->Color:
	return source.get_pixel(posmod(x,source.get_width()),posmod(y,source.get_height()))
static func tile(img:Image,id:String,tx:int,ty:int)->bool:
	var source:=image(id)
	if source==null:return false
	var from:=Vector2i(posmod(tx*T,source.get_width()),posmod(ty*T,source.get_height()))
	img.blit_rect(source,Rect2i(from,Vector2i(T,T)),Vector2i(tx*T,ty*T))
	return true
static func path(tx:int,ty:int)->bool:
	for rect in Layout.PATHS:
		if rect.has_point(Vector2i(tx,ty)):return true
	return false
static func in_place(tx:int,ty:int)->bool:
	for place in Layout.PLACES:
		if place.rect.has_point(Vector2i(tx,ty)):return true
	return false
static func lane(img:Image,tx:int,ty:int)->bool:
	if not tile(img,"lane",tx,ty):return false
	# A narrow worn verge is inside the authored street mask, never a new walkable road.
	if in_place(tx,ty):return true
	var surface:=image("grass" if Layout.band_of(ty)=="grass" else "earth")
	if surface==null:return true
	for py in T:
		for px in T:
			var edge:=((px<2 and not path(tx-1,ty)) or (px>T-3 and not path(tx+1,ty)) or (py<2 and not path(tx,ty-1)) or (py>T-3 and not path(tx,ty+1)))
			if edge:
				var at:=Vector2i(tx*T+px,ty*T+py)
				img.set_pixelv(at,sample(surface,at.x,at.y))
	return true
static func steps(img:Image,tx:int,ty:int)->void:
	if not tile(img,"lane",tx,ty):return
	for row in 4:
		img.fill_rect(Rect2i(tx*T,ty*T+row*6,T,1),Color("#d0b891"))
		img.fill_rect(Rect2i(tx*T,ty*T+row*6+4,T,2),Color("#665a45"))
## Whether pixel (x, y) is on a worn patch `half` px either side of `cx` at its row: solid from 1 px in, ordered
## dither over the 2 px about its edge, so a worn edge meets the grass in pixels, not a ruled blend (Claude, 2026-10-24, A1).
static func worn(x:int,y:int,cx:float,half:float)->bool:
	var k:=half-absf(x+0.5-cx)
	return k>=1.0 or (k>-1.0 and (k+1.0)*0.5>(BAYER[posmod(y,4)*4+posmod(x,4)]+0.5)/16.0)
static func aprons(img:Image)->void:
	var earth:=image("earth")
	if earth==null:return
	# The exterior_ground fan's footprint; thresholds, foundation and doors stay untouched. Its sides were a ruled
	# 45% blend 2 px wide; now they wander a px or two and dither into the grass (Claude, 2026-10-24, A1).
	for place in Layout.PLACES:
		if place.id not in ["home","shop","storage","scrolls"]:continue
		var door:Vector2i=place.door*T
		var north:bool=place.id=="scrolls"
		var start:int=door.y-T if north else door.y+T
		var end:int=door.y if north else 9*T
		for y in range(start,end):
			var half:int=11+(door.y-y)/5 if north else 11+(y-start)/4
			var h:=half-1.5+2.5*R._noise(door.x,y,5.0,170)
			for x in range(door.x+12-half-2,door.x+12+half+2):
				if path(x/T,y/T) or in_place(x/T,y/T):continue
				if worn(x,y,door.x+12.0,h):img.set_pixel(x,y,sample(earth,x,y))
static func clearings(img:Image)->void:
	var stone:=image("lane")
	var earth:=image("earth")
	for place in Layout.PLACES:
		if place.id=="plaza" and stone!=null:
			var at:Vector2i=place.rect.position*T
			# The original broken clearing edge is retained, with the connected lane's material inside.
			for y in range(9,127):
				var left:int=Crossroads._edge(y)
				var right:int=288-left-(7 if y>72 else 0)
				for x in range(left,right):
					var pos:=at+Vector2i(x,y)
					if path(pos.x/T,pos.y/T):continue
					var edge:=mini(x-left,right-1-x)
					var c:=sample(stone,pos.x,pos.y)
					img.set_pixelv(pos,img.get_pixelv(pos).lerp(c,0.38) if edge<3 else c)
		if place.id=="board" and earth!=null:
			var at:Vector2i=place.door*T
			# The reading pad covers its tile and its sides wander 1 to 3 px out into the grass, dithered, where they
			# were ruled 42% blends down the tile's edges (Claude, 2026-10-24, A1). The board and the street bound it.
			for y in T:
				var h:=13.0+2.0*R._noise(at.x,at.y+y,5.0,171)
				for x in range(-4,T+4):
					var pos:=at+Vector2i(x,y)
					if path(pos.x/T,pos.y/T) or in_place(pos.x/T,pos.y/T):continue
					if worn(pos.x,pos.y,at.x+12.0,h):img.set_pixelv(pos,sample(earth,pos.x,pos.y))
