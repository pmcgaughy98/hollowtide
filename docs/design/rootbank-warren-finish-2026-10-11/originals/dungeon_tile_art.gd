extends RefCounted
## Authored native 24px terrain. Neighbour rules select silhouettes, never blur a floor.
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const Rim := preload("res://scripts/art/selout.gd")
const T := 24
const FOLDER := "res://assets/tilesets/dungeon_tiles_2026_10_10/"
const DIRS := [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1)]
static var cache: Dictionary = {}

static func palette(look: String) -> Dictionary:
	var values := ["86674d","87684e","88694f","85664c","81634b","3a4532","4b5740","785638","8b6543","6b4d34","a9875f","b79768","1e221d","3d2b21","785737","536440","6a7c4e","425137","4c5d3b","9a8060","b49a72","4f4030","574330","191713"] if look == "riverbank" else ["526269","53636a","54646b","516168","4e5d64","34484b","486063","52656b","60747a","405359","83999d","a2b7b5","101c24","254345","446761","365c58","517971","284640","315651","687d80","91a6a5","293a42","31464b","121b22"]
	var names := ["floor0","floor1","floor2","floor3","grid","cap","cap_lit","face0","face1","face2","face_lit","lip","ink","root","root_lit","grass","grass_lit","grass_shade","grass_grid","pebble","pebble_lit","pebble_shadow","contact","stairs"]
	var p := {}
	for i in names.size(): p[names[i]] = Color("#"+values[i])
	return p

static func hash_at(x: int, y: int, seed: int) -> int:
	return absi((x*73856093) ^ (y*19349663) ^ (seed*83492791))

