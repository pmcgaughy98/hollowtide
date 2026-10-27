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

# ---------------------------------------------------------------- the ground being painted (Claude, 2026-10-26, lane C)
## The town's ground painters read the map through this view instead of town_layout.gd's consts, so one set of painters
## paints today's Highbank and any outdoor area of the area format (02-town-rewire-design.md section 3.2;
## HighbankPainter.paint_area). Today's map is the default and is put back after every other paint. Kinds, lanes and
## places are kept per tile, so an area's ground rects need not be whole rows; on today's map every row is one kind and
## each lookup answers exactly what Layout.band_of and the PATHS and PLACES loops did. One paint at a time: a painter
## holds `lock` while it switches the view (Godot's Mutex is recursive, so a painter inside a painter is fine).
const KINDS:=["grass","terrace","cliff","water","hedge"]
static var lock:=Mutex.new()
static var view:="" # the area id the view holds ("highbank_v1" is today's map)
static var cols:int=Layout.W # the map's size in tiles
static var rows:int=Layout.H
static var paths:Array=[] # Rect2i, in tiles
static var places:Array=[] # place dicts: id, kind, rect, door (an area's buildings and lots join as places)
static var cliff_art:={} # a cliff row -> its Codex strip, "cliff" or "cliff_b", alternating from the top
static var _kind:=PackedByteArray() # per tile: an index into KINDS
static var _path:=PackedByteArray() # per tile: 1 on a lane
static var _place:=PackedByteArray() # per tile: 1 inside a place's rect
static var _v1:={} # today's view, built once

static func _static_init()->void:
	use_v1()

## Today's Highbank, from its area file (lane A's highbank_v1.gd, tile for tile what town_layout.gd held): TownLayout's
## lists hold whichever area the town shows once Highbank v2 is on, so today's map is read where it cannot move.
const V1_FILE:="res://scripts/world/areas/highbank_v1.gd"
static func use_v1()->void:
	if _v1.is_empty():
		var a:Dictionary=load(V1_FILE).get_script_constant_map().get("AREA",{}) if ResourceLoader.exists(V1_FILE) else {}
		if a.is_empty(): # the consts, as they were before the area files
			var bands:=[]
			for y in Layout.H:bands.append(Layout.band_of(y))
			_v1=_make(Layout.V1_AREA,Vector2i(Layout.W,Layout.H),Layout.PATHS,Layout.PLACES,func(_x:int,y:int)->String:return bands[y])
		else:
			use_area(a)
			_v1={"id":Layout.V1_AREA,"w":cols,"h":rows,"paths":paths,"places":places,"art":cliff_art,"kind":_kind,"path":_path,"place":_place}
	_use(_v1)

## Any outdoor area as data: size, ground ({bands} as today's map has them, or {base, rects}), paths ({rect, kind} or a
## Rect2i), places, buildings (their base is their rect) and lots (solid, no door yet).
static func use_area(area:Dictionary)->void:
	var size:Vector2i=area.get("size",Vector2i(Layout.W,Layout.H))
	var ground:Dictionary=area.get("ground",{})
	var grid:=PackedStringArray()
	grid.resize(size.x*size.y)
	grid.fill(String(ground.get("base","grass")))
	for b in ground.get("bands",[]):
		for y in range(maxi(0,int(b["from"])),mini(size.y,int(b["to"])+1)):
			for x in size.x:grid[y*size.x+x]=String(b["kind"])
	for r in ground.get("rects",[]):
		var rect:Rect2i=Rect2i(r["rect"]).intersection(Rect2i(Vector2i.ZERO,size))
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x):grid[y*size.x+x]=String(r["kind"])
	var rects:=[]
	for p in area.get("paths",[]):rects.append(p if p is Rect2i else p["rect"])
	var all:=[]
	for p in area.get("places",[]):all.append(p)
	for b in area.get("buildings",[]):
		var doors:Array=b.get("door",[])
		var base:Rect2i=b["base"]
		var door:Vector2i=doors[0] if not doors.is_empty() else Vector2i(base.position.x+base.size.x/2,base.end.y-1)
		all.append({"id":b["id"],"name":b.get("name",""),"kind":"building","rect":base,"door":door,"door_tiles":doors if not doors.is_empty() else [door],"service":b.get("service","")})
	for l in area.get("lots",[]):
		var base:Rect2i=l["base"]
		all.append({"id":l["id"],"kind":"lot","rect":base,"door":l.get("door",Vector2i(base.position.x+base.size.x/2,base.end.y-1))})
	_use(_make(String(area.get("id","")),size,rects,all,func(x:int,y:int)->String:return grid[y*size.x+x]))

