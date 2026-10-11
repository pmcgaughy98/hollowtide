extends SceneTree
const W := "D:/dev/hollowtide-hall-interior-20261010/"
const Painter := preload("res://scripts/town/room_painter.gd")
const Room := preload("res://scripts/town/town_room.gd")
const Art := preload("res://scripts/town/hall_room_art.gd")
var bad := 0
var count := 0
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func check(ok: bool,label: String) -> void:
	count+=1
	if not ok: bad+=1
	print("PASS " if ok else "FAIL ",label)
func _run() -> void:
	var previous := load(W+"originals/scripts/town/room_painter.gd")
	var home_before: Image=previous.paint("home",Room.ROOMS.home)
	var home_after: Image=Painter.paint("home",Room.ROOMS.home)
	check(home_before.get_data()==home_after.get_data(),"approved Home remains pixel-exact")
	var before: Image=previous.paint("hall",Room.ROOMS.hall)
	var after: Image=Painter.paint("hall",Room.ROOMS.hall)
	check(after.get_size()==Vector2i(528,336) and before.get_data()!=after.get_data(),"Hall fits original 22x14 room at 24px native grid")
	var door := Rect2i(261,312,30,24)
	check(before.get_region(door).get_data()==after.get_region(door).get_data(),"south exit frame/daylight drawing exact")
	check(Art.PROPS.size()==12,"four pillars, two ferns/benches/tables/parcel stacks at original visual coordinates")
	for p in Art.PROPS:
		var prop: Image=Art._prop(p[0])
		var rect: Rect2i=p[1]
		check(prop.get_size()==rect.size and prop.get_used_rect().size.y>0,"native %s fits %s without expanding its footprint"%[p[0],str(rect)])
	var view := SubViewport.new()
	view.size=Vector2i(528,336)
	view.transparent_bg=true
	view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var sprite := Sprite2D.new()
	sprite.centered=false
	sprite.texture=ImageTexture.create_from_image(after)
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	view.add_child(sprite)
	await frames(8)
	await RenderingServer.frame_post_draw
	var raw := view.get_texture().get_image()
	Art.finish(sprite)
	await frames(8)
	await RenderingServer.frame_post_draw
	var inked := view.get_texture().get_image()
	var mask := Art.mask()
	var outside_exact := true
	var changes := 0
	for y in 336:
		for x in 528:
			if mask.get_pixel(x,y).r<0.5: outside_exact=outside_exact and raw.get_pixel(x,y)==inked.get_pixel(x,y)
			elif raw.get_pixel(x,y)!=inked.get_pixel(x,y): changes+=1
	check(outside_exact and changes>1000,"actual GPU outlines walls/furniture; unmasked floor/runner/exit exact")
	DirAccess.make_dir_recursive_absolute(W+"review")
	inked.save_png(W+"review/hall-finished-native.png")
	view.queue_free()
	await frames(12)
	print("HALL FINISH ",count-bad,"/",count," PASS")
	quit(0 if bad==0 else 1)
