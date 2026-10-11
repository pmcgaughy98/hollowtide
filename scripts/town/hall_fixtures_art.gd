extends RefCounted
## Native pixel finish over Claude's corrected fixtures. No layout or collision changes.
## Side doors remain five-pixel edges; cases keep their shortened back-wall crops.
const INK := Color("#21180f")
const WOOD := Color("#896036")
const WOOD_LIGHT := Color("#bc9457")
const BRASS := Color("#b99a52")
const STONE := Color("#9d8d6c")
const SIZES := {"hall":Vector2i(528,336),"hall_low":Vector2i(720,432),"chamber":Vector2i(408,264),"runners":Vector2i(336,240)}

static func regions(id: String) -> Array:
	match id:
		"hall":return [Rect2i(336,240,48,48)]
		"hall_low":return [Rect2i(600,312,48,48),Rect2i(0,115,24,58),Rect2i(696,115,24,58),Rect2i(0,187,24,58),Rect2i(650,8,20,62)]
		"chamber":return [Rect2i(26,8,20,62),Rect2i(362,8,20,62)]
		"runners":return [Rect2i(0,115,24,58),Rect2i(308,102,7,4),Rect2i(308,124,7,4)]
	return []

static func paint(id: String, fallback: Image) -> Image:
	if not SIZES.has(id) or fallback.get_size()!=SIZES[id]:return fallback
	var img:=fallback.duplicate() as Image
	match id:
		"hall":_stairs(img,Vector2i(336,240),true)
		"hall_low":
			_stairs(img,Vector2i(600,312),false)
			_door(img,0,120,true);_door(img,696,120,false)
			_hatch(img);_case(img,"supply",650)
		"chamber":_case(img,"keepsakes",26);_case(img,"ledgers",362)
		"runners":
			_door(img,0,120,true)
			for y in [102,124]:
				# Empty hooks seen from above: screw head, short brass neck, shaded tip.
				_rect(img,308,y,7,4,INK)
				_rect(img,309,y,5,1,WOOD_LIGHT)
				_rect(img,309,y+1,5,2,WOOD)
				_rect(img,309,y+1,2,1,BRASS.lightened(0.2))
				_rect(img,308,y+2,3,1,BRASS.darkened(0.3))
	return img

static func add_mask(id: String, img: Image) -> Image:
	if not SIZES.has(id) or img.get_size()!=SIZES[id]:return img
	# Side openings already belong to the wall mask. Select only solid case pixels,
	# stair geometry and the two existing empty pegs, never the surrounding floor.
	if id=="hall":img.fill_rect(Rect2i(336,240,48,48),Color.WHITE)
	elif id=="hall_low":
		img.fill_rect(Rect2i(600,312,48,48),Color.WHITE)
		_case_mask(img,"supply",650)
	elif id=="chamber":
		_case_mask(img,"keepsakes",26);_case_mask(img,"ledgers",362)
	elif id=="runners":
		for y in [102,124]:img.fill_rect(Rect2i(308,y,7,4),Color.WHITE)
	return img

static func _rect(img: Image,x: int,y: int,w: int,h: int,c: Color) -> void:
	img.fill_rect(Rect2i(x,y,w,h).intersection(Rect2i(Vector2i.ZERO,img.get_size())),c)

static func _jamb(img: Image,x: int,y: int) -> void:
	_rect(img,x,y,24,7,INK)
	_rect(img,x,y+1,23,5,STONE.darkened(0.16))
	_rect(img,x+1,y+1,22,1,STONE.lightened(0.2))
	_rect(img,x+1,y+2,22,2,STONE)
	for k in [7,16]:
		_rect(img,x+k,y+2,1,4,INK.lightened(0.12))
		_rect(img,x+k+1,y+2,1,2,STONE.lightened(0.12))
	_rect(img,x+3,y+3,2,1,STONE.lightened(0.09))
	_rect(img,x+20,y+4,2,1,STONE.darkened(0.38))

