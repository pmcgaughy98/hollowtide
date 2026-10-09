from pathlib import Path
W=Path(__file__).parent
P=Path('D:/dev/hollowtide-creature-opening-20261009')
for name in ['opening_check','input_check']:
    text=(P/(name+'.gd')).read_text().replace(P.as_posix()+'/',W.as_posix()+'/')
    if name=='opening_check':
        text=text.replace('await capture("title")','''check("Retro village backdrop installed",menu.get_node("CreatureVillage").texture.resource_path.ends_with("creature_village_2026_10_09.png"))
	check("Menu fits the village composition",menu._main_panel.position.x==44 and menu._main_panel.get_rect().end.y<648)
	await capture("title")
	menu._on_options();await frames(2);await capture("options");menu._close_panel();await frames(2)''')
    (W/(name+'.gd')).write_text(text)
print('Prepared existing native flow/input checks for new menu composition')
