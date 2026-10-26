extends RefCounted
## Presentation only. Flood height, current, wet status and save data stay with
## dungeon.gd. No surface is painted outside the existing explored wet tiles.
## The edge and the depth (Claude, 2026-10-26, pass 7 F3, L7-14; the live run read the water as one flat teal band with
## the meadow showing through it): the first row is the shallows, the floor faint under its top third only; every row
## below is opaque, each a band darker than the one above; a band gives way to the next partway down a row, never on
## the tile line, and every band edge wavers by a pixel. A broken foam line, one pixel with a second where it gathers,
## runs along the top edge and moves on every turn; a few short dashes catch the light on the deeper rows. Codex's
## ripple sheet still moves over all of it as the current; its shoreline sheet is no longer drawn.
const R := preload("res://scripts/dungeon/ruin_painter.gd")   # its hash
const DIR := "res://assets/sprites/world/rising_water_2026_10_14/"
const SHALLOW := Color("#6aa39c")
const DEPTH := [Color("#4d8a88"), Color("#3c7479"), Color("#30626b"), Color("#27525d"), Color("#20444f")]
const FOAM := Color("#dcefe6")
const FOAM_DIM := Color("#a8d2c6")
const GLINT := Color("#a9d9cf")
const FOAM_SEG := 3   # the foam is laid in runs of this many pixels, each on, off or doubled
const BAND_SEG := 4   # the bands' strips, each its own height
static var _loaded := false
static var _ripples: Texture2D

static func _ready_art() -> bool:
	if not _loaded:
		_loaded=true
		if ResourceLoader.exists(DIR+"ripples.png"):
			_ripples=load(DIR+"ripples.png")
	return _ripples!=null and _ripples.get_size()==Vector2(192,96)

static func draw(dg: Node2D, canvas: CanvasItem) -> bool:
	if dg.T!=24 or not _ready_art():return false
	var phase := int(Time.get_ticks_msec()/400)%4
	var top: int = dg.water_base-dg.water_rows
	var turn: int = dg.turn
	for y in range(top,dg.water_base):
		var row := y-top
		var band: Color = DEPTH[mini(row,DEPTH.size()-1)]
		var prev: Color = DEPTH[maxi(0,mini(row-1,DEPTH.size()-1))]
		for x in dg.data.w:
			var p := Vector2i(x,y)
			if not dg._floor_at(p) or not (dg.visible_tiles.has(p) or dg.explored[y*dg.data.w+x]!=0):continue
			var o: Vector2 = Vector2(p)*dg.T
			var r := Rect2(o,Vector2(dg.T,dg.T))
			# The bands, in strips BAND_SEG wide whose edges rise and fall a pixel, drifting a little each turn, so no
			# edge runs ruler-straight across the water.
			for s in 24/BAND_SEG:
				var sx := o.x+s*BAND_SEG
				if row==0:
					# The shallows: the floor faint under the top third, then halfway to the first band, then the band.
					var hi := 8+roundi(sin((x*24+s*BAND_SEG)*0.29+turn*0.6+2.0))
					var lo := 16+roundi(sin((x*24+s*BAND_SEG)*0.21+turn*0.6))
					canvas.draw_rect(Rect2(sx,o.y,BAND_SEG,hi),Color(SHALLOW,0.6))
					canvas.draw_rect(Rect2(sx,o.y+hi,BAND_SEG,lo-hi),Color(SHALLOW.lerp(band,0.5),0.85))
					canvas.draw_rect(Rect2(sx,o.y+lo,BAND_SEG,24-lo),band)
				else:
					# The band above runs on into this row and gives way partway down, never on the tile line.
					var mid := 10+roundi(sin((x*24+s*BAND_SEG)*0.21+row*1.7+turn*0.6))
					canvas.draw_rect(Rect2(sx,o.y,BAND_SEG,mid),prev)
					canvas.draw_rect(Rect2(sx,o.y+mid,BAND_SEG,24-mid),band)
			var tile_phase := posmod(x+(y%3)*3,8)*24
			canvas.draw_texture_rect_region(_ripples,r,Rect2(tile_phase,phase*24,24,24))
			# A dash or two of light on the deeper water, placed afresh each turn.
			for k in 2:
				var g := R._h(x*2+k,y,turn*7+81)
				if row==0 or g<0.62:continue
				var gl := 2+int(R._h(x,y+k,turn+82)*3.0)
				canvas.draw_rect(Rect2(o+Vector2(2+int(g*997.0)%(20-gl),3+int(g*7919.0)%17),Vector2(gl,1)),Color(GLINT,0.85))
			if row==0:
				# The foam along the edge, in short runs: some off, some doubled, some a pixel lower. The runs are read
				# from the hash shifted by the turn, so the line is different every turn.
				for s in 24/FOAM_SEG:
					var f := R._h(x*(24/FOAM_SEG)+s+turn*5,top,83)
					if f<0.14:continue
					var at: Vector2 = o+Vector2(s*FOAM_SEG,1.0 if f>0.84 else 0.0)
					canvas.draw_rect(Rect2(at,Vector2(FOAM_SEG,1)),FOAM)
					if f>0.56:
						canvas.draw_rect(Rect2(at+Vector2(0,1),Vector2(FOAM_SEG,1)),FOAM_DIM)
	return true
