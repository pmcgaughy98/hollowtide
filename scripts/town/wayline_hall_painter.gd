extends RefCounted
## Exterior proposal only. Claude's exact hall footprint and door remain the contract.
const Layout = preload("res://scripts/town/town_layout.gd")
const ART = "res://assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png"
const ORIGINAL_ART = "res://assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png"

static func apply(img: Image, ground: Image) -> Image:
	# One coherent complete sprite, not an entrance pasted over the old facade.
	var source: String = ART if ResourceLoader.exists(ART) else ORIGINAL_ART
	if not ResourceLoader.exists(source):
		return img
	var art: Image = load(source).get_image()
	var hall: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "hall")[0]
	var rect: Rect2i = hall["rect"]
	var px = Rect2i(rect.position * Layout.T, rect.size * Layout.T)
	if art.get_size() != px.size:
		push_warning("Wayline Hall art does not match the layout; keeping the blockout.")
		return img
	# This replaces the old opaque rectangle only inside its own footprint.
	# Restore the actual native ground under transparent corners, without repainting neighbours.
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, px.size), px.position)
	img.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), px.position)
	return img
