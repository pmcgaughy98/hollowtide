extends RefCounted
## First creature-era terrain pass. Original Hollowtide terrain atlas with
## native 24px bank pieces. Decoration never changes the generator's topology.
const Gen = preload("res://scripts/hollow/hollow_gen.gd")
const ATLAS = "res://assets/tilesets/hollow_bank_2026_10_09/terrain_24.png"
const INK = Color("#20282a")
const TOP = [Color("#343e38"),Color("#3d493f"),Color("#485143")]
const CLAY = [Color("#a38a65"),Color("#816a50"),Color("#6b5544"),Color("#4e443b")]

static func floor_at(d: Dictionary,x:int,y:int) -> bool:
	return x>=0 and y>=0 and x<d.w and y<d.h and d.tiles[y*d.w+x]!=Gen.WALL

static func paint(d: Dictionary,t:int,seed_value:int) -> Image:
	var img := Image.create(d.w*t,d.h*t,false,Image.FORMAT_RGBA8)
	var source: Image = load(ATLAS).get_image()
	source.convert(Image.FORMAT_RGBA8)
	for y in d.h:
		for x in d.w:
			var p := Vector2i(x*t,y*t)
			if floor_at(d,x,y):
				# A continuous texture coordinate field avoids a visible tile grid.
				for py in t:
					for px in t:
						var gx:int = x*t+px
						var gy:int = y*t+py
						var field:float=sin(gx*0.027+seed_value%17)+cos(gy*0.031)+0.4*sin((gx+gy)*0.055)
						var uv := Vector2i(posmod(gx,24),posmod(gy,24))
						var tile:=Vector2i(3,3)
						if field>1.1:tile=Vector2i(1,0)
						elif field < -1.6:tile=Vector2i(2,0)
						var c := source.get_pixelv(tile*24+uv)
						img.set_pixelv(p+Vector2i(px,py),c)
			else:
				var wall_tile:=Vector2i(0,1) if posmod(x+y,3)==0 else Vector2i(2,3)
				img.blit_rect(source,Rect2i(wall_tile*24,Vector2i(24,24)),p)
				darken(img,Rect2i(p,Vector2i(24,24)),0.48)
	# Neighbour-aware edges are painted after all surfaces so corners meet cleanly.
	for y in d.h:
		for x in d.w:
			var p := Vector2i(x*t,y*t)
			if floor_at(d,x,y):
				if not floor_at(d,x,y-1):
					for k in 3:darken(img,Rect2i(p+Vector2i(0,k),Vector2i(t,1)),0.60+0.12*k)
				continue
			var n:=floor_at(d,x,y-1)
			var s:=floor_at(d,x,y+1)
			var w:=floor_at(d,x-1,y)
			var e:=floor_at(d,x+1,y)
			if n:
				img.fill_rect(Rect2i(p,Vector2i(t,2)),INK)
				img.fill_rect(Rect2i(p+Vector2i(1,2),Vector2i(t-2,1)),CLAY[1])
			if w:
				img.fill_rect(Rect2i(p,Vector2i(2,t)),INK)
				img.fill_rect(Rect2i(p+Vector2i(2,2),Vector2i(1,t-3)),CLAY[1])
			if e:
				img.fill_rect(Rect2i(p+Vector2i(t-2,0),Vector2i(2,t)),INK)
				img.fill_rect(Rect2i(p+Vector2i(t-3,2),Vector2i(1,t-3)),CLAY[0])
			if s:
				var cliff:=Vector2i(2 if posmod(x+y+seed_value,4)==0 else 1,1)
				img.blit_rect(source,Rect2i(cliff*24,Vector2i(24,24)),p)
				img.fill_rect(Rect2i(p+Vector2i(0,t-1),Vector2i(t,1)),INK)
			# Diagonal openings get inset corner caps, including enclosed inner corners.
			for corner in [Vector2i(-1,-1),Vector2i(1,-1),Vector2i(-1,1),Vector2i(1,1)]:
				if floor_at(d,x+corner.x,y+corner.y) and not floor_at(d,x+corner.x,y) and not floor_at(d,x,y+corner.y):
					var at:=p+Vector2i(0 if corner.x<0 else t-3,0 if corner.y<0 else t-3)
					img.fill_rect(Rect2i(at,Vector2i(3,3)),INK)
	# Stone-edged descending stairs remain fully within their walkable tile.
	var st:Vector2i=d.stairs*t
	img.blit_rect(source,Rect2i(0,72,24,24),st)
	return img

static func darken(img:Image,r:Rect2i,k:float) -> void:
	for y in range(r.position.y,r.end.y):
		for x in range(r.position.x,r.end.x):
			var c:=img.get_pixel(x,y)
			img.set_pixel(x,y,Color(c.r*k,c.g*k,c.b*k))
