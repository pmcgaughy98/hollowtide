extends SceneTree
func _initialize() -> void:
	var img := Image.load_from_file("C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-28dcdf03-c699-407e-99dd-b74ffb95154d.png")
	img.resize(336,240,Image.INTERPOLATE_NEAREST)
	var at := "D:/dev/hollowtide-world-refinement-20261008/project/assets/sprites/world/home_interior_2026_10_10/"
	DirAccess.make_dir_recursive_absolute(at)
	img.save_png(at+"home_native.png")
	print("Prepared Home: ",img.get_size()," nearest native normalization; source unchanged")
	quit()
