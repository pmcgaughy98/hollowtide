extends SceneTree
const Title := preload("res://scripts/art/placeholders/title_highbank.gd")
func _initialize() -> void:
 var dummy := Image.create(384,216,false,Image.FORMAT_RGBA8)
 var roofs := Title._street(dummy)
 var lines := Image.create(384,216,false,Image.FORMAT_RGBA8)
 Title._lines(lines,roofs)
 lines.save_png("res://docs/art/slot-candidates/cx-15-title-highbank/layout-a-2026-10-28/lines-component.png")
 print("ROOF_POSTS ", roofs)
 quit()
