from pathlib import Path
W=Path(__file__).parent
p=W/'candidate/scripts/town/building_exteriors.gd';t=p.read_text()
needle='static func available(id: String) -> bool:\n';assert t.count(needle)==1
t=t.replace(needle,needle+'\tif id == "plaza":\n\t\treturn ResourceLoader.exists("res://scripts/town/crossroads_painter.gd") and load("res://scripts/town/crossroads_painter.gd").available()\n')
needle='\t\tif id == "board":\n\t\t\tbuildings';assert t.count(needle)==1
t=t.replace(needle,'\t\tif id == "plaza":\n\t\t\tbuildings[id] = load("res://scripts/town/crossroads_painter.gd").attach(self, town)\n\t\t\tcontinue\n'+needle)
needle='\t\tif id == "board":\n\t\t\tload(';assert t.count(needle)==1
t=t.replace(needle,'\t\tif id == "plaza":\n\t\t\tload("res://scripts/town/crossroads_painter.gd").update(b, town, delta)\n\t\t\tcontinue\n'+needle);p.write_text(t)
p=W/'candidate/scripts/town/highbank_ground_painter.gd';t=p.read_text()
needle='\tvar reading_ground: Image';assert t.count(needle)==1
t=t.replace(needle,needle+'\n\tvar plaza_ground: Image')
needle='\t\tif place["id"] == "board":';assert t.count(needle)==1
t=t.replace(needle,'\t\tif place["id"] == "plaza":\n\t\t\tplaza_ground = img.get_region(px)\n'+needle)
needle='\treturn img\n';assert t.count(needle)==1
t=t.replace(needle,'\tif ResourceLoader.exists("res://scripts/town/crossroads_painter.gd"):\n\t\timg = load("res://scripts/town/crossroads_painter.gd").apply(img, plaza_ground)\n'+needle);p.write_text(t)
print('Optional plaza-only view and ground hooks prepared.')
