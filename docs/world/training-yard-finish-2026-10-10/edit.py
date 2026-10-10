from pathlib import Path
W=Path(__file__).parent
p=W/'candidate/scripts/town/building_exteriors.gd';t=p.read_text()
t=t.replace('static func available(id: String) -> bool:\n','static func available(id: String) -> bool:\n\tif id == "yard":\n\t\treturn ResourceLoader.exists("res://scripts/town/training_yard_painter.gd") and load("res://scripts/town/training_yard_painter.gd").available()\n')
t=t.replace('\t\tif id == "shrine":\n\t\t\tbuildings', '\t\tif id == "yard":\n\t\t\tbuildings[id] = load("res://scripts/town/training_yard_painter.gd").attach(self, town)\n\t\t\tcontinue\n\t\tif id == "shrine":\n\t\t\tbuildings')
t=t.replace('\t\tif id == "shrine":\n\t\t\tload(', '\t\tif id == "yard":\n\t\t\tload("res://scripts/town/training_yard_painter.gd").update(b, town, delta)\n\t\t\tcontinue\n\t\tif id == "shrine":\n\t\t\tload(')
p.write_text(t)
p=W/'candidate/scripts/town/highbank_ground_painter.gd';t=p.read_text().replace('\tvar shrine_ground: Image','\tvar shrine_ground: Image\n\tvar yard_ground: Image')
t=t.replace('\t\tif place["id"] == "shrine":','\t\tif place["id"] == "yard":\n\t\t\tyard_ground = img.get_region(px)\n\t\tif place["id"] == "shrine":')
t=t.replace('\treturn img\n','\tif ResourceLoader.exists("res://scripts/town/training_yard_painter.gd"):\n\t\timg = load("res://scripts/town/training_yard_painter.gd").apply(img, yard_ground)\n\treturn img\n')
p.write_text(t)
text=(W/'originals/scripts/town/hub_town.gd').read_text().replace('res://scripts/town/highbank_ground_painter.gd',(W/'originals/scripts/town/highbank_ground_painter.gd').as_posix())
(W/'baseline_hub.gd').write_text(text)
print('Yard-only optional ground, view and service-feedback hooks ready')
