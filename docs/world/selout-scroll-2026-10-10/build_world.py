from pathlib import Path
W=Path(__file__).parent
s=(W/'originals/scripts/town/building_exteriors.gd').read_text()
s=s.replace('const DETAIL_FINISH = preload("res://scripts/town/building_detail_finish.gdshader")\n','')
s=s.replace('const SOURCES = {','const SOURCES = {\n\t"scrolls": "res://assets/sprites/world/scroll_keeper_2026_10_10/scroll_native.png",')
s=s.replace('static func available(id: String) -> bool:\n', 'static func available(id: String) -> bool:\n\tif id == "scrolls" and not ResourceLoader.exists("res://scripts/town/scroll_keeper_painter.gd"):\n\t\treturn false\n')
s=s.replace('\tif place["id"] == "hall":', '''	if place["id"] == "scrolls":
		var d: Vector2i = place["door"] * Layout.T
		for y in range(d.y - Layout.T, d.y):
			var half := 11 + (d.y - y) / 5
			for x in range(d.x + 12 - half, d.x + 12 + half):
				var at := Vector2i(x, y)
				var c := Color("#8f805e") if (x / 4 + y / 3) % 3 == 0 else Color("#948461")
				img.set_pixelv(at, img.get_pixelv(at).lerp(c, 0.45 if absi(x - d.x - 12) >= half - 2 else 0.9))
		return img
	if place["id"] == "hall":''',1)
