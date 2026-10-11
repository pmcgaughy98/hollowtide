extends SceneTree
func _initialize() -> void:
	var source := Image.load_from_file("C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-674aeeb7-4ade-439a-b3a3-a2aa3ca0825b.png")
	source.convert(Image.FORMAT_RGBA8)
	# Atlas spacing is not a uniform grid: use real alpha gaps to avoid cutting neighbouring props.
	var bands: Array[Vector2i]=[]
	var start := -1
	var last := -1
	for x in source.get_width():
		var occupied := false
		for y in source.get_height():
			if source.get_pixel(x,y).a>0.02: occupied=true; break
		if occupied:
			if start<0: start=x
			last=x
		elif start>=0 and x-last>8:
			bands.append(Vector2i(start,last+1))
			start=-1
	if start>=0: bands.append(Vector2i(start,last+1))
	if bands.size()!=6:
		push_error("Expected six isolated Hall props, found "+str(bands))
		quit(1)
		return
	var names := ["pillar","fern","bench","chart","reports","parcels"]
	var sizes := [Vector2i(22,46),Vector2i(24,32),Vector2i(20,70),Vector2i(48,42),Vector2i(48,42),Vector2i(44,26)]
	var out := "D:/dev/hollowtide-world-refinement-20261008/project/assets/sprites/world/hall_interior_2026_10_10/"
	DirAccess.make_dir_recursive_absolute(out)
	for k in 6:
		var band := Rect2i(bands[k].x,0,bands[k].y-bands[k].x,source.get_height())
		var cell := source.get_region(band)
		# Generated alpha includes nearly invisible specks outside the real sprite.
		# Crop the visible silhouette, preserving its alpha/pixels; do not squash it with empty padding.
		var low := cell.get_size()
		var high := Vector2i.ZERO
		for y in cell.get_height():
			for x in cell.get_width():
				if cell.get_pixel(x,y).a>0.5:
					low=low.min(Vector2i(x,y))
					high=high.max(Vector2i(x+1,y+1))
		var used := Rect2i(low,high-low)
		var prop := cell.get_region(used)
		prop.resize(sizes[k].x,sizes[k].y,Image.INTERPOLATE_NEAREST)
		prop.save_png(out+names[k]+".png")
		print(names[k]," source ",Rect2i(used.position+band.position,used.size)," -> ",prop.get_size())
	quit()
