from pathlib import Path
W=Path(__file__).parent
p=W/'originals/scripts/town/building_exteriors.gd';s=p.read_text()
s=s.replace('static func available(id: String) -> bool:\n', 'static func available(id: String) -> bool:\n\tif id == "shrine":\n\t\treturn ResourceLoader.exists("res://scripts/town/growth_shrine_painter.gd") and load("res://scripts/town/growth_shrine_painter.gd").available()\n')
s=s.replace('\t\tvar r: Rect2i = place["rect"]\n\t\tvar base := Node2D.new()', '\t\tif id == "shrine":\n\t\t\tbuildings[id] = load("res://scripts/town/growth_shrine_painter.gd").attach(self, town)\n\t\t\tcontinue\n\t\tvar r: Rect2i = place["rect"]\n\t\tvar base := Node2D.new()')
s=s.replace('\t\tvar b: Dictionary = buildings[id]\n', '\t\tvar b: Dictionary = buildings[id]\n\t\tif id == "shrine":\n\t\t\tload("res://scripts/town/growth_shrine_painter.gd").update(b, town, delta)\n\t\t\tcontinue\n')
(W/'candidate/scripts/town/building_exteriors.gd').write_text(s)
s=(W/'originals/scripts/town/highbank_ground_painter.gd').read_text()
s=s.replace('\tvar storage_ground: Image','\tvar storage_ground: Image\n\tvar shrine_ground: Image')
s=s.replace('\t\tif place["kind"] == "area":', '\t\tif place["id"] == "shrine":\n\t\t\tshrine_ground = img.get_region(px)\n\t\tif place["kind"] == "area":')
s=s.replace('\treturn img\n','\tif ResourceLoader.exists("res://scripts/town/growth_shrine_painter.gd"):\n\t\timg = load("res://scripts/town/growth_shrine_painter.gd").apply(img, shrine_ground)\n\treturn img\n',1)
(W/'candidate/scripts/town/highbank_ground_painter.gd').write_text(s)
print('Three scoped scripts prepared; all existing drawings retained.')
s=(W/'originals/scripts/town/hub_town.gd').read_text()
old='\t\tUI.text(h, box.position + Vector2(22, 116), "E  close", 15, UI.MUTED, 716, HORIZONTAL_ALIGNMENT_RIGHT)'
assert s.count(old)==1
s=s.replace(old,'\t\tvar hint := "E  evolve     Esc  not now" if panel.get("service", "") == "evolve_ask" else "E  close"\n\t\tUI.text(h, box.position + Vector2(22, 116), hint, 15, UI.MUTED, 716, HORIZONTAL_ALIGNMENT_RIGHT)')
(W/'candidate/scripts/town/hub_town.gd').write_text(s)