static func _door(img: Image,x: int,y: int,west: bool) -> void:
	# The opening is a dark overhead passage; the closed leaf is its narrow edge.
	_rect(img,x,y,24,48,Color("#211a11"))
	for k in [3,7,18,22]:
		_rect(img,x+k,y+2,1,44,Color("#30251a"))
		_rect(img,x+k,y+2,1,2,Color("#55422d"))
	_rect(img,x+10,y+1,5,46,INK)
	_rect(img,x+11,y+1,1,45,WOOD_LIGHT)
	_rect(img,x+12,y+2,2,44,WOOD)
	_rect(img,x+13,y+4,1,13,WOOD.darkened(0.22))
	_rect(img,x+12,y+29,1,9,WOOD_LIGHT.darkened(0.12))
	for dy in [7,37]:
		_rect(img,x+10,y+dy,5,3,Color("#373b32"))
		_rect(img,x+11,y+dy,3,1,Color("#737364"))
		_rect(img,x+12,y+dy+1,1,1,BRASS)
	var handle:=x+15 if west else x+8
	_rect(img,handle,y+22,2,4,INK)
	_rect(img,handle,y+23,2,2,BRASS)
	_rect(img,handle,y+23,1,1,BRASS.lightened(0.3))
	_jamb(img,x,y-5);_jamb(img,x,y+46)

static func _hatch(img: Image) -> void:
	# Keep Claude's firelit gap, ten-pixel counter edge and its existing glow.
	for x in [16,21]:
		_rect(img,x,194,1,44,WOOD.darkened(0.3))
		_rect(img,x+1,195,1,8,WOOD_LIGHT)
	_rect(img,16,194,7,1,WOOD_LIGHT.lightened(0.1))
	_rect(img,16,237,7,1,WOOD.darkened(0.45))
	for y in [199,232]:
		_rect(img,18,y,2,1,BRASS.darkened(0.12))
		_rect(img,18,y,1,1,BRASS.lightened(0.15))
	# The pot stays round in overhead view, with an iron lip and two short handles.
	_rect(img,16,215,2,2,Color("#343a35"))
	_rect(img,22,215,2,2,Color("#343a35"))
	_rect(img,18,213,4,1,Color("#a09e83"))
	_rect(img,18,214,1,3,Color("#72766a"))
	_rect(img,19,215,3,2,Color("#282c22"))
	_rect(img,19,215,1,1,Color("#6d7150"))
	_jamb(img,0,187);_jamb(img,0,238)

static func _source(name: String) -> Image:
	var path:="res://assets/sprites/world/hall_floors_2026_10_11/%s.png" % name
	if not FileAccess.file_exists(path):return null
	var src:=Image.load_from_file(ProjectSettings.globalize_path(path))
	if src==null or src.get_width()!=20 or src.get_height()<62:return null
	src.convert(Image.FORMAT_RGBA8)
	return src

static func _case_mask(img: Image,name: String,x: int) -> void:
	var src:=_source(name)
	if src==null:return
	for y in 62:
		var sy:=y if y<56 else src.get_height()-6+y-56
		for dx in 20:
			if src.get_pixel(dx,sy).a>0.5:img.set_pixel(x+dx,8+y,Color.WHITE)

static func _case(img: Image,name: String,x: int) -> void:
	var src:=_source(name)
	if src==null:return # Leave the existing upright fallback untouched.
	# Etched rails and brass fasteners on the existing timber, with shelf contents exact.
	for dx in [2,17]:
		for y in [14,25,38,51,63]:
			if src.get_pixel(dx,y-8).a<0.5:continue
			_rect(img,x+dx,y,1,3,WOOD.darkened(0.25))
			_rect(img,x+dx-1,y,1,1,WOOD_LIGHT)
	for y in [12,35,60]:
		for dx in [3,16]:
			if src.get_pixel(dx,y-8).a>0.5:
				_rect(img,x+dx,y,1,1,BRASS.lightened(0.25))
	_rect(img,x+3,66,14,1,WOOD_LIGHT)
	_rect(img,x+4,67,12,1,WOOD.darkened(0.2))

