extends SceneTree
const W="D:/dev/hollowtide-town-detail-20261010/"
const RAW="C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-e80e74dd-7376-4172-a966-d010d5053268.png"
const DEST="res://assets/sprites/world/town_detail_2026_10_10/"
func _initialize()->void:
	var source:=Image.load_from_file(RAW)
	if source==null or source.get_size()!=Vector2i(1448,1086):quit(1);return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	# Complete source-panel bounds include moss/contact fringe; native size remains the town contract.
	for entry in [["lookout",Rect2i(0,0,564,377),Vector2i(144,96)],["dock",Rect2i(886,0,562,333),Vector2i(144,72)],["landing",Rect2i(0,407,1086,402),Vector2i(288,108)],["river",Rect2i(0,811,1448,275),Vector2i(384,72)]]:
		var image:=source.get_region(entry[1]);image.resize(entry[2].x,entry[2].y,Image.INTERPOLATE_NEAREST)
		image.convert(Image.FORMAT_RGBA8)
		var error:=image.save_png(ProjectSettings.globalize_path(DEST+entry[0]+"_native.png"))
		print(entry[0]," complete source ",entry[1]," -> native ",entry[2]," save ",error)
		if error!=OK:quit(1);return
	var hall:=Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/world/hall_interior_2026_10_10/hall_native.png"))
	var floor:=hall.get_region(Rect2i(48,144,160,96))
	floor.save_png(ProjectSettings.globalize_path(DEST+"floor_native.png"))
	print("Approved Hall floor material reused unchanged at native source pixels.")
	print("TOWN ART prepared with source crops and nearest resize only.");quit()
