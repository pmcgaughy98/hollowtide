extends SceneTree
## Native pixel recipes, matching the quiet river's teal, silt and reflected sky.
## Four 400ms frames; widths are multiples of the existing 24px world grid.
const OUT := "D:/dev/hollowtide-rising-water-20261014/art/"
const WIDTH := 192
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var ripple := Image.create(WIDTH,96,false,Image.FORMAT_RGBA8)
	var shore := Image.create(WIDTH,32,false,Image.FORMAT_RGBA8)
	ripple.fill(Color(0,0,0,0));shore.fill(Color(0,0,0,0))
	for f in 4:
		for y in 24:
			for x in WIDTH:
				# A broad, low-contrast wash and long broken current strokes; no
				# sharp pebbles/confetti competing with items or creature feet.
				var wave := sin(TAU*x/96.0 + sin(TAU*y/24.0)*0.7 + f*0.13)
				var c := Color("#42665f")
				c.a = 0.12 if wave < 0 else 0.2
				if posmod(x/2+y/2*7,19)==0:c=Color(0.39,0.53,0.48,0.18)
				ripple.set_pixel(x,f*24+y,c)
		# Staggered crescent strokes lean east, with their ends fading rather
		# than marching in lockstep at tile boundaries.
		for k in 7:
			var cx := posmod(k*29+11+f*2,WIDTH)
			var cy := 5+posmod(k*7,15)
			var length := 7+posmod(k*3,9)
			for dx in length:
				var px := posmod(cx+dx,WIDTH)
				var py := cy + (1 if dx<2 or dx>length-3 else 0)
				var c := Color("#91b6a7");c.a=0.36 if dx>1 and dx<length-2 else 0.18
				ripple.set_pixel(px,f*24+py,c)
				if dx>1 and dx<length-1:ripple.set_pixel(px,f*24+py+1,Color(0.20,0.32,0.30,0.25))
		for x in WIDTH:
			var crest := 2+int(round(sin(TAU*x/48.0+f*PI/2.0)*0.65+sin(TAU*x/96.0)*0.4))
			for y in 8:
				var c := Color(0,0,0,0)
				if y<crest:c=Color(0.22,0.29,0.23,0.28)
				elif y==crest:
					c=Color("#bed6c1");c.a=0.78 if posmod(x+f*3,23)<16 else 0.44
				elif y==crest+1:c=Color(0.45,0.58,0.51,0.66)
				elif y==crest+2:c=Color(0.22,0.34,0.32,0.38)
				elif y==crest+3:c=Color(0.26,0.40,0.37,0.16)
				shore.set_pixel(x,f*8+y,c)
	assert(ripple.save_png(OUT+"ripples.png")==OK)
	assert(shore.save_png(OUT+"shoreline.png")==OK)
	print("WATER ART: 192x96 ripple atlas, 192x32 shoreline atlas; four native frames.")
	quit()
