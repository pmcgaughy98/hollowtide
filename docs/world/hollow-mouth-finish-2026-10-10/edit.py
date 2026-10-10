from pathlib import Path
W=Path(__file__).parent
p=W/'candidate/scripts/town/building_exteriors.gd';t=p.read_text()
needle='static func available(id: String) -> bool:\n';assert t.count(needle)==1
t=t.replace(needle,needle+'\tif id == "gate":\n\t\treturn ResourceLoader.exists("res://scripts/town/hollow_mouth_painter.gd") and load("res://scripts/town/hollow_mouth_painter.gd").available()\n')
needle='\t\tif id == "plaza":\n\t\t\tbuildings';assert t.count(needle)==1
t=t.replace(needle,'\t\tif id == "gate":\n\t\t\tbuildings[id] = load("res://scripts/town/hollow_mouth_painter.gd").attach(self, town)\n\t\t\tcontinue\n'+needle)
needle='\t\tvar b: Dictionary = buildings[id]\n';assert t.count(needle)==1
t=t.replace(needle,needle+'\t\tif id == "gate": continue   # Static recess; stepping in is owned by town entry.\n');p.write_text(t)
p=W/'candidate/scripts/town/highbank_ground_painter.gd';t=p.read_text()
needle='\tvar plaza_ground: Image';assert t.count(needle)==1
t=t.replace(needle,needle+'\n\tvar gate_ground: Image')
needle='\t\tif place["id"] == "plaza":';assert t.count(needle)==1
t=t.replace(needle,'\t\tif place["id"] == "gate":\n\t\t\tgate_ground = img.get_region(px)\n'+needle)
needle='\treturn img\n';assert t.count(needle)==1
t=t.replace(needle,'\tif ResourceLoader.exists("res://scripts/town/hollow_mouth_painter.gd"):\n\t\timg = load("res://scripts/town/hollow_mouth_painter.gd").apply(img, gate_ground)\n'+needle);p.write_text(t)
p=W/'run.py';t=p.read_text().replace("if mode=='fallback_painter':", "if mode=='fallback_art': targets=['assets/sprites/world/hollow_mouth_2026_10_10/mouth_native.png','assets/sprites/world/hollow_mouth_2026_10_10/mouth_native.png.import']\nelif mode=='fallback_painter':");p.write_text(t)
print('Optional entrance view / ground hooks prepared; controller untouched.')
