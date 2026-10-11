extends SceneTree
func _initialize() -> void:
	var path := FileAccess.get_file_as_string("D:/dev/hollowtide-hall-interior-20261010/hall-source-path.txt").strip_edges()
	var img := Image.load_from_file(path)
	if img == null: quit(1); return
	var before := img.get_size()
	img.convert(Image.FORMAT_RGBA8)
	img.resize(528,336,Image.INTERPOLATE_NEAREST)
	var at := "D:/dev/hollowtide-world-refinement-20261008/project/assets/sprites/world/hall_interior_2026_10_10/"
	DirAccess.make_dir_recursive_absolute(at)
	img.save_png(at+"hall_native.png")
	print("Prepared Hall ",before," -> ",img.get_size()," nearest native normalization")
	quit()