static func _arch_inside(x: int,y: int,w: int) -> bool:
	var dx:=(float(x)+0.5-w*0.5)/(w*0.5)
	return y>=(1.0-sqrt(maxf(0.0,1.0-dx*dx)))*w*0.5

static func _stairs(img: Image,p: Vector2i,down: bool) -> void:
	var x:=p.x;var y:=p.y
	_rect(img,x,y,48,48,INK)
	var far:=18 if down else 15
	var base:=STONE.darkened(0.62) if down else STONE
	# Cut limestone blocks at the back of the well. Lit arrises, dark mortar joints.
	for dy in far:
		for dx in 38:
			var row:=dy/6
			var joint:=(dx+row*5)%11
			var c:=base
			if dy%6==0 or joint==0:c=base.darkened(0.48)
			elif dy%6==1:c=base.lightened(0.12)
			elif (dx*7+dy*3)%29==0:c=base.darkened(0.15)
			img.set_pixel(x+5+dx,y+2+dy,c)
	# The arch is inside the well: black depth below, warm daylight above.
	for dy in far+2:
		for dx in 24:
			if not _arch_inside(dx,dy,24):continue
			var c:=STONE.darkened(0.38 if down else 0.08)
			if dx<4:c=c.lightened(0.13)
			if dy<4:c=c.lightened(0.15)
			if dx in [5,11,18] and dy<6:c=c.darkened(0.33)
			if dx>=3 and dx<21 and dy>=2 and _arch_inside(dx-3,dy-2,18):
				c=Color("#080704") if down else Color("#fff0bd").lerp(Color("#d0aa60"),float(dy)/(far+2))
			img.set_pixel(x+12+dx,y+dy,c)
	var n:=4 if down else 5
	var step:=7 if down else 6
	for k in n:
		var sy:=y+2+far+k*step
		var lit:=0.28+0.72*pow(float(k+1)/n,1.5) if down else 0.92-0.38*float(k)/n
		var stone:=STONE.lerp(INK,1.0-lit)
		_rect(img,x+5,sy,38,step,stone.darkened(0.18))
		_rect(img,x+5,sy,38,3,stone)
		_rect(img,x+5,sy,38,1,stone.lightened(0.21))
		_rect(img,x+5,sy+step-1,38,1,stone.darkened(0.55))
		# Staggered small chips and tread joints follow the same slab, without floor noise.
		var joint:=x+10+(k*11)%27
		_rect(img,joint,sy+1,1,2,stone.darkened(0.36))
		_rect(img,joint+1,sy+1,1,1,stone.lightened(0.08))
		_rect(img,x+8+(k*7)%25,sy+3,3,1,stone.darkened(0.28))
	# Low rails, with a worn lit inner arris and transverse stone joints.
	for sx in [x,x+43]:
		_rect(img,sx,y,5,45,INK)
		_rect(img,sx+1,y,3,45,STONE.darkened(0.25))
		_rect(img,sx+1,y,1,44,STONE.lightened(0.15))
		for dy in [8,20,32]:
			_rect(img,sx+1,y+dy,3,1,STONE.darkened(0.65))
			_rect(img,sx+1,y+dy+1,2,1,STONE.lightened(0.06))
		_rect(img,sx+1,y+1,3,4,STONE)
		_rect(img,sx+2,y+2,1,1,BRASS)
	# Keep the original landing lip and footprint, with a carved central lozenge.
	_rect(img,x,y+45,48,3,INK)
	_rect(img,x+1,y+45,46,1,STONE.lightened(0.17))
	_rect(img,x+1,y+46,46,1,STONE.darkened(0.12))
	_rect(img,x+23,y+45,2,1,BRASS.lightened(0.1))
	_rect(img,x+22,y+46,4,1,BRASS.darkened(0.18))
