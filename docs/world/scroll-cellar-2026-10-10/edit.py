from pathlib import Path
W=Path(__file__).parent
p=W/'candidate/scripts/town/building_exteriors.gd'
t=p.read_text().replace('scroll_keeper_2026_10_10/scroll_native.png','scroll_cellar_2026_10_10/scroll_native.png')
t=t.replace('# North doorstep stays on its authored tile. Source roof and stonework remain whole.','# North landing meets the recessed stairs. Never draw a sill across the stairwell.').replace('Vector2i(1, 22), Vector2i(22, 2)','Vector2i(5, 12), Vector2i(14, 2)').replace('Vector2i(2, 22), Vector2i(20, 1)','Vector2i(6, 12), Vector2i(12, 1)')
a=t.index('static func _scroll_door_frame(');b=t.index('\nfunc _process',a)
t=t[:a]+'''static func _scroll_door_frame(frame: int, _art: Image, _d: Vector2i) -> Image:
	var img := Image.create(28, 36, false, Image.FORMAT_RGBA8)
	# The source contains the complete descending stairwell. Its lid hinges at the
	# south edge, then folds back toward the roof, exposing the original treads.
	var top: int = [15, 23, 31][frame]
	var depth: int = [16, 8, 4][frame]
	for y in range(top, top + depth):
		for x in range(8, 20):
			var c := Color("#80694a") if (x - 8) % 4 != 0 else Color("#28251f")
			if y == top: c = LIGHT
			if x in [8, 19] or y == top + depth - 1: c = INK
			img.set_pixel(x, y, c)
	# Iron cross-straps, hinges and a ring pull remain attached to the same lid.
	if depth > 4:
		for y in [top + 3, top + depth - 3]:
			img.fill_rect(Rect2i(9, y, 10, 1), Color("#333631"))
		img.fill_rect(Rect2i(13, top + 1, 3, 2), Color("#d0ac68"))
		img.set_pixel(14, top + 1, INK)
	for x in [10, 17]: img.fill_rect(Rect2i(x, 30, 2, 2), Color("#48473c"))
	return img
''' +t[b:]
p.write_text(t)
p=W/'scroll_check.gd';t=p.read_text().replace('three distinct source-masked door drawings','closed / lifting / folded-back hatch drawings').replace('door opens to warm interior','hatch folds back to reveal descending source steps')
t=t.replace('await snap("scrolls_exterior")','await snap("scrolls_exterior")\n\tfor phase in [1, 2]:\n\t\tb["door"].texture = b["frames"][phase]\n\t\tawait snap("scrolls_hatch_" + str(phase))')
t=t.replace('check(count > 100, "door mask has actual visible opening pixels")','check(count > 100, "closed hatch covers the source recess")\n\tvar closed: Image = b["frames"][0].get_image()\n\tvar opened: Image = b["frames"][2].get_image()\n\tcheck(closed.get_pixel(14, 20).a > 0.9 and opened.get_pixel(14, 20).a < 0.1, "open hatch exposes original middle stair treads")\n\tcheck(opened.get_pixel(14, 33).a > 0.9, "lid folds behind the stairwell toward the roof")')
p.write_text(t)
print('Scroll source and hatch-only code updated')
