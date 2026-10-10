extends RefCounted
## Optional Storage exterior; absent art/view retains Claude's original blockout.
const Layout = preload("res://scripts/town/town_layout.gd")
static func apply(img: Image, ground: Image) -> Image:
	if not ResourceLoader.exists("res://scripts/town/building_exteriors.gd"):
		return img
	var view = load("res://scripts/town/building_exteriors.gd")
	if not view.available("storage"):
		return img
	var place: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "storage")[0]
	return view.ground_apply(img, ground, place)