static func _make(id:String,size:Vector2i,rects:Array,all:Array,kind_at:Callable)->Dictionary:
	var kinds:=PackedByteArray()
	var on_path:=PackedByteArray()
	var in_place:=PackedByteArray()
	kinds.resize(size.x*size.y)
	on_path.resize(size.x*size.y)
	in_place.resize(size.x*size.y)
	var art:={}
	var cliffs:=0
	for y in size.y:
		var cliff_row:=false
		for x in size.x:
			var k:=KINDS.find(kind_at.call(x,y))
			kinds[y*size.x+x]=k if k>=0 else 0 # an unknown kind paints as grass
			cliff_row=cliff_row or k==2
		if cliff_row:
			art[y]="cliff" if cliffs%2==0 else "cliff_b" # today: row 18 cliff, row 24 cliff_b
			cliffs+=1
	for r in rects:
		var c:Rect2i=Rect2i(r).intersection(Rect2i(Vector2i.ZERO,size))
		for y in range(c.position.y,c.end.y):
			for x in range(c.position.x,c.end.x):on_path[y*size.x+x]=1
	for p in all:
		var c:Rect2i=Rect2i(p["rect"]).intersection(Rect2i(Vector2i.ZERO,size))
		for y in range(c.position.y,c.end.y):
			for x in range(c.position.x,c.end.x):in_place[y*size.x+x]=1
	return {"id":id,"w":size.x,"h":size.y,"paths":rects,"places":all,"art":art,"kind":kinds,"path":on_path,"place":in_place}

static func _use(v:Dictionary)->void:
	view=v["id"];cols=v["w"];rows=v["h"];paths=v["paths"];places=v["places"];cliff_art=v["art"]
	_kind=v["kind"];_path=v["path"];_place=v["place"]

## The ground kind of a tile. Off the top or bottom of the map is water, as Layout.band_of says; off a side, the
## nearest column's kind.
static func band(tx:int,ty:int)->String:
	if ty<0 or ty>=rows:return "water"
	return KINDS[_kind[ty*cols+clampi(tx,0,cols-1)]]

## The first row of the water a tile stands in (its column's water runs up to it): 30 on today's map.
static func water_top(tx:int,ty:int)->int:
	var r:=ty
	while r>0 and band(tx,r-1)=="water":r-=1
	return r

## The rows of a column where the water meets the bank (grass or earth above it): [30] on today's map.
static func banks(tx:int)->Array:
	var out:=[]
	for y in range(1,rows):
		if band(tx,y)=="water" and band(tx,y-1) in ["grass","terrace"]:out.append(y)
	return out

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
	if tx<0 or ty<0 or tx>=cols or ty>=rows:return false
	return _path[ty*cols+tx]==1
static func in_place(tx:int,ty:int)->bool:
	if tx<0 or ty<0 or tx>=cols or ty>=rows:return false
	return _place[ty*cols+tx]==1
static func lane(img:Image,tx:int,ty:int)->bool:
	if not tile(img,"lane",tx,ty):return false
	# A narrow worn verge is inside the authored street mask, never a new walkable road.
	if in_place(tx,ty):return true
	var surface:=image("grass" if band(tx,ty)=="grass" else "earth")
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
	# Every building but the Hall/Tower (Claude, 2026-10-26, lane C: today's home, shop, storage and scrolls); a door
	# on its top row fans north one tile, any other south down to the lane below it (Market Street, row 9, today).
	for place in places:
		if place.kind!="building" or place.id=="hall":continue
		var door:Vector2i=place.door*T
		var north:bool=place.door.y==place.rect.position.y and place.rect.size.y>1
		var start:int=door.y-T if north else door.y+T
		var end:int=door.y if north else _lane_below(place.door)*T
		for y in range(start,end):
			var half:int=11+(door.y-y)/5 if north else 11+(y-start)/4
			var h:=half-1.5+2.5*R._noise(door.x,y,5.0,170)
			for x in range(door.x+12-half-2,door.x+12+half+2):
				if path(x/T,y/T) or in_place(x/T,y/T):continue
				if worn(x,y,door.x+12.0,h):img.set_pixel(x,y,sample(earth,x,y))
## The first lane row below a door, in its column (two rows down when there is none close).
static func _lane_below(door:Vector2i)->int:
	for y in range(door.y+1,mini(rows,door.y+6)):
		if path(door.x,y):return y
	return mini(rows,door.y+2)
static func clearings(img:Image)->void:
	var stone:=image("lane")
	var earth:=image("earth")
	for place in places:
		if place.id=="plaza" and stone!=null:
			var at:Vector2i=place.rect.position*T
			var wide:int=place.rect.size.x*T # 288 on today's map
			# The original broken clearing edge is retained, with the connected lane's material inside.
			for y in range(9,place.rect.size.y*T-17): # rows 9 to 126 on today's map
				var left:int=Crossroads._edge(y)
				var right:int=wide-left-(7 if y>72 else 0)
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
