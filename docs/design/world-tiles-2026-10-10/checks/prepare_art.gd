extends SceneTree
const SOURCE="D:/dev/hollowtide-world-tiles-20261010/sources/terrain-source.png"
const DEST="res://assets/sprites/world/world_tiles_2026_10_10/"
func _initialize()->void:
	var src:=Image.load_from_file(SOURCE)
	if src==null or src.get_size()!=Vector2i(1254,1254):quit(1);return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	for entry in [["grass",Rect2i(0,0,627,627),Vector2i(192,192)],["earth",Rect2i(627,0,627,627),Vector2i(192,192)],["lane",Rect2i(0,627,627,627),Vector2i(192,192)], ["cliff",Rect2i(627,627,627,154),Vector2i(192,24)], ["cliff_b",Rect2i(627,781,627,156),Vector2i(192,24)]]:
		var img:=src.get_region(entry[1]);img.resize(entry[2].x,entry[2].y,Image.INTERPOLATE_NEAREST);img.convert(Image.FORMAT_RGBA8)
		var err:=img.save_png(ProjectSettings.globalize_path(DEST+entry[0]+"_native.png"))
		print(entry[0]," raw ",entry[1]," -> native ",entry[2]," save ",err)
		if err!=OK:quit(1);return
	print("WORLD TILE materials prepared: source crops and nearest resize only.");quit()
