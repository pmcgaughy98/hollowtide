from pathlib import Path
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
p=W/'candidate/scripts/town/highbank_ground_painter.gd';s=p.read_text()
s=s.replace('All geometry comes from Claude\'s immutable layout.',"Claude's collision layout stays immutable; Preston widened the Hall's visible approach.")
s=s.replace('static func _path_at(x: int, y: int) -> bool:\n', '''static func _path_at(x: int, y: int) -> bool:
\t# Preston: centre the visible three-tile approach on the existing Hall door (24,6).
\t# Tile (25,7..8) is already open grass; this paints paving without changing collision.
\tif Rect2i(23, 7, 3, 2).has_point(Vector2i(x, y)):
\t\treturn true
''')
p.write_text(s)
# Fallback now keeps the requested wider Hall apron, independently of the optional shop.
baseline=s.replace('\tif ResourceLoader.exists("res://scripts/town/item_shop_painter.gd"):\n\t\timg = load("res://scripts/town/item_shop_painter.gd").apply(img, shop_ground)\n','')
(C/'tools/debug/shop_apron_before.gd').write_text(baseline)
p=W/'fallback_check.gd';p.write_text(p.read_text().replace('shop_ground_before','shop_apron_before'))
p=W/'shop_check.gd';s=p.read_text()
s=s.replace('Rect2i(0,0,1152,72),Rect2i(0,192,1152,576),Rect2i(0,72,744,120),Rect2i(888,72,264,120)', 'Rect2i(0,0,1152,72),Rect2i(0,72,744,96),Rect2i(888,72,264,96),Rect2i(0,168,552,24),Rect2i(624,168,120,24),Rect2i(888,168,264,24),Rect2i(0,192,552,26),Rect2i(624,192,528,26),Rect2i(0,218,1152,550)')
s=s.replace('Every town pixel outside the shop remains byte-exact','Every pixel outside Shop and the widened Hall approach remains byte-exact')
p.write_text(s)
# Preserve a runnable copy of the corrected fallback baseline in the archive.
(W/'shop_apron_before.gd').write_text(baseline)
print('Widened only visible Hall approach to x23..25, y7..8; path/collision contract unchanged')
