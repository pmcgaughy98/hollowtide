from pathlib import Path
W=Path(__file__).parent
text=(W/'originals/scripts/town/building_exteriors.gd').read_text()
text=text.replace('## Home / shop presentation only.','## Home, shop and Hall presentation only.')
text=text.replace('const SOURCES = {','const SOURCES = {\n\t"hall": "res://assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png",')
text=text.replace('\t# Worn earth widens from the authored threshold', '\tif place["id"] == "hall":\n\t\treturn img   # The existing two-tile paved steps already join the street.\n\t# Worn earth widens from the authored threshold')
text=text.replace('\t\tvar local_d: Vector2i = (place["door"] - r.position) * Layout.T','\t\tvar entrance: Vector2i = place["door"]\n\t\tfor tile in Layout.door_tiles(place):\n\t\t\tentrance.x = mini(entrance.x, tile.x)\n\t\tvar local_d: Vector2i = (entrance - r.position) * Layout.T\n\t\tvar entrance_width: int = Layout.door_tiles(place).size() * Layout.T')
text=text.replace('_details(r.size * Layout.T, local_d, id)', '_details(r.size * Layout.T, local_d, id, entrance_width)')
text=text.replace('\t\tdoor.position = Vector2(local_d + Vector2i(-2, -36))','\t\tdoor.position = Vector2(local_d + Vector2i(-2, -48 if id == "hall" else -36))')
text=text.replace('static func _details(size: Vector2i, d: Vector2i, id: String) -> Image:', 'static func _details(size: Vector2i, d: Vector2i, id: String, entrance_width: int = 24) -> Image:')
text=text.replace('x < d.x + 29:', 'x < d.x + entrance_width + 5:')
text=text.replace('size.y - 3, 22, 3)', 'size.y - 3, entrance_width - 2, 3)').replace('size.y - 3, 20, 1)', 'size.y - 3, entrance_width - 4, 1)').replace('size.y - 2, 18, 1)', 'size.y - 2, entrance_width - 6, 1)')
anchor='\treturn img\n\nstatic func _door_frame'
sign='''\tif id == "hall":
		var p := d + Vector2i(entrance_width + 10, -25)
		img.fill_rect(Rect2i(p + Vector2i(8, 13), Vector2i(2, 22)), INK)
		img.fill_rect(Rect2i(p, Vector2i(19, 19)), INK)
		img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 17)), LIGHT)
		img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 15)), Color("#49563d"))
		# Original waymark pictogram: three routes meeting at one point (visual proposal).
		for y in 5:
			img.fill_rect(Rect2i(p + Vector2i(4 + y, 5 + y), Vector2i(2, 2)), Color("#e2bd72"))
			img.fill_rect(Rect2i(p + Vector2i(13 - y, 5 + y), Vector2i(2, 2)), Color("#e2bd72"))
		img.fill_rect(Rect2i(p + Vector2i(9, 9), Vector2i(2, 6)), Color("#e2bd72"))
	return img

static func _door_frame'''
assert anchor in text;text=text.replace(anchor,sign)
text=text.replace('\tvar img := Image.create(28, 56, false, Image.FORMAT_RGBA8)','\tif id == "hall":\n\t\treturn _hall_door_frame(frame, art, d)\n\tvar img := Image.create(28, 56, false, Image.FORMAT_RGBA8)')
helper='''static func _hall_door_frame(frame: int, art: Image, d: Vector2i) -> Image:
	var img := Image.create(52, 68, false, Image.FORMAT_RGBA8)
	var seen := {}
	var pending: Array[Vector2i] = [Vector2i(26, 40)]
	# Mask the coherent source arch once: never paint across its masonry or side windows.
	while not pending.is_empty():
		var p: Vector2i = pending.pop_back()
		if seen.has(p) or p.x < 0 or p.y < 0 or p.x >= 52 or p.y >= 68: continue
		var c := art.get_pixelv(d + p + Vector2i(-2, -48))
		if c.a < 0.5 or c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722 > 0.27: continue
		seen[p] = true
		for step in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]: pending.append(p + step)
	var leaf: int = [26, 13, 3][frame]
	for p in seen:
		var col := Color("#333b2f").lerp(Color("#987b46"), clampf((p.y - 43.0) / 23.0, 0.0, 1.0))
		var edge: int = mini(p.x, 51 - p.x)
		if edge < leaf:
			col = Color("#80694a") if edge % 6 != 0 else Color("#1f241e")
			if not seen.has(p + Vector2i.UP): col = LIGHT
			if edge == leaf - 1 or not seen.has(p + Vector2i.LEFT) or not seen.has(p + Vector2i.RIGHT): col = INK
			if p.y in [48, 49] and edge == leaf - 4: col = Color("#e2bd72")
		img.set_pixelv(p, col)
	return img

'''
text=text.replace('func _process(delta: float) -> void:',helper+'func _process(delta: float) -> void:')
(W/'candidate/scripts/town/building_exteriors.gd').write_text(text)
text=(W/'originals/scripts/town/wayline_hall_painter.gd').read_text()
anchor='\t# This replaces the old opaque rectangle only inside its own footprint.'
text=text.replace(anchor,'\tif ResourceLoader.exists("res://scripts/town/building_exteriors.gd"):\n\t\tvar view = load("res://scripts/town/building_exteriors.gd")\n\t\tif view.available("hall"):\n\t\t\treturn view.ground_apply(img, ground, hall)\n'+anchor)
(W/'candidate/scripts/town/wayline_hall_painter.gd').write_text(text)
print('Hall-only extension staged; original Home/shop drawing code retained.')
