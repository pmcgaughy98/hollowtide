extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/route1-spaced-landing-review/"
const GROUND = preload("res://assets/tilesets/route1_rd_2026_10_01/route1_ground_atlas_polished.png")
const SOIL = preload("res://assets/sprites/world/route1_crossing_2026_10_02/path_soil_native32.png")
const AREA := Rect2i(244,336,200,288)
var route: Node2D
var atlas: Image
var overlays: Array=[]
func _initialize() -> void:call_deferred("_run")
func _curve(points: PackedVector2Array) -> PackedVector2Array:
	for pass_index in 2:
		var rounded:=PackedVector2Array([points[0]])
		for i in range(points.size()-1):
			rounded.append(points[i].lerp(points[i+1],0.25));rounded.append(points[i].lerp(points[i+1],0.75))
		rounded.append(points[-1]);points=rounded
	return points
func _polygon(points: PackedVector2Array, half_width: float) -> PackedVector2Array:
	var left:=PackedVector2Array();var right:=PackedVector2Array()
	for i in points.size():
		var direction: Vector2=(points[mini(i+1,points.size()-1)]-points[maxi(i-1,0)]).normalized()
		var normal:=Vector2(-direction.y,direction.x)*half_width
		left.append((points[i]+normal).round());right.append((points[i]-normal).round())
	right.reverse();left.append_array(right);return left
func _base(world: Vector2i) -> Color:
	var terrain: TileMapLayer=route.get_node("Terrain")
	var tile:=terrain.get_cell_atlas_coords(Vector2i(world.x/16,world.y/16))
	var pixel:=atlas.get_pixelv(tile*16+Vector2i(world.x%16,world.y%16))
	for overlay in overlays:
		var at: Vector2i=world-overlay["at"]
		var image: Image=overlay["image"]
		if at.x>=0 and at.x<image.get_width() and at.y>=0 and at.y<image.get_height():
			var above:=image.get_pixelv(at)
			if above.a>0:pixel=above
	return pixel
func _near(mask: PackedByteArray, at: Vector2i, radius: int, value: int) -> bool:
	for dy in range(-radius,radius+1):
		for dx in range(-radius,radius+1):
			var x:=at.x+dx;var y:=at.y+dy
			if x>=0 and x<AREA.size.x and y>=0 and y<AREA.size.y and mask[y*AREA.size.x+x]==value:return true
	return false
func _bake() -> void:
	var started:=Time.get_ticks_msec()
	atlas=GROUND.get_image()
	for path in ["RiverCrossing/JoinedLeveeRoad","RiverCrossing/Landscape/WetBankContours","RiverCrossing/TerrainRelief/RoundedDispatchAndLandingLanes","RiverCrossing/LandingLoop/LandingFootpath"]:
		var node: Sprite2D=route.get_node(path)
		overlays.append({"at":Vector2i(node.position),"image":node.texture.get_image()})
	var incoming:=_curve(PackedVector2Array([Vector2(344,352),Vector2(304,392),Vector2(316,456),Vector2(354,496),Vector2(392,536)]))
	var returning:=_curve(PackedVector2Array([Vector2(392,536),Vector2(420,510),Vector2(424,464),Vector2(424,416)]))
	var shore:=_curve(PackedVector2Array([Vector2(392,536),Vector2(419,567),Vector2(416,594)]))
	var hollow:=_curve(PackedVector2Array([Vector2(304,392),Vector2(276,368),Vector2(258,358)]))
	var polygons: Array=[_polygon(incoming,10.0),_polygon(returning,9.0),_polygon(shore,8.0),_polygon(hollow,8.0)]
	var new_mask:=PackedByteArray();new_mask.resize(AREA.size.x*AREA.size.y)
	var joined:=PackedByteArray();joined.resize(new_mask.size())
	var soil_colours: Dictionary={0xad9873:true,0xb3a078:true,0xb7a57d:true,0xbbaa80:true,0xbfae84:true,0xc3b389:true,0x9d906a:true}
	for y in AREA.size.y:
		for x in AREA.size.x:
			var world:=AREA.position+Vector2i(x,y)
			var i:=y*AREA.size.x+x
			for polygon in polygons:
				if Geometry2D.is_point_in_polygon(Vector2(world)+Vector2(0.5,0.5),polygon):new_mask[i]=1
			var pixel:=_base(world)
			var key: int=(pixel.r8<<16)|(pixel.g8<<8)|pixel.b8
			joined[i]=int(new_mask[i]==1 or soil_colours.has(key))
	var image:=Image.create(AREA.size.x,AREA.size.y,false,Image.FORMAT_RGBA8);image.fill(Color.TRANSPARENT)
	var soil:=SOIL.get_image();var drawn:=0
	for y in AREA.size.y:
		for x in AREA.size.x:
			var at:=Vector2i(x,y);var world:=AREA.position+at
			if world.x>441 or not _near(new_mask,at,2,1):continue
			var i:=y*AREA.size.x+x
			if joined[i]==1:
				var colour:=soil.get_pixel(world.x%32,world.y%32)
				if _near(joined,at,1,0):colour=Color("#9d906a")
				image.set_pixelv(at,colour)
			else:image.set_pixelv(at,Color("#435e46"))
			drawn+=1
	var error:=image.save_png(OUT+"landing_south_loop.png")
	var record:={"offline_bake":true,"area":str(AREA),"bake_ms":Time.get_ticks_msec()-started,"drawn_pixels":drawn,"error":error,"incoming":str(incoming),"returning":str(returning),"rightmost_world_pixel":441}
	var file:=FileAccess.open(OUT+"candidate-bake-results.json",FileAccess.WRITE);file.store_string(JSON.stringify(record,"\t"))
	print("LANDING_LOOP_BAKE ",record)
func _run() -> void:
	var journey: Node2D=load("res://scenes/world_journey.tscn").instantiate()
	journey.initial_area="route1"
	root.add_child(journey);current_scene=journey
	for i in 25:await process_frame
	route=journey.route
	route.get_node("Player").set_physics_process(false)
	_bake()
	journey.queue_free();current_scene=null;journey=null;route=null
	for i in 10:await process_frame
	quit()
