extends RefCounted
## Versioned native props and river detail. Missing assets preserve the original code painters.
const DIR="res://assets/sprites/world/town_detail_2026_10_10/"
const SIZES={"lookout":Vector2i(144,96),"landing":Vector2i(288,108),"dock":Vector2i(144,72),"river":Vector2i(384,72),"floor":Vector2i(160,96)} # 12px landing fringe over the existing bank; collision footprint stays 288x96.
const Layout=preload("res://scripts/town/town_layout.gd")
const Tiles=preload("res://scripts/town/world_tile_art.gd") # the ground being painted (lane C, 2026-10-26)
const Selout=preload("res://scripts/art/selout.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
static var cache:Dictionary={}
static var _finished:Image # the river strip with its sel-out
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
## The river strip along the water at the map's foot (Claude, 2026-10-26, lane C: from the painted view's water, so any
## outdoor area with a river at its foot gets it; today's map is unchanged, the strip at y 696 in three 384 px segments).
static func river(base:Image)->Image:
	var strip:=image("river")
	if strip==null:return base
	var top:=_river_row()
	if top<1:return base
	var y0:=(top-1)*Layout.T # 696 on today's map
	if _finished==null: # the strip's sel-out, made once (Claude, 2026-10-26, lane C: the same pixels, a tenth of a second a paint)
		var geometry:=Image.create(384,72,false,Image.FORMAT_RGBA8);geometry.fill(Color.BLACK)
		for y in range(20,38):
			for x in 384:
				var c:=strip.get_pixel(x,y)
				if not water(c) and c.get_luminance()<0.68:geometry.set_pixel(x,y,Color.WHITE)
		_finished=Selout.selout(strip,geometry)
	var finished:=_finished
	var result:=base.duplicate() as Image
	for segment in ceili(Tiles.cols*Layout.T/384.0): # three on today's map
		var mask:=Image.create(384,72,false,Image.FORMAT_RGBA8);mask.fill(Color.WHITE)
		# Actual platforms/entrances and every authored path keep their existing floor pixels. (Claude, 2026-10-26, lane C:
		# the same pixels cleared as rects, not tested one by one; the river took a third of a second of the street's paint.)
		var window:=Rect2i(segment*384,y0,384,72)
		var keep:=[]
		for place in Tiles.places:
			if place.id not in ["landing","dock","gate"]:continue
			var area:=Rect2i(place.rect.position*Layout.T,place.rect.size*Layout.T)
			if place.id=="dock":area.size.y+=Layout.T
			keep.append(area)
		for path in Tiles.paths:keep.append(Rect2i(path.position*Layout.T,path.size*Layout.T))
		for r:Rect2i in keep:
			var cut:=r.intersection(window)
			if cut.has_area():mask.fill_rect(Rect2i(cut.position-window.position,cut.size),Color.TRANSPARENT)
		result.blend_rect_mask(finished,mask,Rect2i(0,0,384,72),Vector2i(segment*384,y0))
	return result
## The first row of the water at the foot of the painted map (30 today), or -1 when its foot is not water.
static func _river_row()->int:
	var r:=Tiles.rows
	while r>0 and Tiles.band(0,r-1)=="water":r-=1
	return r if r<Tiles.rows else -1
