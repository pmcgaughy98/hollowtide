extends SceneTree
func _initialize()->void:
	var source:=Image.load_from_file("D:/dev/hollowtide-dungeon-tiles-20261010/generated/guild-desk-source.png")
	source.convert(Image.FORMAT_RGBA8)
	var bounds:=Rect2i()
	for y in source.get_height():
		for x in source.get_width():
			if source.get_pixel(x,y).a>0.5:
				bounds=Rect2i(x,y,1,1) if not bounds.has_area() else bounds.merge(Rect2i(x,y,1,1))
	var crop:=source.get_region(bounds)
	crop.resize(190,46,Image.INTERPOLATE_NEAREST)
	var native:=Image.create(192,52,false,Image.FORMAT_RGBA8);native.fill(Color.TRANSPARENT)
	native.blit_rect(crop,Rect2i(0,0,190,46),Vector2i(1,0))
	# Existing four-row contact-shadow footprint stays underneath the same obstacle/depth.
	for y in range(46,50):native.fill_rect(Rect2i(4,y,184,1),Color(0,0,0,float(90-(y-46)*20)/255.0))
	var path:="res://assets/sprites/world/guild_desk/desk_detail_2026_10_10.png"
	assert(native.save_png(ProjectSettings.globalize_path(path))==OK)
	print("DESK source ",source.get_size()," crop ",bounds," native ",native.get_size()," original desk.png retained")
	quit()
