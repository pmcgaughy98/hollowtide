extends RefCounted
## Presentation only. Flood height, current, wet status and save data stay with
## dungeon.gd. No surface is painted outside the existing explored wet tiles.
const DIR := "res://assets/sprites/world/rising_water_2026_10_14/"
static var _loaded := false
static var _ripples: Texture2D
static var _shoreline: Texture2D

static func _ready_art() -> bool:
	if not _loaded:
		_loaded=true
		if ResourceLoader.exists(DIR+"ripples.png") and ResourceLoader.exists(DIR+"shoreline.png"):
			_ripples=load(DIR+"ripples.png")
			_shoreline=load(DIR+"shoreline.png")
	return _ripples!=null and _shoreline!=null and _ripples.get_size()==Vector2(192,96) and _shoreline.get_size()==Vector2(192,32)

static func draw(dg: Node2D, canvas: CanvasItem) -> bool:
	if dg.T!=24 or not _ready_art():return false
	var phase := int(Time.get_ticks_msec()/400)%4
	var top: int = dg.water_base-dg.water_rows
	for y in range(top,dg.water_base):
		for x in dg.data.w:
			var p := Vector2i(x,y)
			if not dg._floor_at(p) or not (dg.visible_tiles.has(p) or dg.explored[y*dg.data.w+x]!=0):continue
			var r := Rect2(Vector2(p)*dg.T,Vector2(dg.T,dg.T))
			var deep: float = float(y-top+1)/float(dg.water_rows)
			# Preserve the existing transparent depth wash, so the meadow and
			# slabs remain legible below the painted current and silt edge.
			canvas.draw_rect(r,Color(0.25,0.5,0.85,0.3+0.2*deep))
			var tile_phase := posmod(x+(y%3)*3,8)*24
			canvas.draw_texture_rect_region(_ripples,r,Rect2(tile_phase,phase*24,24,24))
			if y==top:
				canvas.draw_texture_rect_region(_shoreline,Rect2(r.position,Vector2(24,8)),Rect2(posmod(x,8)*24,phase*8,24,8))
	return true
