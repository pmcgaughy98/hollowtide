from pathlib import Path
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
r='scripts/town/job_board_painter.gd'
raw=(W/'originals'/r).read_bytes();crlf=b'\r\n' in raw;s=raw.decode('utf-8').replace('\r\n','\n')
s=s.replace('const ART := "res://assets/sprites/world/job_board_2026_10_10/board_native.png"','const ART := "res://assets/sprites/world/job_board_2026_10_10/board_native.png"\nconst DISPLAY_ART := "res://assets/sprites/world/job_board_selout_2026_10_10/board_native.png"')
old='''static func _visual_offset() -> Vector2:
\tvar used: Rect2i = load(ART).get_image().get_used_rect()
\t# Keep the original centre and actual opaque foot row, including the source padding.
\treturn Vector2(-Layout.T, -used.end.y)
'''
new='''static func _display_texture() -> Texture2D:
\t# The original 48x24 stand is retained as the exact fallback.
\tif FileAccess.file_exists(DISPLAY_ART):
\t\tvar image := Image.load_from_file(ProjectSettings.globalize_path(DISPLAY_ART))
\t\tif image != null and image.get_size()==Vector2i(96,48):
\t\t\treturn ImageTexture.create_from_image(image)
\treturn load(ART)

static func _visual_scale(texture: Texture2D) -> Vector2:
\treturn Vector2.ONE if texture.get_size()==Vector2(96,48) else Vector2(2,2)

static func _visual_offset(texture: Texture2D = null) -> Vector2:
\tif texture == null: texture = _display_texture()
\tvar original: Rect2i = load(ART).get_image().get_used_rect()
\tvar used: Rect2i = texture.get_image().get_used_rect()
\t# Same canvas centre and opaque foot row for native art and the original 2x fallback.
\treturn Vector2(-Layout.T, original.end.y-used.end.y*_visual_scale(texture).y)
'''
assert s.count(old)==1;s=s.replace(old,new)
s=s.replace("\t# An integer native-pixel enlargement of Preston's original stand, with aligned feet.",'''\t# Refined 96x48 native art keeps the enlarged stand's centre and contact row.
\tvar art := _display_texture()
\tvar visual_scale := _visual_scale(art)
\tvar offset := _visual_offset(art)''')
s=s.replace('shadow.position = _visual_offset() + Vector2(2, 2)','shadow.position = offset + Vector2(2, 2)').replace('shadow.scale = Vector2(2, 2)','shadow.scale = visual_scale').replace('shadow.texture = load(ART)','shadow.texture = art')
s=s.replace('sprite.scale = Vector2(2, 2)','sprite.scale = visual_scale').replace('sprite.position = _visual_offset()','sprite.position = offset').replace('sprite.texture = load(ART)','sprite.texture = art')
(C/r).write_bytes(s.replace('\n','\r\n').encode('utf-8') if crlf else s.encode('utf-8'))
print('Integrated 96x48 native Board with full shared detail ink, original foot and source fallback.')
