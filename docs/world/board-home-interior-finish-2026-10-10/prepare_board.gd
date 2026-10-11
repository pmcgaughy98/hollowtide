extends SceneTree
func _initialize() -> void:
	var img := Image.load_from_file("C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-b8154cb5-b5ce-4d97-beee-c522520d7cdf.png")
	img.convert(Image.FORMAT_RGBA8)
	img.resize(96,48,Image.INTERPOLATE_NEAREST)
	var at := "D:/dev/hollowtide-world-refinement-20261008/project/assets/sprites/world/job_board_selout_2026_10_10/"
	DirAccess.make_dir_recursive_absolute(at)
	img.save_png(at+"board_native.png")
	print("Prepared outlined Board: ",img.get_size()," used ",img.get_used_rect())
	quit()
