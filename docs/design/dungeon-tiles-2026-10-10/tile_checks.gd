extends SceneTree
const Art=preload("res://scripts/dungeon/dungeon_tile_art.gd")
const Gen=preload("res://scripts/hollow/hollow_gen.gd")
var fails:=0
var checks:=0
func ok(label:String,value:bool)->void:
	checks+=1
	if not value:fails+=1
	print(label," -> ","ok" if value else "FAIL")
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func run()->void:
	var cases:={}
	for bits in 256:cases[Art.grass_case(bits)]=true
	ok("Grass covers 47 canonical edge/corner cases",cases.size()==47)
	for look in ["riverbank","valley","ruin"]:
		var p:=Art.palette(look)
		var allowed:={}
		for c in p.values():allowed[c.to_rgba32()]=true
		var palette_ok:=true
		var alpha_ok:=true
		for kind in ["floor","grass","wall","decor"]:
			var count:=4 if kind in ["floor","decor"] else 256
			for i in count:
				var img:=Art.tile(look,kind,i)
				for y in 24:
					for x in 24:
						var c:=img.get_pixel(x,y)
						if c.a>0.5 and not allowed.has(c.to_rgba32()):palette_ok=false
						if kind!="decor" and c.a!=1.0:alpha_ok=false
		ok(look+" atlas uses locked palette",palette_ok)
		ok(look+" terrain is opaque/native",alpha_ok)
		var quiet:=true
		var grid:=true
		for i in 4:
			var floor_img:=Art.tile(look,"floor",i)
			for y in 24:
				for x in 24:
					var c:=floor_img.get_pixel(x,y)
					if x==23 or y==23:
						if c!=p.grid:grid=false
					elif c not in [p.floor0,p.floor1,p.floor2,p.floor3]:quiet=false
		ok(look+" quiet interior has only close floor values",quiet)
		ok(look+" grid stays on final row/column",grid)
		var margin:=true
		for i in 4:
			var decor:=Art.tile(look,"decor",i)
			for y in range(7,18):
				for x in range(7,18):
					if decor.get_pixel(x,y).a>0:margin=false
		ok(look+" details never enter central walking square",margin)
		var wall:=Art.tile(look,"wall",4)
		ok(look+" south wall has top, lip, shadow, face and foot",wall.get_pixel(12,2)==p.cap and wall.get_pixel(12,6)==p.lip and wall.get_pixel(12,7)==p.ink and wall.get_pixel(12,20)==p.face0 and wall.get_pixel(12,23)==p.face2)
	# Joined grass surfaces must meet without a dirt crack at any cardinal seam.
	var east:=Art.tile("riverbank","grass",2)
	var west:=Art.tile("riverbank","grass",8)
	ok("Joined grass has no clay break at east/west seam",east.get_pixel(23,12)!=Art.palette("riverbank").floor0 and west.get_pixel(0,12)!=Art.palette("riverbank").floor0)
	var concave:=Art.tile("riverbank","grass",3)
	var solid_corner:=Art.tile("riverbank","grass",19)
	ok("Missing diagonal cuts an actual concave corner",concave.get_pixel(23,0)!=solid_corner.get_pixel(23,0))
	ok("Hollow floors share identical palette",Art.palette("valley")==Art.palette("ruin"))
	var dg:Node=load("res://scenes/dungeon.tscn").instantiate();dg.floor_seed=4242;dg.poll_input=false;dg.party=[[0,0],[1,0]]
	root.add_child(dg);await frames(4)
	var before:=var_to_bytes(dg.data)
	var a:=Art.paint(dg.data,24,4242,"riverbank")
	var b:=Art.paint(dg.data,24,4242,"riverbank")
	ok("Rendering never changes floor data",before==var_to_bytes(dg.data))
	ok("Fixed seed renders deterministically",a.get_data()==b.get_data())
	# Cover a bright high-z effect as well as the map. Inspect the native world viewport, excluding HUD.
	dg._banner.at=-100000;dg.visible_tiles.clear()
	var flash:=ColorRect.new();flash.color=Color.MAGENTA;flash.position=Vector2(-2000,-2000);flash.size=Vector2(5000,5000);flash.z_index=4001;dg._world.add_child(flash)
	await frames(3);await RenderingServer.frame_post_draw
	var view:SubViewport=dg._world.get_parent()
	var dark:=view.get_texture().get_image()
	var crisp:=true
	for y in range(95,155):
		for x in range(125,260):
			if dark.get_pixel(x,y)!=Color.BLACK:crisp=false
	ok("Unseen cells remain exact opaque dark above world effects",crisp)
	flash.queue_free();dg._reveal();await frames(3);await RenderingServer.frame_post_draw
	var lit:=view.get_texture().get_image()
	ok("Reveal restores visible world pixels",lit.get_data()!=dark.get_data())
	dg.queue_free();load("res://scripts/audio/music.gd")._inst=null;await frames(12)
	print("NATIVE TILE CHECKS ",checks-fails,"/",checks);quit(0 if fails==0 else 1)
