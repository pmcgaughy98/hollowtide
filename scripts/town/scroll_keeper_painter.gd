extends RefCounted
## Optional north-facing Scroll Keeper exterior. Service rules remain with Claude.
const Layout = preload("res://scripts/town/town_layout.gd")
static func apply(img: Image, ground: Image) -> Image:
	if not ResourceLoader.exists("res://scripts/town/building_exteriors.gd"): return img
	var view = load("res://scripts/town/building_exteriors.gd")
	if not view.available("scrolls"): return img
	var place: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "scrolls")[0]
	return view.ground_apply(img, ground, place)
