from pathlib import Path
import shutil
W=Path(__file__).parent; S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
hooks={
'scripts/town/room_painter.gd': [('\t\t_fixtures(id, img)\n','\t\t_fixtures(id, img)\n\t\timg = preload("res://scripts/town/hall_fixtures_art.gd").paint(id, img)\n')],
'scripts/town/hall_floors_art.gd': [('\tif id == "chamber": img.fill_rect(Rect2i(165,240,78,24),Color.BLACK)\n\treturn img','\tif id == "chamber": img.fill_rect(Rect2i(165,240,78,24),Color.BLACK)\n\treturn preload("res://scripts/town/hall_fixtures_art.gd").add_mask(id, img)'), ('\t\tdetail.fill_rect(Rect2i(336,240,48,48),Color.WHITE)\n','\t\tdetail.fill_rect(Rect2i(336,240,48,48),Color.WHITE)\n\t\tdetail = preload("res://scripts/town/hall_fixtures_art.gd").add_mask(id, detail)\n')]}
for rel, replacements in hooks.items():
    raw=(W/'originals'/rel).read_bytes(); text=raw.decode(); newline='\r\n' if '\r\n' in text else '\n';text=text.replace('\r\n','\n')
    for before, after in replacements:
        assert text.count(before)==1,rel
        text=text.replace(before,after)
    (W/'prepared'/rel).write_bytes(text.replace('\n',newline).encode())
for rel in [*hooks,'scripts/town/hall_fixtures_art.gd']:shutil.copy2(W/'prepared'/rel,S/rel)
print('Staged one paint hook, two bounded mask hooks and native helper.')
