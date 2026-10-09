extends SceneTree
func _initialize() -> void:
	var source:=Image.load_from_file("D:/dev/hollowtide-creature-opening-20261009/terrain-source.png")
	source.convert(Image.FORMAT_RGBA8)
	var atlas:=Image.create(96,96,false,Image.FORMAT_RGBA8)
	for y in 4:
		for x in 4:
			var p:=Vector2i(roundi(source.get_width()*x/4.0),roundi(source.get_height()*y/4.0))
			var end:=Vector2i(roundi(source.get_width()*(x+1)/4.0),roundi(source.get_height()*(y+1)/4.0))
			var tile:=source.get_region(Rect2i(p,end-p))
			tile.resize(24,24,Image.INTERPOLATE_NEAREST)
			atlas.blit_rect(tile,Rect2i(0,0,24,24),Vector2i(x*24,y*24))
	DirAccess.make_dir_recursive_absolute("res://assets/tilesets/hollow_bank_2026_10_09")
	atlas.save_png("res://assets/tilesets/hollow_bank_2026_10_09/terrain_24.png")
	print("Prepared 16 original 24px terrain tiles; raw generation retained")
	quit()