s=s.replace('base.z_index = (r.end.y - 1) * Layout.T','base.z_index = r.position.y * Layout.T if id == "scrolls" else (r.end.y - 1) * Layout.T')
s=s.replace('\t\tFinish.apply(sprite)\n\t\tsprite.material.shader = DETAIL_FINISH   # Same house outline; purposeful buildings ink their details too.', '\t\tFinish.apply(sprite, true)   # Shared sel-out includes purposeful internal contours.')
s=s.replace('-48 if id == "hall" else -36','0 if id == "scrolls" else -48 if id == "hall" else -36')
s=s.replace('static func _details(size: Vector2i, d: Vector2i, id: String, entrance_width: int = 24) -> Image:\n','static func _details(size: Vector2i, d: Vector2i, id: String, entrance_width: int = 24) -> Image:\n\tif id == "scrolls": return _scroll_details(size, d)\n')
s=s.replace('static func _door_frame(frame: int, art: Image, d: Vector2i, id: String) -> Image:\n','static func _door_frame(frame: int, art: Image, d: Vector2i, id: String) -> Image:\n\tif id == "scrolls": return _scroll_door_frame(frame, art, d)\n')
helper='''
static func _scroll_details(size: Vector2i, d: Vector2i) -> Image:
	var img := Image.create(size.x, size.y + 1, false, Image.FORMAT_RGBA8)
	# North doorstep stays on its authored tile. Source roof and stonework remain whole.
	img.fill_rect(Rect2i(d + Vector2i(1, 22), Vector2i(22, 2)), INK)
	img.fill_rect(Rect2i(d + Vector2i(2, 22), Vector2i(20, 1)), LIGHT)
	var p := d + Vector2i(-25, 1)
	img.fill_rect(Rect2i(p + Vector2i(8, 15), Vector2i(2, 17)), INK)
	img.fill_rect(Rect2i(p, Vector2i(19, 17)), INK)
	img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 15)), LIGHT)
	img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 13)), Color("#665e44"))
	# Original rolled parchment pictogram; no text or borrowed artwork.
	img.fill_rect(Rect2i(p + Vector2i(5, 4), Vector2i(9, 10)), INK)
	img.fill_rect(Rect2i(p + Vector2i(6, 5), Vector2i(7, 8)), Color("#e3c89a"))
	img.fill_rect(Rect2i(p + Vector2i(4, 4), Vector2i(10, 2)), LIGHT)
	img.fill_rect(Rect2i(p + Vector2i(5, 12), Vector2i(10, 2)), LIGHT)
	img.fill_rect(Rect2i(p + Vector2i(8, 8), Vector2i(3, 1)), Color("#8c7897"))
	return img

static func _scroll_door_frame(frame: int, art: Image, d: Vector2i) -> Image:
	var img := Image.create(28, 36, false, Image.FORMAT_RGBA8)
	var seen := {}
	var pending: Array[Vector2i] = [Vector2i(14, 15)]
	while not pending.is_empty():
		var p: Vector2i = pending.pop_back()
		# The north source's trim shares dark pixels with its porch. Restrict flooding to
		# the complete original door planks so trim / lanterns / roof cannot be repainted.
		if seen.has(p) or not Rect2i(7, 8, 13, 17).has_point(p): continue
		var c := art.get_pixelv(d + p + Vector2i(-2, 0))
		if c.a < 0.5 or c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722 > 0.31: continue
		seen[p] = true
		for step in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]: pending.append(p + step)
	var origin := 28
	var end := 0
	for p in seen:
		origin = mini(origin, p.x)
		end = maxi(end, p.x + 1)
	var width: int = [end - origin, maxi(2, (end - origin) / 2), 2][frame]
	for p in seen:
		var col := Color("#333b2f").lerp(Color("#987b46"), clampf((p.y - 12.0) / 18.0, 0.0, 1.0))
		if p.x < origin + width:
			col = Color("#80694a") if p.x % 5 != 0 else Color("#1f241e")
			if not seen.has(p + Vector2i.UP): col = LIGHT
			if p.x == origin + width - 1 or not seen.has(p + Vector2i.LEFT) or not seen.has(p + Vector2i.RIGHT): col = INK
		if p.x == origin + width - 4 and p.y in [18, 19]: col = Color("#e2bd72")
		img.set_pixelv(p, col)
	return img
'''
s=s.replace('\nfunc _process(delta: float) -> void:',helper+'\nfunc _process(delta: float) -> void:')
(W/'candidate/scripts/town/building_exteriors.gd').write_text(s)
s=(W/'originals/scripts/town/highbank_ground_painter.gd').read_text()
s=s.replace('\tvar storage_ground: Image','\tvar storage_ground: Image\n\tvar scroll_ground: Image')
s=s.replace('\t\t\tif place["id"] == "storage":', '\t\t\tif place["id"] == "scrolls":\n\t\t\t\tscroll_ground = img.get_region(px)\n\t\t\tif place["id"] == "storage":')
s=s.replace('\treturn img\n','\tif ResourceLoader.exists("res://scripts/town/scroll_keeper_painter.gd"):\n\t\timg = load("res://scripts/town/scroll_keeper_painter.gd").apply(img, scroll_ground)\n\treturn img\n',1)
(W/'candidate/scripts/town/highbank_ground_painter.gd').write_text(s)
s=(W/'originals/scripts/town/growth_shrine_painter.gd').read_text().replace('const DETAIL = preload("res://scripts/town/building_detail_finish.gdshader")\n','').replace('\tFinish.apply(sprite)\n\tsprite.material.shader = DETAIL','\tFinish.apply(sprite, true)   # Shared sel-out inks pale carved seams and root detail.')
(W/'candidate/scripts/town/growth_shrine_painter.gd').write_text(s)
p=W/'originals/docs/art/art-direction.md';s=p.read_text()
entry='''## Shared sel-out finish (Preston, October 10, 2026)

The purposeful-building outline treatment is part of Hollowtide sel-out. `scripts/arena/sel_out.gdshaderinc` owns the shared silhouette repair, native colour-cluster cleanup and internal contour recipe. `creature_finish.gd.apply(sprite, true)` opts into dark joints/material boundaries plus thin pale carved seams; purposeful service buildings and Growth Shrine use it. Default creature application preserves its approved display finish and all source textures/palette locks. Decorative scenery remains quieter. The legacy building shader is a compatibility entry point into the same recipe, not a second finish to maintain. New purposeful sprites should call the shared detailed preset, with grounding and entrance alignment handled by their painter.

'''
s=s.replace('\n\n','\n\n'+entry,1)
d=W/'candidate/docs/art';d.mkdir(parents=True,exist_ok=True);(d/'art-direction.md').write_text(s)
print('Scroll north entrance and shared detail finish integrated.')
