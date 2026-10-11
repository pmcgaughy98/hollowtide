from pathlib import Path
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def edit(r,old,new):
    raw=(W/'originals'/r).read_bytes(); crlf=b'\r\n' in raw
    s=raw.decode('utf-8').replace('\r\n','\n'); assert s.count(old)==1
    s=s.replace(old,new)
    (C/r).write_bytes(s.replace('\n','\r\n').encode('utf-8') if crlf else s.encode('utf-8'))
edit('scripts/town/room_painter.gd','\treturn img\n','\tif id == "home":\n\t\timg = preload("res://scripts/town/home_room_art.gd").paint(img)\n\treturn img\n')
edit('scripts/town/town_room.gd','\tmap.texture = ImageTexture.create_from_image(Painter.paint(room_id, r))\n','\tmap.texture = ImageTexture.create_from_image(Painter.paint(room_id, r))\n\tif room_id == "home":\n\t\tpreload("res://scripts/town/home_room_art.gd").finish(map)\n')
print('Integrated Home art and masked shared finish; all room/controller methods retained.')