static func open_at(data: Dictionary, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < data.w and y < data.h and data.tiles[y*data.w+x] != Gen.WALL

static func neighbours(data: Dictionary, x: int, y: int) -> int:
	var bits := 0
	for i in 8:
		if open_at(data,x+DIRS[i].x,y+DIRS[i].y): bits |= 1 << i
	return bits

static func grass_case(bits: int) -> int:
	# A diagonal is meaningful only when both of its edge neighbours exist.
	for pair in [[16,1,2],[32,2,4],[64,4,8],[128,8,1]]:
		if (bits & pair[1]) == 0 or (bits & pair[2]) == 0: bits &= ~pair[0]
	return bits

static func rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	var r := Rect2i(x,y,w,h).intersection(Rect2i(Vector2i.ZERO,img.get_size()))
	if r.has_area(): img.fill_rect(r,c)

static func build_tile(look: String, kind: String, index: int) -> Image:
	var p := palette(look)
	var img := Image.create(T,T,false,Image.FORMAT_RGBA8)
	if kind == "decor":
		img.fill(Color.TRANSPARENT)
		# One deliberately grouped pebble/root cluster, confined to the wall margin.
		for r in [[5,1,8,1,"root"],[8,2,1,3,"root"],[9,4,3,1,"root_lit"],[16,2,4,3,"pebble_shadow"],[16,2,3,2,"pebble"],[16,2,2,1,"pebble_lit"],[20,4,2,2,"pebble_shadow"]]:
			rect(img,r[0],r[1],r[2],r[3],p[r[4]])
		for k in index: img.rotate_90(CLOCKWISE)
		# Re-light the rotated cluster in world space: upper/left faces always catch the light.
		var original := img.duplicate() as Image
		for y in T:
			for x in T:
				var c := original.get_pixel(x,y)
				if c.a < 0.5: continue
				var stone: bool = c in [p.pebble,p.pebble_lit,p.pebble_shadow]
				if not stone: continue
				var upper := y==0 or original.get_pixel(x,y-1).a<0.5
				var left := x==0 or original.get_pixel(x-1,y).a<0.5
				var lower := y==23 or original.get_pixel(x,y+1).a<0.5
				img.set_pixel(x,y,p.pebble_lit if upper or left else (p.pebble_shadow if lower else p.pebble))
		return img
	img.fill(p["floor"+str(index % 4)] if kind == "floor" else p.floor0)
	if kind == "floor":
		# Broad close-valued clay/slate wear, never per-pixel noise or scattered stones.
		if index == 1: rect(img,5,8,6,2,p.floor0)
		if index == 2: rect(img,13,14,5,2,p.floor1)
		rect(img,23,0,1,24,p.grid);rect(img,0,23,24,1,p.grid)
		return img
	if kind == "grass":
		rect(img,23,0,1,24,p.grid);rect(img,0,23,24,1,p.grid)
		var bits := grass_case(index)
		var x0 := 0 if bits & 8 else 4
		var x1 := 24 if bits & 2 else 20
		var y0 := 0 if bits & 1 else 4
		var y1 := 24 if bits & 4 else 20
		var shape := Image.create(T,T,false,Image.FORMAT_RGBA8);shape.fill(Color.BLACK)
		rect(shape,x0,y0,x1-x0,y1-y0,Color.WHITE)
		for corner in [[x0,y0,8,1,128],[x1-3,y0,2,1,16],[x1-3,y1-3,2,4,32],[x0,y1-3,8,4,64]]:
			if not bits & corner[2] and not bits & corner[3]:
				# Convex clipped corners.
				var cx: int = corner[0];var cy: int = corner[1]
				for yy in 3:
					for xx in 3:
						var dx := xx if cx == x0 else 2-xx
						var dy := yy if cy == y0 else 2-yy
						if dx+dy<2: shape.set_pixel(cx+xx,cy+yy,Color.BLACK)
			elif bits & corner[2] and bits & corner[3] and not bits & corner[4]:
				rect(shape,corner[0],corner[1],3,3,Color.BLACK)
		for y in T:
			for x in T:
				if shape.get_pixel(x,y).r < 0.5: continue
				var c: Color = p.grass
				if (x>0 and shape.get_pixel(x-1,y).r<0.5) or (y>0 and shape.get_pixel(x,y-1).r<0.5): c=p.grass_lit
				if (x<T-1 and shape.get_pixel(x+1,y).r<0.5) or (y<T-1 and shape.get_pixel(x,y+1).r<0.5): c=p.grass_shade
				if x==23 or y==23: c=p.grass_grid
				img.set_pixel(x,y,c)
		# Two short blades in the turf mass; no dotted outline.
		rect(img,10,9,1,3,p.grass_lit);rect(img,11,11,2,1,p.grass_lit)
		rect(img,15,16,2,1,p.grass_shade)
		return img
	# Walls: an unbroken cap, a bevelled lip and sixteen pixels of south face.
	img.fill(p.cap)
	if index & 4:
		rect(img,0,0,24,6,p.cap);rect(img,0,5,24,1,p.cap_lit)
		rect(img,0,6,24,1,p.lip);rect(img,0,7,24,1,p.ink)
		rect(img,0,8,24,14,p.face0);rect(img,0,22,24,2,p.face2)
		if look == "riverbank":
			rect(img,0,11,24,1,p.face1);rect(img,0,16,24,1,p.face2)
			rect(img,5,8,2,7,p.root);rect(img,7,14,4,1,p.root_lit)
		elif look == "ruin":
			rect(img,0,14,24,1,p.face2);rect(img,0,15,24,1,p.face1)
			rect(img,8,8,1,6,p.face2);rect(img,19,16,1,6,p.face2)
			rect(img,0,8,24,1,p.face_lit)
		else:
			rect(img,0,13,8,1,p.face2);rect(img,8,14,10,1,p.face2);rect(img,18,13,6,1,p.face2)
			rect(img,8,9,1,5,p.face2);rect(img,18,14,1,7,p.face2)
			rect(img,1,8,10,1,p.face_lit)
	if index & 8:
		rect(img,0,0,4,24,p.face0);rect(img,4,0,1,24,p.lip);rect(img,5,0,1,24,p.ink)
		rect(img,0,0,1,24,p.face_lit)
	if index & 2:
		rect(img,18,0,1,24,p.cap_lit);rect(img,19,0,1,24,p.ink);rect(img,20,0,4,24,p.face2)
	if index & 1:
		rect(img,0,0,24,3,p.face2);rect(img,0,3,24,1,p.cap_lit)
	# Inside corner notches also show height; diagonals never dissolve into blur.
	for corner in [[16,2,1,20,0],[32,2,4,20,20],[64,8,4,0,20],[128,8,1,0,0]]:
		if index & corner[0] and not index & corner[1] and not index & corner[2]:
			rect(img,corner[3],corner[4],4,4,p.face2)
			rect(img,corner[3],corner[4],4,1,p.cap_lit)
	return img

static func tile(look: String, kind: String, index: int) -> Image:
	var key := look+"_"+kind
	if not cache.has(key):
		var path := FOLDER+key+".png"
		cache[key] = Image.load_from_file(ProjectSettings.globalize_path(path)) if FileAccess.file_exists(path) else null
	var atlas: Image = cache[key]
	var cols := 4 if kind in ["floor","decor"] else 16
	if atlas != null and atlas.get_size() == Vector2i(cols*T,T if cols == 4 else 16*T):
		return atlas.get_region(Rect2i((index % cols)*T,(index / cols)*T,T,T))
	return build_tile(look,kind,index)

static func paint(data: Dictionary, t: int, seed: int, look: String) -> Image:
	assert(t == T)
	var p := palette(look)
	var img := Image.create(data.w*T,data.h*T,false,Image.FORMAT_RGBA8)
	var mask := Image.create(img.get_width(),img.get_height(),false,Image.FORMAT_RGBA8);mask.fill(Color.BLACK)
	var grass := {}
	for y in data.h:
		for x in data.w:
			if not open_at(data,x,y) or Vector2i(x,y)==data.stairs: continue
			var b := neighbours(data,x,y)
			# Perimeter patches belong to rooms, never the central walking surface or narrow passages.
			if b & 5 and b & 10 and (b & 15)!=15 and hash_at(x/2,y/2,seed)%4==0:
				grass[Vector2i(x,y)]=true
	for y in data.h:
		for x in data.w:
			var at := Vector2i(x*T,y*T)
			var b := neighbours(data,x,y)
			if not open_at(data,x,y):
				img.blit_rect(tile(look,"wall",b),Rect2i(0,0,T,T),at)
				mask.fill_rect(Rect2i(at,Vector2i(T,T)),Color.WHITE)
				continue
			var terrain := tile(look,"floor",hash_at(x,y,seed)%4)
			if grass.has(Vector2i(x,y)):
				var gb := 0
				for i in 8:
					if grass.has(Vector2i(x,y)+DIRS[i]): gb |= 1 << i
				terrain=tile(look,"grass",gb)
			img.blit_rect(terrain,Rect2i(0,0,T,T),at)
			if not open_at(data,x,y-1): rect(img,at.x,at.y,T,1,p.contact)
			if not open_at(data,x-1,y): rect(img,at.x,at.y,1,T,p.contact)
			if Vector2i(x,y)!=data.stairs and hash_at(x,y,seed+17)%5==0:
				for i in 4:
					if not open_at(data,x+DIRS[i].x,y+DIRS[i].y):
						img.blend_rect(tile(look,"decor",i),Rect2i(0,0,T,T),at);break
	# Preserve the original stairs' exact 24x20 footprint and three descending treads.
	var st: Vector2i = data.stairs*T+Vector2i(0,2)
	rect(img,st.x,st.y,24,20,p.ink);rect(img,st.x+2,st.y+2,20,16,p.stairs)
	for i in 3:
		rect(img,st.x+4,st.y+4+i*4,16,1,p.lip)
		rect(img,st.x+4,st.y+5+i*4,16,2,p.face0)
	mask.fill_rect(Rect2i(st,Vector2i(24,20)),Color.WHITE)
	return Rim.selout(img,mask)
