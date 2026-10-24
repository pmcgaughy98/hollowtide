extends RefCounted
## Versioned native props and river detail. Missing assets preserve the original code painters.
const DIR="res://assets/sprites/world/town_detail_2026_10_10/"
const SIZES={"lookout":Vector2i(144,96),"landing":Vector2i(288,108),"dock":Vector2i(144,72),"river":Vector2i(384,72),"floor":Vector2i(160,96)} # 12px landing fringe over the existing bank; collision footprint stays 288x96.
const Layout=preload("res://scripts/town/town_layout.gd")
const Selout=preload("res://scripts/art/selout.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
static var cache:Dictionary={}
static func image(id:String)->Image:
	if cache.has(id):return cache[id]
	var path:=DIR+id+"_native.png"
	# Claude, 2026-10-24 (A4, LV-19): UI.res_image reads the imported texture, which an exported game has; the PNG it does not.
	var img:=UI.res_image(path)
	if img==null or img.get_size()!=SIZES[id]:return null
	cache[id]=img
	return img
static func available(id:String)->bool:return image(id)!=null
static func floor_material(base:Image,area:Rect2i)->void:
	var stone:=image("floor")
	if stone==null:return
	# Same authored platform footprint, with the approved interior's native stone clusters.
	for y in area.size.y*Layout.T:
		for x in area.size.x*Layout.T:
			base.set_pixelv(area.position*Layout.T+Vector2i(x,y),stone.get_pixel(x%160,y%96))
static func water(c:Color)->bool:return c.b>c.r*1.25 and c.g>c.r*1.1 and c.b>c.g*0.8
static func river(base:Image)->Image:
	var strip:=image("river")
	if strip==null:return base
	var geometry:=Image.create(384,72,false,Image.FORMAT_RGBA8);geometry.fill(Color.BLACK)
	for y in range(20,38):
		for x in 384:
			var c:=strip.get_pixel(x,y)
			if not water(c) and c.get_luminance()<0.68:geometry.set_pixel(x,y,Color.WHITE)
	var finished:=Selout.selout(strip,geometry)
	var result:=base.duplicate() as Image
	for segment in 3:
		var mask:=Image.create(384,72,false,Image.FORMAT_RGBA8);mask.fill(Color.WHITE)
		for y in 72:
			for x in 384:
				var at:=Vector2i(segment*384+x,696+y)
				# Actual platforms/entrances and every authored path keep their existing floor pixels.
				var protected:=false
				for place in Layout.PLACES:
					if place.id not in ["landing","dock","gate"]:continue
					var area:=Rect2i(place.rect.position*Layout.T,place.rect.size*Layout.T)
					if place.id=="dock":area.size.y+=Layout.T
					if area.has_point(at):protected=true
				for path in Layout.PATHS:
					if path.has_point(at/Layout.T):protected=true
				if protected:mask.set_pixel(x,y,Color.TRANSPARENT)
		result.blend_rect_mask(finished,mask,Rect2i(0,0,384,72),Vector2i(segment*384,696))
	return result
