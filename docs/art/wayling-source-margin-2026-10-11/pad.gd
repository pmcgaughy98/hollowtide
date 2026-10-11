extends SceneTree
## Mechanical source-canvas preparation. Keep every original pixel and all
## existing portrait crop coordinates; add eight transparent rows below it.
const OUT := "D:/dev/hollowtide-wayling-margin-20261011/"
func _initialize() -> void:
	var original := Image.load_from_file(OUT + "original.png")
	var candidate := Image.create(original.get_width(),original.get_height()+8,false,original.get_format())
	candidate.fill(Color(0,0,0,0))
	candidate.blit_rect(original,Rect2i(Vector2i.ZERO,original.get_size()),Vector2i.ZERO)
	var retained := candidate.get_region(Rect2i(Vector2i.ZERO,original.get_size()))
	assert(retained.get_data() == original.get_data(),"Original pixel data changed")
	assert(candidate.save_png(OUT + "candidate.png") == OK)
	print("WAYLING CANVAS: ", original.get_size()," -> ",candidate.get_size(),"; every original pixel preserved; 8 transparent rows added below.")
	quit()
