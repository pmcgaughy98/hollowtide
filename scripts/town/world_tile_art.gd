extends RefCounted
## Native terrain materials; global pixel phase keeps joined paths and neighbouring tiles continuous.
const DIR="res://assets/sprites/world/world_tiles_2026_10_10/"
const Layout=preload("res://scripts/town/town_layout.gd")
const Crossroads=preload("res://scripts/town/crossroads_painter.gd")
const T=Layout.T
const SIZES={"grass":Vector2i(192,192),"earth":Vector2i(192,192),"lane":Vector2i(192,192),"cliff":Vector2i(192,24),"cliff_b":Vector2i(192,24)}
static var cache:Dictionary={}
static func image(id:String)->Image:
	if cache.has(id):return cache[id]
	if not SIZES.has(id):return null
	var path:=DIR+id+"_native.png"
	if not FileAccess.file_exists(path):return null
	var source:=Image.load_from_file(ProjectSettings.globalize_path(path))
	if source==null or source.get_size()!=SIZES[id]:return null
	source.convert(Image.FORMAT_RGBA8);cache[id]=source
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
static func aprons(img:Image)->void:
	var earth:=image("earth")
	if earth==null:return
	# Match the existing exterior_ground fan exactly; thresholds, foundation and doors stay untouched.
	for place in Layout.PLACES:
		if place.id not in ["home","shop","storage","scrolls"]:continue
		var door:Vector2i=place.door*T
		var north:bool=place.id=="scrolls"
		var start:int=door.y-T if north else door.y+T
		var end:int=door.y if north else 9*T
		for y in range(start,end):
			var half:int=11+(door.y-y)/5 if north else 11+(y-start)/4
			for x in range(door.x+12-half,door.x+12+half):
				var c:=sample(earth,x,y)
				var edge:=absi(x-door.x-12)>=half-2
				img.set_pixel(x,y,img.get_pixel(x,y).lerp(c,0.45) if edge else c)
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
			for y in T:
				for x in T:
					var c:=sample(earth,at.x+x,at.y+y)
					img.set_pixelv(at+Vector2i(x,y),img.get_pixelv(at+Vector2i(x,y)).lerp(c,0.42) if mini(x,T-1-x)<2 else c)
