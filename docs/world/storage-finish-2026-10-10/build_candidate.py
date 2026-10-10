from pathlib import Path
W=Path(__file__).parent
text=(W/'originals/scripts/town/building_exteriors.gd').read_text()
text=text.replace('## Home, shop and Hall presentation only.','## Finished service exteriors only.')
text=text.replace('const SOURCES = {','const SOURCES = {\n\t"storage": "res://assets/sprites/world/storage_2026_10_10/storage_native.png",')
text=text.replace('static func available(id: String) -> bool:', 'static func available(id: String) -> bool:\n\tif id == "storage" and not ResourceLoader.exists("res://scripts/town/storage_painter.gd"):\n\t\treturn false   # Keep the sprite and restored ground as one optional exterior.')
anchor='\tif id == "hall":\n\t\tvar p := d + Vector2i(entrance_width + 10, -25)'
sign='''\tif id == "storage":
		var p := d + Vector2i(31, -6)
		img.fill_rect(Rect2i(p + Vector2i(8, 13), Vector2i(2, 17)), INK)
		img.fill_rect(Rect2i(p, Vector2i(19, 17)), INK)
		img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 15)), LIGHT)
		img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 13)), Color("#665e44"))
		# Crate pictogram: an outlined box with two diagonal braces.
		img.fill_rect(Rect2i(p + Vector2i(4, 4), Vector2i(11, 10)), INK)
		img.fill_rect(Rect2i(p + Vector2i(5, 5), Vector2i(9, 8)), Color("#ab9265"))
		for y in 7:
			img.set_pixelv(p + Vector2i(5 + y, 5 + y), LIGHT)
			img.set_pixelv(p + Vector2i(13 - y, 5 + y), LIGHT)
'''
assert anchor in text;text=text.replace(anchor,sign+anchor)
anchor='\tfor p in seen:\n\t\tvar col := Color("#333b2f").lerp(Color("#987b46"), clampf((p.y - 34.0) / 21.0, 0.0, 1.0))'
text=text.replace(anchor,'''\tvar origin := 0
	if id == "storage" and not seen.is_empty():
		origin = 28
		var end := 0
		for p in seen:
			origin = mini(origin, p.x)
			end = maxi(end, p.x + 1)
		width = [end - origin, maxi(2, (end - origin) / 2), 2][frame]
'''+anchor)
text=text.replace('if p.x < width:', 'if p.x < origin + width:')
text=text.replace('if p.x == width - 1 or', 'if p.x == origin + width - 1 or')
text=text.replace('if p.x == width - 4 and', 'if p.x == origin + width - 4 and')
(W/'candidate/scripts/town/building_exteriors.gd').write_text(text)
text=(W/'originals/scripts/town/highbank_ground_painter.gd').read_text()
text=text.replace('\tvar shop_ground: Image','\tvar shop_ground: Image\n\tvar storage_ground: Image')
anchor='\t\t\t# Building and service-spot art is a later slice.'
text=text.replace(anchor,'\t\t\tif place["id"] == "storage":\n\t\t\t\tstorage_ground = img.get_region(px)\n'+anchor)
anchor='\treturn img\n'
text=text.replace(anchor,'\tif ResourceLoader.exists("res://scripts/town/storage_painter.gd"):\n\t\timg = load("res://scripts/town/storage_painter.gd").apply(img, storage_ground)\n'+anchor)
(W/'candidate/scripts/town/highbank_ground_painter.gd').write_text(text)
print('Storage asset/view/painter staged; original exteriors and event layout retained.')
