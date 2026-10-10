from pathlib import Path
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def put(r,s):
 if isinstance(s,str):
  original=W/'originals'/r
  if original.exists() and b'\r\n' in original.read_bytes():s=s.replace('\n','\r\n')
  s=s.encode('utf-8')
 q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(s)
 q=C/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(s)
r='scripts/town/building_exteriors.gd';s=(W/'originals'/r).read_text(encoding='utf-8')
anchor='static func available(id: String) -> bool:\n'
assert s.count(anchor)==1
s=s.replace(anchor,anchor+'\tif id in ["lookout", "landing", "dock"]:\n\t\treturn ResourceLoader.exists("res://scripts/town/landmark_exteriors.gd") and load("res://scripts/town/landmark_exteriors.gd").available(id)\n')
anchor='\t\tif id == "gate":\n\t\t\tbuildings[id]'
assert s.count(anchor)==1
s=s.replace(anchor,'\t\tif id in ["lookout", "landing", "dock"]:\n\t\t\tbuildings[id] = load("res://scripts/town/landmark_exteriors.gd").attach(self, town, id)\n\t\t\tcontinue\n'+anchor)
anchor='\t\tvar b: Dictionary = buildings[id]\n'
assert s.count(anchor)==1
s=s.replace(anchor,anchor+'\t\tif b.get("landmark", false): continue   # Open-air props have no door animation.\n')
put(r,s)
r='scripts/town/job_board_painter.gd';s=(W/'originals'/r).read_text(encoding='utf-8')
anchor='static func attach(parent: Node2D, _host: Node2D) -> Dictionary:\n'
assert s.count(anchor)==1
s=s.replace(anchor,'static func _visual_offset() -> Vector2:\n\tvar used: Rect2i = load(ART).get_image().get_used_rect()\n\t# Keep the original centre and actual opaque foot row, including the source padding.\n\treturn Vector2(-Layout.T, -used.end.y)\n\n'+anchor)
old='''\tvar art: Image = load(ART).get_image()
\tfor y in range(2, art.get_height() + 2):
\t\tfor x in range(2, art.get_width() + 2):
\t\t\tif art.get_pixel(x - 2, y - 2).a < 0.5: continue
\t\t\tvar p := at + Vector2i(x, y)
\t\t\timg.set_pixelv(p, img.get_pixelv(p).darkened(0.28))
'''
assert old in s;s=s.replace(old,'\t# The larger stand casts its contact shadow as a separate sprite on the final ground.\n')
anchor='\tvar sprite := Sprite2D.new()\n'
assert s.count(anchor)==1
s=s.replace(anchor,'''\t# An integer native-pixel enlargement of Preston's original stand, with aligned feet.
\tvar shadow := Sprite2D.new()
\tshadow.name = "ContactShadow"
\tshadow.centered = false
\tshadow.position = _visual_offset() + Vector2(2, 2)
\tshadow.scale = Vector2(2, 2)
\tshadow.texture = load(ART)
\tshadow.modulate = Color(0, 0, 0, 0.22)
\tshadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
\tbase.add_child(shadow)
'''+anchor)
anchor='\tsprite.name = "NoticeStand"\n'
assert s.count(anchor)==1
s=s.replace(anchor,anchor+'\tsprite.scale = Vector2(2, 2)\n\tsprite.position = _visual_offset()\n')
put(r,s)
put('scripts/town/landmark_exteriors.gd',(W/'landmark_exteriors.gd').read_bytes())
print('Built larger original Board and three code-native landmark exteriors; no source art/layout/controller edits.')
