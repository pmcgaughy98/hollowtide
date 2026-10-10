extends RefCounted
## Exterior proposal only. Claude's exact home footprint and door remain the contract.
const Layout = preload("res://scripts/town/town_layout.gd")
const ART = "res://assets/sprites/world/home_2026_10_09/home_native.png"

static func apply(img: Image, ground: Image) -> Image:
	if not ResourceLoader.exists(ART):
		return img
	var art: Image = load(ART).get_image()
	var home: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "home")[0]
	var rect: Rect2i = home["rect"]
	var px = Rect2i(rect.position * Layout.T, rect.size * Layout.T)
	if art.get_size() != px.size:
		push_warning("Home art does not match the layout; keeping the blockout.")
		return img
	# This replaces the old opaque rectangle only inside its own footprint.
	# Restore the actual native ground under transparent corners, without repainting neighbours.
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, px.size), px.position)
	img.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), px.position)
	return img
