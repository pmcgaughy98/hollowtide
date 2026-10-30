extends SceneTree
const Giants := preload("res://scripts/art/placeholders/title_giants.gd")
func _initialize() -> void:
 for kind: String in ["tree", "tower"]:
  var img := Image.create(384,216,false,Image.FORMAT_RGBA8)
  img.fill(Color.MAGENTA)
  if kind == "tree": Giants.great_tree(img)
  else: Giants.tower(img,333)
  for y in 216:
   for x in 384:
    if img.get_pixel(x,y) == Color.MAGENTA: img.set_pixel(x,y,Color.TRANSPARENT)
  img.save_png("res://docs/art/slot-candidates/cx-15-title-highbank/layout-a-2026-10-28/"+kind+"-component.png")
 quit()
