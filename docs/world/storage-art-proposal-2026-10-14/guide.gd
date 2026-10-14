extends SceneTree
const OUT := "D:/dev/hollowtide-storage-art-20261014/"
func _initialize() -> void:
	var img:=Image.create(408,312,false,Image.FORMAT_RGBA8)
	img.fill(Color("#34271e"))
	img.fill_rect(Rect2i(24,72,360,216),Color("#aa9876"))
	img.fill_rect(Rect2i(24,0,360,72),Color("#77654c"))
	img.fill_rect(Rect2i(24,48,360,24),Color("#5d3e29"))
	img.fill_rect(Rect2i(0,0,24,312),Color("#5d3e29"))
	img.fill_rect(Rect2i(384,0,24,312),Color("#5d3e29"))
	img.fill_rect(Rect2i(0,288,168,24),Color("#5d3e29"))
	img.fill_rect(Rect2i(240,288,168,24),Color("#5d3e29"))
	img.fill_rect(Rect2i(168,288,72,24),Color("#aa9876"))
	img.save_png(OUT+"shell-guide-native.png")
	img.resize(1224,936,Image.INTERPOLATE_NEAREST)
	img.save_png(OUT+"shell-guide-3x.png")
	print("STORAGE GUIDE: 17x13 tiles, native408x312, empty shell, three-tile south threshold.")
	quit()
