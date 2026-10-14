extends SceneTree
const OUT := "D:/dev/hollowtide-storage-art-20261014/props-guide.png"
func _initialize() -> void:
	var im:=Image.create(1536,1024,false,Image.FORMAT_RGBA8);im.fill(Color(0,0,0,0))
	for c in [Vector2i(256,256),Vector2i(768,256)]:
		im.fill_rect(Rect2i(c-Vector2i(108,132),Vector2i(216,264)),Color("#543c28"))
		for x in 2:
			for y in 3:im.fill_rect(Rect2i(c-Vector2i(90,114)+Vector2i(x*96,y*78),Vector2i(84,66)),Color("#2d241d"))
	im.fill_rect(Rect2i(1064,184,432,144),Color("#6e4b2b"))
	im.fill_rect(Rect2i(1064,184,432,90),Color("#ad8046"))
	im.fill_rect(Rect2i(184,708,144,120),Color("#8b6638"))
	im.fill_rect(Rect2i(196,672,96,60),Color("#9c7543"))
	im.fill_rect(Rect2i(708,720,120,96),Color("#a48954"))
	im.fill_rect(Rect2i(1256,720,48,96),Color("#96743e"))
	im.save_png(OUT);print("Six transparent prop guide cells: cabinets, counter, crates, basket, lamp.");quit()
