extends SceneTree
const Art=preload("res://scripts/dungeon/dungeon_tile_art.gd")
func _initialize()->void:
	var folder:=ProjectSettings.globalize_path(Art.FOLDER)
	DirAccess.make_dir_recursive_absolute(folder)
	for look in ["riverbank","valley","ruin"]:
		for kind in ["floor","grass","wall","decor"]:
			var count:=4 if kind in ["floor","decor"] else 256
			var cols:=4 if count==4 else 16
			var atlas:=Image.create(cols*24,(count/cols)*24,false,Image.FORMAT_RGBA8)
			for i in count:atlas.blit_rect(Art.build_tile(look,kind,i),Rect2i(0,0,24,24),Vector2i((i%cols)*24,(i/cols)*24))
			assert(atlas.save_png(folder+look+"_"+kind+".png")==OK)
	print("12 native tile atlases exported; top/edge/corner rules retained as source")
	quit()
